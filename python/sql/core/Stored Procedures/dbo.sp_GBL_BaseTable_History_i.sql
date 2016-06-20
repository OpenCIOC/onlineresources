SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_History_i]
	@MODIFIED_BY varchar(50),
	@MODIFIED_DATE datetime,
	@NUM varchar(8),
	@FieldList varchar(max),
	@Names bit,
	@LangID smallint
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5
	Checked by: KL
	Checked on: 24-Jul-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @RestoreLang nvarchar(60)

SET @RestoreLang = @@LANGUAGE

IF @NUM IS NOT NULL BEGIN
	DECLARE @Lang varchar(60),
			@FieldSelect nvarchar(max),
			@SQLDeclare nvarchar(max),
			@SQLSelect nvarchar(max),
			@SQLInsert nvarchar(max),
			@ParamList nvarchar(max)

	DECLARE Lang_Cursor CURSOR STATIC FOR 
		SELECT LanguageAlias FROM STP_Language sln WHERE 
			(@LangID IS NULL OR sln.LangID=@LangID)
			AND EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.LangID=sln.LangID)

	OPEN Lang_Cursor

	FETCH NEXT FROM Lang_Cursor INTO @Lang

	WHILE @@FETCH_STATUS = 0 BEGIN

		SET LANGUAGE @Lang

		SET @SQLDeclare = NULL
		SET @SQLSelect = NULL
		SET @SQLInsert = NULL
		SET @ParamList = N'@NUM varchar(8), @MODIFIED_DATE datetime, @MODIFIED_BY varchar(50)'

		SELECT	@SQLDeclare = COALESCE(@SQLDeclare + ', ','') + '@NewContent' + CAST(fo.FieldID AS varchar) + ' varchar(max)',
				@SQLSelect = COALESCE(@SQLSelect + ', ','') + '@NewContent' + CAST(fo.FieldID AS varchar) + '=' + dbo.fn_GBL_FieldOption_Display(
					NULL,
					NULL,
					fo.FieldID,
					fo.FieldName,
					0,
					NULL,
					0,
					fo.DisplayFM,
					fo.DisplayFMWeb,
					fo.FieldType,
					fo.FormFieldType,
					fo.EquivalentSource,
					fod.CheckboxOnText,
					fod.CheckboxOffText,
					0
				),
				@SQLInsert = COALESCE(@SQLInsert,'') + 'IF NOT EXISTS(SELECT * FROM GBL_BaseTable_History
	WHERE NUM=@NUM AND LangID=@@LANGID AND FieldID=' + CAST(fo.FieldID AS varchar) + '
		AND (FieldDisplay=@NewContent' + CAST(fo.FieldID AS varchar) + ' COLLATE Latin1_General_100_CS_AS OR (FieldDisplay IS NULL AND @NewContent' + CAST(fo.FieldID AS varchar) + ' IS NULL))
		AND HST_ID=(SELECT MAX(HST_ID) FROM GBL_BaseTable_History WHERE NUM=@NUM AND LangID=@@LANGID AND FieldID=' + CAST(fo.FieldID AS varchar) + '))
	BEGIN

	IF EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=@NUM AND LangID=@@LANGID) BEGIN
		INSERT INTO GBL_BaseTable_History (
			NUM, LangID, MODIFIED_BY, MODIFIED_DATE, FieldID, FieldDisplay
		)
		VALUES (
			@NUM,
			@@LANGID,
			@MODIFIED_BY,
			@MODIFIED_DATE,
			' + CAST(fo.FieldID AS varchar) + ',
			@NewContent' + CAST(fo.FieldID AS varchar) + '
		)
	END
END
'
			FROM GBL_FieldOption fo
			LEFT JOIN GBL_FieldOption_Description fod
				ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID

			WHERE fo.ChangeHistory > 0
				AND (
					@FieldList IS NULL OR
					EXISTS(SELECT * FROM dbo.fn_GBL_ParseVarCharIDList(@FieldList,',') tm
						WHERE (@Names=1 AND tm.ItemID=fo.FieldName COLLATE Latin1_General_100_CI_AI)
							OR (@Names=0 AND CAST(tm.ItemID AS int)=fo.FieldID)
					)
				)

		IF @SQLSelect IS NOT NULL BEGIN
			SET @SQLSelect = N'DECLARE ' + @SQLDeclare + '
SELECT ' + @SQLSelect + ' FROM GBL_BaseTable bt
INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM
	AND btd.LangID=@@LANGID
LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM
LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM
	AND cbtd.LangID=@@LANGID
LEFT JOIN CCR_BaseTable ccbt ON cbt.NUM=ccbt.NUM
LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM
	AND ccbtd.LangID=@@LANGID
WHERE bt.NUM=@NUM
' + @SQLInsert
			EXEC sp_executesql @SQLSelect, @ParamList, @NUM=@NUM, @MODIFIED_DATE=@MODIFIED_DATE, @MODIFIED_BY=@MODIFIED_BY
		END

		FETCH NEXT FROM Lang_Cursor INTO @Lang

	END

	CLOSE Lang_Cursor

	DEALLOCATE Lang_Cursor
END

SET LANGUAGE @RestoreLang

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_History_i] TO [cioc_login_role]
GO
