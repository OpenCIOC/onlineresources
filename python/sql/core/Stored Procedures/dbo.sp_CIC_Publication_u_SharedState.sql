SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Publication_u_SharedState]
	@PB_ID int,
	@Shared bit,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 19-Jan-2012
	Action: NO ACTION REQUIRED
*/
DECLARE	@Error		int
SET @Error = 0

DECLARE @PublicationObjectName nvarchar(100)

SET @PublicationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Publication')


-- Publication ID given ?
IF @PB_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, NULL)
-- Publication ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM CIC_Publication WHERE PB_ID=@PB_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PB_ID AS varchar), @PublicationObjectName)
END ELSE IF @Shared = 0 AND (SELECT COUNT(*) FROM STP_Member m WHERE NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE MemberID=m.MemberID AND PB_ID=@PB_ID)) <> 1 BEGIN
	SET @Error = 6 -- Value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PB_ID AS varchar), @PublicationObjectName)
END

IF @Error = 0 BEGIN
	IF @Shared = 0 BEGIN
		DECLARE @LocalMemberID int
		SELECT TOP 1 @LocalMemberID = MemberID FROM STP_Member m WHERE NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE MemberID=m.MemberID AND PB_ID=@PB_ID)
		UPDATE CIC_Publication SET MemberID=@LocalMemberID WHERE PB_ID=@PB_ID
	END ELSE BEGIN
		UPDATE CIC_Publication SET MemberID=NULL WHERE PB_ID=@PB_ID
	END
END

RETURN @Error

SET NOCOUNT OFF















GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_u_SharedState] TO [cioc_login_role]
GO
