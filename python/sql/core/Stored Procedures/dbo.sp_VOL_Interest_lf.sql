
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Interest_lf]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 19-Feb-2015
	Action: TESTING REQUIRED
*/

SELECT ai.AI_ID, ai.MODIFIED_BY, ai.MODIFIED_DATE, ai.Code, (SELECT COUNT(VNUM) FROM VOL_OP_AI WHERE AI_ID=ai.AI_ID) AS Usage, 
	(SELECT COUNT(vo.VNUM) FROM VOL_OP_AI voai INNER JOIN VOL_Opportunity vo ON vo.VNUM = voai.VNUM WHERE voai.AI_ID=ai.AI_ID AND vo.MemberID=@MemberID) AS UsageLocal,
	CASE WHEN EXISTS(SELECT * FROM VOL_Interest_InactiveByMember WHERE AI_ID=ai.AI_ID AND MemberID=@MemberID) THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END AS Hidden,
	CAST((SELECT n.Name, l.Culture 
					FROM VOL_Interest_Name n
					INNER JOIN STP_Language l
						ON l.LangID=n.LangID AND n.AI_ID=ai.AI_ID
					FOR XML PATH('DESC'), ROOT('DESCS'),Type) AS nvarchar(max)) AS Descriptions,
	CAST((SELECT n.Name
					FROM VOL_InterestGroup_Name n
					INNER JOIN VOL_AI_IG aiig
						ON aiig.AI_ID=ai.AI_ID AND aiig.IG_ID=n.IG_ID
					WHERE n.LangID=(SELECT TOP 1 LangID FROM VOL_InterestGroup_Name WHERE IG_ID=n.IG_ID ORDER BY CASE WHEN n.LangID=@@LANGID THEN 0 ELSE 1 END)
					ORDER BY Name
					FOR XML PATH('GROUP'), ROOT('GROUPS'),Type) AS nvarchar(max)) AS Groups
		
	FROM VOL_Interest ai
ORDER BY (SELECT TOP 1 Name FROM VOL_Interest_Name WHERE AI_ID=ai.AI_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END)

SET NOCOUNT OFF


GO




GRANT EXECUTE ON  [dbo].[sp_VOL_Interest_lf] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_Interest_lf] TO [cioc_vol_search_role]
GO
