SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_View_TopicSearch_u]
	@TopicSearchID int OUTPUT,
	@MODIFIED_BY varchar(50),
	@MemberID int,
	@AgencyCode char(3),
	@TopicSearchTag varchar(20),
	@ViewType int,
	@DisplayOrder tinyint,
	@PB_ID1 int,
	@Heading1Step tinyint,
	@Heading1ListType tinyint,
	@PB_ID2 int,
	@Heading2Step tinyint,
	@Heading2ListType tinyint,
	@Heading2Required bit,
	@CommunityStep tinyint,
	@CommunityRequired bit,
	@CommunityListType bit,
	@AgeGroupStep tinyint,
	@AgeGroupRequired bit,
	@LanguageStep tinyint,
	@LanguageRequired bit,
	@Descriptions xml,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 15-Sep-2013
	Action:	NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@ViewObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@TopicSearchObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @TopicSearchObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Topic Search')

DECLARE @DescTable table (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	SearchTitle nvarchar(100) NULL,
	SearchDescription nvarchar(1000) NULL,
	Heading1Title nvarchar(255) NULL,
	Heading2Title nvarchar(255) NULL,
	Heading1Help nvarchar(4000) NULL,
	Heading2Help nvarchar(4000) NULL,
	CommunityHelp nvarchar(4000) NULL,
	AgeGroupHelp nvarchar(4000) NULL,
	LanguageHelp nvarchar(4000) NULL
)

DECLARE @BadCulturesDesc nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	SearchTitle,
	SearchDescription,
	Heading1Title,
	Heading2Title,
	Heading1Help,
	Heading2Help,
	CommunityHelp,
	AgeGroupHelp,
	LanguageHelp
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('SearchTitle[1]', 'nvarchar(100)') AS SearchTitle,
	N.value('SearchDescription[1]', 'nvarchar(1000)') AS SearchDescription,
	N.value('Heading1Title[1]', 'nvarchar(255)') AS Heading1Title,
	N.value('Heading2Title[1]', 'nvarchar(255)') AS Heading2Title,
	N.value('Heading1Help[1]', 'nvarchar(4000)') AS Heading1Help,
	N.value('Heading2Help[1]', 'nvarchar(4000)') AS Heading2Help,
	N.value('CommunityHelp[1]', 'nvarchar(4000)') AS CommunityHelp,
	N.value('AgeGroupHelp[1]', 'nvarchar(4000)') AS AgeGroupHelp,
	N.value('LanguageHelp[1]', 'nvarchar(4000)') AS LanguageHelp
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL
	OR NOT EXISTS(SELECT * FROM CIC_View_Description WHERE ViewType=@ViewType AND LangID=nt.LangID)

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
-- Topic Search exists and part of View?
END ELSE IF @TopicSearchID IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_View_TopicSearch vts WHERE vts.TopicSearchID=@TopicSearchID AND ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@TopicSearchID AS varchar), @TopicSearchObjectName)
-- Heading 1 Publication given ?

-- Heading 1 Publication exists ?

-- Heading 2 Publication exists ? 

-- At least one language used ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, @ViewObjectName)
-- Duplicate language data given ?
END ELSE IF (SELECT TOP 1 COUNT(*) FROM @DescTable GROUP BY LangID ORDER BY COUNT(*) DESC) > 1 BEGIN
	SET @Error = 1 -- Unknown Error
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @LanguageObjectName, NULL)
-- Title provided ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE SearchTitle IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Title'), @TopicSearchObjectName)
-- Description provided ?
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable WHERE SearchDescription IS NOT NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Description'), @TopicSearchObjectName)
-- Invalid language ?
END ELSE IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, @LanguageObjectName)
END ELSE BEGIN
	DECLARE @MaxStep tinyint
	SET @MaxStep = 5

	IF @Heading2Step IS NULL BEGIN
		SET @PB_ID2 = NULL
		SET @Heading2Required = 0
	END
	IF @CommunityStep IS NULL SET @CommunityRequired = 0
	IF @AgeGroupStep IS NULL SET @AgeGroupRequired = 0
	IF @LanguageStep IS NULL SET @LanguageRequired = 0
	
	IF @Heading1Step > @MaxStep SET @Heading1Step = @MaxStep
	IF @Heading2Step > @MaxStep SET @Heading2Step = @MaxStep
	IF @CommunityStep > @MaxStep SET @CommunityStep = @MaxStep
	IF @AgeGroupStep > @MaxStep SET @AgeGroupStep = @MaxStep
	IF @LanguageStep > @MaxStep	SET @LanguageStep = @MaxStep

	IF @TopicSearchID IS NULL BEGIN
		INSERT INTO CIC_View_TopicSearch (
			TopicSearchTag,
			ViewType,
			DisplayOrder,
			PB_ID1,
			Heading1Step,
			Heading1ListType,
			PB_ID2,
			Heading2Step,
			Heading2ListType,
			Heading2Required,
			CommunityStep,
			CommunityRequired,
			CommunityListType,
			AgeGroupStep,
			AgeGroupRequired,
			LanguageStep,
			LanguageRequired
		)
		VALUES (
			@TopicSearchTag,
			@ViewType,
			ISNULL(@DisplayOrder,0),
			@PB_ID1,
			ISNULL(@Heading1Step,1),
			ISNULL(@Heading1ListType,0),
			@PB_ID2,
			@Heading2Step,
			ISNULL(@Heading2ListType,0),
			ISNULL(@Heading2Required,0),
			@CommunityStep,
			ISNULL(@CommunityRequired,0),
			ISNULL(@CommunityListType,0),
			@AgeGroupStep,
			ISNULL(@AgeGroupRequired,0),
			@LanguageStep,
			ISNULL(@LanguageRequired,0)
		)
		
		SET @TopicSearchID = SCOPE_IDENTITY()
		
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @TopicSearchObjectName, @ErrMsg
	END ELSE BEGIN
		UPDATE CIC_View_TopicSearch
			SET TopicSearchTag		= @TopicSearchTag,
				DisplayOrder		= ISNULL(@DisplayOrder,DisplayOrder),
				PB_ID1				= @PB_ID1,
				Heading1Step		= ISNULL(@Heading1Step,1),
				Heading1ListType	= ISNULL(@Heading1ListType,0),
				PB_ID2				= @PB_ID2,
				Heading2Step		= @Heading2Step,
				Heading2ListType	= ISNULL(@Heading2ListType,0),
				Heading2Required	= @Heading2Required,
				CommunityStep		= @CommunityStep,
				CommunityRequired	= ISNULL(@CommunityRequired,0),
				CommunityListType	= @CommunityListType,
				AgeGroupStep		= @AgeGroupStep,
				AgeGroupRequired	= ISNULL(@AgeGroupRequired,0),
				LanguageStep		= @LanguageStep,
				LanguageRequired	= ISNULL(@LanguageRequired,0)
		WHERE TopicSearchID = @TopicSearchID
		
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @TopicSearchObjectName, @ErrMsg
	END
	
	IF @TopicSearchID IS NOT NULL BEGIN
		MERGE INTO CIC_View_TopicSearch_Description vtsd
		USING (SELECT * FROM @DescTable) nt
			ON vtsd.TopicSearchID=@TopicSearchID AND vtsd.LangID=nt.LangID
		WHEN MATCHED THEN
			UPDATE SET
				SearchTitle			= nt.SearchTitle,
				SearchDescription	= nt.SearchDescription,
				Heading1Title		= nt.Heading1Title,
				Heading2Title		= nt.Heading2Title,
				Heading1Help		= nt.Heading1Help,
				Heading2Help		= nt.Heading2Help,
				CommunityHelp		= nt.CommunityHelp,
				AgeGroupHelp		= nt.AgeGroupHelp,
				LanguageHelp		= nt.LanguageHelp
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (TopicSearchID, LangID, SearchTitle, SearchDescription, Heading1Title, Heading2Title,
					Heading1Help, Heading2Help, CommunityHelp, AgeGroupHelp, LanguageHelp)
			VALUES (@TopicSearchID, nt.LangID, nt.SearchTitle, nt.SearchDescription, nt.Heading1Title, nt.Heading2Title,
					nt.Heading1Help, nt.Heading2Help, nt.CommunityHelp, nt.AgeGroupHelp, nt.LanguageHelp)
		WHEN NOT MATCHED BY SOURCE AND vtsd.TopicSearchID=@TopicSearchID THEN
			DELETE ;
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @TopicSearchObjectName, @ErrMsg
	END

	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @TopicSearchObjectName, @ErrMsg
	IF @Error = 0 BEGIN
		UPDATE CIC_View
			SET MODIFIED_DATE	= GETDATE(),
				MODIFIED_BY		= @MODIFIED_BY
		WHERE ViewType=@ViewType
	END
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_TopicSearch_u] TO [cioc_login_role]
GO
