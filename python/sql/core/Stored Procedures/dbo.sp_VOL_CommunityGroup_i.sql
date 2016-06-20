SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommunityGroup_i]
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@CommunitySetID [int],
	@BallID [int],
	@ImageURL [varchar](150),
	@Descriptions xml,
	@ErrMsg [varchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@CommunitySetObjectName nvarchar(100),
		@CommunityGroupObjectName nvarchar(100),
		@CommunityGroupNameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @CommunitySetObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community Set')
SET @CommunityGroupObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community Group')
SET @CommunityGroupNameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community group name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	CommunityGroupName nvarchar(100) NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	CommunityGroupName
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('CommunityGroupName[1]', 'nvarchar(100)')
FROM @Descriptions.nodes('//DESC') as T(N)
WHERE N.value('CommunityGroupName[1]', 'nvarchar(100)') IS NOT NULL

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + CommunityGroupName
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM VOL_CommunityGroup vcg INNER JOIN VOL_CommunityGroup_Name vcgn ON vcg.CommunityGroupID=vcgn.CommunityGroupID WHERE CommunityGroupName=nt.CommunityGroupName AND LangID=nt.LangID AND CommunitySetID=@CommunitySetID)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

SET @ImageURL = RTRIM(LTRIM(@ImageURL))
IF @ImageURL = '' SET @ImageURL = NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @CommunitySetObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Community Set ID given ?
END ELSE IF @CommunitySetID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunitySetObjectName, NULL)
-- Community Set ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM VOL_CommunitySet WHERE CommunitySetID=@CommunitySetID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CommunitySetID AS varchar(20)), @CommunitySetObjectName)
-- Community Set belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_CommunitySet WHERE CommunitySetID=@CommunitySetID AND MemberID=@MemberID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, NULL)
END ELSE IF NOT EXISTS(SELECT * FROM @DescTable) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityGroupNameObjectName, @CommunitySetObjectName)
END ELSE IF @BallID IS NOT NULL AND @ImageURL IS NOT NULL BEGIN
	SET @Error = 25
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
END ELSE IF @BallID IS NULL AND @ImageURL IS NULL BEGIN
	SET @Error = 26
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
END ELSE IF @BallID IS NOT NULL AND NOT EXISTS(SELECT * FROM VOL_Ball WHERE BallID=@BallID) BEGIN
	SET @Error = 3
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@BallID AS varchar), cioc_shared.dbo.fn_SHR_STP_ObjectName('Coloured Ball'))
END ELSE IF @BallID IS NOT NULL AND EXISTS(SELECT * FROM VOL_CommunityGroup WHERE CommunitySetID=@CommunitySetID AND BallID=@BallID) BEGIN
	SET @Error = 6
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@BallID AS varchar), cioc_shared.dbo.fn_SHR_STP_ObjectName('Coloured Ball'))
END ELSE IF @ImageURL IS NOT NULL AND EXISTS(SELECT * FROM VOL_CommunityGroup WHERE CommunitySetID=@CommunitySetID AND ImageURL=@ImageURL) BEGIN
	SET @Error = 6
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ImageURL, cioc_shared.dbo.fn_SHR_STP_ObjectName('Image URL'))
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @CommunityGroupNameObjectName)
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
END ELSE BEGIN
	DECLARE @CommunityGroupID int
	INSERT INTO VOL_CommunityGroup (
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		CommunitySetID,
		BallID,
		ImageURL
	)
	VALUES (
		GETDATE(),
		@MODIFIED_BY,
		GETDATE(),
		@MODIFIED_BY,
		@CommunitySetID,
		@BallID,
		@ImageURL
	)
	SET @CommunityGroupID = SCOPE_IDENTITY()
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityGroupObjectName, @ErrMsg OUTPUT
	
	IF @Error = 0 BEGIN
		INSERT INTO VOL_CommunityGroup_Name
		SELECT @CommunityGroupID, LangID, CommunityGroupName
		FROM @DescTable 
		
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityGroupObjectName, @ErrMsg OUTPUT
	END
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunityGroup_i] TO [cioc_login_role]
GO
