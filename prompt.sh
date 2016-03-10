#!/bin/bash

working_directory() {
    dir=`pwd`
    in_home=0
    if [[ `pwd` =~ ^$HOME($|\/) ]]; then
        dir="~${dir#$HOME}"
        in_home=1
    fi

    if [[ `tput cols` -lt 100 ]]; then  # <-- Checking the term width
        first="/`echo $dir | cut -d / -f 2`"
        letter=${first:0:2}
        if [[ $in_home == 1 ]]; then
            letter="~$letter"
        fi
        proj=`echo $dir | cut -d / -f 3`
        beginning="$letter/$proj"
        end=`echo "$dir" | rev | cut -d / -f1 | rev`

        if [[ $proj == "" ]]; then
            echo $dir
        elif [[ $proj == "~" ]]; then
            echo $dir
        elif [[ $dir =~ "$first/$proj"$ ]]; then
            echo $beginning
        elif [[ $dir =~ "$first/$proj/$end"$ ]]; then
            echo "$beginning/$end"
        else
            echo "$beginning/…/$end"
        fi
    else
        echo $dir
    fi
}


function parse_git_dirty {
  [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]] && printf '\e[1;91m*\e[0;33m'
}

function parse_git_stash {
  local stash=`expr $(git stash list 2>/dev/null| wc -l)`
  if [ "$stash" != "0" ]
  then
    echo "stashed:$stash"
  fi
}

function parse_git_unmerged {
  local unmerged=`expr $(git branch --no-color -a --no-merged | wc -l)`
  if [ "$unmerged" != "0" ]
  then
    echo "unmerged:$unmerged"
  fi
}

# Returns "|unpushed:N" where N is the number of unpushed local and remote
# branches (if any).
function parse_git_unpushed {
  local unpushed=`expr $( (git branch --no-color -r --contains HEAD; \
    git branch --no-color -r) | sort | uniq -u | wc -l )`
  if [ "$unpushed" != "0" ]
  then
    echo "unpushed branches:$unpushed"
  fi
}

parse_git_branch() {
    if [[ -f /usr/local/etc/bash_completion.d/git-completion.bash ]]; then
        branch=`__git_ps1 "%s"`
    else
        ref=$(git-symbolic-ref HEAD 2> /dev/null) || return
        branch="${ref#refs/heads/}"
    fi

    if [[ `tput cols` -lt 110 ]]; then  # <---- Again checking the term width
        branch=`echo $branch | sed s/feature/f/1`
        branch=`echo $branch | sed s/hotfix/h/1`
        branch=`echo $branch | sed s/release/\r/1`
        branch=`echo $branch | sed s/master/mstr/1`
        branch=`echo $branch | sed s/develop/dev/1`
    fi

    if [[ $branch != "" ]]; then
        echo "git::$branch$(parse_git_dirty) $(parse_git_stash) $(parse_git_unpushed) $(parse_git_unmerged)"
    fi
}

# Returns (svn:<revision>:<branch|tag>[*]) if applicable
svn_prompt() {
    if [ -d ".svn" ]; then
        local branch dirty rev info=$(svn info 2>/dev/null)
        branch=$(svn_parse_branch "$info")
        # Uncomment if you want to display the current revision.
        rev=$(echo "$info" | awk '/^Revision: [0-9]+/{print $2}')
        # Uncomment if you want to display whether the repo is 'dirty.' In some
        # cases (on large repos) this may take a few seconds, which can
        # noticeably delay your prompt after a command executes.
        #[ "$(svn status)" ] && dirty='*'
        if [ "$branch" != "" ] ; then
            echo "(svn:$rev:$branch$dirty)"
        else
            echo "svn::$rev$dirty "
        fi
    fi
}

# Returns the current branch or tag name from the given `svn info` output
svn_parse_branch() {
    local chunk url=$(echo "$1" | awk '/^URL: .*/{print $2}')
    echo $url | grep -q "/trunk\b"
    if [ $? -eq 0 ] ; then
        echo trunk
        return
    else
        chunk=$(echo $url | grep -o "/releases.*")
        if [ "$chunk" == "" ] ; then
            chunk=$(echo $url | grep -o "/branches.*")
            if [ "$chunk" == "" ] ; then
                chunk=$(echo $url | grep -o "/tags.*")
            fi
        fi
    fi
    echo $chunk | awk -F/ '{print $3}'
}

prompt() {
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        host="\[\e[1;33m\]\h \[\e[00m\]@"
    else
        host=""
    fi
    if [[ $UID -eq 0 ]]; then
        isroot="\[\e[0;33m\]⚡"
    else
        isroot=""
    fi
    if [[ $? -eq 0 ]]; then
        #❯
        exit_status='\[\e[1;32m\]❯ \[\e[00m\]'
    else
        exit_status='\[\e[0;31m\]❯ \[\e[00m\]'
    fi

    prompt='\[\e[1;97m\]$(working_directory)\[\e[00m\]\[\e[0;33m\] $(svn_prompt)$(parse_git_branch)\[\e[00m\]\n'
    PS1=$host$prompt$isroot$exit_status
}
PROMPT_COMMAND=prompt
