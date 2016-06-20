SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_TAX_SRCH_Taxonomy](
	@NUM [varchar](8),
	@LangID [smallint]
)
RETURNS [varchar](max) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@MemberID int,
		@returnStr varchar(max),
		@conStr varchar(3)
		
SELECT @MemberID=MemberID
	FROM GBL_BaseTable
WHERE NUM=@NUM

IF @MemberID IS NOT NULL BEGIN

/* Delimiter for SRCH_Taxonomy items */
SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' ; ',@LangID)

/* Temporary table to gather 4 types of Info */
DECLARE @Terms TABLE (
	[Code] varchar(23) COLLATE Latin1_General_100_CI_AI NOT NULL PRIMARY KEY,
	FirstList bit
)

/* Insert direct Term references for the selected record */
INSERT INTO @Terms 
	SELECT DISTINCT tm.Code, 1
	FROM CIC_BT_TAX tl
	INNER JOIN CIC_BT_TAX_TM tlt
		ON tl.BT_TAX_ID=tlt.BT_TAX_ID
	INNER JOIN TAX_Term tm
		ON tlt.Code=tm.Code
	WHERE NUM=@NUM

/* Insert Broader Term references, do not include Level 1 Terms */
INSERT INTO @Terms
	SELECT DISTINCT tm.Code, 0
		FROM TAX_Term tm
		INNER JOIN TAX_Term_ParentList tmpl
			ON tm.Code=tmpl.ParentCode
		INNER JOIN @Terms tl 
			ON tmpl.Code=tl.Code
	WHERE NOT EXISTS(SELECT * FROM @Terms tl WHERE tm.Code=tl.Code)
		AND tm.Active=1
		AND tm.CdLvl>1

/* Insert Rolled-up Terms */
INSERT INTO @Terms
	SELECT DISTINCT tm.Code, 0
		FROM TAX_Term tm
		INNER JOIN TAX_Term_ParentList tmpl
			ON tm.Code=tmpl.Code
		INNER JOIN @Terms tl
			ON tmpl.ParentCode=tl.Code AND tl.FirstList=1
	WHERE NOT EXISTS(SELECT * FROM @Terms tl WHERE tm.Code=tl.Code)
		AND (
				(
					tm.Active IS NULL
					AND NOT EXISTS(SELECT * FROM TAX_Term_ParentList tmplx
						WHERE tmplx.ParentCode=tm.Code
							AND EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tmplx.Code AND MemberID=@MemberID))
				)
			OR (
				tm.Active=1
				AND NOT EXISTS(SELECT * FROM TAX_Term_ActivationByMember WHERE Code=tm.Code AND MemberID=@MemberID)
			)
		)

/* Select all 3 types of Term info from above + Use References as a semi-colon delimited list */
SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + xtm.Term
	FROM (
		SELECT CASE WHEN tmd.AltTerm IS NOT NULL THEN tmd.AltTerm + @conStr + tmd.Term ELSE tmd.Term END AS Term
			FROM @Terms tm
			INNER JOIN TAX_Term_Description tmd
				ON tm.Code=tmd.Code AND tmd.LangID=@LangID
		UNION SELECT ut.Term
			FROM TAX_Unused ut
			INNER JOIN @Terms tl
				ON ut.Code=tl.Code AND ut.LangID=@LangID
			WHERE ut.Active=1
	) xtm

END

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_TAX_SRCH_Taxonomy] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_TAX_SRCH_Taxonomy] TO [cioc_login_role]
GO
