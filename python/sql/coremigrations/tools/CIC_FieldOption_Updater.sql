DECLARE @ClearUnmatchedFields bit

SET @ClearUnmatchedFields = 0

DECLARE @FieldOption TABLE (
	[FieldID] [int],
	[FieldName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI,
	[FieldType] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AI,
	[FormFieldType] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI,
	[EquivalentSource] [bit],
	[MaxLength] [int],
	[DisplayFM] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI,
	[DisplayFMWeb] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI,
	[UpdateFieldList] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI,
	[FeedbackFieldList] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI,
	[UseDisplayForFeedback] [bit],
	[UseDisplayForMailForm] [bit],
	[CanUseResults] [bit],
	[CanUseSearch] [bit],
	[ChecklistSearch] [varchar](4),
	[CanUseDisplay] [bit],
	[CanUseUpdate] [bit],
	[CanUseIndex] [bit],
	[CanUseFeedback] [bit],
	[CanUsePrivacy] [bit],
	[CanUseExport] [bit],
	[CheckMultiLine] [bit],
	[CheckHTML] [bit],
	[ValidateType] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI,
	[AllowNulls] [bit],
	[CannotRequire] [bit],
	[ChangeHistory] [tinyint],
	[ExtraFieldType] [char](1),
	[FullTextIndex] [bit],
	[MemberSpecific] [bit],
	[CanShare] [bit]
)

DECLARE @FieldOption_Description TABLE (
	[FieldID] [int],
	[LangID] [smallint],
	[FieldDisplay] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI,
	[CheckboxOnText] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI,
	[CheckboxOffText] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI
)

DECLARE @UnmatchedFields TABLE (
	[FieldName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI
)

DECLARE @NewFields TABLE (
	[FieldName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI
)

DECLARE @ChangedFields TABLE (
	[FieldID] [int],
	[AuthFieldID] [int],
	[FieldName] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI
)

INSERT INTO @FieldOption
SELECT 	[FieldID],
		[FieldName],
		[FieldType],
		[FormFieldType],
		[EquivalentSource],
		[MaxLength],
		[DisplayFM],
		[DisplayFMWeb],
		[UpdateFieldList],
		[FeedbackFieldList],
		[UseDisplayForFeedback],
		[UseDisplayForMailForm],
		[CanUseResults],
		[CanUseSearch],
		[CheckListSearch],
		[CanUseDisplay],
		[CanUseUpdate],
		[CanUseIndex],
		[CanUseFeedback],
		[CanUsePrivacy],
		[CanUseExport],
		[CheckMultiLine],
		[CheckHTML],
		[ValidateType],
		[AllowNulls],
		[CannotRequire],
		[ChangeHistory],
		[ExtraFieldType],
		[FullTextIndex],
		[MemberSpecific],
		[CanShare]
	FROM cioc_setup_source.dbo.GBL_FieldOption
WHERE PB_ID IS NULL AND (ExtraFieldType IS NULL)

INSERT INTO @FieldOption_Description
SELECT fod.[FieldID],[LangID],[FieldDisplay],[CheckboxOnText],[CheckboxOffText]
	FROM cioc_setup_source.dbo.GBL_FieldOption_Description fod
	INNER JOIN cioc_setup_source.dbo.GBL_FieldOption fo
		ON fod.FieldID=fo.FieldID
WHERE fo.PB_ID IS NULL AND (fo.ExtraFieldType IS NULL)

SELECT COUNT(*) AS TOTAL_AUTH_FIELDS FROM @FieldOption

INSERT INTO @UnmatchedFields
SELECT FieldName FROM GBL_FieldOption fo
	WHERE PB_ID IS NULL AND (ExtraFieldType IS NULL) AND NOT EXISTS(SELECT * FROM @FieldOption WHERE FieldName=fo.FieldName COLLATE Latin1_General_100_CI_AI)

IF @ClearUnmatchedFields=1 BEGIN
	DELETE fo
	FROM GBL_FieldOption fo
		WHERE EXISTS(SELECT * FROM @UnmatchedFields WHERE FieldName=fo.FieldName COLLATE Latin1_General_100_CI_AI)
END

SELECT FieldName AS UNMATCHED_FIELD FROM @UnmatchedFields

INSERT INTO @NewFields
SELECT FieldName FROM @FieldOption fou WHERE NOT EXISTS(SELECT * FROM GBL_FieldOption WHERE FieldName=fou.FieldName COLLATE Latin1_General_100_CI_AI)

SELECT FieldName AS NEW_FIELD FROM @NewFields

INSERT INTO GBL_FieldOption (FieldName,CREATED_DATE,CREATED_BY)
	SELECT FieldName,GETDATE(),'(Software Update)' FROM @NewFields

INSERT INTO @ChangedFields (FieldID,AuthFieldID,FieldName)
SELECT DISTINCT fo.FieldID,fou.FieldID,fo.FieldName
	FROM GBL_FieldOption fo
	LEFT JOIN GBL_FieldOption_Description fod
		ON fo.FieldID=fod.FieldID
	INNER JOIN @FieldOption fou
		ON fo.FieldName=fou.FieldName COLLATE Latin1_General_100_CI_AI
	LEFT JOIN @FieldOption_Description foud
		ON fou.FieldID=foud.FieldID AND foud.LangID=fod.LangID
	WHERE PB_ID IS NULL AND (fo.ExtraFieldType IS NULL) AND (
		NOT ((fo.FieldType=fou.FieldType COLLATE Latin1_General_100_CI_AI) OR (fo.FieldType IS NULL AND fou.FieldType IS NULL))
		OR NOT ((fo.FormFieldType=fou.FormFieldType COLLATE Latin1_General_100_CI_AI) OR (fo.FormFieldType IS NULL AND fou.FormFieldType IS NULL))
		OR NOT ((fo.EquivalentSource=fou.EquivalentSource) OR (fo.EquivalentSource IS NULL AND fou.EquivalentSource IS NULL))
		--OR NOT ((fo.MaxLength=fou.MaxLength) OR (fo.MaxLength IS NULL AND fou.MaxLength IS NULL))
		OR fo.DisplayFM<>fou.DisplayFM  COLLATE Latin1_General_100_CI_AI OR (fo.DisplayFM IS NULL AND fou.DisplayFM IS NOT NULL) OR (fo.DisplayFM IS NOT NULL AND fou.DisplayFM IS NULL)
		OR fo.DisplayFMWeb<>fou.DisplayFMWeb COLLATE Latin1_General_100_CI_AI OR (fo.DisplayFMWeb IS NULL AND fou.DisplayFMWeb IS NOT NULL) OR (fo.DisplayFMWeb IS NOT NULL AND fou.DisplayFMWeb IS NULL)
		OR NOT ((fo.UpdateFieldList=fou.UpdateFieldList COLLATE Latin1_General_100_CI_AI) OR (fo.UpdateFieldList IS NULL AND fou.UpdateFieldList IS NULL))
		OR NOT ((fo.FeedbackFieldList=fou.FeedbackFieldList COLLATE Latin1_General_100_CI_AI) OR (fo.FeedbackFieldList IS NULL AND fou.FeedbackFieldList IS NULL))
		OR NOT ((fo.UseDisplayForFeedback=fou.UseDisplayForFeedback) OR (fo.UseDisplayForFeedback IS NULL AND fou.UseDisplayForFeedback IS NULL))
		OR NOT ((fo.UseDisplayForMailForm=fou.UseDisplayForMailForm) OR (fo.UseDisplayForMailForm IS NULL AND fou.UseDisplayForMailForm IS NULL))
		OR NOT ((fo.CanUseResults=fou.CanUseResults) OR (fo.CanUseResults IS NULL AND fou.CanUseResults IS NULL))
		OR NOT ((fo.CanUseSearch=fou.CanUseSearch) OR (fo.CanUseSearch IS NULL AND fou.CanUseSearch IS NULL))
		OR fo.ChecklistSearch<>fou.ChecklistSearch OR (fo.ChecklistSearch IS NULL AND fou.ChecklistSearch IS NOT NULL) OR (fo.ChecklistSearch IS NOT NULL AND fou.ChecklistSearch IS NULL)
		OR NOT ((fo.CanUseDisplay=fou.CanUseDisplay) OR (fo.CanUseDisplay IS NULL AND fou.CanUseDisplay IS NULL))
		OR NOT ((fo.CanUseUpdate=fou.CanUseUpdate) OR (fo.CanUseUpdate IS NULL AND fou.CanUseUpdate IS NULL))
		OR NOT ((fo.CanUseIndex=fou.CanUseIndex) OR (fo.CanUseIndex IS NULL AND fou.CanUseIndex IS NULL))
		OR NOT ((fo.CanUseFeedback=fou.CanUseFeedback) OR (fo.CanUseFeedback IS NULL AND fou.CanUseFeedback IS NULL))
		OR NOT ((fo.CanUsePrivacy=fou.CanUsePrivacy) OR (fo.CanUsePrivacy IS NULL AND fou.CanUsePrivacy IS NULL))
		OR NOT ((fo.CanUseExport=fou.CanUseExport) OR (fo.CanUseExport IS NULL AND fou.CanUseExport IS NULL))
		OR NOT ((fo.CheckMultiLine=fou.CheckMultiLine) OR (fo.CheckMultiLine IS NULL AND fou.CheckMultiLine IS NULL))
		OR NOT ((fo.CheckHTML=fou.CheckHTML) OR (fo.CheckHTML IS NULL AND fou.CheckHTML IS NULL))
		OR NOT ((fo.ValidateType=fou.ValidateType COLLATE Latin1_General_100_CI_AI) OR (fo.ValidateType IS NULL AND fou.ValidateType IS NULL))
		OR NOT ((fo.CannotRequire=fou.CannotRequire) OR (fo.CannotRequire IS NULL AND fou.CannotRequire IS NULL))
		OR NOT ((fo.ChangeHistory=fou.ChangeHistory) OR (fo.ChangeHistory IS NULL AND fou.ChangeHistory IS NULL))
		OR NOT ((fo.ExtraFieldType=fou.ExtraFieldType) OR (fo.ExtraFieldType IS NULL AND fou.ExtraFieldType IS NULL))
		OR NOT ((fo.FullTextIndex=fou.FullTextIndex) OR (fo.FullTextIndex IS NULL AND fou.FullTextIndex IS NULL))
		OR NOT ((fo.MemberSpecific=fou.MemberSpecific) OR (fo.MemberSpecific IS NULL AND fou.MemberSpecific IS NULL))
		OR NOT ((fo.CanShare=fou.CanShare) OR (fo.CanShare IS NULL AND fou.CanShare IS NULL))
		OR NOT ((fod.CheckboxOnText=foud.CheckboxOnText COLLATE Latin1_General_100_CI_AI) OR (fod.CheckboxOnText IS NULL AND foud.CheckboxOnText IS NULL))
		OR NOT ((fod.CheckboxOffText=foud.CheckboxOffText COLLATE Latin1_General_100_CI_AI) OR (fod.CheckboxOffText IS NULL AND foud.CheckboxOffText IS NULL))
		OR (fod.FieldDisplay IS NULL AND foud.FieldDisplay IS NOT NULL)
		)
ORDER BY fo.FieldName

UPDATE fo SET
		MODIFIED_BY = '(Software Update)',
		MODIFIED_DATE = GETDATE(),
		FieldType=fou.FieldType,
		FormFieldType=fou.FormFieldType,
		EquivalentSource=fou.EquivalentSource,
		--MaxLength=fou.MaxLength,
		DisplayFM=fou.DisplayFM,
		DisplayFMWeb=fou.DisplayFMWeb,
		UpdateFieldList=fou.UpdateFieldList,
		FeedbackFieldList=fou.FeedbackFieldList,
		UseDisplayForFeedback=fou.UseDisplayForFeedback,
		UseDisplayForMailForm=fou.UseDisplayForMailForm,
		CanUseResults=fou.CanUseResults,
		CanUseSearch=fou.CanUseSearch,
		ChecklistSearch=fou.ChecklistSearch,
		CanUseDisplay=fou.CanUseDisplay,
		CanUseUpdate=fou.CanUseUpdate,
		CanUseIndex=fou.CanUseIndex,
		CanUseFeedback=fou.CanUseFeedback,
		CanUsePrivacy=fou.CanUsePrivacy,
		CanUseExport=fou.CanUseExport,
		CheckMultiLine=fou.CheckMultiLine,
		CheckHTML=fou.CheckHTML,
		ValidateType=fou.ValidateType,
		CannotRequire=fou.CannotRequire,
		ChangeHistory=fou.ChangeHistory,
		ExtraFieldType=fou.ExtraFieldType,
		FullTextIndex=fou.FullTextIndex,
		MemberSpecific=fou.MemberSpecific,
		CanShare=fou.CanShare
	FROM GBL_FieldOption fo
	INNER JOIN @ChangedFields cf
		ON fo.FieldID=cf.FieldID
	INNER JOIN @FieldOption fou
		ON cf.AuthFieldID=fou.FieldID

INSERT INTO GBL_FieldOption_Description (FieldID,LangID,CREATED_DATE,CREATED_BY)
SELECT cf.FieldID, foud.LangID, GETDATE(), '(Software Update)'
	FROM @FieldOption_Description foud
	INNER JOIN @ChangedFields cf
		ON foud.FieldID=cf.AuthFieldID
WHERE NOT EXISTS(SELECT * FROM GBL_FieldOption_Description WHERE FieldID=cf.FieldID AND LangID=foud.LangID)

UPDATE fod SET
		MODIFIED_BY = '(Software Update)',
		MODIFIED_DATE = GETDATE(),
		FieldDisplay = ISNULL(fod.FieldDisplay,foud.FieldDisplay),
		CheckboxOnText = foud.CheckboxOnText,
		CheckboxOffText = foud.CheckboxOffText
	FROM GBL_FieldOption_Description fod
	INNER JOIN @ChangedFields cf
		ON fod.FieldID=cf.FieldID
	INNER JOIN @FieldOption_Description foud
		ON cf.AuthFieldID=foud.FieldID AND fod.LangID=foud.LangID

UPDATE fod SET
		FieldDisplay = foud.FieldDisplay
	FROM GBL_FieldOption_Description fod
	INNER JOIN @ChangedFields cf
		ON fod.FieldID=cf.FieldID
	INNER JOIN @FieldOption_Description foud
		ON cf.AuthFieldID=foud.FieldID AND fod.LangID=foud.LangID AND foud.FieldDisplay IS NULL AND fod.FieldDisplay IS NOT NULL


SELECT FieldName AS CHANGED_FIELD FROM @ChangedFields

EXEC sp_STP_RegenerateUserFields 1
