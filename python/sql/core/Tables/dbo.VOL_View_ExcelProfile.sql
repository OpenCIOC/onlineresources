CREATE TABLE [dbo].[VOL_View_ExcelProfile]
(
[VT_PF_ID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[ProfileID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_ExcelProfile] ADD CONSTRAINT [PK_VOL_View_ExcelProfile] PRIMARY KEY CLUSTERED  ([VT_PF_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_ExcelProfile] ADD CONSTRAINT [FK_VOL_View_ExcelProfile_GBL_ExcelProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[GBL_ExcelProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_View_ExcelProfile] WITH NOCHECK ADD CONSTRAINT [FK_VOL_View_ExcelProfile_VOL_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[VOL_View] ([ViewType]) ON DELETE CASCADE
GO
