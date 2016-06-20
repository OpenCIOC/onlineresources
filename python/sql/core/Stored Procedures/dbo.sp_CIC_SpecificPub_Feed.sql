
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CIC_SpecificPub_Feed]
	@ViewType int,
	@FeedAPIKey uniqueidentifier,
	@Description bit = NULL,
	@Address bit = NULL,
	@Email bit = NULL,
	@Web bit = NULL,
	@OfficePhone bit = NULL,
	@Hours bit = NULL,
	@Code varchar(20),
	@Location varchar(210),
	@ServiceArea varchar(210)

WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.3
	Checked by: KL
	Checked on: 18-Jan-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@MemberID int,
		@CanSeeNonPublic bit,
		@HidePastDueBy int,
		@PB_ID int,
		@UseLocalSubjects bit,
		@UseZeroSubjects bit,
		@CM_ID int
		
SELECT	@MemberID=MemberID,
		@CanSeeNonPublic=CanSeeNonPublic,
		@HidePastDueBy=HidePastDueBy,
		@PB_ID=PB_ID
FROM CIC_View
WHERE ViewType=@ViewType

SELECT TOP 1 @CM_ID=cm.CM_ID
FROM dbo.GBL_Community_Name cmn
INNER JOIN dbo.GBL_Community cm ON cm.CM_ID = cmn.CM_ID
INNER JOIN dbo.GBL_ProvinceState ps ON ps.ProvID = cm.ProvinceState
WHERE ISNULL(@Location,@ServiceArea) IN (cm.Code,cmn.Name,cmn.Name + '|' + ps.NameOrCode)
ORDER BY CASE WHEN ISNULL(@Location,@ServiceArea)=cm.Code THEN 0
	WHEN ISNULL(@Location,@ServiceArea) = cmn.Name + '|' + ps.NameOrCode THEN 1
	ELSE 3
	END,
	CASE WHEN cmn.LangID=@@LANGID THEN 0 ELSE 1 END,
	cmn.LangID

SELECT TOP 75
		bt.NUM,
		dbo.fn_GBL_DisplayFullOrgName_2(bt.NUM,btd.ORG_LEVEL_1,btd.ORG_LEVEL_2,btd.ORG_LEVEL_3,btd.ORG_LEVEL_4,btd.ORG_LEVEL_5,btd.LOCATION_NAME,btd.SERVICE_NAME_LEVEL_1,btd.SERVICE_NAME_LEVEL_2,bt.DISPLAY_LOCATION_NAME,bt.DISPLAY_ORG_NAME) AS ORG_NAME_FULL,
		btd.CMP_LocatedIn AS LOCATION,
		CASE WHEN @Description=1 THEN btd.CMP_DescriptionShort END AS DESCRIPTION_SHORT,
		CASE WHEN @Address=1 AND NOT dbo.fn_GBL_FieldIsPrivate(bt.PRIVACY_PROFILE,'SITE_ADDRESS')=1 THEN REPLACE(btd.CMP_SiteAddress,CHAR(13) + CHAR(10),', ') ELSE NULL END AS SITE_ADDRESS,
		CASE WHEN @Email=1 THEN btd.E_MAIL END AS EMAIL,
		CASE WHEN @OfficePhone=1 THEN btd.OFFICE_PHONE END AS OFFICE_PHONE,
		CASE WHEN @Web=1 THEN btd.WWW_ADDRESS END AS WEB,
		CASE WHEN @Hours=1 THEN cbtd.HOURS END AS HOURS
	FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd
		ON bt.NUM=btd.NUM
			AND btd.LangID=@@LANGID
			AND (@CanSeeNonPublic=1 OR btd.NON_PUBLIC=0)
			AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE > GETDATE())
			AND (@HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < @HidePastDueBy)))
	LEFT JOIN dbo.CIC_BaseTable_Description cbtd
		ON cbtd.NUM=btd.NUM AND cbtd.LangID=btd.LangID
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
	AND EXISTS(SELECT * FROM CIC_BT_PB pr INNER JOIN dbo.CIC_Publication pb ON pr.PB_ID=pb.PB_ID WHERE pr.NUM=bt.NUM AND pb.PubCode=@Code)
	AND (@Location IS NULL OR @CM_ID IS NULL OR LOCATED_IN_CM IN (SELECT * FROM fn_GBL_Community_Search_rst(@CM_ID)))
	AND (@ServiceArea IS NULL OR @CM_ID IS NULL
		OR (@Location IS NULL
			AND EXISTS(SELECT * FROM dbo.CIC_BT_CM pr INNER JOIN fn_GBL_Community_Search_rst(@CM_ID) csl ON csl.CM_ID = pr.CM_ID WHERE pr.NUM=bt.NUM)
			)
		)
ORDER BY btd.ORG_LEVEL_1, btd.ORG_LEVEL_2, btd.ORG_LEVEL_3, btd.ORG_LEVEL_4, btd.ORG_LEVEL_5, btd.LOCATION_NAME, btd.SERVICE_NAME_LEVEL_1, btd.SERVICE_NAME_LEVEL_2

SET NOCOUNT OFF

GO



GRANT EXECUTE ON  [dbo].[sp_CIC_SpecificPub_Feed] TO [cioc_cic_search_role]
GO
