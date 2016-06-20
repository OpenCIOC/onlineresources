
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GBL_FeedAPIKey_l]
	@MemberID int,
	@OnlyPublic bit = 0
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: KL
	Checked on: 22-Jan-2016
	Action: NO ACTION REQUIRED
*/

SELECT FeedAPIKey ,
       CREATED_DATE ,
       CREATED_BY ,
       MODIFIED_DATE ,
       MODIFIED_BY ,
       Owner ,
       CIC ,
       VOL ,
       Inactive
FROM dbo.GBL_FeedAPIKey
WHERE MemberID=@MemberID
	AND (
		@OnlyPublic = 0
		OR (Inactive = 0 AND (CIC=1 OR VOL=1))
	)

SET NOCOUNT OFF

GO


GRANT EXECUTE ON  [dbo].[sp_GBL_FeedAPIKey_l] TO [cioc_login_role]
GO
