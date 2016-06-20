SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_STP_StartFullTextIndex]
WITH EXECUTE AS CALLER
AS

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

EXEC sp_fulltext_table CIC_BaseTable_Description, 'Start_change_tracking'
EXEC sp_fulltext_table CIC_BaseTable_Description, 'Start_background_updateindex'
EXEC sp_fulltext_table GBL_BaseTable_Description, 'Start_change_tracking'
EXEC sp_fulltext_table GBL_BaseTable_Description, 'Start_background_updateindex'
EXEC sp_fulltext_table GBL_BT_ALTORG, 'Start_change_tracking'
EXEC sp_fulltext_table GBL_BT_ALTORG, 'Start_background_updateindex'
EXEC sp_fulltext_table GBL_BT_FORMERORG, 'Start_change_tracking'
EXEC sp_fulltext_table GBL_BT_FORMERORG, 'Start_background_updateindex'
EXEC sp_fulltext_table NAICS_Description, 'Start_change_tracking'
EXEC sp_fulltext_table NAICS_Description, 'Start_background_updateindex'
EXEC sp_fulltext_table TAX_RelatedConcept_Name, 'Start_change_tracking'
EXEC sp_fulltext_table TAX_RelatedConcept_Name, 'Start_background_updateindex'
EXEC sp_fulltext_table TAX_Term_Description, 'Start_change_tracking'
EXEC sp_fulltext_table TAX_Term_Description, 'Start_background_updateindex'
EXEC sp_fulltext_table TAX_Unused, 'Start_change_tracking'
EXEC sp_fulltext_table TAX_Unused, 'Start_background_updateindex'
EXEC sp_fulltext_table THS_Subject_Name, 'Start_change_tracking'
EXEC sp_fulltext_table THS_Subject_Name, 'Start_background_updateindex'
EXEC sp_fulltext_table VOL_Interest_Name, 'Start_change_tracking'
EXEC sp_fulltext_table VOL_Interest_Name, 'Start_background_updateindex'
EXEC sp_fulltext_table VOL_Opportunity_Description, 'Start_change_tracking'
EXEC sp_fulltext_table VOL_Opportunity_Description, 'Start_background_updateindex'
GO
