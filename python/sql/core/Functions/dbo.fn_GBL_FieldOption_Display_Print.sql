SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_FieldOption_Display_Print](
	@MemberID int,
	@ViewType int,
	@RespectPrivacy bit,
	@FieldID int,
	@ContentIfEmpty nvarchar(255)
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	nvarchar(max),
		@newFieldID	int,
		@newContentIfEmpty	nvarchar(2000)

IF @ContentIfEmpty LIKE '@@__%' BEGIN
	SELECT @newFieldID = FieldID FROM GBL_FieldOption WHERE FieldName=RIGHT(@ContentIfEmpty,LEN(@ContentIfEmpty)-2)
	IF @newFieldID IS NOT NULL BEGIN
		SELECT @newContentIfEmpty = dbo.fn_GBL_FieldOption_Display_Print(@MemberID,@ViewType,@RespectPrivacy,@newFieldID,NULL) 
	END
	SET @ContentIfEmpty = NULL
END

IF @RespectPrivacy=0
		AND EXISTS(SELECT * FROM GBL_SharingProfile WHERE ShareMemberID=@MemberID AND CanViewPrivate=0) BEGIN
	SET @RespectPrivacy = NULL
END

SELECT @returnStr = CASE 
			WHEN @ContentIfEmpty IS NOT NULL THEN 'ISNULL(' 
			WHEN @newContentIfEmpty IS NOT NULL THEN 'CAST(ISNULL(' 
			ELSE ''
		END
		+ CASE WHEN (FieldName='LOGO_ADDRESS')
			THEN dbo.fn_GBL_FieldOption_Display_Web(
					@MemberID,
					@ViewType,
					fo.FieldID,
					fo.FieldName,
					@RespectPrivacy,
					fo.PrivacyProfileIDList,
					CASE WHEN NOT EXISTS(SELECT * FROM GBL_BT_SharingProfile WHERE ShareMemberID_Cache=@MemberID) THEN 0 ELSE fo.CanShare END,
					fo.DisplayFM,
					fo.DisplayFMWeb,
					fo.FieldType,
					fo.FormFieldType,
					fo.EquivalentSource,
					fod.CheckboxOnText,
					fod.CheckboxOffText,
					0,
					'',
					''
				)
			ELSE dbo.fn_GBL_FieldOption_Display(
					@MemberID,
					@ViewType,
					fo.FieldID,
					fo.FieldName,
					@RespectPrivacy,
					fo.PrivacyProfileIDList,
					fo.CanShare,
					fo.DisplayFM,
					fo.DisplayFMWeb,
					fo.FieldType,
					fo.FormFieldType,
					fo.EquivalentSource,
					fod.CheckboxOnText,
					fod.CheckboxOffText,
					0
				)
		END + CASE
			WHEN @ContentIfEmpty IS NOT NULL THEN ',''' + REPLACE(@ContentIfEmpty,'''','''''') + ''')' 
			WHEN @newContentIfEmpty IS NOT NULL THEN ',' + @newContentIfEmpty + ') AS nvarchar(max))'
			ELSE ''
		END 
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
WHERE fo.FieldID=@FieldID

RETURN @returnStr

END








GO
GRANT EXECUTE ON  [dbo].[fn_GBL_FieldOption_Display_Print] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FieldOption_Display_Print] TO [cioc_login_role]
GO
