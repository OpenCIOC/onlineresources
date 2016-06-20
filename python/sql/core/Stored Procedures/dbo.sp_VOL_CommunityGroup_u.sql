SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommunityGroup_u]
	@CommunityGroupID [int],
	@MODIFIED_BY [varchar](50),
	@MemberID int,
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


DECLARE	@CommunitySetID	int
SELECT @CommunitySetID=CommunitySetID 
	FROM VOL_CommunityGroup
WHERE CommunityGroupID=@CommunityGroupID


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
WHERE EXISTS(SELECT * FROM VOL_CommunityGroup vcg INNER JOIN VOL_CommunityGroup_Name vcgn ON vcg.CommunityGroupID=vcgn.CommunityGroupID WHERE CommunityGroupName=nt.CommunityGroupName AND LangID=nt.LangID AND CommunitySetID=@CommunitySetID AND vcgn.CommunityGroupID<>@CommunityGroupID)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

SET @ImageURL = RTRIM(LTRIM(@ImageURL))
IF @ImageURL = '' SET @ImageURL = NULL

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @MemberObjectName, @CommunityGroupObjectName)
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@MemberID AS varchar), @MemberObjectName)
-- Community Group ID given ?
END ELSE IF @CommunityGroupID IS NULL BEGIN
	SET @Error = 2 -- No ID Given
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @CommunityGroupObjectName, NULL)
-- Community Group ID exists ?
END ELSE IF NOT EXISTS (SELECT * FROM VOL_CommunityGroup WHERE CommunityGroupID=@CommunityGroupID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@CommunityGroupID AS varchar(20)), @CommunityGroupObjectName)
-- Community Group belongs to Member ?
END ELSE IF NOT EXISTS(SELECT * FROM VOL_CommunitySet vcs INNER JOIN VOL_CommunityGroup vcg ON vcs.CommunitySetID=vcg.CommunitySetID WHERE CommunityGroupID=@CommunityGroupID AND MemberID=@MemberID) BEGIN
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
END ELSE IF @BallID IS NOT NULL AND EXISTS(SELECT * FROM VOL_CommunityGroup WHERE CommunitySetID=@CommunitySetID AND BallID=@BallID AND CommunityGroupID<>@CommunityGroupID) BEGIN
	SET @Error = 6
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@BallID AS varchar), cioc_shared.dbo.fn_SHR_STP_ObjectName('Coloured Ball'))
END ELSE IF @ImageURL IS NOT NULL AND EXISTS(SELECT * FROM VOL_CommunityGroup WHERE CommunitySetID=@CommunitySetID AND ImageURL=@ImageURL AND CommunityGroupID<>@CommunityGroupID) BEGIN
	SET @Error = 6
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ImageURL, cioc_shared.dbo.fn_SHR_STP_ObjectName('Image URL'))
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @CommunityGroupNameObjectName)
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
END ELSE BEGIN
	UPDATE VOL_CommunityGroup
	SET	MODIFIED_DATE		= GETDATE(),
		MODIFIED_BY			= @MODIFIED_BY,
		BallID				= @BallID,
		ImageURL			= @ImageURL
	WHERE CommunityGroupID	= @CommunityGroupID
	
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunityGroupObjectName, @ErrMsg OUTPUT
	
	IF @Error = 0 BEGIN
		MERGE INTO VOL_CommunityGroup_Name vcgn
		USING @DescTable nt
			ON vcgn.CommunityGroupID=@CommunityGroupID AND vcgn.LangID=nt.LangID
		WHEN MATCHED THEN
			UPDATE SET CommunityGroupName=nt.CommunityGroupName
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (CommunityGroupID, LangID, CommunityGroupName)
				VALUES (@CommunityGroupID, nt.LangID, nt.CommunityGroupName)
				
		WHEN NOT MATCHED BY SOURCE AND vcgn.CommunityGroupID=@CommunityGroupID THEN
			DELETE
			;
			
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunitySetObjectName, @ErrMsg OUTPUT
		
	END
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunityGroup_u] TO [cioc_login_role]
GO
