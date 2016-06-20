SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_NUMPub_u]
	@BT_PB_ID [int] OUTPUT,
	@MODIFIED_BY [varchar](50),
	@DeleteFeedback bit,
	@Descriptions [xml],
	@Headings [xml],
	@User_ID int,
	@ViewType int,
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 16-Sep-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@OrganizationProgramObjectName nvarchar(100),
		@PublicationObjectName nvarchar(100),
		@DescriptionObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100),
		@ViewObjectName nvarchar(100)

SET @OrganizationProgramObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Organization / Program Record')
SET @PublicationObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Publication')
SET @DescriptionObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Description')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')
SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')

DECLARE @MemberID int

SELECT @MemberID=MemberID
	FROM CIC_View
WHERE ViewType=@ViewType

DECLARE @NUM varchar(8), 
		@PB_ID int
		
SELECT @NUM = pr.NUM, @PB_ID=pr.PB_ID 
	FROM CIC_BT_PB pr
WHERE BT_PB_ID=@BT_PB_ID

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	Description nvarchar(max) NULL
)

DECLARE @HeadingTable TABLE (
	GH_ID int
)

DECLARE @BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	Description
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND ActiveRecord=1) AS LangID,
	N.value('Description[1]', 'nvarchar(max)') AS Description
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

INSERT INTO @HeadingTable(
	GH_ID
)
SELECT
	N.value('.', 'int') AS GHID
FROM @Headings.nodes('//GHID') as T(N)
INNER JOIN CIC_GeneralHeading gh
	ON N.value('.', 'int')=gh.GH_ID AND gh.Used=1

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

-- ID given ?
IF @BT_PB_ID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @PublicationObjectName, NULL)
-- ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM CIC_BT_PB WHERE BT_PB_ID=@BT_PB_ID) BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @NUM, @PublicationObjectName)
-- View given ?
END ELSE IF @MemberID IS NULL BEGIN
	SET @BT_PB_ID = NULL
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
-- Record in View ?
END ELSE IF NOT dbo.fn_CIC_RecordInView(@NUM,@ViewType,@@LANGID,0,GETDATE())=1 BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationProgramObjectName, NULL)
-- User can modify this publication ?
END ELSE IF NOT dbo.fn_CIC_CanUpdatePub(@NUM,@PB_ID,@User_ID,@ViewType,@@LANGID,GETDATE())=1 BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @OrganizationProgramObjectName, NULL)
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
END

IF @Error = 0 BEGIN
	UPDATE CIC_BT_PB
	SET	MODIFIED_DATE	= GETDATE(),
		MODIFIED_BY		= @MODIFIED_BY
	WHERE BT_PB_ID = @BT_PB_ID	
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg

	IF @Error=0 BEGIN
		DELETE btpbn
		FROM CIC_BT_PB_Description btpbn
		WHERE btpbn.BT_PB_ID=@BT_PB_ID
			AND NOT EXISTS(SELECT * FROM @DescTable nt WHERE btpbn.LangID=nt.LangID AND Description IS NOT NULL)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg
		
		UPDATE btpbn SET
			Description		= nt.Description
		FROM CIC_BT_PB_Description btpbn
		INNER JOIN @DescTable nt
			ON btpbn.LangID=nt.LangID
		WHERE btpbn.BT_PB_ID=@BT_PB_ID
	
		INSERT INTO CIC_BT_PB_Description (
			BT_PB_ID,
			LangID,
			Description
		) SELECT
			@BT_PB_ID,
			LangID,
			Description
		FROM @DescTable nt
		WHERE Description IS NOT NULL AND NOT EXISTS(SELECT * FROM CIC_BT_PB_Description WHERE BT_PB_ID=@BT_PB_ID AND LangID=nt.LangID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @PublicationObjectName, @ErrMsg
		
		MERGE INTO CIC_BT_PB_GH AS btpbgh
		USING @HeadingTable AS nt
			ON btpbgh.BT_PB_ID=@BT_PB_ID AND nt.GH_ID=btpbgh.GH_ID
		WHEN NOT MATCHED BY TARGET
			THEN INSERT (BT_PB_ID, GH_ID, NUM_Cache) VALUES (@BT_PB_ID, nt.GH_ID, @NUM)
		WHEN NOT MATCHED BY SOURCE AND btpbgh.BT_PB_ID=@BT_PB_ID
				AND EXISTS(SELECT * FROM CIC_GeneralHeading gh WHERE gh.GH_ID=btpbgh.GH_ID AND gh.Used IS NOT NULL)
			THEN DELETE ;
	END
	
	IF @Error = 0 AND @DeleteFeedback=1 BEGIN
		EXEC dbo.sp_CIC_Feedback_Pub_BTPBID_d @BT_PB_ID, @User_ID, @ViewType
	END
END

RETURN @Error

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMPub_u] TO [cioc_login_role]
GO
