
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_GeneralHeading_d]
	@MemberID int,
	@SuperUserGlobal bit,
	@GH_ID int,
	@PB_ID int,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.3
	Checked by: CL
	Checked on: 02-Jun-2015
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@GeneralHeadingObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @GeneralHeadingObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('General Heading')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Heading ID given ?
END ELSE IF @GH_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @GeneralHeadingObjectName, NULL)
-- Heading ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_GeneralHeading WHERE GH_ID = @GH_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@GH_ID AS varchar), @GeneralHeadingObjectName)
-- Heading belongs to Member ?
END ELSE IF NOT EXISTS(SELECT *
		FROM CIC_Publication pb INNER JOIN CIC_GeneralHeading gh ON pb.PB_ID=gh.PB_ID
		WHERE GH_ID=@GH_ID AND ((pb.MemberID IS NULL AND (@SuperUserGlobal=1 OR pb.CanEditHeadingsShared=1)) OR pb.MemberID=@MemberID)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE IF @PB_ID IS NOT NULL AND NOT EXISTS(SELECT * 
		FROM CIC_GeneralHeading gh WHERE PB_ID=@PB_ID AND GH_ID=@GH_ID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @GeneralHeadingObjectName, NULL)
END ELSE BEGIN
	BEGIN TRAN DeleteGHTran
	DELETE CIC_GeneralHeading_Related
		WHERE (RelatedGH_ID = @GH_ID)
	DELETE CIC_GeneralHeading
		WHERE (GH_ID = @GH_ID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @GeneralHeadingObjectName, @ErrMsg
	IF @Error <> 0 BEGIN
		ROLLBACK TRAN
	END ELSE BEGIN
		COMMIT TRAN DeleteGHTran
	END
END

RETURN @Error

SET NOCOUNT OFF





GO

GRANT EXECUTE ON  [dbo].[sp_CIC_GeneralHeading_d] TO [cioc_login_role]
GO
