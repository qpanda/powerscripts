bindkey '^r' history-incremental-pattern-search-backward
bindkey '^f' history-incremental-pattern-search-forward
bindkey '^u' kill-region
bindkey '^o' push-input
bindkey '^x^e' edit-command-line

setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt INTERACTIVE_COMMENTS

alias hist="history 0"
alias lls="ls -lah"
alias sls="ls -1a"
alias iless="less -iS"
alias fless="less -iS +F"

export HISTSIZE=10000
export SAVEHIST=10000
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
export PROMPT='%F{cyan}%n@%m%f %F{blue}%1~%f %(?.%F{green}%#%f.%F{red}%#%f) '

autoload -U compinit && compinit
autoload -U edit-command-line && zle -N edit-command-line
