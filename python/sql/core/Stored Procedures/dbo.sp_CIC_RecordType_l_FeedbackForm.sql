SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_RecordType_l_FeedbackForm]
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT rt.RT_ID, rt.RecordType, rtn.Name AS RecordTypeName
	FROM CIC_RecordType rt
	LEFT JOIN CIC_RecordType_Name rtn
		ON rt.RT_ID=rtn.RT_ID AND rtn.LangID=@@LANGID
WHERE EXISTS(SELECT * FROM CIC_View_FeedbackField ff
	INNER JOIN CIC_View_DisplayFieldGroup fg ON ff.DisplayFieldGroupID=fg.DisplayFieldGroupID
	WHERE ViewType=@ViewType AND RT_ID=rt.RT_ID)
ORDER BY rt.DisplayOrder, rt.RecordType

SELECT rt.RT_ID, rt.RecordType, rtn.Name AS RecordTypeName
	FROM CIC_RecordType rt
	LEFT JOIN CIC_RecordType_Name rtn
		ON rt.RT_ID=rtn.RT_ID AND rtn.LangID=@@LANGID
WHERE NOT EXISTS(SELECT * FROM CIC_View_FeedbackField ff
	INNER JOIN CIC_View_DisplayFieldGroup fg ON ff.DisplayFieldGroupID=fg.DisplayFieldGroupID
	WHERE ViewType=@ViewType AND RT_ID=rt.RT_ID)
ORDER BY rt.DisplayOrder, rt.RecordType

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_RecordType_l_FeedbackForm] TO [cioc_login_role]
GO
