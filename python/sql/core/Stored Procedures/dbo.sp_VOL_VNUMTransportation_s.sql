
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_VNUMTransportation_s]
	@MemberID int,
	@VNUM varchar(10)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

SELECT trp.TRP_ID, CASE WHEN trpn.LangID=@@LANGID THEN trpn.Name ELSE '[' + trpn.Name + ']' END AS TransportationType, prn.Notes,
		CASE WHEN pr.VNUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED
	FROM VOL_Transportation trp
	INNER JOIN VOL_Transportation_Name trpn
		ON trp.TRP_ID=trpn.TRP_ID AND trpn.LangID=(SELECT TOP 1 LangID FROM VOL_Transportation_Name WHERE TRP_ID=trpn.TRP_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN VOL_OP_TRP pr 
		ON trp.TRP_ID = pr.TRP_ID AND pr.VNUM=@VNUM
	LEFT JOIN VOL_OP_TRP_Notes prn
		ON pr.OP_TRP_ID=prn.OP_TRP_ID AND prn.LangID=@@LANGID
	LEFT JOIN VOL_Opportunity vo
		ON pr.VNUM=vo.VNUM
WHERE pr.OP_TRP_ID IS NOT NULL
	OR trp.MemberID=vo.MemberID
	OR trp.MemberID=@MemberID
	OR (trp.MemberID IS NULL AND (
		NOT EXISTS(SELECT * FROM VOL_Transportation_InactiveByMember WHERE TRP_ID=trp.TRP_ID AND MemberID=ISNULL(vo.MemberID, @MemberID))
	))
ORDER BY trp.DisplayOrder, trpn.Name

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMTransportation_s] TO [cioc_login_role]
GO
GRANT EXECUTE ON  [dbo].[sp_VOL_VNUMTransportation_s] TO [cioc_vol_search_role]
GO
