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

from __future__ import absolute_import
import pyodbc

import cioc.core.constants as const

PERMISSION_ADMIN = 'admin'
PERMISSION_CIC = 'cic'
PERMISSION_VOL = 'vol'


class ConnectionError(Exception):
	pass


class ConnectionManager(object):
	def __init__(self, request):
		self.request = request
		self.config = request.config

	def get_connection_string_base(self, perm):
		config = self.config
		settings = [
			('Server', config['server']),
			('Database', config['database']),
			('UID', config[perm + '_uid']),
			('PWD', config[perm + '_pwd'])
		]

		return ';'.join('='.join(x) for x in settings)

	def get_connection_string(self, perm):
		return ';'.join(['Driver={%s}' % self.config.get('driver', 'SQL Server Native Client 10.0'), self.get_connection_string_base(perm)])

	def get_asp_connection_string(self, perm, language):
		settings = [
			('Provider', self.config.get('provider', 'SQLNCLI10')),
			('DataTypeCompatibility', '80'),
			('Persist Security Info', 'True'),
			('Current Language', language)
		]

		settings = ';'.join('='.join(x) for x in settings)
		return ';'.join([settings, self.get_connection_string_base(perm)])

	def get_connection(self, perm=None, language=None):
		if not language:
			language = self.request.language.LanguageAlias

		if not perm:
			pageinfo = getattr(self.request, 'pageinfo', None)
			if pageinfo and pageinfo.DbArea == const.DM_VOL:
				perm = PERMISSION_VOL
			else:
				perm = PERMISSION_CIC

		try:
			conn = pyodbc.connect(self.get_connection_string(perm), autocommit=True, unicode_results=True)
			conn.execute("SET LANGUAGE '" + language + "'")
		except pyodbc.Error as e:
			raise ConnectionError(e)

		return conn
