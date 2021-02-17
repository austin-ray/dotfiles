for FILE in "$HOME"/.zshrc.d/*.sh; do
  source "$FILE"
done

export GPG_TTY=$(tty)
export TERM=xterm-256color
export VISUAL=nvim
if [ -e /home/aray/.nix-profile/etc/profile.d/nix.sh ]; then . /home/aray/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
