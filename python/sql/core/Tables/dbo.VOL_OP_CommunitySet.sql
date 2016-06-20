CREATE TABLE [dbo].[VOL_OP_CommunitySet]
(
[OP_CS_ID] [int] NOT NULL IDENTITY(1, 1),
[VNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL,
[CommunitySetID] [int] NOT NULL
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_VOL_OP_CommunitySet_CommunitySetIDVNUM] ON [dbo].[VOL_OP_CommunitySet] ([CommunitySetID], [VNUM]) ON [PRIMARY]

ALTER TABLE [dbo].[VOL_OP_CommunitySet] ADD 
CONSTRAINT [PK_VOL_OP_CommunitySet] PRIMARY KEY CLUSTERED  ([OP_CS_ID]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[VOL_OP_CommunitySet] ADD CONSTRAINT [FK_VOL_OP_CommunitySet_VOL_CommunitySet] FOREIGN KEY ([CommunitySetID]) REFERENCES [dbo].[VOL_CommunitySet] ([CommunitySetID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_OP_CommunitySet] ADD CONSTRAINT [FK_VOL_OP_CommunitySet_VOL_Opportunity] FOREIGN KEY ([VNUM]) REFERENCES [dbo].[VOL_Opportunity] ([VNUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_OP_CommunitySet] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[VOL_OP_CommunitySet] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_OP_CommunitySet] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_OP_CommunitySet] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_OP_CommunitySet] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_OP_CommunitySet] TO [cioc_vol_search_role]
GO
