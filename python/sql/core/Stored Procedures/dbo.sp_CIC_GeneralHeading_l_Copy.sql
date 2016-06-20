SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_GeneralHeading_l_Copy]
	@MemberID int,
	@SuperUserGlobal bit,
	@PB_ID int,
	@CopyPBID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 09-Oct-2012
	Action: NO ACTION REQUIRED
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

SELECT pb.PubCode, pbn.Name AS PubName
	FROM CIC_Publication pb
	LEFT JOIN CIC_Publication_Name pbn
		ON pb.PB_ID=pbn.PB_ID AND pbn.LangID=@@LANGID
WHERE (@SuperUserGlobal=1 OR pb.MemberID IS NULL OR pb.MemberID=@MemberID)
	AND pb.PB_ID=@PB_ID

SELECT pb.PubCode, pbn.Name AS PubName
	FROM CIC_Publication pb
	LEFT JOIN CIC_Publication_Name pbn
		ON pb.PB_ID=pbn.PB_ID AND pbn.LangID=@@LANGID
WHERE (@SuperUserGlobal=1 OR pb.MemberID IS NULL OR pb.MemberID=@MemberID)
	AND pb.PB_ID=@CopyPBID
	
DECLARE @CopyGHTable TABLE (
	GH_ID int NOT NULL PRIMARY KEY,
	GeneralHeading nvarchar(MAX) NOT NULL,
	DisplayOrder tinyint
)

INSERT INTO @CopyGHTable (GH_ID, DisplayOrder, GeneralHeading)
SELECT gh.GH_ID, gh.DisplayOrder, CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END AS GeneralHeading
	FROM CIC_GeneralHeading gh
	LEFT JOIN CIC_GeneralHeading_Name ghn
		ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=ghn.GH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE gh.PB_ID=@CopyPBID
	AND (gh.Used=1 OR gh.Used IS NULL)
	AND CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END IS NOT NULL

SELECT gh.GH_ID, gh.GeneralHeading, gx.GH_ID AS CopyGHID
	FROM @CopyGHTable gh
	LEFT JOIN (
			SELECT gh2.GH_ID, CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh2.GH_ID, @@LANGID) ELSE ghn.Name END AS GeneralHeading
			FROM CIC_GeneralHeading gh2
			LEFT JOIN CIC_GeneralHeading_Name ghn
				ON gh2.GH_ID=ghn.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=ghn.GH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			WHERE gh2.PB_ID=@PB_ID
			) gx
		ON gx.GeneralHeading=gh.GeneralHeading
ORDER BY gh.DisplayOrder, gh.GeneralHeading

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_GeneralHeading_l_Copy] TO [cioc_login_role]
GO
