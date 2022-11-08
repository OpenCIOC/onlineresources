SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CIC_View_DomainMap_l] (
	@MemberID int
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE @Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

DECLARE @DefaultView int,
		@BaseURL varchar(100)

SELECT	@DefaultView=DefaultViewCIC,
		@BaseURL=BaseURLCIC
	FROM dbo.STP_Member
WHERE MemberID=@MemberID

SELECT	vw.ViewType,
		CASE WHEN vw.ViewType=@DefaultView OR (mp.DomainName IS NOT NULL AND mp.DomainName<>@BaseURL) THEN NULL ELSE vw.ViewType END AS URLViewType,
		ISNULL(mp.DomainName, @BaseURL) + ISNULL(mp.PathToStart,'') COLLATE Latin1_General_100_CI_AI AS AccessURL,
		CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END AS ViewName,
		CASE WHEN vw.ViewType=@DefaultView THEN 1 ELSE 0 END AS DEFAULT_VIEW
	FROM dbo.CIC_View vw
	INNER JOIN dbo.CIC_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM dbo.CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.GBL_View_DomainMap mp
		ON (vw.ViewType = mp.CICViewType OR (vw.ViewType=@DefaultView AND mp.CICViewType IS NULL)) AND mp.MemberID=@MemberID AND mp.SecondaryName=0
WHERE vw.MemberID=@MemberID AND
	(
		EXISTS(SELECT * FROM dbo.CIC_View_Recurse vr WHERE vr.ViewType=@DefaultView AND vr.CanSee=vw.ViewType)
		OR vw.ViewType=@DefaultView
	)
ORDER BY CASE WHEN vw.ViewType=@DefaultView THEN 0 ELSE 1 END, vwd.ViewName

RETURN @Error

SET NOCOUNT OFF






GO

GRANT EXECUTE ON  [dbo].[sp_CIC_View_DomainMap_l] TO [cioc_login_role]
GO
