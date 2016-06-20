SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ExcelProfile_u]
	@ProfileID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@MemberID [int],
	@ColumnHeaders [bit],
	@Descriptions [xml],
	@Views [xml],
	@Fields [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: CL
	Checked on: 08-Jun-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName	nvarchar(100),
		@ExcelProfileObjectName nvarchar(100),
		@FieldObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ExcelProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Excel Profile')
SET @FieldObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Field')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL PRIMARY KEY,
	LangID smallint NULL,
	Name nvarchar(50) NULL
)

DECLARE @ViewTable TABLE (
	ViewType int NOT NULL PRIMARY KEY
)

DECLARE @FieldTable TABLE (
	FieldID int NOT NULL PRIMARY KEY,
	DisplayOrder tinyint NULL,
	SortByOrder tinyint NULL
)

DECLARE @UsedNamesDesc nvarchar(max),
		@BadCulturesDesc nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	Name
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('Name[1]', 'nvarchar(50)') AS Name
FROM @Descriptions.nodes('//DESC') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ExcelProfileObjectName, @ErrMsg

INSERT INTO @ViewTable
	( ViewType )
SELECT 
	N.value('.', 'int') AS ViewType
FROM @Views.nodes('//VIEW') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg

INSERT INTO @FieldTable (
	FieldID,
	DisplayOrder,
	SortByOrder
)
SELECT
	N.value('FieldID[1]', 'int') AS FieldID,
	N.value('DisplayOrder[1]', 'tinyint') AS DisplayOrder,
	N.value('SortByOrder[1]', 'tinyint') AS SortByOrder
FROM @Fields.nodes('//FIELD') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

UPDATE @DescTable
	SET Name = (SELECT TOP 1 Name FROM @DescTable WHERE Name IS NOT NULL ORDER BY LangID)
WHERE Name IS NULL

SELECT @UsedNamesDesc = COALESCE(@UsedNamesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM GBL_ExcelProfile ep INNER JOIN GBL_ExcelProfile_Name epn ON ep.ProfileID=epn.ProfileID WHERE Name=nt.Name AND LangID=nt.LangID AND ep.ProfileID<>@ProfileID)

SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Profile ID exists ?
END ELSE IF @ProfileID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_ExcelProfile WHERE ProfileID=@ProfileID AND Domain=1) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar), @ExcelProfileObjectName)
-- Profile belongs to member ?
END ELSE IF @ProfileID IS NOT NULL AND NOT EXISTS (SELECT * FROM GBL_ExcelProfile WHERE MemberID=@MemberID AND ProfileID=@ProfileID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- At least one language used ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @ExcelProfileObjectName)
-- Duplicate language data given ?
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
-- Name provided ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE Name IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @ExcelProfileObjectName)
-- Name in use ?
END ELSE IF @UsedNamesDesc IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNamesDesc, @NameObjectName)
-- Invalid language ?
END ELSE IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, @LanguageObjectName)
END

IF @Error = 0 BEGIN
	IF @ProfileID IS NULL BEGIN
		INSERT INTO GBL_ExcelProfile (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			Domain,
			ColumnHeaders
		) VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			1,
			@ColumnHeaders
		)
		SELECT @ProfileID = SCOPE_IDENTITY()
	END ELSE BEGIN
		UPDATE GBL_ExcelProfile
		SET	MODIFIED_DATE		= GETDATE(),
			MODIFIED_BY			= @MODIFIED_BY,
			ColumnHeaders		= @ColumnHeaders

		WHERE ProfileID = @ProfileID	
	END
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ExcelProfileObjectName, @ErrMsg
	

	IF @Error=0 AND @ProfileID IS NOT NULL BEGIN
		MERGE INTO GBL_ExcelProfile_Name epn
		USING @DescTable nt
			ON epn.ProfileID=@ProfileID AND epn.LangID=nt.LangID
		WHEN MATCHED THEN
			UPDATE SET
			Name		= nt.Name
			
		WHEN NOT MATCHED BY TARGET THEN
		INSERT ( ProfileID, LangID, Name )
			VALUES ( @ProfileID, nt.LangID, nt.Name )
		 
		
		WHEN NOT MATCHED BY SOURCE AND epn.ProfileID=@ProfileID THEN 
			DELETE
			
			;
		 
		
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ExcelProfileObjectName, @ErrMsg
		
		MERGE INTO CIC_View_ExcelProfile epv
		USING (SELECT nt.* FROM @ViewTable nt INNER JOIN CIC_View vw
					ON vw.ViewType=nt.ViewType AND vw.MemberID=@MemberID) nt
			ON epv.ProfileID=@ProfileID AND epv.ViewType=nt.ViewType
		WHEN NOT MATCHED BY TARGET THEN
			INSERT ( ProfileID, ViewType ) VALUES ( @ProfileID, nt.ViewType )
			
		WHEN NOT MATCHED BY SOURCE AND epv.ProfileID=@ProfileID THEN
			DELETE
			
			;
		
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ViewObjectName, @ErrMsg
		
		DELETE FROM @FieldTable WHERE SortByOrder IS NULL AND DisplayOrder IS NULL
		
		MERGE INTO GBL_ExcelProfile_Fld epf
		USING (SELECT nt.* FROM @FieldTable nt
				INNER JOIN GBL_FieldOption fo
					ON fo.FieldID=nt.FieldID
					
				WHERE fo.PB_ID IS NULL OR ( 
					EXISTS(SELECT * FROM CIC_Publication pb WHERE pb.PB_ID=fo.PB_ID AND (pb.MemberID IS NULL OR pb.MemberID=@MemberID)) 
					AND NOT EXISTS(SELECT * FROM CIC_Publication_InactiveByMember pbi WHERE pbi.PB_ID=fo.PB_ID AND pbi.MemberID=@MemberID) )
				) nt
			ON epf.GBLFieldID=nt.FieldID AND epf.ProfileID=@ProfileID
		WHEN MATCHED THEN
			UPDATE SET	DisplayOrder = nt.DisplayOrder, SortByOrder = nt.SortByOrder
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ProfileID, GBLFieldID, DisplayOrder, SortByOrder)
				VALUES (@ProfileID, nt.FieldID, nt.DisplayOrder, nt.SortByOrder)
				
		WHEN NOT MATCHED BY SOURCE AND epf.ProfileID=@ProfileID THEN
			DELETE
			
			;
		
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg
	END
END

RETURN @Error

SET NOCOUNT OFF

















GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ExcelProfile_u] TO [cioc_login_role]
GO
