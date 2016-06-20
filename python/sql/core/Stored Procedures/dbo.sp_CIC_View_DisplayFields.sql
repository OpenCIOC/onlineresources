
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_DisplayFields]
	@NUM varchar(8),
	@ViewType int,
	@WebEnable bit,
	@LoggedIn bit,
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 17-Jul-2015
	Action: NO ACTION REQUIRED
*/

DECLARE @MemberID int,
		@RecordMemberID int,
		@ProfileID int,
		@RespectPrivacyProfile bit,
		@IsCCR bit

SET @IsCCR = CASE WHEN EXISTS(SELECT * FROM CCR_BaseTable ccbt WHERE ccbt.NUM=@NUM) THEN 1 ELSE 0 END

SELECT	@MemberID=MemberID,
		@RespectPrivacyProfile=RespectPrivacyProfile
	FROM CIC_View
WHERE ViewType=@ViewType

IF @LoggedIn=0 BEGIN
	SET @RespectPrivacyProfile = 1
END ELSE IF @RespectPrivacyProfile=0
		AND EXISTS(SELECT * FROM GBL_SharingProfile WHERE ShareMemberID=@MemberID AND CanViewPrivate=0) BEGIN
	SET @RespectPrivacyProfile = NULL
END

SELECT @RecordMemberID = MemberID FROM GBL_BaseTable WHERE NUM=@NUM
IF @RecordMemberID <> @MemberID BEGIN
	SELECT @ProfileID = shp.ProfileID 
	FROM GBL_SharingProfile shp 
	INNER JOIN GBL_BT_SharingProfile shpr 
		ON shpr.ProfileID=shp.ProfileID AND shpr.NUM=@NUM
			AND shpr.ShareMemberID_Cache=@MemberID
	WHERE (shp.CanUseAnyView=1 OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View shpv WHERE shpv.ProfileID=shp.ProfileID AND shpv.ViewType=@ViewType))
END

SELECT	fg.DisplayFieldGroupID,
		fgn.Name AS DisplayFieldGroupName,
		fo.FieldName,
		fo.CheckMultiline,
		fo.CheckHTML,
		CASE
			WHEN (@WebEnable=1 OR FieldName='LOGO_ADDRESS')
				THEN dbo.fn_GBL_FieldOption_Display_Web(
					@MemberID,
					@ViewType,
					fo.FieldID,
					fo.FieldName,
					@RespectPrivacyProfile,
					fo.PrivacyProfileIDList,
					0,
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
					@ViewType,
					fo.FieldID,
					fo.FieldName,
					@RespectPrivacyProfile,
					fo.PrivacyProfileIDList,
					0,
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
		ISNULL(fod.FieldDisplay,fo.FieldName) AS FieldDisplay
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN CIC_View_DisplayField fd
		ON fo.FieldID=fd.FieldID
	INNER JOIN CIC_View_DisplayFieldGroup fg
		ON fd.DisplayFieldGroupID=fg.DisplayFieldGroupID
	INNER JOIN CIC_View_DisplayFieldGroup_Name fgn
		ON fg.DisplayFieldGroupID=fgn.DisplayFieldGroupID
			AND fgn.LangID=(SELECT TOP 1 LangID FROM CIC_View_DisplayFieldGroup_Name WHERE DisplayFieldGroupID=fgn.DisplayFieldGroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE (CanUseDisplay = 1)
	AND (fg.ViewType = @ViewType)
	AND (@IsCCR = 1 OR fo.FieldType <> 'CCR')
	AND (
			@RecordMemberID=@MemberID
			OR CanShare=0
			OR (@ProfileID IS NOT NULL AND 
				EXISTS(SELECT * FROM GBL_SharingProfile_CIC_Fld shpf WHERE shpf.ProfileID=@ProfileID AND shpf.FieldID=fo.FieldID)
			)
		)
ORDER BY fg.DisplayOrder, fgn.Name, fo.DisplayOrder, ISNULL(fod.FieldDisplay,fo.FieldName)

SET NOCOUNT OFF






GO


GRANT EXECUTE ON  [dbo].[sp_CIC_View_DisplayFields] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_View_DisplayFields] TO [cioc_login_role]
GO
