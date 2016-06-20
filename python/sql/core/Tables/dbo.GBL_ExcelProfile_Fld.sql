CREATE TABLE [dbo].[GBL_ExcelProfile_Fld]
(
[PFLD_ID] [int] NOT NULL IDENTITY(1, 1),
[ProfileID] [int] NOT NULL,
[GBLFieldID] [int] NULL,
[VOLFieldID] [int] NULL,
[DisplayOrder] [tinyint] NULL CONSTRAINT [DF_GBL_ExcelProfile_Fld_DisplayOrder] DEFAULT ((0)),
[SortByOrder] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_ExcelProfile_Fld] ADD CONSTRAINT [CK_GBL_ExcelProfile_Fld] CHECK (([GBLFieldID] IS NOT NULL AND [VOLFieldID] IS NULL OR [VOLFieldID] IS NOT NULL AND [GBLFieldID] IS NULL))
GO
ALTER TABLE [dbo].[GBL_ExcelProfile_Fld] ADD CONSTRAINT [PK_GBL_ExcelProfile_Fld] PRIMARY KEY CLUSTERED  ([PFLD_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_ExcelProfile_Fld] ON [dbo].[GBL_ExcelProfile_Fld] ([ProfileID], [GBLFieldID], [VOLFieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_ExcelProfile_Fld] WITH NOCHECK ADD CONSTRAINT [FK_GBL_ExcelProfile_Fld_GBL_FieldOption] FOREIGN KEY ([GBLFieldID]) REFERENCES [dbo].[GBL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_ExcelProfile_Fld] WITH NOCHECK ADD CONSTRAINT [FK_GBL_ExcelProfile_Fld_GBL_ExcelProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[GBL_ExcelProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_ExcelProfile_Fld] ADD CONSTRAINT [FK_GBL_ExcelProfile_Fld_VOL_FieldOption] FOREIGN KEY ([VOLFieldID]) REFERENCES [dbo].[VOL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_ExcelProfile_Fld] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_ExcelProfile_Fld] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_ExcelProfile_Fld] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_ExcelProfile_Fld] TO [cioc_login_role]
GO
