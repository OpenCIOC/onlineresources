CREATE TABLE [dbo].[VOL_FieldOption]
(
[FieldID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[FieldName] [varchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[FieldType] [char] (3) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_VOL_FieldOption_FieldType] DEFAULT ('VOL'),
[FormFieldType] [char] (1) COLLATE Latin1_General_100_CI_AI NULL,
[ExtraFieldType] [char] (1) COLLATE Latin1_General_100_CI_AI NULL,
[EquivalentSource] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_FieldOption_EquivalentSource] DEFAULT ((0)),
[MaxLength] [int] NULL,
[DisplayFM] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayFMWeb] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[UpdateFieldList] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[FeedbackFieldList] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[UseDisplayForFeedback] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_FieldOption_UseDisplayForFeedback] DEFAULT ((0)),
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_VOL_Opportunity_FieldOption_DisplayOrder] DEFAULT ((0)),
[CanUseResults] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_FieldOption_CanUseResults] DEFAULT ((0)),
[CanUseSearch] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_FieldOption_CanUseSearch] DEFAULT ((0)),
[CanUseExport] [bit] NOT NULL CONSTRAINT [DF_VOL_FieldOption_CanUseExport] DEFAULT ((0)),
[CheckListSearch] [varchar] (28) COLLATE Latin1_General_100_CI_AI NULL,
[CanUseDisplay] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_FieldOption_CanUseDisplay] DEFAULT ((0)),
[CanUseUpdate] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_FieldOption_CanUseUpdate] DEFAULT ((0)),
[CanUseFeedback] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_FieldOption_CanUseFeedback] DEFAULT ((0)),
[CheckMultiLine] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_FieldOption_CheckMultiLine] DEFAULT ((0)),
[CheckHTML] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_FieldOption_CheckHTML] DEFAULT ((0)),
[ValidateType] [char] (1) COLLATE Latin1_General_100_CI_AI NULL,
[AllowNulls] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_FieldOption_AllowNulls] DEFAULT ((1)),
[FullTextIndex] [bit] NOT NULL CONSTRAINT [DF_VOL_FieldOption_FullTextIndex] DEFAULT ((0)),
[MemberSpecific] [bit] NOT NULL CONSTRAINT [DF_VOL_FieldOption_MemberSpecific] DEFAULT ((0)),
[CanShare] [bit] NOT NULL CONSTRAINT [DF_VOL_FieldOption_CanShare] DEFAULT ((0)),
[CannotRequire] [bit] NOT NULL CONSTRAINT [DF_VOL_FieldOption_CannotRequire] DEFAULT ((0)),
[ChangeHistory] [tinyint] NOT NULL CONSTRAINT [DF_VOL_FieldOption_ChangeHistory] DEFAULT ((0)),
[DevNotes] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
ALTER TABLE [dbo].[VOL_FieldOption] ADD
CONSTRAINT [FK_VOL_FieldOption_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[VOL_FieldOption] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_FieldOption] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_FieldOption] TO [cioc_vol_search_role]
GO

ALTER TABLE [dbo].[VOL_FieldOption] ADD 
CONSTRAINT [PK_VOL_Opportunity_FieldOption] PRIMARY KEY CLUSTERED  ([FieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_FieldOption] ADD CONSTRAINT [IX_VOL_Opportunity_FieldOption] UNIQUE NONCLUSTERED  ([FieldName]) ON [PRIMARY]

ALTER TABLE [dbo].[VOL_FieldOption] ADD
CONSTRAINT [CK_VOL_FieldOption_CanShare] CHECK (([CanShare]=(0) OR [MemberSpecific]=(0)))
GO
