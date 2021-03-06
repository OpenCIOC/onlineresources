SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_Schedule_l_Upcoming]
	@ViewType INT,
	@HTTPVals VARCHAR(500),
	@PathToStart VARCHAR(50)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked by: KL
	Checked on: 26-Jan-2018
	Action: REVIEW REQUIRED; needs efficiency review, code simplification
*/

DECLARE	@MemberID int,
		@CanSeeNonPublic bit,
		@HidePastDueBy int,
		@PB_ID int
		
SELECT	@MemberID=MemberID,
		@CanSeeNonPublic=CanSeeNonPublic,
		@HidePastDueBy=HidePastDueBy,
		@PB_ID=PB_ID
FROM CIC_View
WHERE ViewType=@ViewType

DECLARE @EOM1 DATE, @EOM2 DATE, @EOM3 DATE
DECLARE @SOM1 DATE, @SOM2 DATE, @SOM3 DATE

SET @EOM1 = EOMONTH(GETDATE())
SET @EOM2 = EOMONTH(DATEADD(m,1,GETDATE()))
SET @EOM3 = EOMONTH(DATEADD(m,2,GETDATE()))
SET @SOM1 = GETDATE()
SET @SOM2 = DATEADD(d,1,@EOM1)
SET @SOM3 = DATEADD(d,1,@EOM2)

DECLARE @InSched TABLE (
	SchedID INT PRIMARY KEY,
	M1W1 date,
	M1W2 date,
	M2W1 date,
	M2W2 date,
	M3W1 date,
	M3W2 date
	)

DECLARE @ExpandWeekly TABLE (
	SchedID INT NOT NULL,
	SchedMonth TINYINT,
	PotentialDay DATE NOT NULL
	
)

/*
Generates 2 potential "first" valid weeks in which weekly events may occur in the given months
*/
INSERT INTO @InSched
SELECT s.SchedID,
	CASE WHEN s.START_DATE < @EOM1 AND (s.END_DATE IS NULL OR s.END_DATE >= @SOM1) THEN DATEADD(wk,(DATEDIFF(wk,DATEADD(dd, -(DATEPART(dw, s.START_DATE)-1), s.START_DATE),CASE WHEN s.START_DATE > @SOM1 THEN s.START_DATE ELSE @SOM1 END) / s.RECURS_EVERY) * s.RECURS_EVERY,DATEADD(dd, -(DATEPART(dw, s.START_DATE)-1), s.START_DATE)) ELSE NULL END AS M1W1,
	CASE WHEN s.START_DATE < @EOM1 AND (s.END_DATE IS NULL OR s.END_DATE >= @SOM1) THEN DATEADD(wk,(DATEDIFF(wk,DATEADD(dd, -(DATEPART(dw, s.START_DATE)-1), s.START_DATE),CASE WHEN s.START_DATE > @SOM1 THEN s.START_DATE ELSE @SOM1 END) / s.RECURS_EVERY + 1) * s.RECURS_EVERY,DATEADD(dd, -(DATEPART(dw, s.START_DATE)-1), s.START_DATE)) ELSE NULL END AS M1W2,
	CASE WHEN s.START_DATE < @EOM2 AND (s.END_DATE IS NULL OR s.END_DATE >= @SOM2) THEN DATEADD(wk,(DATEDIFF(wk,DATEADD(dd, -(DATEPART(dw, s.START_DATE)-1), s.START_DATE),CASE WHEN s.START_DATE > @SOM2 THEN s.START_DATE ELSE @SOM2 END) / s.RECURS_EVERY) * s.RECURS_EVERY,DATEADD(dd, -(DATEPART(dw, s.START_DATE)-1), s.START_DATE)) ELSE NULL END AS M2W1,
	CASE WHEN s.START_DATE < @EOM2 AND (s.END_DATE IS NULL OR s.END_DATE >= @SOM2) THEN DATEADD(wk,(DATEDIFF(wk,DATEADD(dd, -(DATEPART(dw, s.START_DATE)-1), s.START_DATE),CASE WHEN s.START_DATE > @SOM2 THEN s.START_DATE ELSE @SOM2 END) / s.RECURS_EVERY + 1) * s.RECURS_EVERY,DATEADD(dd, -(DATEPART(dw, s.START_DATE)-1), s.START_DATE)) ELSE NULL END AS M2W2,
	CASE WHEN s.START_DATE < @EOM3 AND (s.END_DATE IS NULL OR s.END_DATE >= @SOM3) THEN DATEADD(wk,(DATEDIFF(wk,DATEADD(dd, -(DATEPART(dw, s.START_DATE)-1), s.START_DATE),CASE WHEN s.START_DATE > @SOM3 THEN s.START_DATE ELSE @SOM3 END) / s.RECURS_EVERY) * s.RECURS_EVERY,DATEADD(dd, -(DATEPART(dw, s.START_DATE)-1), s.START_DATE)) ELSE NULL END AS M3W1,
	CASE WHEN s.START_DATE < @EOM3 AND (s.END_DATE IS NULL OR s.END_DATE >= @SOM3) THEN DATEADD(wk,(DATEDIFF(wk,DATEADD(dd, -(DATEPART(dw, s.START_DATE)-1), s.START_DATE),CASE WHEN s.START_DATE > @SOM3 THEN s.START_DATE ELSE @SOM3 END) / s.RECURS_EVERY + 1) * s.RECURS_EVERY,DATEADD(dd, -(DATEPART(dw, s.START_DATE)-1), s.START_DATE)) ELSE NULL END AS M3W2
  FROM [dbo].[GBL_Schedule] s
WHERE START_DATE <= @EOM3
	AND (
		END_DATE >= GETDATE()
		OR (END_DATE IS NULL AND s.RECURS_EVERY<>0)
		OR (s.START_DATE >= GETDATE())
		)
	AND s.RECURS_DAY_OF_WEEK=1
	AND s.GblNUM IS NOT NULL

/*
Likely want to review this code to remove all the union queries
(for example via pivot table to normalize weekday data)
Fine for now, tests correct and no performance issues evident
*/
INSERT INTO @ExpandWeekly
(
    SchedID,
    SchedMonth,
    PotentialDay
)
SELECT s.SchedID,
		1,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (6 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_1 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		1,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (7 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_2 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		1,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (8 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_3 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		1,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (9 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_4 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		1,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (10 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_5 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		1,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (11 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_6 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		1,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (12 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_7 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		2,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (6 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM2), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_1 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		2,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (7 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM2), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_2 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		2,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (8 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM2), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_3 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		2,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (9 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM2), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_4 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		2,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (10 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM2), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_5 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		2,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (11 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM2), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_6 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		2,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (12 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM2), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_7 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		3,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (6 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM3), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_1 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		3,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (7 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM3), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_2 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		3,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (8 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM3), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_3 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		3,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (9 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM3), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_4 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		3,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (10 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM3), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_5 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		3,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (11 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM3), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_6 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL
UNION SELECT s.SchedID,
		3,
		(SELECT DATEADD(DAY, 7 * (s.RECURS_XTH_WEEKDAY_OF_MONTH - 1) + (12 - DATEDIFF(DAY, '17530101', DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM3), '19000101')) % 7) % 7, DATEADD(MONTH, DATEDIFF(MONTH, s.RECURS_XTH_WEEKDAY_OF_MONTH, @SOM1), '19000101')))
	FROM [dbo].[GBL_Schedule] s
	WHERE s.RECURS_WEEKDAY_7 = 1
		AND s.RECURS_XTH_WEEKDAY_OF_MONTH  IS NOT NULL

DELETE e
FROM @ExpandWeekly e
INNER JOIN dbo.GBL_Schedule s ON s.SchedID = e.SchedID
WHERE (SchedMonth = 1 AND NOT (PotentialDay  >= @SOM1 AND PotentialDay <= @EOM1))
	OR (SchedMonth = 2 AND NOT (PotentialDay  >= @SOM2 AND PotentialDay <= @EOM2))
	OR (SchedMonth = 3 AND NOT (PotentialDay  >= @SOM3 AND PotentialDay <= @EOM3))
	OR PotentialDay < s.START_DATE
	OR (s.END_DATE IS NOT NULL AND PotentialDay > END_DATE)


/*
Likely want to review this code to remove all the union queries
(for example via pivot table to normalize weekday data)
Fine for now, tests correct and no performance issues evident
*/
INSERT INTO @ExpandWeekly
(
    SchedID,
    SchedMonth,
    PotentialDay
)
SELECT s.SchedID,
		1,
		DATEADD(DAY,0,sl.M1W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_1 = 1
		AND DATEADD(DAY,0,sl.M1W1) >= @SOM1
		AND DATEADD(DAY,0,sl.M1W1) <= @EOM1
UNION SELECT s.SchedID,
		1,
		DATEADD(DAY,0,sl.M1W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_1 = 1
		AND DATEADD(DAY,0,sl.M1W2) >= @SOM1
		AND DATEADD(DAY,0,sl.M1W2) <= @EOM1
UNION SELECT s.SchedID,
		1,
		DATEADD(DAY,1,sl.M1W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_2 = 1
		AND DATEADD(DAY,1,sl.M1W1) >= @SOM1
		AND DATEADD(DAY,1,sl.M1W1) <= @EOM1
UNION SELECT s.SchedID,
		1,
		DATEADD(DAY,1,sl.M1W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_2 = 1
		AND DATEADD(DAY,1,sl.M1W2) >= @SOM1
		AND DATEADD(DAY,1,sl.M1W2) <= @EOM1
UNION SELECT s.SchedID,
		1,
		DATEADD(DAY,2,sl.M1W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_3 = 1
		AND DATEADD(DAY,2,sl.M1W1) >= @SOM1
		AND DATEADD(DAY,2,sl.M1W1) <= @EOM1
UNION SELECT s.SchedID,
		1,
		DATEADD(DAY,2,sl.M1W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_3 = 1
		AND DATEADD(DAY,2,sl.M1W2) >= @SOM1
		AND DATEADD(DAY,2,sl.M1W2) <= @EOM1
UNION SELECT s.SchedID,
		1,
		DATEADD(DAY,3,sl.M1W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_4 = 1
		AND DATEADD(DAY,3,sl.M1W1) >= @SOM1
		AND DATEADD(DAY,3,sl.M1W1) <= @EOM1
UNION SELECT s.SchedID,
		1,
		DATEADD(DAY,3,sl.M1W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_4 = 1
		AND DATEADD(DAY,3,sl.M1W2) >= @SOM1
		AND DATEADD(DAY,3,sl.M1W2) <= @EOM1
UNION SELECT s.SchedID,
		1,
		DATEADD(DAY,5,sl.M1W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_5 = 1
		AND DATEADD(DAY,4,sl.M1W1) >= @SOM1
		AND DATEADD(DAY,4,sl.M1W1) <= @EOM1
UNION SELECT s.SchedID,
		1,
		DATEADD(DAY,4,sl.M1W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_5 = 1
		AND DATEADD(DAY,4,sl.M1W2) >= @SOM1
		AND DATEADD(DAY,4,sl.M1W2) <= @EOM1
UNION SELECT s.SchedID,
		1,
		DATEADD(DAY,5,sl.M1W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_6 = 1
		AND DATEADD(DAY,5,sl.M1W1) >= @SOM1
		AND DATEADD(DAY,5,sl.M1W1) <= @EOM1
UNION SELECT s.SchedID,
		1,
		DATEADD(DAY,5,sl.M1W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_6 = 1
		AND DATEADD(DAY,5,sl.M1W2) >= @SOM1
		AND DATEADD(DAY,5,sl.M1W2) <= @EOM1
UNION SELECT s.SchedID,
		1,
		DATEADD(DAY,6,sl.M1W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_7 = 1
		AND DATEADD(DAY,6,sl.M1W1) >= @SOM1
		AND DATEADD(DAY,6,sl.M1W1) <= @EOM1
UNION SELECT s.SchedID,
		1,
		DATEADD(DAY,6,sl.M1W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_7 = 1
		AND DATEADD(DAY,6,sl.M1W2) >= @SOM1
		AND DATEADD(DAY,6,sl.M1W2) <= @EOM1
UNION SELECT s.SchedID,
		2,
		DATEADD(DAY,0,sl.M2W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_1 = 1
		AND DATEADD(DAY,0,sl.M2W1) >= @SOM2
		AND DATEADD(DAY,0,sl.M2W1) <= @EOM2
UNION SELECT s.SchedID,
		2,
		DATEADD(DAY,0,sl.M2W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_1 = 1
		AND DATEADD(DAY,0,sl.M2W2) >= @SOM2
		AND DATEADD(DAY,0,sl.M2W2) <= @EOM2
UNION SELECT s.SchedID,
		2,
		DATEADD(DAY,1,sl.M2W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_2 = 1
		AND DATEADD(DAY,1,sl.M2W1) >= @SOM2
		AND DATEADD(DAY,1,sl.M2W1) <= @EOM2
UNION SELECT s.SchedID,
		2,
		DATEADD(DAY,1,sl.M2W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_2 = 1
		AND DATEADD(DAY,1,sl.M2W2) >= @SOM2
		AND DATEADD(DAY,1,sl.M2W2) <= @EOM2
UNION SELECT s.SchedID,
		2,
		DATEADD(DAY,2,sl.M2W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_3 = 1
		AND DATEADD(DAY,2,sl.M2W1) >= @SOM2
		AND DATEADD(DAY,2,sl.M2W1) <= @EOM2
UNION SELECT s.SchedID,
		2,
		DATEADD(DAY,2,sl.M2W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_3 = 1
		AND DATEADD(DAY,2,sl.M2W2) >= @SOM2
		AND DATEADD(DAY,2,sl.M2W2) <= @EOM2
UNION SELECT s.SchedID,
		2,
		DATEADD(DAY,3,sl.M2W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_4 = 1
		AND DATEADD(DAY,3,sl.M2W1) >= @SOM2
		AND DATEADD(DAY,3,sl.M2W1) <= @EOM2
UNION SELECT s.SchedID,
		2,
		DATEADD(DAY,3,sl.M2W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_4 = 1
		AND DATEADD(DAY,3,sl.M2W2) >= @SOM2
		AND DATEADD(DAY,3,sl.M2W2) <= @EOM2
UNION SELECT s.SchedID,
		2,
		DATEADD(DAY,5,sl.M2W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_5 = 1
		AND DATEADD(DAY,4,sl.M2W1) >= @SOM2
		AND DATEADD(DAY,4,sl.M2W1) <= @EOM2
UNION SELECT s.SchedID,
		2,
		DATEADD(DAY,4,sl.M2W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_5 = 1
		AND DATEADD(DAY,4,sl.M2W2) >= @SOM2
		AND DATEADD(DAY,4,sl.M2W2) <= @EOM2
UNION SELECT s.SchedID,
		2,
		DATEADD(DAY,5,sl.M2W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_6 = 1
		AND DATEADD(DAY,5,sl.M2W1) >= @SOM2
		AND DATEADD(DAY,5,sl.M2W1) <= @EOM2
UNION SELECT s.SchedID,
		2,
		DATEADD(DAY,5,sl.M2W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_6 = 1
		AND DATEADD(DAY,5,sl.M2W2) >= @SOM2
		AND DATEADD(DAY,5,sl.M2W2) <= @EOM2
UNION SELECT s.SchedID,
		2,
		DATEADD(DAY,6,sl.M2W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_7 = 1
		AND DATEADD(DAY,6,sl.M2W1) >= @SOM2
		AND DATEADD(DAY,6,sl.M2W1) <= @EOM2
UNION SELECT s.SchedID,
		2,
		DATEADD(DAY,6,sl.M2W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_7 = 1
		AND DATEADD(DAY,6,sl.M2W2) >= @SOM2
		AND DATEADD(DAY,6,sl.M2W2) <= @EOM2
UNION SELECT s.SchedID,
		3,
		DATEADD(DAY,0,sl.M3W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_1 = 1
		AND DATEADD(DAY,0,sl.M3W1) >= @SOM3
		AND DATEADD(DAY,0,sl.M3W1) <= @EOM3
UNION SELECT s.SchedID,
		3,
		DATEADD(DAY,0,sl.M3W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_1 = 1
		AND DATEADD(DAY,0,sl.M3W2) >= @SOM3
		AND DATEADD(DAY,0,sl.M3W2) <= @EOM3
UNION SELECT s.SchedID,
		3,
		DATEADD(DAY,1,sl.M3W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_2 = 1
		AND DATEADD(DAY,1,sl.M3W1) >= @SOM3
		AND DATEADD(DAY,1,sl.M3W1) <= @EOM3
UNION SELECT s.SchedID,
		3,
		DATEADD(DAY,1,sl.M3W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_2 = 1
		AND DATEADD(DAY,1,sl.M3W2) >= @SOM3
		AND DATEADD(DAY,1,sl.M3W2) <= @EOM3
UNION SELECT s.SchedID,
		3,
		DATEADD(DAY,2,sl.M3W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_3 = 1
		AND DATEADD(DAY,2,sl.M3W1) >= @SOM3
		AND DATEADD(DAY,2,sl.M3W1) <= @EOM3
UNION SELECT s.SchedID,
		3,
		DATEADD(DAY,2,sl.M3W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_3 = 1
		AND DATEADD(DAY,2,sl.M3W2) >= @SOM3
		AND DATEADD(DAY,2,sl.M3W2) <= @EOM3
UNION SELECT s.SchedID,
		3,
		DATEADD(DAY,3,sl.M3W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_4 = 1
		AND DATEADD(DAY,3,sl.M3W1) >= @SOM3
		AND DATEADD(DAY,3,sl.M3W1) <= @EOM3
UNION SELECT s.SchedID,
		3,
		DATEADD(DAY,3,sl.M3W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_4 = 1
		AND DATEADD(DAY,3,sl.M3W2) >= @SOM3
		AND DATEADD(DAY,3,sl.M3W2) <= @EOM3
UNION SELECT s.SchedID,
		3,
		DATEADD(DAY,5,sl.M3W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_5 = 1
		AND DATEADD(DAY,4,sl.M3W1) >= @SOM3
		AND DATEADD(DAY,4,sl.M3W1) <= @EOM3
UNION SELECT s.SchedID,
		3,
		DATEADD(DAY,4,sl.M3W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_5 = 1
		AND DATEADD(DAY,4,sl.M3W2) >= @SOM3
		AND DATEADD(DAY,4,sl.M3W2) <= @EOM3
UNION SELECT s.SchedID,
		3,
		DATEADD(DAY,5,sl.M3W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_6 = 1
		AND DATEADD(DAY,5,sl.M3W1) >= @SOM3
		AND DATEADD(DAY,5,sl.M3W1) <= @EOM3
UNION SELECT s.SchedID,
		3,
		DATEADD(DAY,5,sl.M3W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_6 = 1
		AND DATEADD(DAY,5,sl.M3W2) >= @SOM3
		AND DATEADD(DAY,5,sl.M3W2) <= @EOM3
UNION SELECT s.SchedID,
		3,
		DATEADD(DAY,6,sl.M3W1)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_7 = 1
		AND DATEADD(DAY,6,sl.M3W1) >= @SOM3
		AND DATEADD(DAY,6,sl.M3W1) <= @EOM3
UNION SELECT s.SchedID,
		3,
		DATEADD(DAY,6,sl.M3W2)
	FROM [dbo].[GBL_Schedule] s
	INNER JOIN @InSched sl ON sl.SchedID = s.SchedID
	WHERE s.RECURS_WEEKDAY_7 = 1
		AND DATEADD(DAY,6,sl.M3W2) >= @SOM3
		AND DATEADD(DAY,6,sl.M3W2) <= @EOM3

SELECT bt.NUM,
	cioc_shared.dbo.fn_SHR_GBL_Link_Record(bt.NUM,dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM, btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5, btd.LOCATION_NAME, btd.SERVICE_NAME_LEVEL_1, btd.SERVICE_NAME_LEVEL_2, bt.DISPLAY_LOCATION_NAME, bt.DISPLAY_ORG_NAME),@HTTPVals,@PathToStart) AS Name,
	btd.CMP_DescriptionShort + CASE WHEN RIGHT(btd.CMP_DescriptionShort, 4) = ' ...' THEN ' ' + cioc_shared.dbo.fn_SHR_GBL_Link_Record(bt.NUM,'[' + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('More',@@LANGID) + ']',@HTTPVals,@PathToStart) ELSE '' END AS Description,
	dbo.fn_GBL_NUMVNUMToSchedule(bt.NUM, NULL, 1) AS Schedule,
	MIN(xd.MONTH1) AS Month1, MIN(xd.MONTH2) AS Month2, MIN(xd.MONTH3) AS Month3
FROM dbo.GBL_BaseTable bt
INNER JOIN dbo.GBL_BaseTable_Description btd ON btd.NUM = bt.NUM
	AND btd.LangID=@@LANGID
	AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
	AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
	AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
INNER JOIN
(SELECT 
	s.GblNUM,
 	CAST(CASE
		WHEN s.RECURS_EVERY=0 AND s.START_DATE <= @EOM1 AND ISNULL(s.END_DATE,s.START_DATE) >= @SOM1 THEN CASE WHEN @SOM1 > s.START_DATE THEN @SOM1 ELSE s.START_DATE END
		WHEN s.RECURS_DAY_OF_WEEK=1 OR s.RECURS_XTH_WEEKDAY_OF_MONTH IS NOT NULL THEN (SELECT MIN(ew.PotentialDay) FROM @ExpandWeekly ew WHERE ew.SchedID=s.SchedID AND ew.SchedMonth=1)
		WHEN s.RECURS_DAY_OF_MONTH IS NOT NULL
			AND s.START_DATE <= @EOM1
			AND (s.END_DATE IS NULL OR s.END_DATE >= @SOM1)
			AND DAY(@SOM1) <= s.RECURS_DAY_OF_MONTH
			AND DAY(@EOM1) >= s.RECURS_DAY_OF_MONTH
			AND DATEDIFF(MONTH,DATEFROMPARTS(YEAR(s.START_DATE),MONTH(s.START_DATE),1),DATEFROMPARTS(YEAR(@SOM1),MONTH(@SOM1),1)) % s.RECURS_EVERY = 0
			THEN DATEFROMPARTS(YEAR(@SOM1),MONTH(@SOM1),s.RECURS_DAY_OF_MONTH)
		ELSE NULL
	END AS DATETIME) + CAST(ISNULL(s.START_TIME,'0:00') AS DATETIME) AS MONTH1,
	CAST(CASE
		WHEN s.RECURS_EVERY=0 AND s.START_DATE <= @EOM2 AND ISNULL(s.END_DATE,s.START_DATE) >= @SOM2 THEN CASE WHEN @SOM2 > s.START_DATE THEN @SOM2 ELSE s.START_DATE END
		WHEN s.RECURS_DAY_OF_WEEK=1 OR s.RECURS_XTH_WEEKDAY_OF_MONTH IS NOT NULL THEN (SELECT MIN(ew.PotentialDay) FROM @ExpandWeekly ew WHERE ew.SchedID=s.SchedID AND ew.SchedMonth=2)
		WHEN s.RECURS_DAY_OF_MONTH IS NOT NULL
			AND s.START_DATE <= @EOM2
			AND (s.END_DATE IS NULL OR s.END_DATE >= @SOM2)
			AND DAY(@SOM2) <= s.RECURS_DAY_OF_MONTH
			AND DAY(@EOM2) >= s.RECURS_DAY_OF_MONTH
			AND DATEDIFF(MONTH,DATEFROMPARTS(YEAR(s.START_DATE),MONTH(s.START_DATE),1),@SOM2) % s.RECURS_EVERY = 0
			THEN DATEFROMPARTS(YEAR(@SOM2),MONTH(@SOM2),s.RECURS_DAY_OF_MONTH)
		ELSE NULL
	END AS DATETIME) + CAST(ISNULL(s.START_TIME,'0:00') AS DATETIME) AS MONTH2,
	CAST(CASE
		WHEN s.RECURS_EVERY=0 AND s.START_DATE <= @EOM3 AND ISNULL(s.END_DATE,s.START_DATE) >= @SOM3 THEN CASE WHEN @SOM3 > s.START_DATE THEN @SOM3 ELSE s.START_DATE END
		WHEN s.RECURS_DAY_OF_WEEK=1 OR s.RECURS_XTH_WEEKDAY_OF_MONTH IS NOT NULL THEN (SELECT MIN(ew.PotentialDay) FROM @ExpandWeekly ew WHERE ew.SchedID=s.SchedID AND ew.SchedMonth=3)
		WHEN s.RECURS_DAY_OF_MONTH IS NOT NULL
			AND s.START_DATE <= @EOM3
			AND (s.END_DATE IS NULL OR s.END_DATE >= @SOM3)
			AND DAY(@SOM3) <= s.RECURS_DAY_OF_MONTH
			AND DAY(@EOM3) >= s.RECURS_DAY_OF_MONTH
			AND DATEDIFF(MONTH,DATEFROMPARTS(YEAR(s.START_DATE),MONTH(s.START_DATE),1),@SOM3) % s.RECURS_EVERY = 0
			THEN DATEFROMPARTS(YEAR(@SOM3),MONTH(@SOM3),s.RECURS_DAY_OF_MONTH)
		ELSE NULL
	END AS DATETIME) + CAST(ISNULL(s.START_TIME,'0:00') AS DATETIME) AS MONTH3
	FROM [dbo].[GBL_Schedule] s
	LEFT JOIN @InSched sl ON sl.SchedID = s.SchedID
WHERE START_DATE <= @EOM3
	AND (
		END_DATE >= GETDATE()
		OR (END_DATE IS NULL AND s.RECURS_EVERY<>0)
		OR (s.START_DATE >= GETDATE())
		)
) xd ON xd.GblNUM=bt.NUM
WHERE (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))
	AND (bt.MemberID=@MemberID
			OR EXISTS(SELECT *
				FROM GBL_BT_SharingProfile pr
				INNER JOIN GBL_SharingProfile shp
					ON pr.ProfileID=shp.ProfileID
						AND shp.Active=1
						AND (
							shp.CanUseAnyView=1
							OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
						)
				WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID)
		)
GROUP BY bt.NUM,
	dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM, btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5, btd.LOCATION_NAME, btd.SERVICE_NAME_LEVEL_1, btd.SERVICE_NAME_LEVEL_2, bt.DISPLAY_LOCATION_NAME, bt.DISPLAY_ORG_NAME),
	btd.CMP_DescriptionShort


SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Schedule_l_Upcoming] TO [cioc_cic_search_role]
GO
