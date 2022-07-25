CREATE TABLE [dbo].[GBL_FieldOption]
(
[FieldID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[FieldName] [varchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[FieldType] [varchar] (3) COLLATE Latin1_General_100_CI_AI NULL,
[FormFieldType] [char] (1) COLLATE Latin1_General_100_CI_AI NULL,
[ExtraFieldType] [char] (1) COLLATE Latin1_General_100_CI_AI NULL,
[EquivalentSource] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_EquivalentSource] DEFAULT ((0)),
[PB_ID] [int] NULL,
[MaxLength] [int] NULL,
[DisplayFM] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayFMWeb] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[UpdateFieldList] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[FeedbackFieldList] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[FacetFieldList] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[UseDisplayForFeedback] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_UseDisplayForFeedback] DEFAULT ((0)),
[UseDisplayForMailForm] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_UseDisplayForMailForm] DEFAULT ((0)),
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_GBL_FieldOption_DisplayOrder] DEFAULT ((0)),
[CanUseResults] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_CanUseResults] DEFAULT ((0)),
[CanUseSearch] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_CanUseSearch] DEFAULT ((0)),
[CheckListSearch] [varchar] (28) COLLATE Latin1_General_100_CI_AI NULL,
[CanUseDisplay] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_CanUseDisplay] DEFAULT ((0)),
[CanUseUpdate] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_CanUseUpdate] DEFAULT ((0)),
[CanUseIndex] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_CanUseIndex] DEFAULT ((0)),
[CanUseFeedback] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_CanUseFeedback] DEFAULT ((0)),
[CanUsePrivacy] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_CanUsePrivacy] DEFAULT ((0)),
[PrivacyProfileIDList] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CanUseExport] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_CanUseExport] DEFAULT ((0)),
[CheckMultiLine] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_CheckMultiLine] DEFAULT ((0)),
[CheckHTML] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_CheckHTML] DEFAULT ((0)),
[WYSIWYG] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_WYSIWIG] DEFAULT ((0)),
[ValidateType] [char] (1) COLLATE Latin1_General_100_CI_AI NULL,
[AllowNulls] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_AllowNulls] DEFAULT ((1)),
[FullTextIndex] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_FullTextIndex] DEFAULT ((0)),
[MemberSpecific] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_MemberSpecific] DEFAULT ((0)),
[CanShare] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_CanShare] DEFAULT ((0)),
[CannotRequire] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_CannotRequire] DEFAULT ((0)),
[ChangeHistory] [tinyint] NOT NULL CONSTRAINT [DF_GBL_FieldOption_ChangeHistory] DEFAULT ((0)),
[DevNotes] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[AIRS] [bit] NOT NULL CONSTRAINT [DF_GBL_FieldOption_AIRS] DEFAULT ((0)),
[MemberID] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_FieldOption_u] ON [dbo].[GBL_FieldOption] 
FOR UPDATE AS

SET NOCOUNT ON

IF UPDATE(FullTextIndex) BEGIN
	UPDATE btd
		SET SRCH_Anywhere_U=1
	FROM GBL_BaseTable_Description btd
	WHERE EXISTS(SELECT *
		FROM CIC_BT_EXTRA_TEXT et
		INNER JOIN Inserted i
			ON et.FieldName=i.FieldName AND i.ExtraFieldType='t'
		INNER JOIN Deleted d
			ON i.FieldID=d.FieldID AND i.FullTextIndex<>d.FullTextIndex
		WHERE et.NUM=btd.NUM AND et.LangID=btd.LangID)
END

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[GBL_FieldOption] ADD CONSTRAINT [CK_GBL_FieldOption_CanShare] CHECK (([CanShare]=(0) OR [MemberSpecific]=(0)))
GO
ALTER TABLE [dbo].[GBL_FieldOption] ADD CONSTRAINT [PK_GBL_FieldOption] PRIMARY KEY CLUSTERED ([FieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_FieldOption] ADD CONSTRAINT [IX_GBL_BaseTable_FieldName] UNIQUE NONCLUSTERED ([FieldName]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_FieldOption_FieldNameInclFieldID] ON [dbo].[GBL_FieldOption] ([FieldName]) INCLUDE ([FieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_FieldOption] WITH NOCHECK ADD CONSTRAINT [FK_GBL_FieldOption_CIC_Publication] FOREIGN KEY ([PB_ID]) REFERENCES [dbo].[CIC_Publication] ([PB_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_FieldOption] ADD CONSTRAINT [FK_GBL_FieldOption_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[GBL_FieldOption] TO [cioc_cic_search_role]
GO
GRANT SELECT ON  [dbo].[GBL_FieldOption] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[GBL_FieldOption] TO [cioc_login_role]
GO
