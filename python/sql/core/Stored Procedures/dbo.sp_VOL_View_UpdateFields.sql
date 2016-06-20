
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_View_UpdateFields]
	@VNUM varchar(10),
	@User_ID int,
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.2
	Checked by: KL
	Checked on: 23-Oct-2015
	Action: TESTING REQUIRED
*/

DECLARE @MemberID int
SELECT @MemberID=MemberID FROM VOL_View WHERE ViewType=@ViewType

SELECT EnforceReqFields FROM GBL_Agency a INNER JOIN GBL_Users u ON a.AgencyCode=u.Agency AND u.User_ID=@User_ID

SELECT	fo.FieldName,
		fo.EquivalentSource,
		fo.ChangeHistory,
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
		ISNULL(REPLACE(REPLACE(UpdateFieldList,'[LANGID]',@@LANGID),'[MEMBER]', @MemberID), CASE
				WHEN FormFieldType = 'f' THEN NULL
				ELSE CASE WHEN EquivalentSource=1 THEN 'vod.' ELSE 'vo.' END + FieldName
			END) AS FieldSelect,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay,
		CASE WHEN fod.HelpText IS NULL AND foh.HelpText IS NULL THEN 0 ELSE 1 END AS HasHelp
	FROM VOL_FieldOption fo
	LEFT JOIN VOL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN VOL_View_UpdateField uf
		ON fo.FieldID = uf.FieldID
	LEFT JOIN VOL_FieldOption_HelpByMember foh
		ON foh.FieldID = fod.FieldID AND foh.LangID = fod.LangID AND MemberID=@MemberID
WHERE (fo.CanUseUpdate = 1)
	AND (uf.ViewType = @ViewType)
ORDER BY DisplayOrder, ISNULL(FieldDisplay,FieldName)

SET NOCOUNT OFF



GO



GRANT EXECUTE ON  [dbo].[sp_VOL_View_UpdateFields] TO [cioc_login_role]
GO
