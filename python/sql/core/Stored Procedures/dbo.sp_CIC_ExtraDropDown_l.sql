
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_ExtraDropDown_l]
	@MemberID [int],
	@FieldName varchar(100),
	@ShowHidden [bit],
	@AllLanguages [bit],
	@OverrideID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 27-Sep-2014
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT exd.EXD_ID AS EXD_ID, ISNULL(CASE WHEN exdn.LangID=@@LANGID THEN exdn.Name ELSE '[' + exdn.Name + ']' END, exd.Code) AS ExtraDropDown
	FROM CIC_ExtraDropDown exd
	LEFT JOIN CIC_ExtraDropDown_Name exdn
		ON exd.EXD_ID=exdn.EXD_ID
			AND exdn.LangID=CASE
				WHEN @AllLanguages=0 AND (@OverrideID IS NULL OR exdn.EXD_ID<>@OverrideID) THEN @@LANGID
				ELSE (SELECT TOP 1 LangID FROM CIC_ExtraDropDown_Name WHERE EXD_ID=exd.EXD_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END
WHERE exd.FieldName=@FieldName
	AND ISNULL(exd.Code,exdn.Name) IS NOT NULL
	AND (exd.EXD_ID=@OverrideID
	OR ((exd.MemberID IS NULL OR @MemberID IS NULL OR exd.MemberID=@MemberID)
		AND (
			@ShowHidden=1
			OR NOT EXISTS(SELECT * FROM CIC_ExtraDropDown_InactiveByMember WHERE EXD_ID=exd.EXD_ID AND MemberID=@MemberID)
			)
		))
ORDER BY exd.DisplayOrder, exdn.Name

RETURN @Error

SET NOCOUNT OFF





GO

GRANT EXECUTE ON  [dbo].[sp_CIC_ExtraDropDown_l] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_ExtraDropDown_l] TO [cioc_login_role]
GO
