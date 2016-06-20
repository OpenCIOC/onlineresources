
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_History_Offline_s]
	@MachineID int,
	@AsOfDate smalldatetime
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON


/*
	Checked for Release: 3.6.1
	Checked by: CL
	Checked on: 17-Oct-2014
	Action: NO ACTION REQUIRED
*/

DECLARE @MemberID int
SELECT @MemberID=MemberID FROM CIC_Offline_Machines WHERE MachineID=@MachineID

DECLARE @TaxFieldID int
SELECT @TaxFieldID=FieldID FROM GBL_FieldOption WHERE FieldName='TAXONOMY'

DECLARE @SiteAddressID int
SELECT @SiteAddressID=FieldID FROM GBL_FieldOption WHERE FieldName='SITE_ADDRESS'

DECLARE @UserTypes TABLE (
	SL_ID int NOT NULL PRIMARY KEY,
	ViewType int NOT NULL
)

DECLARE	@ViewTypes TABLE (
	ViewType int NOT NULL,
	LangID smallint NOT NULL,
	PB_ID int,
	LimitedView bit,
	CanSeeNonPublic bit,
	HidePastDueBy int,
	CanSeeNonPublicPub bit,
	ViewName nvarchar(100)
)

DECLARE @QuickList TABLE (
	ListType char(1) NOT NULL,
	ListID int NOT NULL,
	LangID smallint NOT NULL,
	Name varchar(200) NOT NULL
)

DECLARE @DisplayFields TABLE (
	FieldID int NOT NULL PRIMARY KEY
)

INSERT INTO @UserTypes (SL_ID, ViewType)
SELECT sl.SL_ID, sl.ViewTypeOffline
FROM CIC_SecurityLevel sl
INNER JOIN CIC_SecurityLevel_Machine slm
	ON sl.SL_ID=slm.SL_ID
WHERE MemberID=@MemberID
	AND slm.MachineID=@MachineID
	AND ViewTypeOffline IS NOT NULL

INSERT INTO @ViewTypes (ViewType, LangID, PB_ID, LimitedView, CanSeeNonPublic, HidePastDueBy, CanSeeNonPublicPub, ViewName)
SELECT vwd.ViewType, vwd.LangID, vw.PB_ID, vw.LimitedView, vw.CanSeeNonPublic, vw.HidePastDueBy, vw.CanSeeNonPublicPub, vwd.ViewName
FROM CIC_View_Description vwd
INNER JOIN CIC_View vw
	ON vwd.ViewType=vw.ViewType
WHERE EXISTS(SELECT * FROM @UserTypes sl WHERE sl.ViewType=vw.ViewType)

INSERT INTO @DisplayFields
SELECT FieldID FROM GBL_FieldOption fo
WHERE ChangeHistory > 0
	AND (FieldName LIKE ('ORG_LEVEL_%')
	OR FieldName IN ('UPDATE_DATE','NON_PUBLIC')
	OR EXISTS(SELECT * FROM CIC_View_DisplayField df 
			INNER JOIN CIC_View_DisplayFieldGroup fg
				ON df.DisplayFieldGroupID=fg.DisplayFieldGroupID
			INNER JOIN @ViewTypes vwd
				ON fg.ViewType=vwd.ViewType
			WHERE CASE WHEN df.FieldID IN (SELECT FieldID FROM GBL_FieldOption WHERE FieldName IN ('TAXONOMY_NOLINK','TAXONOMY_STAFF')) THEN @TaxFieldID
				  WHEN df.FieldID IN (SELECT FieldID FROM GBL_FieldOption WHERE FieldName IN ('SITE_ADDRESS_ONLY', 'SITE_ADDRESS_MAPPED')) THEN @SiteAddressID ELSE df.FieldID END=fo.FieldID)
	)

-- Views
SELECT ViewType, LangID, ViewName FROM @ViewTypes

-- Communities
SELECT cm.CM_ID, cmn.LangID, cmn.Name, cm.ParentCommunity
FROM GBL_Community cm
INNER JOIN GBL_Community_Name cmn
	ON cm.CM_ID=cmn.CM_ID AND EXISTS(SELECT * FROM @ViewTypes WHERE LangID=cmn.LangID)
	
-- Publications
INSERT INTO @QuickList (ListType, ListID, LangID, Name)
SELECT 'P', pb.PB_ID, pb.LangID, ISNULL(pbn.Name, pb.PubCode)
FROM (SELECT MemberID, PB_ID, NonPublic, PubCode, LangID, MODIFIED_DATE
			FROM (SELECT DISTINCT LangID FROM @ViewTypes vwd
			WHERE (PB_ID=NULL OR LimitedView=0)
			AND (CanSeeNonPublicPub=1
				OR EXISTS(SELECT * FROM CIC_View_QuickListPub WHERE ViewType=vwd.ViewType)
				OR CanSeeNonPublicPub=0
				)
			) ln, CIC_Publication pb1
	) pb
LEFT JOIN CIC_Publication_Name pbn
	ON pb.PB_ID=pbn.PB_ID AND pbn.LangID=pb.LangID
WHERE (
	pb.MemberID=@MemberID
	OR (
		pb.MemberID IS NULL
		AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE MemberID=@MemberID AND PB_ID=pb.PB_ID)
		)
	)
	AND EXISTS(SELECT * FROM @ViewTypes vwd
			WHERE (PB_ID=NULL OR LimitedView=0)
			AND (CanSeeNonPublicPub=1
				OR EXISTS(SELECT * FROM CIC_View_QuickListPub WHERE PB_ID=pb.PB_ID AND ViewType=vwd.ViewType)
				OR (CanSeeNonPublicPub=0 AND pb.NonPublic=0)
			)
		)
UNION SELECT 'H', gh.GH_ID, ghn.LangID, CASE WHEN TaxonomyName=1 THEN dbo.fn_CIC_GHIDToTaxTerms(gh.GH_ID, @@LANGID) ELSE ghn.Name END AS Name
FROM CIC_GeneralHeading gh
LEFT JOIN CIC_GeneralHeading_Name ghn
	ON gh.GH_ID=ghn.GH_ID
WHERE EXISTS(SELECT * FROM @ViewTypes WHERE PB_ID=gh.PB_ID AND LimitedView=1 AND LangID=ghn.LangID AND (gh.NonPublic=0 OR CanSeeNonPublicPub=1))
	
SELECT ListType + '-' + CAST(ListID AS varchar) AS ListID, LangID, Name
FROM @QuickList
	
-- View Publications
SELECT ViewType, 'P-' + CAST(pb.PB_ID AS varchar) AS ListID
	FROM CIC_Publication pb, (SELECT DISTINCT ViewType, CanSeeNonPublicPub, PB_ID, LimitedView FROM @ViewTypes) vwd
WHERE (
	pb.MemberID=@MemberID
	OR (
		pb.MemberID IS NULL
		AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember WHERE MemberID=@MemberID AND PB_ID=pb.PB_ID)
		)
	)
	AND (vwd.CanSeeNonPublicPub=1 OR (vwd.CanSeeNonPublicPub=0 AND pb.NonPublic=0))
	AND (vwd.PB_ID IS NULL OR LimitedView=0)
UNION SELECT ViewType, 'P-' + CAST(pb.PB_ID AS varchar) AS ListID
	FROM CIC_View_QuickListPub pb
	WHERE EXISTS(SELECT * FROM @ViewTypes WHERE ViewType=pb.ViewType AND CanSeeNonPublicPub IS NULL)
UNION SELECT ViewType, 'H-' + CAST(gh.GH_ID AS varchar) AS ListID
	FROM CIC_GeneralHeading gh, (SELECT DISTINCT ViewType, CanSeeNonPublicPub, PB_ID, LimitedView FROM @ViewTypes) vwd
WHERE (vwd.CanSeeNonPublicPub=1 OR (vwd.CanSeeNonPublicPub=0 AND gh.NonPublic=0)) AND gh.PB_ID=vwd.PB_ID AND vwd.LimitedView=1

-- Field Groups
SELECT vwd.ViewType, vwd.LangID, fg.DisplayFieldGroupID, fgn.Name, fg.DisplayOrder
	FROM CIC_View_DisplayFieldGroup fg
	INNER JOIN CIC_View_DisplayFieldGroup_Name fgn
		ON fg.DisplayFieldGroupID=fgn.DisplayFieldGroupID
	INNER JOIN @ViewTypes vwd
		ON fgn.LangID=vwd.LangID AND fg.ViewType=vwd.ViewType
ORDER BY fg.DisplayOrder, fgn.Name, fgn.LangID

-- Fields
SELECT DISTINCT f1.FieldID, f1.LangID, f1.FieldName, ISNULL(fod.FieldDisplay, f1.FieldName) AS Name, f1.DisplayOrder
	FROM (
		SELECT sl.LangID, fo.FieldID, fo.FieldName, fo.DisplayOrder
		FROM STP_Language sl, GBL_FieldOption fo
		WHERE sl.Active=1
			AND fo.FieldID IN (SELECT FieldID FROM @DisplayFields)
	) f1
	LEFT JOIN GBL_FieldOption_Description fod
		ON f1.FieldID=fod.FieldID AND f1.LangID=fod.LangID
ORDER BY f1.DisplayOrder, ISNULL(fod.FieldDisplay, f1.FieldName)

-- Field Group Fields
SELECT DISTINCT fg.ViewType, fg.DisplayFieldGroupID, 
		CASE WHEN df.FieldID IN (SELECT FieldID FROM GBL_FieldOption WHERE FieldName IN ('TAXONOMY_NOLINK','TAXONOMY_STAFF')) THEN @TaxFieldID
			WHEN df.FieldID IN (SELECT FieldID FROM GBL_FieldOption WHERE FieldName IN ('SITE_ADDRESS_ONLY', 'SITE_ADDRESS_MAPPED')) THEN @SiteAddressID 
			ELSE df.FieldID END AS FieldID, fg.DisplayOrder
	FROM CIC_View_DisplayField df
	INNER JOIN CIC_View_DisplayFieldGroup fg
		ON df.DisplayFieldGroupID=fg.DisplayFieldGroupID
WHERE EXISTS(SELECT * FROM @ViewTypes vwd WHERE fg.ViewType=vwd.ViewType)
--UNION SELECT DISTINCT ViewType, 0 AS DisplayFieldGroupID, FieldID, -1 AS DisplayOrder FROM @ViewTypes, @AlwaysDisplayFields
ORDER BY fg.DisplayOrder

-- Users
SELECT u.UserName, u.PasswordHash, u.PasswordHashRepeat, u.PasswordHashSalt, sl.ViewType, u.StartLanguage AS LangID
	FROM GBL_Users u
	INNER JOIN @UserTypes sl
		ON u.SL_ID_CIC=sl.SL_ID
	
-- Record NUMs by View
SELECT bt.NUM, btd.LangID, vwd.ViewType
	FROM @ViewTypes vwd
	INNER JOIN GBL_BaseTable_Description btd
		ON vwd.LangID=btd.LangID
	INNER JOIN GBL_BaseTable bt
		ON btd.NUM=bt.NUM
	WHERE (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE < GETDATE())
		AND (vwd.CanSeeNonPublic=0 OR btd.NON_PUBLIC=0)
		AND (vwd.HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < vwd.HidePastDueBy)))
		AND (vwd.PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=vwd.PB_ID))
		AND (
			bt.MemberID=@MemberID
			OR EXISTS(SELECT *
				FROM GBL_BT_SharingProfile pr
				INNER JOIN GBL_SharingProfile shp
					ON pr.ProfileID=shp.ProfileID
						AND shp.Active=1
						AND (
							shp.CanUseAnyView=1
							OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View spvw WHERE ProfileID=shp.ProfileID AND vwd.ViewType=spvw.ViewType)
						)
				WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID)
			)

-- Record Pubs
SELECT NUM, 'P-' + CAST(PB_ID AS varchar) AS ListID
FROM CIC_BT_PB pbr
WHERE EXISTS(SELECT *
		FROM @ViewTypes vwd
		INNER JOIN GBL_BaseTable_Description btd
			ON vwd.LangID=btd.LangID AND btd.NUM=pbr.NUM
		INNER JOIN GBL_BaseTable bt
			ON btd.NUM=bt.NUM
		WHERE bt.NUM=pbr.NUM
			AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE < GETDATE())
			AND (vwd.CanSeeNonPublic=0 OR btd.NON_PUBLIC=0)
			AND (vwd.HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < vwd.HidePastDueBy)))
			AND (vwd.PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=vwd.PB_ID))
			AND (
				bt.MemberID=@MemberID
				OR EXISTS(SELECT *
					FROM GBL_BT_SharingProfile pr
					INNER JOIN GBL_SharingProfile shp
						ON pr.ProfileID=shp.ProfileID
							AND shp.Active=1
							AND (
								shp.CanUseAnyView=1
								OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View spvw WHERE ProfileID=shp.ProfileID AND vwd.ViewType=spvw.ViewType)
							)
					WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID)
				)
		)
UNION SELECT NUM, 'H-' + CAST(GH_ID AS varchar) AS ListID
FROM CIC_BT_PB pbr
INNER JOIN CIC_BT_PB_GH ghr
	ON pbr.BT_PB_ID=ghr.BT_PB_ID
WHERE EXISTS(SELECT * FROM @QuickList WHERE ListType='H' AND ListID=GH_ID)
	AND EXISTS(SELECT *
		FROM @ViewTypes vwd
		INNER JOIN GBL_BaseTable_Description btd
			ON vwd.LangID=btd.LangID AND btd.NUM=pbr.NUM
		INNER JOIN GBL_BaseTable bt
			ON btd.NUM=bt.NUM
		WHERE bt.NUM=pbr.NUM
			AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE < GETDATE())
			AND (vwd.CanSeeNonPublic=0 OR btd.NON_PUBLIC=0)
			AND (vwd.HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < vwd.HidePastDueBy)))
			AND (vwd.PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=vwd.PB_ID))
			AND (
				bt.MemberID=@MemberID
				OR EXISTS(SELECT *
					FROM GBL_BT_SharingProfile pr
					INNER JOIN GBL_SharingProfile shp
						ON pr.ProfileID=shp.ProfileID
							AND shp.Active=1
							AND (
								shp.CanUseAnyView=1
								OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View spvw WHERE ProfileID=shp.ProfileID AND vwd.ViewType=spvw.ViewType)
							)
					WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID)
				)
		)

-- Record Communities
SELECT NUM, CM_ID
FROM CIC_BT_CM pr
WHERE EXISTS(SELECT *
		FROM @ViewTypes vwd
		INNER JOIN GBL_BaseTable_Description btd
			ON vwd.LangID=btd.LangID AND btd.NUM=pr.NUM
		INNER JOIN GBL_BaseTable bt
			ON btd.NUM=bt.NUM
		WHERE bt.NUM=pr.NUM
			AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE < GETDATE())
			AND (vwd.CanSeeNonPublic=0 OR btd.NON_PUBLIC=0)
			AND (vwd.HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < vwd.HidePastDueBy)))
			AND (vwd.PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=vwd.PB_ID))
			AND (
				bt.MemberID=@MemberID
				OR EXISTS(SELECT *
					FROM GBL_BT_SharingProfile pr
					INNER JOIN GBL_SharingProfile shp
						ON pr.ProfileID=shp.ProfileID
							AND shp.Active=1
							AND (
								shp.CanUseAnyView=1
								OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View spvw WHERE ProfileID=shp.ProfileID AND vwd.ViewType=spvw.ViewType)
							)
					WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID)
				)
		)

-- Data
SELECT row=CAST((SELECT NUM, LangID, FieldID, FieldDisplay FOR XML RAW, TYPE) AS nvarchar(max))
FROM GBL_BaseTable_History FIELD_DATA
WHERE HST_ID IN (SELECT MAX(HST_ID)
	FROM GBL_BaseTable_History h
	WHERE (@AsOfDate IS NULL OR MODIFIED_DATE >= @AsOfDate)
		AND h.FieldID IN (SELECT FieldID FROM @DisplayFields)
		AND EXISTS(SELECT *
			FROM GBL_BaseTable bt
			INNER JOIN GBL_BaseTable_Description btd
				ON bt.NUM=btd.NUM AND btd.LangID=h.LangID
			INNER JOIN @ViewTypes vwd
				ON vwd.LangID=btd.LangID
			WHERE bt.NUM=h.NUM
				AND (btd.DELETION_DATE IS NULL OR btd.DELETION_DATE < GETDATE())
				AND (vwd.CanSeeNonPublic=0 OR btd.NON_PUBLIC=0)
				AND (vwd.HidePastDueBy IS NULL OR (btd.UPDATE_SCHEDULE IS NOT NULL AND (DATEDIFF(d,btd.UPDATE_SCHEDULE,GETDATE()) < vwd.HidePastDueBy)))
				AND (vwd.PB_ID IS NULL OR EXISTS(SELECT * FROM CIC_BT_PB WHERE NUM=bt.NUM AND PB_ID=vwd.PB_ID))
				AND (
					bt.MemberID=@MemberID
					OR EXISTS(SELECT *
						FROM GBL_BT_SharingProfile pr
						INNER JOIN GBL_SharingProfile shp
							ON pr.ProfileID=shp.ProfileID
								AND shp.Active=1
								AND (
									shp.CanUseAnyView=1
									OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View spvw WHERE ProfileID=shp.ProfileID AND vwd.ViewType=spvw.ViewType)
								)
						WHERE NUM=bt.NUM AND ShareMemberID_Cache=@MemberID
							AND (
								EXISTS(SELECT * FROM GBL_SharingProfile_CIC_Fld WHERE FieldID=h.FieldID AND ProfileID=shp.ProfileID)
								OR EXISTS(SELECT * FROM GBL_FieldOption WHERE FieldID=h.FieldID AND CanShare=0)
							)
						)
					)
			)
	GROUP BY NUM, LangID, FieldID)

SET NOCOUNT OFF









GO


GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_History_Offline_s] TO [cioc_login_role]
GO
