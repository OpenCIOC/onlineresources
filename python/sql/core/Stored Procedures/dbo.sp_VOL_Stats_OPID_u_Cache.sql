SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Stats_OPID_u_Cache] (@MemberID int = NULL)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE @NOW smalldatetime
SET @NOW = GETDATE()


INSERT INTO dbo.VOL_Opportunity_StatsCache (
	VNUM,
	MemberID,
	CMP_USAGE_COUNT_DATE,
	CMP_USAGE_COUNT,
	CMP_USAGE_COUNT_P,
	CMP_USAGE_COUNT_S
)
SELECT	VNUM,
		MemberID,
		@NOW,
		v.CMP_USAGE_COUNT,
		v.CMP_USAGE_COUNT-v.CMP_USAGE_COUNT_S,
		v.CMP_USAGE_COUNT_S
FROM (
	SELECT st.MemberID, vo.VNUM, vo.OP_ID,
			COUNT(st.OP_ID) AS CMP_USAGE_COUNT,
			COUNT(st.User_ID) AS CMP_USAGE_COUNT_S
		FROM dbo.VOL_Opportunity vo
		INNER JOIN dbo.VOL_Stats_OPID st
			ON st.OP_ID=vo.OP_ID
		WHERE NOT EXISTS(SELECT * FROM dbo.VOL_Opportunity_StatsCache stc WHERE stc.MemberID=st.MemberID AND stc.VNUM=vo.VNUM)
			AND (@MemberID IS NULL OR st.MemberID=@MemberID)
	GROUP BY st.MemberID, vo.VNUM, vo.OP_ID
) v


UPDATE  stc
		SET CMP_USAGE_COUNT_DATE	= @NOW,
			CMP_USAGE_COUNT			= v.CMP_USAGE_COUNT,
			CMP_USAGE_COUNT_P		= v.CMP_USAGE_COUNT-v.CMP_USAGE_COUNT_S,
			CMP_USAGE_COUNT_S		= v.CMP_USAGE_COUNT_S
	FROM dbo.VOL_Opportunity_StatsCache stc
	INNER JOIN dbo.VOL_Opportunity vo
		ON vo.VNUM=stc.VNUM
	INNER JOIN (
		SELECT st.MemberID, vo.VNUM, vo.OP_ID,
			COUNT(st.OP_ID) AS CMP_USAGE_COUNT,
			COUNT(st.User_ID) AS CMP_USAGE_COUNT_S
		FROM dbo.VOL_Opportunity vo
		INNER JOIN dbo.VOL_Stats_OPID st
			ON st.OP_ID = vo.OP_ID
		WHERE (@MemberID IS NULL OR st.MemberID=@MemberID)
	GROUP BY st.MemberID, vo.VNUM, vo.OP_ID
	) v ON stc.VNUM=vo.VNUM AND stc.MemberID=v.MemberID
WHERE stc.CMP_USAGE_COUNT_DATE <> @NOW
	AND (@MemberID IS NULL OR stc.MemberID=@MemberID)

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Stats_OPID_u_Cache] TO [cioc_maintenance_role]
GO
