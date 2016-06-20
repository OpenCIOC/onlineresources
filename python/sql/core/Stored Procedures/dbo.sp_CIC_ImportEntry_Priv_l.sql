SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Priv_l]
	@MemberID int,
	@EF_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 27-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
-- Import Entry belongs to Member ?
END ELSE IF EXISTS(SELECT * FROM CIC_ImportEntry WHERE EF_ID=@EF_ID AND MemberID<>@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @MemberID = NULL
END

SELECT ipp.*,
	(SELECT TOP 1 pp.ProfileID 
		FROM GBL_PrivacyProfile pp
		WHERE pp.MemberID=@MemberID
			AND (SELECT COUNT(*) FROM GBL_PrivacyProfile_Name ppn
				WHERE pp.ProfileID=ppn.ProfileID
					AND EXISTS(SELECT * FROM CIC_ImportEntry_PrivacyProfile_Name ippn
						WHERE ippn.ER_ID=ipp.ER_ID AND ippn.ProfileName=ppn.ProfileName AND ippn.LangID=ppn.LangID)
					)
				= (SELECT COUNT(*) FROM CIC_ImportEntry_PrivacyProfile_Name ippn WHERE ippn.ER_ID=ipp.ER_ID)
		) AS ProfileID,
	(SELECT ippn.ProfileName AS [@ProfileName], l.Culture AS [@Culture]
		FROM CIC_ImportEntry_PrivacyProfile_Name ippn
		INNER JOIN STP_Language l
			ON ippn.LangID=l.LangID
		WHERE ippn.ER_ID=ipp.ER_ID
		FOR XML PATH('DESC'), TYPE) AS Names
	FROM CIC_ImportEntry_PrivacyProfile ipp
WHERE EF_ID=@EF_ID
ORDER BY (SELECT TOP 1 ProfileName FROM CIC_ImportEntry_PrivacyProfile_Name WHERE ER_ID=ipp.ER_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Priv_l] TO [cioc_login_role]
GO
