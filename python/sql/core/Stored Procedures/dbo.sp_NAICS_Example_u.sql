SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_NAICS_Example_u]
	@Code [varchar](6),
	@MODIFIED_BY [varchar](50),
	@Data [xml],
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@ExampleObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@DescriptionObjectName nvarchar(100)

SET @ExampleObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Example')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @DescriptionObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Description')

DECLARE @ExampleTable TABLE (
	Example_ID int NOT NULL,
	LangID smallint NOT NULL,
	Description nvarchar(255) NOT NULL,
	CNT int NOT NULL
)

DECLARE @BadCulturesDesc nvarchar(max),
		@BadDescription nvarchar(max)

INSERT INTO @ExampleTable 
SELECT 
	N.value('Example_ID[1]', 'int') AS Example_ID,
	N.value('LangID[1]', 'smallint') AS LangID,
	N.value('Description[1]', 'nvarchar(255)') AS Description,
	N.value('CNT[1]', 'int') AS CNT
FROM @Data.nodes('//Example') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ExampleObjectName, @ErrMsg


SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ' (' + CAST(nt.LangID AS varchar(6)) + ')')
FROM @ExampleTable nt
LEFT JOIN STP_Language l
	ON l.LangID=nt.LangID
WHERE l.Active=0 OR l.LangID IS NULL

SELECT @BadDescription = COALESCE(@BadDescription + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '), '') + Description
FROM (SELECT DISTINCT Description 
	FROM @ExampleTable nt
	WHERE EXISTS(SELECT * FROM @ExampleTable nt2 
					WHERE nt.CNT <> nt2.CNT 
						AND nt.LangID=nt2.LangID AND nt.Description=nt2.Description)) AS iq

IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, @LanguageObjectName)
END ELSE IF @BadDescription IS NOT NULL BEGIN
	SET @Error = 6 -- Value in Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadDescription, @DescriptionObjectName)
END 

IF @Error = 0 BEGIN
	MERGE INTO NAICS_Example ex
	USING @ExampleTable nt
		ON ex.Example_ID=nt.Example_ID
	WHEN MATCHED AND ex.Description<>nt.Description OR ex.LangID<>nt.LangID THEN
		UPDATE SET 
			MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY,
		 	Description		= nt.Description,
			LangID			= nt.LangID
			
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY, Code, Description, LangID)
			VALUES (GETDATE(), @MODIFIED_BY, GETDATE(), @MODIFIED_BY, @Code, nt.Description, nt.LangID)
	WHEN NOT MATCHED BY SOURCE AND ex.Code=@Code THEN
		DELETE
		;
		
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ExampleObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_NAICS_Example_u] TO [cioc_login_role]
GO
