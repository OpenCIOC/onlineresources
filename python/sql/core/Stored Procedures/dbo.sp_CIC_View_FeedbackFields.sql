
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_View_FeedbackFields]
	@ViewType int,
	@RT_ID int,
	@NUM varchar(8),
	@LoggedIn bit,
	@UPDATE_PASSWORD varchar(21)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 28-Sep-2014
	Action: NO ACTION REQUIRED
*/

DECLARE @MemberID int,
		@BTMemberID int,
		@RespectPrivacyProfile bit,
		@ProfileID int,
		@UPDATE_PASSWORD_REQUIRED bit,
		@PASSWORD_MATCH bit,
		@inclCCR bit

SELECT @BTMemberID=MemberID, @ProfileID = PRIVACY_PROFILE, @PASSWORD_MATCH=CASE WHEN UPDATE_PASSWORD=@UPDATE_PASSWORD THEN 1 ELSE 0 END,
			@UPDATE_PASSWORD_REQUIRED=UPDATE_PASSWORD_REQUIRED
		FROM GBL_BaseTable bt WHERE bt.NUM=@NUM

SELECT	@MemberID=MemberID,
		@RespectPrivacyProfile=RespectPrivacyProfile
	FROM CIC_View
WHERE ViewType=@ViewType

SET @RespectPrivacyProfile=CASE
		WHEN @ProfileID IS NULL THEN 0
		WHEN @LoggedIn=1
			AND (@BTMemberID=@MemberID
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

IF @RT_ID = -1 BEGIN
	SELECT @RT_ID = RECORD_TYPE FROM CIC_BaseTable WHERE NUM=@NUM
	IF @RT_ID = -1 SET @RT_ID = NULL
END

IF @RT_ID IS NOT NULL BEGIN
	IF NOT EXISTS(SELECT * FROM CIC_View_FeedbackField ff
		INNER JOIN CIC_View_DisplayFieldGroup fg
			ON ff.DisplayFieldGroupID=fg.DisplayFieldGroupID
		WHERE fg.ViewType=@ViewType AND ff.RT_ID=@RT_ID) BEGIN
			SET @RT_ID = NULL
	END
END

SET @inclCCR = CASE
		WHEN EXISTS(SELECT * FROM CIC_View WHERE ViewType=@ViewType AND CCRFields=1) THEN 1
		WHEN @NUM IS NULL THEN 0
		ELSE CASE WHEN EXISTS(SELECT * FROM CCR_BaseTable ccbt INNER JOIN GBL_BaseTable bt ON bt.NUM=ccbt.NUM WHERE ccbt.NUM=@NUM) THEN 1 ELSE 0 END
	END

SELECT	fg.DisplayFieldGroupID,
		fgn.Name AS DisplayFieldGroupName,
		fo.FieldName,
		fo.EquivalentSource,
		fo.MaxLength,
		fo.FieldType,
		fo.FormFieldType,
		fo.ExtraFieldType,
		fo.ValidateType,
		fo.AllowNulls,
		fo.CanUseFeedback,
		fo.UseDisplayForFeedback,
		fod.CheckboxOnText,
		fod.CheckboxOffText,
		dbo.fn_CIC_PubRelationID(@NUM, PB_ID) AS BT_PB_ID,
		CASE WHEN UseDisplayForFeedback = 1 THEN dbo.fn_GBL_FieldOption_Display(
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
			ELSE REPLACE(REPLACE(ISNULL(FeedbackFieldList,UpdateFieldList),'[LANGID]',@@LANGID),'[MEMBER]',@MemberID)
		END AS FieldSelect,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay,
		CASE WHEN fod.HelpText IS NULL AND foh.HelpText IS NULL THEN 0 ELSE 1 END AS HasHelp
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN CIC_View_FeedbackField ff
		ON fo.FieldID = ff.FieldID
	INNER JOIN CIC_View_DisplayFieldGroup fg
		ON ff.DisplayFieldGroupID=fg.DisplayFieldGroupID
	INNER JOIN CIC_View_DisplayFieldGroup_Name fgn
		ON fg.DisplayFieldGroupID=fgn.DisplayFieldGroupID
			AND fgn.LangID=(SELECT TOP 1 LangID FROM CIC_View_DisplayFieldGroup_Name WHERE DisplayFieldGroupID=fgn.DisplayFieldGroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_FieldOption_HelpByMember foh
		ON foh.FieldID = fod.FieldID AND foh.LangID = fod.LangID AND foh.MemberID=@MemberID
WHERE	(CanUseFeedback = 1)
	AND (fg.ViewType = @ViewType)
	AND ((@RT_ID IS NULL AND ff.RT_ID IS NULL) OR (@RT_ID=ff.RT_ID))
	AND (fo.PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB pr WHERE pr.NUM=@NUM AND pr.PB_ID=fo.PB_ID))
	AND (@inclCCR=1 OR fo.FieldType<>'CCR')
	AND (fo.PrivacyProfileIDList IS NULL
		OR (@UPDATE_PASSWORD_REQUIRED IS NULL AND @ProfileID IS NULL)
		OR (@UPDATE_PASSWORD_REQUIRED IS NOT NULL AND @PASSWORD_MATCH=1)
		OR (@UPDATE_PASSWORD_REQUIRED=0 AND @PASSWORD_MATCH=0 AND NOT EXISTS(SELECT * FROM GBL_PrivacyProfile_Fld WHERE ProfileID=@ProfileID AND FieldID=fo.FieldID))
		OR (@RespectPrivacyProfile=0)
		)
	AND (
			@NUM IS NULL
			OR (SELECT MemberID FROM GBL_BaseTable WHERE NUM=@NUM)=@MemberID
			OR fo.CanShare=0
			OR EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE ShareMemberID=@MemberID AND shp.Active=1
				AND (shp.CanUseAnyView=1 OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View shpv WHERE shpv.ProfileID=shp.ProfileID AND shpv.ViewType=@ViewType))
				AND EXISTS(SELECT * FROM GBL_SharingProfile_CIC_Fld shpf WHERE shpf.ProfileID=shp.ProfileID AND shpf.FieldID=fo.FieldID)
				AND EXISTS(SELECT * FROM GBL_BT_SharingProfile shpr WHERE shpr.ProfileID=shp.ProfileID AND shpr.NUM=@NUM)
			)
		)
ORDER BY fg.DisplayOrder, fgn.Name, fo.DisplayOrder, ISNULL(fod.FieldDisplay,fo.FieldName)

SET NOCOUNT OFF





GO



GRANT EXECUTE ON  [dbo].[sp_CIC_View_FeedbackFields] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_View_FeedbackFields] TO [cioc_login_role]
GO
