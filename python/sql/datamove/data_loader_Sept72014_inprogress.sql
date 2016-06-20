DECLARE @LoadCode varchar(10), @ObjectType varchar(50)
SET @LoadCode='ce032015'

/*
-- Member
-- VERIFIED JAN 17, 2015
SET @ObjectType='Member'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
		SELECT *,
			  (SELECT TOP 1 Name FROM dbo.GBL_Template_Description WHERE Template_ID=[DefaultTemplate] ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS DefaultTemplateName,
			  (SELECT TOP 1 Name FROM dbo.GBL_Template_Description WHERE Template_ID=[DefaultPrintTemplate] ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS DefaultPrintTemplateName,
			  (SELECT TOP 1 ViewName FROM dbo.CIC_View_Description WHERE ViewType=[DefaultViewCIC] ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS DefaultViewCICName,
			  (SELECT TOP 1 ViewName FROM dbo.VOL_View_Description WHERE ViewType=[DefaultViewVOL] ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS DefaultViewVOLName,
			  (SELECT * FROM dbo.STP_Member_Description Lang WHERE Lang.MemberID=Member.MemberID FOR XML AUTO, ELEMENTS, TYPE) AS Descriptions
			  
		FROM [dbo].[STP_Member] Member
		FOR XML AUTO, ELEMENTS, TYPE
	)

SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- Member
*/


/*
-- Layout
-- VERIFIED JAN 17, 2015
SET @ObjectType='Layout'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
		SELECT (SELECT TOP 1 tld.LayoutName FROM dbo.GBL_Template_Layout_Description tld WHERE tld.LayoutID=Layout.LayoutID ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS LayoutName,
			*,
			(SELECT * FROM dbo.GBL_Template_Layout_Description Lang WHERE Lang.LayoutID=Layout.LayoutID FOR XML AUTO, ELEMENTS, TYPE) AS Descriptions
		FROM [dbo].[GBL_Template_Layout] Layout
		WHERE Layout.SystemLayout=0
		FOR XML AUTO, ELEMENTS, TYPE
	)

SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- Layout
*/


/*
-- Template
-- VERIFIED JAN 17, 2015
SET @ObjectType='Template'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
		SELECT (SELECT TOP 1 td.Name FROM dbo.GBL_Template_Description td WHERE td.Template_ID=Template.Template_ID ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS TemplateName,
			*,
			(SELECT * FROM dbo.GBL_Template_Description Lang WHERE Lang.Template_ID=Template.Template_ID FOR XML AUTO, ELEMENTS, TYPE) AS Descriptions,
			(SELECT * FROM dbo.GBL_Template_Menu MenuLang WHERE MenuLang.Template_ID=Template.Template_ID FOR XML AUTO, ELEMENTS, TYPE) AS MenuItems,
			(SELECT TOP 1 LayoutName FROM GBL_Template_Layout_Description WHERE LayoutID=Template.HeaderLayout ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS HeaderLayoutName,
			(SELECT TOP 1 LayoutName FROM GBL_Template_Layout_Description WHERE LayoutID=Template.FooterLayout ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS FooterLayoutName,
			(SELECT TOP 1 LayoutName FROM GBL_Template_Layout_Description WHERE LayoutID=Template.SearchLayoutCIC ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS SearchLayoutCICName,
			(SELECT TOP 1 LayoutName FROM GBL_Template_Layout_Description WHERE LayoutID=Template.SearchLayoutVOL ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS SearchLayoutVOLName
		FROM dbo.GBL_Template Template
		WHERE Template.SystemTemplate=0
		FOR XML AUTO, ELEMENTS, TYPE
	)

SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- Template
*/

/*
-- Publication
-- VERIFIED JAN 17, 2015
SET @ObjectType='Publication'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT *,
		(SELECT * FROM dbo.CIC_Publication_Name Lang WHERE Lang.PB_ID=Pub.PB_ID FOR XML AUTO, ELEMENTS, TYPE) Descriptions,
		(SELECT *,
			(SELECT * FROM dbo.CIC_GeneralHeading_Group_Name GrpLang WHERE GrpLang.GroupID=Grp.GroupID FOR XML AUTO, ELEMENTS, TYPE) Descriptions
			FROM dbo.CIC_GeneralHeading_Group Grp WHERE Grp.PB_ID=Pub.PB_ID FOR XML AUTO, ELEMENTS, TYPE) Groups,
		(SELECT *,
				(SELECT * FROM dbo.CIC_GeneralHeading_Name Lang WHERE Lang.GH_ID=Heading.GH_ID FOR XML AUTO, ELEMENTS, TYPE) AS Descriptions,
				(SELECT RelatedGH_ID FROM dbo.CIC_GeneralHeading_Related Rel WHERE GH_ID=Heading.GH_ID FOR XML PATH(''), ELEMENTS, TYPE) AS Related,
				(SELECT *,
					(SELECT Code FROM dbo.CIC_GeneralHeading_TAX_TM Term WHERE Term.GH_TAX_ID=Link.GH_TAX_ID FOR XML PATH(''), ELEMENTS, TYPE) AS Terms
				FROM dbo.CIC_GeneralHeading_TAX Link WHERE Link.GH_ID=Heading.GH_ID FOR XML AUTO, ELEMENTS, TYPE) AS Taxonomy
			FROM dbo.CIC_GeneralHeading Heading
			WHERE Heading.PB_ID=Pub.PB_ID FOR XML AUTO, ELEMENTS, TYPE) Headings
	FROM dbo.CIC_Publication Pub
	FOR XML AUTO, ELEMENTS, TYPE
	)
SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- Publication
*/


/*
-- Distribution
-- VERIFIED JAN 17, 2015
SET @ObjectType='Distribution'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

IF EXISTS(SELECT * FROM dbo.CIC_Distribution) BEGIN

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT *,
		(SELECT * FROM CIC_Distribution_Name Lang WHERE [Distribution].DST_ID=DST_ID FOR XML AUTO, ELEMENTS, TYPE) Names
	FROM dbo.CIC_Distribution [Distribution]
	FOR XML AUTO, ELEMENTS, TYPE
	)

END

SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- Distribution
*/

/*
-- CIC View
-- VERIFIED JAN 17, 2015
-- DOES NOT DEAL WITH RECORD TYPE VERSIONS OF FORMS
SET @ObjectType='CIC View'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT *,
		(SELECT *,
			(SELECT TOP 1 inc.PolicyTitle FROM dbo.GBL_InclusionPolicy inc WHERE inc.InclusionPolicyID=Lang.InclusionPolicy ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS InclusionPolicyName,
			(SELECT TOP 1 tip.PageTitle FROM dbo.GBL_SearchTips tip WHERE tip.SearchTipsID=Lang.SearchTips ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS SearchTipsName
			FROM dbo.CIC_View_Description Lang
			WHERE Lang.ViewType=[View].ViewType FOR XML AUTO, ELEMENTS, TYPE) Descriptions,
		(SELECT PubCode FROM dbo.CIC_View_AutoAddPub apb INNER JOIN CIC_Publication pb ON pb.PB_ID=apb.PB_ID WHERE apb.ViewType=[View].ViewType FOR XML PATH(''), ELEMENTS, TYPE) AS AutoAddPub,
		(SELECT FieldName FROM dbo.CIC_View_ChkField fld INNER JOIN dbo.GBL_FieldOption ChkField ON fld.FieldID=ChkField.FieldID WHERE fld.ViewType=[View].ViewType FOR XML PATH(''), ELEMENTS, TYPE) AS ChkField,
		(SELECT DisplayOrder, 
			(SELECT CM_GUID, ProvinceState, cmn.Name 
			FROM GBL_Community cm 
			INNER JOIN GBL_Community_Name cmn 
				ON cm.CM_ID = cmn.CM_ID AND LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID)
			WHERE cm.CM_ID=Community.CM_ID FOR XML PATH(''), ELEMENTS, TYPE) AS [node()]
		 FROM CIC_View_Community Community WHERE ViewType=[View].ViewType FOR XML PATH('Community'), ELEMENTS, TYPE) AS Communities,
		(SELECT *,
			(SELECT PubCode FROM dbo.CIC_Publication pb WHERE pb.PB_ID=TopicSearch.PB_ID1) AS PubCode1,
			(SELECT PubCode FROM dbo.CIC_Publication pb WHERE pb.PB_ID=TopicSearch.PB_ID2) AS PubCode2,
			(SELECT * FROM dbo.CIC_View_TopicSearch_Description Lang WHERE Lang.TopicSearchID=TopicSearch.TopicSearchID FOR XML AUTO, ELEMENTS, TYPE) Descriptions
			 FROM dbo.CIC_View_TopicSearch TopicSearch
			 FOR XML AUTO, ELEMENTS, TYPE
		),
		(SELECT DisplayFieldGroupID, DisplayOrder,
			(SELECT Name, LangID FROM dbo.CIC_View_DisplayFieldGroup_Name Lang WHERE DisplayFieldGroupID=FieldGroup.DisplayFieldGroupID FOR XML AUTO, ELEMENTS, TYPE) AS Descriptions,
			(SELECT FieldName FROM dbo.CIC_View_DisplayField fld INNER JOIN dbo.GBL_FieldOption fo ON fld.FieldID=fo.FieldID WHERE fld.DisplayFieldGroupID=FieldGroup.DisplayFieldGroupID FOR XML PATH(''), ELEMENTS, TYPE) AS DisplayField,
			(SELECT FieldName FROM dbo.CIC_View_FeedbackField fld INNER JOIN dbo.GBL_FieldOption fo ON fld.FieldID=fo.FieldID WHERE fld.DisplayFieldGroupID=FieldGroup.DisplayFieldGroupID FOR XML PATH(''), ELEMENTS, TYPE) AS FeedbackField,
			(SELECT FieldName FROM dbo.CIC_View_UpdateField fld INNER JOIN dbo.GBL_FieldOption fo ON fld.FieldID=fo.FieldID WHERE fld.DisplayFieldGroupID=FieldGroup.DisplayFieldGroupID FOR XML PATH(''), ELEMENTS, TYPE) AS UpdateField,
			(SELECT FieldName FROM dbo.CIC_View_MailFormField fld INNER JOIN dbo.GBL_FieldOption fo ON fld.FieldID=fo.FieldID WHERE fld.DisplayFieldGroupID=FieldGroup.DisplayFieldGroupID FOR XML PATH(''), ELEMENTS, TYPE) AS MailFormField
			FROM dbo.CIC_View_DisplayFieldGroup FieldGroup WHERE FieldGroup.ViewType=[View].ViewType FOR XML AUTO, ELEMENTS, TYPE) AS DisplayFieldGroup,
		(SELECT PubCode FROM dbo.CIC_View_QuickListPub qpb INNER JOIN CIC_Publication pb ON pb.PB_ID=qpb.PB_ID WHERE qpb.ViewType=[View].ViewType FOR XML PATH(''), ELEMENTS, TYPE) AS QuickListPub,
		(SELECT (SELECT TOP 1 ViewName FROM dbo.CIC_View_Description vwd WHERE vwd.ViewType=vwr.CanSee ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS CanSeeView FROM CIC_View_Recurse vwr WHERE ViewType=[View].ViewType FOR XML PATH(''), ELEMENTS, TYPE) AS Recurse,
		(SELECT TOP 1 Name FROM dbo.GBL_Template_Description WHERE Template_ID=[Template] ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS TemplateName,
		(SELECT TOP 1 Name FROM dbo.GBL_Template_Description WHERE Template_ID=[PrintTemplate] ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS PrintTemplateName,
		(SELECT PubCode FROM dbo.CIC_Publication WHERE PB_ID=[View].PB_ID) AS PubCode
	FROM dbo.CIC_View [View]
	FOR XML AUTO, ELEMENTS, TYPE
	)

SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- CIC View
*/


/*
-- VOL View
-- VERIFIED JAN 17, 2015
SET @ObjectType='VOL View'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

IF EXISTS(SELECT * FROM dbo.VOL_View) BEGIN

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT *,
		(SELECT *,
			(SELECT TOP 1 inc.PolicyTitle FROM dbo.GBL_InclusionPolicy inc WHERE inc.InclusionPolicyID=Lang.InclusionPolicy ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS InclusionPolicyName,
			(SELECT TOP 1 tip.PageTitle FROM dbo.GBL_SearchTips tip WHERE tip.SearchTipsID=Lang.SearchTips ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS SearchTipsName
			FROM dbo.VOL_View_Description Lang
			WHERE Lang.ViewType=[View].ViewType FOR XML AUTO, ELEMENTS, TYPE) Descriptions,
		(SELECT FieldName FROM dbo.VOL_View_ChkField fld INNER JOIN dbo.VOL_FieldOption ChkField ON fld.FieldID=ChkField.FieldID WHERE fld.ViewType=[View].ViewType FOR XML PATH(''), ELEMENTS, TYPE) AS ChkField,
		(SELECT FieldName FROM dbo.VOL_View_DisplayField fld INNER JOIN dbo.VOL_FieldOption fo ON fld.FieldID=fo.FieldID WHERE fld.ViewType=[View].ViewType FOR XML PATH(''), ELEMENTS, TYPE) AS DisplayField,
		(SELECT FieldName FROM dbo.VOL_View_FeedbackField fld INNER JOIN dbo.VOL_FieldOption fo ON fld.FieldID=fo.FieldID WHERE fld.ViewType=[View].ViewType FOR XML PATH(''), ELEMENTS, TYPE) AS FeedbackField,
		(SELECT FieldName FROM dbo.VOL_View_UpdateField fld INNER JOIN dbo.VOL_FieldOption fo ON fld.FieldID=fo.FieldID WHERE fld.ViewType=[View].ViewType FOR XML PATH(''), ELEMENTS, TYPE) AS UpdateField,
		(SELECT (SELECT TOP 1 ViewName FROM dbo.VOL_View_Description vwd WHERE vwd.ViewType=vwr.CanSee ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS CanSeeView FROM VOL_View_Recurse vwr WHERE ViewType=[View].ViewType FOR XML PATH(''), ELEMENTS, TYPE) AS Recurse,
		(SELECT TOP 1 Name FROM dbo.GBL_Template_Description WHERE Template_ID=[Template] ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS TemplateName,
		(SELECT TOP 1 Name FROM dbo.GBL_Template_Description WHERE Template_ID=[PrintTemplate] ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS PrintTemplateName,
		(SELECT TOP 1 SetName FROM dbo.VOL_CommunitySet_Name WHERE CommunitySetID=[View].CommunitySetID ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS SetName
	FROM dbo.VOL_View [View]
	FOR XML AUTO, ELEMENTS, TYPE
	)
END
SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- VOL View
*/

/*
-- CIC User Type
-- VERIFIED JAN 17, 2015
SET @ObjectType='CIC User Type'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT *,
		(SELECT * FROM CIC_SecurityLevel_Name Lang WHERE UserType.SL_ID=SL_ID FOR XML AUTO, ELEMENTS, TYPE) Descriptions,
		(SELECT AgencyCode FROM CIC_SecurityLevel_EditAgency Agency WHERE UserType.SL_ID=SL_ID FOR XML PATH(''), ELEMENTS, TYPE) EditAgencies,
		(SELECT (SELECT TOP 1 ViewName FROM CIC_View_Description WHERE ViewType=EditView.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS [View] FROM CIC_SecurityLevel_EditView EditView WHERE UserType.SL_ID=SL_ID FOR XML PATH(''), ELEMENTS, TYPE) AS EditViews,
		(SELECT (SELECT TOP 1 Name FROM GBL_ExternalAPI_Description WHERE API_ID=API.API_ID ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS [API] FROM CIC_SecurityLevel_ExternalAPI API WHERE UserType.SL_ID=SL_ID FOR XML PATH(''), ELEMENTS, TYPE) AS ExternalAPIs,
		(SELECT (SELECT MachineName FROM CIC_Offline_Machines WHERE MachineID=Machine.MachineID) AS Machine FROM CIC_SecurityLevel_Machine Machine WHERE UserType.SL_ID=SL_ID FOR XML PATH(''), ELEMENTS, TYPE) AS Machines,
		(SELECT (SELECT TOP 1 Name FROM CIC_RecordType_Name WHERE RT_ID=RecordType.RT_ID ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS RecordType FROM CIC_SecurityLevel_RecordType RecordType WHERE UserType.SL_ID=SL_ID FOR XML PATH(''), ELEMENTS, TYPE) AS RecordTypes,
		(SELECT TOP 1 ViewName FROM CIC_View_Description WHERE ViewType=UserType.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS ViewTypeName,
		(SELECT TOP 1 ViewName FROM CIC_View_Description WHERE ViewType=UserType.ViewTypeOffline ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS ViewTypeOfflineName
	FROM dbo.CIC_SecurityLevel [UserType]
	FOR XML AUTO, ELEMENTS, TYPE
	)
SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- CIC User Type
*/

/*
-- VOL User Type
-- VERIFIED JAN 17, 2015
SET @ObjectType='VOL User Type'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

IF EXISTS(SELECT * FROM dbo.VOL_SecurityLevel) BEGIN

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT *,
		(SELECT * FROM VOL_SecurityLevel_Name Lang WHERE UserType.SL_ID=SL_ID FOR XML AUTO, ELEMENTS, TYPE) Descriptions,
		(SELECT AgencyCode FROM VOL_SecurityLevel_EditAgency Agency WHERE UserType.SL_ID=SL_ID FOR XML PATH(''), ELEMENTS, TYPE) EditAgencies,
		(SELECT (SELECT TOP 1 ViewName FROM VOL_View_Description WHERE ViewType=EditView.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS [View] FROM VOL_SecurityLevel_EditView EditView WHERE UserType.SL_ID=SL_ID FOR XML PATH(''), ELEMENTS, TYPE) AS EditViews,
		(SELECT (SELECT TOP 1 Name FROM GBL_ExternalAPI_Description WHERE API_ID=API.API_ID ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS [API] FROM VOL_SecurityLevel_ExternalAPI API WHERE UserType.SL_ID=SL_ID FOR XML PATH(''), ELEMENTS, TYPE) AS ExternalAPIs,
		(SELECT TOP 1 ViewName FROM VOL_View_Description WHERE ViewType=UserType.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS ViewTypeName
	FROM dbo.VOL_SecurityLevel [UserType]
	FOR XML AUTO, ELEMENTS, TYPE
	)
END
SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- VOL User Type
*/


/*
-- User
-- VERIFIED JAN 17, 2015
SET @ObjectType='User'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT *,
		(SELECT TOP 1 SecurityLevel FROM dbo.CIC_SecurityLevel_Name WHERE SL_ID=SL_ID_CIC ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS SecurityLevelCIC,
		(SELECT TOP 1 SecurityLevel FROM dbo.VOL_SecurityLevel_Name WHERE SL_ID=SL_ID_VOL ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS SecurityLevelVOL,
		(SELECT * FROM GBL_Users_History Change WHERE [User].User_ID=User_ID FOR XML AUTO, ELEMENTS, TYPE) History
	FROM dbo.GBL_Users [User]
	WHERE Inactive=0
	FOR XML AUTO, ELEMENTS, TYPE
	)
SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- User
*/


/*
-- Export Profile
-- VERIFIED JAN 17, 2015
SET @ObjectType='Export Profile'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT *,
		(SELECT LangID, Name, SourceDbName, SourceDbURL FROM CIC_ExportProfile_Description Lang WHERE [ExportProfile].ProfileID=ProfileID FOR XML AUTO, ELEMENTS, TYPE) Descriptions,
		(SELECT (SELECT DistCode FROM CIC_Distribution WHERE DST_ID=Distribution.DST_ID) AS DistCode FROM CIC_ExportProfile_Dist Distribution WHERE ProfileID=ExportProfile.ProfileID FOR XML PATH(''), ELEMENTS, TYPE) Distributions,
		(SELECT (SELECT FieldName FROM GBL_FieldOption WHERE FieldID=Field.FieldID) AS Field FROM CIC_ExportProfile_Fld Field WHERE ProfileID=ExportProfile.ProfileID FOR XML PATH(''), ELEMENTS, TYPE) Fields,
		(SELECT (SELECT PubCode FROM CIC_Publication WHERE PB_ID=Publication.PB_ID) AS PubCode, Publication.* FROM CIC_ExportProfile_Pub Publication WHERE ProfileID=ExportProfile.ProfileID FOR XML AUTO, ELEMENTS, TYPE) Publications,
		(SELECT (SELECT TOP 1 ViewName FROM CIC_View_Description WHERE ViewType=[Views].ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS ViewName
			FROM dbo.CIC_View_ExportProfile [Views]
			WHERE [Views].ProfileID=[ExportProfile].ProfileID FOR XML PATH(''), ELEMENTS, TYPE) AS [Views]
	FROM dbo.CIC_ExportProfile [ExportProfile]
	FOR XML AUTO, ELEMENTS, TYPE
	)

SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- Export Profile
*/


/*
-- Excel Profile
-- VERIFIED JAN 17, 2015
-- MISSING VOL, BUT THAT FEATURE IS NOT IMPLEMENTED
SET @ObjectType='Excel Profile'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT *,
		(SELECT LangID, Name FROM GBL_ExcelProfile_Name Lang WHERE [ExcelProfile].ProfileID=ProfileID FOR XML AUTO, ELEMENTS, TYPE) Descriptions,
		(SELECT (SELECT FieldName FROM GBL_FieldOption WHERE FieldID=Field.GBLFieldID) AS GBLField, (SELECT FieldName FROM GBL_FieldOption WHERE FieldID=Field.VOLFieldID) AS VOLField, DisplayOrder, SortByOrder FROM GBL_ExcelProfile_Fld Field WHERE ProfileID=ExcelProfile.ProfileID FOR XML PATH('Field'), ELEMENTS, TYPE) Fields,
		(SELECT (SELECT TOP 1 ViewName FROM CIC_View_Description WHERE ViewType=[Views].ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS ViewName
			FROM dbo.CIC_View_ExcelProfile [Views]
			WHERE [Views].ProfileID=[ExcelProfile].ProfileID FOR XML PATH(''), ELEMENTS, TYPE) AS [Views]
	FROM dbo.GBL_ExcelProfile [ExcelProfile]
	FOR XML AUTO, ELEMENTS, TYPE
	)
SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- Excel Profile
*/


/*
-- Print Profile
-- VERIFIED JAN 17, 2015
SET @ObjectType='Print Profile'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT *,
		(SELECT * FROM GBL_PrintProfile_Description Lang WHERE [PrintProfile].ProfileID=ProfileID FOR XML AUTO, ELEMENTS, TYPE) Descriptions,
		(SELECT *, 
			(SELECT FieldName FROM GBL_FieldOption WHERE FieldID=Field.GBLFieldID) AS GBLFieldName,
			(SELECT FieldName FROM VOL_FieldOption WHERE FieldID=Field.VOLFieldID) AS VOLFieldName,
			(SELECT * FROM GBL_PrintProfile_Fld_Description Lang WHERE PFLD_ID=Field.PFLD_ID FOR XML AUTO, ELEMENTS, TYPE) Descriptions,
			(SELECT *,
				(SELECT LangID FROM GBL_PrintProfile_Fld_FindReplace_Lang WHERE PFLD_RP_ID=FindReplace.PFLD_RP_ID FOR XML PATH(''), ELEMENTS, TYPE) AS Languages
			 FROM GBL_PrintProfile_Fld_FindReplace FindReplace WHERE PFLD_ID=Field.PFLD_ID FOR XML AUTO, ELEMENTS, TYPE) Replacements
		 FROM GBL_PrintProfile_Fld Field WHERE ProfileID=PrintProfile.ProfileID FOR XML AUTO, ELEMENTS, TYPE) Fields,
		 (SELECT (SELECT TOP 1 ViewName FROM CIC_View_Description WHERE ViewType=[Views].ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS ViewName
			FROM dbo.CIC_View_PrintProfile [Views]
			WHERE [Views].ProfileID=[PrintProfile].ProfileID FOR XML PATH(''), ELEMENTS, TYPE) AS [Views],
		 (SELECT (SELECT TOP 1 ViewName FROM VOL_View_Description WHERE ViewType=[Views].ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS ViewName
			FROM dbo.VOL_View_PrintProfile [Views]
			WHERE [Views].ProfileID=[PrintProfile].ProfileID FOR XML PATH(''), ELEMENTS, TYPE) AS [VOLViews]
	FROM dbo.GBL_PrintProfile [PrintProfile]
	FOR XML AUTO, ELEMENTS, TYPE
	)

SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- Print Profile
*/

/* 
-- Display Options
-- VERIFIED JAN 17, 2015
SET @ObjectType='Display'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT *,
		(SELECT TOP 1 ViewName FROM CIC_View_Description WHERE ViewType=Display.ViewTypeCIC ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS ViewTypeCICName,
		(SELECT TOP 1 ViewName FROM VOL_View_Description WHERE ViewType=Display.ViewTypeVOL ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS ViewTypeVOLName,
		(SELECT UserUID FROM GBL_Users WHERE User_ID=Display.User_ID) UserUID,
		(SELECT Field.FieldName FROM dbo.GBL_Display_Fld df INNER JOIN dbo.GBL_FieldOption Field ON Field.FieldID = df.FieldID
			WHERE df.DD_ID=Display.DD_ID FOR XML PATH(''), ELEMENTS, TYPE) AS GBLFields,
		(SELECT Field.FieldName FROM dbo.VOL_Display_Fld df INNER JOIN dbo.VOL_FieldOption Field ON Field.FieldID = df.FieldID
			WHERE df.DD_ID=Display.DD_ID FOR XML PATH(''), ELEMENTS, TYPE) AS VOLFields
	FROM dbo.GBL_Display Display
	WHERE (User_ID IS NULL OR EXISTS(SELECT * FROM GBL_Users u WHERE u.User_ID=Display.User_ID AND u.Inactive=0))
	FOR XML AUTO, ELEMENTS, TYPE
	)

SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- Display Options
*/

/*
-- Saved Search
-- VERIFIED JAN 17, 2015
SET @ObjectType='Saved Search'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
	 
INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT ss.*,
		u.UserUID,
		(SELECT sln.SecurityLevel FROM dbo.CIC_SecurityLevel_SavedSearch sls INNER JOIN dbo.CIC_SecurityLevel_Name sln ON sln.LangID=0 AND sln.SL_ID=sls.SL_ID WHERE sls.SSRCH_ID=ss.SSRCH_ID FOR XML PATH(''), ELEMENTS, TYPE) AS CICUserType,
		(SELECT sln.SecurityLevel FROM dbo.VOL_SecurityLevel_SavedSearch sls INNER JOIN dbo.VOL_SecurityLevel_Name sln ON sln.LangID=0 AND sln.SL_ID=sls.SL_ID WHERE sls.SSRCH_ID=ss.SSRCH_ID FOR XML PATH(''), ELEMENTS, TYPE) AS VOLUserType
	FROM dbo.GBL_SavedSearch ss
	INNER JOIN dbo.GBL_Users u ON u.User_ID = ss.User_ID AND u.Inactive=0
	FOR XML PATH('SavedSearch'), ROOT('Searches'), ELEMENTS, TYPE
)
-- Saved Search
*/

/*
-- Field Help
-- VERIFIED JAN 17, 2015
SET @ObjectType='Field Help'

DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT FieldName, LangID, HelpText
		FROM dbo.GBL_FieldOption fo
		INNER JOIN dbo.GBL_FieldOption_Description fod
			ON fod.FieldID = fo.FieldID
	WHERE HelpText IS NOT NULL
	FOR XML PATH('FieldHelp'), ROOT('Fields'), ELEMENTS, TYPE
	)
-- Field Help
*/

/*
-- VOL Help
-- VERIFIED JAN 29, 2015
SET @ObjectType='VOL Field Help'

DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT FieldName, LangID, HelpText
		FROM dbo.VOL_FieldOption fo
		INNER JOIN dbo.VOL_FieldOption_Description fod
			ON fod.FieldID = fo.FieldID
	WHERE HelpText IS NOT NULL
	FOR XML PATH('FieldHelp'), ROOT('Fields'), ELEMENTS, TYPE
	)
-- Field Help
*/

/*
-- Offline Tools
SET @ObjectType='Offline Tools'

DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

IF EXISTS(SELECT * FROM dbo.CIC_Offline_Machines) BEGIN

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT om.*,
			(SELECT sln.SecurityLevel FROM dbo.CIC_SecurityLevel_Name sln INNER JOIN dbo.CIC_SecurityLevel_Machine slm ON slm.SL_ID = sln.SL_ID WHERE slm.MachineID=om.MachineID FOR XML PATH(''), ROOT('UserTypes'), ELEMENTS, TYPE)
		FROM dbo.CIC_Offline_Machines om
	FOR XML PATH('Machine'), ROOT('Machines'), ELEMENTS, TYPE
	)

END
SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- Offline Tools
*/

/*
-- Email Update Text
-- VERIFIED JAN 17, 2015
SET @ObjectType='Email Update Text'

DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT *,
			(SELECT * FROM dbo.GBL_StandardEmailUpdate_Description Lang WHERE Lang.EmailID=eu.EmailID FOR XML AUTO, ELEMENTS, TYPE) AS Descriptions
		FROM dbo.GBL_StandardEmailUpdate eu
	WHERE eu.MemberID IS NOT NULL
	FOR XML PATH('UpdateText'), ROOT('EmailTexts'), ELEMENTS, TYPE
	)
-- Email Update Text
*/

/*
-- Inclusion Policy
-- VERIFIED JAN 17, 2015
SET @ObjectType='Inclusion Policy'

DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT *
		FROM dbo.GBL_InclusionPolicy Policy
	FOR XML AUTO, ROOT('ROOT'), ELEMENTS, TYPE
	)
-- Inclusion Policy
*/

/*
-- Reminders
-- NEEDS TESTING FOR USER Notes
-- VERIFIED JAN 17, 2015
SET @ObjectType='Reminder'

DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
		SELECT Reminder.*,
		(SELECT UserUID FROM dbo.GBL_Users u WHERE u.User_ID=Reminder.UserID) AS UserUID,
		(SELECT AgencyCode FROM dbo.GBL_Reminder_Agency ra INNER JOIN GBL_Agency a ON a.AgencyID = ra.AgencyID WHERE ra.ReminderID=Reminder.ReminderID FOR XML PATH(''), ELEMENTS, TYPE) Agencies,
		(SELECT (SELECT UserUID FROM dbo.GBL_Users u WHERE u.User_ID=ru.User_ID FOR XML PATH(''), ELEMENTS, TYPE)  FROM dbo.GBL_Reminder_User ru WHERE ru.ReminderID=Reminder.ReminderID AND NOT EXISTS(SELECT * FROM dbo.GBL_Reminder_User_Dismiss rdiss WHERE rdiss.User_ID=ru.User_ID AND rdiss.ReminderID=ru.ReminderID) FOR XML PATH(''), ELEMENTS, TYPE) AS Users
		,(SELECT run.*, u.UserUID FROM dbo.GBL_Reminder_User_Note run INNER JOIN GBL_Users u ON u.User_ID=run.User_ID AND u.Inactive=0 WHERE run.ReminderID=Reminder.ReminderID FOR XML AUTO, ELEMENTS, TYPE) AS Notes
		,(SELECT NUM FROM GBL_BT_Reminder r WHERE r.ReminderID=Reminder.ReminderID FOR XML PATH(''), ELEMENTS, TYPE) AS CICRecords
		,(SELECT VNUM FROM VOL_OP_Reminder r WHERE r.ReminderID=Reminder.ReminderID FOR XML PATH(''), ELEMENTS, TYPE) AS VOLRecords
		,(SELECT u.UserUID, rd.DismissalDate FROM dbo.GBL_Reminder_User_Dismiss rd INNER JOIN dbo.GBL_Users u ON u.User_ID=rd.User_ID WHERE u.Inactive=0 AND rd.ReminderID=Reminder.ReminderID FOR XML PATH('Dismiss'), ELEMENTS, TYPE) AS UserDismissed
	FROM GBL_Reminder Reminder
	WHERE Dismissed=0 
			--AND (Reminder.LangID IS NULL OR Reminder.LangID=@@LangID)
			--AND (Reminder.ActiveDate IS NULL OR Reminder.ActiveDate <= GETDATE())
			AND EXISTS(SELECT * FROM dbo.GBL_Users ux
				WHERE (
					(Reminder.UserID=ux.User_ID
						AND NOT EXISTS(SELECT * FROM GBL_Reminder_Agency ra WHERE ra.ReminderID=Reminder.ReminderID)
						AND NOT EXISTS(SELECT * FROM GBL_Reminder_User ru WHERE ru.ReminderID=Reminder.ReminderID)
					)
					OR EXISTS(SELECT *
						FROM GBL_Reminder_Agency ra 
						INNER JOIN GBL_Agency a
							ON ra.AgencyID=a.AgencyID
						INNER JOIN GBL_Users u
							ON u.Agency = a.AgencyCode
						WHERE ra.ReminderID=Reminder.ReminderID AND u.User_ID=ux.User_ID)
					OR EXISTS(SELECT *
						FROM GBL_Reminder_User ru
						WHERE ru.ReminderID=Reminder.ReminderID AND ru.User_ID=ux.User_ID)
					)
					AND NOT EXISTS(SELECT * FROM GBL_Reminder_User_Dismiss WHERE ReminderID=Reminder.ReminderID AND User_ID=ux.User_ID)
			)
	FOR XML AUTO, ROOT('Reminders'), ELEMENTS, TYPE
	)
SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
-- Reminders
*/
-- GBL Feedback
-- VERIFIED JAN 17, 2015
/*
SET @ObjectType='GBL Feedback'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
	 
INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT fe.*,
		u.UserUID,
		(SELECT TOP 1 ViewName FROM CIC_View_Description WHERE ViewType=fe.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS ViewTypeName,
		(SELECT * FROM GBL_Feedback WHERE FB_ID=fe.FB_ID FOR XML PATH('GBLFeedback'), ELEMENTS, TYPE) AS GBLs,
		(SELECT * FROM CIC_Feedback WHERE FB_ID=fe.FB_ID FOR XML PATH('CICFeedback'), ELEMENTS, TYPE) AS CICs,
		(SELECT * FROM CCR_Feedback WHERE FB_ID=fe.FB_ID FOR XML PATH('CCRFeedback'), ELEMENTS, TYPE) AS CCRs,
		(SELECT e.* FROM CIC_Feedback_Extra e INNER JOIN GBL_FieldOption fo ON e.FieldName=fo.FieldName WHERE FB_ID=fe.FB_ID FOR XML PATH('Extra'), ELEMENTS, TYPE) AS Extras,
		(SELECT pbf.*, pb.PUBCODE FROM CIC_Feedback_Publication pbf INNER JOIN CIC_BT_PB btpb ON btpb.BT_PB_ID = pbf.BT_PB_ID INNER JOIN CIC_Publication pb ON pb.PB_ID = btpb.PB_ID WHERE FB_ID=fe.FB_ID FOR XML PATH('Publication'), ELEMENTS, TYPE) AS Publications
	FROM dbo.GBL_FeedbackEntry fe
	LEFT JOIN dbo.GBL_Users u ON u.User_ID = fe.User_ID AND u.Inactive=0
	FOR XML PATH('FeedbackEntry'), ROOT('root'), ELEMENTS, TYPE
)
SELECT * FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
*/
-- GBL Feedback

/*
-- VOL Feedback
-- VERIFIED JAN 17, 2015
SET @ObjectType='VOL Feedback'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType
	 
INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT fe.*,
		u.UserUID,
		(SELECT TOP 1 ViewName FROM VOL_View_Description WHERE ViewType=fe.ViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) AS ViewTypeName
	FROM dbo.VOL_Feedback fe
	LEFT JOIN dbo.GBL_Users u ON u.User_ID = fe.User_ID AND u.Inactive=0
	FOR XML PATH('Feedback'), ROOT('root'), ELEMENTS, TYPE
)
-- VOL Feedback
*/

/*
-- Ward
-- VERIFIED JAN 17, 2015
SET @ObjectType='CIC Ward'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

IF EXISTS(SELECT * FROM dbo.CIC_Ward) BEGIN

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT wd.*,
		cm.CM_GUID,
		(SELECT * FROM CIC_Ward_Name WHERE WD_ID=wd.WD_ID FOR XML PATH('Name'), ELEMENTS, TYPE) AS Names
	FROM dbo.CIC_Ward wd
	LEFT JOIN dbo.GBL_Community cm ON cm.CM_ID = wd.Municipality
	WHERE Municipality IS NOT NULL
	FOR XML PATH('Ward'), ELEMENTS, TYPE
)

END
-- Ward
*/

/*
-- Community Set
-- VERIFIED JAN 17, 2015
SET @ObjectType='VOL Community Set'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT cs.*,
		(SELECT * FROM VOL_CommunitySet_Name WHERE CommunitySetID=cs.CommunitySetID FOR XML PATH('Name'), ELEMENTS, TYPE) AS Names,
		(SELECT *,
			(SELECT * FROM VOL_CommunityGroup_Name WHERE CommunityGroupID=cg.CommunityGroupID FOR XML PATH('Name'), ELEMENTS, TYPE) AS Names,
			(SELECT cgcm.*, c.CM_GUID FROM VOL_CommunityGroup_CM cgcm INNER JOIN GBL_Community c ON c.CM_ID = cgcm.CM_ID AND cgcm.CommunityGroupID=cg.CommunityGroupID FOR XML PATH('Community'), ELEMENTS, TYPE) AS Communities
		FROM VOL_CommunityGroup cg
		WHERE CommunitySetID=cs.CommunitySetID
		FOR XML PATH ('Group'), ELEMENTS, TYPE) AS Groups
	FROM dbo.VOL_CommunitySet cs
	FOR XML PATH('CommunitySet'), ROOT('CommunitySets'), ELEMENTS, TYPE
)

-- Community Set
*/

/*
-- Domain Map
-- VERIFIED JAN 18, 2015
SET @ObjectType='GBL View DomainMap'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT dm.*,
		(SELECT TOP 1 ViewName FROM CIC_View_Description WHERE ViewType=CICViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) CICViewName,
		(SELECT TOP 1 ViewName FROM VOL_View_Description WHERE ViewType=VOLViewType ORDER BY CASE WHEN LangID=0 THEN 0 ELSE 1 END, LangID) VOLViewName
	FROM dbo.GBL_View_DomainMap dm
	FOR XML PATH('Domain'), ROOT('Domains'), ELEMENTS, TYPE
)
-- Domain Map
*/

/*
-- VOL Commitment Length
-- VERIFIED JAN 18, 2015
SET @ObjectType='VOL Commitment Length'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT cl.*,
	  (SELECT * FROM dbo.VOL_CommitmentLength_Name Lang WHERE Lang.CL_ID=cl.CL_ID FOR XML AUTO, ELEMENTS, TYPE) AS Descriptions
	FROM dbo.VOL_CommitmentLength cl
	FOR XML PATH('CommitmentLength'), ROOT('CommitmentLengths'), ELEMENTS, TYPE
)
-- VOL Commitment Length
*/

/*
-- VOL Profile
-- VERIFIED JAN 18, 2015
SET @ObjectType='VOL Profile'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

IF EXISTS(SELECT * FROM VOL_Profile) BEGIN
INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT pr.*,
	(SELECT Name FROM VOL_Profile_AI pa INNER JOIN VOL_Interest_Name i ON i.AI_ID = pa.AI_ID AND LangID=0 WHERE pa.ProfileID=pr.ProfileID FOR XML PATH(''), ELEMENTS, TYPE) AS Interests,
	(SELECT CM_GUID FROM VOL_Profile_CM pa INNER JOIN GBL_Community i ON i.CM_ID = pa.CM_ID AND LangID=0 WHERE pa.ProfileID=pr.ProfileID FOR XML PATH(''), ELEMENTS, TYPE) AS Communities
	FROM dbo.VOL_Profile pr
	FOR XML PATH('VolProfile'), ROOT('VolProfiles'), ELEMENTS, TYPE
)
END
-- VOL Profile
*/


/*
-- VOL Referral
-- VERIFIED JAN 18, 2015
SET @ObjectType='VOL Referral'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT vr.*,
		(SELECT ViewName FROM VOL_View_Description vd WHERE vd.LangID=0 AND vd.ViewType=vr.ViewType) AS ViewName
	FROM dbo.VOL_OP_Referral vr
	FOR XML PATH('Referral'), ROOT('Referrals'), ELEMENTS, TYPE
)
-- VOL Referral
*/

/*
-- Page Message
-- VERIFIED JAN 18, 2015
SET @ObjectType='Page Message'
DELETE FROM cioc_data_loader.dbo.MultiObjectLoader WHERE LoadCode=@LoadCode AND ObjectType=@ObjectType

INSERT INTO cioc_data_loader.dbo.MultiObjectLoader (LoadCode, ObjectType, Data)
SELECT @LoadCode, @ObjectType,
	(
	SELECT pm.*,
		(SELECT pmpi.PageName FROM GBL_PageMsg_PageInfo pmpi WHERE pmpi.PageMsgID=pm.PageMsgID FOR XML PATH(''),TYPE ) AS PAGES
	FROM dbo.GBL_PageMsg pm
	FOR XML PATH('PageMessage'), ROOT('PageMessages'), ELEMENTS, TYPE
)
-- Page Message
*/
