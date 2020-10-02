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

# Python Libraries
from collections import namedtuple
import json

# 3rd Party Libraries
from pyramid.view import view_config, view_defaults
from markupsafe import Markup

# CIOC Libraries
from cioc.core import i18n, validators
from cioc.web.cic.viewbase import CicViewBase

templateprefix = 'cioc.web.cic:templates/taxonomy/'

_ = i18n.gettext


class OptionsSchema(validators.RootSchema):
	GlobalActivations = validators.Bool()

Options = namedtuple('Options', 'GlobalActivations')
_default_options = Options(False)


class ChangesSchema(validators.RootSchema):
	TC = validators.TaxonomyCodeValidator(not_empty=True)
	LV = validators.Int(min=1, max=7)
	action = validators.DictConverter({'activate': True, 'deactivate': False, 'rollup': None})


class RowsSchema(validators.RootSchema):
	TC = validators.TaxonomyCodeValidator(not_empty=True)
	LV = validators.Int(min=1, max=7)


@view_defaults(route_name='cic_taxonomy', match_param='action=activations', renderer='json')
class ActivtionsView(CicViewBase):
	def __init__(self, request, require_login=True):
		CicViewBase.__init__(self, request, require_login)

	@view_config(renderer=templateprefix + 'activations.mak')
	def activations(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		terms = []

		options = self._get_options()

		if options.GlobalActivations:
			active_sql = 'tm.Active'
		else:
			active_sql = 'CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID) THEN 1 ELSE 0 END AS bit) AS Active'

		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute('''
			DECLARE @MemberID int
			SET @MemberID = ?
			SELECT tm.Code,ISNULL(tmd.AltTerm,tmd.Term) AS Term,
			PreferredTerm,
			CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ParentList WHERE ParentCode=tm.Code) THEN 1 ELSE 0 END AS bit) AS HAS_CHILDREN,
			0 AS CountRecords,
			CAST(0 AS bit) AS CAN_ACTIVATE,
			CAST(0 AS bit) AS CAN_ROLLUP,
			CAST(CASE WHEN tm.Active = 1 THEN 1 ELSE 0 END AS bit) AS CAN_DEACTIVATE,
			%s
			FROM TAX_Term tm
			INNER JOIN TAX_Term_Description tmd
				ON tm.Code=tmd.Code AND tmd.LangID=@@LANGID
			WHERE tm.CdLvl=1
			ORDER BY tm.Code
			''' % active_sql, request.dboptions.MemberID)

			terms = cursor.fetchall()

			cursor.close()

		title = _('Taxonomy Activations', request)
		return self._create_response_namespace(title, title, dict(terms=self._get_dd_rows(options, terms, 1), options=options), no_index=True)

	@view_config(request_method="POST", renderer='json')
	def activations_save(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		options = self._get_options()

		model_state = request.model_state
		model_state.schema = ChangesSchema()

		if model_state.validate():
			args = [model_state.value('TC'), user.Mod, None if options.GlobalActivations else request.dboptions.MemberID, model_state.value('action')]

			with request.connmgr.get_connection('admin') as conn:
				sql = '''
					DECLARE @RC int, @ErrMsg nvarchar(500)
					EXEC @RC = dbo.sp_Tax_Term_u_Activate ?,?,?,?, @ErrMsg OUTPUT

					SELECT @RC AS [Return], @ErrMsg AS ErrMsg
					'''
				cursor = conn.execute(sql, args)

				states = cursor.fetchall()

				cursor.nextset()
				result = cursor.fetchone()

				cursor.close()

			states = [{'code': x.Code, 'active': x.Active,
						'activate': not x.Active and x.CAN_ACTIVATE,
						'deactivate': (x.Active or x.Active is None) and x.CAN_DEACTIVATE,
						'rollup': x.Active is not None and x.CAN_ROLLUP}
							for x in states]

			if not result.Return:
				return {'success': True, 'active': model_state.value('action'), 'buttonstates': states}

			return {'success': False, 'reason': result.ErrMsg, 'buttonstates': states}

		return {'success': False, 'reason': '; '.join(': '.join(x) for x in model_state.form.errors.items())}

	def _get_options(self):
		request = self.request

		validator = OptionsSchema()
		try:
			opts = validator.to_python(request.params)
			options = Options(**opts)
		except validators.Invalid:
			# Something went wrong. Tot he defaults
			options = _default_options

		if not request.dboptions.OtherMembersActive:
			options = options._replace(GlobalActivations=True)
		elif not request.user.cic.SuperUserGlobal:
			options = options._replace(GlobalActivations=False)

		log.debug('Options: %s', options)

		return options

	@view_config(match_param='action=activation_ddrows')
	def ddrows(self):
		request = self.request
		user = request.user

		if not user.cic.SuperUser:
			self._security_failure()

		options = self._get_options()

		model_state = request.model_state
		model_state.method = None
		model_state.schema = RowsSchema()

		if not model_state.validate():
			return []

		if options.GlobalActivations:
			active_sql = 'tm.Active'
			records_criteria = ''
			# Has an active parent or child, or there is nothing active on the branch
			can_activate = '''CAST(CASE
					WHEN EXISTS(SELECT * FROM TAX_Term WHERE Code=tm.ParentCode AND Active=1)
					OR EXISTS(SELECT * FROM TAX_Term WHERE ParentCode=tm.Code AND Active=1)
					OR (
						NOT EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl>tm.CdLvl AND Code LIKE tm.Code+'%' AND Active=1)
						AND NOT EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl<tm.CdLvl AND tm.Code LIKE Code+'%' AND Active=1)
					) THEN 1 ELSE 0 END AS bit)'''
			# Has an inactive or rolled-up parent or child, or is the termination of the branch; no records
			can_deactivate = '''CAST(CASE WHEN COUNT(tl.NUM)=0 AND
					(tm.CdLvl = 6
					OR NOT EXISTS(SELECT * FROM TAX_Term WHERE ParentCode=tm.Code)
					OR EXISTS(SELECT * FROM TAX_Term WHERE Code=tm.ParentCode AND NOT Active=1)
					OR EXISTS(SELECT * FROM TAX_Term WHERE ParentCode=tm.Code AND NOT Active=1)
					)
					THEN 1 ELSE 0 END AS bit)'''
			# Has an active parent (at some level) and no active children; no records
			can_rollup = '''CAST(CASE
					WHEN COUNT(tl.NUM)=0
					AND EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl<tm.CdLvl AND tm.Code LIKE Code+'%' AND Active=1)
					AND NOT EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl>tm.CdLvl AND Code LIKE tm.Code+'%' AND Active=1)
					THEN 1 ELSE 0 END AS bit)'''

		else:
			active_sql = 'CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID) THEN 1 ELSE 0 END AS bit) AS Active'
			if request.dboptions.OtherMembersActive:
				records_criteria = 'AND (bt.MemberID=@MemberID OR EXISTS(SELECT * FROM GBL_BT_SharingProfile WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID))'
			elif request.dboptions.OtherMembers:
				records_criteria = 'AND (bt.MemberID=@MemberID)'
			else:
				records_criteria = ''

			can_activate = 'CAST(CASE WHEN tm.Active=1 THEN 1 ELSE 0 END AS bit)'
			can_deactivate = '''CAST(CASE WHEN COUNT(tl.NUM)=0 THEN 1 ELSE 0 END AS bit)'''
			can_rollup = '''CAST(0 AS bit)'''

		sql = '''
			DECLARE @MemberID int
			SET @MemberID = ?
			SELECT tm.Code,ISNULL(tmd.AltTerm,tmd.Term) AS Term,
			PreferredTerm,
			%s,
			%s AS CAN_ACTIVATE,
			%s AS CAN_DEACTIVATE,
			%s AS CAN_ROLLUP,
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
			GROUP BY tm.Code, tm.CdLvl, tm.CdLvl1, ISNULL(tmd.AltTerm,tmd.Term), tm.Active, tm.PreferredTerm, tm.ParentCode
			ORDER BY tm.Code
		''' % (active_sql, can_activate, can_deactivate, can_rollup, records_criteria)

		terms = []
		with request.connmgr.get_connection('admin') as conn:
			cursor = conn.execute(sql, request.dboptions.MemberID, model_state.value('TC'))
			terms = cursor.fetchall()
			cursor.close()

		return self._get_dd_rows(options, terms, model_state.value('LV'))

	def _get_dd_rows(self, options, terms, level):
		request = self.request
		route_path = request.passvars.route_path
		query = [('TC', 'CODE')]
		if options.GlobalActivations:
			query.append(('GlobalActivations', 'on'))

		plus_minus_tmpl = Markup('''<span class="SimulateLink taxPlusMinus" data-taxcode="%(Code)s" data-url="{}" data-level="%(level)d" data-closed="true"><img border="0" align="bottom" src="{}"></span>
						''').format(route_path('cic_taxonomy', action='activation_ddrows', _query=query).replace('CODE', '%(Code)s'), request.static_url('cioc:images/plus.gif'))
		no_icon_tmpl = Markup('''<span data-taxcode="%(Code)s" data-level="%(level)d"><img border="0" align="bottom" src="{}"></span>''').format(request.static_url('cioc:images/noplusminus.gif'))

		more_info_url = request.passvars.makeLink('~/jsonfeeds/tax_moreinfo.asp', [('TC', 'CODE')]).replace('CODE', '%(Code)s')

		base_tmpl = Markup('''<tr valign="top" class="TaxRowLevel%(level)d">
					<td class="%(levelclass)s"><span%(PreferredTerm)s>%(Code)s</span></td>
					<td class="%(levelclass)s"><div class="CodeLevel%(level)d" id="tax-code-%(CodeID)s">{}&nbsp;<span class="taxExpandTerm SimulateLink TaxLink%(Inactive)s" data-closed="true" data-taxcode="%(Code)s" data-url="{}" data-state="%(State)s"><span class="rollup-indicator %(Rollup)s">&uArr;&nbsp;</span>%(Term)s&nbsp;%(Count)s</span>
					<a class="action-icon activate %(can_activate)s" data-action="activate" title="%(activate)s">%(activate)s</a>
					<a class="action-icon deactivate %(can_deactivate)s" data-action="deactivate" title="%(deactivate)s">%(deactivate)s</a>
					<a class="action-icon rollup %(can_rollup)s" data-action="rollup" title="%(rollup)s">%(rollup)s</a></div>
					<div class="taxDetail"></div>
					</td></tr>''')

		level_class = ('TaxLevel%d' % level) if level <= 2 else 'TaxBasic'
		activate = _('Activate', request)
		deactivate = _('Deactivate', request)
		rollup = _('Roll-Up', request)

		def build_line(term):
			return base_tmpl.format((no_icon_tmpl if not term.HAS_CHILDREN else plus_minus_tmpl), more_info_url) % {
				'Code': term.Code,
				'CodeID': term.Code.replace('.', '-'),
				'Term': term.Term,
				'PreferredTerm': Markup(' class="ui-state-highlight"') if term.PreferredTerm else '',
				'Inactive': '' if term.Active else 'Inactive',
				'level': level,
				'levelclass': level_class,
				'Count': (Markup('&nbsp;[%d]') % term.CountRecords) if term.CountRecords else '',
				'Rollup': '' if term.Active is None else 'hidden',
				'State': json.dumps({'CanActivate': term.CAN_ACTIVATE, 'CanDeactivate': term.CAN_DEACTIVATE, 'CanRollup': term.CAN_ROLLUP, 'Active': term.Active}),
				'activate': activate,
				'deactivate': deactivate,
				'rollup': rollup,
				'can_activate': '' if not term.Active and term.CAN_ACTIVATE else 'hidden',
				'can_deactivate': '' if (term.Active or term.Active is None) and term.CAN_DEACTIVATE else 'hidden',
				'can_rollup': '' if term.Active is not None and term.CAN_ROLLUP else 'hidden',
			}
		return list(map(build_line, terms))
