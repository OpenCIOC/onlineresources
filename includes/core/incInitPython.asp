<%
' =========================================================================================
'  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
'
'  Licensed under the Apache License, Version 2.0 (the "License");
'  you may not use this file except in compliance with the License.
'  You may obtain a copy of the License at
'
'	   http://www.apache.org/licenses/LICENSE-2.0
'
'  Unless required by applicable law or agreed to in writing, software
'  distributed under the License is distributed on an "AS IS" BASIS,
'  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
'  See the License for the specific language governing permissions and
'  limitations under the License.
' =========================================================================================
%>

<script language="python" runat="server">
def initialize_python(app_dir):
    #import win32traceutil
	import os, sys
	sys.dont_write_bytecode = True

    # This will be driven by the python version that is registered for activescript
	# NOTE: also update python/wsgisvc.py
	env = 'ciocenv4py2'
	if sys.version_info[0] == 3:
		env = 'ciocenv4py3'

	if app_dir[-1] == '\\' or app_dir[-1] == '/':
		app_dir = app_dir[:-1]
	activate_this = os.path.join(os.environ.get('CIOC_ENV_ROOT', os.path.join(app_dir, '..', '..')), env, 'scripts', 'activate_this.py')
	activate_this = os.path.normpath(activate_this)
	if sys.version_info[0] == 3:
		with open(activate_this, 'rb') as f:
			code = compile(f.read(), activate_this, 'exec') 
		exec(code, {'__file__': activate_this})
	else:
		execfile(activate_this, dict(__file__=activate_this))

	sys.path.insert(0, os.path.join(app_dir, 'python'))

	# without this other imports break
	import pkg_resources 

	from cioc.core import constants as const
	const.update_cache_values()

</script>
