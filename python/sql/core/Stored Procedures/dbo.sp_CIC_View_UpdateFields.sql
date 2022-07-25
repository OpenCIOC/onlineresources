SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_View_UpdateFields]
	@RSN int,
	@NUM varchar(8),
	@User_ID int,
	@ViewType int,
	@RT_ID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

DECLARE @CUR_RT_ID int, @MemberID int
SELECT	@MemberID=MemberID
	FROM dbo.CIC_View
WHERE ViewType=@ViewType

IF @NUM IS NULL BEGIN
	SELECT @NUM=NUM FROM dbo.GBL_BaseTable WHERE RSN=@RSN
END

SELECT @CUR_RT_ID = RECORD_TYPE FROM dbo.CIC_BaseTable WHERE NUM=@NUM
IF @RT_ID = -1 BEGIN
	SET @RT_ID = @CUR_RT_ID
END

IF @RT_ID IS NOT NULL BEGIN
	IF NOT EXISTS(SELECT * FROM dbo.CIC_View_UpdateField uf
		INNER JOIN dbo.CIC_View_DisplayFieldGroup fg
			ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID
		WHERE fg.ViewType=@ViewType AND uf.RT_ID=@RT_ID) BEGIN
			SET @RT_ID = NULL
	END
END

IF @CUR_RT_ID IS NOT NULL BEGIN
	IF NOT EXISTS(SELECT * FROM dbo.CIC_View_UpdateField uf
		INNER JOIN dbo.CIC_View_DisplayFieldGroup fg
			ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID
		WHERE fg.ViewType=@ViewType AND uf.RT_ID=@CUR_RT_ID) BEGIN
			SET @CUR_RT_ID = NULL
	END
END

DECLARE @makeCCR bit

SET @makeCCR = CASE
		WHEN EXISTS(SELECT * FROM dbo.CIC_View WHERE ViewType=@ViewType AND CCRFields=1) THEN 0
		WHEN NOT EXISTS(SELECT *
			FROM dbo.CIC_View_UpdateField uf
			INNER JOIN dbo.CIC_View_DisplayFieldGroup fg
				ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID
			INNER JOIN dbo.GBL_FieldOption fo
				ON uf.FieldID=fo.FieldID
			WHERE fg.ViewType=@ViewType AND fo.FieldType='CCR') THEN 0
		WHEN @RSN IS NULL AND @NUM IS NULL THEN 0
		ELSE CASE WHEN EXISTS(SELECT * FROM dbo.CCR_BaseTable ccbt INNER JOIN dbo.GBL_BaseTable bt ON bt.NUM=ccbt.NUM WHERE bt.RSN=@RSN OR ccbt.NUM=@NUM) THEN 0 ELSE 1 END
	END

SELECT @makeCCR AS makeCCR,
	deleteCCR = CASE
		WHEN NOT EXISTS(SELECT * FROM dbo.CCR_BaseTable WHERE NUM=@NUM) THEN 0
		WHEN EXISTS(SELECT * FROM dbo.CCR_BT_SCH WHERE NUM=@NUM) THEN 0
		WHEN EXISTS(SELECT * FROM dbo.CCR_BT_TOC WHERE NUM=@NUM) THEN 0
		WHEN EXISTS(SELECT * FROM dbo.CCR_BaseTable ccbt LEFT JOIN dbo.CCR_BaseTable_Description ccbtd ON ccbt.NUM=ccbtd.NUM
			WHERE ccbt.NUM=@NUM
				AND (ccbt.TYPE_OF_PROGRAM IS NOT NULL
				OR ccbtd.BEST_TIME_TO_CALL IS NOT NULL
				OR ccbtd.TYPE_OF_CARE_NOTES IS NOT NULL
				OR ccbtd.SCHOOL_ESCORT_NOTES IS NOT NULL
				OR ccbt.SUBSIDY IS NOT NULL
				OR ccbtd.SPACE_AVAILABLE_NOTES IS NOT NULL
				OR ccbt.SPACE_AVAILABLE_DATE IS NOT NULL
				OR ccbt.LICENSE_NUMBER IS NOT NULL
				OR ccbt.LICENSE_RENEWAL IS NOT NULL
				OR ccbt.LC_TOTAL IS NOT NULL
				OR ccbt.LC_INFANT IS NOT NULL
				OR ccbt.LC_TODDLER IS NOT NULL
				OR ccbt.LC_PRESCHOOL IS NOT NULL
				OR ccbt.LC_KINDERGARTEN IS NOT NULL
				OR ccbt.LC_SCHOOLAGE IS NOT NULL
				OR ccbtd.LC_NOTES IS NOT NULL))
			THEN 0
		ELSE 1
		END,
	(SELECT EnforceReqFields FROM dbo.GBL_Agency a INNER JOIN GBL_Users u ON a.AgencyCode=u.Agency AND u.User_ID=@User_ID) AS EnforceReqFields

SELECT	fg.DisplayFieldGroupID,
		fgn.Name AS DisplayFieldGroupName,
		fo.FieldName,
		fo.EquivalentSource,
		fo.ChangeHistory,
		fo.MaxLength,
		fo.FieldType,
		fo.FormFieldType,
		fo.ExtraFieldType,
		fo.ValidateType,
		fo.AllowNulls,
		fo.CanUseFeedback,
		fo.UseDisplayForFeedback,
		fod.CheckboxOnText,
		fod.CheckboxOffText,
		fo.PB_ID,
		dbo.fn_CIC_PubRelationID(@NUM, PB_ID) AS BT_PB_ID,
		ISNULL(REPLACE(REPLACE(UpdateFieldList,'[LANGID]',@@LANGID),'[MEMBER]',@MemberID), CASE
				WHEN FormFieldType = 'f' THEN NULL
				WHEN FieldType='CIC' THEN CASE WHEN EquivalentSource=1 THEN 'cbtd.' ELSE 'cbt.' END + FieldName
				WHEN FieldType='CCR' THEN CASE WHEN EquivalentSource=1 THEN 'ccbtd.' ELSE 'ccbt.' END + FieldName
				WHEN FieldType='GBL' THEN CASE WHEN EquivalentSource=1 THEN 'btd.' ELSE 'bt.' END + FieldName
			END) AS FieldSelect,
		ISNULL(FieldDisplay, FieldName) AS FieldDisplay,
		fo.WYSIWYG,
		CASE WHEN fod.HelpText IS NULL AND foh.HelpText IS NULL THEN 0 ELSE 1 END AS HasHelp
	FROM dbo.GBL_FieldOption fo
	LEFT JOIN dbo.GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID AND fod.LangID=@@LANGID
	INNER JOIN dbo.CIC_View_UpdateField uf
		ON fo.FieldID = uf.FieldID
	INNER JOIN dbo.CIC_View_DisplayFieldGroup fg
		ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID
	INNER JOIN dbo.CIC_View_DisplayFieldGroup_Name fgn
		ON fg.DisplayFieldGroupID=fgn.DisplayFieldGroupID
			AND fgn.LangID=(SELECT TOP 1 LangID FROM dbo.CIC_View_DisplayFieldGroup_Name WHERE DisplayFieldGroupID=fgn.DisplayFieldGroupID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	LEFT JOIN dbo.GBL_FieldOption_HelpByMember foh
		ON foh.FieldID = fod.FieldID AND foh.LangID = fod.LangID AND foh.MemberID=@MemberID
WHERE	(CanUseUpdate = 1) 
		AND (fg.ViewType = @ViewType)
		AND ((@RT_ID IS NULL AND uf.RT_ID IS NULL) OR (@RT_ID=uf.RT_ID))
		AND (fo.PB_ID IS NULL
				OR EXISTS(SELECT * FROM dbo.CIC_BT_PB pr WHERE pr.NUM=@NUM AND pr.PB_ID=fo.PB_ID)
				OR @NUM IS NULL AND (
					EXISTS(SELECT * FROM dbo.CIC_View vw WHERE vw.ViewType=@ViewType AND vw.PB_ID=fo.PB_ID)
					OR EXISTS(SELECT * FROM dbo.CIC_View_AutoAddPub vwa WHERE vwa.ViewType=@ViewType AND vwa.PB_ID=fo.PB_ID)
				)
			)
		AND (@makeCCR = 0 OR fo.FieldType <> 'CCR')
		AND ((@RT_ID IS NULL AND @CUR_RT_ID IS NULL) OR (@RT_ID=@CUR_RT_ID)
			OR EXISTS(SELECT * FROM dbo.CIC_View_UpdateField uf2
				INNER JOIN dbo.CIC_View_DisplayFieldGroup fg2 ON uf2.DisplayFieldGroupID=fg2.DisplayFieldGroupID
				WHERE uf2.FieldID=uf.FieldID
					AND (fg2.ViewType = @ViewType)
					AND ((@CUR_RT_ID IS NULL AND uf2.RT_ID IS NULL) OR (@CUR_RT_ID=uf2.RT_ID))
			))
ORDER BY fg.DisplayOrder, fgn.Name, fo.DisplayOrder, ISNULL(fod.FieldDisplay,fo.FieldName)

SET NOCOUNT OFF




GO



GRANT EXECUTE ON  [dbo].[sp_CIC_View_UpdateFields] TO [cioc_login_role]
GO
