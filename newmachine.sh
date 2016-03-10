# setup xcode
xcode-select --install

# homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

## tap repos
brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/homebrew-php

brew update

# install a few things
brew install bash-completion ssh-copy-id wget freetype jpeg libpng gd zlib cloc htop-osx youtube-dl coreutils

# version control
brew install git
brew install subversion

# install php7 stuff
brew install php70 php70-xdebug php70-intl
brew install composer
brew install wp-cli phpmd phploc phpunit pdepend behat codeception box

# install phpcs
composer global require "squizlabs/php_codesniffer=*"

# Wine!

brew install wine winetricks
# Node
brew install node

# Gulp
npm install -g gulp
