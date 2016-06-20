SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToGeneralHeadings_rst](
	@MemberID int,
	@NUM varchar(8),
	@PB_ID int,
	@NonPublic bit
)
RETURNS @GeneralHeadings TABLE (
	[GH_ID] int NOT NULL,
	[GeneralHeading] nvarchar(200) COLLATE Latin1_General_100_CI_AI NOT NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 15-Sep-2013
	Action: NO ACTION REQUIRED
*/

DECLARE	@BT_PB_ID int

IF @PB_ID IS NOT NULL BEGIN
	SELECT @BT_PB_ID = BT_PB_ID FROM CIC_BT_PB WHERE NUM=@NUM AND PB_ID=@PB_ID
	IF @BT_PB_ID IS NOT NULL BEGIN
		INSERT INTO @GeneralHeadings 
		SELECT gh.GH_ID, CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END AS GeneralHeading
			FROM CIC_BT_PB_GH pr
			INNER JOIN CIC_GeneralHeading gh
				ON pr.GH_ID=gh.GH_ID
			LEFT JOIN CIC_GeneralHeading_Name ghn
				ON gh.GH_ID=ghn.GH_ID AND ghn.LangID=@@LANGID
		WHERE BT_PB_ID=@BT_PB_ID
			AND (@NonPublic=1 OR NonPublic=0)
			AND CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END IS NOT NULL
		ORDER BY gh.DisplayOrder, ghn.Name
	END
END

RETURN

END





GO
GRANT SELECT ON  [dbo].[fn_CIC_NUMToGeneralHeadings_rst] TO [cioc_cic_search_role]
GO
