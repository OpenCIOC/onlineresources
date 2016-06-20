CREATE TABLE [dbo].[VOL_SecurityLevel_SavedSearch]
(
[SL_SRCH_ID] [int] NOT NULL IDENTITY(1, 1),
[SL_ID] [int] NOT NULL,
[SSRCH_ID] [int] NOT NULL
) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_SecurityLevel_SavedSearch_UniquePair] ON [dbo].[VOL_SecurityLevel_SavedSearch] ([SL_ID], [SSRCH_ID]) ON [PRIMARY]

ALTER TABLE [dbo].[VOL_SecurityLevel_SavedSearch] ADD
CONSTRAINT [FK_VOL_SecurityLevel_SavedSearch_GBL_SavedSearch] FOREIGN KEY ([SSRCH_ID]) REFERENCES [dbo].[GBL_SavedSearch] ([SSRCH_ID])
GO
ALTER TABLE [dbo].[VOL_SecurityLevel_SavedSearch] ADD CONSTRAINT [PK_VOL_SecurityLevel_SavedSearch] PRIMARY KEY CLUSTERED  ([SL_SRCH_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_SecurityLevel_SavedSearch] WITH NOCHECK ADD CONSTRAINT [FK_VOL_SecurityLevel_SavedSearch_VOL_SecurityLevel] FOREIGN KEY ([SL_ID]) REFERENCES [dbo].[VOL_SecurityLevel] ([SL_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
