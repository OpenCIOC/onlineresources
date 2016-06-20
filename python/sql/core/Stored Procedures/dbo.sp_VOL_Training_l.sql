
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Training_l]
	@MemberID [int],
	@ShowHidden [bit]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 19-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID exists ?
IF @MemberID IS NOT NULL AND NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END
SELECT trn.TRN_ID, trnn.Name AS TrainingType
	FROM VOL_Training trn
	INNER JOIN VOL_Training_Name trnn
		ON trn.TRN_ID=trnn.TRN_ID AND trnn.LangID=@@LANGID
WHERE (trn.MemberID IS NULL OR @MemberID IS NULL OR trn.MemberID=@MemberID)
	AND (
		@ShowHidden=1
		OR NOT EXISTS(SELECT * FROM VOL_Training_InactiveByMember WHERE TRN_ID=trn.TRN_ID AND MemberID=@MemberID)
	)
ORDER BY trn.DisplayOrder, trnn.Name

RETURN @Error

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Training_l] TO [cioc_login_role]
GO
