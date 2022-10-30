CREATE TABLE [dbo].[VOL_FieldOption_Description]
(
[FieldID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[FieldDisplay] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CheckboxOnText] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CheckboxOffText] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[HelpText] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_FieldOption_Description] ADD CONSTRAINT [PK_VOL_FieldOption_Description] PRIMARY KEY CLUSTERED ([FieldID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_FieldOption_Description] ADD CONSTRAINT [FK_VOL_FieldOption_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_FieldOption_Description] ADD CONSTRAINT [FK_VOL_FieldOption_Description_VOL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[VOL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT INSERT ON  [dbo].[VOL_FieldOption_Description] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[VOL_FieldOption_Description] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[VOL_FieldOption_Description] TO [cioc_login_role]
GO
