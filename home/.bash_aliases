#!/bin/bash

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias dsz='find $(pwd -P) -maxdepth 1 -type d -exec du -sh {} + 2>/dev/null | sort -h'
alias gensums='[[ -f PKGBUILD ]] && makepkg -g >> PKGBUILD'
alias getflags='unset CPPFLAGS; eval $(sed -rn "s/^((C|LD|MAKE)FLAGS)/export \1/p" /etc/makepkg.conf)'
alias grep='grep --color'
alias info='info --vi-keys'
alias j='jobs'
alias ll='ls -l --color'
alias lla='ls -la --color'
alias ls='ls --group-directories-first --color'
alias sudo='sudo '
alias udevinfo='udevadm info -q all -n'
alias webshare='python -m http.server 8080'
alias wgetxc='wget $(xclip -o)'
alias grep="grep --binary-files=without-match --directories=skip --color=auto"
