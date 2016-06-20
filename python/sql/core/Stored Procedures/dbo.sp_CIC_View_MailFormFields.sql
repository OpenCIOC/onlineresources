SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_MailFormFields]
	@NUM [varchar](8),
	@ViewType [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-Apr-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE @MemberID int,
		@BTMemberID int,
		@RespectPrivacyProfile bit,
		@ProfileID	int,
		@IsCCR bit

SELECT @BTMemberID=MemberID, @ProfileID = PRIVACY_PROFILE
	FROM GBL_BaseTable bt
WHERE bt.NUM=@NUM

SELECT	@MemberID=MemberID,
		@RespectPrivacyProfile=RespectPrivacyProfile
	FROM CIC_View
WHERE ViewType=@ViewType

SET @RespectPrivacyProfile=CASE
		WHEN @ProfileID IS NULL THEN 0
		WHEN (@BTMemberID=@MemberID
				OR EXISTS(SELECT *
					FROM GBL_BT_SharingProfile shpr
					INNER JOIN GBL_SharingProfile shp
						ON shpr.ProfileID=shp.ProfileID
					WHERE NUM=@NUM
						AND ShareMemberID_Cache=@MemberID
						AND shp.CanViewPrivate=1)
				)
			AND @RespectPrivacyProfile=0 THEN 0
		ELSE 1
	END

SET @IsCCR = CASE WHEN EXISTS(SELECT * FROM CCR_BaseTable ccbt WHERE ccbt.NUM=@NUM) THEN 1 ELSE 0 END

SELECT	fg.DisplayFieldGroupID,
		fgn.Name AS DisplayFieldGroupName,
		fo.FieldName,
		fo.FormFieldType, 
		fo.CheckMultiLine,
		fo.UseDisplayForMailForm,
		dbo.fn_CIC_PubRelationID(@NUM, PB_ID) AS BT_PB_ID,
		CASE WHEN UseDisplayForMailForm = 1 THEN dbo.fn_GBL_FieldOption_Display(
					@MemberID,
					@ViewType,
					fo.FieldID,
					fo.FieldName,
					@RespectPrivacyProfile,
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
			ELSE CASE WHEN (
					(SELECT MemberID FROM GBL_BaseTable WHERE NUM=@NUM)=@MemberID
					OR CanShare=0
					OR EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE ShareMemberID=@MemberID AND shp.Active=1
						AND (shp.CanUseAnyView=1 OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View shpv WHERE shpv.ProfileID=shp.ProfileID AND shpv.ViewType=@ViewType))
						AND EXISTS(SELECT * FROM GBL_SharingProfile_CIC_Fld shpf WHERE shpf.ProfileID=shp.ProfileID AND shpf.FieldID=fo.FieldID)
						AND EXISTS(SELECT * FROM GBL_BT_SharingProfile shpr WHERE shpr.ProfileID=shp.ProfileID AND shpr.NUM=@NUM)
					)
				) THEN ISNULL(FeedbackFieldList,UpdateFieldList) ELSE NULL END
		END AS FieldSelect,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay,
		CAST(CASE WHEN (SELECT pp.FieldID FROM GBL_PrivacyProfile_Fld pp WHERE pp.ProfileID=@ProfileID AND pp.FieldID=fo.FieldID) IS NULL THEN 0 ELSE 1 END AS bit) AS PRIVATE_FIELD
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN CIC_View_MailFormField mf
		ON fo.FieldID = mf.FieldID
	INNER JOIN CIC_View_DisplayFieldGroup fg
		ON mf.DisplayFieldGroupID=fg.DisplayFieldGroupID
	INNER JOIN CIC_View_DisplayFieldGroup_Name fgn
		ON fg.DisplayFieldGroupID=fgn.DisplayFieldGroupID
			AND fgn.LangID=(SELECT TOP 1 LangID FROM CIC_View_DisplayFieldGroup_Name WHERE DisplayFieldGroupID=fgn.DisplayFieldGroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE	(CanUseFeedback = 1)
	AND (fg.ViewType = @ViewType)
	AND (@IsCCR = 1 OR fo.FieldType <> 'CCR')
	AND (PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB pr WHERE pr.NUM=@NUM AND pr.PB_ID=fo.PB_ID))
	AND (fg.DisplayFieldGroupID IS NOT NULL)
ORDER BY fg.DisplayOrder, fgn.Name, fo.DisplayOrder, ISNULL(fod.FieldDisplay,fo.FieldName)

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_MailFormFields] TO [cioc_login_role]
GO
