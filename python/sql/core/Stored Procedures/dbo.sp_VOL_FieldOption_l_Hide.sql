SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_FieldOption_l_Hide]
	@MemberID [int],
	@AllDescriptions bit = 1
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-May-2011
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT	fo.FieldID,
		fo.FieldName,
		fo.DisplayOrder,
		CAST(CASE WHEN fi.FieldID IS NULL THEN 0 ELSE 1 END AS bit) AS InactiveByMember,
		(SELECT fod.FieldDisplay, l.Culture
			FROM VOL_FieldOption_Description fod
				INNER JOIN STP_Language l
					ON l.LangID=fod.LangID AND @AllDescriptions = 1
			WHERE fod.FieldID=fo.FieldID
			FOR XML PATH('DESC'), ROOT('DESCS'), TYPE) AS Descriptions
	FROM VOL_FieldOption fo
	LEFT JOIN VOL_FieldOption_InactiveByMember fi
		ON fo.FieldID=fi.FieldID AND fi.MemberID=@MemberID
ORDER BY CASE WHEN fi.FieldID IS NOT NULL THEN 0 ELSE 1 END, DisplayOrder, FieldName

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_VOL_FieldOption_l_Hide] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_FieldOption_l_Hide] TO [cioc_vol_search_role]
GO
