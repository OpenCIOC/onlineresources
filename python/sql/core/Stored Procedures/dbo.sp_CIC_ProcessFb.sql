
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ProcessFb]
	@NUM varchar(8),
	@FB_ID int,
	@LangID smallint
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 30-Oct-2012
	Action: NO ACTION REQUIRED
	Notes: DO WE NEED TO BETTER MANAGE CASES WHERE VIEWTYPE IS NOT KNOWN, ESP IF NO ACCESS URL?
*/

SELECT DISTINCT
		CASE WHEN fbe.FBKEY=bt.FBKEY THEN fbe.FBKEY ELSE NULL END AS FBKEY,
		fbe.SOURCE_EMAIL, fbe.AccessURL, fbe.ViewType,
		dbo.fn_CIC_RecordInView(bt.NUM,
			ISNULL(fbe.ViewType,
				ISNULL((SELECT CICViewType FROM GBL_View_DomainMap WHERE DomainName=AccessURL),
					(SELECT DefaultViewCIC FROM STP_Member WHERE MemberID=fbe.MemberID))
				),
			@LangID,0,GETDATE()) AS IN_VIEW,
			(SELECT t.FullSSLCompatible_Cache
				FROM CIC_View vw  INNER JOIN GBL_Template t
					ON t.Template_ID = vw.Template 
				WHERE vw.ViewType= ISNULL(fbe.ViewType,
						ISNULL((SELECT CICViewType FROM GBL_View_DomainMap WHERE DomainName=AccessURL),
							(SELECT DefaultViewCIC FROM STP_Member WHERE MemberID=fbe.MemberID))
						)
			) AS ViewFullSSLCompatibleCIC,
			ISNULL((SELECT m.FullSSLCompatible
				FROM GBL_View_DomainMap m
				WHERE DomainName=ISNULL(AccessURL, (SELECT BaseURLCIC FROM STP_Member WHERE MemberID=fbe.MemberID))
			), 0) AS DomainFullSSLCompatibleCIC
	FROM GBL_FeedbackEntry fbe
	INNER JOIN GBL_BaseTable bt
		ON fbe.NUM=bt.NUM
WHERE fbe.[User_ID] IS NULL
	AND fbe.SOURCE_EMAIL IS NOT NULL
	AND fbe.LangID=@LangID
	AND (@FB_ID IS NULL AND fbe.NUM=@NUM) OR (@FB_ID IS NOT NULL AND fbe.FB_ID=@FB_ID)

SET NOCOUNT OFF




GO

GRANT EXECUTE ON  [dbo].[sp_CIC_ProcessFb] TO [cioc_login_role]
GO
