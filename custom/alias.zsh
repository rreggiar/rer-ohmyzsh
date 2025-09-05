# ssh
alias pz='ssh rreggiar@plaza.gi.ucsc.edu'
alias ct='ssh rreggiar@courtyard.gi.ucsc.edu'
alias park='ssh rreggiar@park.gi.ucsc.edu'
alias mustard='ssh mustard'
alias sherlock='ssh login.sherlock.stanford.edu'
alias centos='ssh -p 2222 root@localhost'
alias changrila='ssh changrila2.stanford.edu'
alias resetAgent='killall ssh-agent && eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_rsa || ssh-agent'

# git
alias ga='git add'
alias gcm='git commit -m'
alias gl='git lg'
alias currCommit="git rev-parse --verify --short HEAD"
alias currBranch="git rev-parse --abbrev-ref HEAD"
alias balenaTag='printf "%s::%s:%s\n" "$USER" "$(currBranch)" "$(currCommit)"'

# pushd
alias dev="pushd ~/dev"

# zsh
alias setAlias='nvim ~/.oh-my-zsh/custom/alias.zsh'
alias setPlugins='nvim ~/.oh-my-zsh/plugins/rer_plugins/rer_plugins.plugin.zsh'
alias myplugins='pushd ~/.oh-my-zsh/plugins/rer_plugins/'
alias hg="history | grep $1"
