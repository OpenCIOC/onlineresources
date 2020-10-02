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


# stdlib
from __future__ import absolute_import
import decimal
import logging
import re
from itertools import chain
from datetime import datetime, date

# 3rd party
from formencode import Schema, validators, All, Pipe, schema, Invalid, ForEach
from formencode.validators import (Int, Bool, StringBool, Set, NoDefault, DictConverter, FieldStorageUploadConverter, OneOf, Regex, FancyValidator)
import isodate
import babel

# this app
import cioc.core.syslanguage as syslanguage
import cioc.core.constants as const
import cioc.core.i18n as i18n
import six

log = logging.getLogger(__name__)

# Make PyFlakes Happy
Pipe, Int, Bool, StringBool, Set, NoDefault, DictConverter, FieldStorageUploadConverter, OneOf, Regex

MAX_INT = 2147483647
MAX_SMALL_INT = 32767
MAX_TINY_INT = 255

ID_MIN = 1
ID_MAX = MAX_INT

MIN_NAICS_CODE = 11
MAX_NAICS_CODE = 999999

_ = i18n.tsf


class RootSchema(Schema):
	allow_extra_fields = True
	filter_extra_fields = True


class IDValidator(Int):
	strip = True
	messages = {
		'max': _("%(value)s is not a valid ID"),
		'min': _("%(value)s is not a valid ID"),
	}

	max = ID_MAX
	min = ID_MIN


class Url(validators.Regex):
	strip = True
	regex = re.compile(r'^((\d{1,3}(\.\d{1,3}){3})|([\w_-]+(\.[\w\._-]+)*))(:[0-9]+)?([/?][^\s]*)?$')

	messages = dict(
		tooLong=_('Enter a value not more than %(max)i characters long'),
		tooShort=_('Enter a value %(min)i characters long or more'),
		invalid=_("Invalid URL")
	)

	min = None
	max = None

	def validate_python(self, value, state):
		validators.Regex.validate_python(self, value, state)

		if self.max is None and self.min is None:
			return
		if value is None:
			value = ''
		elif not isinstance(value, six.string_types):
			try:
				value = str(value)
			except UnicodeEncodeError:
				value = six.text_type(value)
		if self.max is not None and len(value) > self.max:
			raise Invalid(
				self.message('tooLong', state, max=self.max), value, state)
		if self.min is not None and len(value) < self.min:
			raise Invalid(
				self.message('tooShort', state, min=self.min), value, state)

	def empty_value(self, value):
		return None

uuidre_str = '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
uuidre = re.compile(uuidre_str, re.I)


class UUIDValidator(validators.Regex):
	strip = True
	regex = uuidre
	messages = {'invalid': _("Invalid UUID")}
	regexOps = (re.I,)


code_validator_re = '^[-A-Z0-9]{,20}$'


class CodeValidator(validators.Regex):
	strip = True
	regex = re.compile(code_validator_re)
	messages = {'invalid': _("Invalid Code: Only upper case letters, numbers and dashes are allowed")}


class CharCodeValidator(validators.Regex):
	strip = True
	regex = re.compile('^[A-Z]$')
	messages = {'invalid': _("Invalid Code: Only upper case letters are allowed")}


class URLWithProto(validators.URL):
	allow_idna = False
	url_re = re.compile(r'''
		^(http|https)://
		(?:[%:\w]*@)?							   # authenticator
		(?:										   # ip or domain
		(?P<ip>(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))|
		(?P<domain>[a-z0-9][a-z0-9\-]{,62}(?:\.[a-z0-9][a-z0-9\-]{,62})*)	 # subdomain
		(?P<tld>\.[a-z]{2,63}|xn--[a-z0-9\-]{2,59})?	# top level domain
		)
		(?::[0-9]{1,5})?						   # port
		# files/delims/etc
		(?P<path>/[a-z0-9\-\._~:/\?#\[\]@!%\$&\'\(\)\*\+,;=]*)?
		$
	''', re.I | re.VERBOSE)

	def _to_python(self, value, state):
		value = value.strip()
		if self.add_http:
			if not self.scheme_re.search(value):
				value = 'http://' + value
		if self.allow_idna:
			value = self._encode_idna(value)
		match = self.scheme_re.search(value)
		if not match:
			raise Invalid(self.message('noScheme', state), value, state)
		value = match.group(0).lower() + value[len(match.group(0)):]
		match = self.url_re.search(value)
		if not match:
			raise Invalid(self.message('badURL', state), value, state)
		if not match.group('ip') and self.require_tld and not match.group('domain'):
				raise Invalid(
					self.message('noTLD', state, domain=match.group('tld')),
					value, state)
		if self.check_exists and value.startswith(('http://', 'https://')):
			self._check_url_exists(value, state)
		return value

	_convert_to_python = _to_python


class Decimal(validators.RangeValidator):
	"""Convert a value to an integer.
	Example::
		>>> Decimal.to_python('10')
		10
		>>> Decimal.to_python('ten')
		Traceback (most recent call last):
			...
		Invalid: Please enter an integer value
		>>> Int(min=5).to_python('6')
		6
		>>> Int(max=10).to_python('11')
		Traceback (most recent call last):
			...
		Invalid: Please enter a number that is 10 or smaller
	"""

	messages = dict(
		decimal=_('Please enter a decimal value'))

	def _convert_to_python(self, value, state):
		try:
			return decimal.Decimal(value)
		except (ValueError, TypeError):
			raise Invalid(self.message('decimal', state), value, state)

	_to_python = _convert_to_python
	_convert_from_python = _convert_to_python


class AgencyCodeValidator(validators.Regex):
	strip = True
	regex = re.compile('^[A-Z][A-Z][A-Z]$')
	messages = {'invalid': _("Invalid Agency Code")}


class TaxonomyCodeValidator(validators.Regex):
	strip = True
	regex = re.compile('^[A-Z]([A-Z](\-[0-9]{4}(\.[0-9]{4}(\-[0-9]{3}(\.[0-9]{2})?)?)?)?)?(\-L)?$')
	messages = {'invalid': _("Invalid Taxonomy Code")}


class NumValidator(validators.Regex):
	strip = True
	regex = re.compile('^[A-Za-z]{3}[0-9]{4,5}$')
	messages = {'invalid': _("Invalid Record Number")}


class VNumValidator(validators.Regex):
	strip = True
	regex = re.compile('^V-[A-Za-z]{3}[0-9]{4,5}$')
	messages = {'invalid': _("Invalid Record Number")}


class String(validators.String):
	strip = True
	encoding = 'cp1252'

	def empty_value(self, value):
		return None


class UnicodeString(validators.UnicodeString):
	strip = True

	def empty_value(self, value):
		return None

email_regex_str = r'''([A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+(\.[A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+)*@[A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+(\.[A-Za-z0-9!#-'\*\+\-/=\?\^_`\{-~]+)*)'''


class EmailRegexValidator(validators.Regex):
	regex = re.compile(email_regex_str)
	strip = True
	if_empty = None

	messages = {
		'invalid': _("Not a valid email address")
	}


class EmailValidator(All):
	validators = [String(max=const.EMAIL_LENGTH), EmailRegexValidator()]


class EmailListRegexValidator(validators.Regex):
	regex = re.compile(r'''%s(\s*,\s*%s)*''' % (email_regex_str, email_regex_str))
	strip = True
	if_empty = None

	messages = {
		'invalid': _("Not a valid email address list")
	}


class SlugValidator(validators.Regex):
	strip = True
	regex = re.compile(r'[a-z0-9][-_a-z0-9]{0,49}', re.I)

	messages = {'invalid': _("Invalid Slug: Only letters, numbers and dashes are allowed")}


class EmailListValidator(All):
	validators = [String(max=1000), EmailListRegexValidator()]


class NaicsCode(validators.Int):
	min = MIN_NAICS_CODE
	max = MAX_NAICS_CODE


class HexColourValidator(validators.Regex):
	regex = re.compile('^#?([0-9A-Za-z]{6})$')
	strip = True
	if_empty = None

	messages = {
		'invalid': _("Not a valid colour")
	}

	def _to_python(self, value, state):
		value = validators.Regex._to_python(self, value, state)
		if value and value[0] != '#':
			return '#' + value

		return value


class DateConverter(FancyValidator):
	strip = True
	min = None
	max = None

	messages = {
		'format': _('Not a valid date'),
		'day': _('Day is not valid for the given month'),
		'hour': _('Hour is not valid'),
		'minute': _('Minute is not valid'),
		'second': _('Second is not valid'),
		'min': _('Date must be on or after %(min)s'),
		'max': _('Date must be on or before %(min)s'),
	}

	def _to_python(self, value, state):
		gt_args = self.gettextargs
		try:
			v = self._parse_date(value, state)

			if v is None:
				raise Invalid(self.message('format', state), value, state)

		finally:
			self.gettextargs = gt_args

		return v

	def _parse_date(self, value, state):
		locale = state.request.language.FormCulture

		locale_data = babel.Locale.parse(locale)
		months = locale_data.months['format']['wide']
		shortmonths = locale_data.months['format']['abbreviated']
		date_re = r'''(?P<day>\d\d?)\s+(?P<mthname>(%(months)s|%(shortmonths)s))\s+(?P<year>\d\d(\d\d)?)''' % {'months': '|'.join(x.lower() for x in months.values()), 'shortmonths': '|'.join(x.lower() for x in shortmonths.values())}
		time_re = r'''(?P<hour>\d?\d):(?P<minute>\d\d)(:(?P<second>\d\d))?(\s+(?P<ampm>(pm|am)))?'''
		date_match = re.search(date_re, value.lower())
		if date_match is None:
			return None

		month = date_match.group('mthname')
		day = date_match.group('day')
		year = date_match.group('year')

		months = dict((v.lower(), k) for (k, v) in chain(six.iteritems(months), six.iteritems(shortmonths)))
		days = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

		day = int(day)
		year = int(year)
		month = months[month]

		if 1 > day or day > days[month - 1]:
			raise Invalid(self.message('day', state), value, state)

		if month == 2 and day == 29 and not self._isLeapYear(year):
			raise Invalid(self.message('day', state), value, state)

		time_match = re.search(time_re, value.lower())

		if time_match is not None:
			hour = time_match.group('hour')
			minute = time_match.group('minute')
			second = time_match.group('second')
			ampm = time_match.group('ampm')
			# log.debug('AMPM: %s', ampm)
			if ampm is None:
				ampm = ''

			hour = int(hour)
			minute = int(minute)
			if second is None:
				second = 0
			second = int(second)

			if hour < 0:
				raise Invalid(self.message('hour', state), value, state)

			# includes a time
			if hour < 12 and ampm.lower() == 'pm':
				# log.debug("PM bump up 12 hours")
				hour += 12

			elif hour == 12 and ampm.lower() == 'am':
				# log.debug("AM and 12, make 0")
				hour = 0

			if hour > 23:
				raise Invalid(self.message('hour', state), value, state)

			if 0 > minute or minute > 59:
				raise Invalid(self.message('minute', state), value, state)

			if 0 > second or second > 59:
				raise Invalid(self.message('second', state), value, state)

			# log.debug('calling datetime(%i, %i, %i, %i, %i, %i)', year, month, day, hour, minute, second)
			dt = datetime(year, month, day, hour, minute, second)
		else:
			# log.debug('calling datetime(%i, %i, %i)', year, month, day)
			dt = date(year, month, day)

		if self.min and dt < self.min:
			raise Invalid(self.message('min', state, min=i18n.format_date(self.min, state.request)), value, state)

		if self.max and dt > self.max:
			raise Invalid(self.message('min', state, max=i18n.format_date(self.max, state.request)), value, state)

		# log.debug('Date: %s, %s', value, repr(dt))
		return dt

	def _isLeapYear(self, year):
		if year % 400 == 0:
			return 1
		elif year % 100 == 0:
			return 0
		elif year % 4 == 0:
			return 1
		else:
			return 0


class DateSearchBase(RootSchema):
	FirstDate = DateConverter()
	LastDate = DateConverter()


_date_search_class_cache = {
}


def DateSearch(past=False, future=False, today=True, yesterday=True, isnull=False, notnull=False, nextmonth=False):
	options = ['7', '10', 'TM', 'PM']
	if past:
		options.append('P')
	if future:
		options.append('F')
	if today:
		options.append('T')
	if yesterday:
		options.append('Y')
	if isnull:
		options.append('N')
	if notnull:
		options.append('NN')
	if nextmonth:
		options.append('NM')

	optionname = ''.join(options)
	cls = _date_search_class_cache.get(optionname)
	if not cls:
		# create a new class using type(name, bases, attribute_dict)
		_date_search_class_cache[optionname] = cls = type(
			'DateSearch' + optionname,
			(DateSearchBase,),
			{'DateRange': validators.OneOf(options)}
		)

	return cls


class DeleteKeyIfEmpty(FancyValidator):
	def _to_python(self, value_dict, state):
		to_del = []
		try:
			for key, value in six.iteritems(value_dict):
				if not any(v for v in six.itervalues(value)):
					to_del.append(key)

			for key in to_del:
				del value_dict[key]
		except AttributeError:
			pass

		return value_dict


class CultureDictSchema(Schema):
	"""
	Validated a dictionary keyed on form valid culture names (i.e. en_CA,
	fr_CA) on a constant validator. Useful for validating multiple langauge
	values for *_Description or *_Name tables.

	record_cultures keyword arg to constructor indicates whether the valid langauges
	includes all the cultures available for records, or just UI interface.
	"""
	__unpackargs__ = ('validator',)
	ignore_key_missing = True

	validator = None
	record_cultures = False

	delete_empty = True

	def __initargs__(self, new_attrs):
		del new_attrs['validator']
		Schema.__initargs__(self, new_attrs)

	def _to_python(self, value_dict, state):
		sl = syslanguage
		active_cultures = sl.active_record_cultures() if self.record_cultures else sl.active_cultures()

		culture_fields = set(x.replace('-', '_') for x in active_cultures)
		existing_fields = set(self.fields.keys())

		for field in existing_fields - culture_fields:
			if field not in culture_fields:
				del self.fields[field]

		for field in culture_fields - existing_fields:
			self.fields[field] = self.validator

		retval = Schema._to_python(self, value_dict, state)
		if self.delete_empty:
			retval = DeleteKeyIfEmpty().to_python(retval, state)
		return retval


class FlagRequiredIfNoCulture(validators.FormValidator):
	__unpackargs__ = ('targetvalidator',)

	record_cultures = False
	targetvalidator = None

	def _to_python(self, value_dict, state):
		if value_dict:
			return value_dict

		sl = syslanguage
		active_cultures = sl.active_record_cultures() if self.record_cultures else sl.active_cultures()
		errors = {}

		# log.debug('active_cultures: %s', active_cultures)
		for fieldname, validator in six.iteritems(self.targetvalidator.fields):
			if not validator.not_empty:
				continue

			for culture in active_cultures:
				culture = culture.replace('-', '_')

				errors[culture + '.' + fieldname] = Invalid(self.message('empty', state), value_dict, state)

		if errors:
			raise Invalid(schema.format_compound_error(errors),
							value_dict, state, error_dict=errors)

		return value_dict


class ActiveCulture(validators.OneOf):
	"""
	Validator for checking a culture is one of ones that are currently
	active. Useful with formencode.foreach.ForEach for lists of cultures
	being processed.

	record_cultures keyword arg to constructor indicates whether the valid langauges
	includes all the cultures available for records, or just UI interface.
	"""
	__unpackargs__ = ()

	record_cultures = False

	@property
	def list(self):
		if self.record_cultures:
			return syslanguage.active_record_cultures()

		return syslanguage.active_cultures()


class RequireIfAny(validators.FormValidator):
	"""
	Require one field based on another field being present or missing.

	This validator is applied to a form, not an individual field (usually
	using a Schema's ``pre_validators`` or ``chained_validators``) and is
	available under both names ``RequireIfMissing`` and ``RequireIfPresent``.

	If you provide a ``missing`` value (a string key name) then
	if that field is missing the field must be entered.
	This gives you an either/or situation.

	If you provide a ``present`` value (another string key name) then
	if that field is present, the required field must also be present.

	::

		>>> from formencode import validators
		>>> v = validators.RequireIfPresent('phone_type', present='phone')
		>>> v.to_python(dict(phone_type='', phone='510 420	4577'))
		Traceback (most recent call last):
			...
		Invalid: You must give a value for phone_type
		>>> v.to_python(dict(phone=''))
		{'phone': ''}

	Note that if you have a validator on the optionally-required
	field, you should probably use ``if_missing=None``. This way you
	won't get an error from the Schema about a missing value. For example::

		class PhoneInput(Schema):
			phone = PhoneNumber()
			phone_type = String(if_missing=None)
			chained_validators = [RequireifPresent('phone_type', present='phone')]
	"""

	# Field that potentially is required:
	required = None
	# If this field is missing, then it is required:
	missing = None
	# If this field is present, then it is required:
	present = None
	# predicate function
	predicate = any
	__unpackargs__ = ('required',)

	messages = {
		'value-needed-for-x': _('You must give a value for %(field)s')
	}

	validate_partial_form = True

	def validate_partial(self, value_dict, state):
		self.validate_python(value_dict, state)

	def validate_python(self, value_dict, state):
		if not self.field_is_empty(value_dict.get(self.required)):
			return value_dict

		is_required = False
		if self.missing and self.predicate(not value_dict.get(m) for m in self._convert_to_list(self.missing)):
			is_required = True
		if self.present and self.predicate(value_dict.get(p) for p in self._convert_to_list(self.present)):
			is_required = True
		if is_required:
			raise Invalid(
				self.message('value-needed-for-x', state, field=self.required),
				value_dict, state,
				error_dict={self.required:
					Invalid(self.message('empty', state), value_dict, state)})
		return value_dict

	def _convert_to_list(self, value):
		if isinstance(value, (str, six.text_type)):
			return [value]
		elif value is None:
			return []
		elif isinstance(value, (list, tuple)):
			return value
		try:
			for n in value:
				break
			return value
		# @@: Should this catch any other errors?:
		except TypeError:
			return [value]


class RequireAtLeastOne(validators.FormValidator):
	"""
	Require at least one of the listed fields.
	"""

	# Fields that potentially required:
	required = None
	__unpackargs__ = ('required',)

	def _to_python(self, value_dict, state):
		fields = self._convert_to_list(self.required)
		if not any(value_dict.get(m) for m in fields):
			errors = {x: Invalid(self.message('empty', state), value_dict, state) for x in fields}
			raise Invalid(schema.format_compound_error(errors),
							value_dict, state, error_dict=errors)
		return value_dict

	def _convert_to_list(self, value):
		if isinstance(value, (str, six.text_type)):
			return [value]
		elif value is None:
			return []
		elif isinstance(value, (list, tuple)):
			return value
		try:
			for n in value:
				break
			return value
		# @@: Should this catch any other errors?:
		except TypeError:
			return [value]


class RequireNoneOrAll(validators.FormValidator):
	"""
	Require All or None fof the fields
	"""

	# Fields that potentially required:
	required = None
	__unpackargs__ = ('required',)

	def _to_python(self, value_dict, state):
		fields = self._convert_to_list(self.required)
		values = [value_dict.get(m) for m in fields]
		if any(values) and not all(values):
			errors = {x: Invalid(self.message('empty', state), value_dict, state) for x in fields
				if not value_dict.get(x)}
			raise Invalid(schema.format_compound_error(errors),
							value_dict, state, error_dict=errors)
		return value_dict

	def _convert_to_list(self, value):
		if isinstance(value, (str, six.text_type)):
			return [value]
		elif value is None:
			return []
		elif isinstance(value, (list, tuple)):
			return value
		try:
			for n in value:
				break
			return value
		# @@: Should this catch any other errors?:
		except TypeError:
			return [value]


class RequireIfPredicate(validators.FormValidator):
	"""
	Require fields based on a predicate function returning true

	This validator is applied to a form, not an individual field (usually
	using a Schema's ``pre_validators`` or ``chained_validators``).

	"""
	# Field(s) that is/are potentially required:
	required = None
	# predicate function
	predicate = None
	__unpackargs__ = ('predicate', 'required')

	validate_partial_form = True

	def validate_partial(self, field_dict, state):
		self.validate_python(field_dict, state)

	def validate_python(self, value_dict, state):
		is_required = False

		if self.predicate(value_dict, state):
			is_required = True

		errors = {}
		if is_required:
			for name in self._convert_to_list(self.required):
				if self.field_is_empty(value_dict.get(name)):
					errors[name] = Invalid(self.message('empty', state), value_dict, state)

		if errors:
			raise Invalid(schema.format_compound_error(errors),
							value_dict, state, error_dict=errors)

		return value_dict

	def _convert_to_list(self, value):
		if isinstance(value, (str, six.text_type)):
			return [value]
		elif value is None:
			return []
		elif isinstance(value, (list, tuple)):
			return value
		try:
			for n in value:
				break
			return value
		# @@: Should this catch any other errors?:
		except TypeError:
			return [value]


class Number(validators.RangeValidator):
	"""Convert a value to a float or integer.

	Tries to convert it to an integer if no information is lost.

	Example::

		>>> Number.to_python('10')
		10
		>>> Number.to_python('10.5')
		10.5
		>>> Number.to_python('ten')
		Traceback (most recent call last):
			...
		Invalid: Please enter a number
		>>> Number(min=5).to_python('6.5')
		6.5
		>>> Number(max=10.5).to_python('11.5')
		Traceback (most recent call last):
			...
		Invalid: Please enter a number that is 10.5 or smaller
		>>> Number().to_python('infinity')
		inf

	"""

	messages = dict(
		number=_('Please enter a number'))

	def _to_python(self, value, state):
		try:
			value = i18n.parse_decimal(value, state.request)
			try:
				int_value = int(value)
			except OverflowError:
				int_value = None
			if value == int_value:
				return int_value
			return value
		except ValueError:
			raise Invalid(self.message('number', state), value, state)


class ISODateConverter(FancyValidator):

	messages = {'invalidDate': _('That is not a valid day (%(exception)s)')}

	def _to_python(self, value, state):
		try:
			if 'T' in value:
				return isodate.parse_datetime(value)
			else:
				return isodate.parse_date(value)
		except (ValueError, isodate.ISO8601Error) as e:
			raise Invalid(
				self.message('invalidDate', state,
					exception=str(e)), value, state)


class ForceRequire(validators.FormValidator):
	"""
	Forced fields to be required, even if they have a missing value
	::

		>>> f = ForceRequire('pass', 'conf')
		>>> f.to_python({'pass': 'xx', 'conf': 'xx'})
		{'conf': 'xx', 'pass': 'xx'}
		>>> f.to_python({'conf': 'yy'})
		Traceback (most recent call last):
			...
		Invalid: pass: Please enter a value
	"""

	field_names = None
	validate_partial_form = True

	__unpackargs__ = ('*', 'field_names')

	def validate_partial(self, field_dict, state):
		self.validate_python(field_dict, state)

	def validate_python(self, field_dict, state):
		errors = {}
		for name in self._convert_to_list(self.field_names):
			if not field_dict.get(name):
				errors[name] = Invalid(self.message('empty', state), field_dict, state)

		if errors:
			raise Invalid(schema.format_compound_error(errors),
							field_dict, state, error_dict=errors)

		return field_dict

	def _convert_to_list(self, value):
		if isinstance(value, (str, six.text_type)):
			return [value]
		elif value is None:
			return []
		elif isinstance(value, (list, tuple)):
			return value
		try:
			for n in value:
				break
			return value
		# @@: Should this catch any other errors?:
		except TypeError:
			return [value]


class CSVForEach(ForEach):
	def _convert_to_list(self, value):
		if isinstance(value, (str, six.text_type)):
			return value.split(',')

		return ForEach._convert_to_list(self, value)
