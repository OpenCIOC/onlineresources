CREATE TABLE [dbo].[GBL_PrintProfile_Fld_Description]
(
[PFLD_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Label] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Prefix] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[Suffix] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[ContentIfEmpty] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld_Description] ADD CONSTRAINT [PK_GBL_PrintProfile_Fld_Description] PRIMARY KEY CLUSTERED  ([PFLD_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld_Description] ADD CONSTRAINT [FK_GBL_PrintProfile_Fld_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld_Description] ADD CONSTRAINT [FK_GBL_PrintProfile_Fld_Description_GBL_PrintProfile_Fld] FOREIGN KEY ([PFLD_ID]) REFERENCES [dbo].[GBL_PrintProfile_Fld] ([PFLD_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
