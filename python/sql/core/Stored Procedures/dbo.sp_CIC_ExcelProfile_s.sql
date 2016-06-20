SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_ExcelProfile_s]
	@MemberID int,
	@ProfileID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
-- Profile ID given ?
END ELSE IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_ExcelProfile WHERE ProfileID=@ProfileID) BEGIN
	SET @Error = 3 -- No Such Record
-- Profile ID belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_ExcelProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT * 
	FROM GBL_ExcelProfile
WHERE MemberID=@MemberID
	AND Domain=1
	AND ProfileID=@ProfileID

SELECT pn.*, (SELECT Culture FROM STP_Language WHERE pn.LangID=LangID) AS Culture
	FROM GBL_ExcelProfile_Name pn 
WHERE ProfileID=@ProfileID

SELECT GBLFieldID AS FieldID, DisplayOrder, SortByOrder 
	FROM GBL_ExcelProfile_Fld
WHERE ProfileID=@ProfileID
	AND GBLFieldID IS NOT NULL
ORDER BY DisplayOrder, SortByOrder

SELECT ViewType
	FROM CIC_View_ExcelProfile ep
WHERE ProfileID=@ProfileID

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ExcelProfile_s] TO [cioc_login_role]
GO
