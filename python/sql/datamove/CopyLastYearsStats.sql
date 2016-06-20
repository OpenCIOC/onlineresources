SELECT COUNT(*) FROM CIC_Stats_RSN WHERE AccessDate >= '2014-01-01' AND AccessDate < '2015-01-01'

DECLARE @STATFIRSTID int, @STATLASTID int, @STATCURRENTID int, @INCREMENT int

SELECT @STATFIRSTID = MIN(Log_ID), @STATLASTID = MAX(Log_ID) FROM CIC_Stats_RSN WHERE AccessDate >=  '2014-01-01' AND AccessDate < '2015-01-01'
PRINT N'GETTING ROWS FROM ' + CAST(@STATFIRSTID AS nvarchar) + N' TO ' + CAST(@STATLASTID AS nvarchar)

SET @STATCURRENTID = @STATFIRSTID
SET @INCREMENT = 10000

WHILE @STATCURRENTID <= @STATLASTID BEGIN
	PRINT N'SELECT FROM ' + CAST(@STATCURRENTID AS nvarchar) + N' TO ' + CAST(@STATCURRENTID + @INCREMENT AS nvarchar)

	INSERT INTO OntarioCioc_2012_11.dbo.CIC_Stats_RSN
			(MemberID, AccessDate, IPAddress, RSN, LangID, User_ID, ViewType, RobotID, API)
SELECT 
	stat.MemberID,
	AccessDate,
	IPAddress, 
	(SELECT bt2.RSN FROM GBL_BaseTable bt LEFT JOIN OntarioCioc_2012_11.dbo.GBL_BaseTable bt2 ON bt.NUM=bt2.NUM WHERE bt.RSN = stat.RSN),
	stat.LangID, 
	(SELECT CASE WHEN stat.User_ID IS NULL THEN NULL ELSE ISNULL(u2.User_ID, -1) END FROM GBL_Users u LEFT JOIN OntarioCioc_2012_11.dbo.GBL_Users u2 ON u.UserUID=u2.UserUID WHERE u.User_ID=stat.User_ID),
	(SELECT vw.ViewType FROM CIC_View_Description vwd 
		LEFT JOIN OntarioCioc_2012_11.dbo.CIC_View_Description vwd2
			ON vwd2.ViewName=vwd.ViewName AND vwd2.LangID=0
		LEFT JOIN OntarioCioc_2012_11.dbo.CIC_View vw 
			ON vwd2.ViewType=vw.ViewType AND vw.MemberID=stat.MemberID
	 WHERE vwd.ViewType=stat.ViewType AND vwd.LangID = 0 AND vw.MemberID=stat.MemberID),
	stat.RobotID, stat.API
 FROM CIC_Stats_RSN stat 
 WHERE AccessDate >=  '2014-01-01' AND AccessDate < '2015-01-01' AND Log_ID >= @STATCURRENTID AND Log_ID < (@STATCURRENTID + @INCREMENT)


	SET @STATCURRENTID = @STATCURRENTID + @INCREMENT
END


SELECT COUNT(*) FROM VOL_Stats_OPID WHERE AccessDate >=  '2014-01-01' AND AccessDate < '2015-01-01'
SELECT @STATFIRSTID = MIN(Log_ID), @STATLASTID = MAX(Log_ID) FROM VOL_Stats_OPID WHERE AccessDate >=  '2014-01-01' AND AccessDate < '2015-01-01'
PRINT N'GETTING ROWS FROM ' + CAST(@STATFIRSTID AS nvarchar) + N' TO ' + CAST(@STATLASTID AS nvarchar)

SET @STATCURRENTID = @STATFIRSTID
SET @INCREMENT = 10000

WHILE @STATCURRENTID <= @STATLASTID BEGIN
	PRINT N'SELECT FROM ' + CAST(@STATCURRENTID AS nvarchar) + N' TO ' + CAST(@STATCURRENTID + @INCREMENT AS nvarchar)

	INSERT INTO OntarioCioc_2012_11.dbo.VOL_Stats_OPID
			(MemberID, AccessDate, IPAddress, OP_ID, LangID, User_ID, ViewType, RobotID, API )
SELECT
	stat.MemberID,
	AccessDate,
	IPAddress, 
	(SELECT vo2.OP_ID FROM VOL_Opportunity vo LEFT JOIN OntarioCioc_2012_11.dbo.VOL_Opportunity vo2 ON vo.VNUM=vo2.VNUM WHERE vo.OP_ID = stat.OP_ID),
	stat.LangID, 
	(SELECT CASE WHEN stat.User_ID IS NULL THEN NULL ELSE ISNULL(u2.User_ID, -1) END FROM GBL_Users u LEFT JOIN OntarioCioc_2012_11.dbo.GBL_Users u2 ON u.UserUID=u2.UserUID WHERE u.User_ID=stat.User_ID),
	(SELECT vw.ViewType FROM VOL_View_Description vwd 
		LEFT JOIN OntarioCioc_2012_11.dbo.VOL_View_Description vwd2
			ON vwd2.ViewName=vwd.ViewName AND vwd2.LangID=0
		LEFT JOIN OntarioCioc_2012_11.dbo.VOL_View vw 
			ON vwd2.ViewType=vw.ViewType AND vw.MemberID=stat.MemberID
	 WHERE vwd.ViewType=stat.ViewType AND vwd.LangID = 0 AND vw.MemberID=stat.MemberID),
	stat.RobotID, stat.API
 FROM VOL_Stats_OPID stat 
 WHERE AccessDate >= '2014-01-01' AND AccessDate <  '2015-01-01' AND Log_ID >= @STATCURRENTID AND Log_ID < (@STATCURRENTID + @INCREMENT)


	SET @STATCURRENTID = @STATCURRENTID + @INCREMENT
END
