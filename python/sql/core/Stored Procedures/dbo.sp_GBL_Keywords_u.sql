SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Keywords_u]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.2
	Checked by: CL
	Checked on: 20-Oct-2014
	Action: NO ACTION REQUIRED
*/

MERGE INTO GBL_Keywords dst
USING (
SELECT bt.MemberID, other.* 
FROM
	(
	SELECT NUM, LangID, NAME
	FROM (SELECT NUM, LangID, ORG_LEVEL_1, ORG_LEVEL_2, ORG_LEVEL_3, ORG_LEVEL_4, ORG_LEVEL_5, LOCATION_NAME, SERVICE_NAME_LEVEL_1, SERVICE_NAME_LEVEL_2, LEGAL_ORG FROM dbo.GBL_BaseTable_Description WHERE DELETION_DATE IS NULL) btd
	UNPIVOT (
	NAME FOR FIELD IN (ORG_LEVEL_1, ORG_LEVEL_2, ORG_LEVEL_3, ORG_LEVEL_4, ORG_LEVEL_5, LOCATION_NAME, SERVICE_NAME_LEVEL_1, SERVICE_NAME_LEVEL_2, LEGAL_ORG)
	) x
	UNION SELECT ao.NUM, ao.LangID, ao.ALT_ORG COLLATE Latin1_General_100_CI_AI
	FROM dbo.GBL_BT_ALTORG ao
	INNER JOIN dbo.GBL_BaseTable_Description btd
	ON btd.NUM = ao.NUM AND btd.LangID = ao.LangID AND btd.DELETION_DATE IS NULL
	UNION SELECT fo.NUM, fo.LangID, fo.FORMER_ORG COLLATE Latin1_General_100_CI_AI
	FROM dbo.GBL_BT_FORMERORG fo
	INNER JOIN dbo.GBL_BaseTable_Description btd
	ON btd.NUM = fo.NUM AND btd.LangID = fo.LangID AND btd.DELETION_DATE IS NULL
	) other
	INNER JOIN GBL_BaseTable bt
		ON bt.NUM=other.NUM
) src
	ON dst.KeywordType='O' AND src.Name=dst.Name AND src.LangID=dst.LangID AND src.MemberID=dst.MemberID AND src.NUM=dst.NUM

WHEN NOT MATCHED BY TARGET THEN 
	INSERT (MemberID, NUM, LangID, Name, KeywordType) VALUES (src.MemberID, src.NUM, src.LangID, src.Name, 'O')

WHEN NOT MATCHED BY SOURCE AND dst.KeywordType='O' THEN 
	DELETE
	;

MERGE INTO GBL_Keywords dst
USING (
	SELECT DISTINCT tmd.Term AS Name, LangID FROM TAX_Term tm
		INNER JOIN TAX_Term_Description tmd ON tm.Code=tmd.Code
		WHERE Active=1 AND EXISTS(SELECT * FROM CIC_BT_TAX pr INNER JOIN CIC_BT_TAX_TM prt ON pr.BT_TAX_ID=prt.BT_TAX_ID AND prt.Code=tm.Code INNER JOIN GBL_BaseTable_Description btd ON pr.NUM=btd.NUM AND btd.LangID=tmd.LangID)
) src
	ON dst.KeywordType='T' AND src.Name=dst.Name AND dst.LangID=src.LangID

WHEN NOT MATCHED BY TARGET THEN 
	INSERT ( LangID, Name, KeywordType) VALUES (src.LangID, src.Name, 'T')

WHEN NOT MATCHED BY SOURCE AND dst.KeywordType='T' THEN 
	DELETE
	;

MERGE INTO GBL_Keywords dst
USING (
	SELECT sjn.Name, sjn.LangID FROM THS_Subject sj INNER JOIN THS_Subject_Name sjn ON sj.Subj_ID=sjn.Subj_ID
	WHERE sj.Authorized=1 AND Used=1 AND EXISTS(SELECT * FROM CIC_BT_SBJ pr INNER JOIN GBL_BaseTable bt ON pr.NUM=bt.NUM INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM AND btd.LangID=sjn.LangID WHERE pr.Subj_ID=sj.Subj_ID)
) src
	ON dst.KeywordType='S' AND src.Name=dst.Name AND dst.LangID=src.LangID

WHEN NOT MATCHED BY TARGET THEN 
	INSERT (LangID, Name, KeywordType) VALUES (src.LangID, src.Name, 'S')

WHEN NOT MATCHED BY SOURCE AND dst.KeywordType='S' THEN 
	DELETE
	;


SET NOCOUNT OFF




GO
