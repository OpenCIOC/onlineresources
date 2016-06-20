SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_View_FeedbackFields]
	@ViewType int,
	@VNUM varchar(10)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7
	Checked by: ND
	Checked on: 06-Oct-2015
	Action: TESTING REQUIRED
*/

DECLARE @MemberID int
SELECT @MemberID=MemberID FROM VOL_View WHERE ViewType=@ViewType

SELECT	fo.FieldName,
		fo.EquivalentSource,
		fo.MaxLength,
		fo.FieldType,
		fo.FormFieldType,
		fo.ExtraFieldType,
		fo.ValidateType,
		fo.AllowNulls,
		fo.CanUseFeedback,
		fod.CheckboxOnText,
		fod.CheckboxOffText,
		fo.UseDisplayForFeedback,
		CASE WHEN UseDisplayForFeedback = 1 THEN dbo.fn_VOL_FieldOption_Display(
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
			ELSE REPLACE(REPLACE(ISNULL(FeedbackFieldList,UpdateFieldList), '[LANGID]', @@LANGID), '[MEMBER]', @MemberID)
		END AS FieldSelect,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay,
		CASE WHEN fod.HelpText IS NULL AND foh.HelpText IS NULL THEN 0 ELSE 1 END AS HasHelp
	FROM VOL_FieldOption fo
	LEFT JOIN VOL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN VOL_View_FeedbackField ff
		ON fo.FieldID = ff.FieldID
	LEFT JOIN VOL_FieldOption_HelpByMember foh
		ON foh.FieldID = fod.FieldID AND foh.LangID = fod.LangID AND foh.MemberID=@MemberID
WHERE	(CanUseFeedback = 1)
	AND (ff.ViewType = @ViewType)
	AND (
		@VNUM IS NULL
		OR (SELECT MemberID FROM VOL_Opportunity WHERE VNUM=@VNUM)=@MemberID
		OR CanShare=0
		OR EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE ShareMemberID=@MemberID AND shp.Active=1
			AND (shp.CanUseAnyView=1 OR EXISTS(SELECT * FROM GBL_SharingProfile_VOL_View shpv WHERE shpv.ProfileID=shp.ProfileID AND shpv.ViewType=@ViewType))
			AND EXISTS(SELECT * FROM GBL_SharingProfile_CIC_Fld shpf WHERE shpf.ProfileID=shp.ProfileID AND shpf.FieldID=fo.FieldID)
			AND EXISTS(SELECT * FROM VOL_OP_SharingProfile shpr WHERE shpr.ProfileID=shp.ProfileID AND shpr.VNUM=@VNUM)
		)
	)
ORDER BY DisplayOrder, ISNULL(FieldDisplay, FieldName)

SET NOCOUNT OFF






GO



GRANT EXECUTE ON  [dbo].[sp_VOL_View_FeedbackFields] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_View_FeedbackFields] TO [cioc_vol_search_role]
GO
