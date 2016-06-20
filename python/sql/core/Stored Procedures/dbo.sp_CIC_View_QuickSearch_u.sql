
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CIC_View_QuickSearch_u]
	@ViewType int,
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@AgencyCode char(3),
	@Data [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6.2
	Checked by: CL
	Checked on: 21-Apr-2015
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@QuickSearchObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @QuickSearchObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Quick Search')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @QuickSearchTable TABLE (
	QuickSearchID int NOT NULL,
	CNT int NOT NULL,
    PageName varchar(255) NOT NULL,
    PromoteToTab bit NOT NULL,
    QueryParameters varchar(1000) NOT NULL,
	DisplayOrder tinyint NOT NULL
)

DECLARE @DescTable table (
	QuickSearchID int NOT NULL,
	CNT int NOT NULL,
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Name nvarchar(100) NULL
)

DECLARE @NewIDs table (
	QuickSearchID int NULL,
	CNT int NULL,
	ACTN varchar(10)
)

DECLARE @UsedNamesDesc nvarchar(MAX),
		@BadCulturesDesc nvarchar(MAX)

INSERT INTO @QuickSearchTable 
SELECT 
	N.value('QuickSearchID[1]', 'int') AS QuickSearchID,
	N.value('CNT[1]', 'int') AS CNT,
    N.value('PageName[1]', 'varchar(255)') AS PageName,
    N.value('PromoteToTab[1]', 'bit') AS PromoteToTab,
    N.value('QueryParameters[1]', 'varchar(1000)') AS QueryParameters,
	N.value('DisplayOrder[1]', 'int') AS DisplayOrder
FROM @Data.nodes('//QuickSearch') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @QuickSearchObjectName, @ErrMsg

INSERT INTO @DescTable (
	QuickSearchID,
	CNT,
	Culture,
	LangID,
	Name
)
SELECT
	N.value('QuickSearchID[1]', 'int') AS QuickSearchID,
	N.value('CNT[1]', 'int') AS CNT,
	iq.*

FROM @Data.nodes('//QuickSearch') as T(N) CROSS APPLY 
	( SELECT 
		D.value('Culture[1]', 'varchar(5)') AS Culture,
		(SELECT LangID FROM STP_Language sl WHERE sl.Culture = D.value('Culture[1]', 'varchar(5)') AND ActiveRecord=1) AS LangID,
		D.value('Name[1]', 'nvarchar(100)') AS Name
			FROM N.nodes('DESCS/DESC') AS T2(D) ) iq 
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @QuickSearchObjectName, @ErrMsg

SELECT @UsedNamesDesc = COALESCE(@UsedNamesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM CIC_View_QuickSearch qs INNER JOIN CIC_View_QuickSearch_Name qsn ON qs.QuickSearchID=qsn.QuickSearchID WHERE qsn.Name=nt.Name AND LangID=nt.LangID AND qs.QuickSearchID<>nt.QuickSearchID AND qs.ViewType=@ViewType)

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
-- View given ?
END ELSE IF @ViewType IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
-- View exists ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
-- View belongs to Member ?
END ELSE IF NOT EXISTS (SELECT * FROM CIC_View WHERE MemberID=@MemberID AND ViewType=@ViewType) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Ownership OK ?
END ELSE IF @AgencyCode IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_View WHERE ViewType=@ViewType AND (Owner IS NULL OR Owner = @AgencyCode)) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ViewObjectName, NULL)
-- At least one language used ?
END ELSE IF EXISTS(SELECT * FROM @QuickSearchTable) AND NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @ViewObjectName)
-- Duplicate language data given ?
/*
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY QuickSearchID, LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
*/
-- Name provided ?
END ELSE IF EXISTS(SELECT * FROM @QuickSearchTable) AND NOT EXISTS(SELECT * FROM @DescTable WHERE Name IS NOT NULL) BEGIN
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
	MERGE INTO CIC_View_QuickSearch AS qs
	USING @QuickSearchTable AS nt
	ON qs.QuickSearchID=nt.QuickSearchID AND qs.QuickSearchID <> -1
	WHEN MATCHED --AND qs.DisplayOrder<>nt.DisplayOrder
		THEN UPDATE SET 
			DisplayOrder = nt.DisplayOrder,
			PageName = nt.PageName,
			PromoteToTab = nt.PromoteToTab,
			QueryParameters = nt.QueryParameters
			
	WHEN NOT MATCHED BY TARGET
		THEN INSERT ( ViewType, DisplayOrder, PageName, PromoteToTab, QueryParameters ) 
				VALUES ( @ViewType, nt.DisplayOrder, nt.PageName, nt.PromoteToTab, nt.QueryParameters )
	
	WHEN NOT MATCHED BY SOURCE AND qs.ViewType=@ViewType
		THEN DELETE
		
	OUTPUT INSERTED.QuickSearchID, nt.CNT, $action INTO @NewIDs ;
	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @QuickSearchObjectName, @ErrMsg
	
	DELETE FROM @NewIDs WHERE ACTN <> 'INSERT'
		
	IF @Error=0  BEGIN
		
		MERGE INTO CIC_View_QuickSearch_Name AS qsn
		USING ( 
			SELECT CASE WHEN nqsn.QuickSearchID = -1 THEN nid.QuickSearchID ELSE nqsn.QuickSearchID END AS QuickSearchID,
				nqsn.LangID, nqsn.Name
			FROM @DescTable nqsn
			LEFT JOIN @NewIDs nid
				ON nqsn.CNT=nid.CNT)
			AS nt
			
		ON qsn.QuickSearchID=nt.QuickSearchID AND qsn.LangID=nt.LangID
		WHEN MATCHED AND qsn.Name <> nt.Name AND NULLIF(nt.Name, '') IS NOT NULL
			THEN UPDATE SET Name=nt.Name
			
		WHEN MATCHED AND NULLIF(nt.Name, '') IS NULL 
			THEN DELETE
		
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (QuickSearchID, LangID, Name) 
				VALUES (nt.QuickSearchID, nt.LangID, nt.Name )

		WHEN NOT MATCHED BY SOURCE AND EXISTS(SELECT * FROM CIC_View_QuickSearch WHERE QuickSearchID=qsn.QuickSearchID AND ViewType=@ViewType) THEN
			DELETE
				;

		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @QuickSearchObjectName, @ErrMsg

	END
END

RETURN @Error

SET NOCOUNT OFF




GO


GRANT EXECUTE ON  [dbo].[sp_CIC_View_QuickSearch_u] TO [cioc_login_role]
GO
