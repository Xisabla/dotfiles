export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"
# ZSH_THEME="candy"

plugins=(direnv git history rsync zsh-autosuggestions zsh-completions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

setopt autocd
setopt autopushd
setopt correct
setopt extendedglob
setopt numericglobsort

autoload -U compinit
compinit

# Auto launch tmux
# if which tmux 2>&1 >/dev/null; then                         # use tmux by default
#     if [ ! "$USER" = "notmux" ] && [ "$TMUX" = "" ] && [ $TERM != "screen-256color" ] && [  $TERM != "screen" ]; then
#         tmux attach -t terminal || tmux new -s terminal; exit
#     fi
# fi

# User configuration

# - Path
[[ -d "$HOME/.bin" ]]                           && export PATH="$PATH:$HOME/.bin"
[[ -d "$HOME/.local/bin" ]]                     && export PATH="$PATH:$HOME/.local/bin"

[[ -d "/usr/local/go/bin" ]]                    && export PATH="$PATH:/usr/local/go/bin"
[[ -d "$HOME/go/bin" ]]                         && export PATH="$PATH:$HOME/go/bin"

# - Source
[[ -f "$HOME/.tools/proxy.sh" ]]                && source "$HOME/.tools/proxy.sh"
[[ -f "$HOME/.fzf.zsh" ]]                       && source "$HOME/.fzf.zsh"
[[ -f "$HOME/.p10k.zsh" ]]                      && source "$HOME/.p10k.zsh"

[[ -f "$HOME/.cargo/env" ]]                     && source "$HOME/.cargo/env"


# - Aliases
alias bat="batcat"
alias xclip="xclip -selection clipboard"
alias ssh="TERM=xterm ssh"
alias vim="nvim"

alias dev="cd ~/Dev"
alias shared="cd ~/Shared"

# - Exports
export CC="clang"
export CCX="clang++"

export NVM_DIR="$HOME/.nvm"

export EDITOR="vim"
export GPG_TTY=$(tty)

# - Others
eval `ssh-agent`

[[ -s "$NVM_DIR/nvm.sh" ]]              && \. "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]]     && \. "$NVM_DIR/bash_completion"
