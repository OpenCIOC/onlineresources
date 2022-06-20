# =========================================================================================
#  Copyright 2016 Community Information Online Consortium (CIOC) and KCL Software Solutions Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
# 	   http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# =========================================================================================


from __future__ import absolute_import
from collections import defaultdict
from datetime import date, datetime, time
import decimal
import os

from pyramid.i18n import make_localizer, TranslationStringFactory, TranslationString
from pyramid.threadlocal import get_current_request

from babel import Locale, dates, numbers
import formencode.api


tsf = TranslationStringFactory("cioc")


def gettext(s, request=None, *args, **kwargs):
	if not request:
		request = get_current_request()

	if not isinstance(s, TranslationString):
		s = tsf(s, *args, **kwargs)

	if request:
		return get_localizer(request).translate(s)
	return s


def ngettext(singular, plural, num, request, **kwargs):
	if not request:
		request = get_current_request()

	if "domain" not in kwargs:
		kwargs["domain"] = "cioc"

	return get_localizer(request).pluralize(singular, plural, num, **kwargs)


_localizers = {}


def get_localizer(request):
	locale_name = request.language.Culture
	try:
		return _localizers[locale_name]
	except KeyError:
		tdirs = [
			os.path.join(os.path.dirname(__file__), "..", "locale"),
			formencode.api.get_localedir(),
		]
		l = _localizers[locale_name] = make_localizer(
			locale_name.replace("-", "_"), tdirs
		)
		return l


class LocaleDict(defaultdict):
	def __missing__(self, key):
		return Locale.parse(key, sep="-")


_locales = LocaleDict()


def get_locale(request):
	return _locales[request.language.Culture]


_locale_date_format = {
	"en-CA": "d MMM yyyy",
	"fr-CA": "d MMM yyyy",
	"de": "dd.MM.yyyy",
	"fr": "d MMM yyyy",
	"es-MX": "MM/dd/yyyy",
	"it": "d MMM yyyy",
	"nl": "d MMM yyyy",
	"no": "d MMM yyyy",
	"pt": "d-MM-yyyy",
	"sv": "d MMM yyyy",
	"hu": "MMM d. yyyy",
	"pl": "d MMM yyyy",
	"ro": "d MMM yyyy",
	"hr": "d MMM yyyy",
	"sk": "dd.MM.yyyy",
	"sl": "d MMM yyyy",
	"el": "dd/MM/yyyy",
	"bg": "d MMM yyyy",
	"ru": "d MMM yyyy",
	"tr": "d MMM yyyy",
	"lv": "d MMM yyyy",
	"lt": "d MMM yyyy",
	"zh-TW": "yyyy/MM/dd",
	"ko": "yyyy/MM/dd",
	"zh-CN": "yyyy/MM/dd",
	"th": "d MMM yyyy",
}


def format_date(d, request):
	if d is None:
		return ""
	if not isinstance(d, (date, datetime, time)):
		return d

	l = get_locale(request)
	format = _locale_date_format.get(request.language.Culture, "medium")
	d_out = dates.format_date(d, locale=l, format=format)
	return d_out


def format_time(t, request):
	if t is None:
		return ""
	if not isinstance(t, (datetime, time)):
		return t

	l = get_locale(request)
	return dates.format_time(t, locale=l)


def format_datetime(dt, request):
	if dt is None:
		return ""
	if not isinstance(dt, (date, datetime, time)):
		return dt

	parts = []

	if isinstance(dt, (date, datetime)):
		parts.append(format_date(dt, request))

	if isinstance(dt, (datetime, time)):
		parts.append(format_time(dt, request))

	return " ".join(parts)


def format_decimal(d, request):
	if d is None:
		return ""
	if not isinstance(d, (float, int, decimal.Decimal)):
		return d
	l = get_locale(request)
	return numbers.format_decimal(d, locale=l)


def parse_decimal(d, request):
	if d is None:
		return None
	if isinstance(d, (int, float, decimal.Decimal)):
		return d
	l = get_locale(request)
	return numbers.parse_decimal(d, locale=l)
