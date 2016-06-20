SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_THS_Source_u]
	@MODIFIED_BY [varchar](50),
	@Data [xml],
	@ErrMsg [varchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Dec-2011
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@SourceObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@NameObjectName nvarchar(100)

SET @SourceObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Source')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')

DECLARE @SourceTable TABLE (
	SRC_ID int NOT NULL,
	CNT int NOT NULL
)

DECLARE @DescTable TABLE (
	SRC_ID int NOT NULL,
	CNT int NOT NULL,
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	SourceName nvarchar(100)
)

DECLARE @IDMap TABLE (
	SRC_ID int NULL,
	CNT int NULL,
	ACTN varchar(10)
)
DECLARE @BadCulturesDesc nvarchar(max),
		@BadDescription nvarchar(max),
		@MissingDescription nvarchar(max)

INSERT INTO @SourceTable 
SELECT 
	N.value('SRC_ID[1]', 'int') AS SRC_ID,
	N.value('CNT[1]', 'int') AS CNT
FROM @Data.nodes('//Source') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SourceObjectName, @ErrMsg

INSERT INTO @DescTable
SELECT
	N.value('SRC_ID[1]', 'int') AS SRC_ID,
	N.value('CNT[1]', 'int') AS CNT,
	iq.*
FROM @Data.nodes('//Source') AS T(N) CROSS APPLY 
	( SELECT 
		D.value('Culture[1]', 'varchar(5)') AS Culture,
		(SELECT LangID FROM STP_Language sl WHERE sl.Culture = D.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
		D.value('SourceName[1]', 'nvarchar(50)') AS SourceName
			FROM N.nodes('DESCS/DESC') AS T2(D) ) iq 
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SourceObjectName, @ErrMsg

SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
	FROM @DescTable nt
WHERE nt.LangID IS NULL

SELECT @BadDescription = COALESCE(@BadDescription + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '), '') + SourceName
FROM (SELECT DISTINCT SourceName 
	FROM @DescTable nt
	WHERE EXISTS(SELECT * FROM @DescTable nt2 
					WHERE nt.CNT <> nt2.CNT 
						AND nt.LangID=nt2.LangID AND nt.SourceName=nt2.SourceName)) AS iq	
						
SELECT @MissingDescription = COALESCE(@MissingDescription + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '), '') + CAST(SRC_ID AS varchar(20))
	FROM @SourceTable s
WHERE NOT EXISTS(SELECT * FROM @DescTable WHERE s.SRC_ID=SRC_ID)

IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, @LanguageObjectName)
END ELSE IF @MissingDescription IS NOT NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @SourceObjectName)
END ELSE IF @BadDescription IS NOT NULL BEGIN
	SET @Error = 6 -- Value in Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadDescription, @NameObjectName)
END 

DECLARE @Modified AS TABLE (
	SRC_ID int NULL
)

IF @Error = 0 BEGIN
	MERGE INTO THS_Source s
	USING @SourceTable nt
		ON s.SRC_ID=nt.SRC_ID
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT (CREATED_DATE, CREATED_BY, MODIFIED_DATE, MODIFIED_BY)
			VALUES (GETDATE(), @MODIFIED_BY, GETDATE(), @MODIFIED_BY)
	WHEN NOT MATCHED BY SOURCE AND NOT EXISTS(SELECT * FROM THS_Subject WHERE SRC_ID=s.SRC_ID)THEN
		DELETE
	OUTPUT INSERTED.SRC_ID, nt.CNT, $action INTO @IDMap
		;
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SourceObjectName, @ErrMsg
END

IF @Error = 0 BEGIN	
	DELETE @IDMap WHERE ACTN <> 'INSERT' 
	
	MERGE INTO THS_Source_Name sn
	USING (SELECT LangID, SourceName, CASE WHEN dt.SRC_ID = -1 THEN map.SRC_ID ELSE dt.SRC_ID END AS SRC_ID
			FROM @DescTable dt
			LEFT JOIN @IDMap map
				ON map.CNT=dt.CNT) nt
				
		ON sn.LangID=nt.LangID AND sn.SRC_ID=nt.SRC_ID
	WHEN MATCHED AND sn.SourceName <> nt.SourceName THEN
		UPDATE SET SourceName=nt.SourceName
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (SRC_ID, LangID, SourceName) VALUES (nt.SRC_ID, nt.LangID, nt.SourceName)
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE
	OUTPUT CASE WHEN INSERTED.SRC_ID IS NOT NULL THEN INSERTED.SRC_ID ELSE DELETED.SRC_ID END  INTO @Modified
		;
		
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SourceObjectName, @ErrMsg
END

IF @Error = 0 BEGIN	
	UPDATE THS_Source SET
		MODIFIED_DATE = GETDATE(),
		MODIFIED_BY=@MODIFIED_BY
	WHERE EXISTS(SELECT * FROM @Modified WHERE THS_Source.SRC_ID=SRC_ID)
		
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SourceObjectName, @ErrMsg
END

RETURN @Error

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_THS_Source_u] TO [cioc_login_role]
GO
