SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_THS_UsedWith](
	@MemberID int,
	@Subj_ID int,
	@UsedSubj_ID int,
	@Inactive bit
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr	nvarchar(3),
		@returnStr	nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(', ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + CASE WHEN sjn.LangID=@@LANGID THEN sjn.Name ELSE '[' + sjn.Name + ']' END
	FROM THS_Subject sj
	INNER JOIN THS_Subject_Name sjn
		ON sj.Subj_ID=sjn.Subj_ID AND sjn.LangID=CASE
				WHEN @Inactive=1 THEN (SELECT TOP 1 LangID FROM THS_Subject_Name WHERE Subj_ID=sjn.Subj_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
				ELSE @@LANGID
			END
	INNER JOIN THS_SBJ_UseInstead ui
		ON sj.Subj_ID=ui.UsedSubj_ID
			AND ui.Subj_ID=@Subj_ID
			AND ui.UsedSubj_ID<>@UsedSubj_ID
	INNER JOIN THS_Subject sj2
		ON ui.Subj_ID=sj2.Subj_ID
			AND sj2.UseAll=1
WHERE @Inactive=1 OR EXISTS(SELECT * FROM THS_Subject_InactiveByMember WHERE MemberID=@MemberID AND Subj_ID=sj.Subj_ID)
ORDER BY sjn.Name

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_THS_UsedWith] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_THS_UsedWith] TO [cioc_login_role]
GO
