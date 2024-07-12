SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Stats_RSN_u_Cache] (@MemberID int = NULL)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE @NOW smalldatetime
SET @NOW = GETDATE()

INSERT INTO dbo.GBL_BaseTable_StatsCache (
	NUM,
	MemberID,
	CMP_USAGE_COUNT_DATE,
	CMP_USAGE_COUNT,
	CMP_USAGE_COUNT_P,
	CMP_USAGE_COUNT_S
)
SELECT	NUM,
		MemberID,
		@NOW,
		v.CMP_USAGE_COUNT,
		v.CMP_USAGE_COUNT-v.CMP_USAGE_COUNT_S,
		v.CMP_USAGE_COUNT_S
FROM (
	SELECT st.MemberID, bt.NUM, bt.RSN,
			COUNT(st.RSN) AS CMP_USAGE_COUNT,
			COUNT(st.User_ID) AS CMP_USAGE_COUNT_S
		FROM dbo.GBL_BaseTable bt
		INNER JOIN dbo.CIC_Stats_RSN st
			ON st.RSN=bt.RSN
		WHERE NOT EXISTS(SELECT * FROM dbo.GBL_BaseTable_StatsCache stc WHERE stc.MemberID=st.MemberID AND stc.NUM=bt.NUM)
			AND (@MemberID IS NULL OR st.MemberID=@MemberID)
	GROUP BY st.MemberID, bt.NUM, bt.RSN
) v

UPDATE  stc
		SET CMP_USAGE_COUNT_DATE	= @NOW,
			CMP_USAGE_COUNT			= v.CMP_USAGE_COUNT,
			CMP_USAGE_COUNT_P		= v.CMP_USAGE_COUNT-v.CMP_USAGE_COUNT_S,
			CMP_USAGE_COUNT_S		= v.CMP_USAGE_COUNT_S
	FROM dbo.GBL_BaseTable_StatsCache stc
	INNER JOIN dbo.GBL_BaseTable bt
		ON stc.NUM=bt.NUM
	INNER JOIN (
		SELECT
			st.MemberID, bt.NUM, bt.RSN,
			COUNT(st.RSN) AS CMP_USAGE_COUNT,
			COUNT(st.User_ID) AS CMP_USAGE_COUNT_S
		FROM dbo.GBL_BaseTable bt
		INNER JOIN dbo.CIC_Stats_RSN st
			ON st.RSN=bt.RSN
		WHERE (@MemberID IS NULL OR st.MemberID=@MemberID)
	GROUP BY st.MemberID, bt.NUM, bt.RSN
	) v ON stc.NUM=v.NUM AND stc.MemberID=v.MemberID
WHERE stc.CMP_USAGE_COUNT_DATE <> @NOW
	AND (@MemberID IS NULL OR stc.MemberID=@MemberID)

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Stats_RSN_u_Cache] TO [cioc_maintenance_role]
GO
