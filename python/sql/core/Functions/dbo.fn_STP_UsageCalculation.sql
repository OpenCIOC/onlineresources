SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_STP_UsageCalculation] (
	@MemberID int,
	@StartRange date,
	@EndRange date,
	@IncludeCIC bit,
	@IncludeVOL bit,
	@OnlyAgencyCodes varchar(500),
	@ExcludeAgencyCodes varchar(500)
)
RETURNS @UsageTable TABLE (
	[Item] varchar(20),
	[ItemDescription] varchar(100),
	[OwnerCode] varchar(30),
	[MemberName] nvarchar(200),
	[ItemCount] decimal(10,1)
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.7.4
	Checked by: KL
	Checked on: 29-Mar-2016
	Action: NO ACTION REQUIRED
*/

IF @EndRange IS NULL SET @EndRange = GETDATE()
IF @StartRange IS NULL SET @StartRange = DATEADD(QUARTER,-1,GETDATE())
SET @IncludeCIC = ISNULL(@IncludeCIC,0)
SET @IncludeVOL = ISNULL(@IncludeVOL,0)

INSERT INTO @UsageTable
SELECT
	'1-BASE' AS Item,
	'Basic Support' AS ItemDescription,
	'[N/A]' AS OwnerCode,
	CASE
		WHEN @IncludeCIC=0 THEN memd.MemberNameVOL
		WHEN @IncludeVOL=0 THEN memd.MemberNameCIC
		ELSE memd.MemberName
	END AS MemberName,
	CASE
		WHEN @IncludeCIC=1 AND @IncludeVOL=1 THEN 1
		WHEN @IncludeCIC=0 THEN .5
		WHEN @IncludeVOL=0 AND mem.UseVOL=1 THEN .5
		ELSE 1 
	END AS ItemCount
FROM STP_Member mem
INNER JOIN STP_Member_Description memd ON memd.MemberID = mem.MemberID
WHERE (memd.MemberID=@MemberID OR @MemberID IS NULL)
	AND memd.LangID=@@LANGID

UNION SELECT
	'2-USER' AS Item,
	'User' AS ItemDescription,
	CAST(Agency AS varchar(100)) AS OwnerCode,
	CASE
		WHEN @IncludeCIC=0 THEN memd.MemberNameVOL
		WHEN @IncludeVOL=0 THEN memd.MemberNameCIC
		ELSE memd.MemberName
	END AS MemberName,
	COUNT(
		CASE
			WHEN u.SL_ID_CIC IS NULL AND u.SL_ID_VOL IS NULL THEN 1
			WHEN @IncludeCIC=1 AND u.SL_ID_CIC IS NOT NULL THEN 1
			WHEN @IncludeVOL=1 AND u.SL_ID_VOL IS NOT NULL THEN 1
		END
		) AS ItemCount
FROM dbo.GBL_Users u
INNER JOIN STP_Member_Description memd ON u.MemberID_Cache=memd.MemberID AND memd.LangID=@@LANGID
WHERE (MemberID_Cache=@MemberID OR @MemberID IS NULL)
	AND TechAdmin=0
	AND (@OnlyAgencyCodes IS NULL
		OR Agency IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@OnlyAgencyCodes,','))
		)
	AND (@ExcludeAgencyCodes IS NULL
		OR Agency NOT IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@ExcludeAgencyCodes,','))
		)
	AND Inactive=0
GROUP BY MemberName, MemberNameVOL, MemberNameCIC, Agency
HAVING COUNT(
		CASE
			WHEN u.SL_ID_CIC IS NULL AND u.SL_ID_VOL IS NULL THEN 1
			WHEN @IncludeCIC=1 AND u.SL_ID_CIC IS NOT NULL THEN 1
			WHEN @IncludeVOL=1 AND u.SL_ID_VOL IS NOT NULL THEN 1
		END
		) > 0

UNION SELECT
	'3-RECORD' AS Item,
	'CIC Basic Record, Excluding Deleted' AS ItemDescription,
	CAST(RECORD_OWNER AS varchar(100)) AS OwnerCode,
	CASE
		WHEN @IncludeCIC=0 THEN memd.MemberNameVOL
		WHEN @IncludeVOL=0 THEN memd.MemberNameCIC
		ELSE memd.MemberName
	END AS MemberName,
	COUNT(*) AS ItemCount
FROM dbo.GBL_BaseTable bt
INNER JOIN STP_Member_Description memd ON bt.MemberID=memd.MemberID AND memd.LangID=@@LANGID
WHERE (bt.MemberID=@MemberID OR @MemberID IS NULL)
	AND @IncludeCIC=1
	AND (@OnlyAgencyCodes IS NULL
		OR bt.RECORD_OWNER IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@OnlyAgencyCodes,','))
		)
	AND (@ExcludeAgencyCodes IS NULL
		OR bt.RECORD_OWNER NOT IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@ExcludeAgencyCodes,','))
		)
	AND EXISTS(SELECT * FROM dbo.GBL_BaseTable_Description btd WHERE btd.NUM=bt.NUM AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > @EndRange))
GROUP BY MemberName, MemberNameVOL, MemberNameCIC, RECORD_OWNER
HAVING COUNT(*) > 0

UNION SELECT
	'4-RECORDLANG' AS Item,
	'CIC Record - Additional Language, Excluding Deleted' AS ItemDescription,
	CAST(RECORD_OWNER AS varchar(100)) AS OwnerCode,
	CASE
		WHEN @IncludeCIC=0 THEN memd.MemberNameVOL
		WHEN @IncludeVOL=0 THEN memd.MemberNameCIC
		ELSE memd.MemberName
	END AS MemberName,
	COUNT(*)-COUNT(DISTINCT bt.NUM) AS ItemCount
FROM dbo.GBL_BaseTable bt
INNER JOIN dbo.GBL_BaseTable_Description btd ON btd.NUM=bt.NUM
INNER JOIN STP_Member_Description memd ON bt.MemberID=memd.MemberID AND memd.LangID=@@LANGID
WHERE (bt.MemberID=@MemberID OR @MemberID IS NULL)
	AND @IncludeCIC=1
	AND (@OnlyAgencyCodes IS NULL
		OR bt.RECORD_OWNER IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@OnlyAgencyCodes,','))
		)
	AND (@ExcludeAgencyCodes IS NULL
		OR bt.RECORD_OWNER NOT IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@ExcludeAgencyCodes,','))
		)
	AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > @EndRange)
GROUP BY MemberName, MemberNameVOL, MemberNameCIC, RECORD_OWNER
HAVING COUNT(*)-COUNT(DISTINCT bt.NUM) > 0

UNION SELECT
	'5-RECORDDEL' AS Item,
	'CIC Record - Deleted' AS ItemDescription,
	CAST(RECORD_OWNER AS varchar(100)) AS OwnerCode,
	CASE
		WHEN @IncludeCIC=0 THEN memd.MemberNameVOL
		WHEN @IncludeVOL=0 THEN memd.MemberNameCIC
		ELSE memd.MemberName
	END AS MemberName,
	COUNT(*) AS ItemCount
FROM dbo.GBL_BaseTable bt
INNER JOIN dbo.GBL_BaseTable_Description btd ON btd.NUM=bt.NUM
INNER JOIN STP_Member_Description memd ON bt.MemberID=memd.MemberID AND memd.LangID=@@LANGID
WHERE (bt.MemberID=@MemberID OR @MemberID IS NULL)
	AND @IncludeCIC=1
	AND (@OnlyAgencyCodes IS NULL
		OR bt.RECORD_OWNER IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@OnlyAgencyCodes,','))
		)
	AND (@ExcludeAgencyCodes IS NULL
		OR bt.RECORD_OWNER NOT IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@ExcludeAgencyCodes,','))
		)
	AND btd.DELETION_DATE < @EndRange
GROUP BY MemberName, MemberNameVOL, MemberNameCIC, RECORD_OWNER
HAVING COUNT(*) > 0

UNION SELECT
	'6-ACCESS' AS Item,
	'CIC Record Access' AS ItemDescription,
	ISNULL(CASE WHEN bt.MemberID=@MemberID OR @MemberID IS NULL THEN CAST(RECORD_OWNER AS varchar(100)) ELSE NULL END,'[Shared or Missing/Deleted]') AS OwnerCode,
		CASE
		WHEN @IncludeCIC=0 THEN memd.MemberNameVOL
		WHEN @IncludeVOL=0 THEN memd.MemberNameCIC
		ELSE memd.MemberName
	END AS MemberName,
	COUNT(*) AS ItemCount
FROM dbo.CIC_Stats_RSN st
INNER JOIN STP_Member_Description memd ON st.MemberID=memd.MemberID AND memd.LangID=@@LANGID
LEFT JOIN dbo.GBL_BaseTable bt ON bt.RSN = st.RSN
LEFT JOIN dbo.GBL_Agency a ON a.AgencyCode = bt.RECORD_OWNER
WHERE (st.MemberID=@MemberID OR @MemberID IS NULL)
	AND @IncludeCIC=1
	AND (@OnlyAgencyCodes IS NULL
		OR bt.RECORD_OWNER IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@OnlyAgencyCodes,','))
		)
	AND (@ExcludeAgencyCodes IS NULL
		OR bt.RECORD_OWNER IS NULL
		OR bt.RECORD_OWNER NOT IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@ExcludeAgencyCodes,','))
		)
	AND st.AccessDate BETWEEN @StartRange AND @EndRange
GROUP BY MemberName, MemberNameVOL, MemberNameCIC, 
	CASE WHEN bt.MemberID=@MemberID OR @MemberID IS NULL THEN CAST(RECORD_OWNER AS varchar(100)) ELSE NULL END
HAVING COUNT(*) > 0

UNION SELECT
	'3-RECORD' AS Item,
	'Volunteer Record Basic, Excluding Deleted/Expired' AS ItemDescription,
	CAST(RECORD_OWNER AS varchar(100)) AS OwnerCode,
	CASE
		WHEN @IncludeCIC=0 THEN memd.MemberNameVOL
		WHEN @IncludeVOL=0 THEN memd.MemberNameCIC
		ELSE memd.MemberName
	END AS MemberName,
	COUNT(*) AS ItemCount
FROM dbo.VOL_Opportunity bt
INNER JOIN STP_Member_Description memd ON bt.MemberID=memd.MemberID AND memd.LangID=@@LANGID
WHERE (bt.MemberID=@MemberID OR @MemberID IS NULL)
	AND @IncludeVOL=1
	AND (@OnlyAgencyCodes IS NULL
		OR bt.RECORD_OWNER IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@OnlyAgencyCodes,','))
		)
	AND (@ExcludeAgencyCodes IS NULL
		OR bt.RECORD_OWNER NOT IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@ExcludeAgencyCodes,','))
		)
	AND EXISTS(SELECT * FROM dbo.VOL_Opportunity_Description btd
		WHERE btd.VNUM=bt.VNUM
			AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > @EndRange)
			AND (bt.DISPLAY_UNTIL IS NULL OR bt.DISPLAY_UNTIL > @EndRange)
			)
GROUP BY MemberName, MemberNameVOL, MemberNameCIC, RECORD_OWNER
HAVING COUNT(*) > 0

UNION SELECT
	'4-RECORDLANG' AS Item,
	'Volunteer Record - Additional Language, Excluding Deleted/Expired' AS ItemDescription,
	CAST(RECORD_OWNER AS varchar(100)) AS OwnerCode,
	CASE
		WHEN @IncludeCIC=0 THEN memd.MemberNameVOL
		WHEN @IncludeVOL=0 THEN memd.MemberNameCIC
		ELSE memd.MemberName
	END AS MemberName,
	COUNT(*)-COUNT(DISTINCT bt.VNUM) AS ItemCount
FROM dbo.VOL_Opportunity bt
INNER JOIN dbo.VOL_Opportunity_Description btd ON btd.VNUM=bt.VNUM
INNER JOIN STP_Member_Description memd ON bt.MemberID=memd.MemberID AND memd.LangID=@@LANGID
WHERE (bt.MemberID=@MemberID OR @MemberID IS NULL)
	AND @IncludeVOL=1
	AND (@OnlyAgencyCodes IS NULL
		OR bt.RECORD_OWNER IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@OnlyAgencyCodes,','))
		)
	AND (@ExcludeAgencyCodes IS NULL
		OR bt.RECORD_OWNER NOT IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@ExcludeAgencyCodes,','))
		)
	AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > @EndRange)
	AND (bt.DISPLAY_UNTIL IS NULL OR bt.DISPLAY_UNTIL > @EndRange)
GROUP BY MemberName, MemberNameVOL, MemberNameCIC, RECORD_OWNER
HAVING COUNT(*)-COUNT(DISTINCT bt.VNUM) > 0

UNION SELECT
	'5-RECORDDEL' AS Item,
	'Volunteer Record - Deleted/Expired' AS ItemDescription,
	CAST(RECORD_OWNER AS varchar(100)) AS OwnerCode,
	CASE
		WHEN @IncludeCIC=0 THEN memd.MemberNameVOL
		WHEN @IncludeVOL=0 THEN memd.MemberNameCIC
		ELSE memd.MemberName
	END AS MemberName,
	COUNT(*) AS ItemCount
FROM dbo.VOL_Opportunity bt
INNER JOIN dbo.VOL_Opportunity_Description btd ON btd.VNUM=bt.VNUM
INNER JOIN STP_Member_Description memd ON bt.MemberID=memd.MemberID AND memd.LangID=@@LANGID
WHERE (bt.MemberID=@MemberID OR @MemberID IS NULL)
	AND @IncludeVOL=1
	AND (@OnlyAgencyCodes IS NULL
		OR bt.RECORD_OWNER IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@OnlyAgencyCodes,','))
		)
	AND (@ExcludeAgencyCodes IS NULL
		OR bt.RECORD_OWNER NOT IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@ExcludeAgencyCodes,','))
		)
	AND (btd.DELETION_DATE < @EndRange OR bt.DISPLAY_UNTIL < @EndRange)
GROUP BY MemberName, MemberNameVOL, MemberNameCIC, RECORD_OWNER
HAVING COUNT(*) > 0

UNION SELECT
	'6-ACCESS' AS Item,
	'Volunteer Record Access' AS ItemDescription,
	ISNULL(CASE WHEN bt.MemberID=@MemberID OR @MemberID IS NULL THEN CAST(RECORD_OWNER AS varchar(100)) ELSE NULL END,'[Shared or Missing/Deleted]') AS OwnerCode,
	CASE
		WHEN @IncludeCIC=0 THEN memd.MemberNameVOL
		WHEN @IncludeVOL=0 THEN memd.MemberNameCIC
		ELSE memd.MemberName
	END AS MemberName,
	COUNT(*) AS ItemCount
FROM dbo.VOL_Stats_OPID st
INNER JOIN STP_Member_Description memd ON st.MemberID=memd.MemberID AND memd.LangID=@@LANGID
LEFT JOIN dbo.VOL_Opportunity bt ON bt.OP_ID = st.OP_ID
LEFT JOIN dbo.GBL_Agency a ON a.AgencyCode = bt.RECORD_OWNER
WHERE (st.MemberID=@MemberID OR @MemberID IS NULL)
	AND @IncludeVOL=1
	AND (@OnlyAgencyCodes IS NULL
		OR bt.RECORD_OWNER IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@OnlyAgencyCodes,','))
		)
	AND (@ExcludeAgencyCodes IS NULL
		OR bt.RECORD_OWNER IS NULL
		OR bt.RECORD_OWNER NOT IN (SELECT ItemID COLLATE Latin1_General_100_CI_AI FROM dbo.fn_GBL_ParseVarCharIDList(@ExcludeAgencyCodes,','))
		)
	AND st.AccessDate BETWEEN @StartRange AND @EndRange
GROUP BY MemberName, MemberNameVOL, MemberNameCIC, 
	CASE WHEN bt.MemberID=@MemberID OR @MemberID IS NULL THEN CAST(RECORD_OWNER AS varchar(100)) ELSE NULL END
HAVING COUNT(*) > 0

UNION SELECT
	'7-PROFILE' AS Item,
	'Volunteer Profile' AS ItemDescription,
	'[N/A]' AS OwnerCode,
	CASE
		WHEN @IncludeCIC=0 THEN memd.MemberNameVOL
		WHEN @IncludeVOL=0 THEN memd.MemberNameCIC
		ELSE memd.MemberName
	END AS MemberName,
	COUNT(*) AS ItemCount
FROM dbo.VOL_Profile p
INNER JOIN STP_Member_Description memd ON p.MemberId=memd.MemberID AND memd.LangID=@@LANGID
WHERE (p.MemberID=@MemberID OR @MemberID IS NULL)
	AND @IncludeVOL=1
	AND p.Active=1
GROUP BY MemberName, MemberNameVOL, MemberNameCIC
HAVING COUNT(*) > 0

RETURN

END

GO
