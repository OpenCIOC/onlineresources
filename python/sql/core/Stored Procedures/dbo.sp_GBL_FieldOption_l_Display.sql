SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_FieldOption_l_Display]
	@MemberID [int],
	@AllDescriptions bit = 1
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT	fo.FieldID,
		fo.FieldName,
		fo.DisplayOrder,
		CASE WHEN fo.FieldType = 'GBL' THEN 1 ELSE 0 END AS  Shared, 
		CASE WHEN fo.AllowNulls = 1 THEN 0 ELSE 1 END AS Required,
		CASE WHEN fo.CheckHTML=1 AND fo.FormFieldType='m' OR fo.FieldName IN ('ELIGIBILITY') THEN fo.WYSIWYG ELSE NULL END AS WYSIWYG,
		fo.CannotRequire,
		fo.MemberID,
		(SELECT fod.FieldDisplay, l.Culture
			FROM dbo.GBL_FieldOption_Description fod
				INNER JOIN dbo.STP_Language l
					ON l.LangID=fod.LangID AND @AllDescriptions = 1
			WHERE fod.FieldID=fo.FieldID
			FOR XML PATH('DESC'), ROOT('DESCS'), TYPE) AS Descriptions
	FROM dbo.GBL_FieldOption fo
	LEFT JOIN dbo.GBL_FieldOption_InactiveByMember fi
		ON fo.FieldID=fi.FieldID AND fi.MemberID=@MemberID
ORDER BY fo.DisplayOrder, fo.FieldName

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_FieldOption_l_Display] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_FieldOption_l_Display] TO [cioc_login_role]
GO
