CREATE TABLE [dbo].[VOL_OP_SM]
(
[OP_SM_ID] [int] NOT NULL IDENTITY(1, 1),
[VNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[SM_ID] [int] NOT NULL,
[Protocol] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL CONSTRAINT [DF_VOL_OP_SM_Protocol] DEFAULT ('http://'),
[URL] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_OP_SM] ADD CONSTRAINT [PK_VOL_OP_SM] PRIMARY KEY CLUSTERED ([OP_SM_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_OP_SM_UniqueType] ON [dbo].[VOL_OP_SM] ([VNUM], [LangID], [SM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_OP_SM] ADD CONSTRAINT [FK_VOL_OP_SM_GBL_SocialMedia] FOREIGN KEY ([SM_ID]) REFERENCES [dbo].[GBL_SocialMedia] ([SM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_OP_SM] ADD CONSTRAINT [FK_VOL_OP_SM_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_OP_SM] ADD CONSTRAINT [FK_VOL_OP_SM_VOL_Opportunity] FOREIGN KEY ([VNUM]) REFERENCES [dbo].[VOL_Opportunity] ([VNUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT DELETE ON  [dbo].[VOL_OP_SM] TO [cioc_login_role]
GO
GRANT INSERT ON  [dbo].[VOL_OP_SM] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[VOL_OP_SM] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[VOL_OP_SM] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[VOL_OP_SM] TO [cioc_vol_search_role]
GO
