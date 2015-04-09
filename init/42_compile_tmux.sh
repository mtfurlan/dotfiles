#!/bin/bash

if ! which tmux>/dev/null; then
	#no tmux, so install it
	echo "Compiling tmux"
	tmuxScript="https://gist.githubusercontent.com/Scuzzball/a1ca6488a4b9498332cb/raw/d91a03572a977fb2a8eb042fc845148f7be5a9f6/tmux_local_install.sh"
	bash <(curl -s $tmuxScript)
else
	echo "Tmux already exists"
fi
