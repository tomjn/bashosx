# Toms Bash Scripts

Primarily aimed at my OS X machine, this is a set of bash scripts I git clone into ~/bash_osx, including small pieces of automation, prompts and alias' etc

Update your .bash_profile to include this line to get started, then open a new tab:

```
source ${HOME}/bashosx/init.sh
```
Optimised for dark colour schemes, works best with base16 ocean

## Install Instructions

 - Open your terminal, and you should find yourself in your home folder aka `~`
 - Clone this repository into the `bashosx` folder by running the command `git clone https://github.com/Tarendai/bashosx.git bashosx`
 - You should now have a folder `bashosx` in your home directory
 - You now need to tell your terminal to load `bashosx/init.sh` when it starts, do this by editing `.bash_profile`
 - To do this, go to your home directory ( `cd ~` ), and open the file using `vim .bash_profile`. If the file doesn't exist it will be created
 - Press `i` to enter edit mode, and at the end of the file on a new line, type: `source ${HOME}/bashosx/init.sh`
 - Press `esc` to exit edit mode, then type: `:wq` to save and exit
 - Congratulations! Open a new terminal, and if you've done everything correctly, you should see a new terminal prompt


## Features

 - WP CLI bash completion
 - Handles Composer and Homebrew PATH inclusion automatically
 - Responsive terminal prompt
 - Prompt will indicate if the last command was a success or failure using colours
 - Sets up colours and bash completions for common commands
 - Adds SSH hostname autocompletion
 - Adds a lightning symbol when logged in as a root user
 - Shows the current svn revision and trunk/branch
 - Shows the current git branch, if there are uncommitted changes, and if there are commits that haven't been pushed yet


## Troubleshooting

 - If you're on OS X you may need to modify `.profile` rather than `.bash_profile`, although on my machine I use the latter
