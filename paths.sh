export PATH=/usr/local/share/npm/bin:$PATH
export PATH=~/.composer/vendor/bin:$PATH
export PATH="/usr/local/sbin:$PATH"
export PATH=~/.local/bin:$PATH
export PATH=/usr/local/lib/ruby/gems/2.6.0/bin:$PATH

# if homebrew is available, set the PATH
if hash brew 2>/dev/null; then
	export PATH="$(brew --prefix)/bin:$PATH"
fi
