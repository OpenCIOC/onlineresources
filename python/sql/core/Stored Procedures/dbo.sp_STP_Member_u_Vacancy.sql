SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_STP_Member_u_Vacancy]
	@MemberID int,
	@VacancyFundedCapacity bit,
	@VacancyServiceHours bit,
	@VacancyServiceDays bit,
	@VacancyServiceWeeks bit,
	@VacancyServiceFTE bit,
	@ErrMsg nvarchar(500) OUTPUT
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

DECLARE	@MemberObjectName nvarchar(100),
		@VacancyObjectName nvarchar(100)

SET @VacancyObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Vacancy')
SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
END ELSE BEGIN
	/* Update fields */
	UPDATE STP_Member
	SET
		VacancyFundedCapacity	= ISNULL(@VacancyFundedCapacity,VacancyFundedCapacity),
		VacancyServiceHours		= ISNULL(@VacancyServiceHours,VacancyServiceHours),
		VacancyServiceDays		= ISNULL(@VacancyServiceDays,VacancyServiceDays),
		VacancyServiceWeeks		= ISNULL(@VacancyServiceWeeks,VacancyServiceWeeks),
		VacancyServiceFTE		= ISNULL(@VacancyServiceFTE,VacancyServiceFTE)
	FROM STP_Member
	WHERE MemberID=@MemberID

	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @VacancyObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_STP_Member_u_Vacancy] TO [cioc_login_role]
GO
