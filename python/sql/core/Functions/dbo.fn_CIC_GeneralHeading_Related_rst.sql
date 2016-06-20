SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_GeneralHeading_Related_rst](
	@GH_ID int,
	@NonPublic bit,
	@AnyLanguage bit
)
RETURNS @GeneralHeadings TABLE (
	[GeneralHeading] nvarchar(200) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 09-Oct-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @GeneralHeadings
SELECT ISNULL(CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE CASE WHEN ghn.LangID=@@LANGID THEN ghn.Name ELSE '[' + ghn.Name + ']' END END,'[' + cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ']') AS GeneralHeading
	FROM CIC_GeneralHeading_Related rt
	INNER JOIN CIC_GeneralHeading gh
		ON rt.RelatedGH_ID = gh.GH_ID
	LEFT JOIN CIC_GeneralHeading_Name ghn
		ON gh.GH_ID=ghn.GH_ID
			AND ghn.LangID = CASE WHEN @AnyLanguage=1
				THEN (SELECT TOP 1 LangID FROM CIC_GeneralHeading_Name WHERE GH_ID=gh.GH_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
				ELSE @@LANGID
			END
WHERE rt.GH_ID = @GH_ID
	AND (@NonPublic=1 OR NonPublic=0)
	AND (gh.TaxonomyName=1 OR ghn.GH_ID IS NOT NULL)
ORDER BY ghn.Name

RETURN
END
GO
