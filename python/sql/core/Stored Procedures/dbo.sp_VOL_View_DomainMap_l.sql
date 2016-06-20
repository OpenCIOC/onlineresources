SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_View_DomainMap_l] (
	@MemberID int
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 15-May-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

DECLARE @DefaultView int,
		@BaseURL varchar(100)

SELECT	@DefaultView=DefaultViewVOL,
		@BaseURL=BaseURLVOL
	FROM STP_Member
WHERE MemberID=@MemberID

SELECT	vw.ViewType,
		CASE WHEN vw.ViewType=@DefaultView OR DomainName IS NOT NULL THEN NULL ELSE vw.ViewType END AS URLViewType,
		ISNULL(DomainName, @BaseURL) + ISNULL(PathToStart,'') COLLATE Latin1_General_100_CI_AI AS AccessURL,
		CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END AS ViewName,
		CASE WHEN vw.ViewType=@DefaultView THEN 1 ELSE 0 END AS DEFAULT_VIEW,
		CASE WHEN ISNULL(mp.FullSSLCompatible, 0) = 1 AND (SELECT FullSSLCompatible FROM GBL_Template WHERE Template_ID=vw.Template) = 1 THEN 'https' ELSE 'http' END AS Protocol
	FROM VOL_View vw
	INNER JOIN VOL_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN GBL_View_DomainMap mp
		ON vw.ViewType = mp.VOLViewType AND mp.MemberID=@MemberID
WHERE vw.MemberID=@MemberID AND
	(
		EXISTS(SELECT * FROM VOL_View_Recurse vr WHERE vr.ViewType=@DefaultView AND vr.CanSee=vw.ViewType)
		OR vw.ViewType=@DefaultView
	)
ORDER BY CASE WHEN vw.ViewType=@DefaultView THEN 0 ELSE 1 END, vwd.ViewName

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_View_DomainMap_l] TO [cioc_login_role]
GO
