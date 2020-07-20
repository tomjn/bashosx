source ${HOME}/bashosx/alias.sh

source ${HOME}/bashosx/wp/wp-completion.bash

_complete_ssh_hosts ()
{
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        comp_ssh_hosts=`cat ~/.ssh/known_hosts | \
                        cut -f 1 -d ' ' | \
                        sed -e s/,.*//g | \
                        grep -v ^# | \
                        uniq | \
                        grep -v "\[" ;
                cat ~/.ssh/config | \
                        grep "^Host " | \
                        awk '{print $2}'
                `
        COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- $cur))
        return 0
}
complete -F _complete_ssh_hosts ssh

export HISTCONTROL=ignoredups
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

source "${HOME}/bashosx/paths.sh"
source "${HOME}/bashosx/prompt.sh"

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# don't print anything out unless it's an interactive shell
[ -z "$PS1" ] && return

if hash direnv 2>/dev/null; then
        eval "$(direnv hook bash)"
fi

# if we're a remote server, print out some info when opening a new session such as current load
if [ -n "${SSH_CLIENT}" ] || [ -n "${SSH_TTY}" ]; then
        printf "\nHello \e[1;33m$(whoami)\e[0m, you are connected to \e[1;33m$(hostname)\e[0m, current uptime is:\n\n\e[1;32m$(uptime)\n\n"
fi
