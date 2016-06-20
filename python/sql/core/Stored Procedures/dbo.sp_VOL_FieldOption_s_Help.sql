
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_FieldOption_s_Help]
	@FieldName varchar(100),
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: CL
	Checked on: 05-Sep-2014
	Action: NO ACTION REQUIRED
*/

SELECT	fo.FieldID,
		fo.FieldName,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay,
		ISNULL(foh.HelpText, fod.HelpText) AS HelpText
	FROM VOL_FieldOption fo
	LEFT JOIN VOL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	LEFT JOIN VOL_FieldOption_HelpByMember foh
		ON foh.FieldID=fod.FieldID AND foh.LangID=fod.LangID AND foh.MemberID=@MemberID
WHERE FieldName = @FieldName

SET NOCOUNT OFF



GO

GRANT EXECUTE ON  [dbo].[sp_VOL_FieldOption_s_Help] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_FieldOption_s_Help] TO [cioc_vol_search_role]
GO
