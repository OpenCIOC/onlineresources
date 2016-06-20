
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_IndexField_l]
	@NUM varchar(8),
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 17-Jul-2014
	Action: NO ACTION REQUIRED
*/

DECLARE @MemberID int,
		@RespectPrivacyProfile bit

SELECT	@MemberID=MemberID,
		@RespectPrivacyProfile=RespectPrivacyProfile
	FROM CIC_View
WHERE ViewType=@ViewType

IF @RespectPrivacyProfile=0
		AND EXISTS(SELECT * FROM GBL_SharingProfile WHERE ShareMemberID=@MemberID AND CanViewPrivate=0) BEGIN
	SET @RespectPrivacyProfile = NULL
END


SELECT	fo.FieldName,
		fod.LangID,
		fo.CheckMultiline, 
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay,
		dbo.fn_GBL_FieldOption_Display(
					@MemberID,
					@ViewType,
					fo.FieldID,
					fo.FieldName,
					@RespectPrivacyProfile,
					fo.PrivacyProfileIDList,
					0,
					fo.DisplayFM,
					fo.DisplayFMWeb,
					fo.FieldType,
					fo.FormFieldType,
					fo.EquivalentSource,
					fod.CheckboxOnText,
					fod.CheckboxOffText,
			1
		) AS FieldSelect
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
WHERE (CanUseIndex = 1)
	AND (EXISTS(SELECT * FROM CIC_View_DisplayFieldGroup gp
			INNER JOIN CIC_View_DisplayField fd
				ON gp.DisplayFieldGroupID = fd.DisplayFieldGroupID
			WHERE ViewType=@ViewType AND fd.FieldID=fo.FieldID)
		OR CanUseDisplay = 0
	)
	AND (
			(SELECT MemberID FROM GBL_BaseTable WHERE NUM=@NUM)=@MemberID
			OR CanShare=0
			OR EXISTS(SELECT * FROM GBL_SharingProfile shp WHERE ShareMemberID=@MemberID AND shp.Active=1
				AND (shp.CanUseAnyView=1 OR EXISTS(SELECT * FROM GBL_SharingProfile_CIC_View shpv WHERE shpv.ProfileID=shp.ProfileID AND shpv.ViewType=@ViewType))
				AND EXISTS(SELECT * FROM GBL_SharingProfile_CIC_Fld shpf WHERE shpf.ProfileID=shp.ProfileID AND shpf.FieldID=fo.FieldID)
				AND EXISTS(SELECT * FROM GBL_BT_SharingProfile shpr WHERE shpr.ProfileID=shp.ProfileID AND shpr.NUM=@NUM AND shpr.ShareMemberID_Cache=@MemberID)
			)
		)
ORDER BY ISNULL(FieldDisplay, FieldName)

SET NOCOUNT OFF




GO

GRANT EXECUTE ON  [dbo].[sp_CIC_View_IndexField_l] TO [cioc_login_role]
GO
