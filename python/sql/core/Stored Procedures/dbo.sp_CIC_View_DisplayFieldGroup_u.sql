SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CIC_View_DisplayFieldGroup_u]
	@ViewType int,
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@AgencyCode char(3),
	@Data [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@FieldGroupObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @FieldGroupObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Field Group')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @FieldTable TABLE (
	DisplayFieldGroupID int NOT NULL,
	CNT int NOT NULL,
	DisplayOrder tinyint NOT NULL
)

DECLARE @DescTable TABLE (
	DisplayFieldGroupID int NOT NULL,
	CNT int NOT NULL,
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Name nvarchar(100) NULL
)

DECLARE @NewIDs Table (
	DisplayFieldGroupID int NULL,
	CNT int NULL,
	ACTN varchar(10)
)

DECLARE @UsedNamesDesc nvarchar(max),
		@BadCulturesDesc nvarchar(max)

INSERT INTO @FieldTable 
SELECT 
	N.value('DisplayFieldGroupID[1]', 'int') AS DisplayFieldGroupID,
	N.value('CNT[1]', 'int') AS CNT,
	N.value('DisplayOrder[1]', 'int') AS DisplayOrder
FROM @Data.nodes('//GROUP') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldGroupObjectName, @ErrMsg

INSERT INTO @DescTable (
	DisplayFieldGroupID,
	CNT,
	Culture,
	LangID,
	Name
)
SELECT
	N.value('DisplayFieldGroupID[1]', 'int') AS DisplayFieldGroupID,
	N.value('CNT[1]', 'int') AS CNT,
	iq.*

FROM @Data.nodes('//GROUP') as T(N) CROSS APPLY 
	( SELECT 
		D.value('Culture[1]', 'varchar(5)') AS Culture,
		(SELECT LangID FROM dbo.STP_Language sl WHERE sl.Culture = D.value('Culture[1]', 'varchar(5)') AND ActiveRecord=1) AS LangID,
		D.value('Name[1]', 'nvarchar(100)') AS Name
			FROM N.nodes('DESCS/DESC') AS T2(D) ) iq 
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldGroupObjectName, @ErrMsg

SELECT @UsedNamesDesc = COALESCE(@UsedNamesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM dbo.CIC_View_DisplayFieldGroup fg INNER JOIN CIC_View_DisplayFieldGroup_Name fgn ON fg.DisplayFieldGroupID=fgn.DisplayFieldGroupID WHERE fgn.Name=nt.Name AND LangID=nt.LangID AND fg.DisplayFieldGroupID<>nt.DisplayFieldGroupID AND fg.ViewType=@ViewType)

SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM dbo.STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- View given ?
END ELSE IF @ViewType IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
-- View exists ?
END ELSE IF NOT EXISTS (SELECT * FROM dbo.CIC_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
-- View belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM dbo.CIC_View WHERE MemberID=@MemberID AND ViewType=@ViewType) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.CIC_View WHERE ViewType=@ViewType AND (Owner IS NULL OR Owner = @AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
-- At least one language used ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @ViewObjectName)
-- Duplicate language data given ?
/*
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY DisplayFieldGroupID, LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
*/
-- Name provided ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE Name IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @ViewObjectName)
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
	MERGE INTO dbo.CIC_View_DisplayFieldGroup AS fg
	USING @FieldTable AS nt
	ON fg.DisplayFieldGroupID=nt.DisplayFieldGroupID AND fg.DisplayFieldGroupID <> -1
	WHEN MATCHED --AND fg.DisplayOrder<>nt.DisplayOrder
		THEN UPDATE SET 
			DisplayOrder = nt.DisplayOrder
			
	WHEN NOT MATCHED BY TARGET
		THEN INSERT ( ViewType, DisplayOrder ) 
				VALUES ( @ViewType, nt.DisplayOrder )
	
	WHEN NOT MATCHED BY SOURCE AND fg.ViewType=@ViewType
		THEN DELETE
		
	OUTPUT INSERTED.DisplayFieldGroupID, nt.CNT, $action INTO @NewIDs ;
	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldGroupObjectName, @ErrMsg
	
	DELETE FROM @NewIDs WHERE ACTN <> 'INSERT'
		
	IF @Error=0  BEGIN
		
		MERGE INTO dbo.CIC_View_DisplayFieldGroup_Name AS fgn
		USING ( 
			SELECT CASE WHEN nfgn.DisplayFieldGroupID = -1 THEN nid.DisplayFieldGroupID ELSE nfgn.DisplayFieldGroupID END AS DisplayFieldGroupID,
				nfgn.LangID, nfgn.Name
			FROM @DescTable nfgn
			LEFT JOIN @NewIDs nid
				ON nfgn.CNT=nid.CNT)
			AS nt
			
		ON fgn.DisplayFieldGroupID=nt.DisplayFieldGroupID AND fgn.LangID=nt.LangID
		WHEN MATCHED AND fgn.Name <> nt.Name AND NULLIF(nt.Name, '') IS NOT NULL
			THEN UPDATE SET Name=nt.Name
			
		WHEN MATCHED AND NULLIF(nt.Name, '') IS NULL 
			THEN DELETE
		
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (DisplayFieldGroupID, LangID, Name) 
				VALUES (nt.DisplayFieldGroupID, nt.LangID, nt.Name )
				;

		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldGroupObjectName, @ErrMsg

	END
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_DisplayFieldGroup_u] TO [cioc_login_role]
GO
