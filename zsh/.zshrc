# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║                          Obsidian Arcana ZSH Config                          ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ═══════════════════════════════════════════════════════════════════════════════
# Oh-My-Zsh Configuration
# ═══════════════════════════════════════════════════════════════════════════════

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme - using a sleek theme that matches the Obsidian Arcana aesthetic
ZSH_THEME="agnoster"

# Uncomment one of these if you prefer a different theme:
# ZSH_THEME="powerlevel10k/powerlevel10k"  # Highly customizable (needs separate install)
# ZSH_THEME="spaceship"                     # Modern and feature-rich (needs separate install)
# ZSH_THEME="robbyrussell"                  # Default oh-my-zsh theme

# ═══════════════════════════════════════════════════════════════════════════════
# Plugin Configuration
# ═══════════════════════════════════════════════════════════════════════════════

# Plugins to load
# Note: zsh-autosuggestions and zsh-syntax-highlighting need to be installed separately
# See the install script for installation commands
plugins=(
    git                       # Git aliases and functions
    zsh-autosuggestions       # Fish-like autosuggestions
    zsh-syntax-highlighting   # Syntax highlighting for commands
    sudo                      # Press ESC twice to add sudo
    history                   # History search and management
    colored-man-pages         # Colorful man pages
    command-not-found         # Suggests packages for unknown commands
    extract                   # Universal archive extraction
    z                         # Quick directory jumping
    docker                    # Docker autocompletion (if docker installed)
    archlinux                 # Arch Linux package manager aliases
)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# ═══════════════════════════════════════════════════════════════════════════════
# Autosuggestions Configuration
# ═══════════════════════════════════════════════════════════════════════════════

# Suggestion highlight color (muted purple to match theme)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#7c6f8c"

# Suggestion strategy (history first, then completion)
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Accept suggestion with right arrow or end key
bindkey '^[[C' forward-char                    # Right arrow accepts one char
bindkey '^[[F' end-of-line                     # End key accepts full suggestion
bindkey '^E' autosuggest-accept                # Ctrl+E accepts suggestion

# ═══════════════════════════════════════════════════════════════════════════════
# Completion Configuration
# ═══════════════════════════════════════════════════════════════════════════════

# Enable completion caching for faster loads
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

# Case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Menu-driven completion with highlighting
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:*:*:descriptions' format '%F{purple}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{yellow}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'

# Group matches
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:-command-:*:*' group-order aliases builtins functions commands

# Fuzzy matching for mistyped commands
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 2 numeric

# ═══════════════════════════════════════════════════════════════════════════════
# History Configuration
# ═══════════════════════════════════════════════════════════════════════════════

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history

# History options
setopt EXTENDED_HISTORY          # Write timestamps to history
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicates
setopt HIST_IGNORE_SPACE         # Don't record entries starting with space
setopt HIST_FIND_NO_DUPS         # Don't display duplicates during search
setopt HIST_SAVE_NO_DUPS         # Don't write duplicates to history file
setopt SHARE_HISTORY             # Share history between sessions
setopt INC_APPEND_HISTORY        # Add commands as they are typed

# History search with arrow keys (type part of command, then up/down)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ═══════════════════════════════════════════════════════════════════════════════
# Key Bindings
# ═══════════════════════════════════════════════════════════════════════════════

# Use vim keybindings (comment out for emacs mode)
# bindkey -v

# Better word navigation
bindkey '^[[1;5C' forward-word     # Ctrl+Right
bindkey '^[[1;5D' backward-word    # Ctrl+Left
bindkey '^H' backward-kill-word    # Ctrl+Backspace

# Home and End keys
bindkey '^[[H' beginning-of-line
bindkey '^[[4~' end-of-line

# Delete key
bindkey '^[[3~' delete-char

# ═══════════════════════════════════════════════════════════════════════════════
# Aliases
# ═══════════════════════════════════════════════════════════════════════════════

# File listing with colors
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# Safety nets
alias rm='rm -iv'
alias cp='cp -iv'
alias mv='mv -iv'

# Colorful output
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Arch Linux package management
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || echo "No orphans to clean"'

# AUR helper (yay)
alias yay-update='yay -Syu'
alias yay-clean='yay -Sc'

# System info
alias myip='curl -s https://ipinfo.io/ip'
alias ports='ss -tulanp'
alias mem='free -h'
alias df='df -h'

# Git shortcuts (on top of oh-my-zsh git plugin)
alias gs='git status'
alias gp='git push'
alias gc='git commit -m'
alias gd='git diff'

# Quick edit configs
alias zshrc='${EDITOR:-micro} ~/.zshrc'
alias hyprconf='${EDITOR:-micro} ~/.config/hypr/hyprland.conf'

# ═══════════════════════════════════════════════════════════════════════════════
# Environment Variables
# ═══════════════════════════════════════════════════════════════════════════════

# Default editor
export EDITOR='micro'
export VISUAL='micro'

# Better less behavior
export LESS='-R --use-color -Dd+r$Du+b'

# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Path additions (uncomment and modify as needed)
# export PATH="$HOME/.local/bin:$PATH"
# export PATH="$HOME/.cargo/bin:$PATH"

# ═══════════════════════════════════════════════════════════════════════════════
# Custom Prompt Segment (for agnoster theme)
# ═══════════════════════════════════════════════════════════════════════════════

# Shorten directory display to 2 levels
PROMPT_DIRTRIM=2

# Remove username@hostname from prompt (uncomment if needed)
# prompt_context() {}

# ═══════════════════════════════════════════════════════════════════════════════
# Auto-start / Extra Functions
# ═══════════════════════════════════════════════════════════════════════════════

# Fastfetch on terminal open (uncomment if desired)
fastfetch

# Quick directory creation and cd
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
ex() {
    if [ -f "$1" ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1   ;;
            *.tar.gz)    tar xzf $1   ;;
            *.tar.xz)    tar xJf $1   ;;
            *.bz2)       bunzip2 $1   ;;
            *.rar)       unrar x $1   ;;
            *.gz)        gunzip $1    ;;
            *.tar)       tar xf $1    ;;
            *.tbz2)      tar xjf $1   ;;
            *.tgz)       tar xzf $1   ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1;;
            *.7z)        7z x $1      ;;
            *)           echo "'$1' cannot be extracted via ex()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# FZF Integration (if installed)
# ═══════════════════════════════════════════════════════════════════════════════

# Source fzf if available
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

# FZF theme matching Obsidian Arcana
export FZF_DEFAULT_OPTS="
  --color=bg+:#1a1a2e,bg:#0d0d17,spinner:#9d4edd,hl:#7b2cbf
  --color=fg:#c9c9e0,header:#7b2cbf,info:#9d4edd,pointer:#ff6b6b
  --color=marker:#9d4edd,fg+:#ffffff,prompt:#9d4edd,hl+:#e040fb
  --border='rounded' --border-label='' --preview-window='border-rounded'
  --prompt='❯ ' --marker='◆' --pointer='▶' --separator='─'
"

# ═══════════════════════════════════════════════════════════════════════════════
# End of Configuration
# ═══════════════════════════════════════════════════════════════════════════════
