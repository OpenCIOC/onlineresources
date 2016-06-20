SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_STP_Member_Check] (
	@MODIFIED_BY varchar(50),
	@UseCIC bit,
	@UseVOL bit,
	@MemberID int OUTPUT,
	@ErrMsg nvarchar(500) OUTPUT
) AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-May-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int
SET @Error = 0

DECLARE @DefaultTemplate int,
		@DefaultViewCIC	int,
		@DefaultViewVOL	int,
		@Now smalldatetime,
		@DbCode varchar(15),
		@MemberName nvarchar(255)
		
SET @Now = GETDATE()
SET @DbCode = 'CIOCDB_' + CAST(MONTH(@Now) AS varchar) + CAST(YEAR(@Now) AS varchar)
SET @MemberName = 'New Member [' + CAST(@Now AS varchar) + ']'

SET @UseCIC = ISNULL(@UseCIC,0)
SET @UseVOL = ISNULL(@UseVOL,0)
	
IF @UseCIC=0 AND @UseVOL=0 BEGIN
	SET @UseCIC=1
END
		
EXEC sp_STP_Language_Check
EXEC @Error = sp_GBL_Template_Default_Check @DefaultTemplate, @ErrMsg

IF NOT EXISTS(SELECT * FROM STP_Member) OR NOT EXISTS(SELECT * FROM STP_Member_Description) BEGIN
	/* we have no member. make one */
	EXEC sp_STP_Member_i @MODIFIED_BY, @DbCode, @MemberName, NULL, NULL, @UseCIC, @UseVOL, @MemberID OUTPUT, @ErrMsg OUTPUT
END

INSERT INTO STP_Member_Description (
	LangID
)
SELECT LangID
	FROM STP_Language sln
WHERE Active=1
	AND NOT EXISTS(SELECT * FROM STP_Member_Description dod WHERE dod.LangID=sln.LangID)

DELETE dod
	FROM STP_Member_Description dod
	WHERE EXISTS(SELECT * FROM STP_Language sln WHERE sln.LangID=dod.LangID AND sln.Active=0)

SELECT @UseCIC=UseCIC, @DefaultViewCIC=DefaultViewCIC,
	@UseVOL=UseVOL, @DefaultViewVOL=DefaultViewVOL
FROM STP_Member

IF @UseCIC=1 AND @DefaultViewCIC IS NULL BEGIN
	IF NOT EXISTS(SELECT * FROM CIC_View) BEGIN
		/* we have no CIC views */
		EXEC sp_CIC_View_i @MODIFIED_BY, @MemberID, 'Default', @DefaultViewCIC OUTPUT, @ErrMsg OUTPUT
	END ELSE BEGIN
		SELECT @DefaultViewCIC=ViewType
		FROM CIC_View
	END
	UPDATE STP_Member
	SET	MODIFIED_DATE	= GETDATE(),
		MODIFIED_BY		= @MODIFIED_BY,
		DefaultViewCIC	= @DefaultViewCIC
END

IF @UseVOL=1 AND @DefaultViewVOL IS NULL BEGIN
	IF NOT EXISTS(SELECT * FROM VOL_View) BEGIN
		/* we have no VOL views */
		EXEC sp_VOL_View_i @MODIFIED_BY, @MemberID, 'Default', @DefaultViewVOL OUTPUT, @ErrMsg OUTPUT
	END ELSE BEGIN
		SELECT @DefaultViewVOL=ViewType
		FROM VOL_View
	END
	UPDATE STP_Member
	SET MODIFIED_DATE	= GETDATE(),
		MODIFIED_BY		= @MODIFIED_BY,
		DefaultViewVOL	= @DefaultViewVOL
END



GO
GRANT EXECUTE ON  [dbo].[sp_STP_Member_Check] TO [cioc_login_role]
GO
