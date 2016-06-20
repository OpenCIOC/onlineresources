SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_PageMsg_s]
	@MemberID int,
	@AgencyCode char(3),
	@UseCIC bit,
	@UseVOL bit,
	@PageMsgID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 23-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
END

SELECT *
	FROM GBL_PageMsg
WHERE MemberID=@MemberID
	AND PageMsgID=@PageMsgID

SELECT	vw.ViewType,
		CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END
			+ CASE WHEN (vw.Owner IS NOT NULL AND vw.Owner<>@AgencyCode) THEN ' [' + vw.Owner + ']' ELSE '' END AS ViewName,
		CAST(CASE WHEN pmv.ViewType IS NULL THEN 0 ELSE 1 END AS bit) AS VIEW_SELECTED,
		CAST(CASE WHEN (vw.Owner IS NULL OR vw.Owner=@AgencyCode) AND @UseCIC=1 THEN 1 ELSE 0 END AS bit) AS CAN_EDIT
	FROM CIC_View vw
	INNER JOIN CIC_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM CIC_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN (SELECT ViewType
		FROM CIC_View_PageMsg
			WHERE PageMsgID=@PageMsgID
		) pmv
	ON vw.ViewType=pmv.ViewType
WHERE vw.MemberID=@MemberID 
	AND (
		pmv.ViewType IS NOT NULL
		OR (
			(vw.Owner IS NULL OR vw.Owner=@AgencyCode)
			AND @UseCIC=1
		)
	)
ORDER BY vwd.ViewName

SELECT	vw.ViewType,
		CASE WHEN vwd.LangID=@@LANGID THEN vwd.ViewName ELSE '[' + vwd.ViewName + ']' END
			+ CASE WHEN (vw.Owner IS NOT NULL AND vw.Owner<>@AgencyCode) THEN ' [' + vw.Owner + ']' ELSE '' END AS ViewName,
		CAST(CASE WHEN pmv.ViewType IS NULL THEN 0 ELSE 1 END AS bit) AS VIEW_SELECTED,
		CAST(CASE WHEN (vw.Owner IS NULL OR vw.Owner=@AgencyCode) AND @UseVOL=1 THEN 1 ELSE 0 END AS bit) AS CAN_EDIT
	FROM VOL_View vw
	INNER JOIN VOL_View_Description vwd
		ON vw.ViewType=vwd.ViewType
			AND vwd.LangID = (SELECT TOP 1 LangID FROM VOL_View_Description WHERE ViewType=vwd.ViewType ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN (SELECT ViewType
		FROM VOL_View_PageMsg
			WHERE PageMsgID=@PageMsgID
		) pmv
	ON vw.ViewType=pmv.ViewType
WHERE vw.MemberID=@MemberID 
	AND (
		pmv.ViewType IS NOT NULL
		OR (
			(vw.Owner IS NULL OR vw.Owner=@AgencyCode)
			AND @UseVOL=1
		)
	)
ORDER BY vwd.ViewName

SELECT	pg.PageName,
		pgn.PageTitle,
		CASE WHEN CIC=1 AND VOL=1 THEN 4 WHEN CIC=1 THEN 1 ELSE 2 END AS PAGE_TYPE,
		CAST(CASE WHEN pmp.PageName IS NULL THEN 0 ELSE 1 END AS bit) AS PAGE_SELECTED, 
		CAST(CASE WHEN (@UseCIC=1 AND CIC=1) OR (@UseVOL=1 AND VOL=1) THEN 1 ELSE 0 END AS bit) AS CAN_EDIT
	FROM GBL_PageInfo pg
	LEFT JOIN GBL_PageMsg_PageInfo pmp
		ON pmp.PageName=pg.PageName AND pmp.PageMsgID=@PageMsgID
	LEFT JOIN GBL_PageInfo_Description pgn
		ON pg.PageName=pgn.PageName AND pgn.LangID=(SELECT TOP 1 LangID FROM GBL_PageInfo_Description WHERE PageName=pg.PageName ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE NoPageMsg=0
	AND (
		pmp.PageMsgID IS NOT NULL
		OR ((@UseCIC=1 AND CIC=1) OR (@UseVOL=1 AND VOL=1))
	)
ORDER BY PAGE_TYPE, pg.PageName

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PageMsg_s] TO [cioc_login_role]
GO
