#!/usr/bin/env bash

cd "$(dirname "${0}")/../"

VADER_DIRECTORY="~/.config/nvim/bundle/vader.vim"

read -r -d '' CMD_LINE_CONFIG <<'EOF'
filetype off
set rtp+=~/.config/nvim/bundle/vader.vim
set rtp+=.
filetype plugin indent on
syntax enable
EOF

# CMD_LINE_CONFIG=${CMD_LINE_CONFIG//[$'\t\r\n']}
echo "CMD_LINE_CONFIG = '$CMD_LINE_CONFIG'"

# echo "${CMD_LINE_CONFIG}" | vim -Nu +Vader! test/*.vader

vim -Nu <(cat << "EOF"
filetype off
set rtp+=~/.config/nvim/bundle/vader.vim
set rtp+=.
filetype plugin indent on
syntax enable
EOF) +Vader test/*.vader
