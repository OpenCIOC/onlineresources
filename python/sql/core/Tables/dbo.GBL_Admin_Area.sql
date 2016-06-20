CREATE TABLE [dbo].[GBL_Admin_Area]
(
[AdminAreaID] [int] NOT NULL IDENTITY(1, 1),
[AreaCode] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Domain] [tinyint] NOT NULL,
[Inactive] [bit] NOT NULL CONSTRAINT [DF_GBL_Admin_Area_Inactive] DEFAULT ((0)),
[CheckListSearch] [varchar] (4) COLLATE Latin1_General_100_CI_AI NULL,
[ManageLocation] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[ManageLocationParams] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[CheckGblFieldActive] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CheckVolFieldActive] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
ALTER TABLE [dbo].[GBL_Admin_Area] ADD 
CONSTRAINT [PK_GBL_Admin_Area] PRIMARY KEY CLUSTERED  ([AdminAreaID]) ON [PRIMARY]
ALTER TABLE [dbo].[GBL_Admin_Area] ADD
CONSTRAINT [FK_GBL_FieldOption_GBL_Admin_Area] FOREIGN KEY ([CheckGblFieldActive]) REFERENCES [dbo].[GBL_FieldOption] ([FieldName]) ON DELETE CASCADE ON UPDATE CASCADE
ALTER TABLE [dbo].[GBL_Admin_Area] ADD
CONSTRAINT [FK_GBL_Admin_Area_VOL_FieldOption] FOREIGN KEY ([CheckVolFieldActive]) REFERENCES [dbo].[VOL_FieldOption] ([FieldName]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Admin_Area] ADD CONSTRAINT [CK_GBL_Admin_Area_Domain] CHECK (([Domain]>(0) AND [Domain]<=(4) OR [Domain] IS NULL))
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_Admin_Area_UniqueCode] ON [dbo].[GBL_Admin_Area] ([AreaCode], [Domain]) ON [PRIMARY]
GO
