
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_FieldOption_l_Help]
	@MemberID int,
	@LangID smallint
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: CL
	Checked on: 05-Sep-2014
	Action: NO ACTION REQUIRED
*/

SELECT	fo.FieldName,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay,
		fod.HelpText,
		ISNULL(foh.HelpText, fod.HelpText) AS HelpTextMember
	FROM VOL_FieldOption fo
	LEFT JOIN VOL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@LangID
	LEFT JOIN VOL_FieldOption_HelpByMember foh
		ON foh.FieldID = fod.FieldID AND foh.LangID = fod.LangID AND foh.MemberID=@MemberID
WHERE @MemberID IS NULL
	OR NOT EXISTS(SELECT * FROM VOL_FieldOption_InactiveByMember fi WHERE fi.FieldID=fo.FieldID AND fi.MemberID=@MemberID)
ORDER BY DisplayOrder, FieldName

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_VOL_FieldOption_l_Help] TO [cioc_login_role]
GO
