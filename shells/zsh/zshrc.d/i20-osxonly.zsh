#*******************************************************************************************************************
#* Config files                                                                                                    *
#*******************************************************************************************************************
#* File:             20-osxonly.sh                                                                                 *
#* Copyright:        (c) 2011-2012 alimonda.com; Emanuele Alimonda                                                 *
#*                   Public Domain                                                                                 *
#*******************************************************************************************************************

# Probe for Mac OS X
if [ "$(uname)" = "Darwin" ]; then
	# http://blog.warrenmoore.net/blog/2010/01/09/make-terminal-follow-aliases-like-symlinks/
	function cd {
		if [ ${#1} = 0 ]; then
			builtin cd
		elif [ -d "${1}" ]; then
			builtin cd "${1}"
		elif [[ -f "${1}" || -L "${1}" ]]; then
			local dir_path=$(getTrueName "$1")
			builtin cd "$dir_path"
		else
			builtin cd "${1}"
		fi
	}

	function intmux {
		[ -n "$1" -a -d "$1" ] && cd "$1"
		# Check for session
		if ! tmux has -t stuff >&- 2>&-; then
			# Start a new session
			tmuxattach --onlystart
		fi
		tmux new-window -t stuff && tmux rename-window -t stuff "($(basename "$PWD"))"
	}

	function dequarantine {
		while [ $# -gt 0 ]; do
			THISFILE="$1"
			shift
			[ -z "$THISFILE" -o ! -e "$THISFILE" ] && continue
			xattr -d com.apple.quarantine "$THISFILE" 2>/dev/null
		done
	}

	#export TERM='xterm-256color'
	# Use a nice-looking $PS1
	#export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
	#shopt -s checkwinsize
	export CLICOLOR=1

	#export OSXSDK="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk"
	function osxsdk {
		echo "$(xcodebuild -version $(xcodebuild -showsdks 2>/dev/null | awk '/^$/{p=0};p; /macOS SDKs:/{p=1}' | tail -1 | cut -f3) Path 2>/dev/null)"
	}

	if [ -d /usr/local/share/zsh-completions ]; then
		fpath=(/usr/local/share/zsh-completions $fpath)
	fi

	# Perl local::lib
	eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)
fi

# vim: ts=4 sw=4
