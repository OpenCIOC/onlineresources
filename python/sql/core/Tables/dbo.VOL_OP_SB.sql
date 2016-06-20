CREATE TABLE [dbo].[VOL_OP_SB]
(
[OP_SB_ID] [int] NOT NULL IDENTITY(1, 1),
[VNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL,
[SB_ID] [int] NOT NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[VOL_OP_SB] ADD 
CONSTRAINT [PK_VOL_OP_SB] PRIMARY KEY CLUSTERED  ([OP_SB_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_OP_SB] ADD CONSTRAINT [IX_VOL_OP_SB_UniquePair] UNIQUE NONCLUSTERED  ([VNUM], [SB_ID]) ON [PRIMARY]

GO

ALTER TABLE [dbo].[VOL_OP_SB] WITH NOCHECK ADD CONSTRAINT [FK_VOL_OP_SB_VOL_Opportunity] FOREIGN KEY ([VNUM]) REFERENCES [dbo].[VOL_Opportunity] ([VNUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_OP_SB] ADD CONSTRAINT [FK_VOL_OP_SB_VOL_Suitability] FOREIGN KEY ([SB_ID]) REFERENCES [dbo].[VOL_Suitability] ([SB_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_OP_SB] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_OP_SB] TO [cioc_vol_search_role]
GO
