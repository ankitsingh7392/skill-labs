# Pro Dev Terminal Setup (macOS + iTerm2)

A complete guide to setting up a professional developer terminal from scratch.

---

## 1. iTerm2

Better terminal than the default macOS Terminal.

```bash
brew install --cask iterm2
```

**Recommended settings (inside iTerm2 Preferences):**
- Profiles → Colors → Color Presets → `Solarized Dark` or `One Dark`
- Profiles → Text → Font → `MesloLGS NF` size 13 (required for Powerlevel10k icons)
- Profiles → Window → Columns: 220, Rows: 50
- General → Closing → uncheck "Confirm closing multiple sessions"

**Install MesloLGS NF font:**
```bash
brew install --cask font-meslo-lg-nerd-font
```

---

## 2. Homebrew

Package manager for macOS.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Add to `~/.zshrc` to stop brew auto-updating on every command:
```zsh
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1
```

Run updates manually when you're ready:
```bash
brew update && brew upgrade && brew cleanup
# or with the alias:
brewup
```

---

## 3. Oh My Zsh

Framework that manages zsh plugins and themes.

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

---

## 4. Powerlevel10k (prompt theme)

Fast, feature-rich prompt with git status, time, exit codes, and more.

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
```

Add to `~/.zshrc`:
```zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
source ~/powerlevel10k/powerlevel10k.zsh-theme
```

Configure it:
```bash
p10k configure
```

---

## 5. Plugins

### zsh-autosuggestions
Shows command suggestions as you type (grey text). Press `→` to accept.

```bash
brew install zsh-autosuggestions
```

Add to plugins in `~/.zshrc`:
```zsh
plugins=(git zsh-autosuggestions)
```

### zsh-syntax-highlighting
Colours commands green (valid) or red (not found) as you type.

```bash
brew install zsh-syntax-highlighting
```

Add to `~/.zshrc`:
```zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

---

## 6. fzf (fuzzy finder)

Interactive fuzzy search for history, files, and directories.

```bash
brew install fzf
$(brew --prefix)/opt/fzf/install --all --no-bash --no-fish
```

**Key bindings after install:**
| Shortcut | Action |
|---|---|
| `Ctrl+R` | Fuzzy search command history |
| `Ctrl+T` | Fuzzy find files in current dir |
| `Alt+C` | Fuzzy cd into a subdirectory |

---

## 7. zoxide (smarter cd)

Remembers your most visited directories. Type `z` instead of the full path.

```bash
brew install zoxide
```

Add to `~/.zshrc`:
```zsh
eval "$(zoxide init zsh)"
```

**Usage:**
```bash
z project-ark        # jump to ~/Desktop/ankit-github/project-ark
z skill              # jump to skill-labs
zi                   # interactive fuzzy picker for your history
```

---

## 8. bat (better cat)

Syntax-highlighted file viewer with line numbers and git diff markers.

```bash
brew install bat
```

Add alias to `~/.zshrc`:
```zsh
alias cat='bat'
```

**Usage:**
```bash
cat main.py          # syntax highlighted
bat --plain main.py  # no line numbers, plain output
bat -n main.py       # line numbers only, no highlighting
```

---

## 9. eza (better ls)

Modern ls replacement with icons, colours, and git status.

```bash
brew install eza
```

Add aliases to `~/.zshrc`:
```zsh
alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias lt='eza --tree --icons --level=2'
```

**Usage:**
```bash
ls              # files with icons
ll              # detailed list with git status
lt              # tree view 2 levels deep
lt --level=3    # tree view 3 levels deep
```

---

## 10. History settings

Add to `~/.zshrc` — these are not set by default:

```zsh
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS    # no duplicate entries
setopt HIST_IGNORE_SPACE   # commands starting with space are not saved
setopt SHARE_HISTORY       # share history across all open tabs instantly
setopt HIST_VERIFY         # preview before running a history command
```

---

## 11. Useful aliases

```zsh
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'
alias gpl='git pull'

# Brew
alias brewup='brew update && brew upgrade && brew cleanup'

# Shell
alias reload='source ~/.zshrc'
alias zshrc='code ~/.zshrc'
```

---

## Full ~/.zshrc reference

```zsh
# Enable Powerlevel10k instant prompt. Should stay at the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Homebrew
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# History
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt HIST_VERIFY

# PATH
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Editor
export EDITOR='code'
export VISUAL='code'

# Syntax highlighting & theme
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/powerlevel10k/powerlevel10k.zsh-theme

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide
eval "$(zoxide init zsh)"

# Aliases: navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Aliases: listing
alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias lt='eza --tree --icons --level=2'

# Aliases: file viewing
alias cat='bat'

# Aliases: git
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'
alias gpl='git pull'

# Aliases: brew
alias brewup='brew update && brew upgrade && brew cleanup'

# Aliases: misc
alias reload='source ~/.zshrc'
alias zshrc='code ~/.zshrc'

# Global credentials
source ~/.secrets/.env

# Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```

---

## Quick install checklist

```bash
# 1. iTerm2
brew install --cask iterm2
brew install --cask font-meslo-lg-nerd-font

# 2. Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 3. Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

# 4. Plugins
brew install zsh-autosuggestions zsh-syntax-highlighting

# 5. Tools
brew install fzf zoxide bat eza
$(brew --prefix)/opt/fzf/install --all --no-bash --no-fish

# 6. Configure p10k
p10k configure
```
