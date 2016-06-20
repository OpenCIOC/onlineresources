SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_s_CanCopy_2]
	@ViewType int,
	@RT_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: CL
	Checked on: 8-Oct-2013
	Action: NO ACTION REQUIRED
*/

IF @RT_ID IS NOT NULL BEGIN
	IF NOT EXISTS(SELECT * FROM CIC_View_UpdateField uf
		INNER JOIN CIC_View_DisplayFieldGroup fg
			ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID
		WHERE ViewType=@ViewType AND RT_ID=@RT_ID) BEGIN
			SET @RT_ID = NULL
	END
END

SELECT
	CAST(CASE WHEN EXISTS(SELECT * FROM CIC_View_UpdateField uf
			INNER JOIN CIC_View_DisplayFieldGroup fg
				ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID
			WHERE uf.FieldID=fo.FieldID AND ViewType=@ViewType AND (uf.RT_ID=@RT_ID OR (uf.RT_ID IS NULL AND @RT_ID IS NULL)))
		THEN 1 ELSE 0 END AS bit) AS CAN_UPDATE,
		fo.FieldName,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
WHERE	FieldName LIKE 'ORG_LEVEL_[1-5]' OR FieldName = 'LOCATION_NAME' OR FieldName LIKE 'SERVICE_NAME_LEVEL_[1-2]'
ORDER BY fo.FieldName

SELECT	fg.DisplayFieldGroupID,
		fgn.Name AS DisplayFieldGroupName,
		fo.FieldName,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN CIC_View_UpdateField uf
		ON fo.FieldID = uf.FieldID
	INNER JOIN CIC_View_DisplayFieldGroup fg
		ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID
	INNER JOIN CIC_View_DisplayFieldGroup_Name fgn
		ON fg.DisplayFieldGroupID=fgn.DisplayFieldGroupID
			AND fgn.LangID=(SELECT TOP 1 LangID FROM CIC_View_DisplayFieldGroup_Name WHERE DisplayFieldGroupID=fgn.DisplayFieldGroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE	(CanUseUpdate = 1) 
		AND (fg.ViewType = @ViewType)
		AND (uf.RT_ID=@RT_ID OR (uf.RT_ID IS NULL AND @RT_ID IS NULL))
		AND FieldName NOT LIKE 'ORG_LEVEL_[1-5]'
		AND FieldName NOT IN ('NUM','RECORD_OWNER','NON_PUBLIC','MAIN_ADDRESS', 'LOCATION_NAME', 'SERVICE_NAME_LEVEL_1', 'SERVICE_NAME_LEVEL_2')
ORDER BY uf.RT_ID, fg.DisplayOrder, fgn.Name, fo.DisplayOrder, ISNULL(fod.FieldDisplay,fo.FieldName)

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_s_CanCopy_2] TO [cioc_login_role]
GO
