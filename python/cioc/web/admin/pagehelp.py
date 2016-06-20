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


#std library
import os
import logging
import subprocess
from datetime import datetime

#3rd party libs
from pyramid.view import view_config

#this app
from cioc.core.i18n import gettext as _, format_date
from cioc.web.admin.viewbase import AdminViewBase

log = logging.getLogger(__name__)

templateprefix = 'cioc.web.admin:templates/page_help.mak'


class SubProcException(Exception):
	pass


git_exe_options = ['git.cmd', 'git.exe']
git_path_prefix = os.environ.get('CIOC_GIT_CMD_PREFIX', 'c:/Program Files (x86)/Git/cmd')
git = None

for git_exe in git_exe_options:
	git_exe = os.path.join(git_path_prefix, git_exe)
	if os.path.exists(git_exe):
		git = git_exe
		break


def get_git_blame(filename):
	if git is None:
		raise SubProcException("Can't find git executable", -1)

	proc = subprocess.Popen([git, 'blame', '-p', '-L', '1,1', filename], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	#proc = subprocess.Popen([git, '--version'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	output = proc.communicate()

	if proc.returncode:
		log.debug(output)
		raise SubProcException('Result Failed: \n' + output[1].join('\n'), proc.returncode)

	#blame = output
	lines = output[0].split('\n')
	return dict(x for x in (l.strip().split(' ', 1) for l in lines[1:-2]) if len(x) == 2)


def get_help_content(request, strHelpFileName):
	filename = '../pagehelp/' + strHelpFileName

	try:
		blame = get_git_blame(filename)
		last_mod_date = blame.get('committer-time')
		if last_mod_date:
			last_mod_date = datetime.fromtimestamp(int(blame['committer-time']))

		else:
			last_mod_date = datetime.now()

		last_mod_date = format_date(last_mod_date, request)
	except SubProcException, e:
		log.error('Error getting last change timestamp. Subproc returned %d: %s', e.args[1], e.args[0])
		last_mod_date = '%s' % _('Unknown')
	except WindowsError, e:
		log.exception('Error getting last change timestamp.')
		last_mod_date = '%s' % _('Unknown')

	with open(filename, 'rU') as f:
		return f.read().decode('utf-8-sig').replace('$Date$', last_mod_date)


class EmailValues(AdminViewBase):

	@view_config(route_name='admin_pagehelp', renderer='cioc.web.admin:templates/pagehelp.mak')
	def index(self):
		request = self.request

		page_name = request.params.get("Page")
		ErrMsg = ''

		page_help = None
		page_help_content = None

		title = _('Page Help', request)
		if not page_name:
			ErrMsg = _('Cannot print page help: ', request) + _("No page was chosen", request)
		else:
			with request.connmgr.get_connection('admin') as conn:
				page_help = conn.execute('EXEC dbo.sp_GBL_PageInfo_s_Help ?',
							page_name).fetchone()

			if not page_help or not os.path.exists('../pagehelp/' + page_help.HelpFileName):
				self._error_page(_('Cannot print page help: ', request) + _("No help was found for the selected page."), title=title)

			else:
				page_help_content = get_help_content(request, page_help.HelpFileName)

		return self._create_response_namespace(title, title, dict(page_help=page_help, page_help_content=page_help_content, ErrMsg=ErrMsg), no_index=True, print_table=False)
