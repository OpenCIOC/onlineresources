CREATE TABLE [dbo].[GBL_Community_Type_Name]
(
[Code] [varchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL CONSTRAINT [DF_GBL_Community_Type_Name_LangID] DEFAULT ((0)),
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Article] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Simplified] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Community_Type_Name] ADD CONSTRAINT [PK_GBL_Community_Type_Name] PRIMARY KEY CLUSTERED ([Code], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Community_Type_Name] ADD CONSTRAINT [FK_GBL_Community_Type_Name_GBL_Community_Type] FOREIGN KEY ([Code]) REFERENCES [dbo].[GBL_Community_Type] ([Code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Community_Type_Name] ADD CONSTRAINT [FK_GBL_Community_Type_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
