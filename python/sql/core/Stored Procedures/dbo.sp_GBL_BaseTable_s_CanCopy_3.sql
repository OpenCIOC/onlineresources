SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_BaseTable_s_CanCopy_3]
	@NUM varchar(8),
	@ViewType int,
	@RT_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: CL
	Checked on: 8-Oct-2013
	Action: NO ACTION REQUIRED
*/

DECLARE @MemberID int,
		@BTMemberID int,
		@RespectPrivacyProfile bit,
		@ProfileID	int

SELECT	@MemberID=MemberID,
		@RespectPrivacyProfile=RespectPrivacyProfile
	FROM CIC_View
WHERE ViewType=@ViewType

SELECT @BTMemberID=MemberID, @ProfileID = PRIVACY_PROFILE
	FROM GBL_BaseTable bt
WHERE bt.NUM=@NUM

SET @RespectPrivacyProfile=CASE
		WHEN @ProfileID IS NULL THEN 0
		WHEN (@BTMemberID=@MemberID
				OR EXISTS(SELECT *
					FROM GBL_BT_SharingProfile shpr
					INNER JOIN GBL_SharingProfile shp
						ON shpr.ProfileID=shp.ProfileID
					WHERE NUM=@NUM
						AND ShareMemberID_Cache=@MemberID
						AND shp.CanViewPrivate=1)
				)
			AND @RespectPrivacyProfile=0 THEN 0
		ELSE 1
	END

DECLARE @SQLSelect nvarchar(max)		

IF @RT_ID IS NOT NULL BEGIN
	IF NOT EXISTS(SELECT * FROM CIC_View_UpdateField uf
		INNER JOIN CIC_View_DisplayFieldGroup fg
			ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID
		WHERE ViewType=@ViewType AND RT_ID=@RT_ID) BEGIN
			SET @RT_ID = NULL
	END
END

SELECT	@SQLSelect = COALESCE(@SQLSelect + ', ','') + dbo.fn_GBL_FieldOption_Display(
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
			1
		)
		FROM GBL_FieldOption fo
		LEFT JOIN GBL_FieldOption_Description fod
			ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
		WHERE	(CanUseUpdate = 1)
				AND FieldName NOT IN ('NUM','RECORD_OWNER','NON_PUBLIC','ORG_LEVEL_1','ORG_LEVEL_2','ORG_LEVEL_3','ORG_LEVEL_4','ORG_LEVEL_5','LOCATION_NAME', 'SERVICE_NAME_LEVEL_1', 'SERVICE_NAME_LEVEL_2', 'MAIN_ADDRESS')
				AND EXISTS(SELECT * FROM CIC_View_UpdateField uf
					INNER JOIN CIC_View_DisplayFieldGroup fg
						ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID
					INNER JOIN CIC_View_DisplayFieldGroup_Name fgn
						ON fg.DisplayFieldGroupID=fgn.DisplayFieldGroupID
							AND fgn.LangID=(SELECT TOP 1 LangID FROM CIC_View_DisplayFieldGroup_Name WHERE DisplayFieldGroupID=fgn.DisplayFieldGroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
					WHERE (fg.ViewType = @ViewType)
						AND (uf.RT_ID=@RT_ID OR (uf.RT_ID IS NULL AND @RT_ID IS NULL))
						AND fo.FieldID = uf.FieldID
)

IF @SQLSelect IS NOT NULL BEGIN
	EXEC ('SELECT ' + @SQLSelect + ' FROM GBL_BaseTable bt
	INNER JOIN GBL_BaseTable_Description btd ON bt.NUM=btd.NUM
		AND btd.LangID=@@LANGID
	LEFT JOIN CIC_BaseTable cbt ON bt.NUM=cbt.NUM
	LEFT JOIN CIC_BaseTable_Description cbtd ON cbt.NUM=cbtd.NUM
		AND cbtd.LangID=@@LANGID
	LEFT JOIN CCR_BaseTable ccbt ON cbt.NUM=ccbt.NUM
	LEFT JOIN CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM
		AND ccbtd.LangID=@@LANGID
	WHERE bt.NUM=''' + @NUM + '''')
END ELSE BEGIN
	SELECT NUM FROM GBL_BaseTable WHERE 0=1
END

SET NOCOUNT OFF






GO
GRANT EXECUTE ON  [dbo].[sp_GBL_BaseTable_s_CanCopy_3] TO [cioc_login_role]
GO
