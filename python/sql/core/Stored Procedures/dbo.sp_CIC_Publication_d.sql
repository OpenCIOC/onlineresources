SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Publication_d]
	@PB_ID int,
	@MemberID int,
	@SuperUserGlobal bit,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 31-May-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@PublicationObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @PublicationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Publication')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Publication ID given ?
END ELSE IF @PB_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, NULL)
-- Publication ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_Publication WHERE PB_ID=@PB_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PB_ID AS varchar), @PublicationObjectName)
-- Publication can be edited by Member ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_Publication WHERE PB_ID=@PB_ID AND (MemberID=@MemberID OR (MemberID IS NULL AND @SuperUserGlobal=1))) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Publication in use by records ?
END ELSE IF EXISTS (SELECT * FROM CIC_BT_PB WHERE PB_ID=@PB_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record'))
-- Publication in use by Views ?
END ELSE IF EXISTS(SELECT * FROM CIC_View WHERE PB_ID=@PB_ID) BEGIN
	SET @Error = 7 -- Can't delete value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, cioc_shared.dbo.fn_SHR_STP_ObjectName('View'))
END ELSE BEGIN
	BEGIN TRAN DeletePBTran
	
	DELETE ghr
		FROM CIC_GeneralHeading_Related ghr
		INNER JOIN CIC_GeneralHeading gh
			ON ghr.RelatedGH_ID=gh.GH_ID AND gh.PB_ID=@PB_ID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg
	
	IF @Error = 0 BEGIN
		DELETE CIC_GeneralHeading_Group
			WHERE PB_ID=@PB_ID
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg
	END
	
	IF @Error <> 0 BEGIN
		ROLLBACK TRAN
	END ELSE BEGIN
		COMMIT TRAN DeletePBTran
	END
	
	IF @Error = 0 BEGIN
		DELETE CIC_Publication WHERE PB_ID=@PB_ID
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg
	END
END

RETURN @Error

SET NOCOUNT OFF







GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_d] TO [cioc_login_role]
GO
