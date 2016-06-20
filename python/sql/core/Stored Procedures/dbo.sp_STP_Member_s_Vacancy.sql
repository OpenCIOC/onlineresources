SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_STP_Member_s_Vacancy] (
	@MemberID int
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 23-Dec-2011
	Action:	NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

/* Select fields */
SELECT	VacancyFundedCapacity,
		VacancyServiceHours,
		VacancyServiceDays,
		VacancyServiceWeeks,
		VacancyServiceFTE
FROM STP_Member
WHERE MemberID=@MemberID

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_STP_Member_s_Vacancy] TO [cioc_login_role]
GO
