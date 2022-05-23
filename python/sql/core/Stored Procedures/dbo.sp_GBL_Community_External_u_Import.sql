SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Community_External_u_Import]
	@ComData [xml],
	@SystemCode varchar(30),
	@SystemName varchar(200),
	@CopyrightHolder1 nvarchar(255),
	@CopyrightHolder2 nvarchar(255),
	@ContactEmail varchar(100)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error	int,
		@ErrMsg	nvarchar(500)

SET @Error = 0

DECLARE	@CommunityObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@ProvinceStateObjectName nvarchar(100)

SET @CommunityObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @ProvinceStateObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Province/State')

DECLARE @ExternalCommunityTable TABLE (
	FKEXTID int NOT NULL PRIMARY KEY,
	EXT_ID int NULL INDEX IX1 NONCLUSTERED,
	EXT_GUID uniqueidentifier NOT NULL INDEX IX2 NONCLUSTERED,
	AreaName nvarchar(200) NOT NULL,
	PrimaryAreaType varchar(30) NULL,
	SubAreaType varchar(30) NULL,
	AIRSExportType varchar(20) NULL,
	FKParentID int NULL,
	FKProvice nvarchar(100) NULL,
	FKCountry nvarchar(100) NULL, 
	ProvinceState int NULL
)

DECLARE @ExternalMappingOneTable table (
	CM_GUID uniqueidentifier NOT NULL PRIMARY KEY,
	CM_ID int NULL INDEX IX1 NONCLUSTERED,
	FKEXTID int NULL,
	EXT_ID int NULL
)

DECLARE @ExternalMappingAllTable table (
	CM_GUID uniqueidentifier NOT NULL INDEX IX2 NONCLUSTERED,
	CM_ID int NULL INDEX IX1 NONCLUSTERED,
	FKEXTID int NULL,
	EXT_ID int NULL
)

-- Create Table of Communities (Main Communities)
INSERT INTO @ExternalCommunityTable
		(FKEXTID,
		 EXT_GUID,
		 AreaName,
		 PrimaryAreaType,
		 SubAreaType,
		 AIRSExportType,
		 FKParentID,
		 FKProvice,
		 FKCountry,
		 ProvinceState
		)
SELECT	N.value('@ID', 'int') AS FKEXTID,
		N.value('@GUID', 'uniqueidentifier') AS EXT_GUID,
		N.value('@AreaName', 'nvarchar(200)') AS AreaName,
		N.value('@PrimaryAreaType', 'varchar(30)') AS PrimaryAreaType,
		N.value('@SubAreaType', 'varchar(30)') AS SubAreaType,
		N.value('@AIRSExportType', 'varchar(20)') AS AIRSExportType,
		N.value('@Parent_ID', 'int') AS FKParentID,
		N.value('@Province', 'nvarchar(100)') AS Province,
		N.value('@Country', 'nvarchar(100)') AS Country,
		(SELECT ProvID FROM GBL_ProvinceState pt WHERE ISNULL(pt.NameOrCode,'')=ISNULL(N.value('@Province', 'nvarchar(100)'),'') AND ISNULL(pt.Country, '')=ISNULL(N.value('@Country', 'nvarchar(100)'), '')) AS ProvinceState
FROM @ComData.nodes('//MapEntry') AS T(N)

INSERT INTO @ExternalMappingOneTable
		(CM_GUID, FKEXTID)
SELECT	N.value('@GUID', 'uniqueidentifier') AS EXT_GUID,
		N.value('@MapOne_EXT_ID', 'int') AS FKEXTID
FROM @ComData.nodes('//Community') AS T(N)

INSERT INTO @ExternalMappingAllTable
		(CM_GUID, FKEXTID)
SELECT	N.value('../../@GUID', 'uniqueidentifier') AS EXT_GUID,
		N.value('@EXT_ID', 'int') AS FKEXTID
FROM @ComData.nodes('//Map') AS T(N)

-- Insertion error (probably primary key)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityObjectName, @ErrMsg

-- Match Communities on GUID
UPDATE ct SET EXT_ID=cm.EXT_ID
	FROM @ExternalCommunityTable ct
	INNER JOIN GBL_Community_External_Community cm
		ON ct.EXT_GUID=cm.EXT_GUID

/*
-- Invalid Province in incoming Community data
IF EXISTS(SELECT * FROM @CommunityTable ct WHERE ct.FKProvID IS NOT NULL AND NOT EXISTS(SELECT * FROM @ProvinceTable pt WHERE ct.FKProvID=pt.FKProvID)) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST((SELECT TOP 1 ct.FKProvID FROM @CommunityTable ct WHERE ct.FKProvID IS NOT NULL AND NOT EXISTS(SELECT * FROM @ProvinceTable pt WHERE ct.FKProvID=pt.FKProvID)) AS varchar), @ProvinceStateObjectName)
END

*/

IF @Error = 0 BEGIN

	IF EXISTS(SELECT * FROM GBL_Community_External_System WHERE SystemCode = @SystemCode) BEGIN
		UPDATE GBL_Community_External_System 
		SET SystemName=@SystemName, CopyrightHolder1=@CopyrightHolder1, CopyrightHolder2=@CopyrightHolder2, ContactEmail=@ContactEmail
		WHERE SystemCode = @SystemCode
	END ELSE BEGIN
		INSERT INTO GBL_Community_External_System
				(SystemCode,
				 SystemName,
				 CopyrightHolder1,
				 CopyrightHolder2,
				 ContactEmail
				)
		VALUES	(@SystemCode, -- SystemCode - varchar(30)
				 @SystemName, -- SystemName - varchar(200)
				 @CopyrightHolder1, -- CopyrightHolder1 - nvarchar(255)
				 @CopyrightHolder2, -- CopyrightHolder2 - nvarchar(255)
				 @ContactEmail  -- ContactEmail - varchar(100)
				)
	END

	DELETE FROM GBL_Community_External_Map
	WHERE NOT EXISTS(SELECT * FROM @ExternalCommunityTable WHERE MapOneEXTID=EXT_ID)

	DELETE mp FROM GBL_Community_External_Map_All mp
	WHERE NOT EXISTS(SELECT * FROM @ExternalCommunityTable ec WHERE ec.EXT_ID=mp.EXT_ID)
	
	-- Update Basic Communities (Round 1)
	MERGE INTO GBL_Community_External_Community cm
	USING @ExternalCommunityTable ct
		ON ct.EXT_GUID=cm.EXT_GUID AND cm.SystemCode=@SystemCode
	WHEN MATCHED AND (
			cm.AreaName + '.' <> ct.AreaName + '.'
			OR ISNULL(cm.PrimaryAreaType, '') <> ISNULL(ct.PrimaryAreaType, '')
			OR ISNULL(cm.SubAreaType, '') <> ISNULL(ct.SubAreaType, '')
			OR ISNULL(cm.AIRSExportType, '') <> ISNULL(ct.AIRSExportType, '')
			OR ISNULL(cm.ProvinceState, -1) <> ISNULL(ct.ProvinceState, -1)
			) THEN
		UPDATE SET
			AreaName		= ct.AreaName,
			PrimaryAreaType	= ct.PrimaryAreaType,
			SubAreaType		= ct.SubAreaType,
			AIRSExportType	= ct.AIRSExportType ,
			ProvinceState	= ct.ProvinceState
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			EXT_GUID,
			SystemCode,
			AreaName,
			PrimaryAreaType,
			SubAreaType,
			AIRSExportType,
			ProvinceState
		) VALUES (
			ct.EXT_GUID,
			@SystemCode,
			ct.AreaName,
			ct.PrimaryAreaType,
			ct.SubAreaType,
			ct.AIRSExportType,
			ct.ProvinceState
		)
	WHEN NOT MATCHED BY SOURCE
			AND cm.SystemCode = @SystemCode THEN
		DELETE
		;
		
	UPDATE ct SET EXT_ID = cm.EXT_ID
		FROM @ExternalCommunityTable ct
		INNER JOIN GBL_Community_External_Community cm
			ON ct.EXT_GUID=cm.EXT_GUID
		WHERE ct.EXT_ID IS NULL


	UPDATE ex SET EXT_ID=cm.EXT_ID
	FROM @ExternalMappingOneTable ex
	INNER JOIN @ExternalCommunityTable cm
		ON cm.FKEXTID = ex.FKEXTID

	UPDATE ex SET CM_ID=cm.CM_ID
	FROM @ExternalMappingOneTable ex
	INNER JOIN GBL_Community cm
		ON cm.CM_GUID = ex.CM_GUID

	DELETE FROM @ExternalMappingOneTable WHERE CM_ID IS NULL

	UPDATE ex SET EXT_ID=cm.EXT_ID
	FROM @ExternalMappingAllTable ex
	INNER JOIN @ExternalCommunityTable cm
		ON cm.FKEXTID = ex.FKEXTID

	UPDATE ex SET CM_ID=cm.CM_ID
	FROM @ExternalMappingAllTable ex
	INNER JOIN GBL_Community cm
		ON cm.CM_GUID = ex.CM_GUID

	DELETE FROM @ExternalMappingAllTable WHERE CM_ID IS NULL OR EXT_ID IS NULL
	
	MERGE INTO GBL_Community_External_Map mp
	USING @ExternalMappingOneTable nt
		ON mp.CM_ID=nt.CM_ID AND mp.SystemCode=@SystemCode
	WHEN MATCHED AND ISNULL(mp.MapOneEXTID, '')<>ISNULL(nt.EXT_ID, '') THEN
		UPDATE SET MapOneEXTID = nt.EXT_ID
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (SystemCode, CM_ID, MapOneEXTID) VALUES (@SystemCode, nt.CM_ID, nt.EXT_ID)
	WHEN NOT MATCHED BY SOURCE AND mp.SystemCode = @SystemCode THEN
		DELETE 
		;

	MERGE INTO GBL_Community_External_Map_All mp
	USING @ExternalMappingAllTable nt
		ON mp.CM_ID=nt.CM_ID AND mp.EXT_ID=nt.EXT_ID AND mp.SystemCode=@SystemCode
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (SystemCode, CM_ID, EXT_ID) VALUES (@SystemCode, nt.CM_ID, nt.EXT_ID)
	WHEN NOT MATCHED BY SOURCE AND mp.SystemCode = @SystemCode THEN
		DELETE 
		;

	DELETE mo FROM GBL_Community_External_Map mo
	WHERE MapOneEXTID IS NULL AND SystemCode=@SystemCode 
		AND NOT EXISTS(SELECT * FROM GBL_Community_External_Map_All WHERE CM_ID=mo.CM_ID AND SystemCode=@SystemCode)

	UPDATE excm
		SET excm.Parent_ID=ett2.EXT_ID
	FROM dbo.GBL_Community_External_Community excm
	INNER JOIN @ExternalCommunityTable ett
		ON excm.EXT_ID=ett.EXT_ID
	INNER JOIN @ExternalCommunityTable ett2
		ON ett.FKParentID=ett2.FKEXTID
END

SELECT @Error AS Error, @ErrMsg AS ErrMsg

-- add a second result set to match the Main community import
SELECT 0 AS Something WHERE 0=1

SET NOCOUNT OFF







GO

GRANT EXECUTE ON  [dbo].[sp_GBL_Community_External_u_Import] TO [cioc_login_role]
GO
