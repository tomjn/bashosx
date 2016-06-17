#!/bin/bash

brew=/usr/local/bin/brew
logger=/usr/bin/logger

$brew update 2>&1  | $logger -t brewup.update
$brew upgrade 2>&1 | $logger -t brewup.upgrade
$brew cleanup 2>&1 | $logger -t brewup.cleanup
$brew prune 2>&1   | $logger -t brewup.prune

# not needed as homebrew will take care of this, but uncomment if necessary
# also keep composer in good shape
#/usr/local/bin/composer selfupdate
