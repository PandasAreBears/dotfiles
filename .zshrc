path=(
  $path
  ~/.local/bin
  ~/.local/bin/nvim-macos-arm64/bin
  ~/.cargo/bin
  ~/.local/include
  ~/.local/lib
)

export CLICOLOR=1

alias less="less -r"
alias reload="source ~/.zshrc"
alias vi=nvim
alias vim=nvim
alias shut="sudo shutdown -p now"

function restow() {
	pushd ~/.dotfiles
	stow .
	popd
}

set -o vi

NEWLINE=$'\n'
export PS1="%F{#4c4f69}%T %F{#94e2d5}%1~ ${NEWLINE}%F{#7287fd}-> %F{#f5e0dc}"

source "$HOME/.config/zsh/extras.sh"
