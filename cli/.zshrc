for FILE in "$HOME"/.zshrc.d/*.sh; do
  source "$FILE"
done

export GPG_TTY=$(tty)
export TERM=xterm-256color
export VISUAL=nvim

bindkey '^N' forward-word
bindkey '^Y' autosuggest-accept
