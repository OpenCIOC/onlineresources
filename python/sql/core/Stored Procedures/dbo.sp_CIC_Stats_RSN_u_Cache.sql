SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Stats_RSN_u_Cache]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 31-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @RC int, @NUMBER int
SET @NUMBER= 10000
SET @RC=@NUMBER 

DECLARE @NOW smalldatetime
SET @NOW = GETDATE()
SET @RC = @NUMBER

WHILE @RC = @NUMBER BEGIN
	INSERT INTO GBL_BaseTable_StatsCache (
		NUM,
		MemberID,
		CMP_USAGE_COUNT_DATE,
		CMP_USAGE_COUNT,
		CMP_USAGE_COUNT_P,
		CMP_USAGE_COUNT_S
	)
	SELECT TOP (@NUMBER)
			NUM,
			MemberID,
			@NOW,
			dbo.fn_CIC_UsageCount(v.MemberID,v.RSN),
			dbo.fn_CIC_UsageCountPublic(v.MemberID,v.RSN),
			dbo.fn_CIC_UsageCountLogin(v.MemberID,v.RSN)
	FROM (
		SELECT DISTINCT st.MemberID, bt.NUM, bt.RSN
			FROM GBL_BaseTable bt
			INNER JOIN CIC_Stats_RSN st
				ON st.RSN=bt.RSN
			WHERE NOT EXISTS(SELECT * FROM GBL_BaseTable_StatsCache stc WHERE stc.MemberID=st.MemberID AND stc.NUM=bt.NUM)
	) v
	SET @RC = @@ROWCOUNT
END

SET @RC = @NUMBER
WHILE @RC = @NUMBER BEGIN
	UPDATE TOP(@NUMBER) stc
		SET CMP_USAGE_COUNT_DATE	= @NOW,
			CMP_USAGE_COUNT			= dbo.fn_CIC_UsageCount(stc.MemberID,bt.RSN),
			CMP_USAGE_COUNT_P		= dbo.fn_CIC_UsageCountPublic(stc.MemberID,bt.RSN),
			CMP_USAGE_COUNT_S		= dbo.fn_CIC_UsageCountLogin(stc.MemberID,bt.RSN)
	FROM GBL_BaseTable_StatsCache stc
	INNER JOIN GBL_BaseTable bt
		ON stc.NUM=bt.NUM
	WHERE CMP_USAGE_COUNT_DATE <> @NOW
	SET @RC = @@ROWCOUNT
END

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Stats_RSN_u_Cache] TO [cioc_maintenance_role]
GO
