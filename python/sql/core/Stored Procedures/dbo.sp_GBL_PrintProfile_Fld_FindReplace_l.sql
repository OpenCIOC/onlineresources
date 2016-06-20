SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PrintProfile_Fld_FindReplace_l]
	@MemberID int,
	@Domain tinyint,
	@PFLD_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 20-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE	@ProfileID int,
		@GBLField bit
		
SELECT @ProfileID=ProfileID, @GBLField = CASE WHEN GBLFieldID IS NULL THEN 0 ELSE 1 END
	FROM GBL_PrintProfile_Fld fld
WHERE PFLD_ID=@PFLD_ID

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
-- Ownership OK ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_PrintProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID AND Domain=@Domain) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ProfileID = NULL
END

IF @GBLField=1 BEGIN
	SELECT fo.FieldName, ppn.ProfileID, ProfileName
		FROM GBL_PrintProfile_Fld fld
		INNER JOIN GBL_PrintProfile_Description ppn
			ON ppn.ProfileID=fld.ProfileID AND LangID=(SELECT TOP 1 LangID FROM GBL_PrintProfile_Description WHERE ppn.ProfileID=ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		INNER JOIN GBL_FieldOption fo
			ON fld.GBLFieldID=fo.FieldID
	WHERE PFLD_ID=@PFLD_ID
		AND fld.ProfileID=@ProfileID
END ELSE BEGIN
	SELECT fo.FieldName, ppn.ProfileID, ProfileName
		FROM GBL_PrintProfile_Fld fld
		INNER JOIN GBL_PrintProfile_Description ppn
			ON ppn.ProfileID=fld.ProfileID AND LangID=(SELECT TOP 1 LangID FROM GBL_PrintProfile_Description WHERE ppn.ProfileID=ProfileID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		INNER JOIN VOL_FieldOption fo
			ON fld.VOLFieldID=fo.FieldID
	WHERE PFLD_ID=@PFLD_ID
		AND fld.ProfileID=@ProfileID
		AND @Domain=2
END

SELECT *, (SELECT LangID AS [text()]
			FROM GBL_PrintProfile_Fld_FindReplace_Lang
			WHERE pfr.PFLD_RP_ID=PFLD_RP_ID
			FOR XML PATH('LangID'), TYPE) AS Languages
	FROM GBL_PrintProfile_Fld_FindReplace pfr
	INNER JOIN GBL_PrintProfile_Fld fld
		ON pfr.PFLD_ID=fld.PFLD_ID
WHERE pfr.PFLD_ID=@PFLD_ID
	AND fld.ProfileID=@ProfileID
ORDER BY RunOrder

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PrintProfile_Fld_FindReplace_l] TO [cioc_login_role]
GO
