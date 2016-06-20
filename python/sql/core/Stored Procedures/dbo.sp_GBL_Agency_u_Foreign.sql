SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Agency_u_Foreign]
	@MemberID int,
	@ForeignAgencies [varchar](max),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 09-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(60)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Member')

IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE IF NOT EXISTS (SELECT * FROM STP_Member WHERE MemberID = @MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
END ELSE BEGIN
	MERGE INTO STP_Member_ListForeignAgency fa
	USING (SELECT fa.ItemID AS AgencyID
		FROM dbo.fn_GBL_ParseIntIDList(@ForeignAgencies, ',') fa
		INNER JOIN GBL_Agency a
			ON fa.ItemID=a.AgencyID) nt
	ON fa.MemberID=@MemberID AND nt.AgencyID=fa.AgencyID
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (MemberID, AgencyID) VALUES (@MemberID, nt.AgencyID)
	WHEN NOT MATCHED BY SOURCE AND fa.MemberID=@MemberID THEN
		DELETE
	;
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @MemberObjectName, @ErrMsg OUTPUT
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Agency_u_Foreign] TO [cioc_login_role]
GO
