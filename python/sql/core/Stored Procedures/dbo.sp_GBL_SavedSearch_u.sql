SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_SavedSearch_u]
	@SSRCH_ID int OUTPUT,
	@User_ID int,
	@SearchName varchar(255),
	@WhereClause nvarchar(max),
	@Notes nvarchar(2000),
	@IncludeDeleted bit,
	@Domain tinyint,
	@SharedWithSLs varchar(max),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 25-Sep-2013
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int 	
SET @Error = 0

DECLARE	@SavedSearchObjectName nvarchar(100),
		@SearchNameObjectName nvarchar(100),
		@UserObjectName nvarchar(100)

SET @SavedSearchObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Saved Search')
SET @SearchNameObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Name')
SET @UserObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('User')

DECLARE @MemberID int,
		@SavedSearchQuota tinyint
		
SELECT	@MemberID=MemberID_Cache,
		@SavedSearchQuota=SavedSearchQuota
	FROM GBL_Users
WHERE [User_ID]=@User_ID

SET @SearchName = RTRIM(LTRIM(@SearchName))
IF @SearchName = '' SET @SearchName = NULL

SET @Notes = RTRIM(LTRIM(@Notes))
IF @Notes = '' SET @Notes = NULL

IF @Domain <> 1 AND @Domain <> 2 BEGIN
	SET @Error = 23 -- No Module
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
END ELSE IF @SSRCH_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_SavedSearch WHERE SSRCH_ID=@SSRCH_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@SSRCH_ID AS varchar), @SavedSearchObjectName)
END ELSE IF @SSRCH_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_SavedSearch WHERE SSRCH_ID=@SSRCH_ID AND User_ID=@User_ID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @UserObjectName, NULL)
END ELSE IF @SearchName IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SearchNameObjectName, @SavedSearchObjectName)
END ELSE IF @WhereClause IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('WHERE clause'), @SavedSearchObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM GBL_Users WHERE [User_ID]=@User_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@User_ID AS varchar), @UserObjectName)
END ELSE IF EXISTS(SELECT *
		FROM GBL_SavedSearch
		WHERE [User_ID] = @User_ID
			AND SearchName=@SearchName
			AND Domain = @Domain
			AND LangID=@@LANGID
			AND (@SSRCH_ID IS NULL OR SSRCH_ID<>@SSRCH_ID)
		) BEGIN
	SET @Error = 6 -- Value in use
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SearchName, @SearchNameObjectName)
END ELSE IF (SELECT COUNT(*) FROM GBL_SavedSearch WHERE LangID=@@LANGID AND [User_ID]=@User_ID AND Domain=@Domain) >= @SavedSearchQuota BEGIN
	SET @Error = 17 -- Over saved search quota
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@SavedSearchQuota AS varchar), NULL)
-- Saved Search ID Exists ?
END ELSE IF @SSRCH_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_SavedSearch WHERE SSRCH_ID=@SSRCH_ID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@SSRCH_ID AS varchar), @SavedSearchObjectName)
END ELSE IF @SSRCH_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_SavedSearch WHERE SSRCH_ID=@SSRCH_ID AND User_ID=@User_ID) BEGIN
	SET @Error = 8 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @SavedSearchObjectName, NULL)
END ELSE BEGIN
	IF @SSRCH_ID IS NULL BEGIN
		INSERT INTO GBL_SavedSearch (
			CREATED_DATE,
			MODIFIED_DATE,
			[User_ID],
			SearchName,
			WhereClause,
			Notes,
			IncludeDeleted,
			Domain,
			LangID
		) 
		VALUES (
			GETDATE(),
			GETDATE(),
			@User_ID,
			@SearchName,
			@WhereClause,
			@Notes,
			@IncludeDeleted,
			@Domain,
			@@LANGID
		)
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SavedSearchObjectName, @ErrMsg
		SET @SSRCH_ID = SCOPE_IDENTITY()
	END ELSE BEGIN
		UPDATE GBL_SavedSearch  SET
			MODIFIED_DATE	= GETDATE(),
			SearchName		= @SearchName,
			WhereClause		= @WhereClause,
			Notes			= @Notes,
			IncludeDeleted	= @IncludeDeleted
		WHERE SSRCH_ID = @SSRCH_ID
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @SavedSearchObjectName, @ErrMsg
	END
	
	IF @Error =0 BEGIN
		DECLARE @SLIDs TABLE ( SL_ID int )
		
		INSERT INTO @SLIDs (SL_ID)
		SELECT tm.ItemID
			FROM fn_GBL_ParseIntIDList(@SharedWithSLs, ',') tm
		WHERE (@Domain=1 AND EXISTS(SELECT * FROM CIC_SecurityLevel sl WHERE sl.MemberID=@MemberID AND sl.SL_ID=tm.ItemID))
			OR (@Domain=2 AND EXISTS(SELECT * FROM VOL_SecurityLevel sl WHERE sl.MemberID=@MemberID AND sl.SL_ID=tm.ItemID))
	
		IF @Domain=1 BEGIN
			DELETE FROM CIC_SecurityLevel_SavedSearch
				WHERE (
					SSRCH_ID = @SSRCH_ID AND
					NOT EXISTS(SELECT * FROM @SLIDs tm
						WHERE tm.SL_ID = CIC_SecurityLevel_SavedSearch.SL_ID)
				)
			INSERT INTO CIC_SecurityLevel_SavedSearch (SSRCH_ID, SL_ID)
				SELECT @SSRCH_ID AS SSRCH_ID, tm.SL_ID AS SL_ID
				FROM @SLIDs tm
				WHERE NOT EXISTS(SELECT *
						FROM CIC_SecurityLevel_SavedSearch
						WHERE SSRCH_ID=@SSRCH_ID AND SL_ID=tm.SL_ID
					)
		END ELSE IF @Domain=2 BEGIN
			DELETE FROM VOL_SecurityLevel_SavedSearch
				WHERE (
					SSRCH_ID = @SSRCH_ID AND
					NOT EXISTS(SELECT * FROM @SLIDs tm
						WHERE tm.SL_ID = VOL_SecurityLevel_SavedSearch.SL_ID)
				)
			INSERT INTO VOL_SecurityLevel_SavedSearch (SSRCH_ID, SL_ID)
				SELECT @SSRCH_ID AS SSRCH_ID, tm.SL_ID AS SL_ID

				FROM @SLIDs tm
				WHERE (
					NOT EXISTS(SELECT * FROM VOL_SecurityLevel_SavedSearch
						WHERE SSRCH_ID = @SSRCH_ID AND SL_ID = tm.SL_ID)
				)
		END
	END
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_SavedSearch_u] TO [cioc_login_role]
GO
