# /etc/skel/.bashrc:
# $Header: /home/cvsroot/gentoo-src/rc-scripts/etc/skel/.bashrc,v 1.8 2003/02/28 15:45:35 azarah Exp $

alias java_ls='/usr/libexec/java_home -V 2>&1 | grep -E "\d.\d.\d[,_]" | cut -d , -f 1 | colrm 1 4 | grep -v Home'

alias failed_findbugs='open build/reports/findbugs/test.html'
alias failed_tests='open build/reports/tests/index.html'
function setjdk() {
    export JAVA_HOME=$(/usr/libexec/java_home -v $1)
    export PATH=$JAVA_HOME/bin:$PATH
    java -version
}

alias rds-tunnels='ssh rds-tunnels'
alias psql-goldfish-backend='echo PASSWORD=anG4iEr3V8QGvjAKHCAoHXmTFyPYOPkn && psql --host localhost --port 15432 --dbname goldfishbackend --username GR44L9GXzFgRL9GZZuNkcgBKwgupwMVx --password'
alias psql-goldfish-channels='echo PASSWORD=ZhDw5H3osntjQUn6V8yEATun3q4B6Prj && psql --host localhost --port 15440 --dbname goldfishchannels --username B0mlK0519U1Wvn90NJWz3GIRn1OwAsO5 --password'
alias psql-sync-channel='echo PASSWORD=24c4c5a5abb448d8a73fb5c8912da3b4 && psql --host localhost --port 15434 --dbname sync_channel --username sync --password'
alias psql-alexandria='echo PASSWORD=0CfrtO2ybKxh3l5arlwZk2Pjpx6IFyKI && psql --host localhost --port 15435 --dbname alexandria --username KIWSdTmBuzyTCILS42KgfqM357bNSw2h --password'
alias psql-strategy='echo PASSWORD=OwTAA8RKSZj1BaYkXvOiQiLbtnZNX4g2 && psql --host localhost --port 15440 --dbname strategyservice --username PXApiqcd3Mozt7GYLEQqJy8JIzlH6fJT --password'
alias psql-hosted-page='echo PASSWORD=M0n3ul9OtN9xC6OH02HXlxRfMdvk4Chh && psql --host localhost --port 15440 --dbname hostedpageservice --username Zv0K4KNal1YClQfiRz3z2dsLpt0x0QLt --password'
alias psql-automation-orchestrator='echo PASSWORD=1Q0zRIOzDlc3mh4cW4xjdunFeoIziB && psql --host localhost --port 15440 --dbname automation_orchestrator --username dekfd77fgbq8ecuosnnxdsxxa9fu2qvf --password'
alias psql-praxis='echo PASSWORD=43xGog4ANElExQBkJiNbtNMaKDGn3rUY && psql --host localhost --port 15439 --dbname praxis --username p2FjAaxEgG5sPFkw7XTkS7PEx59hnoEW --password'
alias psql-voltron='echo PASSWORD=fdEp32TzC36dTQAaqKO8Erx5Z9uDLPca && psql --host localhost --port 15440 --dbname voltron --username DbGplfkJ54SwlgXN99zTF57CNsJ3ce9a --password'
alias psql-strategy-builder='echo PASSWORD=gkKPafI8noOYybSdD0wLZbjCxLRnOmYU && psql --host localhost --port 15441 --dbname strategybuilder --username udwHoqEZtUFgDM9DwTP7vaGvj4OxR5xA --password'
alias psql-tracking-pixel='echo PASSWORD=6ph1F2t3nguANokXqNXJld1YVtcAxLre && psql --host localhost --port 15442 --dbname trackingpixelservice --username P8YmRq56MuONg3hkIa7DtaQpxVmJf3N8 --password'
alias psql-tracking-link='echo PASSWORD=9Id9bsHmHecAgmKJs4j1SRVLivMjmkr1 && psql --host localhost --port 15443 --dbname trackinglinkservice --username YdBm1BGQLeV1fzitXZJkDe4bIHM1J2HR --password'
alias psql-timer='echo PASSWORD="9)vt4}zdWUq;Nw6Fh9a3Jno2gkvgqW" && psql --host localhost --port 15444 --dbname timer_service --username b4asqg8iasnqajz0dndjz3aggeqzestj --password'
alias psql-subscription='echo PASSWORD=ZjjvpR73jfUreDMvDPlDmSo7N4hXDLGM && psql --host localhost --port 15445 --dbname subscriptionservice --username XbjFaN4GzCUh4m9Cy2Er8aFRvwCgQ8hZ --password'
alias psql-insight='echo PASSWORD=6W18csVUAZOW6V42DuclbCgYsDbeQoMv && psql --host localhost --port 15446 --dbname insightservice --username R0HB1QHR8ISCvY5VhAgOYlIoykhu1G2r --password'

export INFR=~/.m2/repository/com/infusionsoft/
export LIBTOOL=glibtool
export GRADLE_OPTS="-Xmx2g -XX:MaxPermSize=1g"
export EDITOR="vim"
export HISTFILESIZE=1000000000 
export HISTSIZE=1000000
export TERM="xterm-color" 
export PS1='\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\] \$ '
#export PS1='\[\033[1;34m\]\$\[\033[0m\] '
export PATH=/Applications/Firefox.app/Contents/MacOS:/usr/local/groovy/bin:/usr/local/maven/bin:/opt/local/bin:/opt/local/sbin:/usr/local/mysql/bin:$PATH
export PATH=$PATH:/opt/local/bin
export PATH=$PATH:/opt/local/sbin
export PATH=$PATH:/usr/local/maven/bin
export PATH=$PATH:/usr/local/groovy/bin
export PATH=$PATH:/usr/local/mysql/bin
export PATH=$PATH:/usr/local/grails/bin
export PATH=$PATH:/usr/local/scala/bin
export PATH=$PATH:/Applications/Xcode.app/Contents/Developer/usr/bin
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export II=~/.m2/repository/com/infusionsoft/
export MAVEN_OPTS="-XX:ReservedCodeCacheSize=64m -Xmx1200m -XX:MaxPermSize=512m -XX:CompileCommand=exclude,com/infusion/databridge/MemoryRst,loadMeta -Dfile.encoding=ISO-8859-1"
export GRAILS_OPTS="-Xmx1200m -XX:MaxPermSize=512m"
export ANT_OPTS="-Xmx512m -Dfile.encoding=ISO-8859-1"

shopt -s extglob
# allow people to write messages to this terminal
mesg y

alias tailf='tail -n 100 -f'
alias u='cd ..'
alias uu='cd ../..'
alias uuu='cd ../../..'
alias t='cd /'
alias gc='git commit -a'
alias gs='git status'
alias gr="git pull —-rebase"
alias grc='git rebase —-continue'
alias gra='git rebase —-abort'
alias gp='git push'
alias m0='m0=`pwd`'
alias r0='cd $m0'
alias m1='m1=`pwd`'
alias r1='cd $m1;pwd'
alias m2='m2=`pwd`'
alias r2='cd $m2;pwd'
alias m3='m3=`pwd`'
alias r3='cd $m3;pwd'
alias cds='m0=`pwd`; cd '
alias s='temp9=`pwd`; cd $m0; m0=$temp9; pwd'
alias l.='ls -d .*'
alias ll.=' ls -ld .*'
alias psm='ps -A -o pid,%mem,args --sort rss'
alias vp='vi ~/.profile'
alias sp='source ~/.profile'
alias cutf='cut -d " " -f'
alias ll='ls -l'
alias vi='vim'
alias findm='find $II -name $@'
alias debugg='export GRADLE_OPTS="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=1044"'
alias undebugg='export GRADLE_OPTS=""'
alias sdkgen='./gradlew -x integrationTest -x test clean buildSdk publishToMavenLocalSdk'
alias vgg='vi ~/.grails/goldfish-backend-config.groovy'
alias vg='vi ~/.gradle/gradle.properties'
alias vb='vi build.gradle'
unset delm
delm() {
find $II -name $@ -exec rm -rf {} \;
}

unset git_remote
git_remote() {
	if [ $# -eq 0 ]
        then
            echo "No arguments supplied: Usage git_remote '[remote]'"
    else
        dir=`basename $PWD`
        echo "Setting up remote for $1 to $dir"
        git remote add $1 ssh://$1.local/Users/ericm/Projects/$dir
    fi
}

unset stealth_lookup
stealth_lookup() {
	if [ $# -eq 0 ]
		then
			echo "No arguments supplied: Usage stealth_lookup '[query]'"
	else 
		curl -X GET "https://proofing-api.goldfishapp.co/rest/v2/stealth/accounts?apiKey=74871304-bb1bc07c-c4fb-4a04-ba29-e7d7db0c5621&offset=0&limit=100&search_param=$1" | jsonpp
	fi
}

unset stealth_login
stealth_login() {
        if [ $# -eq 0 ]
                then
                        echo "No arguments supplied: Usage stealth_login '[tenant_id]'"
        else
                curl -X POST "https://proofing-api.goldfishapp.co/rest/v2/stealth/tenant/login?apiKey=74871304-bb1bc07c-c4fb-4a04-ba29-e7d7db0c5621&platform_tenant_id=$1" | jsonpp
	fi
}

unset alexandria_lookup
alexandria_lookup() {
        if [ $# -eq 0 ]
                then
                        echo "No arguments supplied: Usage alexandria_lookup '[tenant_id]'"
        else
                curl -X GET --header "Accept: application/json" "https://alexandria.sbsp.io/tenants/$1?api_key=0c77fcfe-8cd5-4271-b3b3-24269b7ac265" | jsonpp
	fi
}

unset chmodr
chmodr() {
chmod -R "$@"
}

unset chgrpr
chgrpr() {
chgrp -R "$@"
}

unset find4
find4() {
find -maxdepth 4 $*
}

unset find3
find3() {
find -maxdepth 3 $*
}

unset find1
find1() {
find -mindepth 1 -maxdepth 1 $*
}

unset rmr
rmr() {
rm -r --force $*
}

unset findd
findd() {
	find -type d -mindepth 1 -maxdepth 1 $*
}

unset grepr
grepr() {
	grep -D skip -n -s -r -I -i "$@" *
}

unset psf
psf() {
	ps auxw | grep $1
}

unset findvi
findvi() {
	vi `find "/all/$1/" -name "$2*$3"`
}

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
[[ -s "/Users/ericm/.gvm/bin/gvm-init.sh" && ! $(which gvm-init.sh) ]] && source "/Users/ericm/.gvm/bin/gvm-init.sh"

# The next line updates PATH for the Google Cloud SDK.
source '/Users/ericm/google-cloud-sdk/path.bash.inc'

# The next line enables shell command completion for gcloud.
source '/Users/ericm/google-cloud-sdk/completion.bash.inc'

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/ericm/.sdkman"
[[ -s "/Users/ericm/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/ericm/.sdkman/bin/sdkman-init.sh"
