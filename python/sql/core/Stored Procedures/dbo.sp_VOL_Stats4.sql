SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Stats4]
	@MemberID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

SELECT  a.AgencyCode AS RECORD_OWNER,
		COUNT(DISTINCT CASE WHEN vo.MemberID=@MemberID THEN vo.VNUM ELSE NULL END) AS RecordCountLocal,
		COUNT(DISTINCT vo2.VNUM) AS RecordCountOther,
		COUNT(st.[User_ID]) AS StaffUsageCount,
		COUNT(st.Log_ID) AS UsageCount
	FROM (
		SELECT ax.RecordOwnerVOL,
				ax.AgencyCode,
				CASE WHEN ax.MemberID=@MemberID OR EXISTS(SELECT * FROM STP_Member_ListForeignAgency memf WHERE ax.AgencyID=memf.AgencyID AND memf.MemberID=@MemberID)
					THEN @MemberID ELSE ax.MemberID END AS MemberID
			FROM GBL_Agency ax
		UNION SELECT DISTINCT CAST(1 AS bit) AS RecordOwnerVOL,
				RECORD_OWNER AS AgencyCode,
				CASE WHEN ax2.MemberID=@MemberID OR EXISTS(SELECT * FROM STP_Member_ListForeignAgency memf WHERE ax2.AgencyID=memf.AgencyID AND memf.MemberID=@MemberID)
					THEN @MemberID ELSE ax2.MemberID END AS MemberID
			FROM VOL_Opportunity vox
			LEFT JOIN GBL_Agency ax2
				ON vox.RECORD_OWNER=ax2.AgencyCode
		) a
	LEFT JOIN VOL_Opportunity vo
		ON a.AgencyCode=vo.RECORD_OWNER
	LEFT JOIN VOL_Stats_OPID st
		ON st.OP_ID=vo.OP_ID AND st.MemberID=@MemberID
	LEFT JOIN VOL_Opportunity vo2
		ON vo2.VNUM=vo.VNUM
			AND vo2.MemberID<>@MemberID
			AND EXISTS(SELECT *
					FROM VOL_OP_SharingProfile pr
					INNER JOIN GBL_SharingProfile shp
						ON pr.ProfileID=shp.ProfileID
							AND shp.Active=1
					WHERE VNUM=vo.VNUM AND ShareMemberID_Cache=@MemberID
				)
GROUP BY a.AgencyCode, a.MemberID, a.RecordOwnerVOL
HAVING (
		(a.MemberID=@MemberID AND a.RecordOwnerVOL=1)
		OR COUNT(st.Log_ID) > 0
	)
UNION SELECT NULL AS RECORD_OWNER,
		NULL AS RecordCountLocal,
		NULL AS RecordCountOther,
		COUNT(st.[User_ID]) AS StaffUsageCount,
		COUNT(st.Log_ID) AS UsageCount
	FROM VOL_Stats_OPID st
WHERE st.MemberID=@MemberID AND OP_ID IS NULL
ORDER BY RECORD_OWNER

RETURN @Error

SET NOCOUNT OFF

GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Stats4] TO [cioc_login_role]
GO
