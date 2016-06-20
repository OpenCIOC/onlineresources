SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_ExtraCheckList_s_Entryform] (
	@MemberID int,
	@FieldName varchar(100)
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.2
	Checked by: KL
	Checked on: 17-Feb-2015
	Action: NO ACTION REQUIRED
*/

SELECT 
	(
	SELECT exc.EXC_ID '@ID', ISNULL(CASE WHEN excn.LangID=@@LANGID THEN excn.Name ELSE '[' + excn.Name + ']' END,exc.Code) '@Name'
		FROM VOL_ExtraCheckList exc
		LEFT JOIN VOL_ExtraCheckList_Name excn
			ON exc.EXC_ID=excn.EXC_ID
				AND excn.LangID=(SELECT TOP 1 LangID FROM VOL_ExtraCheckList_Name WHERE EXC_ID=exc.EXC_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE exc.FieldName=@FieldName
		AND COALESCE(excn.Name,exc.Code) IS NOT NULL
		AND (exc.MemberID IS NULL OR @MemberID IS NULL OR exc.MemberID=@MemberID)
		AND NOT EXISTS(SELECT * FROM VOL_ExtraCheckList_InactiveByMember WHERE EXC_ID=exc.EXC_ID AND MemberID=@MemberID)
	ORDER BY exc.DisplayOrder, ISNULL(excn.Name,exc.Code)
FOR XML PATH('CHK'),ROOT('EXTRA_CHECKLIST'), TYPE) AS EXTRA_CHECKLIST 

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_ExtraCheckList_s_Entryform] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_ExtraCheckList_s_Entryform] TO [cioc_vol_search_role]
GO
