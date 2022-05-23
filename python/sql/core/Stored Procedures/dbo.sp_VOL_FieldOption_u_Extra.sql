SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_VOL_FieldOption_u_Extra]
	@SuperUSerGlobal bit,
	@OwnerMemberID int,
	@MemberID int,
	@FieldID int,
	@MODIFIED_BY varchar(50),
	@ExtraFieldType char(1),
	@ExtraFieldName varchar(25),
	@MaxLength int,
	@FullTextIndex bit,
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE	@Error	int
SET @Error = 0

DECLARE	@FieldObjectName nvarchar(60)

SET @FieldObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Field')

DECLARE @FieldName varchar(100)

IF @ExtraFieldType IN ('a', 'd') BEGIN
	SET @FieldName = 'EXTRA_DATE_' + @ExtraFieldName
	SET @MaxLength = 25
	SET @FullTextIndex = 0
END ELSE IF @ExtraFieldType = 'e' BEGIN
	SET @FieldName = 'EXTRA_EMAIL_' + @ExtraFieldName
	SET @MaxLength = 100
	SET @FullTextIndex = 0
END ELSE IF @ExtraFieldType = 'r' BEGIN
	SET @FieldName = 'EXTRA_RADIO_' + @ExtraFieldName
	SET @MaxLength = NULL
	SET @FullTextIndex = 0
END ELSE IF @ExtraFieldType = 't' BEGIN
	SET @FieldName = 'EXTRA_' + @ExtraFieldName
	SET @MaxLength = CASE
			WHEN @MaxLength < 1 THEN 1
			WHEN @MaxLength IS NULL OR @MaxLength > 8000 THEN 8000
			ELSE @MaxLength
		END
END ELSE IF @ExtraFieldType = 'w' BEGIN
	SET @FieldName = 'EXTRA_WWW_' + @ExtraFieldName
	SET @MaxLength = 255
	SET @FullTextIndex = 0
END ELSE IF @ExtraFieldType = 'l' BEGIN
	SET @FieldName = 'EXTRA_CHECKLIST_' + @ExtraFieldName
	SET @MaxLength = NULL
	SET @FullTextIndex = 0
END ELSE IF @ExtraFieldType = 'p' BEGIN
	SET @FieldName = 'EXTRA_DROPDOWN_' + @ExtraFieldName
	SET @MaxLength = NULL
	SET @FullTextIndex = 0
END ELSE BEGIN
	SET @Error = 5 -- Invalid Code
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @ExtraFieldType, @FieldObjectName)
END

/* Identify errors that will prevent the record from being deleted */
IF @Error=0 BEGIN
	IF @FieldID IS NOT NULL AND NOT EXISTS (SELECT * FROM VOL_FieldOption WHERE FieldID=@FieldID AND (ExtraFieldType=@ExtraFieldType OR (ExtraFieldType IN ('a','d') AND @ExtraFieldType IN ('a','d')))) BEGIN
		SET @Error = 3 -- No Such Record
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@FieldID AS varchar), @FieldObjectName)
	END ELSE IF EXISTS(SELECT * FROM VOL_FieldOption WHERE FieldName=@FieldName AND (@FieldID IS NULL OR FieldID<>@FieldID)) BEGIN
		SET @Error = 6 -- Value In Use
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FieldName, @FieldObjectName)
	END ELSE IF @SuperUSerGlobal=0 AND @FieldID IS NOT NULL AND NOT EXISTS(SELECT * FROM VOL_FieldOption WHERE FieldID=@FieldID AND MemberID=@OwnerMemberID) BEGIN
		SET @Error = 8 -- Security Failure
		SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @FieldObjectName, NULL)
	/* No issues exist that prevent the update */
	END ELSE BEGIN
		IF @FieldID IS NULL BEGIN
			INSERT INTO VOL_FieldOption (
				CREATED_DATE,
				CREATED_BY,
				MODIFIED_DATE,
				MODIFIED_BY,
				FieldName,
				FieldType,
				ExtraFieldType,
				MaxLength,
				FullTextIndex,
				MemberID
			) VALUES (
				GETDATE(),
				@MODIFIED_BY,
				GETDATE(),
				@MODIFIED_BY,
				@FieldName,
				'VOL',
				@ExtraFieldType,
				@MaxLength,
				@FullTextIndex,
				@OwnerMemberID
			)
			EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg
			SET @FieldID = SCOPE_IDENTITY()
			
			IF @ExtraFieldType='r' AND @FieldID IS NOT NULL BEGIN
				INSERT INTO VOL_FieldOption_Description (
					FieldID,
					LangID,
					CREATED_DATE,
					CREATED_BY,
					MODIFIED_DATE,
					MODIFIED_BY,
					CheckboxOnText,
					CheckboxOffText
				) SELECT
					@FieldID,
					LangID,
					GETDATE(),
					@MODIFIED_BY,
					GETDATE(),
					@MODIFIED_BY,
					cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Yes',LangID),
					cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('No',LangID)
				FROM STP_Language
				WHERE Active=1
			END
			
			IF @Error=0 AND @FieldID IS NOT NULL AND (SELECT COUNT(*) FROM STP_Member WHERE Active=1) > 1 BEGIN
				INSERT INTO VOL_FieldOption_InactiveByMember (
					FieldID,
					MemberID
				)
				SELECT	@FieldID,
						MemberID
					FROM STP_Member
				WHERE Active=1 AND MemberID <> @MemberID
			END
			
			EXEC dbo.sp_STP_RegenerateUserFields 2, @FieldName
		END ELSE BEGIN
			DECLARE @FieldNameChanged bit
			SELECT @FieldNameChanged = CASE WHEN FieldName<>@FieldName THEN CAST(1 AS bit) ELSE CAST(0 AS bit) END FROM VOL_FieldOption WHERE FieldID=@FieldID
			UPDATE VOL_FieldOption
			SET	FieldName				= @FieldName,
				ExtraFieldType			= @ExtraFieldType,
				MaxLength				= @MaxLength,
				FullTextIndex			= @FullTextIndex,
				MODIFIED_BY				= @MODIFIED_BY,
				MODIFIED_DATE			= GETDATE(),
				MemberID				= @OwnerMemberID
			WHERE FieldID=@FieldID
			EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg
			
			EXEC dbo.sp_STP_RegenerateUserFields 2, @FieldName
		END
	END
END

RETURN @Error

SET NOCOUNT OFF







GO
GRANT EXECUTE ON  [dbo].[sp_VOL_FieldOption_u_Extra] TO [cioc_login_role]
GO
