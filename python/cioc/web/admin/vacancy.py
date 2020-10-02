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


# std lib
from __future__ import absolute_import
import logging
import six
from six.moves import map
log = logging.getLogger(__name__)

from operator import attrgetter
import itertools
import tempfile
import zipfile
from datetime import datetime

# 3rd party
from pyramid.view import view_config, view_defaults

# this app
from cioc.core.i18n import gettext as _
from cioc.web.admin import viewbase
from cioc.core.bufferedzip import BufferedZipFile
from cioc.core.utf8csv import write_csv_to_zip
from cioc.core.webobfiletool import FileIterator

templateprefix = 'cioc.web.admin:templates/vacancy/'


@view_defaults(route_name='admin_vacancy')
class Community(viewbase.AdminViewBase):

	@view_config(match_param='action=history', renderer=templateprefix + 'list.mak')
	def index(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('EXEC sp_CIC_Vacancy_l_History ?', request.dboptions.MemberID)
			history = cursor.fetchall()
			cursor.close()

		headings = [
			_('Record #', request),
			_('Record Name', request),
			_('Service Title', request),
			_('Service Title At Change', request),
			_('Vacancy Unit Type ID', request),
			_('Vacancy Unit Type GUID', request),
			_('Modified Date', request),
			_('Modified By', request),
			_('Vacancy Change', request),
			_('Total Vacancy', request)
		]
		fields = [
			'NUM',
			'OrgName',
			'ServiceTitleNow',
			'ServiceTitle',
			'BT_VUT_ID',
			'BT_VUT_GUID',
			'MODIFIED_DATE',
			'MODIFIED_BY',
			'VacancyChange',
			'VacancyFinal',
		]

		getter = attrgetter(*fields)

		def row_getter(x):
			return tuple(u'' if y is None else six.text_type(y) for y in getter(x))

		file = tempfile.TemporaryFile()
		with BufferedZipFile(file, 'w', zipfile.ZIP_DEFLATED) as zip:
			write_csv_to_zip(zip, itertools.chain([headings], map(row_getter, history)), 'vacancy_history.csv')

		length = file.tell()
		file.seek(0)
		res = request.response
		res.content_type = 'application/zip'
		res.charset = None
		res.app_iter = FileIterator(file)
		res.content_length = length
		res.headers['Content-Disposition'] = 'attachment;filename=vacancy-history-%s.zip' % (datetime.today().isoformat('-').replace(':', '-').split('.')[0])
		return res
