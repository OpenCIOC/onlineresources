SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_GBL_Redirect_s_Slug] (
	@MemberID [INT],
	@Slug VARCHAR(50)
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error	INT
SET @Error = 0

SELECT url  FROM dbo.GBL_Redirect r
WHERE MemberID=@MemberID  AND Slug = @Slug



RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Redirect_s_Slug] TO [cioc_cic_search_role]
GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Redirect_s_Slug] TO [cioc_vol_search_role]
GO
