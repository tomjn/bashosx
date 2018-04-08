# Toms Bash Scripts

Primarily aimed at my OS X machine, this is a set of bash scripts I git clone into ~/bash_osx, including small pieces of automation, prompts and alias' etc

## Install Instructions

Clone and update your `.bashrc` file using the following commands:

```
git clone https://github.com/tomjn/bashosx.git ~/bashosx
echo "source ${HOME}/bashosx/init.sh" >> ~/.bashrc
```
Finally, open a new terminal window/tab. For full features, make sure to have `git` and `svn` installed.

Optimised for dark colour schemes, works best with the [base16 ocean](https://github.com/mdo/ocean-terminal)

## Features

 - WP CLI bash completion
 - Handles Composer and Homebrew PATH inclusion automatically
 - Responsive terminal prompt
 - Prompt will indicate if the last command was a success or failure using colours
 - Sets up colours and bash completions for common commands
 - Adds SSH hostname autocompletion
 - Adds a lightning symbol when logged in as a root user
 - Shows the current svn revision and trunk/branch
 - Shows the current git branch, if there are uncommitted changes, staged changes, and if there are commits that haven't been pushed yet
 - A script to help setup new Macs with a handful of core tools such as homebrew, node, php, etc


## Troubleshooting

 - If you're on OS X you may need to modify `.profile` rather than `.bash_profile`, although on my machine I use the latter
