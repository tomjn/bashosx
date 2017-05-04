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

function parse_git_branch() {
    # Based on: http://stackoverflow.com/a/13003854/170413
    local branch
    if branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null); then
        if [[ "$branch" == "HEAD" ]]; then
            branch='detached*'
        fi
        echo $branch
    fi
}

function parse_git_dirty {
    if [ $( git rev-parse --is-bare-repository ) == "true" ]; then
        return
    fi
    w=""
    git diff --no-ext-diff --quiet || w+="\e[1;91m*\e[0;33m"
    git diff --no-ext-diff --cached --quiet || w+="\e[1;32m+\e[0;33m"
    if [ $w ]; then
        printf $w
    fi
}

function parse_git_stash {
    local stash=`expr $(git stash list 2>/dev/null| wc -l)`
    if [ "$stash" != "0" ]
    then
        echo "stashed:$stash "
    fi
}

function parse_git_unmerged {
    if [ $( git rev-parse --is-bare-repository ) == "true" ]; then
        return
    fi
    local unmerged=`expr $(git branch --no-color -a --no-merged | wc -l)`
    if [ "$unmerged" != "0" ]
    then
        echo "unmerged:$unmerged "
    fi
}

# Returns "|unpushed:N" where N is the number of unpushed local and remote
# branches (if any).
function parse_git_unpushed {
    local unpushed=`expr $( (git branch --no-color -r --contains HEAD; \
    git branch --no-color -r) | sort | uniq -u | wc -l )`
    if [ "$unpushed" != "0" ]
    then
        echo "unpushed-branches:$unpushed "
    fi
}

function parse_remote_state() {
    local git_eng="env LANG=C git"   # force git output in English to make our work easier
    # git status --porcelain --branch | grep '^##' | grep -o '\[.\+\]$' ?
    remote_state=$(git status -sb 2> /dev/null | grep -oh "\[.*\]")
    if [[ "$remote_state" != "" ]]; then
        out=""
        local stat="$($git_eng status --porcelain --branch | grep '^##' | grep -o '\[.\+\]$')"
        local aheadN="$(echo $stat | grep -o 'ahead [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
        local behindN="$(echo $stat | grep -o 'behind [[:digit:]]\+' | grep -o '[[:digit:]]\+')"
        if [[ "$remote_state" == *ahead* ]] && [[ "$remote_state" == *behind* ]]; then
            out="\e[1;91mbehind:$behindN \e[1;32mahead:$aheadN\e[0;33m"
        elif [[ "$remote_state" == *ahead* ]]; then
            out="$out${GREEN}$aheadN${COLOREND}"
            out="\e[1;32mahead:$aheadN\e[0;33m"
        elif [[ "$remote_state" == *behind* ]]; then
            out="\e[1;91mbehind:$behindN\e[0;33m"
        fi

        printf "$out "
    fi
}

# formerly parse_git_branch
function git_prompt() {
    if [[ $(command -v git) ]]; then
        local branch
        if [[ -f /usr/local/etc/bash_completion.d/git-completion.bash ]]; then
            branch=`__git_ps1 "%s"`
        else
            branch="$(parse_git_branch)"
            #ref=$(git-symbolic-ref HEAD 2> /dev/null) || return
            #branch="${ref#refs/heads/}"
        fi

        if [[ `tput cols` -lt 110 ]]; then  # <---- Again checking the term width
            branch=`echo $branch | sed s/feature/f/1`
            branch=`echo $branch | sed s/hotfix/h/1`
            branch=`echo $branch | sed s/release/\r/1`
            branch=`echo $branch | sed s/master/mstr/1`
            branch=`echo $branch | sed s/develop/dev/1`
        fi

        if [[ $branch != "" ]]; then
            echo "git::$branch$(parse_git_dirty) $(parse_git_stash)$(parse_remote_state)"
        fi
    else
        echo "git:notinstalled"
    fi
}

# Returns (svn:<revision>:<branch|tag>[*]) if applicable
function svn_prompt() {
    if [[ $(command -v svn) ]]; then
        if svn info >/dev/null 2>&1; then
            local branch dirty rev info=$(svn info 2>/dev/null)
            branch=$(svn_parse_branch "$info")
            # Uncomment if you want to display the current revision.
            rev=$(echo "$info" | awk '/^Revision: [0-9]+/{print $2}')
            # Uncomment if you want to display whether the repo is 'dirty.' In some
            # cases (on large repos) this may take a few seconds, which can
            # noticeably delay your prompt after a command executes.
            #[ "$(svn status)" ] && dirty='*'
            if [ "$branch" != "" ] ; then
                echo "svn:$rev:$branch$dirty"
            else
                echo "svn::$rev$dirty "
            fi
        elif [ -d ".svn" ]; then
            echo "svn:old "
        fi
    else
        echo "svn:notinstalled "
    fi
}

# Returns the current branch or tag name from the given `svn info` output
function svn_parse_branch() {
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

function prompt() {
    local excode=$?
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        host="\[\e[1;33m\]$(hostname) \[\e[00m\]"
    else
        host=""
    fi
    if [[ $UID -eq 0 ]]; then
        isroot="\[\e[0;33m\]⚡"
    else
        isroot=""
    fi
    #❯
    if [[ $excode -eq 127 ]]; then
        # command succeeded
        exit_status="\[\e[1;33m\]❯ \[\e[00m\]"
    elif [[ $excode -eq 0 ]]; then
        # command not found
        exit_status="\[\e[1;32m\]❯ \[\e[00m\]"
    else
        # command failed?
        exit_status="\[\e[0;31m\]❯ \[\e[00m\]"
    fi

    rpi=""
    if [ -f "/etc/os-release" ]
    then
        if grep -q Raspbian "/etc/os-release"; then
            rpi="🍓"
        fi
    fi

    prompt='\[\e[1;97m\]$rpi$(working_directory)\[\e[00m\]\[\e[0;33m\] $(svn_prompt)$(git_prompt)\[\e[00m\]\n'
    PS1=$host$prompt$isroot$exit_status
}
PROMPT_COMMAND=prompt
