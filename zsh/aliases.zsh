# Get running service from docker swarm
alias dsps="docker service ps $1  --filter desired-state=running"

# Allows k8s login via cli
alias klogin="kubelogin"

# Tui for conventional commits
alias gc='git cz'

# Interactive git add
alias gi='git add -i'


# From https://github.com/techgirlgeek/mac_profile/blob/master/zsh_custom/aliases.zsh
#
#
alias lstr='ls -ltrh'
alias ll='ls -lh'
alias homeshuttle='sshuttle -r kcassio@sea1l3vipcj01.davita.corp 10.9.0.0/16 10.10.0.0/16 10.12.0.0/16'
alias homeshuttleD='sshuttle --dns -r kcassio@den3l1cliqa74077.davita.corp 0/0'
alias ddig="dig +search +short drupal.slack.com"
alias gitprunedry="git remote prune origin --dry-run"
alias gitprune="git remote prune origin"
alias vssh="vagrant ssh "
alias vup="vagrant up "
alias vdestroy="vagrant destroy "
alias vprov="vagrant provision "
alias vstat="vagrant status"
alias vhalt="vagrant halt "
alias artifactoryport="ssh 10.9.35.205 -L 1178:localhost:1178"
alias evalbundle='eval "$(<env.sh)"'
alias clear_dns='sudo killall -HUP mDNSResponder; sleep 2; echo macOS DNS Cache Reset'
alias morpa_rvm='rvm use ruby-2.3.3'

# K8s aliases
alias k='kubectl'
alias ka="kubectl apply -f $1"
alias kd="kubectl delete -f $1"
alias ke='kubectl get events --sort-by={.lastTimestamp}'
alias kg='kubectl get'
alias kns='kubens'
alias knx='kubectx'
alias kpon='kubeon'
alias kpoff='kubeoff'
alias kpodw='k get pods -o wide'
alias kpod='k get pods'

# Fix the silly symantic DNS "helper"
alias fixsymantic="cd /Library/LaunchDaemons; for i in `ls com.symantec*`; do sudo mv $i $i.bak; done
"

# Elastic
alias cerebro='docker run -p 9000:9000 lmenezes/cerebro'

# LDAP
alias myldap='ldapsearch -o ldif-wrap=no  -H ldaps://den3ha.adldap.davita.corp/ -b dc=davita,dc=corp -D kcassio@davita.corp -W "(samAccountName=kcassio)" memberof'
#alias userldap='ldapsearch -o ldif-wrap=no  -H ldaps://den3ha.adldap.davita.corp/ -b dc=davita,dc=corp -D kcassio@davita.corp -W "(samAccountName=$1)" memberof'
#userldap() {
#    ldapsearch -o ldif-wrap=no  -H ldaps://den3ha.adldap.davita.corp/ -b dc=davita,dc=corp -D kcassio@davita.corp -W "(samAccountName=$1)" memberof
#}
alias mytest="echo Make it say: $1"

# Alias jql to a much better experience
alias jql=jless

