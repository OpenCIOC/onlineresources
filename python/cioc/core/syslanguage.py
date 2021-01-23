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
from collections import namedtuple
from operator import attrgetter
import datetime

from pyramid.decorator import reify
from cioc.core.connection import ConnectionError
from six.moves import zip

# System Language Constants
LANG_ENGLISH = 0
LANG_GERMAN = 1
LANG_FRENCH = 2
LANG_JAPANESE = 3
LANG_SPANISH = 5
LANG_ITALIAN = 6
LANG_DUTCH = 7
LANG_NORWEGIAN = 8
LANG_PORTUGUESE = 9
LANG_SWEDISH = 11
LANG_CZECH = 12
LANG_HUNGARIAN = 13
LANG_POLISH = 14
LANG_ROMANIAN = 15
LANG_CROATIAN = 16
LANG_SLOVAK = 17
LANG_SLOVENIAN = 18
LANG_GREEK = 19
LANG_BULGARIAN = 20
LANG_RUSSIAN = 21
LANG_TURKISH = 22
LANG_LATVIAN = 25
LANG_LITHUANIAN = 26
LANG_TRADITIONAL_CHINESE = 28
LANG_KOREAN = 29
LANG_SIMPLIFIED_CHINESE = 30
LANG_THAI = 32

# SQL Server Language Alias Constants
SQLALIAS_ENGLISH = 'English'
SQLALIAS_GERMAN = 'German'
SQLALIAS_FRENCH = 'French'
SQLALIAS_JAPANESE = 'Japanese'
SQLALIAS_SPANISH = 'Spanish'
SQLALIAS_ITALIAN = 'Italian'
SQLALIAS_DUTCH = 'Dutch'
SQLALIAS_NORWEGIAN = 'Norwegian'
SQLALIAS_PORTUGUESE = 'Portuguese'
SQLALIAS_SWEDISH = 'Swedish'
SQLALIAS_CZECH = 'Czech'
SQLALIAS_HUNGARIAN = 'Hungarian'
SQLALIAS_POLISH = 'Polish'
SQLALIAS_ROMANIAN = 'Romanian'
SQLALIAS_CROATIAN = 'Croatian'
SQLALIAS_SLOVAK = 'Slovak'
SQLALIAS_SLOVENIAN = 'Slovenian'
SQLALIAS_GREEK = 'Greek'
SQLALIAS_BULGARIAN = 'Bulgarian'
SQLALIAS_RUSSIAN = 'Russian'
SQLALIAS_TURKISH = 'Turkish'
SQLALIAS_LATVIAN = 'Latvian'
SQLALIAS_LITHUANIAN = 'Lithuanian'
SQLALIAS_TRADITIONAL_CHINESE = 'Traditional Chinese'
SQLALIAS_KOREAN = 'Korean'
SQLALIAS_SIMPLIFIED_CHINESE = 'Simplified Chinese'
SQLALIAS_THAI = 'Thai'

# Specific Culture Codes
CULTURE_ENGLISH_CANADIAN = "en-CA"
CULTURE_FRENCH_CANADIAN = "fr-CA"
CULTURE_GERMAN = "de"
CULTURE_SPANISH = "es-MX"
CULTURE_CHINESE_SIMPLIFIED = "zh-CN"

LCID_ENGLISH_CANADIAN = 4105
LCID_FRENCH_CANADIAN = 3084


def is_active_culture(culture):
	try:
		return _culture_cache[culture].Active
	except KeyError:
		return False


def is_record_culture(culture):
	try:
		return _culture_cache[culture].ActiveRecord
	except KeyError:
		return False


def active_cultures():
	return [x.Culture for x in sorted(_culture_list, key=attrgetter('LanguageName')) if x.Active]


def active_record_cultures():
	return [x.Culture for x in sorted(_culture_list, key=lambda x: (not x.Active, x.LanguageName)) if x.ActiveRecord]


def culture_map():
	return _culture_cache.copy()

_culture_fields = 'Culture LanguageName LanguageAlias LCID LangID Active ActiveRecord DateFormatCode'
_culture_field_list = _culture_fields.split()
CultureDescriptionBase = namedtuple('CultureDescriptionBase', _culture_fields)


class CultureDescription(CultureDescriptionBase):
	slots = ('FormCulture',)

	@reify
	def FormCulture(self):
		return self.Culture.replace('-', '_')

# global value will be updated by running app
_culture_list = [
	CultureDescription(
		Culture=CULTURE_ENGLISH_CANADIAN,
		LanguageName='English',
		LanguageAlias=SQLALIAS_ENGLISH,
		LCID=LCID_ENGLISH_CANADIAN,
		LangID=LANG_ENGLISH,
		Active=False,
		ActiveRecord=False,
		DateFormatCode=106
	),
	CultureDescription(
		Culture=CULTURE_FRENCH_CANADIAN,
		LanguageName=u'Français',
		LanguageAlias=SQLALIAS_FRENCH,
		LCID=LCID_FRENCH_CANADIAN,
		LangID=LANG_FRENCH,
		Active=False,
		ActiveRecord=False,
		DateFormatCode=106
	)
]
_culture_cache = None


def update_culture_map():
	global _culture_cache

	_culture_cache = dict((x.Culture, x) for x in _culture_list)

update_culture_map()


def update_cultures(cultures):
	global _culture_list
	_culture_list = [CultureDescription(**x) for x in cultures]
	update_culture_map()

_fetched_from_db = False
_updated = None


def _fetch_from_db(request):
	global _fetched_from_db, _updated

	try:
		with request.connmgr.get_connection('admin', 'English') as conn:
			cursor = conn.execute('EXEC sp_STP_Language_lf')

			cols = [x[0] for x in cursor.description]
			langs = [dict(zip(cols, x)) for x in cursor.fetchall()]

			cursor.close()

		update_cultures(langs)
		_fetched_from_db = True
		_updated = datetime.datetime.now().isoformat()
	except ConnectionError:
		pass


class SystemLanguage(object):
	def __init__(self, request):
		if not _fetched_from_db or request.params.get('ResetDb') == 'True':
			_fetch_from_db(request)

		self.listeners = []
		self.setSystemLanguage(CULTURE_ENGLISH_CANADIAN)

	def setSystemLanguage(self, culture):
		try:
			self.description = _culture_cache[culture]
		except KeyError:
			self.description = _culture_cache[CULTURE_ENGLISH_CANADIAN]._replace(Active=True)

		for fn in self.listeners:
			fn(self.description)

	def addListener(self, fn):
		self.listeners.append(fn)

	@property
	def LocaleID(self):
		return self.description.LCID

	def __getattr__(self, key):
		""" convenience access to attributes of self.description

		>>> a = SystemLanguage()
		>>> a.description.LanuageName = a.LanguageName
		True
		>>>
		"""
		return getattr(self.description, key)
