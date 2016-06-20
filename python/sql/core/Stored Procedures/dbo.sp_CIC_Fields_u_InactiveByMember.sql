SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Fields_u_InactiveByMember]
	@MemberID int,
	@HideFields varchar(max),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 15-Apr-2012
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
	MERGE INTO GBL_FieldOption_InactiveByMember ibm
	USING (SELECT ItemID AS FieldID
			FROM dbo.fn_GBL_ParseIntIDList(@HideFields, ',') nt
			INNER JOIN GBL_FieldOption fo
				ON fo.FieldID=nt.ItemID
			WHERE fo.PB_ID IS NULL OR ( 
				EXISTS(SELECT * FROM CIC_Publication pb WHERE pb.PB_ID=fo.PB_ID AND (pb.MemberID IS NULL OR pb.MemberID=@MemberID)) 
				AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember pbi WHERE pbi.PB_ID=fo.PB_ID AND pbi.MemberID=@MemberID) )) nt
		ON nt.FieldID=ibm.FieldID AND ibm.MemberID=@MemberID
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (FieldID, MemberID) VALUES (nt.FieldID, @MemberID)
	WHEN NOT MATCHED BY SOURCE AND ibm.MemberID=@MemberID THEN
		DELETE
		;
END

RETURN @Error

SET NOCOUNT OFF


















GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Fields_u_InactiveByMember] TO [cioc_login_role]
GO
