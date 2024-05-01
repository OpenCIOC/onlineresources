SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_YesVolunteer]
    @MemberID int,
    @VNUM varchar(10),
    @DefaultViewType int,
    @ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON;

DECLARE @Error int;
SET @Error = 0;

-- Member ID given ?
IF @MemberID IS NULL BEGIN
    SET @Error = 10; -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS (SELECT  * FROM  dbo.STP_Member WHERE MemberID = @MemberID) BEGIN
    SET @Error = 3; -- No Such Record
END;

SELECT
    vo.RECORD_OWNER,
    vod.POSITION_TITLE,
    vod.DUTIES,
    vod.APPLICATION_QUESTION_1,
    vod.APPLICATION_QUESTION_2,
    vod.APPLICATION_QUESTION_3,
    CASE WHEN vo.DISPLAY_UNTIL IS NULL OR   vo.DISPLAY_UNTIL > GETDATE() THEN 0 ELSE 1 END AS EXPIRED,
    dbo.fn_VOL_RecordInView(@VNUM, @ViewType, @@LANGID, 0, GETDATE()) AS IN_VIEW,
    dbo.fn_VOL_RecordInView(@VNUM, @DefaultViewType, @@LANGID, 0, GETDATE()) AS IN_DEFAULT_VIEW,
    c.CMP_Name AS CONTACT_NAME,
    c.TITLE AS CONTACT_TITLE,
    c.ORG AS CONTACT_ORG,
    c.CMP_PhoneFull AS CONTACT_PHONE,
    c.CMP_Fax AS CONTACT_FAX,
    c.EMAIL AS CONTACT_EMAIL,
    dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM, btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5, btd.LOCATION_NAME, btd.SERVICE_NAME_LEVEL_1, btd.SERVICE_NAME_LEVEL_2, bt.DISPLAY_LOCATION_NAME, bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
	(SELECT memd.VolunteerApplicationSurvey FROM dbo.STP_Member_Description memd WHERE memd.MemberID=@MemberID AND memd.LangID=@@LANGID) AS VolunteerApplicationSurvey
FROM    dbo.VOL_Opportunity vo
    INNER JOIN dbo.VOL_Opportunity_Description vod
        ON vo.VNUM = vod.VNUM
            AND vod.LangID = (
                    SELECT    TOP 1  LangID
                    FROM  dbo.VOL_Opportunity_Description
                    WHERE VNUM = vo.VNUM
                    ORDER BY
                        CASE WHEN LangID = @@LANGID THEN 0 ELSE 1 END,
                        LangID
                )
    INNER JOIN dbo.GBL_BaseTable bt
        ON vo.NUM = bt.NUM
    LEFT JOIN dbo.GBL_BaseTable_Description btd
        ON bt.NUM = btd.NUM
            AND btd.LangID = (
                    SELECT  TOP 1   LangID
                    FROM    dbo.GBL_BaseTable_Description
                    WHERE   NUM = btd.NUM
                    ORDER BY
                        CASE WHEN LangID = vod.LangID THEN 0 ELSE 1 END,
                        LangID
                )
    LEFT JOIN dbo.GBL_Contact c
        ON vo.VNUM = c.VolVNUM AND  c.VolContactType = 'CONTACT' AND c.LangID = vod.LangID
WHERE   vo.VNUM = @VNUM;

RETURN @Error;

SET NOCOUNT OFF;




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_YesVolunteer] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_YesVolunteer] TO [cioc_vol_search_role]
GO
