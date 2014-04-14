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
        echo "git::$branch "
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
        [ "$(svn status)" ] && dirty='*'
        if [ "$branch" != "" ] ; then
           echo "(svn:$rev:$branch$dirty)"
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
    if [[ $? -eq 0 ]]; then
        #❯
        exit_status='\[\e[1;32m\]❯ \[\e[00m\]'
    else
        exit_status='\[\e[0;31m\]❯ \[\e[00m\]'
    fi

    prompt='\[\e[0;36m\]$(working_directory)\[\e[00m\]\[\e[0;32m\] $(parse_git_branch)$(svn_prompt)\[\e[00m\]\n'
    PS1=$prompt$exit_status
}
PROMPT_COMMAND=prompt