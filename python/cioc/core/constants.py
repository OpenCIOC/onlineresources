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
import os

CIOC_TASK_NOTIFY_EMAIL = os.environ.get('CIOC_TASK_NOTIFY_EMAIL', 'qw4afPcItA5KJ18NH4nV@cioc.ca')
CIOC_ADMIN_EMAIL = os.environ.get('CIOC_ADMIN_EMAIL', 'admin@cioc.ca')

DM_CIC = 1
DM_VOL = 2
DM_CCR = 3
DM_GBL = DM_GLOBAL = 4

DM_S_CIC = "CIC"
DM_S_VOL = "VOL"
DM_S_CCR = "CCR"
DM_S_GBL = "GBL"

_ = lambda x: x
_DomainTuple = namedtuple('_DomainTuple', 'id str label')
DMT_GBL = _DomainTuple(id=DM_GLOBAL, str=DM_S_GBL, label=_('Global'))
DMT_CIC = _DomainTuple(id=DM_CIC, str=DM_S_CIC, label=_('CIC'))
DMT_VOL = _DomainTuple(id=DM_VOL, str=DM_S_VOL, label=_('Volunteer'))
DMT_CCR = _DomainTuple(id=DM_CCR, str=DM_S_CCR, label=_('Child Care'))
del _

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

# Types of Update record privileges
UPDATE_NONE = 0
UPDATE_OWNED = 1
UPDATE_ALL = 2
UPDATE_OWNED_LIST = 3

# Types of View privileges
STATS_NONE = 0
STATS_VIEW = 1
STATS_ALL = 2

# Specialized Update Types for Update Publication privileges
UPDATE_RECORD = 1

# Types of Export record privileges
EXPORT_NONE = 0
EXPORT_OWNED = 1
EXPORT_ALL = 2
EXPORT_VIEW = 3

# Types of Geo-coding
GC_BLANK = 0
GC_SITE = 1
GC_INTERSECTION = 2
GC_MANUAL = 3
GC_CURRENT = 4
GC_DONT_CHANGE = -1
MAP_PIN_MIN = 1
MAP_PIN_MAX = 12

# jQuery and jQueryUI versions
JQUERY_VERSION = "1.9.1"
JQUERY_UI_VERSION = "1.9.0"

# formatting constants
DATE_TEXT_SIZE = 25
TEXT_SIZE = 85
TEXTAREA_COLS = 85
TEXTAREA_ROWS_SHORT = 2
TEXTAREA_ROWS_LONG = 4
TEXTAREA_ROWS_XLONG = 10
TIME_TEXT_SIZE = 10
MAX_LENGTH_CHECKLIST_NOTES = 255
EMAIL_LENGTH = 60


# order by
OB_NAME = 0
OB_POS = 1
OB_RSN = 2
OB_NUM = 3
OB_UPDATE = 4
OB_RELEVANCY = 5
OB_CUSTOM = 6
OB_REQUEST = 7
OB_LOCATION = 8

_app_path = None
_config_file = None
_app_name = None
session_lock_dir = None
cache_lock_dir = None


def update_cache_values():
	# called from application init at startup
	global _app_path, _config_file, _app_name, session_lock_dir, cache_lock_dir, _sass_dir

	if _app_path is None:
		_app_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..'))
		_app_name = os.path.split(_app_path)[1]
		_config_file = os.path.join(_app_path, '..', '..', 'config', _app_name + '.ini')
		session_lock_dir = os.path.join(_app_path, 'python', 'session_lock')
		cache_lock_dir = os.path.join(_app_path, 'python', 'cache_lock')
		_sass_dir = os.path.join(_app_path, 'styles', 'sass')

		try:
			os.makedirs(session_lock_dir)
		except os.error:
			pass

		try:
			os.makedirs(cache_lock_dir)
		except os.error:
			pass
