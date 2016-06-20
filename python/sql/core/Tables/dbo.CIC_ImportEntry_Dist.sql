CREATE TABLE [dbo].[CIC_ImportEntry_Dist]
(
[EP_ID] [int] NOT NULL IDENTITY(1, 1),
[EF_ID] [int] NOT NULL,
[DST_ID] [int] NOT NULL,
[CODE] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Dist] ADD CONSTRAINT [PK_GBL_ImportEntry_Dist] PRIMARY KEY CLUSTERED  ([EP_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Dist] ADD CONSTRAINT [IX_GBL_ImportEntry_Dist_UniquePair1] UNIQUE NONCLUSTERED  ([EP_ID], [CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Dist] ADD CONSTRAINT [IX_GBL_ImportEntry_Dist_UniquePair2] UNIQUE NONCLUSTERED  ([EP_ID], [DST_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_ImportEntry_Dist] ON [dbo].[CIC_ImportEntry_Dist] ([EP_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Dist] ADD CONSTRAINT [FK_GBL_ImportEntry_Dist_CIC_Distribution] FOREIGN KEY ([DST_ID]) REFERENCES [dbo].[CIC_Distribution] ([DST_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Dist] ADD CONSTRAINT [FK_CIC_ImportEntry_Dist_CIC_ImportEntry] FOREIGN KEY ([EF_ID]) REFERENCES [dbo].[CIC_ImportEntry] ([EF_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_ImportEntry_Dist] TO [cioc_cic_search_role]
GO
