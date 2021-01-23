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


# Logging
from __future__ import absolute_import
import logging
from six.moves import map
log = logging.getLogger(__name__)

# 3rd Party Libraries
from pyramid.view import view_config, view_defaults
from markupsafe import Markup

# CIOC Libraries
from cioc.core import constants as const, i18n, validators
from cioc.web.cic.viewbase import CicViewBase

templateprefix = 'cioc.web.cic:templates/generalheading/'

_ = i18n.gettext


class CodesSchema(validators.RootSchema):
	Code = validators.ForEach(validators.TaxonomyCodeValidator())

	chained_validators = [validators.ForceRequire('Code')]


class RowsSchema(validators.RootSchema):
	TC = validators.TaxonomyCodeValidator(not_empty=True)
	LV = validators.Int(min=1, max=7)


@view_defaults(route_name='cic_generalheading', match_param='action=quicktaxonomy', renderer='json')
class ActivtionsView(CicViewBase):

	@view_config(renderer=templateprefix + 'quicktaxonomy.mak')
	def quicktaxonomy(self):
		request = self.request
		user = request.user

		if not user.cic or user.cic.CanUpdatePubs != const.UPDATE_ALL:
			self._security_failure()

		model_state = request.model_state
		model_state.validators = {
				'PB_ID': validators.IDValidator(not_empty=True)
				}
		model_state.method = None

		if not model_state.validate():
			self._error_page(_('Invalid Publication ID', request))

		PB_ID = model_state.value('PB_ID')

		if user.cic.LimitedView and PB_ID and PB_ID != user.cic.PB_ID:
			self._security_failure()

		terms = []

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('''
			SELECT PubCode FROM CIC_Publication WHERE PB_ID=?

			DECLARE @MemberID int
			SET @MemberID = ?
			SELECT tm.Code,ISNULL(tmd.AltTerm,tmd.Term) AS Term,
			CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ParentList WHERE ParentCode=tm.Code) THEN 1 ELSE 0 END AS bit) AS HAS_CHILDREN,
			0 AS CountRecords,
			CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID) THEN 1 ELSE 0 END AS bit) AS Active
			FROM TAX_Term tm
			INNER JOIN TAX_Term_Description tmd
				ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID
			WHERE tm.CdLvl=1
			ORDER BY tm.Code
			''', PB_ID, request.dboptions.MemberID)

			pubcode = cursor.fetchone()
			if pubcode:
				pubcode = pubcode[0]

			cursor.nextset()

			terms = cursor.fetchall()

			cursor.close()

		title = _('Quick Create Taxonomy Headings', request)
		return self._create_response_namespace(title, title, dict(terms=self._get_dd_rows(terms, 1), pubcode=pubcode, PB_ID=PB_ID), no_index=True)

	@view_config(request_method="POST", renderer='json')
	def activations_save(self):
		request = self.request
		user = request.user

		if not user.cic or user.cic.CanUpdatePubs != const.UPDATE_ALL:
			self._security_failure()

		validator = validators.IDValidator(not_empty=True)
		try:
			PB_ID = validator.to_python(request.POST.get('PB_ID'))
		except validators.Invalid as e:
			self._error_page(_('Publication ID:', request) + e.message)

		if user.cic.LimitedView and PB_ID and user.cic.PB_ID != PB_ID:
			self._security_failure()

		model_state = request.model_state
		model_state.schema = CodesSchema()

		if model_state.validate():
			args = [PB_ID, user.Mod, request.dboptions.MemberID, not request.dboptions.OtherMembersActive or user.cic.SuperUserGlobal, ','.join(model_state.value('Code'))]

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
					DECLARE @RC int, @ErrMsg nvarchar(500), @BadCodes nvarchar(max)
					EXEC @RC = dbo.sp_CIC_GeneralHeading_i_QuickTax ?,?,?,?,?, @BadCodes OUTPUT, @ErrMsg OUTPUT

					SELECT @RC AS [Return], @ErrMsg AS ErrMsg, @BadCodes AS BadCodes
					'''
				cursor = conn.execute(sql, args)

				result = cursor.fetchone()

				cursor.close()

			if not result.Return:
				info_msg = _('The General Heading(s) were successfully added.', request) if result.BadCodes is None else result.BadCodes
				self._go_to_route('cic_publication', action='edit', _query=[('PB_ID', PB_ID), ('InfoMsg', info_msg)])

			self._error_page(result.ErrMsg)

		self._error_page(_('There were validation errors.', request))

	@view_config(match_param='action=ddrows')
	def ddrows(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		model_state = request.model_state
		model_state.method = None
		model_state.schema = RowsSchema()

		if not model_state.validate():
			return []

		if request.dboptions.OtherMembersActive:
			records_criteria = 'AND (bt.MemberID=@MemberID OR EXISTS(SELECT * FROM GBL_BT_SharingProfile WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID))'
		elif request.dboptions.OtherMembers:
			records_criteria = 'AND (bt.MemberID=@MemberID)'
		else:
			records_criteria = ''

		sql = '''
			DECLARE @MemberID int
			SET @MemberID = ?
			SELECT tm.Code,ISNULL(tmd.AltTerm,tmd.Term) AS Term,
			CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID) THEN 1 ELSE 0 END AS bit) AS Active,
			CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term WHERE ParentCode=tm.Code) THEN 1 ELSE 0 END AS bit) AS HAS_CHILDREN,
			COUNT(DISTINCT tl.NUM) AS CountRecords
			FROM TAX_Term tm
			INNER JOIN TAX_Term_Description tmd
				ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID
			LEFT JOIN CIC_BT_TAX_TM tlt
				ON tlt.Code=tm.Code
			LEFT JOIN CIC_BT_TAX tl
				ON tlt.BT_TAX_ID=tl.BT_TAX_ID
					AND EXISTS(SELECT *
						FROM GBL_BaseTable bt
						WHERE bt.NUM=tl.NUM
						%s
						)
			WHERE tm.ParentCode = ?
			GROUP BY tm.Code, tm.CdLvl, tm.CdLvl1, ISNULL(tmd.AltTerm,tmd.Term), tm.Active, tm.ParentCode
			ORDER BY tm.Code
		''' % (records_criteria)

		terms = []
		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute(sql, request.dboptions.MemberID, model_state.value('TC'))
			terms = cursor.fetchall()
			cursor.close()

		return self._get_dd_rows(terms, model_state.value('LV'))

	def _get_dd_rows(self, terms, level):
		request = self.request
		route_path = request.passvars.route_path
		query = [('TC', 'CODE')]

		plus_minus_tmpl = Markup('''<span class="SimulateLink taxPlusMinus" data-taxcode="%(Code)s" data-url="{}" data-level="%(level)d" data-closed="true"><img border="0" align="bottom" src="{}"></span>
						''').format(route_path('cic_generalheading', action='ddrows', _query=query).replace('CODE', '%(Code)s'), request.static_url('cioc:images/plus.gif'))
		no_icon_tmpl = Markup('''<span data-taxcode="%(Code)s" data-level="%(level)d"><img border="0" align="bottom" src="{}"></span>''').format(request.static_url('cioc:images/noplusminus.gif'))

		more_info_url = request.passvars.makeLink('~/jsonfeeds/tax_moreinfo.asp', [('TC', 'CODE')]).replace('CODE', '%(Code)s')

		base_tmpl = Markup('''<tr valign="top" class="TaxRowLevel%(level)d">
					<td class="%(levelclass)s"><input type="checkbox" value="%(Code)s" name="Code"></td>
					<td class="%(levelclass)s">%(Code)s</td>
					<td class="%(levelclass)s"><div class="CodeLevel%(level)d" id="tax-code-%(CodeID)s">{}&nbsp;<span class="taxExpandTerm SimulateLink TaxLink%(Inactive)s" data-closed="true" data-taxcode="%(Code)s" data-url="{}"><span class="rollup-indicator %(Rollup)s">&uArr;&nbsp;</span>%(Term)s&nbsp;%(Count)s</span>
					</div>
					<div class="taxDetail"></div>
					</td></tr>''')

		level_class = ('TaxLevel%d' % level) if level <= 2 else 'TaxBasic'

		def build_line(term):
			return base_tmpl.format((no_icon_tmpl if not term.HAS_CHILDREN else plus_minus_tmpl), more_info_url) % {
				'Code': term.Code,
				'CodeID': term.Code.replace('.', '-'),
				'Term': term.Term,
				'Inactive': '' if term.Active else 'Inactive',
				'level': level,
				'levelclass': level_class,
				'Count': (Markup('&nbsp;[%d]') % term.CountRecords) if term.CountRecords else '',
				'Rollup': '' if term.Active is None else 'hidden',
			}
		return list(map(build_line, terms))
