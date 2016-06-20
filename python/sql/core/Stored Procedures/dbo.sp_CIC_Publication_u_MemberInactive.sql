SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Publication_u_MemberInactive]
	@MemberID int,
	@HiddenPubs varchar(max),
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

DECLARE @MemberObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')


-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Publication ID exists ?
END

IF @Error = 0 BEGIN
	MERGE INTO CIC_Publication_InactiveByMember pub
	USING (SELECT ItemID AS PB_ID FROM 
			dbo.fn_GBL_ParseIntIDList(@HiddenPubs, ',') nt
			INNER JOIN CIC_Publication pb
				ON pb.PB_ID=nt.ItemID AND pb.MemberID IS NULL) nt
	ON nt.PB_ID=pub.PB_ID AND pub.MemberID=@MemberID
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (PB_ID, MemberID) VALUES (nt.PB_ID, @MemberID)
	WHEN NOT MATCHED BY SOURCE AND pub.MemberID=@MemberID THEN
		DELETE
		;
END

RETURN @Error

SET NOCOUNT OFF















GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Publication_u_MemberInactive] TO [cioc_login_role]
GO
