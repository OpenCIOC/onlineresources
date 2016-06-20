SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Opportunity_History_i_Field]
	@MODIFIED_BY varchar(50),
	@MODIFIED_DATE datetime,
	@VNUMList varchar(max),
	@FieldName varchar(100),
	@User_ID int,
	@ViewType int,
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

DECLARE	@FieldID int

SELECT @FieldID = fo.FieldID
	FROM VOL_FieldOption fo
WHERE fo.FieldName = @FieldName COLLATE Latin1_General_100_CI_AI
	AND ChangeHistory > 0

IF @FieldID IS NOT NULL AND @VNUMList IS NOT NULL BEGIN
	DECLARE @Lang varchar(60),
			@FieldSelect nvarchar(max),
			@SQL nvarchar(max),
			@ParamList nvarchar(max)

	DECLARE Lang_Cursor CURSOR STATIC FOR 
		SELECT LanguageAlias FROM STP_Language sln WHERE 
			(@LangID IS NULL OR sln.LangID=@LangID)
			AND EXISTS(SELECT * FROM VOL_Opportunity_Description vod WHERE vod.LangID=sln.LangID)

	OPEN Lang_Cursor

	FETCH NEXT FROM Lang_Cursor INTO @Lang

	WHILE @@FETCH_STATUS = 0 BEGIN

		SET LANGUAGE @Lang

		SELECT @FieldSelect = dbo.fn_VOL_FieldOption_Display(
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
				)
			FROM VOL_FieldOption fo
			LEFT JOIN VOL_FieldOption_Description fod
				ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
			WHERE fo.FieldID=@FieldID

		SET @ParamList = N'@FieldID int, @VNUMList varchar(max), @MODIFIED_DATE datetime, @MODIFIED_BY varchar(50)'

		SET @SQL = N'
INSERT INTO VOL_Opportunity_History (
	VNUM, LangID, MODIFIED_BY, MODIFIED_DATE, FieldID, FieldDisplay
)
SELECT DISTINCT vo.VNUM, vod.LangID,
	@MODIFIED_BY,
	@MODIFIED_DATE,
	@FieldID,
	' + @FieldSelect + '
FROM VOL_Opportunity vo
INNER JOIN VOL_Opportunity_Description vod ON vo.VNUM=vod.VNUM
	AND vod.LangID=@@LANGID
INNER JOIN dbo.fn_GBL_ParseVarCharIDList(@VNUMList,'','') tm
		ON tm.ItemID = vo.VNUM COLLATE Latin1_General_100_CS_AI
WHERE NOT EXISTS(SELECT * FROM VOL_Opportunity_History
		WHERE VNUM=vo.VNUM AND LangID=@@LANGID AND FieldID=@FieldID
		AND (FieldDisplay=' + @FieldSelect + ' COLLATE Latin1_General_100_CS_AS OR (FieldDisplay IS NULL AND ' + @FieldSelect + ' IS NULL))
		AND HST_ID=(SELECT MAX(HST_ID) FROM VOL_Opportunity_History WHERE VNUM=vo.VNUM AND LangID=@@LANGID AND FieldID=@FieldID)
		)'

		EXEC sp_executesql @SQL, @ParamList, @FieldID=@FieldID, @VNUMList=@VNUMList, @MODIFIED_DATE=@MODIFIED_DATE, @MODIFIED_BY=@MODIFIED_BY

		FETCH NEXT FROM Lang_Cursor INTO @Lang

	END

	CLOSE Lang_Cursor

	DEALLOCATE Lang_Cursor
END

SET LANGUAGE @RestoreLang

SET NOCOUNT OFF










GO
GRANT EXECUTE ON  [dbo].[sp_VOL_Opportunity_History_i_Field] TO [cioc_login_role]
GO
