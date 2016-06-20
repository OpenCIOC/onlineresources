SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_PrintProfile_u]
	@ProfileID [int],
	@MODIFIED_BY [varchar](50),
	@MemberID [int],
	@StyleSheet [varchar](150),
	@TableClass [varchar](50),
	@PageBreak [bit],
	@Separator [varchar](255),
	@MsgBeforeRecord [bit],
	@InViews [varchar](max),
	@Descriptions [xml],
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

DECLARE @MemberObjectName nvarchar(100),
		@ProfileObjectName nvarchar(100),
		@NameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@ViewObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ProfileObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Profile')
SET @NameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	ProfileName nvarchar(50) NULL,
	PageTitle nvarchar(100) NULL,
	Header nvarchar(max) NULL,
	Footer nvarchar(max) NULL,
	DefaultMsg nvarchar(max) NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	ProfileName,
	PageTitle,
	Header,
	Footer,
	DefaultMsg
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('ProfileName[1]', 'nvarchar(50)') AS ProfileName,
	N.value('PageTitle[1]', 'nvarchar(100)') AS PageTitle,
	N.value('Header[1]', 'nvarchar(max)') AS Header,
	N.value('Footer[1]', 'nvarchar(max)') AS Footer,
	N.value('DefaultMsg[1]', 'nvarchar(max)') AS DefaultMsg
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ProfileName
FROM @DescTable nt
WHERE EXISTS(
	SELECT *
	FROM GBL_PrintProfile pp
	INNER JOIN GBL_PrintProfile_Description ppd
		ON pp.ProfileID=ppd.ProfileID
	WHERE pp.MemberID=@MemberID
		AND ppd.ProfileName=nt.ProfileName
		AND ppd.LangID=nt.LangID
		AND pp.ProfileID<>@ProfileID AND pp.Domain=1
	)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

SET @StyleSheet = RTRIM(LTRIM(@StyleSheet))
IF @StyleSheet = '' SET @StyleSheet = NULL
SET @TableClass = RTRIM(LTRIM(@TableClass))
IF @TableClass = '' SET @TableClass = NULL
SET @Separator = RTRIM(LTRIM(@Separator))
IF @Separator = '' SET @Separator = NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Profile ID given ?
END ELSE IF @ProfileID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ProfileObjectName, NULL)
-- Profile ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM GBL_PrintProfile WHERE ProfileID=@ProfileID AND Domain=1) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ProfileID AS varchar(20)), @ProfileObjectName)
-- Profile belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM GBL_PrintProfile WHERE ProfileID=@ProfileID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
-- At least one language used ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @ProfileObjectName)
-- Duplicate language data given ?
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
-- Name provided ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE ProfileName IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NameObjectName, @ProfileObjectName)
-- Name in use ?
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value In Use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @NameObjectName)
-- Invalid language ?
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
END

IF @Error = 0 BEGIN
	UPDATE GBL_PrintProfile 
	SET	MODIFIED_DATE	= GETDATE(),
		MODIFIED_BY		= @MODIFIED_BY,
		StyleSheet		= @StyleSheet,
		TableClass		= @TableClass,
		PageBreak		= @PageBreak,
		Separator		= @Separator,
		MsgBeforeRecord	= @MsgBeforeRecord
	WHERE ProfileID = @ProfileID
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
	
	IF @Error = 0 BEGIN
		MERGE INTO GBL_PrintProfile_Description ppd
		USING @DescTable nt
			ON @ProfileID=ppd.ProfileID AND ppd.LangID=nt.LangID
		WHEN MATCHED THEN
			UPDATE SET 
				ProfileName = nt.ProfileName,
				PageTitle = nt.PageTitle,
				Header = nt.Header,
				Footer = nt.Footer,
				DefaultMsg = nt.DefaultMsg
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (MemberID_Cache, ProfileID, LangID, ProfileName, PageTitle, Header, Footer, DefaultMsg)
				VALUES (@MemberID, @ProfileID, nt.LangID, nt.ProfileName, nt.PageTitle, nt.Header, nt.Footer, nt.DefaultMsg)
		WHEN NOT MATCHED BY SOURCE AND ppd.ProfileID=@ProfileID THEN
			DELETE
			;
			
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
	END
	
	IF @Error = 0 BEGIN
		
		MERGE INTO CIC_View_PrintProfile ppv
		USING (SELECT ViewType
				FROM CIC_View vw
				INNER JOIN fn_GBL_ParseIntIDList(@InViews, ',') nt
					ON ViewType=nt.ItemID) nt
			ON ppv.ProfileID=@ProfileID AND ppv.ViewType = nt.ViewType
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ProfileID, ViewType) VALUES (@ProfileID, nt.ViewType)
		WHEN NOT MATCHED BY SOURCE AND ppv.ProfileID=@ProfileID THEN
			DELETE
			;
			
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ProfileObjectName, @ErrMsg
	
	END
END

RETURN @Error

SET NOCOUNT OFF









GO
GRANT EXECUTE ON  [dbo].[sp_CIC_PrintProfile_u] TO [cioc_login_role]
GO
