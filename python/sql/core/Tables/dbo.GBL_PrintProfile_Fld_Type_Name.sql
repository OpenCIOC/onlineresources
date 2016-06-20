CREATE TABLE [dbo].[GBL_PrintProfile_Fld_Type_Name]
(
[FieldTypeID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[FieldType] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld_Type_Name] ADD CONSTRAINT [PK_GBL_PrintProfile_Fld_Type_Name] PRIMARY KEY CLUSTERED  ([FieldTypeID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld_Type_Name] ADD CONSTRAINT [FK_GBL_PrintProfile_Fld_Type_Name_GBL_PrintProfile_Fld_Type] FOREIGN KEY ([FieldTypeID]) REFERENCES [dbo].[GBL_PrintProfile_Fld_Type] ([FieldTypeID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld_Type_Name] ADD CONSTRAINT [FK_GBL_PrintProfile_Fld_Type_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
