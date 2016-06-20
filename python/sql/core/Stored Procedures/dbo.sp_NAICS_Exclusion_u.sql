SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_NAICS_Exclusion_u]
	@Code varchar(6),
	@MODIFIED_BY [varchar](50),
	@Data xml,
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

DECLARE	@ExclusionObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@DescriptionObjectName nvarchar(100)

SET @ExclusionObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Exclusion')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @DescriptionObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Description')

DECLARE @ExclusionTable TABLE (
	Exclusion_ID int NOT NULL,
	LangID smallint NOT NULL,
	Description nvarchar(255) NOT NULL,
	Establishment bit NOT NULL,
	CNT int NOT NULL
)

DECLARE @UseCodesTable TABLE (
	Exclusion_ID int NOT NULL,
	UseCode varchar(6) NOT NULL,
	CNT int NOT NULL
)

DECLARE @IDMap TABLE (
	Exclusion_ID int NULL,
	CNT int NULL,
	ACTN varchar(10) NULL
)

DECLARE @BadCulturesDesc nvarchar(max),
		@BadDescription nvarchar(max)

INSERT INTO @ExclusionTable 
SELECT 
	N.value('Exclusion_ID[1]', 'int') AS Exclusion_ID,
	N.value('LangID[1]', 'smallint') AS LangID,
	N.value('Description[1]', 'nvarchar(255)') AS Description,
	N.value('Establishment[1]', 'bit') AS Establishment,
	N.value('CNT[1]', 'int') AS CNT
FROM @Data.nodes('//Exclusion') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ExclusionObjectName, @ErrMsg

INSERT INTO @UseCodesTable (
	Exclusion_ID,
	CNT,
	UseCode
)
SELECT
	N.value('Exclusion_ID[1]', 'int') AS Exclusion_ID,
	N.value('CNT[1]', 'int') AS CNT,
	iq.*

FROM @Data.nodes('//Exclusion') as T(N) CROSS APPLY 
	( SELECT D.value('.', 'int') AS UseCode
			FROM N.nodes('UseCodes/UseCode') AS T2(D) ) iq 
WHERE EXISTS(SELECT * FROM NAICS WHERE Code=iq.UseCode) AND iq.UseCode<>@Code -- Flag bad codes?
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ExclusionObjectName, @ErrMsg


SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown') + ' (' + CAST(nt.LangID AS varchar(6)) + ')')
	FROM @ExclusionTable nt
	LEFT JOIN STP_Language l
		ON l.LangID=nt.LangID
WHERE l.Active=0 OR l.LangID IS NULL

SELECT @BadDescription = COALESCE(@BadDescription + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '), '') + Description
FROM (SELECT DISTINCT Description 
	FROM @ExclusionTable nt
	WHERE EXISTS(SELECT * FROM @ExclusionTable nt2 
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
	-- We can't cascase the delete in the NAICS_Exclusion MERGE statement. 
	-- Explicitly delete UseCodes before deleting the exclusions in the 
	-- merge statement.
	DELETE exu 
	FROM NAICS_Exclusion_Use exu 
	INNER JOIN NAICS_Exclusion ex
		ON exu.Exclusion_ID=ex.Exclusion_ID
	LEFT JOIN @ExclusionTable nt
		ON ex.Exclusion_ID=nt.Exclusion_ID
	WHERE ex.Code=@Code AND nt.Exclusion_ID IS NULL
	
	MERGE INTO NAICS_Exclusion ex
	USING @ExclusionTable nt
		ON ex.Exclusion_ID=nt.Exclusion_ID
	WHEN MATCHED AND ex.Description<>nt.Description OR ex.LangID<>nt.LangID OR ex.Establishment<>nt.Establishment THEN
		UPDATE SET 
			MODIFIED_DATE	= GETDATE(),
			MODIFIED_BY		= @MODIFIED_BY,
		 	Description		= nt.Description,
			Establishment	= nt.Establishment,
			LangID			= nt.LangID
			
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY, Code, Description, Establishment, LangID)
			VALUES (GETDATE(), @MODIFIED_BY, GETDATE(), @MODIFIED_BY, @Code, nt.Description, nt.Establishment, nt.LangID)
	WHEN NOT MATCHED BY SOURCE AND ex.Code=@Code THEN
		DELETE
		
	OUTPUT INSERTED.Exclusion_ID, nt.CNT, $action INTO @IDMap
		;
		
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ExclusionObjectName, @ErrMsg
	
	DELETE FROM @IDMap WHERE ACTN <> 'INSERT'
	
	IF @Error = 0 BEGIN
		MERGE INTO NAICS_Exclusion_Use exu
		USING (SELECT UseCode, CASE WHEN uc.Exclusion_ID = -1 THEN map.Exclusion_ID ELSE uc.Exclusion_ID END AS Exclusion_ID
			FROM @UseCodesTable uc
			LEFT JOIN @IDMap map
				ON map.CNT=uc.CNT ) nt
			
		ON exu.Exclusion_ID = nt.Exclusion_ID AND exu.UseCode=nt.UseCode
		
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY, Exclusion_ID, UseCode)
			VALUES (GETDATE(), @MODIFIED_BY, GETDATE(), @MODIFIED_BY, nt.Exclusion_ID, nt.UseCode)
			
		WHEN NOT MATCHED BY SOURCE AND EXISTS(SELECT * FROM @UseCodesTable WHERE Exclusion_ID = exu.Exclusion_ID) 
					OR EXISTS(SELECT * FROM @IDMap m WHERE m.Exclusion_ID=exu.Exclusion_ID) THEN
			DELETE
			
			; -- MERGE statement must be terminated by semi-colon.
				
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ExclusionObjectName, @ErrMsg
	END
		
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_NAICS_Exclusion_u] TO [cioc_login_role]
GO
