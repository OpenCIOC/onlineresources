SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToLocalTerms_rst](
	@MemberID int,
	@NUM varchar(8),
	@LangID smallint
)
RETURNS @LocalTerms TABLE (
	[Subj_ID] int NULL,
	[SubjectTerm] nvarchar(200) COLLATE Latin1_General_100_CI_AI NULL
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 16-Apr-2012
	Action: NO ACTION REQUIRED
*/

INSERT INTO @LocalTerms
SELECT sj.Subj_ID, sjn.Name AS SubjectTerm
	FROM CIC_BT_SBJ pr
	INNER JOIN THS_Subject sj
		ON pr.Subj_ID=sj.Subj_ID
	INNER JOIN THS_Subject_Name sjn
		ON sj.Subj_ID=sjn.Subj_ID AND sjn.LangID=@LangID
WHERE pr.NUM=@NUM
	AND sj.Authorized=0
	AND (@MemberID IS NULL OR NOT EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=@MemberID AND Subj_ID=sj.Subj_ID))
ORDER BY sjn.Name

RETURN

END


GO
GRANT SELECT ON  [dbo].[fn_CIC_NUMToLocalTerms_rst] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[fn_CIC_NUMToLocalTerms_rst] TO [cioc_login_role]
GO
