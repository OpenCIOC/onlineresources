CREATE TABLE [dbo].[GBL_FieldOption_Description]
(
[FieldID] [int] NOT NULL,
[LangID] [smallint] NOT NULL CONSTRAINT [DF_GBL_FieldOption_Description_LangID] DEFAULT ((0)),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_FieldOption_Description_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_FieldOption_Description_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[FieldDisplay] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CheckboxOnText] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[CheckboxOffText] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[HelpText] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_FieldOption_Description] ADD CONSTRAINT [PK_GBL_FieldOption_Description] PRIMARY KEY CLUSTERED  ([FieldID], [LangID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_FieldOption_Description_FieldIDLangIDInclFieldDisplay] ON [dbo].[GBL_FieldOption_Description] ([FieldID], [LangID]) INCLUDE ([FieldDisplay]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_FieldOption_Description] ADD CONSTRAINT [FK_GBL_FieldOption_Description_GBL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[GBL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_FieldOption_Description] ADD CONSTRAINT [FK_GBL_FieldOption_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[GBL_FieldOption_Description] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_FieldOption_Description] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_FieldOption_Description] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_FieldOption_Description] TO [cioc_login_role]
GO
