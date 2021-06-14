SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMTaxonomy_ct_l]
	@NUMS [varchar](max)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE @Terms TABLE (
    Codes VARCHAR(500),
	Terms NVARCHAR(MAX)
)

/* SELECT The linked Terms (and linked term names) that are associated with the passed in list of NUMs */
INSERT INTO @Terms
SELECT 
  dbo.fn_CIC_NUMToTaxCodes_Link(pr.BT_TAX_ID),
  dbo.fn_CIC_NUMToTaxTerms_Link(pr.BT_TAX_ID,@@LANGID)
FROM CIC_BT_TAX pr
INNER JOIN dbo.fn_GBL_ParseVarCharIDList2(@NUMS, ',') AS n
	ON pr.NUM=n.ItemID COLLATE Latin1_General_100_CI_AI

SELECT DISTINCT Codes, Terms FROM @Terms ORDER BY Codes

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMTaxonomy_ct_l] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMTaxonomy_ct_l] TO [cioc_login_role]
GO
