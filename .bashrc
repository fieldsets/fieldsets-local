# .bashrc

# Source global definitions
if [ -f /etc/bash.bashrc ]; then
	. /etc/bash.bashrc
fi

# You may uncomment the following lines if you want `ls' to be colorized:
export SHELL=/bin/bash
export TERM=xterm-256color
export LS_OPTIONS='--color=auto'
eval "$(dircolors)"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# User specific aliases and functions