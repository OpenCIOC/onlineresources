SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_InterestToInterestGroup](
	@AI_ID int
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 05-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; ')

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + ign.Name
	FROM  VOL_AI_IG pr
	INNER JOIN VOL_InterestGroup ig
		ON pr.IG_ID = ig.IG_ID
	INNER JOIN VOL_InterestGroup_Name ign
		ON ig.IG_ID=ign.IG_ID AND ign.LangID=@@LANGID
WHERE pr.AI_ID=@AI_ID
ORDER BY ign.Name

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_VOL_InterestToInterestGroup] TO [cioc_vol_search_role]
GO
