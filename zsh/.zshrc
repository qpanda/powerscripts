bindkey '^r' history-incremental-search-backward
bindkey '^f' history-incremental-search-forward
bindkey '^u' kill-region
bindkey '^o' push-input

setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt INTERACTIVE_COMMENTS

export HISTSIZE=10000
export SAVEHIST=10000
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
export PROMPT='%F{cyan}%n@%m%f %F{blue}%1~%f %(?.%F{green}%#%f.%F{red}%#%f) '

autoload -U compinit && compinit
