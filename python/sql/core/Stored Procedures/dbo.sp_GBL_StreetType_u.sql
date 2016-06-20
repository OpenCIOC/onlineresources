
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_StreetType_u]
	@MODIFIED_BY nvarchar(50),
	@ListValues xml,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 22-Jul-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@PostalStreetTypeObjectName nvarchar(60)
SET @PostalStreetTypeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Street Type')

DECLARE @StreetTypeTable TABLE (
	SType_ID int,
	StreetType nvarchar(20),
	AfterName bit,
	Culture varchar(5),
	LangID int null
)

INSERT INTO @StreetTypeTable (SType_ID, StreetType, AfterName, Culture, LangID)
SELECT 
	N.value('SType_ID[1]', 'int') AS SType_ID,
	N.value('StreetType[1]', 'nvarchar(20)') AS StreetType,
	N.value('AfterName[1]', 'bit') AS AfterName,
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language WHERE Culture=N.value('Culture[1]', 'varchar(5)')) AS LangID
FROM @ListValues.nodes('//CHK') AS T(N)

DECLARE @BadCulturesDesc nvarchar(MAX), @UsedNames nvarchar(MAX)
SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @StreetTypeTable nt
WHERE LangID IS NULL

SELECT DISTINCT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + StreetType
FROM @StreetTypeTable nt
WHERE EXISTS(SELECT * FROM @StreetTypeTable ep WHERE StreetType=nt.StreetType AND AfterName=nt.AfterName AND SType_ID<>nt.SType_ID)

IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, cioc_shared.dbo.fn_SHR_STP_ObjectName('Language'))
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value in Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, cioc_shared.dbo.fn_SHR_STP_ObjectName('Name'))
END ELSE BEGIN
	MERGE INTO GBL_StreetType dst
	USING (SELECT DISTINCT SType_ID, StreetType, AfterName, LangID FROM @StreetTypeTable) src
		ON dst.SType_ID=src.SType_ID
	WHEN MATCHED AND src.StreetType<>dst.StreetType COLLATE Latin1_General_100_CS_AS OR src.AfterName<>dst.AfterName OR src.LangID<>dst.LangID THEN
		UPDATE SET StreetType=src.StreetType, AfterName=src.AfterName, LangID=src.LangID, MODIFIED_DATE=GETDATE(), MODIFIED_BY=@MODIFIED_BY
		
		
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (CREATED_BY, CREATED_DATE, MODIFIED_BY, MODIFIED_DATE, StreetType, AfterName, LangID)
			VALUES (@MODIFIED_BY, GETDATE(), @MODIFIED_BY, GETDATE(), src.StreetType, src.AfterName, src.LangID)
	
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE 
		
		;
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PostalStreetTypeObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF




GO

GRANT EXECUTE ON  [dbo].[sp_GBL_StreetType_u] TO [cioc_login_role]
GO
