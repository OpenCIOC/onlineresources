SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_VOL_GetInvolved_Sync]
	@MemberID int,
	@GetInvolvedUser nvarchar(100),
	@GetInvolvedToken nvarchar(100),
	@GetInvolvedSite nvarchar(200)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE @Opportunities TABLE (
	VNUM varchar(10),
	COMMUNITIES xml,
	INTERESTS xml,
	SKILLS xml,
	OP_NAME nvarchar(500),
	ORG_NAME_FULL nvarchar(1500),
	DISPLAY_UNTIL smalldatetime,
	DELETION_DATE smalldatetime,
	DUTIES nvarchar(max),
	ViewInfo xml,
	Culture char(5)
)

DECLARE @DefaultView int,
		@BaseURL varchar(100),
		@DefaultEmailVOLProfile varchar(100)
		

SELECT	@DefaultView=DefaultViewVOL,
		@BaseURL=BaseURLVOL,
		@DefaultEmailVOLProfile=DefaultEmailVOLProfile
	FROM STP_Member
	WHERE MemberID=@MemberID

INSERT INTO @Opportunities
SELECT 	vo.VNUM,
		(SELECT TOP 4 cmn.Name + ', Ontario' AS [@Name]
			FROM GBL_Community_Name cmn
			INNER JOIN VOL_OP_CM opcm
				ON cmn.CM_ID=opcm.CM_ID
			WHERE cmn.LangID=0 AND opcm.VNUM=vo.VNUM
		FOR XML PATH('NAME'), ROOT('NAMES'), TYPE) AS COMMUNITIES,
		(SELECT DISTINCT Name AS [@Name] FROM 
			(SELECT gii.GIInterestName AS Name
			FROM VOL_OP_AI ai
			INNER JOIN VOL_Interest_GetInvolved_Map map
				ON ai.AI_ID=map.AI_ID
			INNER JOIN VOL_GetInvolved_Interest gii
				ON gii.GIInterestID=map.GIInterestID
			WHERE vo.VNUM=ai.VNUM
			UNION SELECT gii.GIInterestName AS Name
			FROM VOL_OP_SK sk
			INNER JOIN VOL_Skill_GetInvolved_Map map
				ON sk.SK_ID=map.SK_ID
			INNER JOIN VOL_GetInvolved_Interest gii
				ON gii.GIInterestID=map.GIInterestID
			WHERE vo.VNUM=sk.VNUM
			) interests
		FOR XML PATH('NAME'), ROOT('NAMES'), TYPE) AS INTERESTS,
		(SELECT DISTINCT Name AS [@Name] FROM 
			(SELECT gis.GISkillName AS Name
			FROM VOL_OP_AI ai
			INNER JOIN VOL_Interest_GetInvolved_Map map
				ON ai.AI_ID=map.AI_ID
			INNER JOIN VOL_GetInvolved_Skill gis
				ON gis.GISkillID=map.GISkillID
			WHERE vo.VNUM=ai.VNUM
			UNION SELECT gis.GISkillName AS Name
			FROM VOL_OP_SK sk
			INNER JOIN VOL_Skill_GetInvolved_Map map
				ON sk.SK_ID=map.SK_ID
			INNER JOIN VOL_GetInvolved_Skill gis
				ON gis.GISkillID=map.GISkillID
			WHERE vo.VNUM=sk.VNUM
			) skills
		FOR XML PATH('NAME'), ROOT('NAMES'), TYPE) AS SKILLS,
		vod.POSITION_TITLE,
		dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM, btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5, btd.LOCATION_NAME, btd.SERVICE_NAME_LEVEL_1, btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		vo.DISPLAY_UNTIL,
		vod.DELETION_DATE,
		vod.DUTIES,
		(SELECT CASE WHEN vw.ViewType=@DefaultView OR DomainName IS NOT NULL THEN NULL ELSE vw.ViewType END AS [@ViewType],
			ISNULL(DomainName, @BaseURL) + ISNULL(PathToStart,'') COLLATE Latin1_General_100_CI_AI AS [@AccessURL],
			l.Culture AS [@Culture]
			FROM VOL_View vw
			INNER JOIN VOL_View_Description vwd
				ON vwd.ViewType=vw.ViewType
			INNER JOIN STP_Language l
				ON vwd.LangID=l.LangID AND EXISTS(SELECT * FROM VOL_Opportunity_Description WHERE vwd.LangID=LangID)
			LEFT JOIN (SELECT * FROM GBL_View_DomainMap WHERE SecondaryName = 0) mp
				ON vw.ViewType = mp.VOLViewType
			WHERE vw.UseProfilesView=1
				AND (EXISTS(SELECT * FROM VOL_View_Recurse vr WHERE vr.ViewType=@DefaultView AND vr.CanSee=vw.ViewType)
				OR vw.ViewType=@DefaultView)
				AND dbo.fn_VOL_RecordInView(vo.VNUM,vwd.ViewType,vwd.LangID,1,GETDATE())=1
			ORDER BY CASE WHEN vw.ViewType=@DefaultView THEN 0 ELSE 1 END
		FOR XML PATH('DESC'),ROOT('DESCS'),TYPE) AS ViewInfo,
		l.Culture
	FROM VOL_Opportunity vo
	INNER JOIN GBL_BaseTable bt
		ON vo.NUM=bt.NUM
	INNER JOIN VOL_Opportunity_Description vod
		ON vo.VNUM=vod.VNUM AND vod.LangID=0
	INNER JOIN GBL_BaseTable_Description btd
		ON btd.NUM=bt.NUM AND btd.LangID in (0,2)
	INNER JOIN GBL_Agency a
		ON a.AgencyCode=vo.RECORD_OWNER
	INNER JOIN STP_Language l
		ON btd.LangID=l.LangID
WHERE vo.MemberID=@MemberID AND a.GetInvolvedUser=@GetInvolvedUser AND a.GetInvolvedToken=@GetInvolvedToken AND a.GetInvolvedSite=@GetInvolvedSite
	AND EXISTS(SELECT * FROM VOL_OP_CommunitySet WHERE VNUM=vo.VNUM AND CommunitySetID=a.GetInvolvedCommunitySet)
	AND vod.DELETION_DATE IS NULL OR vod.DELETION_DATE > GETDATE()

DELETE FROM @Opportunities
WHERE ViewInfo IS NULL

SELECT * FROM @Opportunities

SET NOCOUNT OFF




GO

GRANT EXECUTE ON  [dbo].[sp_VOL_GetInvolved_Sync] TO [cioc_maintenance_role]
GO
