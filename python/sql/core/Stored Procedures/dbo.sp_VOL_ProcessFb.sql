SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_ProcessFb]
	@VNUM varchar(10),
	@FB_ID int,
	@LangID smallint
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.8
	Checked by: CL
	Checked on: 17-Sep-2017
	Action: TESTING REQUIRED
*/
IF @FB_ID IS NOT NULL AND @VNUM IS NOT NULL BEGIN
	UPDATE VOL_Feedback SET VNUM=@VNUM WHERE FB_ID=@FB_ID AND VNUM IS NULL
END

SELECT DISTINCT 
		CASE WHEN fbe.FBKEY=vo.FBKEY THEN fbe.FBKEY ELSE NULL END AS FBKEY,
		fbe.SOURCE_EMAIL, fbe.AccessURL, fbe.ViewType,
		dbo.fn_VOL_RecordInView(vo.VNUM,
			ISNULL(fbe.ViewType,
				ISNULL((SELECT VOLViewType FROM GBL_View_DomainMap WHERE DomainName=AccessURL),
					(SELECT DefaultViewVOL FROM STP_Member WHERE MemberID=fbe.MemberID))
				),
			@LangID,0,GETDATE()) AS IN_VIEW
	FROM VOL_Feedback fbe
	INNER JOIN VOL_Opportunity vo
		ON fbe.VNUM=vo.VNUM
WHERE [User_ID] IS NULL
	AND fbe.SOURCE_EMAIL IS NOT NULL
	AND fbe.LangID=@LangID
	AND (@FB_ID IS NULL AND fbe.VNUM=@VNUM) OR (@FB_ID IS NOT NULL AND FB_ID=@FB_ID)

SET NOCOUNT OFF




GO

GRANT EXECUTE ON  [dbo].[sp_VOL_ProcessFb] TO [cioc_login_role]
GO
