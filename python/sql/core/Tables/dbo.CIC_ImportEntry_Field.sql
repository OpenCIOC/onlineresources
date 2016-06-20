CREATE TABLE [dbo].[CIC_ImportEntry_Field]
(
[EFLD_ID] [int] NOT NULL IDENTITY(1, 1),
[EF_ID] [int] NOT NULL,
[FieldID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Field] ADD CONSTRAINT [PK_GBL_ImportEntry_Field] PRIMARY KEY CLUSTERED  ([EFLD_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Field] ADD CONSTRAINT [IX_GBL_ImportEntry_Field_UniquePair2] UNIQUE NONCLUSTERED  ([EFLD_ID], [FieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Field] ADD CONSTRAINT [FK_CIC_ImportEntry_Field_CIC_ImportEntry] FOREIGN KEY ([EF_ID]) REFERENCES [dbo].[CIC_ImportEntry] ([EF_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Field] ADD CONSTRAINT [FK_GBL_ImportEntry_Field_GBL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[GBL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
