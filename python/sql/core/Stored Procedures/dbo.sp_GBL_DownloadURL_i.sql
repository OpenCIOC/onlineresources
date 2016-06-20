SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_DownloadURL_i]
	@MODIFIED_BY varchar(50),
	@MemberID [int],
	@Domain tinyint,
	@ResourceURL varchar(150),
	@ResourceNames xml,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 13-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@DownloadResourceObjectName nvarchar(100),
		@URLObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @DownloadResourceObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Download Resource')
SET @URLObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('URL')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @NamesTable TABLE (
	Name nvarchar(50) NOT NULL,
	LangID smallint NOT NULL
)

INSERT INTO @NamesTable (
	Name,
	LangID
)
SELECT
	N.value('@V', 'nvarchar(50)') AS Name,
	N.value('@LANG', 'smallint') AS LangID
FROM @ResourceNames.nodes('//NM') as T(N)

DECLARE @UsedNames nvarchar(max),
		@BadLangIDs nvarchar(max),
		@URL_ID int
		
SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + Name
FROM @NamesTable nt
WHERE EXISTS(SELECT * FROM GBL_DownloadURL url INNER JOIN GBL_DownloadURL_Name urln ON url.URL_ID=urln.URL_ID WHERE MemberID=@MemberID AND Domain=@Domain AND Name=nt.Name AND LangID=nt.LangID)

SELECT @BadLangIDs = COALESCE(@BadLangIDs + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + CAST(LangID AS varchar)
FROM @NamesTable nt
WHERE NOT EXISTS(SELECT * FROM STP_Language WHERE LangID=nt.LangID AND Active=1)

SET @ResourceURL = RTRIM(LTRIM(@ResourceURL))
IF @ResourceURL = '' SET @ResourceURL = NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @DownloadResourceObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- URL given ?
END ELSE IF @ResourceURL IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @URLObjectName, @DownloadResourceObjectName)
-- URL exists ?
END ELSE IF EXISTS(SELECT * FROM GBL_DownloadURL WHERE MemberID=@MemberID AND Domain=@Domain AND ResourceURL=@ResourceURL) BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ResourceURL, @URLObjectName)
-- Name in use ?
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, cioc_shared.dbo.fn_SHR_STP_ObjectName('Name'))
-- Invalid languages ?
END ELSE IF @BadLangIDs IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadLangIDs, @LanguageObjectName)
-- Duplicate language data given ?
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @NamesTable GROUP BY LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
END ELSE BEGIN
	INSERT INTO GBL_DownloadURL (
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		MemberID,
		Domain,
		ResourceURL
	)
	VALUES (
		GETDATE(),
		@MODIFIED_BY,
		GETDATE(),
		@MODIFIED_BY,
		@MemberID,
		@Domain,
		@ResourceURL
	)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DownloadResourceObjectName, @ErrMsg
	SET @URL_ID = SCOPE_IDENTITY()
	
	IF @Error = 0 AND @URL_ID IS NOT NULL BEGIN
		INSERT INTO GBL_DownloadURL_Name (
			URL_ID,
			LangID,
			MemberID_Cache,
			Name
		) SELECT
			@URL_ID,
			LangID,
			@MemberID,
			Name
		FROM @NamesTable
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DownloadResourceObjectName, @ErrMsg
	END
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_DownloadURL_i] TO [cioc_login_role]
GO
