SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Agency_s]
	@MemberID int,
	@AgencyID int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 09-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int
SET @Error = 0

DECLARE @AgencyObjectName nvarchar(100)
SET @AgencyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Agency')

IF @AgencyID IS NULL BEGIN
	SET @Error = 2 -- No ID Provided
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AgencyObjectName, NULL)
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Agency WHERE AgencyID=@AgencyID) BEGIN
	SET @Error = 3 -- No Record with ID
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@AgencyID AS varchar(25)), @AgencyObjectName)
END ELSE IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_Agency WHERE AgencyID=@AgencyID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @AgencyObjectName, NULL)
END 

SELECT a.*,
		(SELECT COUNT(*) FROM GBL_Users u INNER JOIN GBL_Agency a ON u.Agency=a.AgencyCode WHERE a.AgencyID=@AgencyID) AS Users,
		(SELECT COUNT(*) FROM GBL_BaseTable bt WHERE RECORD_OWNER=a.AgencyCode) AS GBLRecords,
		(SELECT COUNT(*) FROM VOL_Opportunity vo WHERE RECORD_OWNER=a.AgencyCode) AS VOLRecords,
		(SELECT ISNULL(md.MemberName, '#' + CAST(m.MemberID AS varchar(25)))
	FROM STP_Member m
	INNER JOIN STP_Member_Description md
		ON md.MemberID=m.MemberID AND md.LangID=(SELECT TOP 1 LangID FROM STP_Member_Description WHERE MemberID=md.MemberID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		WHERE m.MemberID=a.MemberID) AS MemberName
	FROM GBL_Agency a
WHERE AgencyID=@AgencyID AND (@MemberID IS NULL OR MemberID=@MemberID)


RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Agency_s] TO [cioc_login_role]
GO
