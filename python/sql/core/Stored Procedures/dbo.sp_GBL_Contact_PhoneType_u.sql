SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Contact_PhoneType_u]
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

DECLARE	@PhoneTypeObjectName nvarchar(60)
SET @PhoneTypeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Contact PhoneType')

DECLARE @PhoneTypeTable TABLE (
	PhoneType nvarchar(20),
	Culture varchar(5),
	LangID int null
)

INSERT INTO @PhoneTypeTable (PhoneType, Culture, LangID)
SELECT 
	N.value('PhoneType[1]', 'nvarchar(20)') AS PhoneType,
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language WHERE Culture=N.value('Culture[1]', 'varchar(5)')) AS LangID
FROM @ListValues.nodes('//CHK') as T(N)

DECLARE @BadCulturesDesc nvarchar(max), @UsedNames nvarchar(max)
SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @PhoneTypeTable nt
WHERE LangID IS NULL

IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, cioc_shared.dbo.fn_SHR_STP_ObjectName('Language'))
END ELSE BEGIN

	MERGE INTO GBL_Contact_PhoneType dst
	USING (SELECT DISTINCT PhoneType,LangID FROM @PhoneTypeTable) src
		ON dst.PhoneType=src.PhoneType AND dst.LangID=src.LangID
	WHEN MATCHED AND src.PhoneType<>dst.PhoneType COLLATE Latin1_General_100_CS_AS THEN
		UPDATE SET PhoneType=src.PhoneType
		
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (PhoneType,LangID)
			VALUES (src.PhoneType, src.LangID)
	
	WHEN NOT MATCHED BY SOURCE THEN 
		DELETE 
		
		;
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PhoneTypeObjectName, @ErrMsg
	
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Contact_PhoneType_u] TO [cioc_login_role]
GO
