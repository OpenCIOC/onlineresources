SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CIC_View_FacetFields_l]
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked by: KL
	Checked on: 25-Jul-2019
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE @Field1 INT, @Field2 INT, @Field3 INT, @Field4 INT

SELECT @Field1=vw.RefineField1, @Field2=vw.RefineField2, @Field3=vw.RefineField3, @Field4=vw.RefineField4
	FROM dbo.CIC_View vw
	WHERE vw.ViewType=@ViewType

SELECT fo.FieldID, FieldName, FieldType,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay,
		CASE WHEN ChecklistSearch IN ('scha','sche') THEN 'sch' ELSE ChecklistSearch END AS ChecklistSearch,
		fo.PB_ID,
		fo.FacetFieldList
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
WHERE
	fo.FieldID IN (@Field1,@Field2,@Field3,@Field4)
	AND fo.FacetFieldList IS NOT NULL 
ORDER BY CASE
				WHEN fo.FieldID=@Field1 THEN 1
				WHEN fo.FieldID=@Field2 THEN 2
				WHEN fo.FieldID=@Field3 THEN 3
				WHEN fo.FieldID=@Field4 THEN 4
				END

RETURN @Error

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_FacetFields_l] TO [cioc_cic_search_role]
GO
