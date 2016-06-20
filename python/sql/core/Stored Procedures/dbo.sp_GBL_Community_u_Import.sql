
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Community_u_Import]
	@ComData [xml],
	@SourceName nvarchar(200)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.1
	Checked by: KL
	Checked on: 16-Sep-2014
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int,
		@ErrMsg	nvarchar(500)

SET @Error = 0

DECLARE	@CommunityObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@ParentObjectName nvarchar(100),
		@ProvinceStateObjectName nvarchar(100)

SET @CommunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @ParentObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Parent Community')
SET @ProvinceStateObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Province/State')

DECLARE @ProvinceTable TABLE (
	FKProvID int NOT NULL PRIMARY KEY,
	ProvID int NULL,
	NameOrCode nvarchar(100) NULL,
	Country nvarchar(100) NOT NULL
)

DECLARE @ProvinceNameTable TABLE (
	FKProvID int NOT NULL,
	LangID smallint NULL,
	Name nvarchar(100) NOT NULL
)

DECLARE @CommunityTable TABLE (
	FKCMID int NOT NULL PRIMARY KEY,
	CM_ID int NULL,
	CREATED_DATE smalldatetime NULL,
	MODIFIED_DATE smalldatetime NULL,
	CM_GUID uniqueidentifier NOT NULL,
	FKCMID_Parent int NULL,
	ParentCommunity int NULL,
	FKProvID int NULL,
	ProvinceState int NULL,
	AlternativeArea bit NOT NULL
)

DECLARE @SearchCommunityTable TABLE (
	FKCMID int NOT NULL,
	Search_FKCMID int NOT NULL
)

DECLARE @CommunityNameTable TABLE (
	FKCMID int NOT NULL,
	LangID smallint NULL,
	Name nvarchar(200) NOT NULL,
	AltName bit NOT NULL
)

INSERT INTO @ProvinceTable (FKProvID, NameOrCode, Country)
SELECT	N.value('@id', 'int') AS FKProvID,
		N.value('@name_or_code', 'nvarchar(100)') AS NameOrCode,
		N.value('@country', 'nvarchar(100)') AS Country
FROM @ComData.nodes('//province_state') AS T(N)

-- Insertion error (probably primary key)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityObjectName, @ErrMsg

UPDATE pt SET ProvID=pv.ProvID
	FROM @ProvinceTable pt
	INNER JOIN GBL_ProvinceState pv
		ON pt.Country=pv.Country
			AND (
				(pt.NameOrCode IS NULL AND pv.NameOrCode IS NULL) 
				OR pt.NameOrCode=pv.NameOrCode
			)

-- Duplicate Province / State entries
IF EXISTS(SELECT COUNT(*) FROM @ProvinceTable GROUP BY NameOrCode, Country HAVING COUNT(*) > 1) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProvinceStateObjectName, @NameObjectName)
END

INSERT INTO @ProvinceNameTable (FKProvID, LangID, Name)
SELECT	N.value('../../@id', 'int') AS FKProvID,
		(SELECT LangID FROM STP_Language WHERE Culture=N.value('@culture', 'varchar(5)')) AS LangID,
		N.value('@value', 'nvarchar(100)') AS Name
FROM @ComData.nodes('//province_state/names/name') AS T(N)
DELETE FROM @ProvinceNameTable WHERE LangID IS NULL

EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityObjectName, @ErrMsg

-- Duplicate Province Name entries
IF EXISTS(SELECT COUNT(*) FROM @ProvinceNameTable ptn GROUP BY LangID, Name HAVING COUNT(*) > 1) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProvinceStateObjectName, @NameObjectName)
END

-- Create Table of Communities (Main Communities)
INSERT INTO @CommunityTable (FKCMID, CREATED_DATE, MODIFIED_DATE, CM_GUID, FKCMID_Parent, FKProvID, ProvinceState, AlternativeArea)
SELECT	N.value('@id', 'int') AS FKProvID,
		N.value('@created_date', 'smalldatetime') AS CREATED_DATE,
		N.value('@modified_date', 'smalldatetime') AS MODIFIED_DATE,
		N.value('@guid', 'uniqueidentifier') AS CM_GUID,
		N.value('@parent_id', 'int') AS FKCMID_Parent,
		N.value('@prov_state', 'int') AS FKProvID,
		(SELECT ProvID FROM @ProvinceTable pt WHERE pt.FKProvID=N.value('@prov_state', 'int')) AS ProvinceState,
		0 AS AlternativeArea
FROM @ComData.nodes('//community') AS T(N)

-- Insertion error (probably primary key)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityObjectName, @ErrMsg

-- Create Table of Communities (Alternative Search Areas)
INSERT INTO @CommunityTable (FKCMID, CREATED_DATE, MODIFIED_DATE, CM_GUID, FKCMID_Parent, FKProvID, ProvinceState, AlternativeArea)
SELECT	N.value('@id', 'int') AS FKProvID,
		N.value('@created_date', 'smalldatetime') AS CREATED_DATE,
		N.value('@modified_date', 'smalldatetime') AS MODIFIED_DATE,
		N.value('@guid', 'uniqueidentifier') AS CM_GUID,
		N.value('@parent_id', 'int') AS FKCMID_Parent,
		N.value('@prov_state', 'int') AS FKProvID,
		(SELECT ProvID FROM @ProvinceTable pt WHERE pt.FKProvID=N.value('@prov_state', 'int')) AS ProvinceState,
		1 AS AlternativeArea
FROM @ComData.nodes('//alt_search_area') AS T(N)

-- Insertion error (probably primary key)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityObjectName, @ErrMsg

-- Match Communities on GUID
UPDATE ct SET CM_ID=cm.CM_ID
	FROM @CommunityTable ct
	INNER JOIN GBL_Community cm
		ON ct.CM_GUID=cm.CM_GUID

-- Invalid Province in incoming Community data
IF EXISTS(SELECT * FROM @CommunityTable ct WHERE ct.FKProvID IS NOT NULL AND NOT EXISTS(SELECT * FROM @ProvinceTable pt WHERE ct.FKProvID=pt.FKProvID)) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST((SELECT TOP 1 ct.FKProvID FROM @CommunityTable ct WHERE ct.FKProvID IS NOT NULL AND NOT EXISTS(SELECT * FROM @ProvinceTable pt WHERE ct.FKProvID=pt.FKProvID)) AS varchar), @ProvinceStateObjectName)
END

-- Invalid Parent Community in incoming Community data
IF EXISTS(SELECT * FROM @CommunityTable ct WHERE ct.FKCMID_Parent IS NOT NULL AND NOT EXISTS(SELECT * FROM @CommunityTable ct2 WHERE ct2.FKCMID=ct.FKCMID_Parent)) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST((SELECT TOP 1 ct.FKCMID_Parent FROM @CommunityTable ct WHERE ct.FKCMID_Parent IS NOT NULL AND NOT EXISTS(SELECT * FROM @CommunityTable ct2 WHERE ct2.FKCMID=ct.FKCMID_Parent)) AS varchar), @ParentObjectName)
END

-- Search Communities
INSERT INTO @SearchCommunityTable (FKCMID,Search_FKCMID)
SELECT	N.value('../../@id', 'int') AS FKCMID,
		N.value('@value', 'int') AS Search_FKCMID
FROM @ComData.nodes('//alt_search_area/search_areas/cm_id') AS T(N)

-- Official and Alternate Names
INSERT INTO @CommunityNameTable (FKCMID, LangID, Name, AltName)
SELECT	N.value('../../@id', 'int') AS FKCMID,
		(SELECT LangID FROM STP_Language WHERE Culture=N.value('@culture', 'varchar(5)')) AS LangID,
		N.value('@value', 'nvarchar(100)') AS Name,
		0 AS AltName
FROM @ComData.nodes('//community/names/name') AS T(N)
DELETE FROM @CommunityNameTable WHERE LangID IS NULL

INSERT INTO @CommunityNameTable (FKCMID, LangID, Name, AltName)
SELECT	N.value('../../@id', 'int') AS FKCMID,
		(SELECT LangID FROM STP_Language WHERE Culture=N.value('@culture', 'varchar(5)')) AS LangID,
		N.value('@value', 'nvarchar(100)') AS Name,
		1 AS AltName
FROM @ComData.nodes('//community/alt_names/name') AS T(N)
DELETE FROM @CommunityNameTable WHERE LangID IS NULL

INSERT INTO @CommunityNameTable (FKCMID, LangID, Name, AltName)
SELECT	N.value('../../@id', 'int') AS FKCMID,
		(SELECT LangID FROM STP_Language WHERE Culture=N.value('@culture', 'varchar(5)')) AS LangID,
		N.value('@value', 'nvarchar(100)') AS Name,
		0 AS AltName
FROM @ComData.nodes('//alt_search_area/names/name') AS T(N)
DELETE FROM @CommunityNameTable WHERE LangID IS NULL

INSERT INTO @CommunityNameTable (FKCMID, LangID, Name, AltName)
SELECT	N.value('../../@id', 'int') AS FKCMID,
		(SELECT LangID FROM STP_Language WHERE Culture=N.value('@culture', 'varchar(5)')) AS LangID,
		N.value('@value', 'nvarchar(100)') AS Name,
		1 AS AltName
FROM @ComData.nodes('//alt_search_area/alt_names/name') AS T(N)
DELETE FROM @CommunityNameTable WHERE LangID IS NULL

-- Match Communities on name and province
UPDATE ct SET CM_ID=cm.CM_ID
	FROM @CommunityTable ct
	INNER JOIN GBL_Community cm
		ON EXISTS(SELECT *
					FROM GBL_Community_Name cmn
					INNER JOIN @CommunityNameTable ctn
						ON ctn.FKCMID=ct.FKCMID
							AND cmn.Name=ctn.Name
							AND cmn.LangID=ctn.LangID
							AND ctn.LangID=(SELECT TOP 1 LangID FROM @CommunityNameTable WHERE FKCMID=ctn.FKCMID ORDER BY LangID)
				WHERE cmn.CM_ID=cm.CM_ID
				)
	WHERE ct.CM_ID IS NULL
		AND NOT EXISTS(SELECT * FROM @CommunityTable ct2 WHERE ct2.CM_ID=cm.CM_ID)
		AND (
			ct.ProvinceState=cm.ProvinceState
			OR (ct.ProvinceState IS NULL AND cm.ProvinceState IS NULL)
		)
	
-- Match Communities on name
UPDATE ct SET CM_ID=cm.CM_ID
	FROM @CommunityTable ct
	INNER JOIN GBL_Community cm
		ON EXISTS(SELECT *
					FROM GBL_Community_Name cmn
					INNER JOIN @CommunityNameTable ctn
						ON ctn.FKCMID=ct.FKCMID
							AND cmn.Name=ctn.Name
							AND cmn.LangID=ctn.LangID
							AND ctn.LangID=(SELECT TOP 1 LangID FROM @CommunityNameTable WHERE FKCMID=ctn.FKCMID ORDER BY LangID)
				WHERE cmn.CM_ID=cm.CM_ID
				)
	WHERE ct.CM_ID IS NULL
		AND NOT EXISTS(SELECT * FROM @CommunityTable ct2 WHERE ct2.CM_ID=cm.CM_ID)

-- Duplicate Community Name entries
IF EXISTS(SELECT COUNT(*) FROM @CommunityNameTable ctn INNER JOIN @CommunityTable ct ON ctn.FKCMID=ct.FKCMID GROUP BY LangID, FKProvID, Name HAVING COUNT(*) > 1) BEGIN
	DECLARE @DuplicateName varchar(255)
	SELECT TOP 1 @DuplicateName = Name FROM @CommunityNameTable ctn INNER JOIN @CommunityTable ct ON ctn.FKCMID=ct.FKCMID GROUP BY LangID, FKProvID, Name HAVING COUNT(*) > 1
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @DuplicateName, @NameObjectName)
END

IF @Error = 0 BEGIN
	-- Update provinces to authorized, if not currently
	UPDATE GBL_ProvinceState
		SET Authorized=1
	WHERE Authorized=0 AND EXISTS(SELECT * FROM @ProvinceTable pt WHERE pt.ProvID=GBL_ProvinceState.ProvID)

	-- Insert missing provinces / countries
	INSERT INTO GBL_ProvinceState (NameOrCode, Country, Authorized)
	SELECT NameOrCode, Country, 1
		FROM @ProvinceTable pt
	WHERE pt.ProvID IS NULL
	
	-- Update ProvID in @ProvinceTable
	UPDATE pt SET ProvID=pv.ProvID
		FROM @ProvinceTable pt
		INNER JOIN GBL_ProvinceState pv
			ON pt.Country=pv.Country
				AND (
					(pt.NameOrCode IS NULL AND pv.NameOrCode IS NULL) 
					OR pt.NameOrCode=pv.NameOrCode
				)
		WHERE pt.ProvID IS NULL
	
	-- Update Province Names	
	MERGE INTO GBL_ProvinceState_Name pvn
	USING (SELECT pt.ProvID, ptn.LangID, ptn.Name
			FROM @ProvinceNameTable ptn
			INNER JOIN @ProvinceTable pt
				ON ptn.FKProvID=pt.FKProvID
			) nt
		ON pvn.ProvID=nt.ProvID AND pvn.LangID=nt.LangID
	WHEN MATCHED AND pvn.Name <> nt.Name THEN
		UPDATE SET
			Name = nt.Name
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (ProvID, LangID, Name)
			VALUES (nt.ProvID, nt.LangID, nt.Name)
	WHEN NOT MATCHED BY SOURCE
			AND EXISTS(SELECT * FROM @ProvinceNameTable WHERE LangID=pvn.LangID)
			AND EXISTS(SELECT * FROM @ProvinceTable WHERE ProvID=pvn.ProvID) THEN
		DELETE
		;
	
	-- Update Basic Communities (Round 1)
	MERGE INTO GBL_Community cm
	USING @CommunityTable ct
		ON ct.CM_ID=cm.CM_ID
	WHEN MATCHED AND (
			cm.CM_GUID<>ct.CM_GUID
			OR cm.Authorized=0
			OR cm.ProvinceState<>ct.ProvinceState 
			OR (cm.ProvinceState IS NULL AND ct.ProvinceState IS NOT NULL)
			OR (cm.ProvinceState IS NOT NULL AND ct.ProvinceState IS NULL)
			OR cm.AlternativeArea<>ct.AlternativeArea
			OR cm.Source<>@SourceName
			OR cm.Source IS NULL
			) THEN
		UPDATE SET
			MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= '(Import)',
			CM_GUID			= ct.CM_GUID,
			ProvinceState	= ct.ProvinceState,
			AlternativeArea	= ct.AlternativeArea,
			Authorized		= 1,
			Source			= @SourceName
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			CM_GUID,
			ParentCommunity,
			ProvinceState,
			AlternativeArea,
			Authorized,
			Source
		) VALUES (
			ISNULL(ct.CREATED_DATE,GETDATE()),
			'(Import)',
			ISNULL(ct.MODIFIED_DATE,GETDATE()),
			'(Import)',
			ct.CM_GUID,
			(SELECT CM_ID FROM @CommunityTable ct2 WHERE ct2.FKCMID=ct.FKCMID_Parent),
			ct.ProvinceState,
			ct.AlternativeArea,
			1,
			@SourceName
		)
	WHEN NOT MATCHED BY SOURCE
			AND cm.Authorized=1
			AND NOT EXISTS(SELECT * FROM CIC_BT_CM pr WHERE pr.CM_ID=cm.CM_ID)
			AND NOT EXISTS(SELECT * FROM VOL_OP_CM pr WHERE pr.CM_ID=cm.CM_ID) 
			AND NOT EXISTS(SELECT * FROM GBL_BaseTable WHERE LOCATED_IN_CM=cm.CM_ID)
			AND NOT EXISTS(SELECT * FROM CIC_Ward WHERE Municipality=cm.CM_ID)
			AND NOT EXISTS(SELECT * FROM CIC_BusRoute WHERE Municipality=cm.CM_ID) 
			AND NOT EXISTS(SELECT * FROM GBL_Community cm2 WHERE cm2.ParentCommunity=cm.CM_ID) THEN
		DELETE
		;
		
	-- Update CM_ID in @CommunityTable
	UPDATE ct SET CM_ID = cm.CM_ID
		FROM @CommunityTable ct
		INNER JOIN GBL_Community cm
			ON ct.CM_GUID=cm.CM_GUID
		WHERE ct.CM_ID IS NULL

	-- Update ParentCommunity in @CommunityTable
	UPDATE ct SET ParentCommunity = (SELECT CM_ID FROM @CommunityTable ct2 WHERE ct2.FKCMID=ct.FKCMID_Parent)
		FROM @CommunityTable ct
	
	-- Update ParentCommunity data
	UPDATE cm
		SET MODIFIED_DATE	= ISNULL(ct.MODIFIED_DATE,GETDATE()),
			MODIFIED_BY		= '(Import)',
			ParentCommunity	= ct.ParentCommunity
	FROM GBL_Community cm
	INNER JOIN @CommunityTable ct
		ON cm.CM_GUID=ct.CM_GUID
	WHERE cm.ParentCommunity<>ct.ParentCommunity
		OR (cm.ParentCommunity IS NULL AND ct.ParentCommunity IS NOT NULL)
		OR (cm.ParentCommunity IS NOT NULL AND ct.ParentCommunity IS NULL)
	
	IF EXISTS(SELECT * FROM @CommunityTable WHERE FKCMID_Parent IS NOT NULL AND ParentCommunity IS NULL) BEGIN
		SET @Error = 1
	END
	
	-- Remove non-matching Communities not marked as local
	DELETE cm
		FROM GBL_Community cm
		WHERE NOT EXISTS(SELECT * FROM @CommunityTable ct WHERE cm.CM_GUID=ct.CM_GUID)
			AND cm.Authorized=1
			AND NOT EXISTS(SELECT * FROM CIC_BT_CM pr WHERE pr.CM_ID=cm.CM_ID)
			AND NOT EXISTS(SELECT * FROM VOL_OP_CM pr WHERE pr.CM_ID=cm.CM_ID) 
			AND NOT EXISTS(SELECT * FROM GBL_BaseTable WHERE LOCATED_IN_CM=cm.CM_ID)
			AND NOT EXISTS(SELECT * FROM CIC_Ward WHERE Municipality=cm.CM_ID)
			AND NOT EXISTS(SELECT * FROM CIC_BusRoute WHERE Municipality=cm.CM_ID) 
			AND NOT EXISTS(SELECT * FROM GBL_Community cm2 WHERE cm2.ParentCommunity=cm.CM_ID)
			
	-- Update extra Communities to non-authorized status
	UPDATE GBL_Community
		SET Authorized=0
	WHERE Authorized=1 AND NOT EXISTS(SELECT * FROM @CommunityTable ct WHERE ct.CM_GUID=GBL_Community.CM_GUID)
	
	-- Update Community Names
	DECLARE @UpdateCM TABLE (
		CM_ID_NEW int,
		CM_ID_OLD int
	)
	
	MERGE INTO GBL_Community_Name cmn
	USING (SELECT ct.CM_ID, ctn.LangID, ctn.Name, ct.ProvinceState
			FROM @CommunityNameTable ctn
			INNER JOIN @CommunityTable ct
				ON ctn.FKCMID=ct.FKCMID
			WHERE ctn.AltName=0
			) nt
		ON cmn.CM_ID=nt.CM_ID AND cmn.LangID=nt.LangID
	WHEN MATCHED AND cmn.Name <> nt.Name THEN
		UPDATE SET
			Name = nt.Name
		/*
			Name = CASE WHEN EXISTS(SELECT * FROM GBL_Community_Name cmn2 WHERE cmn2.Name=nt.Name AND cmn2.LangID=nt.LangID AND (cmn2.ProvinceStateCache=nt.ProvinceState OR (cmn2.ProvinceStateCache IS NULL AND nt.ProvinceState IS NULL)))
				THEN nt.Name + ' **'
				ELSE nt.Name
				END
		*/
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (CM_ID, LangID, Name, ProvinceStateCache)
			VALUES (nt.CM_ID, nt.LangID, nt.Name, nt.ProvinceState)
	WHEN NOT MATCHED BY SOURCE
			AND EXISTS(SELECT * FROM @CommunityNameTable WHERE LangID=cmn.LangID)
			AND EXISTS(SELECT * FROM @CommunityTable WHERE CM_ID=cmn.CM_ID) THEN
		DELETE
	OUTPUT inserted.CM_ID, deleted.CM_ID INTO @UpdateCM
		;
		
	MERGE INTO GBL_Community_AltName cmn
	USING (SELECT ct.CM_ID, ctn.LangID, ctn.Name
			FROM @CommunityNameTable ctn
			INNER JOIN @CommunityTable ct
				ON ctn.FKCMID=ct.FKCMID
			WHERE ctn.AltName=1
			) nt
		ON cmn.CM_ID=nt.CM_ID AND cmn.LangID=nt.LangID AND cmn.AltName=nt.Name
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (CM_ID, LangID, AltName)
			VALUES (nt.CM_ID, nt.LangID, nt.Name)
	WHEN NOT MATCHED BY SOURCE
			AND EXISTS(SELECT * FROM @CommunityNameTable WHERE LangID=cmn.LangID)
			AND EXISTS(SELECT * FROM @CommunityTable WHERE CM_ID=cmn.CM_ID) THEN
		DELETE
	OUTPUT inserted.CM_ID, deleted.CM_ID INTO @UpdateCM
		;


	-- Update Search Areas
	MERGE INTO GBL_Community_AltAreaSearch sa
	USING (SELECT ct.CM_ID, ct2.CM_ID AS Search_CM_ID
			FROM @SearchCommunityTable st
			INNER JOIN @CommunityTable ct
				ON st.FKCMID=ct.FKCMID
			INNER JOIN @CommunityTable ct2
				ON st.Search_FKCMID=ct2.FKCMID
			) nt
		ON sa.CM_ID=nt.CM_ID
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (CM_ID, Search_CM_ID)
			VALUES (nt.CM_ID, nt.Search_CM_ID)
	WHEN NOT MATCHED BY SOURCE
			AND EXISTS(SELECT * FROM @CommunityTable WHERE CM_ID=sa.CM_ID) THEN
		DELETE
	OUTPUT inserted.CM_ID, deleted.CM_ID INTO @UpdateCM
		;
	
	-- Update Modified Dates
	UPDATE cm
		SET MODIFIED_DATE	= ISNULL(ct.MODIFIED_DATE,GETDATE()),
			MODIFIED_BY		= '(Import)'
	FROM GBL_Community cm
	INNER JOIN @CommunityTable ct
		ON cm.CM_GUID=ct.CM_GUID
	WHERE EXISTS(SELECT * FROM @UpdateCM tm WHERE cm.CM_ID=tm.CM_ID_NEW OR cm.CM_ID=tm.CM_ID_OLD)
	
	-- Remove extra provinces / countries not in use (e.g. by local records)
	DELETE FROM pv
		FROM GBL_ProvinceState pv
	WHERE NOT EXISTS(SELECT * FROM @ProvinceTable pt WHERE pt.ProvID=pv.ProvID)
		AND NOT EXISTS(SELECT * FROM GBL_Community cm WHERE cm.ProvinceState=pv.ProvID)
		
	-- Update extra provinces / countries to non-authorized status
	UPDATE GBL_ProvinceState
		SET Authorized=0
	WHERE Authorized=1 AND NOT EXISTS(SELECT * FROM @ProvinceTable pt WHERE pt.ProvID=GBL_ProvinceState.ProvID)
END

SELECT @Error AS Error, @ErrMsg AS ErrMsg

SELECT cm.CM_ID,
	cm.Source,
	cmn.Name,
	(SELECT TOP 1 Name FROM GBL_Community_Name WHERE CM_ID=cm.ParentCommunity ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID) AS Parent,
	CAST(CASE WHEN EXISTS(SELECT * FROM CIC_BT_CM pr WHERE pr.CM_ID=cm.CM_ID)
			OR EXISTS(SELECT * FROM VOL_OP_CM pr WHERE pr.CM_ID=cm.CM_ID) 
			OR EXISTS(SELECT * FROM GBL_BaseTable WHERE LOCATED_IN_CM=cm.CM_ID)
			OR EXISTS(SELECT * FROM CIC_Ward WHERE Municipality=cm.CM_ID)
			OR EXISTS(SELECT * FROM CIC_BusRoute WHERE Municipality=cm.CM_ID) 
			OR EXISTS(SELECT * FROM GBL_Community cm2 WHERE cm2.ParentCommunity=cm.CM_ID) THEN 1 ELSE 0 END AS bit) AS Used
	FROM GBL_Community cm
	LEFT JOIN GBL_Community_Name cmn
		ON cmn.CM_ID=cm.CM_ID AND LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cmn.CM_ID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE Authorized=0

SET NOCOUNT OFF






GO

GRANT EXECUTE ON  [dbo].[sp_GBL_Community_u_Import] TO [cioc_login_role]
GO
