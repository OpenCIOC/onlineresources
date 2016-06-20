SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToRelatedTerms_rst](
	@MemberID int,
	@NUM varchar(8)
)
RETURNS @RelatedTerms TABLE (
	[Subj_ID] int NULL,
	[SubjectTerm] nvarchar(200) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @RelatedTerms
SELECT sj.Subj_ID, sjn.Name AS SubjectTerm
	FROM (SELECT rt.RelatedSubj_ID
			FROM CIC_BT_SBJ pr
			INNER JOIN THS_Subject sj
				ON pr.Subj_ID = sj.Subj_ID
			INNER JOIN THS_SBJ_RelatedTerm rt
				ON sj.Subj_ID = rt.Subj_ID
		WHERE (pr.NUM = @NUM AND
			NOT EXISTS(SELECT * FROM CIC_BT_SBJ WHERE NUM=@NUM AND Subj_ID=rt.RelatedSubj_ID))
		GROUP BY rt.RelatedSubj_ID) tm
	INNER JOIN THS_Subject sj
		ON tm.RelatedSubj_ID = sj.Subj_ID
	INNER JOIN THS_Subject_Name sjn
		ON sj.Subj_ID=sjn.Subj_ID AND sjn.LangID=@@LANGID
WHERE NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=@MemberID AND Subj_ID=sj.Subj_ID) 
ORDER BY sjn.Name

RETURN

END

GO
GRANT SELECT ON  [dbo].[fn_CIC_NUMToRelatedTerms_rst] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[fn_CIC_NUMToRelatedTerms_rst] TO [cioc_login_role]
GO
