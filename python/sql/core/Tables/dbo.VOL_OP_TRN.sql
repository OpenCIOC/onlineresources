CREATE TABLE [dbo].[VOL_OP_TRN]
(
[OP_TRN_ID] [int] NOT NULL IDENTITY(1, 1),
[VNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL,
[TRN_ID] [int] NOT NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[VOL_OP_TRN] ADD 
CONSTRAINT [PK_VOL_OP_TRN] PRIMARY KEY CLUSTERED  ([OP_TRN_ID]) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_OP_TRN_UniquePair] ON [dbo].[VOL_OP_TRN] ([VNUM], [TRN_ID]) ON [PRIMARY]

GO

ALTER TABLE [dbo].[VOL_OP_TRN] WITH NOCHECK ADD CONSTRAINT [FK_VOL_OP_TRN_VOL_Opportunity] FOREIGN KEY ([VNUM]) REFERENCES [dbo].[VOL_Opportunity] ([VNUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_OP_TRN] ADD CONSTRAINT [FK_VOL_OP_TRN_VOL_Training] FOREIGN KEY ([TRN_ID]) REFERENCES [dbo].[VOL_Training] ([TRN_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_OP_TRN] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_OP_TRN] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_OP_TRN] TO [cioc_vol_search_role]
GO
