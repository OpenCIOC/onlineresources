
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMLanguage_s]
	@MemberID int,
	@NUM varchar(8),
	@LNIDs varchar(5000) = NULL
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 11-Aug-2015
	Action: NO ACTION REQUIRED
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

DECLARE @RecordMemberID int
SELECT @RecordMemberID = MemberID FROM GBL_BaseTable WHERE NUM=@NUM

SELECT lnd.LND_ID, ISNULL(lndn.Name,lnd.Code) AS Name, lndn.HelpText
	FROM GBL_Language_Details lnd
	LEFT JOIN GBL_Language_Details_Name lndn
		ON lndn.LND_ID = lnd.LND_ID AND LangID=(SELECT TOP 1 LangID FROM GBL_Language_Details_Name WHERE LND_ID=lnd.LND_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE (lndn.LND_ID IS NOT NULL OR lnd.Code IS NOT NULL)
		AND (
			MemberID=@MemberID
			OR MemberID=@RecordMemberID
			OR (
				MemberID IS NULL
				AND NOT EXISTS(SELECT * FROM GBL_Language_Details_InactiveByMember WHERE MemberID=ISNULL(@RecordMemberID, @MemberID))
			)
			OR EXISTS(SELECT * FROM CIC_BT_LN_LND lnd INNER JOIN CIC_BT_LN ln ON ln.BT_LN_ID = lnd.BT_LN_ID WHERE NUM=@NUM AND lnd.LND_ID=lnd.LND_ID)
		)

SELECT ln.LN_ID, lnn.LangID, ISNULL(lnn.Name,ln.Code) AS LanguageName, prn.Notes,
		CASE WHEN pr.NUM IS NULL THEN 0 ELSE 1 END AS IS_SELECTED,
		STUFF((SELECT ',' + CAST(LND_ID AS varchar) FROM CIC_BT_LN_LND WHERE BT_LN_ID=pr.BT_LN_ID FOR XML PATH(''), TYPE).value('.', 'varchar(max)'), 1, 1, '') AS LNDIDs
	FROM GBL_Language ln
	LEFT JOIN GBL_Language_Name lnn
		ON ln.LN_ID=lnn.LN_ID
			AND lnn.LangID=(SELECT TOP 1 LangID FROM GBL_Language_Name WHERE LN_ID=ln.LN_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN CIC_BT_LN pr 
		ON ln.LN_ID = pr.LN_ID AND pr.NUM=@NUM
	LEFT JOIN CIC_BT_LN_Notes prn
		ON pr.BT_LN_ID=prn.BT_LN_ID AND prn.LangID=@@LANGID
	LEFT JOIN GBL_BaseTable bt
		ON pr.NUM=bt.NUM
WHERE (lnn.LN_ID IS NOT NULL OR ln.Code IS NOT NULL)
	AND (
		pr.BT_LN_ID IS NOT NULL
		OR EXISTS(SELECT * FROM dbo.fn_GBL_ParseIntIDList(@LNIDs, ',') WHERE ItemID=ln.LN_ID)
		OR ln.ShowOnForm=1 AND (
			ln.MemberID=bt.MemberID
			OR ln.MemberID=@MemberID
			OR (ln.MemberID IS NULL AND (
				NOT EXISTS(SELECT * FROM GBL_Language_InactiveByMember WHERE LN_ID=ln.LN_ID AND MemberID=ISNULL(bt.MemberID, @MemberID))
			))
		)
	)
ORDER BY ln.DisplayOrder, lnn.Name

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMLanguage_s] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMLanguage_s] TO [cioc_login_role]
GO
