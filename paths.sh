export PATH=/usr/local/share/npm/bin:$PATH
export PATH=~/.composer/vendor/bin:$PATH

# if homebrew is available, set the PATH
if hash brew 2>/dev/null; then
	export PATH="$(brew --prefix)/bin:$PATH"
fi