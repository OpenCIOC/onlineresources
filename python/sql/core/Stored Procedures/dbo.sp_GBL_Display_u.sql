SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_Display_u]
	@User_ID int,
	@ViewType int,
	@Domain tinyint,
	@ShowID bit,
	@ShowOwner bit,
	@ShowAlert bit,
	@ShowOrg bit,
	@ShowCommunity bit,
	@ShowUpdateSchedule bit,
	@LinkUpdate bit,
	@LinkEmail bit,
	@LinkSelect bit,
	@LinkWeb bit,
	@LinkListAdd bit,
	@OrderBy int,
	@OrderByCustom int,
	@OrderByDesc BIT,
    @TableSort BIT,
	@GLinkMail bit,
	@GLinkPub bit,
	@ShowTable bit,
	@VShowPosition bit,
	@VShowDuties bit,
	@FieldList varchar(max),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 16-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error int
SET @Error = 0

DECLARE	@ViewObjectName nvarchar(60),
		@DisplayOptionsObjectName nvarchar(60)

SET @ViewObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('View')
SET @DisplayOptionsObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Display Options')

DECLARE @DD_ID int

IF @Domain <> 1 AND @Domain <> 2 BEGIN
	SET @Error = 23 -- No Module
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, NULL, NULL)
END ELSE IF @User_ID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_Users WHERE [User_ID]=@User_ID) BEGIN
	SET @Error = 6 -- Security Failure
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('User'), NULL)
END ELSE IF @Domain = 1 AND @User_ID IS NULL AND NOT EXISTS(SELECT * FROM CIC_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
END ELSE IF @Domain = 2 AND @User_ID IS NULL AND NOT EXISTS(SELECT * FROM VOL_View WHERE ViewType=@ViewType) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ViewType AS varchar), @ViewObjectName)
END ELSE BEGIN
	IF @User_ID IS NOT NULL BEGIN
		SET @ViewType = NULL
		SELECT @DD_ID = DD_ID
			FROM GBL_Display
		WHERE [User_ID]=@User_ID AND [Domain]=@Domain

		IF @DD_ID IS NULL BEGIN
			INSERT INTO GBL_Display (
				[Domain],
				[User_ID]
			) VALUES (
				@Domain,
				@User_ID
			)
			SET @DD_ID=SCOPE_IDENTITY()
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DisplayOptionsObjectName, @ErrMsg
		END
	END ELSE BEGIN
		SELECT @DD_ID = DD_ID
			FROM GBL_Display
		WHERE @ViewType = CASE WHEN @Domain=1 THEN ViewTypeCIC ELSE ViewTypeVOL END

		IF @DD_ID IS NULL BEGIN
			IF @Domain = 1 BEGIN
				INSERT INTO GBL_Display (
					[Domain],
					ViewTypeCIC
				) VALUES (
					@Domain,
					@ViewType
				)
			END ELSE BEGIN
				INSERT INTO GBL_Display (
					[Domain],
					ViewTypeVOL
				) VALUES (
					@Domain,
					@ViewType
				)
			END
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DisplayOptionsObjectName, @ErrMsg
			SET @DD_ID=SCOPE_IDENTITY()
		END
	END
	IF @DD_ID IS NOT NULL BEGIN
		IF @Domain = 1 BEGIN
			IF NOT EXISTS(SELECT * FROM GBL_FieldOption WHERE FieldID=@OrderByCustom) BEGIN
				SET @OrderByCustom = NULL
			END
		END ELSE BEGIN
			IF NOT EXISTS(SELECT * FROM VOL_FieldOption WHERE FieldID=@OrderByCustom) BEGIN
				SET @OrderByCustom = NULL
			END
		END

		UPDATE GBL_Display SET
			ShowID			= @ShowID,
			ShowOwner		= @ShowOwner,
			ShowAlert		= @ShowAlert,
			ShowOrg			= @ShowOrg,
			ShowCommunity	= @ShowCommunity,
			ShowUpdateSchedule	= @ShowUpdateSchedule,
			LinkUpdate		= @LinkUpdate,
			LinkEmail		= @LinkEmail,
			LinkSelect		= @LinkSelect,
			LinkWeb			= @LinkWeb,
			LinkListAdd		= @LinkListAdd,
			OrderBy			= @OrderBy,
			OrderByCustom	= @OrderByCustom,
			OrderByDesc		= @OrderByDesc,
			TableSort		= @TableSort,
			GLinkMail		= @GLinkMail,
			GLinkPub		= @GLinkPub,
			ShowTable		= @ShowTable,
			VShowPosition	= @VShowPosition,
			VShowDuties		= @VShowDuties
		WHERE DD_ID=@DD_ID
		EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DisplayOptionsObjectName, @ErrMsg

		/* Update Field List */
		DECLARE @tmpFieldIDs TABLE(FieldID int)
		IF @Domain = 1 BEGIN
			INSERT INTO @tmpFieldIDs SELECT DISTINCT tm.*
				FROM dbo.fn_GBL_ParseIntIDList(@FieldList,',') tm
				INNER JOIN  GBL_FieldOption fld ON tm.ItemID = fld.FieldID
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DisplayOptionsObjectName, @ErrMsg
			
			DELETE pr
				FROM GBL_Display_Fld pr
				LEFT JOIN @tmpFieldIDs tm
					ON pr.FieldID = tm.FieldID
			WHERE tm.FieldID IS NULL AND DD_ID=@DD_ID
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DisplayOptionsObjectName, @ErrMsg
						
			INSERT INTO GBL_Display_Fld (DD_ID, FieldID) SELECT DD_ID=@DD_ID, tm.FieldID
				FROM @tmpFieldIDs tm
			WHERE NOT EXISTS(SELECT * FROM GBL_Display_Fld pr WHERE DD_ID=@DD_ID AND pr.FieldID=tm.FieldID)
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DisplayOptionsObjectName, @ErrMsg
			
			DELETE FROM VOL_Display_Fld WHERE DD_ID=@DD_ID
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DisplayOptionsObjectName, @ErrMsg
		END ELSE BEGIN
			INSERT INTO @tmpFieldIDs SELECT DISTINCT tm.*
				FROM dbo.fn_GBL_ParseIntIDList(@FieldList,',') tm
				INNER JOIN  VOL_FieldOption fld ON tm.ItemID = fld.FieldID
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DisplayOptionsObjectName, @ErrMsg
			
			DELETE pr
				FROM VOL_Display_Fld pr
				LEFT JOIN @tmpFieldIDs tm
					ON pr.FieldID = tm.FieldID
			WHERE tm.FieldID IS NULL AND DD_ID=@DD_ID
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DisplayOptionsObjectName, @ErrMsg
			
			INSERT INTO VOL_Display_Fld (DD_ID, FieldID) SELECT DD_ID=@DD_ID, tm.FieldID
				FROM @tmpFieldIDs tm
			WHERE NOT EXISTS(SELECT * FROM VOL_Display_Fld pr WHERE DD_ID=@DD_ID AND pr.FieldID=tm.FieldID)
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DisplayOptionsObjectName, @ErrMsg
			
			DELETE FROM GBL_Display_Fld WHERE DD_ID=@DD_ID
			EXEC @Error =  cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @DisplayOptionsObjectName, @ErrMsg
		END
	END
END

RETURN @Error

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Display_u] TO [cioc_login_role]
GO
