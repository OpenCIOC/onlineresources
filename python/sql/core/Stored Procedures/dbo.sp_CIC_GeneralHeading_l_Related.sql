SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_GeneralHeading_l_Related]
	@GH_ID [int],
	@PB_ID [int]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 09-Oct-2012
	Action: NO ACTION REQUIRED
*/

SELECT	gh.GH_ID,
		ISNULL(CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END,'[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ']') AS Name
	FROM CIC_GeneralHeading gh
	LEFT JOIN CIC_GeneralHeading_Name ghn
		ON ghn.GH_ID=gh.GH_ID AND ghn.LangID=(SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=gh.GH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE gh.PB_ID=@PB_ID AND (@GH_ID IS NULL OR @GH_ID<>gh.GH_ID)
ORDER BY gh.DisplayOrder, Name

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_CIC_GeneralHeading_l_Related] TO [cioc_login_role]
GO
