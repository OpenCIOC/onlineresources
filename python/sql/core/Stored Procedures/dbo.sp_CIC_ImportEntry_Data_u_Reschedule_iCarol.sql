SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Data_u_Reschedule_iCarol]
	@MemberID INT,
	@ER_ID_List VARCHAR(MAX),
	@ErrMsg NVARCHAR(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON


DECLARE @Error INT

SET @Error = 0
SET @ErrMsg = NULL

DECLARE	@MemberObjectName	NVARCHAR(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS VARCHAR), @MemberObjectName)
	SET @MemberID = NULL
END

SELECT @Error AS Error, @ErrMsg AS ErrMsg

IF @Error=0 BEGIN

	UPDATE ir SET DATE_MODIFIED=GETDATE()
	FROM dbo.CIC_iCarolImportRollup ir
	INNER JOIN dbo.CIC_ImportEntry_Data ied
		ON ir.ResourceAgencyNum=ied.EXTERNAL_ID
	INNER JOIN dbo.CIC_ImportEntry ie
		ON ie.EF_ID = ied.EF_ID
	INNER JOIN dbo.fn_GBL_ParseIntIDList(@ER_ID_List, ',') l
		ON ied.ER_ID=l.ItemID
	WHERE ie.SourceDbCode='ICAROL' AND ie.MemberID=@MemberID
END

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Data_u_Reschedule_iCarol] TO [cioc_login_role]
GO
