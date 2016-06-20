
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CIC_FieldOption_u_Help]
	@FieldID int,
	@MemberID int,
	@GlobalSuperUser bit,
	@MODIFIED_BY [varchar](50),
	@Data [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: CL
	Checked on: 05-Sep-2014
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@FieldObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @FieldObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Field')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @DescTable TABLE (
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	HelpText nvarchar(MAX) NULL,
	HelpTextMember nvarchar(MAX) NULL
)

DECLARE @BadCulturesDesc nvarchar(max)

INSERT INTO @DescTable (
	Culture,
	LangID,
	HelpText,
	HelpTextMember
)
SELECT
	N.value('Culture[1]', 'varchar(5)') AS Culture,
	(SELECT LangID FROM STP_Language sl WHERE sl.Culture = N.value('Culture[1]', 'varchar(5)') AND ActiveRecord=1) AS LangID,
	N.value('HelpText[1]', 'nvarchar(max)') AS HelpText,
	N.value('HelpTextMember[1]', 'nvarchar(max)') AS HelpTextMember
FROM @Data.nodes('//DESC') AS T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg



SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

IF @FieldID IS NULL BEGIN
	SET @Error = 10 -- Required field
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, 'FieldID', @FieldObjectName)
END ELSE IF NOT EXISTS(SELECT * FROM GBL_FieldOption WHERE FieldID=@FieldID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, CAST(@FieldID AS varchar), @FieldObjectName)
END ELSE IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, @LanguageObjectName)
END

IF @Error = 0 BEGIN

	IF @GlobalSuperUser = 1 BEGIN
		MERGE INTO GBL_FieldOption_Description dst
		USING (
				SELECT l.LangID, HelpText
				FROM @DescTable dt
				INNER JOIN STP_Language l
					ON l.LangID=dt.LangID AND l.ActiveRecord=1
		) src
			ON dst.FieldID=@FieldID AND dst.LangID=src.LangID
		WHEN MATCHED THEN 
			UPDATE SET
				HelpText = src.HelpText,
				MODIFIED_BY = @MODIFIED_BY,
				MODIFIED_DATE = GETDATE()
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				CREATED_BY,
				CREATED_DATE,
				MODIFIED_BY,
				MODIFIED_DATE,
				FieldID,
				LangID,
				HelpText
			) VALUES ( 
				@MODIFIED_BY,
				GETDATE(),
				@MODIFIED_BY,
				GETDATE(),
				@FieldID,
				src.LangID,
				src.HelpText
			)
		
		WHEN NOT MATCHED BY SOURCE AND FieldID=@FieldID THEN	
			UPDATE SET HelpText=NULL
			;
		
	END
	
	INSERT INTO GBL_FieldOption_Description (
		CREATED_BY,
		CREATED_DATE,
		MODIFIED_BY,
		MODIFIED_DATE,
		FieldID,
		LangID,
		HelpText
	) SELECT 
		@MODIFIED_BY,
		GETDATE(),
		@MODIFIED_BY,
		GETDATE(),
		@FieldID,
		LangID,
		HelpText
	FROM @DescTable nf
	WHERE HelpTextMember IS NOT NULL AND 
		NOT EXISTS(SELECT * FROM GBL_FieldOption_Description WHERE FieldID=@FieldID AND LangID=nf.LangID)
	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg
	
	MERGE INTO GBL_FieldOption_HelpByMember dst
	USING (
			SELECT l.LangID, HelpTextMember AS HelpText
			FROM @DescTable dt
			INNER JOIN STP_Language l
				ON l.LangID=dt.LangID AND l.ActiveRecord=1
	) src
		ON dst.FieldID=@FieldID AND dst.LangID=src.LangID AND MemberID=@MemberID
	WHEN MATCHED AND src.HelpText IS NOT NULL THEN 
		UPDATE SET
			HelpText = src.HelpText,
			MODIFIED_BY = @MODIFIED_BY,
			MODIFIED_DATE = GETDATE()
	WHEN MATCHED AND src.HelpText IS NULL THEN
		DELETE
	WHEN NOT MATCHED BY TARGET AND src.HelpText IS NOT NULL THEN
		INSERT (
			CREATED_BY,
			CREATED_DATE,
			MODIFIED_BY,
			MODIFIED_DATE,
			FieldID,
			LangID,
			MemberID,
			HelpText
		) VALUES ( 
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@FieldID,
			src.LangID,
			@MemberID,
			src.HelpText
		)
	
	WHEN NOT MATCHED BY SOURCE AND FieldID=@FieldID AND MemberID=@MemberID THEN	
		DELETE
		;
		

END

RETURN @Error

SET NOCOUNT OFF





GO


GRANT EXECUTE ON  [dbo].[sp_CIC_FieldOption_u_Help] TO [cioc_login_role]
GO
