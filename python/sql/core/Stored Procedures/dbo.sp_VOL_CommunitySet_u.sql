SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_CommunitySet_u]
	@CommunitySetID [int],
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@Descriptions [xml],
	@ErrMsg [varchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 29-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@MemberObjectName nvarchar(100),
		@CommunitySetObjectName nvarchar(100),
		@CommunitySetNameObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @MemberObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('CIOC Membership')
SET @CommunitySetObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community Set')
SET @CommunitySetNameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Community set name')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	SetName nvarchar(100) NULL,
	AreaServed nvarchar(100) NULL
)

DECLARE @UsedNames nvarchar(max),
		@BadCultures nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	SetName,
	AreaServed
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND Active=1) AS LangID,
	N.value('SetName[1]', 'nvarchar(100)'),
	N.value('AreaServed[1]', 'nvarchar(100)')
FROM @Descriptions.nodes('//DESC') as T(N)

SELECT @UsedNames = COALESCE(@UsedNames + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + SetName
FROM @DescTable nt
WHERE EXISTS(SELECT * FROM VOL_CommunitySet s INNER JOIN VOL_CommunitySet_Name sn ON s.CommunitySetID=sn.CommunitySetID WHERE SetName=nt.SetName AND LangID=nt.LangID AND s.CommunitySetID<>@CommunitySetID)

SELECT @BadCultures = COALESCE(@BadCultures + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

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
-- Area Served provided ?
END ELSE IF EXISTS(SELECT * FROM @DescTable WHERE SetName IS NOT NULL AND AreaServed IS NULL) BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Area served'), @CommunitySetObjectName)
-- Name already in use ?
END ELSE IF @UsedNames IS NOT NULL BEGIN
	SET @Error = 6 -- Value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UsedNames, @CommunitySetNameObjectName)
-- Invalid language ?
END ELSE IF @BadCultures IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCultures, @LanguageObjectName)
END ELSE BEGIN
	UPDATE VOL_CommunitySet
	SET	MODIFIED_DATE	= GETDATE(),
		MODIFIED_BY		= @MODIFIED_BY
	WHERE CommunitySetID = @CommunitySetID
	
	EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunitySetObjectName, @ErrMsg OUTPUT
	
	IF @Error = 0 BEGIN
		MERGE INTO VOL_CommunitySet_Name csn
		USING (SELECT * FROM @DescTable WHERE SetName IS NOT NULL AND AreaServed IS NOT NULL) nt
			ON csn.CommunitySetID=@CommunitySetID AND csn.LangID=nt.LangID
		WHEN MATCHED THEN
			UPDATE SET SetName=nt.SetName, AreaServed=nt.AreaServed
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (CommunitySetID, LangID, SetName, AreaServed)
				VALUES (@CommunitySetID, nt.LangID, nt.SetName, nt.AreaServed)
				
		WHEN NOT MATCHED BY SOURCE AND csn.CommunitySetID=@CommunitySetID THEN
			DELETE
			;
			
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @CommunitySetObjectName, @ErrMsg OUTPUT
			
	END
END

RETURN @Error

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_VOL_CommunitySet_u] TO [cioc_login_role]
GO
