SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_Reminder_u]
	@ReminderID int OUTPUT,
	@MODIFIED_BY varchar(50),
	@User_ID int,
	@Culture varchar(5),
	@NoteTypeID int,
	@ActiveDate smalldatetime,
	@DueDate smalldatetime,
	@Notes nvarchar(max),
	@DismissForAll bit,
	@AgencyCode varchar(max),
	@User_IDs varchar(max),
	@NUMs varchar(max),
	@VNUMs varchar(max),
	@ErrMsg nvarchar(500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@Error	int
SET @Error = 0

DECLARE	@ReminderObjectName nvarchar(100),
		@NoteTypeObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)
		
SET @ReminderObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Reminder')
SET @NoteTypeObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Note Type')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')


DECLARE @MemberID int, @LangID smallint
SELECT @MemberID=MemberID_Cache FROM GBL_Users WHERE User_ID=@User_ID

SELECT @LangID=LangID FROM STP_Language WHERE Culture=@Culture AND ActiveRecord=1

SET @Notes = NULLIF(RTRIM(LTRIM(@Notes)), '')

IF @ReminderID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_Reminder WHERE ReminderID=@ReminderID AND MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@ReminderID AS varchar), @ReminderObjectName)
END ELSE IF @Notes IS NULL BEGIN
	SET @Error = 10 -- Required Field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, cioc_shared.dbo.fn_SHR_STP_ObjectName('Notes'), @ReminderObjectName)
END ELSE IF @NoteTypeID IS NOT NULL AND NOT EXISTS(SELECT * FROM GBL_RecordNote_Type WHERE NoteTypeID=@NoteTypeID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@NoteTypeID AS varchar), @NoteTypeObjectName)
END ELSE IF @Culture IS NOT NULL AND @LangID IS NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @Culture, @LanguageObjectName)
END ELSE BEGIN
	IF @ReminderID IS NULL BEGIN
		INSERT INTO GBL_Reminder (
			CREATED_DATE,
			CREATED_BY,
			MODIFIED_DATE,
			MODIFIED_BY,
			MemberID,
			UserID, 
			LangID,
			NoteTypeID,
			ActiveDate,
			DueDate,
			Notes,
			DismissForAll
		) VALUES (
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			@MemberID,
			@User_ID,
			@LangID,
			@NoteTypeID,
			@ActiveDate,
			@DueDate,
			@Notes,
			@DismissForAll
		)
		SET @ReminderID = SCOPE_IDENTITY()
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @ReminderObjectName, @ErrMsg
	END ELSE BEGIN
		UPDATE GBL_Reminder SET
			MODIFIED_DATE = GETDATE(),
			MODIFIED_BY = @MODIFIED_BY,
			LangID = @LangID,
			NoteTypeID = @NoteTypeID,
			ActiveDate = @ActiveDate,
			DueDate = @DueDate,
			Notes = @Notes,
			DismissForAll = @DismissForAll
		WHERE ReminderID = @ReminderID
			
	END
	
	IF @ReminderID IS NOT NULL BEGIN
	
		MERGE INTO GBL_Reminder_Agency dst
		USING (SELECT AgencyID 
			FROM GBL_Agency a
			INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@AgencyCode, ',') codes
				ON a.AgencyCode = codes.ItemID COLLATE Latin1_General_100_CI_AI 
				) src
		ON dst.ReminderID=@ReminderID AND dst.AgencyID=src.AgencyID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ReminderID, AgencyID)
				VALUES (@ReminderID, src.AgencyID)
		WHEN NOT MATCHED BY SOURCE AND dst.ReminderID=@ReminderID THEN
			DELETE
			
			;
		
		MERGE INTO GBL_Reminder_User dst
		USING (
			SELECT User_ID 
			FROM GBL_Users u
			INNER JOIN dbo.fn_GBL_ParseIntIDList(@User_IDs, ',') ids
				ON u.User_ID = ids.ItemID) src
		ON dst.ReminderID=@ReminderID AND dst.User_ID=src.User_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ReminderID, User_ID)
				VALUES (@ReminderID, src.User_ID)
		WHEN NOT MATCHED BY SOURCE AND dst.ReminderID=@ReminderID THEN
			DELETE
			;
			
	
		MERGE INTO GBL_BT_Reminder dst
		USING (
			SELECT NUM
			FROM GBL_BaseTable bt
			INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@NUMs, ',') nums
				ON bt.NUM = nums.ItemID COLLATE Latin1_General_100_CI_AI
			) src
		ON dst.ReminderID=@ReminderID AND dst.NUM=src.NUM
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ReminderID, NUM)
				VALUES (@ReminderID, NUM)
		WHEN NOT MATCHED BY SOURCE AND dst.ReminderID=@ReminderID THEN
			DELETE
			;
		
		MERGE INTO VOL_OP_Reminder dst
		USING (
			SELECT VNUM
			FROM VOL_Opportunity vo
			INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@VNUMs, ',') vnums
				ON vo.VNUM = vnums.ItemID COLLATE Latin1_General_100_CS_AI
			) src
		ON dst.ReminderID=@ReminderID AND dst.VNUM=src.VNUM
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ReminderID, VNUM)
				VALUES (@ReminderID, src.VNUM)
		WHEN NOT MATCHED BY SOURCE AND dst.ReminderID=@ReminderID THEN
			DELETE
			;
			
			
	END
END

RETURN @Error

SET NOCOUNT OFF






GO
GRANT EXECUTE ON  [dbo].[sp_GBL_Reminder_u] TO [cioc_login_role]
GO
