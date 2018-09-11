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


# stdlib
import re
import logging

# 3rd party
from webhelpers.html import tags
from webhelpers.html.builder import HTML, literal
from markupsafe import Markup

from pyramid_simpleform import Form, State
from pyramid_simpleform.renderers import FormRenderer

# this app
from cioc.core.i18n import gettext, format_date, TranslationString, TranslationStringFactory
import cioc.core.constants as const

log = logging.getLogger(__name__)


class DefaultModel(object):
	pass

_split_re = re.compile(r'((?:-\d+)?\.?)')


def split(value):
	retval = _split_re.split(value, 1)

	return retval + ([''] * (3 - len(retval)))


def traverse_object_for_value(obj, name, is_array=False):
	try:
		return obj[name]
	except (KeyError, TypeError, IndexError):
		if is_array:
			raise

		try:
			return getattr(obj, name)
		except (AttributeError, TypeError):
			head, sep, tail = split(name)
			if head == name:
				raise KeyError

			newobj = traverse_object_for_value(obj, head)

			# array
			if sep[0] == '-':
				end = -1
				if sep[-1] != '.':
					end = len(sep)
				newobj = traverse_object_for_value(newobj, int(sep[1:end], 10), is_array=True)
				if sep[-1] != '.':
					return newobj

			return traverse_object_for_value(newobj, tail)


class CiocFormRenderer(FormRenderer):
	def value(self, name, default=None):
		try:
			return traverse_object_for_value(self.form.data, name)
		except (KeyError, AttributeError, IndexError):
			return default

	def radio(self, name, value=None, checked=False, label=None, **attrs):
		"""
		Outputs radio input.
		"""
		try:
			checked = unicode(traverse_object_for_value(self.form.data, name)) == unicode(value)
		except (KeyError, AttributeError):
			pass

		return tags.radio(name, value, checked, label, **attrs)

	def _fix_id(self, id):
		if id is None:
			return None
		return id.replace('.', '_')

	def _fix_class(self, attrs, default):
		class_ = attrs.pop('class_', None)
		if class_:
			class_ = set(class_.split())
		else:
			class_ = set()

		class_.update(default.split())
		return ' '.join(class_)

	def checkbox(self, name, value='1', checked=False, label=None, id=None, **attrs):
		try:
			checked = not not traverse_object_for_value(self.form.data, name)
		except (KeyError, AttributeError):
			pass

		return tags.checkbox(name, value, checked, label, self._fix_id(id or name), **attrs)

	def ms_checkbox(self, name, value=None, checked=False, label=None, id=None, **attrs):
		"""
		Outputs checkbox in radio style (i.e. multi select)
		"""
		checked = unicode(value) in self.value(name, []) or checked
		id = self._fix_id(id or ('_'.join((name, unicode(value)))))
		return tags.checkbox(name, value, checked, label, id, **attrs)

	def label(self, name, label=None, **attrs):
		"""
		Outputs a <label> element.

		`name`	: field name. Automatically added to "for" attribute.

		`label` : if **None**, uses the capitalized field name.
		"""
		attrs['for_'] = self._fix_id(attrs.get('for_') or name)

		label = label or name.capitalize()
		return HTML.tag("label", label, **attrs)

	def text(self, name, value=None, id=None, **attrs):
		kw = {'maxlength': 200, 'size': const.TEXT_SIZE}
		kw.update(attrs)
		kw['size'] = min((kw['maxlength']+1, kw['size']))
		return FormRenderer.text(self, name, value, self._fix_id(id or name), **kw)
	
	def proto_url(self, name, value=None, id=None, **attrs):
		kw = {
			'type': 'text', 'maxlength': 150, 'size': const.TEXT_SIZE - 5,
		}
		kw.update(attrs)
		kw['class_'] = self._fix_class(attrs, 'url')
		return self.text(name, value, id, **kw)

	def email(self, name, value=None, id=None, **attrs):
		kw = {'type': 'email', 'maxlength': 60, 'class_': self._fix_class(attrs, 'email')}
		return self.text(name, value, id, **kw)

	def textarea(self, name, value=None, id=None, **attrs):
		default_rows = attrs.pop('default_rows', const.TEXTAREA_ROWS_SHORT)
		max_rows = attrs.pop('max_rows', None)
		value = self.value(name, value) or ''
		if value:
			rows = len(value) // (const.TEXTAREA_COLS - 20) + default_rows
			if max_rows:
				rows = min([rows, max_rows])
		else:
			rows = default_rows
		kw = {'cols': const.TEXTAREA_COLS, 'rows': rows}
		kw.update(attrs)
		return FormRenderer.textarea(self, name, value, self._fix_id(id or name), **kw)

	def colour(self, name, value=None, id=None, **attrs):
		kw = {'maxlength': 50, 'size': 20}
		kw.update(attrs)
		kw['size'] = min((kw['maxlength'], kw['size']))
		kw['class_'] = self._fix_class(attrs, 'colour')

		id = id or name

		value = self.value(name, value)
		if value and value[0] == '#':
			value = value[1:]

		return literal('#') + tags.text(name, value, self._fix_id(id), **kw)

	def date(self, name, value=None, id=None, **attrs):
		kw = {'maxlength': 200, 'size': const.DATE_TEXT_SIZE}
		kw.update(attrs)
		kw['size'] = min((kw['maxlength'], kw['size']))

		kw['class_'] = self._fix_class(attrs, 'DatePicker')
		kw['id'] = self._fix_id(id or name)

		value = self.value(name, value)
		value = format_date(value, self.form.request)

		return tags.text(name, value, **kw)

	def date_search(self, name='', past=False, future=False, today=True, yesterday=True, isnull=False, notnull=False, nextmonth=False):
		request = self.form.request
		_ = lambda x: gettext(x, request)

		if name:
			prefix = name + '.'
		else:
			prefix = ''

		options = [(u'', '')]
		if past:
			options.append(('P', _('Past')))
		if future:
			options.append(('F', _('Future')))
		if today:
			options.append(('T', _('Today')))
		if yesterday:
			options.append(('Y', _('Yesterday')))
		options.extend([('7', _('Last 7 Days')), ('10', _('Last 10 Days')), ('TM', _('This Month')), ('PM', _('Previous Month'))])
		if nextmonth:
			options.append(('NM', _('Next Month')))
		if isnull:
			options.append(('N', _('Is Null')))
		if notnull:
			options.append(('NN', _('Not Null')))

		namespace = {
			'date_range_label': self.label(prefix + 'DateRange', _('Date is in: ')),
			'date_range_error': self.errorlist(prefix + 'DateRange'),
			'date_range': self.select(prefix + 'DateRange', options=options),
			'or_label': _('OR'),
			'first_date_label': self.label(prefix + 'FirstDate', _('on or after the date')),
			'first_date_error': self.errorlist(prefix + 'FirstDate'),
			'first_date': self.date(prefix + 'FirstDate'),
			'last_date_label': self.label(prefix + 'LastDate', _('before the date')),
			'last_date_error': self.errorlist(prefix + 'LastDate'),
			'last_date': self.date(prefix + 'LastDate')
		}

		return _date_search_template % namespace

	def errorlist(self, name=None, **attrs):
		"""
		Renders errors in a <ul> element if there are multiple, otherwise will
		use a div. Unless specified in attrs, class will be "Alert".

		If no errors present returns an empty string.

		`name` : errors for name. If **None** all errors will be rendered.
		"""

		if name is None:
			errors = self.all_errors()
		else:
			errors = self.errors_for(name)

		if not errors:
			return ''

		if 'class_' not in attrs:
			attrs['class_'] = "Alert"

		if len(errors) > 1:
			content = "\n".join(HTML.tag("li", error) for error in errors)

			return HTML.tag("ul", tags.literal(content), **attrs)

		return HTML.tag("div", errors[0], **attrs)


fe_tsf = TranslationStringFactory('FormEncode')


class ModelState(object):
	def __init__(self, request):
		def formencode_translator(x):
			if not isinstance(x, TranslationString):
				x = fe_tsf(x)
			return gettext(x, request)

		self.form = Form(request, state=State(_=formencode_translator, request=request))
		self.renderer = CiocFormRenderer(self.form)
		self._defaults = None

	@property
	def is_valid(self):
		if not self.form.is_validated:
			raise RuntimeError("Form has not been validated. Call validate() first")

		return not self.form.validate()

	@property
	def schema(self):
		return self.form.schema

	@schema.setter  # NOQA
	def schema(self, value):
		if self.form.schema:
			raise RuntimeError("schema property has already been set")
		self.form.schema = value

	@property
	def validators(self):
		return self.form.validators

	@validators.setter  # NOQA
	def validators(self, value):
		if self.form.validators:
			raise RuntimeError("validators property has alread been set")

		self.form.validators = value

	@property
	def method(self):
		return self.form.method

	@method.setter  # NOQA
	def method(self, value):
		self.form.method = value

	@property
	def defaults(self):
		return self._defaults

	@defaults.setter  # NOQA
	def defaults(self, value):
		if self._defaults:
			raise RuntimeError("defaults property has already been set")

		if self.form.is_validated:
			raise RuntimeError("Form has already been validated")

		self._defaults = value
		self.form.data.update(value)

	def validate(self, *args, **kw):
		return self.form.validate(*args, **kw)

	def bind(self, obj=None, include=None, exclude=None):
		if obj is None:
			obj = DefaultModel()

		return self.form.bind(obj, include, exclude)

	def value(self, name, default=None):
		return self.renderer.value(name, default)

	def is_error(self, name):
		return self.renderer.is_error(name)

	def errors_for(self, name):
		return self.renderer.errors_for(name)


_date_search_template = Markup(u'''
<table class="NoBorder cell-padding-2">
	<tr>
		<td class="FieldLabelLeftClr">%(date_range_label)s</td>
		<td>%(date_range_error)s%(date_range)s <strong>%(or_label)s</strong></td>
	</tr>
	<tr>
		<td class="FieldLabelLeftClr">%(first_date_label)s</td>
		<td>%(first_date_error)s%(first_date)s</td>
	</tr>
	<tr>
		<td class="FieldLabelLeftClr">%(last_date_label)s</td>
		<td>%(last_date_error)s%(last_date)s</td>
	</tr>
	</table>
''')
