SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_View_CustomField_s]
	@IdList varchar(max),
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Mar-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE @MemberID int
SELECT @MemberID=MemberID FROM VOL_View WHERE ViewType=@ViewType

DECLARE	@tmpFlds TABLE(FieldID int)

INSERT INTO @tmpFlds SELECT DISTINCT tm.*
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
	INNER JOIN VOL_FieldOption fo ON tm.ItemID = fo.FieldID

SELECT	fo.FieldID,
		fo.FieldName,
		fo.CheckMultiline,
		fo.CheckHTML,
		fo.FormFieldType,
		dbo.fn_VOL_FieldOption_Display(
				@MemberID,
				@ViewType,
				fo.FieldID,
				fo.FieldName,
				CASE WHEN NOT EXISTS(SELECT * FROM VOL_OP_SharingProfile WHERE ShareMemberID_Cache=@MemberID) THEN 0 ELSE fo.CanShare END,
				fo.DisplayFM,
				fo.FormFieldType,
				fo.EquivalentSource,
				fod.CheckboxOnText,
				fod.CheckboxOffText,
				0
			) AS FieldSelect,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay
	FROM VOL_FieldOption fo
	LEFT JOIN VOL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN @tmpFlds tm
		ON fo.FieldID=tm.FieldID
WHERE (CanUseDisplay = 0 OR ValidateType = 'd'
		OR EXISTS(SELECT * FROM VOL_View_DisplayField fd
				WHERE ViewType=@ViewType AND fd.FieldID=fo.FieldID))
ORDER BY DisplayOrder

SET NOCOUNT OFF






GO
GRANT EXECUTE ON  [dbo].[sp_VOL_View_CustomField_s] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[sp_VOL_View_CustomField_s] TO [cioc_vol_search_role]
GO
