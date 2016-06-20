SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_Template_SystemLayoutURLs](
	@Template_ID int
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr		varchar(3),
		@returnStr	varchar(max)

SET @conStr = ';'
SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') + tl.LayoutCSSURL
	FROM GBL_Template_Layout tl
WHERE tl.SystemLayout = 1
	AND tl.LayoutCSSURL IS NOT NULL
	AND EXISTS(SELECT * FROM GBL_Template t
			WHERE t.Template_ID=@Template_ID
				AND (t.SearchLayoutCIC=tl.LayoutID OR t.SearchLayoutVOL=tl.LayoutID OR t.HeaderLayout=tl.LayoutID OR t.FooterLayout=tl.LayoutID)
			)

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END
GO
