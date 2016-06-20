SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommunitySet_lr]
	@MemberID int,
	@VNUM varchar(10)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Apr-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT	cs.MemberID, ISNULL(memd.MemberNameVOL,memd.MemberName) AS MemberName,
		cs.CommunitySetID, csn.SetName, CASE WHEN pr.CommunitySetID IS NULL THEN 0 ELSE 1 END AS RecordUses
	FROM VOL_CommunitySet cs
	INNER JOIN VOL_CommunitySet_Name csn
		ON cs.CommunitySetID=csn.CommunitySetID AND LangID=(SELECT TOP 1 LangID FROM VOL_CommunitySet_Name WHERE csn.CommunitySetID=CommunitySetID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN VOL_OP_CommunitySet pr
		ON cs.CommunitySetID=pr.CommunitySetID AND VNUM=@VNUM
	LEFT JOIN STP_Member_Description memd
		ON cs.MemberID=memd.MemberID AND memd.LangID=(SELECT TOP 1 LangID FROM STP_Member_Description WHERE MemberID=cs.MemberID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE cs.MemberID=@MemberID
	OR pr.CommunitySetID IS NOT NULL
ORDER BY SetName

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunitySet_lr] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunitySet_lr] TO [cioc_vol_search_role]
GO
