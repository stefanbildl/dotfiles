# User configuration

# Preferred editor for local and remote sessions
export EDITOR='nvim'
alias e=nvim
alias vim=nvim

bindkey -v

eval "$(starship init zsh)"

bindkey ^R history-incremental-search-backward 
bindkey ^S history-incremental-search-forward

[ -s "./environment.sh" ] && \. "./environment.sh"  # This loads my work or personal environment
