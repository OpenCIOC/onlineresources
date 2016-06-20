SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_CustomField_s]
	@IdList [varchar](max),
	@ViewType [int],
	@LoggedIn bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 12-Apr-2012
	Action:	NO ACTION REQUIRED
*/

DECLARE @MemberID int,
		@RespectPrivacyProfile bit

SELECT	@MemberID=MemberID,
		@RespectPrivacyProfile=RespectPrivacyProfile
	FROM CIC_View
WHERE ViewType=@ViewType

IF @LoggedIn=0 BEGIN
	SET @RespectPrivacyProfile = 1
END ELSE IF @RespectPrivacyProfile=0
		AND EXISTS(SELECT * FROM GBL_SharingProfile WHERE ShareMemberID=@MemberID AND CanViewPrivate=0) BEGIN
	SET @RespectPrivacyProfile = NULL
END

DECLARE	@tmpFlds TABLE(FieldID int)

DECLARE	@siteAddressID int
IF EXISTS(SELECT * FROM CIC_View_DisplayFieldGroup gp
				INNER JOIN CIC_View_DisplayField fd
					ON gp.DisplayFieldGroupID = fd.DisplayFieldGroupID
				INNER JOIN GBL_FieldOption fo
					ON fd.FieldID=fo.FieldID
				WHERE ViewType = @ViewType AND fo.FieldName='SITE_ADDRESS_MAPPED') BEGIN
	SELECT @siteAddressID=FieldID FROM GBL_FieldOption WHERE FieldName='SITE_ADDRESS'
END

INSERT INTO @tmpFlds SELECT DISTINCT tm.*
	FROM dbo.fn_GBL_ParseIntIDList(@IdList,',') tm
	INNER JOIN GBL_FieldOption fo ON tm.ItemID = fo.FieldID

UPDATE tm
	SET FieldID = (SELECT FieldID FROM GBL_FieldOption WHERE FieldName='SITE_ADDRESS')
	FROM @tmpFlds tm
	INNER JOIN GBL_FieldOption fo
		ON tm.FieldID = fo.FieldID
	WHERE fo.FieldName='SITE_ADDRESS_MAPPED'

SELECT	fo.FieldID,
		fo.FieldName,
		fo.CheckMultiline,
		fo.CheckHTML,
		fo.FormFieldType,
		dbo.fn_GBL_FieldOption_Display(
					@MemberID,
					@ViewType,
					fo.FieldID,
					fo.FieldName,
					@RespectPrivacyProfile,
					fo.PrivacyProfileIDList,
					CASE WHEN NOT EXISTS(SELECT * FROM GBL_BT_SharingProfile WHERE ShareMemberID_Cache=@MemberID) THEN 0 ELSE fo.CanShare END,
					fo.DisplayFM,
					fo.DisplayFMWeb,
					fo.FieldType,
					fo.FormFieldType,
					fo.EquivalentSource,
					fod.CheckboxOnText,
					fod.CheckboxOffText,
				0
		) AS FieldSelect,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN @tmpFlds tm
		ON fo.FieldID=tm.FieldID
WHERE (CanUseDisplay = 0 OR ValidateType = 'd'
		OR fo.FieldID=@siteAddressID
		OR EXISTS(SELECT * FROM CIC_View_DisplayFieldGroup gp
				INNER JOIN CIC_View_DisplayField fd
					ON gp.DisplayFieldGroupID = fd.DisplayFieldGroupID
				WHERE ViewType=@ViewType AND fd.FieldID=fo.FieldID))
ORDER BY DisplayOrder

SET NOCOUNT OFF




GO
GRANT EXECUTE ON  [dbo].[sp_CIC_View_CustomField_s] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[sp_CIC_View_CustomField_s] TO [cioc_login_role]
GO
