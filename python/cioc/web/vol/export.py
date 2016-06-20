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


import zipfile
import tempfile
import logging

from pyramid.response import Response
from pyramid.view import view_config

from cioc.core import i18n
from cioc.core.webobfiletool import FileIterator
from cioc.web.cic import viewbase

log = logging.getLogger(__name__)

_ = i18n.gettext

mime_type = 'application/zip'


@view_config(route_name='vol_export')
class VOLExport(viewbase.CicViewBase):

	def __call__(self):
		request = self.request
		user = request.user

		if not user.vol.SuperUser:
			self._security_failure()

		sql = 'SELECT * FROM VOL_SHARE_VIEW_EN vo WHERE ' + request.viewdata.WhereClauseVOL.replace('NON_PUBLIC', 'XNP').replace('DELETION_DATE', 'XDEL').replace('UPDATE_DATE', 'XUPD').replace('vod.', 'vo.').replace('vo.MemberID=1', '1=1')

		log.debug('SQL: %s', sql)

		log.debug('sql: %s', sql)
		data = [u'<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<ROOT xmlns="urn:ciocshare-schema-vol">'.encode('utf8')]
		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute(sql)

			data.extend(u''.join([u'<RECORD VNUM="', unicode(x.VNUM), u'" RECORD_OWNER="', unicode(x.RECORD_OWNER), u'" HAS_ENGLISH="', unicode(x.HAS_ENGLISH), u'" HAS_FRENCH="', unicode(x.HAS_FRENCH), u'">'] + map(unicode, x[7:]) + [u'</RECORD>']).encode('utf8') for x in cursor.fetchall())

			cursor.close()

		data.append(u'</ROOT>'.encode('utf8'))
		data = u'\r\n'.encode('utf8').join(data)

		file = tempfile.TemporaryFile()
		zip = zipfile.ZipFile(file, 'w', zipfile.ZIP_DEFLATED)
		zip.writestr('export.xml', data)
		zip.close()
		length = file.tell()
		file.seek(0)

		res = Response(content_type='application/zip', charset=None)
		res.app_iter = FileIterator(file)
		res.content_length = length

		res.headers['Content-Disposition'] = 'attachment;filename=Export.zip'
		return res
