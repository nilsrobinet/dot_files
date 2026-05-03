# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt extendedglob
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/nilsr/.zshrc'
# case insensitive path-completion 
#zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

autoload -Uz compinit
compinit
# End of lines added by compinstall
bindkey    "^[[H"    beginning-of-line
bindkey    "^[[F"    end-of-line
bindkey    "^[[3~"    delete-char
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '[%b]'

setopt PROMPT_SUBST

# Show host only when connected via SSH
ssh_host='%(!.%F{red}.%F{green})%m%f'  # optional color + %m=short hostname
ssh_host=''                             # default empty

if [[ -n ${SSH_CONNECTION-} || -n ${SSH_CLIENT-} || -n ${SSH_TTY-} ]]; then
  ssh_host='%F{yellow}%m%f'
fi

PROMPT='${ssh_host}:%F{blue}%~%f %F{red}${vcs_info_msg_0_}%f$ '

source $HOME/.aliases
