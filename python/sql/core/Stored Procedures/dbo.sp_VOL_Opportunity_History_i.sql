SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Opportunity_History_i]
	@MODIFIED_BY varchar(50),
	@MODIFIED_DATE datetime,
	@VNUM varchar(10),
	@FieldList varchar(max),
	@Names bit,
	@LangID smallint
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE @RestoreLang nvarchar(60)

SET @RestoreLang = @@LANGUAGE

IF @VNUM IS NOT NULL BEGIN
	DECLARE @Lang varchar(60),
			@FieldSelect nvarchar(max),
			@SQLDeclare nvarchar(max),
			@SQLSelect nvarchar(max),
			@SQLInsert nvarchar(max),
			@ParamList nvarchar(max)

	DECLARE Lang_Cursor CURSOR STATIC FOR 
		SELECT LanguageAlias FROM STP_Language sln WHERE 
			(@LangID IS NULL OR sln.LangID=@LangID)
			AND EXISTS(SELECT * FROM VOL_Opportunity_Description vod WHERE vod.LangID=sln.LangID)

	OPEN Lang_Cursor

	FETCH NEXT FROM Lang_Cursor INTO @Lang

	WHILE @@FETCH_STATUS = 0 BEGIN

		SET LANGUAGE @Lang

		SET @SQLDeclare = NULL
		SET @SQLSelect = NULL
		SET @SQLInsert = NULL
		SET @ParamList = N'@VNUM varchar(10), @MODIFIED_DATE datetime, @MODIFIED_BY varchar(50)'

		SELECT	@SQLDeclare = COALESCE(@SQLDeclare + ', ','') + '@NewContent' + CAST(fo.FieldID AS varchar) + ' varchar(max)',
				@SQLSelect = COALESCE(@SQLSelect + ', ','') + '@NewContent' + CAST(fo.FieldID AS varchar) + '=' + dbo.fn_VOL_FieldOption_Display(
					NULL,
					NULL,
					fo.FieldID,
					fo.FieldName,
					0,
					fo.DisplayFM,
					fo.FormFieldType,
					fo.EquivalentSource,
					fod.CheckboxOnText,
					fod.CheckboxOffText,
					0
				),
				@SQLInsert = COALESCE(@SQLInsert,'') + 'IF NOT EXISTS(SELECT * FROM VOL_Opportunity_History
	WHERE VNUM=@VNUM AND LangID=@@LANGID AND FieldID=' + CAST(fo.FieldID AS varchar) + '
		AND (FieldDisplay=@NewContent' + CAST(fo.FieldID AS varchar) + ' COLLATE Latin1_General_100_CS_AS OR (FieldDisplay IS NULL AND @NewContent' + CAST(fo.FieldID AS varchar) + ' IS NULL))
		AND HST_ID=(SELECT MAX(HST_ID) FROM VOL_Opportunity_History WHERE VNUM=@VNUM AND LangID=@@LANGID AND FieldID=' + CAST(fo.FieldID AS varchar) + '))
	BEGIN

	IF EXISTS(SELECT * FROM VOL_Opportunity_Description WHERE VNUM=@VNUM AND LangID=@@LANGID) BEGIN
		INSERT INTO VOL_Opportunity_History (
			VNUM, LangID, MODIFIED_BY, MODIFIED_DATE, FieldID, FieldDisplay
		)
		VALUES (
			@VNUM,
			@@LANGID,
			@MODIFIED_BY,
			@MODIFIED_DATE,
			' + CAST(fo.FieldID AS varchar) + ',
			@NewContent' + CAST(fo.FieldID AS varchar) + '
		)
	END
END
'
			FROM VOL_FieldOption fo
			LEFT JOIN VOL_FieldOption_Description fod
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
SELECT ' + @SQLSelect + ' FROM VOL_Opportunity vo
INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM
	AND vod.LangID=@@LANGID
WHERE vo.VNUM=@VNUM
' + @SQLInsert
			EXEC sp_executesql @SQLSelect, @ParamList, @VNUM=@VNUM, @MODIFIED_DATE=@MODIFIED_DATE, @MODIFIED_BY=@MODIFIED_BY
		END

		FETCH NEXT FROM Lang_Cursor INTO @Lang

	END

	CLOSE Lang_Cursor

	DEALLOCATE Lang_Cursor
END

SET LANGUAGE @RestoreLang

SET NOCOUNT OFF





GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Opportunity_History_i] TO [cioc_login_role]
GO
