SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_AIRS_Export_3_1] (
	@ViewType [int],
	@LangID [smallint],
	@DST_ID [int],
	@IncludeDeleted [bit],
	@AutoIncludeSiteAgency [bit]
)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 11-Feb-2012
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

DECLARE	@MemberID int,
		@CanSeeNonPublic bit,
		@CanSeeDeleted bit,
		@HidePastDueBy int,
		@PB_ID int,
		@UseLocalSubjects bit,
		@UseZeroSubjects bit
		
SELECT	@MemberID = MemberID,
		@CanSeeNonPublic = CanSeeNonPublic,
		@CanSeeDeleted = CASE WHEN CanSeeDeleted=0 OR @IncludeDeleted=0 THEN 0 ELSE 1 END,
		@HidePastDueBy = HidePastDueBy,
		@PB_ID=PB_ID
FROM CIC_View
WHERE ViewType=@ViewType

SELECT
		(SELECT TOP 1 MemberNameCIC FROM STP_Member_Description WHERE MemberID=@MemberID ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID) AS "SourceEntity",
		(SELECT TOP 1 DatabaseCode FROM STP_Member WHERE MemberID=@MemberID) AS "SourceID",
		CONVERT(varchar,GETDATE(),126) AS "OriginTimestamp",
		'CIOC' AS "SoftwareVendor",
		'3.5.1' AS "SoftwareVersion",
		(SELECT CONVERT(varchar,ReleaseDate,126) FROM tax_updater.dbo.MetaData WHERE Language='eng') AS "TaxonomyVersion",
		'3.1' AS "SchemaVersion"


SELECT CAST(dbo.fn_GBL_AIRS_XML_Agency_3_1(@MemberID,@ViewType,@CanSeeNonPublic,@CanSeeDeleted,@HidePastDueBy,@PB_ID,pbt.NUM,@DST_ID,@LangID,@AutoIncludeSiteAgency) AS nvarchar(max))
	FROM GBL_BaseTable pbt
	INNER JOIN GBL_BaseTable_Description pbtd
		ON pbt.NUM=pbtd.NUM
			AND pbtd.LangID=@LangID
			AND (@CanSeeNonPublic=1 OR pbtd.NON_PUBLIC=0)
			AND (pbtd.DELETION_DATE IS NULL OR pbtd.DELETION_DATE > GETDATE())
			AND (@HidePastDueBy IS NULL OR (pbtd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,pbtd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
	WHERE (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=pbt.NUM AND PB_ID=@PB_ID))
		AND (pbt.MemberID=@MemberID
				OR EXISTS(SELECT *
					FROM GBL_BT_SharingProfile pr
					INNER JOIN GBL_SharingProfile shp
						ON pr.ProfileID=shp.ProfileID
							AND shp.Active=1
							AND (
								shp.CanUseAnyView=1
								OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View WHERE ProfileID=shp.ProfileID AND ViewType=@ViewType)
							)
					WHERE NUM=pbt.NUM AND ShareMemberID_Cache=@MemberID)
			)
		AND EXISTS(SELECT * FROM GBL_BT_OLS pr INNER JOIN GBL_OrgLocationService ols ON pr.OLS_ID=ols.OLS_ID AND ols.Code='AGENCY' WHERE pr.NUM=pbt.NUM)
		AND (
			@DST_ID IS NULL
			OR EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=pbt.NUM)
			OR (@AutoIncludeSiteAgency=1 AND EXISTS(SELECT * FROM GBL_BaseTable slbt WHERE ORG_NUM=pbt.NUM AND EXISTS(SELECT * FROM CIC_BT_DST WHERE DST_ID=@DST_ID AND NUM=slbt.NUM)))
		)
		AND pbt.ORG_NUM IS NULL

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_GBL_AIRS_Export_3_1] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_GBL_AIRS_Export_3_1] TO [cioc_login_role]
GO
