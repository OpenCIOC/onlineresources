
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_History_Offline_s_NewItems]
	@MachineID int,
	@NUMList varchar(max),
	@FieldList varchar(max)
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

DECLARE @DisplayFields TABLE (
	FieldID int NOT NULL PRIMARY KEY
)

DECLARE @NUMs TABLE (
	NUM varchar(8) COLLATE Latin1_General_100_CI_AI PRIMARY KEY
)

INSERT INTO @NUMs (NUM)
SELECT DISTINCT ItemID FROM dbo.fn_GBL_ParseVarCharIDList(@NUMList,',')

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
				WHEN df.FieldID IN (SELECT FieldID FROM GBL_FieldOption WHERE FieldName IN ('SITE_ADDRESS_ONLY', 'SITE_ADDRESS_MAPPED')) THEN @SiteAddressID
				ELSE df.FieldID END=fo.FieldID)
	)

-- Data
SELECT record=CAST((SELECT NUM, LangID, FieldID, FieldDisplay FOR XML RAW, TYPE) AS nvarchar(max))
FROM GBL_BaseTable_History FIELD_DATA
WHERE (
		EXISTS(SELECT * FROM @NUMs n WHERE n.NUM=FIELD_DATA.NUM)
		OR EXISTS(SELECT * FROM dbo.fn_GBL_ParseIntIDList(@FieldList,',') WHERE FieldID=ItemID)
		)
	AND HST_ID IN (SELECT MAX(HST_ID)
	FROM GBL_BaseTable_History h
	WHERE h.FieldID IN (SELECT FieldID FROM @DisplayFields)
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


GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_History_Offline_s_NewItems] TO [cioc_login_role]
GO
