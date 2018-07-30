SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_LocatedIn_Check]
	@CommunityEn nvarchar(200),
	@CommunityFr nvarchar(200),
	@AuthCommunity nvarchar(200) OUTPUT,
	@ProvState nvarchar(100),
	@DefaultProvState nvarchar(2),
	@Country nvarchar(100),
	@CM_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 05-Apr-2012
	Action: NO ACTION REQUIRED
*/

SELECT TOP 1 @CM_ID = CM_ID
	FROM GBL_Community_Name cm
	LEFT JOIN GBL_ProvinceState pst
		ON cm.ProvinceStateCache=pst.ProvID
WHERE [Name] IN (@CommunityEn,@CommunityFr)
ORDER BY CASE
		WHEN [Name]=@CommunityEn AND LangID=0 THEN 0
		WHEN [Name]=@CommunityFr AND LangID=2 THEN 1
		ELSE 2
	END,
	CASE WHEN pst.NameOrCode=@ProvState THEN 4 WHEN @ProvState IS NULL AND pst.NameOrCode=@DefaultProvState THEN 2 ELSE 0 END +
	CASE WHEN pst.Country=@Country THEN 1 WHEN pst.Country IS NULL OR @Country IS NULL THEN 0 ELSE -1 END DESC

IF @CM_ID IS NULL AND @AuthCommunity IS NOT NULL BEGIN
	SELECT TOP 1 @CM_ID=CM_ID
		FROM GBL_Community_Name
	WHERE [Name]=@AuthCommunity
	ORDER BY LangID
END ELSE BEGIN
	SET @AuthCommunity = NULL
END

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_LocatedIn_Check] TO [cioc_login_role]
GO
