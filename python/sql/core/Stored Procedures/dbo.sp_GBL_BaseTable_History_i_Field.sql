SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_History_i_Field]
	@MODIFIED_BY varchar(50),
	@MODIFIED_DATE datetime,
	@NUMList varchar(max),
	@FieldName varchar(100),
	@User_ID int,
	@ViewType int,
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

DECLARE	@FieldID int

SELECT @FieldID = fo.FieldID
	FROM GBL_FieldOption fo
WHERE fo.FieldName = @FieldName COLLATE Latin1_General_100_CI_AI
	AND ChangeHistory > 0

IF @FieldID IS NOT NULL AND @NUMList IS NOT NULL BEGIN
	DECLARE @Lang varchar(60),
			@FieldSelect nvarchar(max),
			@SQL nvarchar(max),
			@ParamList nvarchar(max)

	DECLARE Lang_Cursor CURSOR STATIC FOR 
		SELECT LanguageAlias FROM STP_Language sln WHERE 
			(@LangID IS NULL OR sln.LangID=@LangID)
			AND EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.LangID=sln.LangID)

	OPEN Lang_Cursor

	FETCH NEXT FROM Lang_Cursor INTO @Lang

	WHILE @@FETCH_STATUS = 0 BEGIN

		SET LANGUAGE @Lang

		SELECT @FieldSelect = dbo.fn_GBL_FieldOption_Display(
					NULL,
					@ViewType,
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
				)
			FROM GBL_FieldOption fo
			LEFT JOIN GBL_FieldOption_Description fod
				ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
			WHERE fo.FieldID=@FieldID

		SET @ParamList = N'@FieldID int, @NUMList varchar(max), @MODIFIED_DATE datetime, @MODIFIED_BY varchar(50)'

		SET @SQL = N'
INSERT INTO GBL_BaseTable_History (
	NUM, LangID, MODIFIED_BY, MODIFIED_DATE, FieldID, FieldDisplay
)
SELECT DISTINCT bt.NUM, btd.LangID,
	@MODIFIED_BY,
	@MODIFIED_DATE,
	@FieldID,
	' + @FieldSelect + '
FROM GBL_BaseTable bt
INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM
	AND btd.LangID=@@LANGID
LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM
LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM
	AND cbtd.LangID=@@LANGID
LEFT JOIN CCR_BaseTable ccbt ON cbt.NUM=ccbt.NUM
LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM
	AND ccbtd.LangID=@@LANGID
INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@NUMList,'','') tm
		ON tm.ItemID = bt.NUM COLLATE Latin1_General_100_CI_AI
WHERE NOT EXISTS(SELECT * FROM GBL_BaseTable_History
		WHERE NUM=bt.NUM AND LangID=@@LANGID AND FieldID=@FieldID
		AND (FieldDisplay=' + @FieldSelect + ' COLLATE Latin1_General_100_CS_AS OR (FieldDisplay IS NULL AND ' + @FieldSelect + ' IS NULL))
		AND HST_ID=(SELECT MAX(HST_ID) FROM GBL_BaseTable_History WHERE NUM=bt.NUM AND LangID=@@LANGID AND FieldID=@FieldID)
		)'

		EXEC sp_executesql @SQL, @ParamList, @FieldID=@FieldID, @NUMList=@NUMList, @MODIFIED_DATE=@MODIFIED_DATE, @MODIFIED_BY=@MODIFIED_BY

		FETCH NEXT FROM Lang_Cursor INTO @Lang

	END

	CLOSE Lang_Cursor

	DEALLOCATE Lang_Cursor
END

SET LANGUAGE @RestoreLang

SET NOCOUNT OFF









GO
GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_History_i_Field] TO [cioc_login_role]
GO
