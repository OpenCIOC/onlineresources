SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_VOL_FieldOption_Display_Print](
	@MemberID int,
	@ViewType int,
	@FieldID int,
	@ContentIfEmpty nvarchar(255)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 14-May-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	nvarchar(max),
		@newFieldID	int,
		@newContentIfEmpty	nvarchar(2000)

IF @ContentIfEmpty LIKE '@@__%' BEGIN
	SELECT @newFieldID = FieldID FROM GBL_FieldOption WHERE FieldName=RIGHT(@ContentIfEmpty,LEN(@ContentIfEmpty)-2)
	IF @newFieldID IS NOT NULL BEGIN
		SELECT @newContentIfEmpty = dbo.fn_VOL_FieldOption_Display_Print(@MemberID,@ViewType,@newFieldID,NULL) 
	END
	SET @ContentIfEmpty = NULL
END
SELECT @returnStr = CASE 
			WHEN @ContentIfEmpty IS NOT NULL THEN 'ISNULL(' 
			WHEN @newContentIfEmpty IS NOT NULL THEN 'CAST(ISNULL(' 
			ELSE ''
		END
		+ dbo.fn_VOL_FieldOption_Display(
					@MemberID,
					@ViewType,
					fo.FieldID,
					fo.FieldName,
					fo.CanShare,
					fo.DisplayFM,
					fo.FormFieldType,
					fo.EquivalentSource,
					fod.CheckboxOnText,
					fod.CheckboxOffText,
					0
				)
		 + CASE
			WHEN @ContentIfEmpty IS NOT NULL THEN ',''' + REPLACE(@ContentIfEmpty,'''','''''') + ''')' 
			WHEN @newContentIfEmpty IS NOT NULL THEN ',' + @newContentIfEmpty + ') AS nvarchar(max))'
			ELSE ''
		END 
	FROM VOL_FieldOption fo
	LEFT JOIN VOL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
WHERE fo.FieldID=@FieldID

RETURN @returnStr

END






GO
GRANT EXECUTE ON  [dbo].[fn_VOL_FieldOption_Display_Print] TO [cioc_vol_search_role]
GO
