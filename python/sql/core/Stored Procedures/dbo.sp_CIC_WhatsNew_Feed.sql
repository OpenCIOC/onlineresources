
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_WhatsNew_Feed]
	@ViewType int,
	@FeedAPIKey uniqueidentifier,
	@Description bit = NULL,
	@Address bit = NULL,
	@Email bit = NULL,
	@Web bit = NULL,
	@OfficePhone bit = NULL,
	@Hours bit = NULL

WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: KL
	Checked on: 22-Jan-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@MemberID int,
		@CanSeeNonPublic bit,
		@HidePastDueBy int,
		@PB_ID int,
		@UseLocalSubjects bit,
		@UseZeroSubjects bit
		
SELECT	@MemberID=MemberID,
		@CanSeeNonPublic=CanSeeNonPublic,
		@HidePastDueBy=HidePastDueBy,
		@PB_ID=PB_ID
FROM CIC_View
WHERE ViewType=@ViewType

SELECT TOP 15
		bt.NUM,
		dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		btd.CMP_LocatedIn AS LOCATION,
		CASE WHEN @Description=1 THEN btd.CMP_DescriptionShort END AS DESCRIPTION_SHORT,
		CASE WHEN @Address=1 AND NOT dbo.fn_GBL_FieldIsPrivate(bt.PRIVACY_PROFILE,'SITE_ADDRESS')=1 THEN REPLACE(btd.CMP_SiteAddress,CHAR(13) + CHAR(10),', ') ELSE NULL END AS SITE_ADDRESS,
		CASE WHEN @Email=1 THEN btd.E_MAIL END AS EMAIL,
		CASE WHEN @OfficePhone=1 THEN btd.OFFICE_PHONE END AS OFFICE_PHONE,
		CASE WHEN @Web=1 THEN btd.WWW_ADDRESS END AS WEB,
		CASE WHEN @Hours=1 THEN cbtd.HOURS END AS HOURS,
		cioc_shared.dbo.fn_SHR_GBL_DateString(bt.CREATED_DATE) AS CREATED_DATE
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
			AND btd.LangID=@@LANGID
			AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
			AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
			AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
	LEFT JOIN dbo.CIC_BaseTable_Description cbtd
		ON cbtd.NUM=btd.NUM AND cbtd.LangID=btd.LangID
WHERE (@FeedAPIKey IS NULL OR EXISTS(SELECT * FROM GBL_FeedAPIKey WHERE FeedAPIKey=@FeedAPIKey AND Inactive=0 AND CIC=1))
	AND (@PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=@PB_ID))
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
ORDER BY
	btd.CREATED_DATE,
	btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5, btd.LOCATION_NAME, btd.SERVICE_NAME_LEVEL_1, btd.SERVICE_NAME_LEVEL_2

RETURN CASE WHEN @FeedAPIKey IS NULL OR EXISTS(SELECT * FROM GBL_FeedAPIKey WHERE FeedAPIKey=@FeedAPIKey AND Inactive=0 AND CIC=1) THEN 0 ELSE -1 END

SET NOCOUNT OFF

GO

GRANT EXECUTE ON  [dbo].[sp_CIC_WhatsNew_Feed] TO [cioc_cic_search_role]
GO
