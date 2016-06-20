SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMTaxonomy_sf]
	@User_ID [int],
	@ViewType [int],
	@NUM [varchar](8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 03-Oct-2013
	Action: NO ACTION REQUIRED
*/

/* Select basic information about this record:
   Organization name, Taxonomy data management fields, Can the user index the record? */
SELECT dbo.fn_CIC_CanIndexRecord(bt.NUM, @User_ID, @ViewType, @@LANGID, GETDATE()) AS CAN_INDEX, 
	cioc_shared.dbo.fn_SHR_GBL_DateString(cbt.TAX_MODIFIED_DATE) AS TAX_MODIFIED_DATE, cbt.TAX_MODIFIED_BY,
	dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM AND btd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=btd.NUM ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	INNER JOIN CIC_BaseTable cbt
		ON bt.NUM=cbt.NUM
WHERE bt.NUM=@NUM

/* Select this list of linked term sets used by this record */
SELECT tlt.*, tmd.Term
	FROM CIC_BT_TAX tl
	INNER JOIN CIC_BT_TAX_TM tlt
		ON tlt.BT_TAX_ID=tl.BT_TAX_ID
	INNER JOIN TAX_Term tm
		ON tlt.Code=tm.Code
	INNER JOIN TAX_Term_Description tmd
		ON tm.Code=tmd.Code AND tmd.LangID=(SELECT TOP 1 LangID FROM TAX_Term_Description WHERE tmd.Code=Code ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE tl.NUM=@NUM
ORDER BY dbo.fn_CIC_NUMToTaxTerms_Link(tlt.BT_TAX_ID,@@LANGID)

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMTaxonomy_sf] TO [cioc_login_role]
GO
