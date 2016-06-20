
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
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

SELECT DISTINCT 
		CASE WHEN fbe.FBKEY=vo.FBKEY THEN fbe.FBKEY ELSE NULL END AS FBKEY,
		fbe.SOURCE_EMAIL, fbe.AccessURL, fbe.ViewType,
		dbo.fn_VOL_RecordInView(vo.VNUM,
			ISNULL(fbe.ViewType,
				ISNULL((SELECT VOLViewType FROM GBL_View_DomainMap WHERE DomainName=AccessURL),
					(SELECT DefaultViewVOL FROM STP_Member WHERE MemberID=fbe.MemberID))
				),
			@LangID,0,GETDATE()) AS IN_VIEW,
			(SELECT t.FullSSLCompatible_Cache
				FROM VOL_View vw  INNER JOIN GBL_Template t
					ON t.Template_ID = vw.Template 
				WHERE vw.ViewType= ISNULL(fbe.ViewType,
						ISNULL((SELECT VOLViewType FROM GBL_View_DomainMap WHERE DomainName=AccessURL),
							(SELECT DefaultViewVOL FROM STP_Member WHERE MemberID=fbe.MemberID))
						)
			) AS ViewFullSSLCompatibleVOL,
			ISNULL((SELECT m.FullSSLCompatible
				FROM GBL_View_DomainMap m
				WHERE DomainName=ISNULL(AccessURL, (SELECT BaseURLVOL FROM STP_Member WHERE MemberID=fbe.MemberID))
			), CAST(0 AS bit)) AS DomainFullSSLCompatibleVOL
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
