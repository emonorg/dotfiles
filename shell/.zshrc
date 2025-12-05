export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="bira"

plugins=(git)

source $ZSH/oh-my-zsh.sh

eval $(/opt/homebrew/bin/brew shellenv)

# Set default GCC to GNU version
export PATH="/opt/homebrew/bin:$PATH"
alias gcc="gcc-15"

alias "vim"="nvim"
alias "vi"="nvim"
alias "lg"="lazygit"

export SDKROOT=$(xcrun --show-sdk-path)

export PATH="/Users/emadmamaghani/.deno/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/Users/emadmamaghani/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


autoload -Uz vcs_info

# Enable git for vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '%b'

precmd() {
  vcs_info  # updates $vcs_info_msg_0_

  # Gruvbox-ish colors
  local USER="%n"
  local DIR="%F{214}%1~%f"      # yellow dir
  local BRANCH=""

  if [[ -n ${vcs_info_msg_0_} ]]; then
    BRANCH=" (%F{67}${vcs_info_msg_0_}%f)"   # blue branch
  fi

  PROMPT="[$USER $DIR]$BRANCH | "
}

export PATH="/usr/local/bin:$PATH"

[[ -s "/Users/emadmamaghani/.gvm/scripts/gvm" ]] && source "/Users/emadmamaghani/.gvm/scripts/gvm"

