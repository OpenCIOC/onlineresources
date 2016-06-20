SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToBroaderTerms_rst](
	@NUM varchar(8),
	@LangID smallint
)
RETURNS @BroaderTerms TABLE (
	[Subj_ID] int NULL,
	[SubjectTerm] nvarchar(200) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @BroaderTermsIDs TABLE (Subj_ID int)
DECLARE	@NewTermsIDs1 TABLE (Subj_ID int)
DECLARE	@NewTermsIDs2 TABLE (Subj_ID int)
DECLARE	@loopCount int,
		@rowCount int

INSERT INTO @BroaderTermsIDs
	SELECT bt.BroaderSubj_ID
		FROM CIC_BT_SBJ pr
			INNER JOIN THS_SBJ_BroaderTerm bt
				ON pr.Subj_ID = bt.Subj_ID
		WHERE     (pr.NUM = @NUM)
		GROUP BY bt.BroaderSubj_ID

INSERT INTO @NewTermsIDs1 SELECT * FROM @BroaderTermsIDs

SET @rowCount = @@ROWCOUNT
SET @loopCount = 6

WHILE @rowCount > 0 AND @loopCount > 0 BEGIN
	DELETE @NewTermsIDs2
	INSERT INTO @NewTermsIDs2 SELECT * FROM @NewTermsIDs1
	DELETE @NewTermsIDs1
	INSERT @NewTermsIDs1 SELECT bt.BroaderSubj_ID
		FROM @NewTermsIDs2 nt2
		INNER JOIN THS_SBJ_BroaderTerm bt
			ON nt2.Subj_ID = bt.Subj_ID
	GROUP BY bt.BroaderSubj_ID
	SET @rowCount = @@ROWCOUNT
	IF @rowCount > 0 BEGIN
		INSERT INTO @BroaderTermsIDs SELECT nt1.Subj_ID
			FROM @NewTermsIDs1 nt1
			LEFT JOIN @BroaderTermsIDs bt
				ON nt1.Subj_ID = bt.Subj_ID
		WHERE bt.Subj_ID IS NULL 
		SET @rowCount = @@ROWCOUNT
	END
	SET @loopCount = @loopCount - 1
END

INSERT INTO @BroaderTerms
SELECT sj.Subj_ID, sjn.Name AS SubjectTerm
	FROM @BroaderTermsIDs bt
	INNER JOIN THS_Subject sj
		ON bt.Subj_ID = sj.Subj_ID
	INNER JOIN THS_Subject_Name sjn
		ON sj.Subj_ID=sjn.Subj_ID AND sjn.LangID=@LangID
ORDER BY sjn.Name

RETURN

END

GO
GRANT SELECT ON  [dbo].[fn_CIC_NUMToBroaderTerms_rst] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[fn_CIC_NUMToBroaderTerms_rst] TO [cioc_login_role]
GO
