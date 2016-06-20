# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================

# import os
import re
import sys
from subprocess import call, check_output

args = sys.argv[1:]

if len(args) != 1:
	print 'iisconfig [iissitename]'
	sys.exit(1)

config = {
	'iishome': '%systemroot%\\system32\\inetsrv',
	'iissitename': args[0]
}


def run_cmd(cmd, **kwargs):
	kwargs.update(config)
	call(cmd % kwargs, shell=True)


def get_output(cmd, **kwargs):
	kwargs.update(config)
	return check_output(cmd % kwargs, shell=True)

run_cmd("%(iishome)s\\appcmd.exe set config -section:system.webServer/proxy /enabled:True /includePortInXForwardedFor:False /preserveHostHeader:True /arrResponseHeader:False /reverseRewriteHostInResponseHeaders:False /timeout:\"01:00:00\" /commit:apphost")

run_cmd("%(iishome)s\\appcmd.exe set config \"%(iissitename)s\" -section:system.webServer/asp /session.allowSessionState:\"False\" /enableParentPaths:\"True\" /codePage:\"65001\"  /commit:apphost")

run_cmd("%(iishome)s\\appcmd.exe set config \"%(iissitename)s\" -section:system.webServer/security/requestFiltering /requestLimits.maxQueryString:8192 /requestLimits.maxUrl:8192 /commit:apphost")

output = get_output("%(iishome)s\\appcmd.exe list config \"%(iissitename)s\" -section:system.webServer/rewrite/allowedServerVariables")

headers = 'HTTP_CIOC_FRIENDLY_RECORD_URL HTTP_CIOC_FRIENDLY_RECORD_URL_ROOT HTTP_X_FORWARDED_PROTO HTTP_CIOC_USING_SSL HTTP_CIOC_SSL_POSSIBLE RESPONSE_LOCATION'.split()
for header in headers:
	if re.search(' name="' + header + '"', output):
		# already set
		continue

	run_cmd("%(iishome)s\\appcmd.exe set config \"%(iissitename)s\" -section:system.webServer/rewrite/allowedServerVariables /+[name='%(header)s'] /commit:apphost", header=header)
