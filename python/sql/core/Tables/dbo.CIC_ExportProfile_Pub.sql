CREATE TABLE [dbo].[CIC_ExportProfile_Pub]
(
[ExportPubID] [int] NOT NULL IDENTITY(1, 1),
[ProfileID] [int] NOT NULL,
[PB_ID] [int] NOT NULL,
[IncludeHeadings] [bit] NOT NULL CONSTRAINT [DF_GBL_ExportProfile_Pub_IncludeHeadings] DEFAULT ((0)),
[IncludeDescription] [bit] NOT NULL CONSTRAINT [DF_GBL_ExportProfile_Pub_IncludeDescription] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Pub] ADD CONSTRAINT [PK_CIC_ExportProfile_Pub] PRIMARY KEY CLUSTERED  ([ExportPubID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Pub] ADD CONSTRAINT [IX_CIC_ExportProfile_Pub_UniquePair] UNIQUE NONCLUSTERED  ([ProfileID], [PB_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Pub] WITH NOCHECK ADD CONSTRAINT [FK_CIC_ExportProfile_Pub_CIC_Publication] FOREIGN KEY ([PB_ID]) REFERENCES [dbo].[CIC_Publication] ([PB_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Pub] WITH NOCHECK ADD CONSTRAINT [FK_CIC_ExportProfile_Pub_CIC_ExportProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[CIC_ExportProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_ExportProfile_Pub] TO [cioc_cic_search_role]
GO
