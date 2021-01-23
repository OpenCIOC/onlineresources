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
import logging
from email.utils import formataddr
from operator import attrgetter
from itertools import groupby

from pyramid.view import view_config

from cioc.core import viewbase, validators as ciocvalidators
from cioc.core.i18n import gettext as _
from cioc.core.email import send_email
from cioc.core.rootfactories import BasicRootFactory
import six

template = 'cioc.web.gbl:templates/emaillist.mak'
log = logging.getLogger(__name__)


class EmailListContext(BasicRootFactory):
	def __init__(self, request, *args, **kwargs):
		BasicRootFactory.__init__(self, request, *args, **kwargs)

		sql = 'SELECT dbo.fn_GBL_DisplayFullOrgName_Agency(a.AgencyNUM%(DbArea)s, @@LANGID) AS AgencyName, a.UpdateEmail%(DbArea)s AS AgencyEmail  FROM GBL_Agency a WHERE AgencyCode=?' % {'DbArea': request.pageinfo.DbAreaS}
		with request.connmgr.get_connection('admin') as conn:
			agency_name = conn.execute(sql, request.user.Agency).fetchone()

		if agency_name:
			self.agency_name = agency_name.AgencyName
			self.agency_email = agency_name.AgencyEmail
		else:
			self.agency_name = None
			self.agency_email = None


def parse_access_url(value):
	if value is None:
		return value
	if isinstance(value, six.string_types):
		listval = value.split(' ')
	elif isinstance(value, (list, tuple)):
		listval = value
	else:
		raise ValueError()

	if not len(listval) == 4:
		raise ValueError()

	urlviewtype, viewtype, accessurl, protocol = listval

	if not urlviewtype:
		urlviewtype = None
	else:
		try:
			urlviewtype = int(urlviewtype)
		except (ValueError, TypeError):
			raise ValueError()

	if not viewtype:
		viewtype = None
	else:
		try:
			viewtype = int(viewtype)
		except (ValueError, TypeError):
			raise ValueError()

	return [urlviewtype, viewtype, accessurl, protocol]


class AccessURLValidator(ciocvalidators.FancyValidator):
	_ = lambda x: x
	messages = {
		'invalidAccessURL': _('URL/View not in expected format'),
	}
	del _

	def _to_python(self, value, state):

		try:
			listval = parse_access_url(value)
		except ValueError:
			raise ciocvalidators.Invalid(self.message('invalidAccessURL', state), value, state)

		return listval


class EmailListSchema(ciocvalidators.RootSchema):
	ignore_key_missing = True
	if_key_missing = None

	EmailAddress = ciocvalidators.All(validators=[
		ciocvalidators.String(max=1000),
		ciocvalidators.EmailListRegexValidator(not_empty=True)
	])
	AccessURL = AccessURLValidator(not_empty=True, if_missing=None)

	PDF = ciocvalidators.Bool()
	Subject = ciocvalidators.UnicodeString(max=255, not_empty=True)
	ReplyTo = ciocvalidators.Bool(if_missing=True, accept_iterator=True)
	BodyPrefix = ciocvalidators.UnicodeString()
	BodySuffix = ciocvalidators.UnicodeString()


def make_email_list_schema(request, list_validator):
	agency_name = request.context.agency_name
	user = request.user
	name_validator = ciocvalidators.UnicodeString(max=100, if_missing=agency_name or u' '.join([user.FirstName, user.LastName]))
	list_validator = ciocvalidators.CSVForEach(list_validator)
	return EmailListSchema(IDList=list_validator, FromName=name_validator)


class EmailRecordListBase(viewbase.ViewBase):
	def __init__(self, request):
		viewbase.ViewBase.__init__(self, request, True)

	def __call__(self):
		if self.request.method == 'POST' and not self.request.params.get('_method') == 'get':
			return self.post()

		return self.get()

	def post(self):
		request = self.request

		model_state = request.model_state
		model_state.schema = make_email_list_schema(request, self.get_list_validator())
		if not model_state.validate():
			return self.get_edit_info()

		with request.connmgr.get_connection('admin') as conn:
			record_data, access_url, out_of_view_records = self.get_rendered_records(conn)

		if not record_data:
			ErrMsg = _('No records available for the selected view', request)
			return self.get_edit_info(record_data, access_url, out_of_view_records, ErrMsg)

		user = request.user

		body = [model_state.value('BodyPrefix'), record_data, model_state.value('BodySuffix')]
		body = u'\n\n'.join([x for x in body if x])
		from_ = formataddr((model_state.value('FromName'), request.context.agency_email))
		args = {
			'author': from_,
			'to': model_state.value('EmailAddress'),
			'subject': model_state.value('Subject'),
			'message': body,
		}
		if model_state.value('ReplyTo'):
			name = u' '.join([x for x in [request.user.FirstName, request.user.LastName] if x]) or False
			args['author'] = formataddr((name, user.Email))
		try:
			send_email(request, **args)
		except Exception:
			log.exception('Error sending email')
			return self._go_to_page(
				'~/' + self.extra_link_component + 'presults.asp',
				{'ErrMsg': _('There was an error sending your Email', request)})
		else:
			return self._go_to_page(
				'~/' + self.extra_link_component + 'presults.asp',
				{'InfoMsg': _('Your Record List Email was Sent', request)})

	def get(self):
		request = self.request

		model_state = request.model_state
		model_state.schema = make_email_list_schema(request, self.get_list_validator())
		model_state.method = None

		return self.get_edit_info()

	def get_rendered_records(self, conn):
		request = self.request
		model_state = request.model_state

		access_url = model_state.value('AccessURL')
		if isinstance(access_url, six.string_types):
			# on validation error, we get raw values rather than parsed values
			try:
				access_url = parse_access_url(access_url)
			except ValueError:
				access_url = None

		if not access_url:
			# default access_url values
			dboptions_fields = ['DefaultView', 'BaseURL', 'FullSSLCompatibleBaseURL']
			access_url = [getattr(self.request.dboptions, x + request.pageinfo.DbAreaS) for x in dboptions_fields]
			access_url[-1] = 'https' if access_url[-1] else 'http'
			access_url = [None] + access_url

		exclude_keys = u'Use%sVw' % request.pageinfo.DbAreaS
		view_param = {} if not access_url[0] else {exclude_keys: six.text_type(access_url[0])}
		urlprefix = u'%s://%s' % (access_url[-1], access_url[-2])
		link_tmpl = self.get_link_template('%s', view_param, exclude_keys)

		link_tmpl = urlprefix + link_tmpl
		if model_state.value('PDF'):
			can_pdf = conn.execute('SELECT AllowPDF FROM %s_View WHERE ViewType=?' % request.pageinfo.DbAreaS, access_url[1]).fetchone()
			if can_pdf.AllowPDF:
				link_tmpl = link_tmpl % '%s/pdf'

		sql = '''EXEC %s ?, ?, ?, 1, ?''' % self.stored_proc

		cursor = conn.execute(
			sql, request.dboptions.MemberID, request.viewdata.dom.ViewType, access_url[1],
			','.join(model_state.value('IDList')))

		records = cursor.fetchall()

		item_tmpl = '%s\n' + link_tmpl

		in_view_records = None
		out_of_view_records = None
		for in_view, group in groupby(records, key=attrgetter('IN_VIEW')):
			value = '\n\n'.join(item_tmpl % (x.ORG_NAME_FULL, x.NUM) for x in group).strip()
			if in_view:
				in_view_records = value
			else:
				out_of_view_records = value

		return in_view_records, access_url, out_of_view_records

	def get_edit_info(self, record_data=None, access_url=None, out_of_view_records=None, ErrMsg=None):
		request = self.request

		model_state = request.model_state

		ErrMsg = None
		if not model_state.validate():
			# form error
			ErrMsg = _("There were validation errors.", request)
			idlist = model_state.value('IDList')
			if idlist and isinstance(idlist, six.string_types):
				# on error we get unparsed values, need to check for Comma Separated Values
				idlist = idlist.split(',')
				model_state.form.data['IDList'] = idlist

		with request.connmgr.get_connection('admin') as conn:
			urloptions = conn.execute(
				'''EXEC sp_%s_View_DomainMap_l ?''' % request.pageinfo.DbAreaS,
				request.dboptions.MemberID).fetchall()

			if not record_data:
				record_data, access_url, out_of_view_records = self.get_rendered_records(conn)

		urloptions = [
			(
				'%s %s %s %s' % (x.URLViewType or '', x.ViewType, x.AccessURL, x.Protocol),
				('* ' if x.DEFAULT_VIEW else '') + x.ViewName + ' (' + x.AccessURL + ')'
			) for x in urloptions]

		model_state.form.data['AccessURL'] = u' '.join(six.text_type(x or '') for x in access_url)
		model_state.form.data['PDF'] = 'on' if model_state.value('PDF') else ''
		model_state.form.data['IDList'] = u','.join(model_state.value('IDList'))

		title = _('Prepare Record List Email')
		return self._create_response_namespace(
			title, title,
			{
				'ErrMsg': ErrMsg,
				'record_data': record_data,
				'out_of_view_records': out_of_view_records,
				'agency_name': request.context.agency_name,
				'agency_email': request.context.agency_email,
				'urloptions': urloptions,
			}, no_index=True)


@view_config(route_name='record_list_cic', renderer=template)
class EmailRecordListCIC(EmailRecordListBase):
	stored_proc = 'sp_GBL_BaseTable_l_EmailList'
	extra_link_component = ''

	def get_list_validator(self):
		return ciocvalidators.NumValidator()

	def get_link_template(self, *args, **kwargs):
		return self.request.passvars.makeDetailsLink(*args, **kwargs)


@view_config(route_name='record_list_vol', renderer=template)
class EmailRecordListVOL(EmailRecordListBase):
	stored_proc = 'sp_VOL_Opportunity_l_EmailList'
	extra_link_component = 'volunteer/'

	def get_list_validator(self):
		return ciocvalidators.VNumValidator()

	def get_link_template(self, *args, **kwargs):
		return self.request.passvars.makeVOLDetailsLink(*args, **kwargs)
