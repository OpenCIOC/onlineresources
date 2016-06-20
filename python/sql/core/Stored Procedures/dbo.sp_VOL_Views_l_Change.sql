SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Views_l_Change]
	@MemberID int,
	@User_ID int,
	@CurrentView int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Dec-2011
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

DECLARE @DefaultView int

IF @User_ID IS NULL BEGIN
	SELECT @DefaultView = DefaultViewVOL
		FROM STP_Member
	WHERE MemberID=@MemberID
END ELSE BEGIN
	SELECT @DefaultView = ViewType
		FROM VOL_SecurityLevel sl
		INNER JOIN GBL_Users u
			ON sl.SL_ID = u.SL_ID_VOL
	WHERE [User_ID]=@User_ID
END

SELECT vw.ViewType, vwd.ViewName
	FROM VOL_View vw
	LEFT JOIN VOL_View_Recurse vr
		ON (vw.ViewType=vr.CanSee AND vr.ViewType=@DefaultView)
	INNER JOIN VOL_View_Description vwd
		ON vw.ViewType=vwd.ViewType AND vwd.LangID=@@LANGID
WHERE vw.MemberID=@MemberID
	AND vw.ViewType <> @CurrentView
	AND (vw.ViewType=@DefaultView OR vr.CanSee IS NOT NULL)
ORDER BY ViewName

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Views_l_Change] TO [cioc_login_role]
GO
