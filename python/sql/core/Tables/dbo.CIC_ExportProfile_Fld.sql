CREATE TABLE [dbo].[CIC_ExportProfile_Fld]
(
[ExportFieldID] [int] NOT NULL IDENTITY(1, 1),
[ProfileID] [int] NOT NULL,
[FieldID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Fld] ADD CONSTRAINT [PK_CIC_ExportProfile_Fld] PRIMARY KEY CLUSTERED  ([ExportFieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Fld] ADD CONSTRAINT [IX_GBL_ExportProfile_Fld_UniquePair] UNIQUE NONCLUSTERED  ([ProfileID], [FieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Fld] WITH NOCHECK ADD CONSTRAINT [FK_CIC_ExportProfile_Fld_GBL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[GBL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_ExportProfile_Fld] WITH NOCHECK ADD CONSTRAINT [FK_CIC_ExportProfile_Fld_CIC_ExportProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[CIC_ExportProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_ExportProfile_Fld] TO [cioc_cic_search_role]
GO
