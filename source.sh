#!/bin/bash

DOTFILES_DIR=$HOME/dotfiles

git config --global include.path "$DOTFILES_DIR/gitconfig"

NVIM_INIT=$HOME/.config/nvim/init.vim

if test -f "$NVIM_INIT"; then
    mv "$NVIM_INIT" "${NVIM_INIT}.bak"
fi

cat <<-EOT | tee $NVIM_INIT $HOME/.vimrc > /dev/null
let \$DOTFILE=expand("\$HOME/dotfiles/nvim/init.vim")
if filereadable(\$DOTFILE)
    source \$DOTFILE
endif
EOT







