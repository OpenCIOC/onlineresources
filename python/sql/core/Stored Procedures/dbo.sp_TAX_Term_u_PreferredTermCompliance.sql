
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_Term_u_PreferredTermCompliance]
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@AutoFixList varchar(max)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.3
	Checked by: KL
	Checked on: 01-May-2015
	Action: NO ACTION REQUIRED
*/

DECLARE @TAXONOMY int, @NUM varchar(8), @MODIFIED_DATE datetime

SELECT @TAXONOMY=FieldID FROM GBL_FieldOption WHERE FieldName='TAXONOMY'

SET @MODIFIED_DATE = GETDATE()

DECLARE @AutoFixCodes TABLE (
	Code varchar(21) COLLATE Latin1_General_100_CI_AI NOT NULL PRIMARY KEY,
	AutoFixType char(1),
	AutoFixCode varchar(21) COLLATE Latin1_General_100_CI_AI NULL
)

INSERT INTO @AutoFixCodes (Code, AutoFixType, AutoFixCode)
SELECT tm.Code,
		CASE
			WHEN (tm.Active=0 OR am.Code IS NULL) AND tm.PreferredTerm=1 THEN 'A'
			WHEN tmauto.Code IS NOT NULL THEN 'R'
			WHEN tm.PreferredTerm=0 AND NOT EXISTS(SELECT * FROM CIC_BT_TAX_TM ttm INNER JOIN CIC_BT_TAX ttl ON ttl.BT_TAX_ID = ttm.BT_TAX_ID INNER JOIN GBL_BaseTable bt ON bt.NUM=ttl.NUM WHERE Code=tm.Code AND MemberID=@MemberID) THEN 'I'
			ELSE NULL
		END AS AutoFixType,
		tmauto.Code AS AutoFixCode
	FROM TAX_Term tm
	LEFT JOIN TAX_Term tmauto
		ON tmauto.Code=(SELECT MAX(Code) FROM TAX_Term tm2 WHERE tm2.PreferredTerm=1 AND tm2.CdLvl < tm.CdLvl AND tm2.CdLvl1=tm.CdLvl1 AND tm.Code LIKE tm2.Code + '%')
	INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@AutoFixList,',') fl
		ON tm.Code=fl.ItemID COLLATE Latin1_General_100_CI_AI
	LEFT JOIN TAX_Term_ActivationByMember am
		ON am.Code = tm.Code AND am.MemberID=@MemberID
WHERE (tm.PreferredTerm=0 AND (tm.Active=1 OR am.Code IS NOT NULL)
			AND (
				EXISTS(SELECT * FROM TAX_Term tm2 WHERE tm2.PreferredTerm=1
					AND (
						(tm2.CdLvl > tm.CdLvl AND tm2.CdLvl1=tm.CdLvl1 AND tm2.Code LIKE tm.Code + '%')
						OR (tm2.CdLvl < tm.CdLvl AND tm2.CdLvl1=tm.CdLvl1 AND tm.Code LIKE tm2.Code + '%')
						)
					)
				OR EXISTS(SELECT * FROM TAX_Term tm2 WHERE tm2.PreferredTerm=1
					AND tm2.ParentCode=tm.ParentCode
					)
			)
		)
	OR (tm.PreferredTerm=1 AND (tm.Active=0 OR am.Code IS NULL))
ORDER BY Code

DELETE FROM @AutoFixCodes WHERE AutoFixType IS NULL

UPDATE tm SET Active=1
	FROM TAX_Term tm
	INNER JOIN @AutoFixCodes tmauto
		ON (tm.Code=tmauto.AutoFixCode AND tmauto.AutoFixType='R')
			OR (tm.Code=tmauto.Code AND tmauto.AutoFixType='A')
WHERE Active=0

-- Local Activation
INSERT INTO TAX_Term_ActivationByMember
		(MemberID, Code)
SELECT DISTINCT @MemberID, tm.Code
	FROM TAX_Term tm
	INNER JOIN @AutoFixCodes tmauto
		ON (tm.Code=tmauto.AutoFixCode AND tmauto.AutoFixType='R')
			OR (tm.Code=tmauto.Code AND tmauto.AutoFixType='A')
WHERE NOT EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE MemberID=@MemberID AND Code=tm.Code)

DECLARE @RollUpNUMs TABLE (
	NUM varchar(8) PRIMARY KEY NOT NULL
)

INSERT INTO @RollUpNUMs ( NUM )
SELECT DISTINCT pr.NUM FROM dbo.CIC_BT_TAX pr
INNER JOIN CIC_BT_TAX_TM tlc
	ON tlc.BT_TAX_ID = pr.BT_TAX_ID
INNER JOIN @AutoFixCodes tmauto
	ON tlc.Code=tmauto.Code AND tmauto.AutoFixType='R'
INNER JOIN GBL_BaseTable bt
	ON bt.NUM=pr.NUM AND bt.MemberID=@MemberID
WHERE pr.BT_TAX_ID NOT IN (
	SELECT DISTINCT tl.BT_TAX_ID FROM CIC_BT_TAX tl
	INNER JOIN dbo.CIC_BT_TAX_TM tlt ON tlt.BT_TAX_ID = tl.BT_TAX_ID AND tlt.Code LIKE tmauto.AutoFixCode + '%'
	GROUP BY tl.BT_TAX_ID, tl.NUM
	HAVING COUNT(*) > 1
)

UPDATE tlc
	SET Code=tmauto.AutoFixCode
FROM CIC_BT_TAX_TM tlc
INNER JOIN @AutoFixCodes tmauto
	ON tlc.Code=tmauto.Code AND tmauto.AutoFixType='R'
INNER JOIN dbo.CIC_BT_TAX pr
	ON pr.BT_TAX_ID = tlc.BT_TAX_ID
INNER JOIN GBL_BaseTable bt
	ON bt.NUM=pr.NUM AND bt.MemberID=@MemberID
WHERE tlc.BT_TAX_ID NOT IN (
	SELECT DISTINCT tl.BT_TAX_ID FROM CIC_BT_TAX tl
	INNER JOIN dbo.CIC_BT_TAX_TM tlt ON tlt.BT_TAX_ID = tl.BT_TAX_ID AND tlt.Code LIKE tmauto.AutoFixCode + '%'
	GROUP BY tl.BT_TAX_ID, tl.NUM
	HAVING COUNT(*) > 1
)
	
UPDATE cbt
	SET TAX_MODIFIED_DATE	= GETDATE(),
		TAX_MODIFIED_BY		= @MODIFIED_BY
FROM dbo.CIC_BaseTable cbt
INNER JOIN @RollUpNUMs rn ON rn.NUM = cbt.NUM

UPDATE cbtd
	SET SRCH_Taxonomy_U = 1
FROM dbo.CIC_BaseTable_Description cbtd
INNER JOIN @RollUpNUMs rn ON rn.NUM = cbtd.NUM

DECLARE @DupTable TABLE (
	NUM varchar(8),
	Link varchar(1000),
	MinBTTAXID int
)

INSERT INTO @DupTable
        ( NUM, Link )
SELECT NUM, dbo.fn_CIC_NUMToTaxCodes_Link(pr.BT_TAX_ID)
FROM CIC_BT_TAX pr
GROUP BY NUM, dbo.fn_CIC_NUMToTaxCodes_Link(pr.BT_TAX_ID)
HAVING COUNT(*) > 1

UPDATE dt
	SET MinBTTAXID=(SELECT MIN(BT_TAX_ID) FROM CIC_BT_TAX pr WHERE pr.NUM=dt.NUM AND dbo.fn_CIC_NUMToTaxCodes_Link(pr.BT_TAX_ID)=dt.Link)
FROM @DupTable dt

DECLARE @DeleteTable TABLE (
	BT_TAX_ID int
)

INSERT INTO @DeleteTable
        ( BT_TAX_ID )
SELECT BT_TAX_ID
	FROM CIC_BT_TAX pr
	INNER JOIN @DupTable dt
		ON pr.NUM=dt.NUM AND dbo.fn_CIC_NUMToTaxCodes_Link(pr.BT_TAX_ID)=dt.Link AND pr.BT_TAX_ID<>dt.MinBTTAXID

DELETE pr
FROM dbo.CIC_BT_TAX pr
INNER JOIN @DeleteTable ON [@DeleteTable].BT_TAX_ID = pr.BT_TAX_ID

UPDATE cbtd 
	SET SRCH_Taxonomy_U=1
FROM dbo.CIC_BaseTable_Description cbtd
WHERE NUM IN (SELECT NUM FROM @DupTable)
	AND SRCH_Taxonomy_U=0

EXEC dbo.sp_CIC_SRCH_TAX_u NULL

DECLARE MyCursor CURSOR STATIC FOR 
	SELECT rn.NUM FROM @RollUpNUMs rn

OPEN MyCursor

FETCH NEXT FROM MyCursor INTO @NUM

WHILE @@FETCH_STATUS = 0 BEGIN
	
	EXEC sp_GBL_BaseTable_History_i @MODIFIED_BY, @MODIFIED_DATE, @NUM, @TAXONOMY, 0, NULL
	
	FETCH NEXT FROM MyCursor INTO @NUM
END

CLOSE MyCursor

DEALLOCATE MyCursor

-- Local deactivation if no records left
DELETE tac
	FROM TAX_Term_ActivationByMember tac
	INNER JOIN TAX_Term tm
		ON tm.Code = tac.Code AND tac.MemberID=@MemberID
	INNER JOIN @AutoFixCodes tmauto
		ON tm.Code=tmauto.Code
			AND tmauto.AutoFixType IN ('R','I')
WHERE NOT EXISTS(SELECT * FROM CIC_BT_TAX_TM ttm INNER JOIN CIC_BT_TAX ttl ON ttl.BT_TAX_ID = ttm.BT_TAX_ID INNER JOIN GBL_BaseTable bt ON bt.NUM=ttl.NUM WHERE Code=tm.Code AND MemberID=@MemberID)

-- Global Deactivation if no records left
UPDATE tm SET Active=0
	FROM TAX_Term tm
	INNER JOIN @AutoFixCodes tmauto
		ON tm.Code=tmauto.Code
			AND tmauto.AutoFixType IN ('R', 'I')
WHERE Active=1 AND PreferredTerm=0
	AND NOT EXISTS(SELECT * FROM CIC_BT_TAX_TM WHERE Code=tm.Code)
	
DELETE tac
	FROM TAX_Term_ActivationByMember tac
WHERE NOT EXISTS(SELECT * FROM TAX_Term tm WHERE tm.Code=tac.Code AND tm.Active=1)

/* Synchronize a local activation in one-member database */
IF (SELECT COUNT(*) FROM STP_Member WHERE Active=1)=1 BEGIN
	DECLARE @TmpMemberID int
	SELECT TOP 1 @TmpMemberID=MemberID FROM STP_Member WHERE Active=1
	
	MERGE INTO TAX_Term_ActivationByMember tac
	USING (SELECT Code FROM TAX_Term WHERE Active=1) nt
		ON nt.Code=tac.Code AND tac.MemberID=@TmpMemberID
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (Code, MemberID) VALUES (nt.Code, @TmpMemberID)
	WHEN NOT MATCHED BY SOURCE AND tac.MemberID=@TmpMemberID THEN
		DELETE
		;
END

SET NOCOUNT OFF


GO




GRANT EXECUTE ON  [dbo].[sp_TAX_Term_u_PreferredTermCompliance] TO [cioc_login_role]
GO
