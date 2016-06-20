SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_View_DisplayFields]
	@ViewType int,
	@WebEnable int,
	@VNUM varchar(10),
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE @ProfileID	int

SELECT @ProfileID = PRIVACY_PROFILE
	FROM GBL_BaseTable bt
	INNER JOIN VOL_Opportunity vo
		ON bt.NUM=vo.NUM
WHERE vo.VNUM=@VNUM

DECLARE @MemberID int
SELECT @MemberID=MemberID FROM VOL_View WHERE ViewType=@ViewType

SELECT 
		fo.FieldName,
		CAST(0 AS bit) AS IS_VOL,
		fo.DisplayOrder,
		fo.CheckMultiline,
		fo.CheckHTML,
		CASE
			WHEN (@WebEnable=1 OR FieldName='LOGO_ADDRESS')
				THEN dbo.fn_GBL_FieldOption_Display_Web(
					@MemberID,
					NULL,
					fo.FieldID,
					fo.FieldName,
					1,
					fo.PrivacyProfileIDList,
					CASE WHEN NOT EXISTS(SELECT * FROM GBL_BT_SharingProfile WHERE ShareMemberID_Cache=@MemberID) THEN 0 ELSE fo.CanShare END,
					fo.DisplayFM,
					fo.DisplayFMWeb,
					fo.FieldType,
					fo.FormFieldType,
					fo.EquivalentSource,
					fod.CheckboxOnText,
					fod.CheckboxOffText,
					1,
					@HTTPVals,
					@PathToStart
				)
			ELSE dbo.fn_GBL_FieldOption_Display(
					@MemberID,
					NULL,
					fo.FieldID,
					fo.FieldName,
					1,
					fo.PrivacyProfileIDList,
					CASE WHEN NOT EXISTS(SELECT * FROM GBL_BT_SharingProfile WHERE ShareMemberID_Cache=@MemberID) THEN 0 ELSE fo.CanShare END,
					fo.DisplayFM,
					fo.DisplayFMWeb,
					fo.FieldType,
					fo.FormFieldType,
					fo.EquivalentSource,
					fod.CheckboxOnText,
					fod.CheckboxOffText,
					1
				)
		END AS FieldSelect,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
WHERE fo.FieldType='GBL'
	AND fo.FieldName IN ('NUM',
		'ORG_NAME_FULL',
		'OFFICE_PHONE','TOLL_FREE_PHONE','FAX',
		'SITE_ADDRESS_MAPPED','MAIL_ADDRESS',
		'E_MAIL','WWW_ADDRESS_NW')
	AND (@ProfileID IS NULL OR fo.PrivacyProfileIDList IS NULL)

UNION SELECT
		fo.FieldName,
		CAST(1 AS bit) AS IS_VOL,
		fo.DisplayOrder,
		fo.CheckMultiline,
		fo.CheckHTML,
		CASE
			WHEN (@WebEnable=1)
				THEN dbo.fn_VOL_FieldOption_Display_Web(
					@MemberID,
					@ViewType,
					fo.FieldID,
					fo.FieldName,
					0,
					fo.DisplayFM,
					fo.DisplayFMWeb,
					fo.FormFieldType,
					fo.EquivalentSource,
					fod.CheckboxOnText,
					fod.CheckboxOffText,
					1,
					@HTTPVals,
					@PathToStart

				)
			ELSE dbo.fn_VOL_FieldOption_Display(
					@MemberID,
					@ViewType,
					fo.FieldID,
					fo.FieldName,
					0,
					fo.DisplayFM,
					fo.FormFieldType,
					fo.EquivalentSource,
					fod.CheckboxOnText,
					fod.CheckboxOffText,
					1
				)
		END AS FieldSelect,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay
	FROM VOL_FieldOption fo
	LEFT JOIN VOL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN VOL_View_DisplayField df
		ON fo.FieldID = df.FieldID
WHERE     (fo.CanUseDisplay = 1)
	AND (df.ViewType = @ViewType)
	AND (
		(SELECT MemberID FROM VOL_Opportunity WHERE VNUM=@VNUM)=@MemberID
		OR CanShare=0
		OR EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE ShareMemberID=@MemberID AND shp.Active=1
			AND (shp.CanUseAnyView=1 OR EXISTS(SELECT * FROM GBL_SharingProfile_VOL_View shpv WHERE shpv.ProfileID=shp.ProfileID AND shpv.ViewType=@ViewType))
			AND EXISTS(SELECT * FROM GBL_SharingProfile_CIC_Fld shpf WHERE shpf.ProfileID=shp.ProfileID AND shpf.FieldID=fo.FieldID)
			AND EXISTS(SELECT * FROM VOL_OP_SharingProfile shpr WHERE shpr.ProfileID=shp.ProfileID AND shpr.VNUM=@VNUM)
		)
	)
ORDER BY IS_VOL DESC, DisplayOrder

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_View_DisplayFields] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_View_DisplayFields] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_View_DisplayFields] TO [cioc_vol_search_role]
GO
