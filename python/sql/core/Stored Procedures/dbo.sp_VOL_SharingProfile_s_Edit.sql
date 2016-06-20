
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_VOL_SharingProfile_s_Edit]
	@MemberID int,
	@ProfileID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 25-Mar-2012
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

SELECT spn.*, l.Culture
FROM GBL_SharingProfile_Name spn
INNER JOIN STP_Language l
	ON spn.LangID=l.LangID
WHERE ProfileID=@ProfileID

SELECT * 
FROM GBL_SharingProfile_VOL_Fld
WHERE ProfileID=@ProfileID

SELECT *
FROM GBL_SharingProfile_VOL_View
WHERE ProfileID=@ProfileID

SELECT l.Culture
FROM GBL_SharingProfile_EditLang el
INNER JOIN STP_Language l
	ON l.LangID = el.LangID
WHERE el.ProfileID=@ProfileID

RETURN @Error

SET NOCOUNT OFF





GO

GRANT EXECUTE ON  [dbo].[sp_VOL_SharingProfile_s_Edit] TO [cioc_login_role]
GO
