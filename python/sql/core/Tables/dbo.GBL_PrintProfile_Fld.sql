CREATE TABLE [dbo].[GBL_PrintProfile_Fld]
(
[PFLD_ID] [int] NOT NULL IDENTITY(1, 1),
[ProfileID] [int] NOT NULL,
[GBLFieldID] [int] NULL,
[VOLFieldID] [int] NULL,
[FieldTypeID] [int] NOT NULL,
[HeadingLevel] [tinyint] NULL,
[LabelStyle] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[ContentStyle] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Separator] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_GBL_PrintProfile_Fld_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld] ADD CONSTRAINT [CK_GBL_PrintProfile_Fld] CHECK (([GBLFieldID] IS NOT NULL AND [VOLFieldID] IS NULL OR [VOLFieldID] IS NOT NULL AND [GBLFieldID] IS NULL))
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld] ADD CONSTRAINT [PK_GBL_PrintProfile_Fld] PRIMARY KEY CLUSTERED  ([PFLD_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld] WITH NOCHECK ADD CONSTRAINT [FK_GBL_PrintProfile_Fld_GBL_PrintProfile_Fld_Type] FOREIGN KEY ([FieldTypeID]) REFERENCES [dbo].[GBL_PrintProfile_Fld_Type] ([FieldTypeID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld] WITH NOCHECK ADD CONSTRAINT [FK_GBL_PrintProfile_Fld_GBL_FieldOption] FOREIGN KEY ([GBLFieldID]) REFERENCES [dbo].[GBL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld] WITH NOCHECK ADD CONSTRAINT [FK_GBL_PrintProfile_Fld_GBL_PrintProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[GBL_PrintProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_PrintProfile_Fld] ADD CONSTRAINT [FK_GBL_PrintProfile_Fld_VOL_FieldOption] FOREIGN KEY ([VOLFieldID]) REFERENCES [dbo].[VOL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
