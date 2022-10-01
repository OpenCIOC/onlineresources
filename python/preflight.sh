#!/usr/bin/env bash
# vim: set nobomb
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
siteroot="$(dirname $SCRIPT_DIR)"
sitename="$(basename $siteroot)"
domain=localhost

usage() {
	cat <<EOF

Usage:
 preflight.sh [options]

Install CIOC local dependencies and perform site setup that requires elevated privileges.

Options:
 -d, --domain DOMAIN   Created site will listen on http port 80 with domain DOMAIN (default localhost)
 -s, --site-name SITE  Create a site in IIS with the name SITE (default $sitename)
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

echo "Checking for required windows features"
read -r -a features <<< "IIS-WebServerRole IIS-WebServer IIS-ISAPIExtensions IIS-ASP IIS-ASPNET45 IIS-HttpCompressionDynamic IIS-Performance IIS-IPSecurity IIS-CGI IIS-ManagementScriptingTools IIS-LegacyScripts IIS-HttpTracing IIS-RequestMonitor"

mapfile -t features_enabled < <(MSYS_NO_PATHCONV=1 $SYSTEMROOT/system32/dism.exe /Online /Get-Features | grep -B 1 'Enabled' | grep "Feature Name" | sed -e 's/Feature Name : //')

newfeatures=()
for i in "${features[@]}"; do
	skip=
	for j in "${features_enabled[@]}"; do
		[[ $i == $j ]] && { skip=1; break; }
	done
	[[ -n $skip ]] || newfeatures+=("/featurename:\\[$i\\]")
done

if (( "${#newfeatures[@]}" > 0 )) ; then
	echo "Installing windows features: ${newfeatures[@]}"
	MSYS_NO_PATHCONV=1 $SYSTEMROOT/system32/dism.exe "/Online" "/Enable-Feature" "${newfeatures[@]}" /All
fi

( echo "Checking for Web Plaform installer" && winget list -e --id Microsoft.webpicmd -s winget > /dev/null ) || ( echo "installing Web Platform installer" &&  winget install -e --id Microsoft.webpicmd -s winget )
( echo "Checking for WkHtmlToPDF" && winget list -e --id wkhtmltopdf.wkhtmltox -s winget > /dev/null) || ( echo "Installing WkHtmlToPDF" && winget install -e --id wkhtmltopdf.wkhtmltox -s winget )

echo "Checking for Microsoft Application Request Routing 3.0"
if ! wmic product get name | grep "Microsoft Application Request Routing 3.0" > /dev/null ; then
	echo "Installing Microsoft Application Request Routing 3.0"
	MSYS_NO_PATHCONV=1 /c/Program\ Files/Microsoft/Web\ Platform\ Installer/WebpiCmd.exe /Install /Products:ARRv3_0 /AcceptEula /SuppressReboot
fi

echo "Checking for Microsoft ODBC Driver 17 for SQL Server"
if ! wmic product get name | grep "Microsoft ODBC Driver 17 for SQL Server" > /dev/null ; then
	echo "Downloading Microsoft ODBC Driver 17 for SQL Server"
	curl -o $TEMP/msobdcsql.msi "https://go.microsoft.com/fwlink/?linkid=2186919"
	echo "Installing Microsoft ODBC Driver 17 for SQL Server"
	MSYS_NO_PATHCONV=1 msiexec /passive /i $TEMP\\msodbcsql.msi AgreeToLicense=yes
	rm $TEMP/msodbcsql.msi
fi

echo "Checking for Python 3.9.12"
if ! wmic product get name | grep "Python 3.9.12 Core Interpreter (64-bit)" > /dev/null ; then
	echo "Downloading Python 3.9.12"
	curl -o $TEMP/python39-amd64.exe "https://www.python.org/ftp/python/3.9.12/python-3.9.12-amd64.exe"
	echo "Installing Python 3.9.12"
	MSYS_NO_PATHCONV=1 $TEMP\\python39-amd64.exe /quiet InstallAllUsers=1 AssociateFiles=0 CompileAll=1
	rm $TEMP/python39-amd64.exe
fi

export PATH="/c/Program Files/Python39/:/c/Program Files/Python39/scripts:$PATH"
"/c/Program Files/Python39/python" -m pip install -U pip virtualenv virtualenvwrapper-win
if [[ ! -e "/c/Program Files/Python39/Lib/site-packages/pywin32-303.dist-info" ]]; then
	"/c/Program Files/Python39/python" -m pip install pywin32==303
	"/c/Program Files/Python39/python" "/c/Program Files/Python39/Scripts/pywin32_postinstall.py" -install -quiet
fi

for gencache in "'{2A75196C-D9EB-4129-B803-931327F72D5C}', 0, 2, 8" "'{00000600-0000-0010-8000-00AA006D2EA4}', 0, 6, 0" "'{B691E011-1797-432E-907A-4D8C69339129}', 0, 6, 1" "'{D97A6DA0-A85C-11CF-83AE-00A0C90C2BD8}', 0, 3, 0" "'{D97A6DA0-9C1C-11D0-9C3C-00A0C922E764}', 0, 3, 0"; do
	"/c/Program Files/Python39/python" -c "from win32com.client import gencache; gencache.EnsureModule($gencache)"
done

mkdir -p "$USERPROFILE/Envs"
for identity in "IIS_IUSRS" "IUSR"  ; do 
	MSYS_NO_PATHCONV=1 $SYSTEMROOT/system32/icacls.exe "c:\\Program Files\\Python39/Lib/site-packages/win32com/gen_py" /grant "$identity:(OI)(CI)F"
	MSYS_NO_PATHCONV=1 $SYSTEMROOT/system32/icacls.exe "$USERPROFILE/Envs" /grant "$identity:(OI)(CI)RX" /T
done
MSYS_NO_PATHCONV=1 $SYSTEMROOT/system32/icacls.exe "c:\\Program Files\\Python39/Lib/site-packages/win32com/gen_py" /grant "$USERNAME:(OI)(CI)F"

appcmd="$SYSTEMROOT/system32/inetsrv/appcmd.exe"



( echo "Checking for App Pool $sitename" && $appcmd list apppool | grep "APPPOOL \"$sitename\"" > /dev/null
) || (
echo "Adding App Pool $sitename" && MSYS_NO_PATHCONV=1 $appcmd add apppool /name:$sitename /managedPipelineMode:Integrated /commit:MACHINE/WEBROOT/APPHOST)

( echo "Checking for Site $sitename" && $appcmd list site | grep "SITE \"$sitename\"" > /dev/null
) || (
echo "Adding Site $sitename" && MSYS_NO_PATHCONV=1 $appcmd add site /name:$sitename /physicalPath:"$siteroot" /bindings:http/*:80:"$domain" )

$appcmd set config $sitename -section:system.webServer/asp /session.allowSessionState:False /enableParentPaths:True /codePage:65001 /commit:apphost
$appcmd set config $sitename  -section:system.webServer/security/requestFiltering /requestLimits.maxQueryString:8192 /requestLimits.maxUrl:8192 /commit:apphost

read -r -a headers <<< "HTTP_CIOC_FRIENDLY_RECORD_URL HTTP_CIOC_FRIENDLY_RECORD_URL_ROOT HTTP_X_FORWARDED_PROTO HTTP_CIOC_USING_SSL HTTP_CIOC_SSL_POSSIBLE RESPONSE_LOCATION HTTP_CIOC_SSL_HSTS"
mapfile -t headers_set < <($appcmd list config current -section:system.webServer/rewrite/allowedServerVariables | grep "<add name=\"" | sed -e 's/^.*<add name="//' -e 's/".*$//')
for header in "${headers[@]}"; do
	skip=
	for j in "${headers_set[@]}"; do
		[[ $header == $j ]] && { skip=1; break; }
	done
	[[ -n $skip ]] || $appcmd set config $sitename -section:system.webServer/rewrite/allowedServerVariables /+"[name='$header']" /commit:apphost
done

