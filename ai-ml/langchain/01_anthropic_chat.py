from langchain_anthropic import ChatAnthropic
from dotenv import load_dotenv

load_dotenv()

model = ChatAnthropic(
    model="claude-haiku-4-5-20251001",
    # temperature=,
    # max_tokens=,
    # timeout=,
    # max_retries=,
    # ...
)
import getpass
import os 

if "ANTHROPIC_API_KEY" not in os.environ:
    os.environ["ANTHROPIC_API_KEY"] = getpass.getpass("Please enter the key:")

    
model = ChatAnthropic(
    model="claude-haiku-4-5-20251001",
    # temperature=,
    # max_tokens=,
    # timeout=,
    # max_retries=,
    # ...
)
response = model.invoke("Hello!")
print(f"{response.content}")
