SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Data_Owner_l]
	@MemberID int,
	@EF_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.1
	Checked by: KL
	Checked on: 04-Mar-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
-- Import Entry belongs to Member ?
END ELSE IF EXISTS(SELECT * FROM CIC_ImportEntry WHERE EF_ID=@EF_ID AND MemberID<>@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @MemberID = NULL
END

SELECT DISTINCT OWNER
	FROM CIC_ImportEntry_Data ied
	LEFT JOIN GBL_BaseTable bt
		ON bt.NUM=ied.NUM
WHERE (bt.MemberID=@MemberID OR bt.MemberID IS NULL)
	AND ied.EF_ID=@EF_ID
	AND ied.DATA IS NOT NULL
	
RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Data_Owner_l] TO [cioc_login_role]
GO
