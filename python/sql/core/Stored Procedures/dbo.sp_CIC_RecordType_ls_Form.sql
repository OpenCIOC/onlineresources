SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_RecordType_ls_Form]
	@ViewType int,
	@User_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @SL_ID int

SET @SL_ID = NULL
IF @User_ID IS NOT NULL BEGIN
	SELECT @SL_ID=SL_ID_CIC FROM GBL_Users WHERE User_ID=@User_ID
	IF NOT EXISTS(SELECT * FROM CIC_SecurityLevel_RecordType WHERE SL_ID=@SL_ID) BEGIN
		SET @SL_ID = NULL
	END
END

SELECT	rt.*, rtn.Name AS RecordTypeName, ProgramOrBranch,
		CAST(CASE WHEN EXISTS(SELECT * FROM CIC_View_UpdateField uf
			INNER JOIN CIC_View_DisplayFieldGroup fg
				ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID
			WHERE ViewType=@ViewType AND uf.RT_ID=rt.RT_ID) THEN 1 ELSE 0 END AS bit) AS HAS_FORM
	FROM CIC_RecordType rt
	LEFT JOIN CIC_RecordType_Name rtn
		ON rt.RT_ID=rtn.RT_ID AND rtn.LangID=@@LANGID
WHERE @SL_ID IS NULL
	OR EXISTS(SELECT * FROM CIC_SecurityLevel_RecordType srt WHERE rt.RT_ID=srt.RT_ID AND SL_ID=@SL_ID)
ORDER BY rt.DisplayOrder, rt.RecordType

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_RecordType_ls_Form] TO [cioc_login_role]
GO
