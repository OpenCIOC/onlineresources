SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NAICSCount](
	@ViewType int,
	@Code varchar(6),
	@NoDeleted bit,
	@Today datetime
)
RETURNS int WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 01-Feb-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@UsageCount int,
		@SearchString varchar(10)

SELECT @SearchString=ISNULL(SearchChildren,Code)+'%'
	FROM NAICS
WHERE Code=@Code

SELECT @UsageCount = COUNT(*)
	FROM CIC_BT_NC pr
WHERE pr.Code LIKE @SearchString
	AND dbo.fn_CIC_RecordInView(pr.NUM,@ViewType,@@LANGID,@NoDeleted,@Today)=1

RETURN ISNULL(@UsageCount,0)

END




GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NAICSCount] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NAICSCount] TO [cioc_login_role]
GO
