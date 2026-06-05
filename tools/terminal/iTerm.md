# Pro Dev Terminal — Setup & Cheat Sheet

Everything in one place: setup, config, and daily commands for every tool.

---

## Quick Install (fresh Mac)

```bash
# 1. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. iTerm2 + font
brew install --cask iterm2
brew install --cask font-meslo-lg-nerd-font

# 3. Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 4. Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

# 5. Plugins
brew install zsh-autosuggestions zsh-syntax-highlighting

# 6. Core tools
brew install fzf zoxide bat eza git-delta ripgrep fd tldr httpie tmux jq yq

# 7. Dev tools
brew install lazygit lazydocker k9s helm kubectl minikube

# 8. fzf shell integration
$(brew --prefix)/opt/fzf/install --all --no-bash --no-fish

# 9. Configure prompt
p10k configure
```

---

## iTerm2 — Appearance

**Font:** MesloLGS NF, size 13
`Preferences → Profiles → Text → Font`

**Colour scheme:** Catppuccin Mocha (dark, easy on eyes)
`Preferences → Profiles → Colors → Color Presets → Catppuccin-Mocha`

**Theme:** Minimal
`Preferences → Appearance → General → Theme → Minimal`

**Window size:** 220 cols × 50 rows
`Preferences → Profiles → Window`

**Key shortcuts:**
| Shortcut | Action |
|---|---|
| `Cmd+D` | Split pane vertically |
| `Cmd+Shift+D` | Split pane horizontally |
| `Cmd+[` / `Cmd+]` | Switch between panes |
| `Cmd+T` | New tab |
| `Cmd+Shift+Enter` | Maximise pane |
| `Cmd+K` | Clear screen |

---

## fzf — Fuzzy Finder

**Key bindings (active in every terminal session):**
| Shortcut | Action |
|---|---|
| `Ctrl+R` | Fuzzy search command history |
| `Ctrl+T` | Fuzzy find files in current directory |
| `Alt+C` | Fuzzy cd into a subdirectory |

**Usage in commands:**
```bash
# Preview files while fuzzy finding
fzf --preview 'bat --color=always {}'

# Kill a process interactively
kill -9 $(ps aux | fzf | awk '{print $2}')

# Open a file in VS Code
code $(fzf)

# Checkout a git branch interactively
git checkout $(git branch | fzf)
```

---

## zoxide — Smarter cd

Learns your most visited directories. Replaces `cd` for common destinations.

```bash
z project-ark          # jump to ~/Desktop/ankit-github/project-ark
z skill                # jump to skill-labs
z down                 # jump to ~/Downloads
zi                     # interactive fuzzy picker from your history
zoxide query --list    # show all remembered directories with scores
```

---

## bat — Better cat

Syntax-highlighted file viewer.

```bash
cat main.py             # syntax highlighted with line numbers
bat --plain main.py     # plain output, no decorations
bat -n main.py          # line numbers only
bat -A main.py          # show non-printable characters
bat *.py                # view multiple files
bat --diff file.py      # show git diff inline
```

---

## eza — Better ls

```bash
ls                      # files with icons
ll                      # detailed list with git status and icons
lt                      # tree view, 2 levels deep
lt --level=3            # tree view, 3 levels deep
eza -lah --sort=size    # sort by file size
eza -lah --sort=modified # sort by last modified
eza --only-dirs         # show directories only
```

---

## ripgrep (rg) — Fast Search

Faster than grep, respects .gitignore automatically.

```bash
rg "function"           # search for "function" in current directory
rg "TODO" src/          # search in specific folder
rg -t py "import"       # search only Python files
rg -l "pattern"         # list files that match (no content)
rg -i "error"           # case-insensitive search
rg "old" --replace "new" # preview replacements
rg --stats "pattern"    # show match statistics
```

---

## fd — Better find

```bash
fd main.py              # find files named main.py
fd -e py                # find all .py files
fd -t d node_modules    # find directories named node_modules
fd "test" src/          # search in specific folder
fd -x rm {}             # find and delete (careful!)
fd --hidden .env        # include hidden files
```

---

## jq — JSON Processor

```bash
cat data.json | jq .            # pretty print
cat data.json | jq '.name'      # extract field
cat data.json | jq '.users[]'   # iterate array
cat data.json | jq '.users[] | select(.active == true)'  # filter
curl api.example.com | jq .     # pretty print API response
jq -r '.name' data.json         # raw output (no quotes)
jq 'keys' data.json             # list all top-level keys
```

---

## yq — YAML Processor

```bash
yq '.' config.yaml              # pretty print
yq '.database.host' config.yaml # extract field
yq -i '.version = "2.0"' app.yaml  # edit in place
yq '. | keys' config.yaml       # list keys
yq -o json config.yaml          # convert YAML to JSON
```

---

## httpie — Better curl

```bash
http GET api.example.com/users              # GET request
http POST api.example.com/users name="Ankit" email="a@b.com"  # POST with body
http PUT api.example.com/users/1 name="New" # PUT
http DELETE api.example.com/users/1         # DELETE
http GET api.example.com/data Authorization:"Bearer TOKEN"    # with header
http --json POST api.example.com/data < body.json             # from file
```

---

## tldr — Simplified Man Pages

Quick examples for any command — much faster than `man`.

```bash
tldr git             # git examples
tldr docker          # docker examples
tldr kubectl         # kubectl examples
tldr tar             # tar examples
tldr ffmpeg          # ffmpeg examples
tldr --update        # update the local cache
```

---

## tmux — Terminal Multiplexer

Persistent sessions that survive terminal close. Essential for remote work.

**Start / attach:**
```bash
tmux                        # new session
tmux new -s work            # new named session
tmux attach -t work         # re-attach to session
tmux ls                     # list sessions
tmux kill-session -t work   # kill session
```

**Inside tmux (prefix = Ctrl+B):**
| Shortcut | Action |
|---|---|
| `Ctrl+B c` | New window |
| `Ctrl+B ,` | Rename window |
| `Ctrl+B n` / `p` | Next / previous window |
| `Ctrl+B %` | Split vertically |
| `Ctrl+B "` | Split horizontally |
| `Ctrl+B arrow` | Switch pane |
| `Ctrl+B d` | Detach (session keeps running) |
| `Ctrl+B [` | Scroll mode (q to exit) |
| `Ctrl+B z` | Zoom pane toggle |

---

## lazygit — TUI Git Client

The fastest way to manage git. Launch with `lg`.

```bash
lg    # open lazygit in current repo
```

**Inside lazygit:**
| Key | Action |
|---|---|
| `Space` | Stage / unstage file |
| `c` | Commit |
| `P` | Push |
| `p` | Pull |
| `b` | Branch menu |
| `m` | Merge |
| `r` | Rebase |
| `d` | Diff |
| `?` | Help / all shortcuts |
| `q` | Quit |

---

## lazydocker — TUI Docker Manager

Visual dashboard for containers, images, volumes. Launch with `ld`.

```bash
ld    # open lazydocker
```

**Inside lazydocker:**
| Key | Action |
|---|---|
| `[` / `]` | Navigate panels |
| `Enter` | Select / expand |
| `s` | Stop container |
| `r` | Restart container |
| `d` | Remove container/image |
| `l` | View logs |
| `e` | Exec into container |
| `?` | Help |
| `q` | Quit |

---

## k9s — Kubernetes TUI

Full Kubernetes cluster management from the terminal. Launch with `k9s`.

```bash
k9s                     # connect to current context
k9s --context prod      # connect to specific context
k9s --namespace default # specific namespace
```

**Inside k9s:**
| Key | Action |
|---|---|
| `:pod` | View pods |
| `:svc` | View services |
| `:deploy` | View deployments |
| `:ns` | View namespaces |
| `:node` | View nodes |
| `l` | View logs |
| `s` | Shell into pod |
| `d` | Describe resource |
| `Ctrl+D` | Delete resource |
| `/` | Filter/search |
| `?` | Help |
| `q` | Quit |

---

## kubectl — Kubernetes CLI

```bash
kubectl get pods                          # list pods
kubectl get pods -n kube-system          # specific namespace
kubectl get pods -o wide                  # with node info
kubectl describe pod <name>              # full details
kubectl logs <pod>                        # view logs
kubectl logs -f <pod>                     # follow logs
kubectl exec -it <pod> -- /bin/sh        # shell into pod
kubectl apply -f deployment.yaml         # apply manifest
kubectl delete -f deployment.yaml        # delete from manifest
kubectl get all                           # get everything
kubectl config get-contexts              # list contexts
kubectl config use-context <name>        # switch context
```

---

## git-delta — Better Git Diffs

Automatically used when you run `git diff`, `git log -p`, `git show`.

```bash
git diff                  # delta-powered syntax-highlighted diff
git log -p                # commits with highlighted diffs
git show HEAD             # last commit with highlighted diff
```

Configure in `~/.gitconfig` for permanent use:
```ini
[core]
    pager = delta
[delta]
    navigate = true
    side-by-side = true
    line-numbers = true
```

---

## Aliases Reference

All aliases defined in `~/.zshrc`:

```bash
# Navigation
..          → cd ..
...         → cd ../..
....        → cd ../../..

# Files
ls          → eza --icons
ll          → eza -lah --icons --git
lt          → eza --tree --icons --level=2
cat         → bat

# Git
gs          → git status
gl          → git log --oneline --graph --decorate
gp          → git push
gpl         → git pull
lg          → lazygit

# Docker
ld          → lazydocker
dps         → docker ps
dpa         → docker ps -a
dlog        → docker logs -f

# Kubernetes
k           → kubectl
kgp         → kubectl get pods
kgs         → kubectl get services
kgn         → kubectl get nodes
kctx        → kubectl config current-context

# Search
rg          → rg --smart-case
find        → fd

# Data
json        → jq .
yaml        → yq .

# Network
ip          → curl -s ifconfig.me
ports       → lsof -i -P -n | grep LISTEN

# Shell
reload      → source ~/.zshrc
zshrc       → code ~/.zshrc
brewup      → brew update && brew upgrade && brew cleanup
```
