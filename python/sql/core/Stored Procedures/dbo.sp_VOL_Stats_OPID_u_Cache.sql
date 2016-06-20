SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Stats_OPID_u_Cache]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE @RC int, @NUMBER int
SET @NUMBER= 10000
SET @RC=@NUMBER 

DECLARE @NOW smalldatetime
SET @NOW = GETDATE()
SET @RC = @NUMBER

WHILE @RC = @NUMBER BEGIN
	INSERT INTO VOL_Opportunity_StatsCache (
		VNUM,
		MemberID,
		CMP_USAGE_COUNT_DATE,
		CMP_USAGE_COUNT,
		CMP_USAGE_COUNT_P,
		CMP_USAGE_COUNT_S
	)
	SELECT TOP (@NUMBER)
			VNUM,
			MemberID,
			@NOW,
			dbo.fn_VOL_UsageCount(v.MemberID,v.OP_ID),
			dbo.fn_VOL_UsageCountPublic(v.MemberID,v.OP_ID),
			dbo.fn_VOL_UsageCountLogin(v.MemberID,v.OP_ID)
	FROM (
		SELECT DISTINCT st.MemberID, vo.VNUM, vo.OP_ID
			FROM VOL_Opportunity vo
			INNER JOIN VOL_Stats_OPID st
				ON st.OP_ID=vo.OP_ID
			WHERE NOT EXISTS(SELECT * FROM VOL_Opportunity_StatsCache stc WHERE stc.MemberID=st.MemberID AND stc.VNUM=vo.VNUM)
	) v
	SET @RC = @@ROWCOUNT
END

SET @RC = @NUMBER
WHILE @RC = @NUMBER BEGIN
	UPDATE TOP(@NUMBER) stc
		SET CMP_USAGE_COUNT_DATE	= @NOW,
			CMP_USAGE_COUNT			= dbo.fn_VOL_UsageCount(stc.MemberID,vo.OP_ID),
			CMP_USAGE_COUNT_P		= dbo.fn_VOL_UsageCountPublic(stc.MemberID,vo.OP_ID),
			CMP_USAGE_COUNT_S		= dbo.fn_VOL_UsageCountLogin(stc.MemberID,vo.OP_ID)
	FROM VOL_Opportunity_StatsCache stc
	INNER JOIN VOL_Opportunity vo
		ON vo.VNUM=stc.VNUM
	WHERE CMP_USAGE_COUNT_DATE <> @NOW
	SET @RC = @@ROWCOUNT
END

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Stats_OPID_u_Cache] TO [cioc_maintenance_role]
GO
