SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToUsedForTerms_rst](
	@MemberID int,
	@NUM varchar(8),
	@LangID smallint
)
RETURNS @UsedForTerms TABLE (
	[Subj_ID] int NULL,
	[SubjectTerm] nvarchar(200) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
	Notes: MAY BE ABLE TO MAKE THIS MORE EFFICIENT
*/

DECLARE	@currentTerm int,
		@requiredTerm int
DECLARE @UseInstead1 TABLE (Subj_ID int)
DECLARE @UseInstead2 TABLE (Subj_ID int)

/* first get all the known good terms */
INSERT @UseInstead1 SELECT DISTINCT ui.Subj_ID FROM CIC_BT_SBJ pr
	INNER JOIN THS_SBJ_UseInstead ui
		ON pr.Subj_ID = ui.UsedSubj_ID
	INNER JOIN THS_Subject sj
		ON ui.Subj_ID = sj.Subj_ID
WHERE NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=@MemberID AND Subj_ID=sj.Subj_ID)
	AND (pr.NUM=@NUM AND sj.UseAll=0)

/* next get all the potential terms */
INSERT @UseInstead2 SELECT DISTINCT ui.Subj_ID
	FROM CIC_BT_SBJ pr
	INNER JOIN THS_SBJ_UseInstead ui
		ON pr.Subj_ID = ui.UsedSubj_ID
	INNER JOIN THS_Subject sj
		ON ui.Subj_ID = sj.Subj_ID
WHERE NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=@MemberID AND Subj_ID=sj.Subj_ID) 
	AND (pr.NUM=@NUM AND sj.UseAll=1)

/* last get the qualifying terms from potential terms */
INSERT INTO @UseInstead1 SELECT tm2.Subj_ID
	FROM @UseInstead2 tm2
	INNER JOIN THS_SBJ_UseInstead ui
		ON tm2.Subj_ID = ui.Subj_ID
	GROUP BY tm2.Subj_ID
	HAVING COUNT(*) = 1

DELETE tm2
	FROM @UseInstead2 tm2
	LEFT JOIN @UseInstead1 tm1
		ON tm2.Subj_ID = tm1.Subj_ID
WHERE tm1.Subj_ID IS NOT NULL

SELECT @currentTerm = MIN(Subj_ID) FROM @UseInstead2
WHILE @currentTerm > 0 AND @currentTerm IS NOT NULL BEGIN
	SELECT @requiredTerm = MIN(UsedSubj_ID) FROM THS_SBJ_UseInstead ui WHERE Subj_ID = @currentTerm
	WHILE @requiredTerm > 0 AND @requiredTerm IS NOT NULL BEGIN
		IF NOT EXISTS(SELECT BT_SBJ_ID FROM CIC_BT_SBJ WHERE (NUM = @NUM AND Subj_ID = @requiredTerm)) BEGIN
			DELETE @UseInstead2 WHERE Subj_ID = @currentTerm
		END
		SELECT @requiredTerm = MIN(UsedSubj_ID) FROM THS_SBJ_UseInstead ui WHERE Subj_ID = @currentTerm AND UsedSubj_ID > @requiredTerm
	END	
	SELECT @currentTerm = MIN(Subj_ID) FROM @UseInstead2 WHERE Subj_ID > @currentTerm
END

INSERT INTO @UseInstead1 SELECT * FROM @UseInstead2

INSERT INTO @UsedForTerms
SELECT sj.Subj_ID, sjn.Name AS SubjectTerm
	FROM @UseInstead1 tm
	INNER JOIN THS_Subject sj
		ON tm.Subj_ID = sj.Subj_ID
	INNER JOIN THS_Subject_Name sjn
		ON sj.Subj_ID=sjn.Subj_ID AND sjn.LangID=@LangID
ORDER BY sjn.Name

RETURN

END


GO
GRANT SELECT ON  [dbo].[fn_CIC_NUMToUsedForTerms_rst] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[fn_CIC_NUMToUsedForTerms_rst] TO [cioc_login_role]
GO
