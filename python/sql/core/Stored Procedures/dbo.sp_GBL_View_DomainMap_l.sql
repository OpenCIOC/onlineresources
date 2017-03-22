SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_View_DomainMap_l]
	@AgencyCode char(3) = NULL,
	@MemberID int = NULL
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 12-Mar-2015
	Action: NO ACTION REQUIRED
*/

DECLARE @DefaultViewCIC int,
		@DefaultViewVOL int

IF @AgencyCode IS NOT NULL BEGIN
SELECT @MemberID = MemberID FROM GBL_Agency WHERE AgencyCode=@AgencyCode

SELECT	@DefaultViewCIC=DefaultViewCIC,
		@DefaultViewVOL=DefaultViewVOL
	FROM STP_Member
WHERE MemberID=@MemberID
END

SELECT *, l.Culture AS DefaultCulture FROM GBL_View_DomainMap m
INNER JOIN STP_Language l
	ON m.DefaultLangID=l.LangID
WHERE MemberID=@MemberID ORDER BY DomainName

IF @AgencyCode IS NOT NULL BEGIN
SELECT vw.ViewType,
	vwd.ViewName + CASE WHEN vw.ViewType=@DefaultViewCIC OR EXISTS(SELECT * FROM CIC_View_Recurse vr WHERE vr.ViewType=@DefaultViewCIC AND vr.CanSee=vw.ViewType) THEN '' ELSE ' *' END
FROM CIC_View vw
INNER JOIN CIC_View_Description vwd
	ON vw.ViewType=vwd.ViewType AND vwd.LangID = (SELECT TOP 1 LangID FROM CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vw.MemberID=@MemberID
ORDER BY vwd.ViewName

SELECT vw.ViewType,
	vwd.ViewName + CASE WHEN vw.ViewType=@DefaultViewVOL OR EXISTS(SELECT * FROM VOL_View_Recurse vr WHERE vr.ViewType=@DefaultViewVOL AND vr.CanSee=vw.ViewType) THEN '' ELSE ' *' END
FROM VOL_View vw
INNER JOIN VOL_View_Description vwd
	ON vw.ViewType=vwd.ViewType AND vwd.LangID = (SELECT TOP 1 LangID FROM VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE vw.MemberID=@MemberID
ORDER BY vwd.ViewName
END

SET NOCOUNT OFF

GO


GRANT EXECUTE ON  [dbo].[sp_GBL_View_DomainMap_l] TO [cioc_login_role]
GO
