SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Stats]
	@MemberID int,
	@EF_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int,
		@ErrMsg nvarchar(500)

SET @Error = 0
SET @ErrMsg = NULL

DECLARE	@MemberObjectName	nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
	SET @MemberID = NULL
-- Import Entry belongs to Member ?
END ELSE IF EXISTS(SELECT * FROM CIC_ImportEntry WHERE EF_ID=@EF_ID AND MemberID<>@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END

SELECT @Error AS Error, @ErrMsg AS ErrMsg

SELECT ied.*,
	(SELECT COUNT(*)
		FROM CIC_ImportEntry_Data ied
		WHERE ied.EF_ID=@EF_ID
			AND ied.DATA IS NOT NULL AND ied.IMPORTED=0
			AND NOT EXISTS(SELECT * FROM GBL_BaseTable bt WHERE bt.NUM=ied.NUM)
			AND EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID=0)
			AND NOT EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID<>0)
		) AS ADD_ENGLISH,
	(SELECT COUNT(*)
		FROM CIC_ImportEntry_Data ied
		WHERE ied.EF_ID=@EF_ID
			AND ied.DATA IS NOT NULL AND ied.IMPORTED=0
			AND NOT EXISTS(SELECT * FROM GBL_BaseTable bt WHERE bt.NUM=ied.NUM)
			AND EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID=2)
			AND NOT EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID<>2)
		) AS ADD_FRENCH,
	(SELECT COUNT(*)
		FROM CIC_ImportEntry_Data ied
		WHERE ied.EF_ID=@EF_ID
			AND ied.DATA IS NOT NULL AND ied.IMPORTED=0
			AND NOT EXISTS(SELECT * FROM GBL_BaseTable bt WHERE bt.NUM=ied.NUM)
			AND (SELECT COUNT(*) FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID) > 1
		) AS ADD_MULTILINGUAL,
	(SELECT COUNT(*)
			FROM CIC_ImportEntry_Data ied
			INNER JOIN GBL_BaseTable bt
				ON bt.NUM=ied.NUM
			WHERE bt.MemberID=@MemberID
				AND ied.EF_ID=@EF_ID
				AND ied.DATA IS NOT NULL AND ied.IMPORTED=0
				AND EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID=0)
				AND NOT EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID<>0)
		) AS UPDATE_ENGLISH,
	(SELECT COUNT(*)
			FROM CIC_ImportEntry_Data ied
			INNER JOIN GBL_BaseTable bt
				ON bt.NUM=ied.NUM
			WHERE bt.MemberID=@MemberID
				AND ied.EF_ID=@EF_ID
				AND ied.DATA IS NOT NULL AND ied.IMPORTED=0
				AND EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID=2)
				AND NOT EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID<>2)
		) AS UPDATE_FRENCH,
	(SELECT COUNT(*)
			FROM CIC_ImportEntry_Data ied
			INNER JOIN GBL_BaseTable bt
				ON bt.NUM=ied.NUM
			WHERE bt.MemberID=@MemberID
				AND ied.EF_ID=@EF_ID
				AND ied.DATA IS NOT NULL AND ied.IMPORTED=0
				AND (SELECT COUNT(*) FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID) > 1
		) AS UPDATE_MULTILINGUAL,
	(SELECT COUNT(*)
			FROM CIC_ImportEntry_Data ied
			INNER JOIN GBL_BaseTable bt
				ON bt.NUM=ied.NUM
			WHERE bt.MemberID<>@MemberID
				AND ied.EF_ID=@EF_ID
				AND ied.DATA IS NOT NULL AND ied.IMPORTED=0
				AND EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID=0)
				AND NOT EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID<>0)
		) AS NOUPDATE_ENGLISH,
	(SELECT COUNT(*)
			FROM CIC_ImportEntry_Data ied
			INNER JOIN GBL_BaseTable bt
				ON bt.NUM=ied.NUM
			WHERE bt.MemberID<>@MemberID
				AND ied.EF_ID=@EF_ID
				AND ied.DATA IS NOT NULL AND ied.IMPORTED=0
				AND EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID=2)
				AND NOT EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID<>2)
		) AS NOUPDATE_FRENCH,
	(SELECT COUNT(*)
			FROM CIC_ImportEntry_Data ied
			INNER JOIN GBL_BaseTable bt
				ON bt.NUM=ied.NUM
			WHERE bt.MemberID<>@MemberID
				AND ied.EF_ID=@EF_ID
				AND ied.DATA IS NOT NULL AND ied.IMPORTED=0
				AND (SELECT COUNT(*) FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID) > 1
		) AS NOUPDATE_MULTILINGUAL,
	(SELECT COUNT(*)
			FROM CIC_ImportEntry_Data ied
			WHERE ied.EF_ID=@EF_ID
				AND (ied.DATA IS NULL OR ied.IMPORTED=1)
				AND EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID=0)
				AND NOT EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID<>0)
		) AS COMPLETED_ENGLISH,
	(SELECT COUNT(*)
			FROM CIC_ImportEntry_Data ied
			WHERE ied.EF_ID=@EF_ID
				AND (ied.DATA IS NULL OR ied.IMPORTED=1)
				AND EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID=2)
				AND NOT EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID<>2)
		) AS COMPLETED_FRENCH,
	(SELECT COUNT(*)
			FROM CIC_ImportEntry_Data ied
			WHERE ied.EF_ID=@EF_ID
				AND (ied.DATA IS NULL OR ied.IMPORTED=1)
				AND (SELECT COUNT(*) FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID) > 1
		) AS COMPLETED_MULTILINGUAL,
	(SELECT COUNT(*)
			FROM CIC_ImportEntry_Data ied
			WHERE ied.EF_ID=@EF_ID
				AND ied.DATA IS NOT NULL AND ied.IMPORTED=1
				AND EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID=0)
				AND NOT EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID<>0)
		) AS COMPLETED_ENGLISH_RETRYABLE,
	(SELECT COUNT(*)
			FROM CIC_ImportEntry_Data ied
			WHERE ied.EF_ID=@EF_ID
				AND ied.DATA IS NOT NULL AND ied.IMPORTED=1
				AND EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID=2)
				AND NOT EXISTS(SELECT * FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID AND LangID<>2)
		) AS COMPLETED_FRENCH_RETRYABLE,
	(SELECT COUNT(*)
			FROM CIC_ImportEntry_Data ied
			WHERE ied.EF_ID=@EF_ID
				AND ied.DATA IS NOT NULL AND ied.IMPORTED=1
				AND (SELECT COUNT(*) FROM CIC_ImportEntry_Data_Language WHERE ER_ID=ied.ER_ID) > 1
		) AS COMPLETED_MULTILINGUAL_RETRYABLE
FROM CIC_ImportEntry ied
WHERE MemberID=@MemberID
	AND EF_ID=@EF_ID

SELECT LanguageName, SourceDbName, SourceDbURL
	FROM CIC_ImportEntry_Description ieds
	INNER JOIN STP_Language sln
		ON ieds.LangID=sln.LangID
WHERE ieds.EF_ID=@EF_ID

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Stats] TO [cioc_login_role]
GO
