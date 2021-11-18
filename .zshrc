# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Zsh stuff
export ZSH="/home/gautier/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(direnv git history rsync zsh-autosuggestions zsh-completions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

setopt autocd
setopt autopushd
setopt correct

autoload -U compinit
compinit

# User configuration
if which tmux 2>&1 >/dev/null; then                         # use tmux
    if [ "$TMUX" = "" ] && [ $TERM != "screen-256color" ] && [  $TERM != "screen" ]; then
        tmux attach -t terminal || tmux new -s terminal; exit
    fi
fi


export PATH="/home/gautier/.bin:$PATH"

alias glow="glow -p"
alias nano="vim"

# Defaults
export EDITOR=vim

# Sources
[[ ! -f ~/.p10k.zsh ]]          || source ~/.p10k.zsh       # power10k
[[ ! -f ~/.oc_completion ]]     || source ~/.oc_completion  # working with oc
[[ ! -f ~/.tools/proxy.sh ]]    || source ~/.tools/proxy.sh # custom proxy tool

# SSH
if [[ -f "$HOME/.ssh/wsl2-ssh-pageant.exe" ]]; then         # see: https://github.com/BlackReloaded/wsl2-ssh-pageant
    export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"

    if ! ss -a | grep -q "$SSH_AUTH_SOCK"; then
        rm -f "$SSH_AUTH_SOCK"
        wsl2_ssh_pageant_bin="$HOME/.ssh/wsl2-ssh-pageant.exe"
        if test -x "$wsl2_ssh_pageant_bin"; then
            (setsid nohup socat UNIX-LISTEN:"$SSH_AUTH_SOCK,fork" EXEC:"$wsl2_ssh_pageant_bin" >/dev/null 2>&1 &)
        else
            echo >&2 "WARNING: $wsl2_ssh_pageant_bin is not executable."
        fi
        unset wsl2_ssh_pageant_bin
    fi
fi

eval `ssh-agent`

# nvm
if [[ -f "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi
