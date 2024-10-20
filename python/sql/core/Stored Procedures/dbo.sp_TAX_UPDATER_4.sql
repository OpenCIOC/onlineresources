SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_TAX_UPDATER_4] AS
BEGIN

SET NOCOUNT ON

/* Update code mappings according to "old code" table */
DECLARE @MappingTable TABLE (
	Code varchar(21) NOT NULL,
	NewCode varchar(21) NOT NULL,
	OneToOne [bit] NOT NULL DEFAULT 0
)

INSERT INTO @MappingTable (Code, NewCode)
SELECT tm.Code, uoc.Code
	FROM dbo.TAX_Term tm
	INNER JOIN dbo.TAX_U_oldCode uoc
		ON uoc.oldCode=tm.Code
WHERE tm.Authorized=1
	AND NOT EXISTS(SELECT * FROM dbo.TAX_U_Term utt WHERE utt.Code=tm.Code)
ORDER BY tm.Code

UPDATE mt
	SET OneToOne=1
FROM @MappingTable mt
WHERE NOT EXISTS(SELECT * FROM @MappingTable mt2 WHERE mt2.Code=mt.Code AND mt2.NewCode<>mt.NewCode)
	AND NOT EXISTS(SELECT * FROM @MappingTable mt2 WHERE mt2.Code<>mt.Code AND mt2.NewCode=mt.NewCode)

UPDATE tt
	SET Code=mt.NewCode
FROM dbo.CIC_BT_TAX_TM tt
INNER JOIN @MappingTable mt
	ON tt.Code=mt.Code AND mt.OneToOne=1
WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BT_TAX_TM tt2 WHERE tt2.BT_TAX_ID=tt.BT_TAX_ID AND tt2.Code=mt.NewCode)

UPDATE ghtm
	SET Code=mt.NewCode
FROM dbo.CIC_GeneralHeading_TAX_TM ghtm
INNER JOIN @MappingTable mt
	ON ghtm.Code=mt.Code AND mt.OneToOne=1
WHERE NOT EXISTS(SELECT * FROM dbo.CIC_GeneralHeading_TAX_TM ghtm2 WHERE ghtm2.GH_TAX_ID=ghtm.GH_TAX_ID AND ghtm2.Code=mt.NewCode)

DELETE tt
	FROM dbo.CIC_BT_TAX_TM tt
	INNER JOIN @MappingTable mt
		ON tt.Code=mt.Code AND mt.OneToOne=1
WHERE EXISTS(SELECT * FROM dbo.CIC_BT_TAX_TM tt2 WHERE tt2.BT_TAX_ID=tt.BT_TAX_ID AND tt2.Code=mt.NewCode)

UPDATE trc
	SET trc.Code=mt.NewCode
FROM dbo.TAX_TM_RC trc
INNER JOIN @MappingTable mt
	ON trc.Code=mt.Code AND mt.OneToOne=1
WHERE NOT EXISTS(SELECT * FROM dbo.TAX_TM_RC trc2 WHERE trc2.RC_ID=trc.RC_ID AND trc2.Code=mt.NewCode)

DELETE trc
FROM dbo.TAX_TM_RC trc
INNER JOIN @MappingTable mt
	ON trc.Code=mt.Code AND mt.OneToOne=1
WHERE EXISTS(SELECT * FROM dbo.TAX_TM_RC trc2 WHERE trc2.RC_ID=trc.RC_ID AND trc2.Code=mt.NewCode)

UPDATE sa
	SET sa.Code=mt.NewCode
FROM dbo.TAX_SeeAlso sa
INNER JOIN @MappingTable mt
	ON sa.Code=mt.Code AND mt.OneToOne=1
WHERE sa.SA_Code<>mt.NewCode
	AND NOT EXISTS(SELECT * FROM dbo.TAX_SeeAlso WHERE Code=mt.NewCode AND SA_Code=sa.SA_Code)

UPDATE ut
	SET ut.Code=mt.NewCode
FROM dbo.TAX_Unused ut
INNER JOIN @MappingTable mt
	ON ut.Code=mt.Code AND mt.OneToOne=1
WHERE NOT EXISTS(SELECT * FROM dbo.TAX_Unused WHERE Code=mt.Code AND (Term=ut.Term AND LangID=ut.LangID))

UPDATE act
	SET act.Code=mt.NewCode
FROM dbo.TAX_Term_ActivationByMember act
INNER JOIN @MappingTable mt
	ON act.Code=mt.Code AND mt.OneToOne=1
		AND NOT EXISTS(SELECT * FROM dbo.TAX_Term_ActivationByMember act2 WHERE act2.Code=mt.Code AND act2.MemberID=act.MemberID)

/* Ensure all Terms in use are marked as Active */
UPDATE tm
	SET tm.Active=1
FROM dbo.TAX_Term tm
WHERE Active=0 AND EXISTS(SELECT * FROM dbo.CIC_BT_TAX_TM tt WHERE tt.Code=tm.Code)

INSERT INTO dbo.TAX_Term_ActivationByMember (MemberID, Code)
	SELECT DISTINCT bt.MemberID, tt.Code
		FROM dbo.GBL_BaseTable bt
		INNER JOIN dbo.CIC_BT_TAX pr
			ON bt.NUM=pr.NUM
		INNER JOIN dbo.CIC_BT_TAX_TM tt
			ON pr.BT_TAX_ID=tt.BT_TAX_ID
	WHERE NOT EXISTS(SELECT * FROM dbo.TAX_Term_ActivationByMember WHERE MemberID=bt.MemberID AND Code=tt.Code)

SET NOCOUNT OFF

END


GO
GRANT EXECUTE ON  [dbo].[sp_TAX_UPDATER_4] TO [cioc_login_role]
GO
