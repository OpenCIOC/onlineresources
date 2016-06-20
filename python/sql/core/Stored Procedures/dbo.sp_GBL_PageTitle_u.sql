SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_PageTitle_u]
	@PageName varchar(255),
	@MODIFIED_BY [varchar](50),
	@Data [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@PageObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @PageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Page')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	TitleOverride nvarchar(max) NULL
)

DECLARE @BadCulturesDesc nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	TitleOverride
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND ActiveRecord=1) AS LangID,
	N.value('TitleOverride[1]', 'nvarchar(max)') AS TitleOverride
FROM @Data.nodes('//DESC') AS T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageObjectName, @ErrMsg

SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

IF @PageName IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, 'PageName', @PageObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM GBL_PageInfo WHERE PageName=@PageName) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@PageName AS varchar), @PageObjectName)
END ELSE IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, @LanguageObjectName)
END

DECLARE @RowsChanged int = 0

IF @Error = 0 BEGIN
	MERGE INTO GBL_PageInfo_Description pgd
	USING @DescTable nt
		ON pgd.PageName = @PageName AND pgd.LangID=nt.LangID
	WHEN MATCHED AND ISNULL(pgd.TitleOverride, 'NULLNULLNULL') <> ISNULL(nt.TitleOverride, 'NULLNULLNULL') THEN
		UPDATE SET TitleOverride=nt.TitleOverride
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (PageName, LangID, TitleOverride) VALUES (@PageName, nt.LangID, nt.TitleOverride)
	WHEN NOT MATCHED BY SOURCE AND pgd.PageName=@PageName AND pgd.TitleOverride IS NOT NULL THEN
		-- Can't delete record, just set value to null
		UPDATE SET TitleOverride=NULL
		; 
	SET @RowsChanged = @@ROWCOUNT

	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PageObjectName, @ErrMsg
END

IF @Error = 0 AND @RowsChanged <> 0 BEGIN
	UPDATE GBL_PageInfo
		SET MODIFIED_BY = @MODIFIED_BY,
			MODIFIED_DATE = GETDATE()
	WHERE PageName = @PageName
END

RETURN @Error

SET NOCOUNT OFF














GO
GRANT EXECUTE ON  [dbo].[sp_GBL_PageTitle_u] TO [cioc_login_role]
GO
