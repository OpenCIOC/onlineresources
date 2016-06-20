SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Fields_u]
	@MODIFIED_BY [varchar](50),
	@MemberID int,
	@SuperUserGlobal bit,
	@Data [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7.4
	Checked by: CL
	Checked on: 19-Jun-2016
	Action: NO ACTION REQUIRED
*/

DECLARE	@Error		int
SET @Error = 0

DECLARE	@FieldObjectName nvarchar(100),
		@LanguageObjectName nvarchar(100)

SET @FieldObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Field')
SET @LanguageObjectName = cioc_shared.dbo.fn_SHR_STP_ObjectName('Language')

DECLARE @FieldTable TABLE (
	FieldID int NOT NULL,
	Required bit NOT NULL,
	DisplayOrder tinyint NOT NULL
)

DECLARE @DescTable TABLE (
	FieldID int NOT NULL,
	Culture varchar(5) NOT NULL,
	LangID smallint NULL,
	FieldDisplay nvarchar(100) NULL
)

DECLARE @BadCulturesDesc nvarchar(max)

INSERT INTO @FieldTable 
SELECT 
	N.value('FieldID[1]', 'int') AS FieldID,
	CASE WHEN N.query('Required').value('/', 'varchar(4)') = 'True' THEN 1 ELSE 0 END AS Required,
	N.value('DisplayOrder[1]', 'int') AS DisplayOrder
FROM @Data.nodes('//Field') as T(N)
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

INSERT INTO @DescTable (
	FieldID,
	Culture,
	LangID,
	FieldDisplay
)
SELECT
	N.value('FieldID[1]', 'int') AS FieldID,
	iq.*

FROM @Data.nodes('//Field') AS T(N) CROSS APPLY 
	( SELECT 
		D.value('Culture[1]', 'varchar(5)') AS Culture,
		(SELECT LangID FROM STP_Language sl WHERE sl.Culture = D.value('Culture[1]', 'varchar(5)') AND ActiveRecord=1) AS LangID,
		D.value('FieldDisplay[1]', 'nvarchar(100)') AS FieldDisplay
			FROM N.nodes('DESCS/DESC') AS T2(D) ) iq 
EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg



SELECT @BadCulturesDesc = COALESCE(@BadCulturesDesc + cioc_shared.dbo.fn_SHR_STP_ObjectName(' ; '),'') + ISNULL(Culture,cioc_shared.dbo.fn_SHR_STP_ObjectName('Unknown'))
FROM @DescTable nt
WHERE LangID IS NULL

IF @BadCulturesDesc IS NOT NULL BEGIN
	SET @Error = 3 -- No Such Record
	SET @ErrMsg = cioc_shared.dbo.fn_SHR_STP_FormatError(@Error, @BadCulturesDesc, @LanguageObjectName)
END

IF @Error = 0 BEGIN
		UPDATE fo
		SET	MODIFIED_DATE		= GETDATE(),
			MODIFIED_BY			= @MODIFIED_BY,
			AllowNulls			= CASE WHEN nf.Required = 1 THEN 0 ELSE 1 END,
			DisplayOrder		= nf.DisplayOrder
		FROM GBL_FieldOption fo
		INNER JOIN @FieldTable nf
			ON fo.FieldID=nf.FieldID

	EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg
	

	IF @Error=0  BEGIN
		UPDATE fod SET
			FieldDisplay = CASE WHEN nf.FieldDisplay ='' THEN NULL ELSE nf.FieldDisplay END,
			MODIFIED_BY = @MODIFIED_BY,
			MODIFIED_DATE = GETDATE()
		FROM GBL_FieldOption_Description fod
		INNER JOIN @DescTable nf
			ON fod.LangID=nf.LangID AND fod.FieldID=nf.FieldID
		WHERE @SuperUserGlobal=1 OR EXISTS(SELECT * FROM GBL_FieldOption fo WHERE fo.FieldID=fod.FieldID AND fo.MemberID=@MemberID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg
	
		INSERT INTO GBL_FieldOption_Description (
			CREATED_BY,
			CREATED_DATE,
			MODIFIED_BY,
			MODIFIED_DATE,
			FieldID,
			LangID,
			FieldDisplay
		) SELECT 
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			nf.FieldID,
			LangID,
			FieldDisplay
		FROM @DescTable nf
		INNER JOIN GBL_FieldOption fo
			ON fo.FieldID = nf.FieldID
		WHERE FieldDisplay != '' AND FieldDisplay IS NOT NULL AND 
			NOT EXISTS(SELECT * FROM GBL_FieldOption_Description WHERE FieldID=nf.FieldID AND LangID=nf.LangID)
			AND (@SuperUserGlobal=1 OR fo.MemberID=@MemberID)
		EXEC @Error = cioc_shared.dbo.sp_STP_UnknownErrorCheck @@ERROR, @FieldObjectName, @ErrMsg

	END
END

RETURN @Error

SET NOCOUNT OFF

















GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Fields_u] TO [cioc_login_role]
GO
