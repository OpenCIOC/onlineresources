#!/usr/bin/env bash
# vim: set nobomb
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
siteroot="$(dirname $SCRIPT_DIR)"
sitename="$(basename $siteroot)"
domain=localhost
port=6543
voluser=cioc_vol_search
db_server="(local),1433"
db_name="cioc"
admin_user="cioc_login"
admin_passwd=
cic_user="cioc_cic_search"
cic_passwd=
vol_user="cioc_vol_search"
vol_passwd=
preflight=true
redis_host=127.0.0.1


usage() {
	cat <<EOF

Usage:
 bootstrap.sh [options]

Install CIOC local dependencies and perform site setup that requires elevated privileges.

Options:
 -d, --domain DOMAIN        Created site will listen on http port 80 with domain DOMAIN (default: $domain)
 -s, --site-name SITE       Create a site in IIS with the name SITE (default: $sitename)
 -p, --port PORT            Port to forward traffic to python process (default: $port)
 -S, --db-server SERVER     Server host (default: $db_server)
 -D, --db-name DBNAME       Name of CIOC database on SERVER (default: $db_name)
 -a, --admin-user USER      Login username for user with cioc_login_role permission to DBNAME (default: $admin_user)
 -A, --admin-passwd PASSWD  Login password for user with cioc_login_role permission to DBNAME (default: will prompt)
 -c, --cic-user USER        Login username for user with cioc_cic_search_role permission to DBNAME (default: $cic_user)
 -C, --cic-passwd PASSWD    Login password for user with cioc_cic_search_role permission to DBNAME (default: will prompt)
 -v, --vol-user USER        Login username for user with cioc_vol_search_role permission to DBNAME (default: $vol_user)
 -V, --vol-passwd PASSWD    Login password for user with cioc_vol_search_role permission to DBNAME (default: will prompt)
 -r, --redis-host HOST		Redis host to use (default: $redis_host)
 -h, --help                 Show this text and exit
 --no-preflight				Skip installing system dependencies that require elevated privileges
EOF
}

while [[ $# -gt 0 ]]; do
	case $1 in
		-d|--domain)
			domain=$2
			shift
			shift
			;;
		-s|--site-name)
			sitename=$2
			shift
			shift
			;;
		-S|--db-server)
			db_server=$2
			shift
			shift
			;;
		-D|--db-name)
			db_name=$2
			shift
			shift
			;;
		-a|--admin-user)
			admin_user=$2
			shift
			shift
			;;
		-A|--admin-passwd)
			admin_passwd=$2
			shift
			shift
			;;
		-c|--cic-user)
			cic_user=$2
			shift
			shift
			;;
		-C|--cic-passwd)
			cic_passwd=$2
			shift
			shift
			;;
		-v|--vol-user)
			vol_user=$2
			shift
			shift
			;;
		-V|--vol-passwd)
			vol_passwd=$2
			shift
			shift
			;;
		-r|--redis)
			redis_host=$2
			shift
			shift
			;;
	    --no-preflight)
			preflight=false
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown option $1"
			usage
			exit 1
			;;
	esac
done

if [[ $preflight == 'true' ]]; then
	echo "Launching preflight elevated in new window..."
	sleep 1
	powershell -noprofile -file preflight.ps1 -domain:"$domain" -sitename:"$sitename"
fi

[[ -e ../pythonport.config ]] || sed -E "s/(name=\"SetPythonPort\" defaultValue=\")([^\"]*)/\\1$port" ../pythonport-sample.config > pythonport.config
mkdir -p "$siteroot/../../config"
configfile="$siteroot/../../config/$sitename.ini"
if [[ ! -e "$configfile" ]]; then
	cat > "$configfile" <<EOF
[global]
server=$db_server
database=$db_name
driver=ODBC Driver 17 for SQL Server
provider=MSOLEDBSQL

session.type=redis
session.url=$redis_host:6379
cache.type=redis
cache.url=$redis_host:6379

admin_uid=$admin_user
admin_pwd=$admin_passwd

cic_uid=$cic_user
cic_pwd=$cic_passwd

vol_uid=$vol_user
vol_pwd=$vol_passwd
EOF
fi

# install node.js tools like google-closure-compiler
npm install

env_python="$USERPROFILE/Envs/ciocenv4py3/Scripts/python.exe"
[[ -e $env_python ]] || "/c/Program Files/Python39/scripts/mkvirtualenv.bat"  --system-site-packages ciocenv4py3
$env_python -m pip install -U pip
$env_python -m pip install -r requirements-dev.txt
