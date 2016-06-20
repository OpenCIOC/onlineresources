CREATE TABLE [dbo].[CIC_ExportProfile_Dist]
(
[ExportDistID] [int] NOT NULL IDENTITY(1, 1),
[ProfileID] [int] NOT NULL,
[DST_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Dist] ADD CONSTRAINT [PK_CIC_ExportProfile_Dist] PRIMARY KEY CLUSTERED  ([ExportDistID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Dist] ADD CONSTRAINT [IX_GBL_ExportProfile_Dist_UniquePair] UNIQUE NONCLUSTERED  ([ProfileID], [DST_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Dist] WITH NOCHECK ADD CONSTRAINT [FK_CIC_ExportProfile_Dist_CIC_Distribution] FOREIGN KEY ([DST_ID]) REFERENCES [dbo].[CIC_Distribution] ([DST_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Dist] WITH NOCHECK ADD CONSTRAINT [FK_CIC_ExportProfile_Dist_CIC_ExportProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[CIC_ExportProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_ExportProfile_Dist] TO [cioc_cic_search_role]
GO
