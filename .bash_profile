# .bash_profile

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n 2> /dev/null || true

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin:/fieldsets-bin

export PATH