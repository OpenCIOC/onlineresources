CREATE TABLE [dbo].[GBL_Keywords]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NULL,
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL,
[KeywordType] [char] (1) COLLATE Latin1_General_100_CI_AI NOT NULL CONSTRAINT [DF_GBL_Keywords_IsOrg] DEFAULT ('O')
) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_Keywords_Update] ON [dbo].[GBL_Keywords] ([KeywordType], [Name], [LangID], [MemberID], [NUM]) ON [PRIMARY]

GO
ALTER TABLE [dbo].[GBL_Keywords] ADD CONSTRAINT [PK_GBL_Keywords] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_Keywords] ON [dbo].[GBL_Keywords] ([ID], [LangID]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GBL_Keywords] ADD CONSTRAINT [FK_GBL_Keywords_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Keywords] ADD CONSTRAINT [FK_GBL_Keywords_GBL_BaseTable_Description] FOREIGN KEY ([NUM], [LangID]) REFERENCES [dbo].[GBL_BaseTable_Description] ([NUM], [LangID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_Keywords] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_Keywords] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_Keywords] TO [cioc_vol_search_role]
GO
CREATE FULLTEXT INDEX ON [dbo].[GBL_Keywords] KEY INDEX [PK_GBL_Keywords] ON [GBLRecord] WITH STOPLIST OFF
GO

ALTER FULLTEXT INDEX ON [dbo].[GBL_Keywords] ADD ([Name] LANGUAGE 0)
GO
