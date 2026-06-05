from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import HTMLResponse, FileResponse, RedirectResponse
from pathlib import Path
import shutil
import socket
import urllib.parse
import tempfile
import time


"""
pip install fastapi uvicorn python-multipart
uvicorn data_transfer:app --host 0.0.0.0 --port 8080
"""
app = FastAPI()

# Store uploads in system temp folder
UPLOAD_DIR = Path(tempfile.gettempdir()) / "local_file_share"
UPLOAD_DIR.mkdir(exist_ok=True)

# Optional cleanup: delete files older than 24 hours on startup
MAX_FILE_AGE_SECONDS = 24 * 60 * 60


def cleanup_old_files():
    now = time.time()
    for f in UPLOAD_DIR.iterdir():
        if f.is_file():
            age = now - f.stat().st_mtime
            if age > MAX_FILE_AGE_SECONDS:
                try:
                    f.unlink()
                except Exception:
                    pass


cleanup_old_files()


def get_local_ip() -> str:
    """
    Detect the local LAN IP of this machine.
    """
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = "127.0.0.1"
    finally:
        s.close()
    return ip


def human_size(num_bytes: int) -> str:
    """
    Convert bytes into KB/MB/GB for display.
    """
    units = ["B", "KB", "MB", "GB", "TB"]
    size = float(num_bytes)
    for unit in units:
        if size < 1024 or unit == units[-1]:
            return f"{size:.2f} {unit}"
        size /= 1024


@app.get("/", response_class=HTMLResponse)
def home():
    files = []
    for f in sorted(UPLOAD_DIR.iterdir(), key=lambda x: x.stat().st_mtime, reverse=True):
        if f.is_file():
            files.append((f.name, f.stat().st_size))

    file_items = "".join(
        f"""
        <li class="file-item">
            <div>
                <div class="file-name">{name}</div>
                <div class="file-size">{human_size(size)} ({size} bytes)</div>
            </div>
            <a class="download-btn" href="/download/{urllib.parse.quote(name)}">Download</a>
        </li>
        """
        for name, size in files
    )

    server_ip = get_local_ip()

    return f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Local File Share</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <style>
            body {{
                font-family: Arial, sans-serif;
                max-width: 760px;
                margin: 30px auto;
                padding: 16px;
                background: #f7f7f7;
                color: #222;
            }}
            .card {{
                background: white;
                border-radius: 14px;
                padding: 20px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.08);
                margin-bottom: 20px;
            }}
            h1 {{
                margin-top: 0;
            }}
            .server-link {{
                word-break: break-all;
                font-size: 18px;
                margin: 10px 0;
            }}
            form {{
                display: flex;
                flex-direction: column;
                gap: 12px;
            }}
            input[type="file"] {{
                padding: 10px;
                background: #fafafa;
                border: 1px solid #ddd;
                border-radius: 8px;
            }}
            button {{
                width: 140px;
                padding: 12px 16px;
                border: none;
                border-radius: 10px;
                background: #111;
                color: white;
                cursor: pointer;
                font-size: 15px;
            }}
            button:hover {{
                opacity: 0.9;
            }}
            ul {{
                list-style: none;
                padding: 0;
                margin: 0;
            }}
            .file-item {{
                display: flex;
                justify-content: space-between;
                align-items: center;
                gap: 12px;
                padding: 14px 12px;
                border-bottom: 1px solid #eee;
            }}
            .file-name {{
                font-weight: 600;
                word-break: break-word;
            }}
            .file-size {{
                font-size: 13px;
                color: #666;
                margin-top: 4px;
            }}
            .download-btn {{
                text-decoration: none;
                padding: 10px 14px;
                border-radius: 8px;
                background: #efefef;
                color: #111;
                white-space: nowrap;
            }}
            .muted {{
                color: #666;
                font-size: 14px;
            }}
            code {{
                background: #f1f1f1;
                padding: 2px 6px;
                border-radius: 6px;
            }}
        </style>
    </head>
    <body>
        <div class="card">
            <h1>Local File Share</h1>
            <p class="muted">Open this link on any mobile connected to the same Wi-Fi:</p>
            <div class="server-link">
                <a href="http://{server_ip}:8080">http://{server_ip}:8080</a>
            </div>
            <p class="muted">Files are stored temporarily in: <code>{UPLOAD_DIR}</code></p>
        </div>

        <div class="card">
            <h2>Upload File</h2>
            <form action="/upload" enctype="multipart/form-data" method="post">
                <input name="file" type="file" required />
                <button type="submit">Upload</button>
            </form>
        </div>

        <div class="card">
            <h2>Available Files</h2>
            <ul>
                {file_items if file_items else "<li class='muted'>No files uploaded yet.</li>"}
            </ul>
        </div>
    </body>
    </html>
    """


@app.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    if not file.filename:
        raise HTTPException(status_code=400, detail="No filename provided")

    safe_name = Path(file.filename).name
    destination = UPLOAD_DIR / safe_name

    with destination.open("wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return RedirectResponse(url="/", status_code=303)


@app.get("/download/{filename}")
def download_file(filename: str):
    safe_name = Path(filename).name
    file_path = UPLOAD_DIR / safe_name

    if not file_path.exists() or not file_path.is_file():
        raise HTTPException(status_code=404, detail="File not found")

    return FileResponse(
        path=file_path,
        filename=safe_name,
        media_type="application/octet-stream"
    )