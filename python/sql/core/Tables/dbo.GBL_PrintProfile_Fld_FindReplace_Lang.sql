CREATE TABLE [dbo].[GBL_PrintProfile_Fld_FindReplace_Lang]
(
[PFLD_RP_ID_LN] [int] NOT NULL IDENTITY(1, 1),
[PFLD_RP_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld_FindReplace_Lang] ADD CONSTRAINT [PK_GBL_PrintProfile_Fld_FindReplace_Lang] PRIMARY KEY CLUSTERED  ([PFLD_RP_ID_LN]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_PrintProfile_Fld_FindReplace_Lang] ON [dbo].[GBL_PrintProfile_Fld_FindReplace_Lang] ([PFLD_RP_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld_FindReplace_Lang] ADD CONSTRAINT [FK_GBL_PrintProfile_Fld_FindReplace_Lang_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld_FindReplace_Lang] ADD CONSTRAINT [FK_GBL_PrintProfile_Fld_FindReplace_Lang_GBL_PrintProfile_Fld_FindReplace] FOREIGN KEY ([PFLD_RP_ID]) REFERENCES [dbo].[GBL_PrintProfile_Fld_FindReplace] ([PFLD_RP_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
