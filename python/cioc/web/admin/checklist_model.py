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
from formencode import validators
from pyramid.decorator import reify
from markupsafe import Markup

from cioc.core import constants as const, i18n, validators as ciocvalidators
import six

_ = lambda x: x


class CheckListModel(object):
	FieldName = None
	FieldNameSrc = None
	CheckListName = None

	CodeTitle = _('Code')
	CodeSize = 10
	CodeField = 'Code'
	CodeMaxLength = 20
	CodeValidator = None
	DisplayOrder = True
	CodeTip = None
	ExtraFields = None
	ExtraDescriptionFields = None
	HighlightMissingLang = True
	PageName = _('Edit Checklist / Drop-Down Values')
	PageTitleTemplate = _('Edit %(type)s Values For Checklist / Drop-Down: {0}')
	ManagePageTitleTemplate = _('Manage Checklist / Drop-Down: {0}')
	PrefixFields = None
	SearchLinkTitle = _('CIC:')
	SearchLinkTitle2 = _('Volunteer:')
	SearchLink = None
	SearchLink2 = None
	ShowAdd = True
	ShowDelete = True
	ShowNotice1 = None
	ShowNotice2 = True
	ShowOnForm = False
	UsageSQL = None
	CanDelete = True
	CanAdd = True
	CanDeleteCondition = None
	ExtraDuplicateCondition = None
	Shared = 'partial'
	SearchParameter2 = None
	ExtraWhere = None
	ExtraHideDeleteCondition = None
	ExtraNameFields = None

	@property
	def AdminAreaCode(self):
		return 'CHECK_' + self.FieldCode.upper()

	@reify
	def SearchParameter(self):
		return self.ID.replace('_', '')

	OtherSqlValidators = None

	HasMunicipality = False

	skip = False
	HasFieldName = False

	def __init__(self, request):
		self.request = request

	@reify
	def OtherMemberItemsCountSQL(self):
		MemberID = self.request.dboptions.MemberID

		if self.Shared == 'full':
			return ''

		extra_where = ''
		if self.ExtraWhere:
			extra_where = ' AND ' + self.ExtraWhere
		return ' SELECT COUNT(*) FROM %s WHERE MemberID IS NOT NULL AND MemberID <> %d%s' % (self.Table, MemberID, extra_where)

	@reify
	def OrderBy(self):
		ob = []
		if self.DisplayOrder:
			ob.append('c.DisplayOrder')

		if self.CodeTitle:
			ob.append('c.' + self.CodeField)

		ob.append('(SELECT TOP 1 Name from %(Table)s_Name n WHERE n.%(ID)s=c.%(ID)s ORDER BY CASE WHEN n.LangID=@@LANGID THEN 0 ELSE 1 END)')

		return ','.join(ob)

	@reify
	def NameSQL(self):
		if not self.FieldNameSrc and self.FieldName:
			return None

		return '''
			SELECT ISNULL(FieldDisplay, FieldName) Name
			FROM %(src)s_FieldOption fo
			LEFT JOIN %(src)s_FieldOption_Description fod
				ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
			WHERE fo.FieldName='%(name)s'
		''' % {
			'src': self.FieldNameSrc, 'name': self.FieldName
		}

	def can_delete_item(self, chkid, chkusage):
		if not chkusage:
			return True

		usage = chkusage.get(six.text_type(chkid))

		return not any(getattr(usage, x, None) for x in ['Usage1Local', 'Usage1Other', 'Usage2Local', 'Usage2Other'])

	@property
	def Table(self):
		return '_'.join((self.Domain.str, self.FieldName))

	def SelectSQLNS(self, only_mine, only_shared, no_other):
		assert not (only_mine and only_shared)
		ns = {'Table': self.Table, 'ID': self.ID, 'MemberID': self.request.dboptions.MemberID, 'Membership': '', 'Hidden': ''}
		if self.Shared == 'partial':
			ns['Hidden'] = ',CASE WHEN EXISTS(SELECT * FROM %(Table)s_InactiveByMember WHERE c.%(ID)s=%(ID)s AND MemberID=%(MemberID)d) THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END AS Hidden' % ns
			if only_mine:
				ns['Where'] = 'WHERE c.MemberID = %d' % self.request.dboptions.MemberID
			elif only_shared:
				ns['Where'] = 'WHERE c.MemberID IS NULL'
			elif no_other:  # Regular Super User
				ns['Where'] = 'WHERE (c.MemberID IS NULL OR c.MemberID = %d)' % self.request.dboptions.MemberID
			else:  # Global Super User
				ns['Where'] = ''
				ns['Membership'] = ''',
					(SELECT	MemberName
						FROM STP_Member_Description memd
						WHERE memd.MemberID=c.MemberID
							AND memd.LangID=(SELECT TOP 1 LangID FROM STP_Member_Description WHERE MemberID=memd.MemberID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
					) AS MemberName'''
		else:
			ns['Where'] = ''

		if self.ExtraWhere:
			if ns['Where']:
				ns['Where'] = ns['Where'] + ' AND ' + self.ExtraWhere
			else:
				ns['Where'] = 'WHERE ' + self.ExtraWhere

		ob = self.OrderBy or ''
		if ob:
			ob_full = 'ORDER BY ' + (ob % ns)

		ns['OrderBy'] = ob_full

		return ns

	def SelectSQL(self, only_mine, only_shared, no_other):
		ns = self.SelectSQLNS(only_mine, only_shared, no_other)
		return '''
				DECLARE @MemberID int
				SET @MemberID = %(MemberID)d
				SELECT *,
					CAST((SELECT n.*, l.Culture
					FROM %(Table)s_Name n
					INNER JOIN STP_Language l
						ON l.LangID=n.LangID AND n.%(ID)s=c.%(ID)s
					FOR XML PATH('DESC'), ROOT('DESCS'),Type) AS nvarchar(max)) AS Descriptions
					%(Hidden)s
					%(Membership)s
				FROM %(Table)s c %(Where)s %(OrderBy)s''' % ns

	def UpdateSQL(self, shared):
		other_fields = []
		other_name_fields = []
		if self.CodeTitle:
			other_fields.append((self.CodeField, 'varchar(%d)' % self.CodeMaxLength, 'NULL', 'COLLATE Latin1_General_100_CS_AS'))
		if self.DisplayOrder:
			other_fields.append(('DisplayOrder', 'tinyint', 'NOT NULL', ''))

		if self.ShowOnForm:
			other_fields.append(('ShowOnForm', 'bit', 'NOT NULL', ''))

		for field in self.ExtraFields or []:
			other_fields.append((field['field'], field['sqltype'], field.get('null', 'NOT NULL'), field.get('extra_compare', '') or ''))

		for field in self.ExtraNameFields or []:
			other_name_fields.append((field['field'], field['sqltype'], field.get('null', 'NOT NULL'), field.get('extra_compare', '') or ''))

		if self.HasFieldName:
			other_fields.append(('FieldName', 'varchar(100)', 'NOT NULL', ''))

		other_field_defs = ",\n".join(' '.join(x[:-1]) for x in other_fields)
		if other_field_defs:
			other_field_defs = ',\n' + other_field_defs

		other_name_field_defs = ",\n".join(' '.join(x[:-1]) for x in other_name_fields)
		if other_name_field_defs:
			other_name_field_defs = ',\n' + other_name_field_defs

		other_field_xquery = ',\n'.join("N.value('{0}[1]', '{1}') AS {0}".format(*x) if x[0] != 'FieldName' else "'%s' AS FieldName" % self.FieldName.replace("'", "''") for x in other_fields)
		if other_field_xquery:
			other_field_xquery = ',\n' + other_field_xquery

		other_name_field_xquery = ',\n'.join("D.value('{0}[1]', '{1}') AS {0}".format(*x) if x[0] != 'FieldName' else "'%s' AS FieldName" % self.FieldName.replace("'", "''") for x in other_name_fields)
		if other_name_field_xquery:
			other_name_field_xquery = ',\n' + other_name_field_xquery

		other_field_update = ',\n'.join('{0}=nf.{0}'.format(*x) for x in other_fields if x[0] != 'FieldName')
		if other_field_update:
			other_field_update = ',\n' + other_field_update

		other_name_field_update = ',\n'.join('{0}=nf.{0}'.format(*x) for x in other_name_fields if x[0] != 'FieldName')
		if other_name_field_update:
			other_name_field_update = ',\n' + other_name_field_update

		other_field_update_condition = ' OR '.join('chk.{0}<>nf.{0} {3} OR (chk.{0} IS NULL AND nf.{0} IS NOT NULL) OR (chk.{0} IS NOT NULL and nf.{0} IS NULL)'.format(*x) for x in other_fields if x[0] != 'FieldName')
		if other_field_update_condition:
			other_field_update_condition = ' AND (' + other_field_update_condition + ')'

		other_name_field_update_condition = ' OR '.join('chk.{0}<>nf.{0} {3} OR (chk.{0} IS NULL AND nf.{0} IS NOT NULL) OR (chk.{0} IS NOT NULL and nf.{0} IS NULL)'.format(*x) for x in other_name_fields if x[0] != 'FieldName')
		if other_name_field_update_condition:
			other_name_field_update_condition = ' OR (' + other_name_field_update_condition + ')'

		ns = {
			'ID': self.ID, 'Table': self.Table, 'OtherFieldDefs': other_field_defs,
			'OtherFieldXQuery': other_field_xquery, 'OtherFieldUpdate': other_field_update,
			'OtherFieldUpdateCondition': other_field_update_condition,
			'ExtraDuplicateCondition': self.ExtraDuplicateCondition or '',
			'OtherNameFieldDefs': other_name_field_defs,
			'OtherNameFieldXQuery': other_name_field_xquery, 'OtherNameFieldUpdate': other_name_field_update,
			'OtherNameFieldUpdateCondition': other_name_field_update_condition
		}
		add_base_sql = ''
		if self.CanAdd:
			ofi = [x[0] for x in other_fields]
			if self.Shared == 'partial' and not shared:
				ofi.insert(0, 'MemberID')

			ofi = ', '.join(ofi)
			if ofi:
				ofi = ', ' + ofi
			ns['OtherFieldInsert'] = ofi
			ofis = ['nf.{0}'.format(*x) for x in other_fields]
			if self.Shared == 'partial' and not shared:
				ofis.insert(0, '@MemberID')
			ofis = ', '.join(ofis)
			if ofis:
				ofis = ', ' + ofis
			ns['OtherFieldInsertSource'] = ofis

			add_base_sql = '''
				WHEN NOT MATCHED BY TARGET THEN
					INSERT (CREATED_BY, CREATED_DATE, MODIFIED_BY, MODIFIED_DATE %(OtherFieldInsert)s)
					VALUES (@MODIFIED_BY, GETDATE(), @MODIFIED_BY, GETDATE() %(OtherFieldInsertSource)s)
			'''
			add_base_sql %= ns

		delete_base_sql = ''
		if self.CanDelete:
			cdc = []
			if self.Shared == 'partial':
				if shared:
					cdc.append('chk.MemberID IS NULL')
				else:
					cdc.append('chk.MemberID = @MemberID')

			if self.CanDeleteCondition:
				cdc.append(self.CanDeleteCondition)

			ns['CanDeleteCondition'] = (' AND ' + ' AND '.join(cdc)) if cdc else ''

			delete_base_sql = ' WHEN NOT MATCHED BY SOURCE %(CanDeleteCondition)s THEN DELETE ' % ns

		ns['BaseInsertSQL'] = add_base_sql
		ns['BaseDeleteSQL'] = delete_base_sql

		name_insert_condition = ''
		name_delete_condition = ''
		if self.Shared == 'partial':
			name_insert_condition = ' AND EXISTS(SELECT * FROM %(Table)s WHERE %(ID)s=nf.%(ID)s)' % ns
			if shared:
				member_id_condition = ' IS NULL'
			else:
				member_id_condition = '=@MemberID'

			ns['NameDeleteMemberIDCondition'] = member_id_condition
			name_delete_condition = ''' AND EXISTS(SELECT * FROM %(Table)s t WHERE
					t.%(ID)s=chk.%(ID)s AND t.MemberID %(NameDeleteMemberIDCondition)s)''' % ns

		ns['ExtraNameInsertField'] = ''
		ns['ExtraNameInsertValue'] = ''
		ns['ExtraNameMergeSelect'] = ''
		if other_name_fields or self.HasFieldName:
			ofi = []
			ofis = []
			if other_name_fields:
				ofi = [x[0] for x in other_name_fields]
				ofis = ['nf.{0}'.format(*x) for x in other_name_fields]
				ns['ExtraNameMergeSelect'] = ',' + ', '.join(ofi)

			if self.HasFieldName:
				ofi.append('FieldName_Cache')
				ofis.append("'" + self.FieldName.replace("'", "''") + "'")
				name_delete_condition = name_delete_condition + " AND FieldName_Cache='%s'" % self.FieldName.replace("'", "''")

			ofi = ', '.join(ofi)
			if ofi:
				ofi = ', ' + ofi
			ns['ExtraNameInsertField'] = ofi
			ofis = ', '.join(ofis)
			if ofis:
				ofis = ', ' + ofis
			ns['ExtraNameInsertValue'] = ofis

		ns['NameInsertCondition'] = name_insert_condition
		ns['NameDeleteCondition'] = name_delete_condition

		if self.OtherSqlValidators:
			ns['OtherSqlValidators'] = 'END ELSE BEGIN' + self.OtherSqlValidators
		else:
			ns['OtherSqlValidators'] = ''

		sql = '''
			DECLARE @MODIFIED_BY varchar(50),
					@data xml,
					@RequestLanguage varchar(50),
					@Error int,
					@MemberID int,
					@ErrMsg varchar(500)

			SET NOCOUNT ON

			SET @Error = 0
			SET @RequestLanguage = @@LANGUAGE
			SET @MemberID = ?
			SET @MODIFIED_BY = ?
			SET @data = ?

			DECLARE @DescTable TABLE (
				%(ID)s int NULL,
				CNT int NOT NULL,
				Culture varchar(5) NOT NULL,
				LangID smallint NULL,
				Name nvarchar(200) NULL
				%(OtherNameFieldDefs)s
			)

			DECLARE @ChecklistTable TABLE (
				%(ID)s int NULL,
				CNT int NOT NULL
				%(OtherFieldDefs)s
			)

			DECLARE @NewChecklistMap TABLE (
				%(ID)s int NULL,
				CNT int NULL,
				ACTN varchar(10)
			)

			SET LANGUAGE 'English'

			INSERT INTO @ChecklistTable
			SELECT
				N.value('%(ID)s[1]', 'int') AS %(ID)s,
				N.value('CNT[1]', 'int') AS CNT
				%(OtherFieldXQuery)s
			FROM @Data.nodes('//CHK') as T(N)
			--EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

			SET LANGUAGE @RequestLanguage

			INSERT INTO @DescTable
			SELECT
				N.value('%(ID)s[1]', 'int') AS %(ID)s,
				N.value('CNT[1]', 'int') AS CNT,
				iq.*

			FROM @Data.nodes('//CHK') as T(N) CROSS APPLY
				( SELECT
					D.value('Culture[1]', 'varchar(5)') AS Culture,
					(SELECT LangID FROM STP_Language sl WHERE sl.Culture = D.value('Culture[1]', 'varchar(5)') AND ActiveRecord=1) AS LangID,
					D.value('Name[1]', 'nvarchar(200)') AS Name
					%(OtherNameFieldXQuery)s
						FROM N.nodes('DESCS/DESC') AS T2(D) ) iq

			DECLARE @BadCulturesDesc nvarchar(max), @UsedNames nvarchar(max)
			SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
			FROM @DescTable nt
			WHERE LangID IS NULL

			SELECT DISTINCT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
			FROM @DescTable ntn
			INNER JOIN @ChecklistTable nt
				ON nt.CNT=ntn.CNT
			WHERE EXISTS(SELECT * FROM @DescTable ep INNER JOIN @ChecklistTable ct ON ep.CNT=ct.CNT WHERE Name=ntn.Name AND LangID=ntn.LangID AND ep.CNT<>nt.CNT %(ExtraDuplicateCondition)s)

			IF @BadCulturesDesc IS NOT NULL BEGIN
				SET @Error = 3 -- No Such Record
				SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, cioc_shared.dbo.fn_SHR_STP_ObjectName('Language'))
			END ELSE IF @UsedNames IS NOT NULL BEGIN
				SET @Error = 6 -- Value in Use
				SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, cioc_shared.dbo.fn_SHR_STP_ObjectName('Name'))
			%(OtherSqlValidators)s
			END


			-- XXX Check for no values and delete?
			-- XXX check for modification?
			-- XXX Check for duplicates

			IF @Error = 0 BEGIN

				MERGE INTO %(Table)s AS chk
				USING @ChecklistTable AS nf
				ON chk.%(ID)s=nf.%(ID)s
				WHEN MATCHED %(OtherFieldUpdateCondition)s -- OR EXISTS FOR Name?
					THEN UPDATE SET
						MODIFIED_DATE = GETDATE(),
						MODIFIED_BY = @MODIFIED_BY
						%(OtherFieldUpdate)s
				%(BaseDeleteSQL)s
				%(BaseInsertSQL)s
				OUTPUT INSERTED.%(ID)s, nf.CNT, $action INTO @NewChecklistMap
					;

				--EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

				DELETE FROM @NewChecklistMap WHERE ACTN <> 'INSERT'

				DECLARE @ModifiedNames TABLE (
					%(ID)s int,
					ACTN varchar(10)
				)

				IF @Error = 0 BEGIN

					MERGE INTO %(Table)s_Name AS chk
					USING (
						SELECT CASE WHEN ndesc.%(ID)s = -1 THEN nid.%(ID)s ELSE ndesc.%(ID)s END AS %(ID)s,
						ndesc.LangID, ndesc.Name
						%(ExtraNameMergeSelect)s
						FROM @DescTable ndesc
						LEFT JOIN @NewChecklistMap nid
							ON ndesc.CNT=nid.CNT
						) AS nf

					ON chk.%(ID)s=nf.%(ID)s AND chk.LangID=nf.LangID
					WHEN MATCHED AND ((chk.Name + '|') <> (nf.Name + '|') COLLATE Latin1_General_100_CS_AS AND NULLIF(nf.Name, '') IS NOT NULL)
						%(OtherNameFieldUpdateCondition)s
						THEN UPDATE SET Name=nf.Name
							%(OtherNameFieldUpdate)s

					WHEN MATCHED AND NULLIF(nf.Name, '') IS NULL
						THEN DELETE

					WHEN NOT MATCHED BY TARGET %(NameInsertCondition)s
						THEN INSERT (%(ID)s, LangID, Name%(ExtraNameInsertField)s)
							VALUES (nf.%(ID)s, nf.LangID, nf.Name%(ExtraNameInsertValue)s)
					WHEN NOT MATCHED BY SOURCE %(NameDeleteCondition)s
						THEN DELETE

					OUTPUT INSERTED.%(ID)s, $action INTO @ModifiedNames
						;

					--EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

				END

				IF @Error = 0 BEGIN
					UPDATE %(Table)s
					SET MODIFIED_BY = @MODIFIED_BY, MODIFIED_DATE = GETDATE()
					WHERE EXISTS(SELECT * FROM @ModifiedNames WHERE %(Table)s.%(ID)s = %(ID)s)
				END

			END

			SELECT @Error AS [Return], @ErrMsg AS ErrMsg

			SET NOCOUNT OFF
			'''

		return sql % ns


_normal_notice_1 = _('<p class="Alert">It is strongly recommended that you do not remove or edit the values that came with the database. Keeping these shared values promotes consistency and facilitates data sharing.</p>')

_unique_code_validator = '''
	DECLARE @UsedCodes varchar(max)
	SELECT DISTINCT @UsedCodes = COALESCE(@UsedCodes + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + CAST(%(CodeField)s AS nvarchar(max))
	FROM @ChecklistTable nt
	WHERE EXISTS(SELECT * FROM @ChecklistTable ep WHERE %(CodeField)s=nt.%(CodeField)s AND ep.CNT<>nt.CNT %(ExtraCondition)s)

	IF @UsedCodes IS NOT NULL BEGIN
		SET @Error = 6 -- Value in Use
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedCodes, cioc_shared.dbo.fn_SHR_STP_ObjectName('Code'))
	END
'''


class ChkAccessibility(CheckListModel):
	FieldName = "ACCESSIBILITY"
	FieldCode = "ac"
	FieldNameSrc = "gbl"

	ID = 'AC_ID'

	Domain = const.DMT_GBL
	SearchLink = ('~/results.asp', dict(incDel='on', ACID='IDIDID'))
	SearchLink2 = ('~/results.asp', dict(incDel='on', DisplayStatus='A', ACID='IDIDID'))
	ShowNotice1 = _normal_notice_1

	UsageSQL = '''	SELECT ac.AC_ID, 
		                (SELECT COUNT(*) FROM GBL_BT_AC btac
			                INNER JOIN GBL_BaseTable bt ON btac.NUM=bt.NUM AND bt.MemberID=@MemberID
			                WHERE btac.AC_ID=ac.AC_ID) AS Usage1Local,
		                (SELECT COUNT(*) FROM GBL_BT_AC btac
			                INNER JOIN GBL_BaseTable bt ON btac.NUM=bt.NUM AND bt.MemberID<>@MemberID
			                WHERE btac.AC_ID=ac.AC_ID) AS Usage1Other,
		                (SELECT COUNT(*) FROM VOL_OP_AC voac
			                INNER JOIN VOL_Opportunity vo ON voac.VNUM=vo.VNUM AND vo.MemberID=@MemberID
			                WHERE voac.AC_ID=ac.AC_ID) AS Usage1Local,
		                (SELECT COUNT(*) FROM VOL_OP_AC voac
			                INNER JOIN VOL_Opportunity vo ON voac.VNUM=vo.VNUM AND vo.MemberID<>@MemberID
			                WHERE voac.AC_ID=ac.AC_ID) AS Usage1Other
	              FROM GBL_Accessibility ac
					'''

	CanDeleteCondition = '(NOT EXISTS(SELECT * FROM GBL_BT_AC bt WHERE bt.AC_ID=chk.AC_ID) AND NOT EXISTS(SELECT * FROM VOL_OP_AC vo WHERE vo.AC_ID=chk.AC_ID))'


class ChkAccredited(CheckListModel):
	FieldName = 'ACCREDITED'
	FieldCode = 'acr'
	FieldNameSrc = "gbl"

	ID = 'ACR_ID'

	SearchLinkTitle = None
	Domain = const.DMT_CIC
	SearchLink = ('~/results.asp', dict(incDel='on', ACRID='IDIDID'))

	Table = 'CIC_Accreditation'
	UsageSQL = '''	SELECT acr.ACR_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CIC_Accreditation acr
					LEFT JOIN CIC_BaseTable cbt
						ON cbt.ACCREDITED=acr.ACR_ID
					LEFT JOIN GBL_BaseTable bt
						ON cbt.NUM=bt.NUM
					GROUP BY acr.ACR_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BaseTable WHERE ACCREDITED=chk.ACR_ID)'


class ChkAgeGroup(CheckListModel):
	FieldName = 'AgeGroup'
	FieldCode = 'ag'
	CheckListName = _('Age Groups')
	AdminAreaCode = 'AGEGROUP'

	ID = 'AgeGroup_ID'
	SearchParameter = 'AgeGroup'

	PageName = _('Age Groups')
	PageTitleTemplate = _('Edit %(type)s Age Groups')
	ManagePageTitleTemplate = _('Manage Age Groups')
	Domain = const.DMT_GBL

	ShowNotice2 = False

	CodeTitle = None

	OrderBy = 'c.MinAge, c.MaxAge'

	DisplayOrder = False
	ExtraFields = [
		{'type': 'text', 'title': _('Min Age'), 'field': 'MinAge', 'format': i18n.format_decimal, 'kwargs': {'size': 3, 'maxlength': 4}, 'validator': ciocvalidators.Number(min=0, max=100), 'sqltype': 'decimal(5,2)', 'null': 'NULL'},
		{'type': 'text', 'title': _('Max Age'), 'field': 'MaxAge', 'format': i18n.format_decimal, 'kwargs': {'size': 3, 'maxlength': 4}, 'validator': ciocvalidators.Number(min=0, max=100), 'sqltype': 'decimal(5,2)', 'null': 'NULL'},
		{'type': 'checkbox', 'title': _('Child Care'), 'field': 'CCR', 'kwargs': {}, 'validator': validators.Bool(), 'sqltype': 'bit'}
	]


class ChkActivityStatus(CheckListModel):
	FieldName = 'Activity_Status'
	FieldCode = 'as'
	Shared = 'full'
	AdminAreaCode = 'ACTIVITYSTATUS'

	CheckListName = _('Activity Statuses')
	PageTitleTemplate = _('Edit Activity Status')
	ManagePageTitleTemplate = _('Manage Activity Status')
	Domain = const.DMT_CIC

	ID = 'ASTAT_ID'
	SearchParameter = None
	SearchLink = ('~/results.asp', dict(incDel='on', Limit='EXISTS(SELECT * FROM CIC_BT_ACT WHERE bt.NUM=NUM AND ASTAT_ID=IDIDID)'))

	UsageSQL = '''	SELECT ast.ASTAT_ID,
					COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
					COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
					NULL AS Usage2Local,
					NULL AS Usage2Other
					FROM CIC_Activity_Status ast
					LEFT JOIN (SELECT DISTINCT NUM, ASTAT_ID FROM CIC_BT_ACT) cbt
						ON cbt.ASTAT_ID=ast.ASTAT_ID
					LEFT JOIN GBL_BaseTable bt
						ON cbt.NUM=bt.NUM
					GROUP BY ast.ASTAT_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BT_ACT WHERE ASTAT_ID=chk.ASTAT_ID)'


class WithMunicipalityBase(CheckListModel):
	ExtraFields = [
		{'type': 'municipality', 'title': _('Municipality'), 'field': 'Municipality', 'kwargs': {'size': 22, 'maxlength': 200, 'class_': 'municipality'}, 'validator': ciocvalidators.IDValidator(), 'sqltype': 'int', 'null': 'NULL'}
	]

	HasMunicipality = True

	ExtraDuplicateCondition = 'AND (ct.Municipality=nt.Municipality OR (ct.Municipality IS NULL AND nt.Municipality IS NULL))'

	def SelectSQL(self, only_mine, only_shared, no_other):
		ns = self.SelectSQLNS(only_mine, only_shared, no_other)

		return '''
				DECLARE @MemberID int
				SET @MemberID = %(MemberID)d
				SELECT *, (SELECT TOP 1 ISNULL(Display,Name) FROM GBL_Community_Name WHERE CM_ID=Municipality) MunicipalityWeb,
					CAST((SELECT n.Name, l.Culture
					FROM %(Table)s_Name n
					INNER JOIN STP_Language l
						ON l.LangID=n.LangID AND n.%(ID)s=c.%(ID)s
					FOR XML PATH('DESC'), ROOT('DESCS'),Type) AS nvarchar(max)) AS Descriptions
					%(Hidden)s
					%(Membership)s

				FROM %(Table)s c %(Where)s %(OrderBy)s''' % ns


class ChkBillingAddressType(CheckListModel):
	FieldName = "BillingAddressType"
	FieldCode = "ba"
	Shared = 'full'
	AdminAreaCode = 'BILLADDRTYPE'

	ID = 'AddressTypeID'

	CheckListName = _('Billing Address Type')
	Domain = const.DMT_GBL
	SearchLink = ('~/results.asp', dict(incDel='on', Limit='EXISTS(SELECT * FROM GBL_BT_BILLINGADDRESS WHERE bt.NUM=NUM AND ADDRTYPE=IDIDID)'))
	SearchParameter = None

	ShowNotice1 = _normal_notice_1
	DisplayOrder = False

	ExtraFields = [
		{'type': 'checkbox', 'title': _('Default'), 'field': 'DefaultType', 'kwargs': {}, 'validator': validators.Bool(), 'sqltype': 'bit'}
	]

	UsageSQL = '''	SELECT ba.AddressTypeID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM GBL_BillingAddressType ba
					LEFT JOIN (SELECT DISTINCT NUM, ADDRTYPE AS AddressTypeID FROM GBL_BT_BILLINGADDRESS) btba
						ON btba.AddressTypeID=ba.AddressTypeID
					LEFT JOIN GBL_BaseTable bt
						on btba.NUM=bt.NUM
					GROUP BY ba.AddressTypeID'''

	CanDeleteCondition = '(NOT EXISTS(SELECT * FROM GBL_BT_BILLINGADDRESS bt WHERE bt.ADDRTYPE=chk.AddressTypeID))'


class ChkBusRoutes(WithMunicipalityBase):
	FieldName = 'BUS_ROUTES'
	FieldCode = 'br'
	FieldNameSrc = 'gbl'

	Table = 'CIC_BusRoute'

	Domain = const.DMT_CIC

	ID = 'BR_ID'

	HighlightMissingLang = False

	CodeField = 'RouteNumber'
	CodeTitle = _('Number')
	CodeSize = 10
	CodeMaxLength = 20
	CodeValidator = validators.String(max=CodeMaxLength, not_empty=True)

	OtherSqlValidators = _unique_code_validator % {'CodeField': 'RouteNumber', 'ExtraCondition': ' AND ISNULL(nt.Municipality, -1)=ISNULL(ep.Municipality, -1)'}

	SearchLink = ('~/results.asp', dict(incDel='on', BRID='IDIDID'))

	UsageSQL = '''	SELECT br.BR_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CIC_BusRoute br
					LEFT JOIN CIC_BT_BR pr
						ON pr.BR_ID=br.BR_ID
					LEFT JOIN GBL_BaseTable bt
						ON bt.NUM=pr.NUM
					GROUP BY br.BR_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BT_BR WHERE BR_ID=chk.BR_ID)'


class ChkCertified(CheckListModel):
	FieldName = 'CERTIFIED'
	FieldCode = 'crt'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'CRT_ID'
	Table = 'CIC_Certification'

	SearchLink = ('~/results.asp', dict(incDel='on', CRTID='IDIDID'))

	UsageSQL = '''	SELECT crt.CRT_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CIC_Certification crt
					LEFT JOIN CIC_BaseTable cbt
						ON cbt.CERTIFIED=crt.CRT_ID
					LEFT JOIN GBL_BaseTable bt
						ON cbt.NUM=bt.NUM
					GROUP BY crt.CRT_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BaseTable WHERE CERTIFIED=chk.CRT_ID)'


class ChkCommitmentLength(CheckListModel):
	FieldName = 'COMMITMENT_LENGTH'
	FieldCode = 'cl'
	FieldNameSrc = 'vol'

	Domain = const.DMT_VOL

	ID = 'CL_ID'
	Table = 'VOL_CommitmentLength'

	ShowNotice1 = _normal_notice_1

	SearchLink = ('~/volunteer/results.asp', dict(incDel='on', DisplayStatus='A', CLID='IDIDID'))
	SearchLinkTitle = _('Volunteer:')

	UsageSQL = '''	SELECT cl.CL_ID,
						COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM VOL_CommitmentLength cl
					LEFT JOIN VOL_OP_CL pr
						ON pr.CL_ID=cl.CL_ID
					LEFT JOIN VOL_Opportunity vo
						ON pr.VNUM=vo.VNUM
					GROUP BY cl.CL_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM VOL_OP_CL WHERE CL_ID=chk.CL_ID)'


class ChkCurrency(CheckListModel):
	FieldName = 'PREF_CURRENCY'
	FieldCode = 'cur'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'CUR_ID'
	Table = 'GBL_Currency'

	CodeField = 'Currency'
	CodeMaxLength = 3
	CodeSize = 3
	CodeValidator = validators.String(max=CodeMaxLength, not_empty=True)

	HighlightMissingLang = False

	SearchLink = ('~/results.asp', dict(incDel='on', CURID='IDIDID'))

	UsageSQL = '''	SELECT cur.CUR_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM GBL_Currency cur
					LEFT JOIN CIC_BaseTable cbt
						ON cbt.PREF_CURRENCY=cur.CUR_ID
					LEFT JOIN GBL_BaseTable bt
						ON cbt.NUM=bt.NUM
					GROUP BY cur.CUR_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BaseTable WHERE PREF_CURRENCY=chk.CUR_ID)'


class ChkDistribution(CheckListModel):
	FieldName = 'DISTRIBUTION'
	FieldCode = 'dst'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'DST_ID'
	CodeField = 'DistCode'
	CodeSize = CheckListModel.CodeMaxLength
	DisplayOrder = False
	CodeValidator = ciocvalidators.CodeValidator(not_empty=True)
	OtherSqlValidators = _unique_code_validator % {'CodeField': CodeField, 'ExtraCondition': ''}

	SearchLink = ('~/results.asp', dict(incDel='on', DSTID='IDIDID'))

	UsageSQL = '''	SELECT dst.DST_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CIC_Distribution dst
					LEFT JOIN CIC_BT_DST pr
						ON pr.DST_ID=dst.DST_ID
					LEFT JOIN GBL_BaseTable bt
						ON pr.NUM=bt.NUM
					GROUP BY dst.DST_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=chk.DST_ID)'


class ChkExtraChecklist(CheckListModel):
	skip = True
	HasFieldName = True

	@reify
	def is_cic(self):
		return self.FieldCode.startswith('exc')

	@reify
	def FieldCode(self):
		return self.request.params['chk']

	@reify
	def ExtraFieldSuffix(self):
		return self.FieldCode[3:].upper()

	@reify
	def FieldName(self):
		return 'EXTRA_CHECKLIST_' + self.ExtraFieldSuffix

	@reify
	def FieldNameSrc(self):
		return "gbl" if self.is_cic else 'vol'

	@reify
	def Domain(self):
		return const.DMT_CIC if self.is_cic else const.DMT_VOL

	@reify
	def SearchLinkTitle(self):
		return _('CIC:') if self.is_cic else _('Volunteer:')

	ID = 'EXC_ID'

	@reify
	def Table(self):
		return 'CIC_ExtraChecklist' if self.is_cic else 'VOL_ExtraChecklist'

	@reify
	def SearchLink(self):
		return ('~/results.asp' if self.is_cic else '~/volunteer/results.asp', {'incDel': 'on', 'EXC': self.ExtraFieldSuffix, 'EXC' + self.ExtraFieldSuffix + 'ID': 'IDIDID'})

	@reify
	def DataTable(self):
		return 'CIC_BT_EXC' if self.is_cic else 'VOL_OP_EXC'

	@reify
	def UsageSQL(self):
		args = {
			'Table': self.Table,
			'DataTable': self.DataTable,
			'FieldName': self.FieldName.replace("'", "''"),
			'RecordTable': 'GBL_BaseTable' if self.is_cic else 'VOL_Opportunity',
			'RecordID': 'NUM' if self.is_cic else 'VNUM'
		}
		return '''	SELECT exc.EXC_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM %(Table)s exc
					LEFT JOIN %(DataTable)s pr
						ON pr.EXC_ID=exc.EXC_ID
					LEFT JOIN %(RecordTable)s bt
						ON pr.%(RecordID)s=bt.%(RecordID)s
					WHERE exc.FieldName='%(FieldName)s'
					GROUP BY exc.EXC_ID
						''' % args

	@reify
	def ExtraWhere(self):
		return "FieldName='%s'" % self.FieldName.replace("'", "''")

	@reify
	def CanDeleteCondition(self):
		return "NOT EXISTS(SELECT * FROM %s WHERE EXC_ID=chk.EXC_ID) AND chk.FieldName='%s'" % (self.DataTable, self.FieldName.replace("'", "''"))

	@reify
	def ExtraHideDeleteCondition(self):
		return " AND EXISTS(SELECT * FROM %s WHERE chk.EXC_ID=EXC_ID AND FieldName='%s')" % (self.Table, self.FieldName.replace("'", "''"))


class ChkExtraDropDown(CheckListModel):
	skip = True
	HasFieldName = True

	@reify
	def is_cic(self):
		return self.FieldCode.startswith('exd')

	@reify
	def FieldCode(self):
		return self.request.params['chk']

	@reify
	def ExtraFieldSuffix(self):
		return self.FieldCode[3:].upper()

	@reify
	def FieldName(self):
		return 'EXTRA_DROPDOWN_' + self.ExtraFieldSuffix

	@reify
	def FieldNameSrc(self):
		return "gbl" if self.is_cic else 'vol'

	@reify
	def Domain(self):
		return const.DMT_CIC if self.is_cic else const.DMT_VOL

	@reify
	def SearchLinkTitle(self):
		return _('CIC:') if self.is_cic else _('Volunteer:')

	ID = 'EXD_ID'

	@reify
	def Table(self):
		return 'CIC_ExtraDropDown' if self.is_cic else 'VOL_ExtraDropDown'

	@reify
	def SearchLink(self):
		return ('~/results.asp' if self.is_cic else '~/volunteer/results.asp', {'incDel': 'on', 'EXD': self.ExtraFieldSuffix, 'EXD' + self.ExtraFieldSuffix + 'ID': 'IDIDID'})

	@reify
	def DataTable(self):
		return 'CIC_BT_EXD' if self.is_cic else 'VOL_OP_EXD'

	@reify
	def UsageSQL(self):
		args = {
			'Table': self.Table,
			'DataTable': self.DataTable,
			'FieldName': self.FieldName.replace("'", "''"),
			'RecordTable': 'GBL_BaseTable' if self.is_cic else 'VOL_Opportunity',
			'RecordID': 'NUM' if self.is_cic else 'VNUM'
		}
		return '''	SELECT exd.EXD_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM %(Table)s exd
					LEFT JOIN %(DataTable)s pr
						ON pr.EXD_ID=exd.EXD_ID
					LEFT JOIN %(RecordTable)s bt
						ON pr.%(RecordID)s=bt.%(RecordID)s
					WHERE exd.FieldName='%(FieldName)s'
					GROUP BY exd.EXD_ID
						''' % args

	@reify
	def ExtraWhere(self):
		return "FieldName='%s'" % self.FieldName.replace("'", "''")

	@reify
	def CanDeleteCondition(self):
		return "NOT EXISTS(SELECT * FROM %s WHERE EXD_ID=chk.EXD_ID) AND chk.FieldName='%s'" % (self.DataTable, self.FieldName.replace("'", "''"))

	@reify
	def ExtraHideDeleteCondition(self):
		return " AND EXISTS(SELECT * FROM %s WHERE chk.EXD_ID=EXD_ID AND FieldName='%s')" % (self.Table, self.FieldName.replace("'", "''"))


class ChkFeeType(CheckListModel):
	FieldName = 'FEES'
	FieldCode = 'ft'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'FT_ID'
	Table = 'CIC_FeeType'
	ShowNotice1 = _normal_notice_1

	SearchLink = ('~/results.asp', dict(incDel='on', FTID='IDIDID'))

	UsageSQL = '''	SELECT ft.FT_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CIC_FeeType ft
					LEFT JOIN CIC_BT_FT pr
						ON pr.FT_ID=ft.FT_ID
					LEFT JOIN GBL_BaseTable bt
						ON pr.NUM=bt.NUM
					GROUP BY ft.FT_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BT_FT WHERE FT_ID=chk.FT_ID)'


class ChkFunding(CheckListModel):
	FieldName = 'FUNDING'
	FieldCode = 'fd'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'FD_ID'
	ShowNotice1 = _normal_notice_1

	SearchLink = ('~/results.asp', dict(incDel='on', FDID='IDIDID'))

	UsageSQL = '''	SELECT fd.FD_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CIC_Funding fd
					LEFT JOIN CIC_BT_FD pr
						ON pr.FD_ID=fd.FD_ID
					LEFT JOIN GBL_BaseTable bt
						ON pr.NUM=bt.NUM
					GROUP BY fd.FD_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BT_FD WHERE FD_ID=chk.FD_ID)'


class ChkFiscalYearEnd(CheckListModel):
	FieldName = 'FISCAL_YEAR_END'
	FieldCode = 'fye'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'FYE_ID'
	Table = 'CIC_FiscalYearEnd'

	SearchLink = ('~/results.asp', dict(incDel='on', FYEID='IDIDID'))

	UsageSQL = '''	SELECT fye.FYE_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CIC_FiscalYearEnd fye
					LEFT JOIN CIC_BaseTable cbt
						ON cbt.FISCAL_YEAR_END=fye.FYE_ID
					LEFT JOIN GBL_BaseTable bt
						ON cbt.NUM=bt.NUM
					GROUP BY fye.FYE_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BaseTable WHERE FISCAL_YEAR_END=chk.FYE_ID)'


class ChkInterestGroup(CheckListModel):
	FieldName = 'InterestGroup'
	FieldCode = 'ig'
	AdminAreaCode = 'INTERESTGROUP'

	Shared = 'full'

	CheckListName = _('Interest Group')

	Domain = const.DMT_VOL

	ID = 'IG_ID'
	DisplayOrder = False

	ShowNotice1 = _('<p class="Alert">There is no requirement to complete this setup if General Areas of Interest are not being used by any member of the database.</p>')

	SearchLink = ('~/volunteer/results.asp', dict(incDel='on', DisplayStatus='A', IGID='IDIDID'))
	SearchLinkTitle = _('Volunteer:')

	UsageSQL = '''	SELECT ig.IG_ID,
						COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM VOL_InterestGroup ig
					LEFT JOIN (SELECT DISTINCT VNUM, IG_ID
								FROM VOL_AI_IG aiig
								INNER JOIN VOL_OP_AI voai
								ON aiig.AI_ID=voai.AI_ID) igvo
						ON igvo.IG_ID=ig.IG_ID
					LEFT JOIN VOL_Opportunity vo
						ON igvo.VNUM = vo.VNUM
					GROUP BY ig.IG_ID
						'''
	CanDeleteCondition = '''NOT EXISTS(SELECT *
							FROM VOL_OP_AI voai
							INNER JOIN VOL_AI_IG aigi
								ON aigi.AI_ID=voai.AI_ID AND aigi.IG_ID=chk.IG_ID)'''


class ChkInteractionLevel(CheckListModel):
	FieldName = 'INTERACTION_LEVEL'
	FieldCode = 'il'
	FieldNameSrc = 'vol'

	Domain = const.DMT_VOL

	ID = 'IL_ID'
	Table = 'VOL_InteractionLevel'
	ShowNotice1 = _normal_notice_1

	SearchLink = ('~/volunteer/results.asp', dict(incDel='on', DisplayStatus='A', ILID='IDIDID'))
	SearchLinkTitle = _('Volunteer:')

	UsageSQL = '''	SELECT il.IL_ID,
						COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM VOL_InteractionLevel il
					LEFT JOIN VOL_OP_IL pr
						ON pr.IL_ID=il.IL_ID
					LEFT JOIN VOL_Opportunity vo
						ON pr.VNUM=vo.VNUM
					GROUP BY il.IL_ID
						'''
	CanDeleteCondition = '''NOT EXISTS(SELECT * FROM VOL_OP_IL WHERE IL_ID=chk.IL_ID)'''


class ChkLanguage(CheckListModel):
	FieldName = 'LANGUAGES'
	FieldCode = 'ln'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'LN_ID'
	Table = 'GBL_Language'
	ShowNotice1 = _normal_notice_1
	ShowOnForm = True
	HighlightMissingLang = False

	SearchLink = ('~/results.asp', dict(incDel='on', LNID='IDIDID'))

	UsageSQL = '''	SELECT ln.LN_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM GBL_Language ln
					LEFT JOIN CIC_BT_LN pr
						ON pr.LN_ID=ln.LN_ID
					LEFT JOIN GBL_BaseTable bt
						ON pr.NUM=bt.NUM
					GROUP BY ln.LN_ID
	        			'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BT_LN WHERE LN_ID=chk.LN_ID)'


class ChkNoteType(CheckListModel):
	FieldName = "RecordNote_Type"
	FieldCode = "nt"
	Shared = 'full'
	AdminAreaCode = 'NOTETYPE'

	ID = 'NoteTypeID'

	Domain = const.DMT_GBL
	CheckListName = _('Note Type')
	SearchLink = ('~/results.asp', dict(incDel='on', Limit='EXISTS(SELECT * FROM GBL_RecordNote WHERE bt.NUM=GblNUM AND NoteTypeID=IDIDID)'))
	SearchLink2 = ('~/results.asp', dict(incDel='on', DisplayStatus='A', Limit='EXISTS(SELECT * FROM GBL_RecordNote WHERE op.VNUM=VolVNUM AND NoteTypeID=IDIDID)'))
	SearchParameter = None

	DisplayOrder = False

	UsageSQL = '''	SELECT nt.NoteTypeID,
						COUNT(CASE WHEN prnt.GblNUM IS NOT NULL AND prnt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN prnt.GblNUM IS NOT NULL AND prnt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						COUNT(CASE WHEN prnt.VolVNUM IS NOT NULL AND prnt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage2Local,
						COUNT(CASE WHEN prnt.VolVNUM IS NOT NULL AND prnt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage2Other
					FROM GBL_RecordNote_Type nt
					LEFT JOIN (
						SELECT DISTINCT GblNUM, VolVNUM, ISNULL(bt.MemberID,vo.MemberID) AS MemberID, NoteTypeID
						FROM GBL_RecordNote rnt
						LEFT JOIN dbo.GBL_BaseTable bt ON bt.NUM=rnt.GblNUM
						LEFT JOIN dbo.VOL_Opportunity vo ON vo.VNUM=rnt.VolVNUM
						WHERE GblNoteType IS NOT NULL
					) prnt
						ON prnt.NoteTypeID=nt.NoteTypeID
					GROUP BY nt.NoteTypeID
						'''

	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM GBL_RecordNote bt WHERE bt.NoteTypeID=chk.NoteTypeID)'


def gen_map_pin_field(itemid, usage, request):
	chkusage = usage.get(six.text_type(itemid))
	if not chkusage:
		return ''
	return Markup('<img src="%s">' % request.static_url('cioc:images/mapping/' + chkusage.MapImageSm))


class ChkMappingCategories(CheckListModel):
	FieldName = "MappingCategory"
	FieldCode = "mc"
	Shared = 'full'
	AdminAreaCode = 'MAPCATEGORY'

	ID = 'MapCatID'

	ShowNotice2 = False

	Domain = const.DMT_CIC
	Table = "GBL_MappingCategory"
	CheckListName = _('Mapping Category')
	PageTitleTemplate = _('Edit %(type)s Mapping Categories')
	ManagePageTitleTemplate = _('Manage Mapping Categories')
	SearchLink = ('~/results.asp', dict(incDel='on', Limit='bt.MAP_PIN=IDIDID AND bt.LATITUDE IS NOT NULL'))
	# SearchLink2 = ('~/results.asp', dict(incDel='on', DisplayStatus='A', ACID='IDIDID'))
	SearchParameter = None

	DisplayOrder = False
	CodeTitle = None

	OrderBy = 'MapCatID'
	UsageSQL = '''	SELECT mc.MapCatID, mc.MapImageSm,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM GBL_MappingCategory mc
					LEFT JOIN GBL_BaseTable btmc
						ON btmc.MAP_PIN=mc.MapCatID AND btmc.LATITUDE IS NOT NULL
					LEFT JOIN GBL_BaseTable bt
						ON btmc.NUM=bt.NUM
					GROUP BY mc.MapCatID, mc.MapImageSm
						'''

	CanDelete = False
	ShowAdd = False

	PrefixFields = [{'header': '', 'body': gen_map_pin_field}]


class ChkMembershipType(CheckListModel):
	FieldName = 'MEMBERSHIP'
	FieldCode = 'mt'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'MT_ID'
	Table = 'CIC_MembershipType'

	SearchLink = ('~/results.asp', dict(incDel='on', MTID='IDIDID'))

	UsageSQL = '''	SELECT mt.MT_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CIC_MembershipType mt
					LEFT JOIN CIC_BT_MT pr
						ON pr.MT_ID=mt.MT_ID
					LEFT JOIN GBL_BaseTable bt
						ON pr.NUM=bt.NUM
					GROUP BY mt.MT_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BT_MT WHERE MT_ID=chk.MT_ID)'


class ChkPaymentMethod(CheckListModel):
	FieldName = 'PREF_PAYMENT_METHOD'
	FieldCode = 'pay'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'PAY_ID'
	Table = 'GBL_PaymentMethod'

	SearchLink = ('~/results.asp', dict(incDel='on', PAYID='IDIDID'))

	UsageSQL = '''	SELECT pay.PAY_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM GBL_PaymentMethod pay
					LEFT JOIN CIC_BaseTable cbt
						ON cbt.PREF_PAYMENT_METHOD=pay.PAY_ID
					LEFT JOIN GBL_BaseTable bt
						ON cbt.NUM=bt.NUM
					GROUP BY pay.PAY_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BaseTable WHERE PREF_PAYMENT_METHOD=chk.PAY_ID)'


class ChkPaymentTerms(CheckListModel):
	FieldName = 'PAYMENT_TERMS'
	FieldCode = 'pyt'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'PYT_ID'
	Table = 'GBL_PaymentTerms'

	SearchLink = ('~/results.asp', dict(incDel='on', PYTID='IDIDID'))

	UsageSQL = '''	SELECT pyt.PYT_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM GBL_PaymentTerms pyt
					LEFT JOIN CIC_BaseTable cbt
						ON cbt.PAYMENT_TERMS=pyt.PYT_ID
					LEFT JOIN GBL_BaseTable bt
						ON cbt.NUM=bt.NUM
					GROUP BY pyt.PYT_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BaseTable WHERE PAYMENT_TERMS=chk.PYT_ID)'


class ChkQuality(CheckListModel):
	FieldName = 'QUALITY'
	FieldCode = 'rq'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'RQ_ID'
	ShowNotice1 = _normal_notice_1

	CodeField = 'Quality'
	CodeSize = 1
	CodeMaxLength = 1
	CodeValidator = ciocvalidators.CharCodeValidator(not_empty=True)
	OtherSqlValidators = _unique_code_validator % {'CodeField': 'Quality', 'ExtraCondition': ''}

	HighlightMissingLang = False

	SearchLink = ('~/results.asp', dict(incDel='on', RQID='IDIDID'))

	UsageSQL = '''	SELECT rq.RQ_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CIC_Quality rq
					LEFT JOIN CIC_BaseTable cbt
						ON cbt.QUALITY=rq.RQ_ID
					LEFT JOIN GBL_BaseTable bt
						ON cbt.NUM=bt.NUM
					GROUP BY rq.RQ_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BaseTable WHERE QUALITY=chk.RQ_ID)'


class ChkRecordType(CheckListModel):
	FieldName = 'RECORD_TYPE'
	FieldCode = 'rt'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'RT_ID'
	Table = 'CIC_RecordType'
	ShowNotice1 = _normal_notice_1

	CodeField = 'RecordType'
	CodeSize = 1
	CodeMaxLength = 1
	CodeValidator = ciocvalidators.CharCodeValidator(not_empty=True)
	OtherSqlValidators = _unique_code_validator % {'CodeField': 'RecordType', 'ExtraCondition': ''}

	HighlightMissingLang = False

	SearchLink = ('~/results.asp', dict(incDel='on', RTID='IDIDID'))

	UsageSQL = '''	SELECT rt.RT_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CIC_RecordType rt
					LEFT JOIN CIC_BaseTable cbt
						ON cbt.RECORD_TYPE=rt.RT_ID
					LEFT JOIN GBL_BaseTable bt
						ON cbt.NUM=bt.NUM
					GROUP BY rt.RT_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BaseTable WHERE RECORD_TYPE=chk.RT_ID)'


class ChkSkill(CheckListModel):
	FieldName = 'SKILLS'
	FieldCode = 'sk'
	FieldNameSrc = 'vol'

	Domain = const.DMT_VOL

	ID = 'SK_ID'
	Table = 'VOL_Skill'

	ShowNotice1 = _normal_notice_1

	SearchLink = ('~/volunteer/results.asp', dict(incDel='on', DisplayStatus='A', SKID='IDIDID'))
	SearchLinkTitle = _('Volunteer:')

	UsageSQL = '''	SELECT sk.SK_ID,
						COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM VOL_Skill sk
					LEFT JOIN VOL_OP_SK pr
						ON pr.SK_ID=sk.SK_ID
					LEFT JOIN VOL_Opportunity vo
						ON pr.VNUM=vo.VNUM
					GROUP BY sk.SK_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM VOL_OP_SK WHERE SK_ID=chk.SK_ID)'


class ChkSuitability(CheckListModel):
	FieldName = 'SUITABILITY'
	FieldCode = 'sb'
	FieldNameSrc = 'vol'

	Domain = const.DMT_VOL

	ID = 'SB_ID'
	ShowNotice1 = _normal_notice_1

	SearchLink = ('~/volunteer/results.asp', dict(incDel='on', DisplayStatus='A', SBID='IDIDID'))
	SearchLinkTitle = _('Volunteer:')

	UsageSQL = '''	SELECT sb.SB_ID,
						COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM VOL_Suitability sb
					LEFT JOIN VOL_OP_SB pr
						ON pr.SB_ID=sb.SB_ID
					INNER JOIN VOL_Opportunity vo
						ON pr.VNUM=vo.VNUM
					GROUP BY sb.SB_ID
						'''
	CanDeleteCondition = '''NOT EXISTS(SELECT * FROM VOL_OP_SB WHERE SB_ID=chk.SB_ID)'''


class ChkSchool(CheckListModel):
	FieldName = 'SCHOOL'
	FieldCode = 'sch'
	CheckListName = _('School')

	Domain = const.DMT_CIC

	ID = 'SCH_ID'
	Table = 'CCR_School'

	CodeTitle = _('School Board')
	CodeField = 'SchoolBoard'
	CodeMaxLength = 100
	CodeSize = 60

	HighlightMissingLang = False

	ShowNotice1 = _('<p class="Alert">The School checklist is shared for the Schools In-Area and School Escort fields.</p>')

	DisplayOrder = False

	SearchLinkTitle = _('In Area:')
	SearchLink = ('~/results.asp', dict(incDel='on', SCHAID='IDIDID'))
	SearchLinkTitle2 = _('Escort:')
	SearchLink2 = ('~/results.asp', dict(incDel='on', SCHEID='IDIDID'))
	SearchParameter = 'SCHAID'
	SearchParameter2 = 'SCHEID'

	UsageSQL = '''	SELECT sch.SCH_ID,
						COUNT(CASE WHEN InArea=1 AND bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN InArea=1 AND bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						COUNT(CASE WHEN Escort=1 AND bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage2Local,
						COUNT(CASE WHEN Escort=1 AND bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage2Other
					FROM CCR_School sch
					LEFT JOIN CCR_BT_SCH pr
						ON pr.SCH_ID=sch.SCH_ID
					LEFT JOIN GBL_BaseTable bt
						ON pr.NUM=bt.NUM
					GROUP BY sch.SCH_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CCR_BT_SCH WHERE SCH_ID=chk.SCH_ID)'
	ExtraDuplicateCondition = 'AND (ct.SchoolBoard=nt.SchoolBoard OR (ct.SchoolBoard IS NULL AND nt.SchoolBoard IS NULL))'


class ChkServiceLevel(CheckListModel):
	FieldName = 'SERVICE_LEVEL'
	FieldCode = 'sl'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'SL_ID'
	Table = 'CIC_ServiceLevel'
	ShowNotice1 = _normal_notice_1

	CodeField = 'ServiceLevelCode'
	CodeSize = 2
	CodeMaxLength = 2
	CodeValidator = validators.Regex('(0[1-9])|([1-9]\d)', not_empty=True)
	OtherSqlValidators = _unique_code_validator % {'CodeField': 'ServiceLevelCode', 'ExtraCondition': ''}
	CodeTip = _('A two digit number')

	HighlightMissingLang = False

	DisplayOrder = False

	SearchLink = ('~/results.asp', dict(incDel='on', SLID='IDIDID'))

	UsageSQL = '''	SELECT sl.SL_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CIC_ServiceLevel sl
					LEFT JOIN CIC_BT_SL pr
						ON pr.SL_ID=sl.SL_ID
					LEFT JOIN GBL_BaseTable bt
						ON pr.NUM=bt.NUM
					GROUP BY sl.SL_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BT_SL WHERE SL_ID=chk.SL_ID)'


class ChkSeason(CheckListModel):
	FieldName = 'SEASONS'
	FieldCode = 'ssn'
	FieldNameSrc = 'vol'

	Domain = const.DMT_VOL

	ID = 'SSN_ID'
	ShowNotice1 = _normal_notice_1

	SearchLink = ('~/volunteer/results.asp', dict(incDel='on', DisplayStatus='A', SSNID='IDIDID'))
	SearchLinkTitle = _('Volunteer:')

	UsageSQL = '''	SELECT ssn.SSN_ID,
						COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM VOL_Seasons ssn
					LEFT JOIN VOL_OP_SSN pr
						ON pr.SSN_ID=ssn.SSN_ID
					INNER JOIN VOL_Opportunity vo
						ON pr.VNUM=vo.VNUM
					GROUP BY ssn.SSN_ID
						'''
	CanDeleteCondition = '''NOT EXISTS(SELECT * FROM VOL_OP_SSN WHERE SSN_ID=chk.SSN_ID)'''


class ChkTypeOfCare(CheckListModel):
	FieldName = 'TYPE_OF_CARE'
	FieldCode = 'toc'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'TOC_ID'
	Table = 'CCR_TypeOfCare'
	ShowNotice1 = _normal_notice_1

	SearchLink = ('~/results.asp', dict(incDel='on', TOCID='IDIDID'))

	UsageSQL = '''	SELECT toc.TOC_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CCR_TypeOfCare toc
					LEFT JOIN CCR_BT_TOC pr
						ON pr.TOC_ID=toc.TOC_ID
					LEFT JOIN GBL_BaseTable bt
						ON pr.NUM=bt.NUM
					GROUP BY toc.TOC_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CCR_BT_TOC WHERE TOC_ID=chk.TOC_ID)'


class ChkTypeOfProgram(CheckListModel):
	FieldName = 'TYPE_OF_PROGRAM'
	FieldCode = 'top'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'TOP_ID'
	Table = 'CCR_TypeOfProgram'
	ShowNotice1 = _normal_notice_1

	SearchLink = ('~/results.asp', dict(incDel='on', TOPID='IDIDID'))

	UsageSQL = '''	SELECT [top].TOP_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CCR_TypeOfProgram [top]
					LEFT JOIN CCR_BaseTable cbt
						ON cbt.TYPE_OF_PROGRAM=[top].TOP_ID
					LEFT JOIN GBL_BaseTable bt
						ON cbt.NUM=bt.NUM
					GROUP BY [top].TOP_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CCR_BaseTable WHERE TYPE_OF_PROGRAM=chk.TOP_ID)'


class ChkTraining(CheckListModel):
	FieldName = 'TRAINING'
	FieldCode = 'trn'
	FieldNameSrc = 'vol'

	Domain = const.DMT_VOL

	ID = 'TRN_ID'
	ShowNotice1 = _normal_notice_1

	SearchLink = ('~/volunteer/results.asp', dict(incDel='on', DisplayStatus='A', TRNID='IDIDID'))
	SearchLinkTitle = _('Volunteer:')

	UsageSQL = '''	SELECT trn.TRN_ID,
						COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM VOL_Training trn
					LEFT JOIN VOL_OP_TRN pr
						ON pr.TRN_ID=trn.TRN_ID
					INNER JOIN VOL_Opportunity vo
						ON pr.VNUM=vo.VNUM
					GROUP BY trn.TRN_ID
						'''
	CanDeleteCondition = '''NOT EXISTS(SELECT * FROM VOL_OP_TRN WHERE TRN_ID=chk.TRN_ID)'''


class ChkTransportation(CheckListModel):
	FieldName = 'TRANSPORTATION'
	FieldCode = 'trp'
	FieldNameSrc = 'vol'

	Domain = const.DMT_VOL

	ID = 'TRP_ID'
	ShowNotice1 = _normal_notice_1

	SearchLink = ('~/volunteer/results.asp', dict(incDel='on', DisplayStatus='A', TRPID='IDIDID'))
	SearchLinkTitle = _('Volunteer:')

	UsageSQL = '''	SELECT cl.TRP_ID,
						COUNT(CASE WHEN vo.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN vo.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM VOL_Transportation cl
					LEFT JOIN VOL_OP_TRP pr
						ON pr.TRP_ID=cl.TRP_ID
					INNER JOIN VOL_Opportunity vo
						ON pr.VNUM=vo.VNUM
					GROUP BY cl.TRP_ID
						'''
	CanDeleteCondition = '''NOT EXISTS(SELECT * FROM VOL_OP_TRP WHERE TRP_ID=chk.TRP_ID)'''


class ChkVacancyServiceTitle(CheckListModel):
	FieldName = 'Vacancy_ServiceTitle'
	FieldCode = 'vst'

	CheckListName = _('Vacancy Info Service Title')
	PageTitleTemplate = _('Edit %(type)s Vacancy Info Service Titles')
	ManagePageTitleTemplate = _('Manage Vacancy Info Service Titles')
	Domain = const.DMT_CIC
	SearchParameter = None

	ID = 'VST_ID'
	CodeTitle = None


class ChkVacancyTargetPop(CheckListModel):
	FieldName = 'Vacancy_TargetPop'
	FieldCode = 'vtp'

	CheckListName = _('Vacancy Into Target Population')
	PageTitleTemplate = _('Edit %(type)s Vacancy Into Target Populations')
	ManagePageTitleTemplate = _('Manage Vacancy Into Target Populations')
	Domain = const.DMT_CIC

	ID = 'VTP_ID'
	SearchLink = ('~/results.asp', dict(incDel='on', VacancyTP='IDIDID'))
	SearchParameter = 'VacancyTP'

	UsageSQL = '''	SELECT ast.VTP_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CIC_Vacancy_TargetPop ast
					LEFT JOIN (SELECT DISTINCT NUM, VTP_ID FROM CIC_BT_VUT vut INNER JOIN CIC_BT_VUT_TP vtp ON vut.BT_VUT_ID=vtp.BT_VUT_ID) cbt
						ON cbt.VTP_ID=ast.VTP_ID
					LEFT JOIN GBL_BaseTable bt
						ON cbt.NUM=bt.NUM
					GROUP BY ast.VTP_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BT_VUT vut INNER JOIN CIC_BT_VUT_TP vtp ON vut.BT_VUT_ID=vut.BT_VUT_ID  WHERE vtp.VTP_ID=chk.VTP_ID)'


class ChkVacancyUnitType(CheckListModel):
	FieldName = 'Vacancy_UnitType'
	FieldCode = 'vut'

	CheckListName = _('Vacancy Info Unit Type')
	PageTitleTemplate = _('Edit %(type)s Vacancy Info Unit Types')
	ManagePageTitleTemplate = _('Manage Vacancy Info Unit Types')
	Domain = const.DMT_CIC

	ID = 'VUT_ID'
	SearchLink = ('~/results.asp', dict(incDel='on', Limit='EXISTS(SELECT * FROM CIC_BT_VUT WHERE bt.NUM=NUM AND VUT_ID=IDIDID)'))
	SearchParameter = None

	UsageSQL = '''	SELECT ast.VUT_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CIC_Vacancy_UnitType ast
					LEFT JOIN (SELECT DISTINCT NUM, VUT_ID FROM CIC_BT_VUT) cbt
						ON cbt.VUT_ID=ast.VUT_ID
					LEFT JOIN GBL_BaseTable bt
						ON cbt.NUM=bt.NUM
					GROUP BY ast.VUT_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BT_VUT WHERE VUT_ID=chk.VUT_ID)'


class ChkWard(WithMunicipalityBase):
	FieldName = 'WARD'
	FieldCode = 'wd'
	FieldNameSrc = 'gbl'

	Domain = const.DMT_CIC

	ID = 'WD_ID'

	CodeField = 'WardNumber'
	CodeTitle = _('Number')
	CodeValidator = validators.Int(min=0, max=ciocvalidators.MAX_SMALL_INT, not_empty=True)
	OtherSqlValidators = _unique_code_validator % {'CodeField': 'WardNumber', 'ExtraCondition': ' AND ((nt.Municipality IS NULL AND ep.Municipality IS NULL) OR nt.Municipality=ep.Municipality)'}

	HighlightMissingLang = False

	DisplayOrder = False

	SearchLink = ('~/results.asp', dict(incDel='on', WDID='IDIDID'))

	UsageSQL = '''	SELECT br.WD_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM CIC_Ward br
					LEFT JOIN CIC_BaseTable cbt
						ON cbt.WARD=br.WD_ID
					LEFT JOIN GBL_BaseTable bt
						ON cbt.NUM=bt.NUM
					GROUP BY br.WD_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BaseTable WHERE WARD=chk.WD_ID)'


class ChkLanguageDetail(CheckListModel):
	FieldName = "Language_Details"
	FieldCode = 'lnd'

	CheckListName = _('Language Details')
	PageTitleTemplate = _('Edit %(type)s Language Details')
	ManagePageTitleTemplate = _('Manage Language Details')
	SearchLink = ('~/results.asp', dict(incDel='on', Limit='EXISTS(SELECT * FROM CIC_BT_LN ln INNER JOIN CIC_BT_LND lnd ON ln.LN_ID=lnd.LN_ID WHERE bt.NUM=NUM AND LND_ID=IDIDID)'))
	SearchParameter = None

	Domain = const.DMT_GBL
	ID = "LND_ID"

	ExtraNameFields = [
		{'type': 'textarea', 'title': _('Help Text (%s)'), 'field': 'HelpText', 'kwargs': {'maxlength': 4000, 'cols': 50, 'default_rows': const.TEXTAREA_ROWS_SHORT}, 'validator': ciocvalidators.UnicodeString(max=4000), 'sqltype': 'nvarchar(4000)', 'null': 'NULL', 'extra_compare': 'COLLATE Latin1_General_100_CS_AS'},
	]

	SearchLink = ('~/results.asp', dict(incDel='on', Limit='EXISTS(SELECT * FROM CIC_BT_LN_LND lnd INNER JOIN CIC_BT_LN ln ON ln.BT_LN_ID=lnd.BT_LN_ID WHERE bt.NUM=ln.NUM AND LND_ID=IDIDID)'))
	UsageSQL = '''	SELECT ast.LND_ID,
						COUNT(CASE WHEN bt.MemberID=@MemberID THEN 1 ELSE NULL END) AS Usage1Local,
						COUNT(CASE WHEN bt.MemberID<>@MemberID THEN 1 ELSE NULL END) AS Usage1Other,
						NULL AS Usage2Local,
						NULL AS Usage2Other
					FROM GBL_Language_Details ast
					LEFT JOIN (SELECT DISTINCT NUM, LND_ID FROM CIC_BT_LN ln INNER JOIN CIC_BT_LN_LND lnd ON ln.BT_LN_ID=lnd.BT_LN_ID) cbt
						ON cbt.LND_ID=ast.LND_ID
					LEFT JOIN GBL_BaseTable bt
						ON cbt.NUM=bt.NUM
					GROUP BY ast.LND_ID
						'''
	CanDeleteCondition = 'NOT EXISTS(SELECT * FROM CIC_BT_LN_LND WHERE LND_ID=chk.LND_ID)'

checklists = dict((x.FieldCode, x) for k, x in six.iteritems(globals()) if k.startswith('Chk') and not x.skip)
