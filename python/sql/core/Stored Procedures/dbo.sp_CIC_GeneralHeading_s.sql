
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_GeneralHeading_s]
	@MemberID int,
	@AgencyCode char(3),
	@GH_ID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 09-Oct-2012
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
-- Template belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM CIC_Publication pb INNER JOIN CIC_GeneralHeading gh ON pb.PB_ID=gh.PB_ID AND gh.GH_ID=@GH_ID WHERE (MemberID=@MemberID OR MemberID IS NULL) AND (Owner IS NULL OR Owner=@AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
END

SELECT *,
		ISNULL(CASE
			WHEN gh.TaxonomyName=1
				THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID)
				ELSE (SELECT TOP 1 ghn.Name FROM CIC_GeneralHeading_Name ghn WHERE ghn.GH_ID=gh.GH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			END,'[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ']') AS CurrentDisplayName,
		(SELECT COUNT(*) FROM CIC_BT_PB_GH pbgh INNER JOIN CIC_BT_PB btpb ON btpb.BT_PB_ID = pbgh.BT_PB_ID INNER JOIN GBL_BaseTable bt ON btpb.NUM=bt.NUM WHERE GH_ID=@GH_ID AND bt.MemberID=@MemberID) AS UsageCountLocal,
		(SELECT COUNT(*) FROM CIC_BT_PB_GH pbgh INNER JOIN CIC_BT_PB btpb ON btpb.BT_PB_ID = pbgh.BT_PB_ID INNER JOIN GBL_BaseTable bt ON btpb.NUM=bt.NUM WHERE GH_ID=@GH_ID AND bt.MemberID <> @MemberID) AS UsageCountOther,
		(SELECT PubCode FROM CIC_Publication WHERE PB_ID=gh.PB_ID) AS PubCode
	FROM CIC_GeneralHeading gh
WHERE GH_ID=@GH_ID
	AND EXISTS(SELECT * FROM CIC_Publication pb WHERE pb.PB_ID=gh.PB_ID
			AND (MemberID=@MemberID OR MemberID IS NULL)
			AND (Owner IS NULL OR Owner=@AgencyCode)
		)
	
SELECT n.*, l.Culture
	FROM CIC_GeneralHeading_Name n
	INNER JOIN STP_Language l
		ON l.LangID=n.LangID
WHERE GH_ID=@GH_ID

SELECT RelatedGH_ID
	FROM CIC_GeneralHeading_Related
WHERE GH_ID=@GH_ID

SELECT ght.GH_TAX_ID, MatchAny, tm.Code
	FROM CIC_GeneralHeading_TAX ght
	INNER JOIN CIC_GeneralHeading_TAX_TM tm
		ON ght.GH_TAX_ID=tm.GH_TAX_ID
WHERE ght.GH_ID=@GH_ID
ORDER BY MatchAny, (SELECT TOP 1 ISNULL(tmd.AltTerm,tmd.Term)
		FROM CIC_GeneralHeading_TAX_TM tm2
		INNER JOIN TAX_Term_Description tmd
			ON tm2.Code=tmd.Code AND tmd.LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE tmd.Code=Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
		WHERE tm2.GH_TAX_ID=ght.GH_TAX_ID
		ORDER BY tm2.Code),
		ght.GH_TAX_ID, tm.Code

RETURN @Error

SET NOCOUNT OFF






GO

GRANT EXECUTE ON  [dbo].[sp_CIC_GeneralHeading_s] TO [cioc_login_role]
GO
