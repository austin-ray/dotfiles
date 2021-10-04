#!/bin/zsh
if which fzf >/dev/null 2>&1; then
  source /usr/share/fzf/key-bindings.zsh
  source /usr/share/zsh/site-functions/_fzf

  bindkey -M vicmd '?' fzf-history-widget
fi
