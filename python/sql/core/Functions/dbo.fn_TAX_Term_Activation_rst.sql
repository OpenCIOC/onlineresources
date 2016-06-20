SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_TAX_Term_Activation_rst](
	@MemberID int,
	@Code varchar(21),
	@GetChildren bit
)
RETURNS @ActivationStatus TABLE (
	Code varchar(21) NOT NULL PRIMARY KEY,
	Active bit NULL,
	CAN_ACTIVATE bit NOT NULL,
	CAN_DEACTIVATE bit NOT NULL,
	CAN_ROLLUP bit NOT NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 10-May-2012
	Action: NO ACTION REQUIRED
*/

IF @MemberID IS NULL BEGIN
	INSERT INTO @ActivationStatus
	SELECT	tm.Code,
			tm.Active,
			CAST(CASE
					WHEN 
					tm.CdLvl > 1
					AND (
						EXISTS(SELECT * FROM TAX_Term WHERE Code=tm.ParentCode AND Active=1)
						OR EXISTS(SELECT * FROM TAX_Term WHERE ParentCode=tm.Code AND Active=1)
						OR (
							NOT EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl>tm.CdLvl AND Code LIKE tm.Code+'%' AND Active=1) 
							AND NOT EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl<tm.CdLvl AND tm.Code LIKE Code+'%' AND Active=1)
						)
					) THEN 1 ELSE 0 END AS bit) AS CAN_ACTIVATE,
			CAST(CASE WHEN NOT EXISTS(SELECT * FROM CIC_BT_TAX_TM WHERE Code=tm.Code)
					AND (
						tm.CdLvl = 6
						OR NOT EXISTS(SELECT * FROM TAX_Term WHERE ParentCode=tm.Code)
						OR EXISTS(SELECT * FROM TAX_Term WHERE Code=tm.ParentCode AND NOT Active=1)
						OR EXISTS(SELECT * FROM TAX_Term WHERE ParentCode=tm.Code AND NOT Active=1)
					)
					THEN 1 ELSE 0 END AS bit) AS CAN_DEACTIVATE,
			CAST(CASE
					WHEN NOT EXISTS(SELECT * FROM CIC_BT_TAX_TM WHERE Code=tm.Code)
						AND EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl<tm.CdLvl AND tm.Code LIKE Code+'%' AND Active=1)
						AND NOT EXISTS(SELECT * FROM TAX_Term WHERE CdLvl1=tm.CdLvl1 AND CdLvl>tm.CdLvl AND Code LIKE tm.Code+'%' AND Active=1)
					THEN 1 ELSE 0 END AS bit) AS CAN_ROLLUP		
		FROM TAX_Term tm
	WHERE (@GetChildren=0 AND tm.Code=@Code)
		OR (@GetChildren=1 AND tm.ParentCode=@Code)
END ELSE BEGIN
	INSERT INTO @ActivationStatus
	SELECT	tm.Code,
			CAST(CASE WHEN EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID) THEN 1 ELSE 0 END AS bit) AS Active,
			CAST(CASE WHEN tm.Active=1 THEN 1 ELSE 0 END AS bit) AS CAN_ACTIVATE,
			CAST(CASE WHEN NOT EXISTS(SELECT *
						FROM CIC_BT_TAX_TM tlt
						INNER JOIN CIC_BT_TAX tl
							ON tlt.BT_TAX_ID=tl.BT_TAX_ID
						INNER JOIN GBL_BaseTable bt
							ON tl.NUM=bt.NUM
								AND (bt.MemberID=@MemberID OR EXISTS(SELECT * FROM GBL_BT_SharingProfile WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID))
					WHERE Code=tm.Code)
				THEN 1 ELSE 0 END AS bit) AS CAN_DEACTIVATE,
			CAST(0 AS bit) AS CAN_ROLLUP		
		FROM TAX_Term tm
	WHERE (@GetChildren=0 AND tm.Code=@Code)
		OR (@GetChildren=1 AND tm.ParentCode=@Code)
END

RETURN

END

GO
