CREATE TABLE [dbo].[GBL_PrintProfile_Fld_Type]
(
[FieldTypeID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld_Type] ADD CONSTRAINT [PK_GBL_PrintProfile_Fld_Type] PRIMARY KEY CLUSTERED  ([FieldTypeID]) ON [PRIMARY]
GO
