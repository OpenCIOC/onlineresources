SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToLocalTerms_Web](
	@MemberID int,
	@NUM varchar(8),
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 15-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + cioc_shared.dbo.fn_SHR_THS_Link_Subject(Subj_ID,SubjectTerm,'bresults.asp',@HTTPVals,@PathToStart)
	FROM fn_CIC_NUMToLocalTerms_rst(@MemberID,@NUM,@@LANGID)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToLocalTerms_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToLocalTerms_Web] TO [cioc_login_role]
GO
