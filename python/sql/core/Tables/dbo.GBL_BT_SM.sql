CREATE TABLE [dbo].[GBL_BT_SM]
(
[BT_SM_ID] [int] NOT NULL IDENTITY(1, 1),
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[SM_ID] [int] NOT NULL,
[Protocol] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL CONSTRAINT [DF_GBL_BT_SM_Protocol] DEFAULT ('http://'),
[URL] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BT_SM] ADD CONSTRAINT [PK_GBL_BT_SM] PRIMARY KEY CLUSTERED  ([BT_SM_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_BT_SM_UniqueType] ON [dbo].[GBL_BT_SM] ([NUM], [LangID], [SM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BT_SM] ADD CONSTRAINT [FK_GBL_BT_SM_GBL_BaseTable] FOREIGN KEY ([NUM]) REFERENCES [dbo].[GBL_BaseTable] ([NUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_BT_SM] ADD CONSTRAINT [FK_GBL_BT_SM_GBL_SocialMedia] FOREIGN KEY ([SM_ID]) REFERENCES [dbo].[GBL_SocialMedia] ([SM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_BT_SM] ADD CONSTRAINT [FK_GBL_BT_SM_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[GBL_BT_SM] TO [cioc_cic_search_role]
GO
GRANT DELETE ON  [dbo].[GBL_BT_SM] TO [cioc_login_role]
GO
GRANT INSERT ON  [dbo].[GBL_BT_SM] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[GBL_BT_SM] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[GBL_BT_SM] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[GBL_BT_SM] TO [cioc_vol_search_role]
GO
