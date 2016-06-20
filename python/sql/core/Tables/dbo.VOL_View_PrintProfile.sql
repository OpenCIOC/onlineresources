CREATE TABLE [dbo].[VOL_View_PrintProfile]
(
[VT_PF_ID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[ProfileID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_PrintProfile] ADD CONSTRAINT [PK_VOL_View_PrintProfile] PRIMARY KEY CLUSTERED  ([VT_PF_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View_PrintProfile] ADD CONSTRAINT [FK_VOL_View_PrintProfile_GBL_PrintProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[GBL_PrintProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_View_PrintProfile] ADD CONSTRAINT [FK_VOL_View_PrintProfile_VOL_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[VOL_View] ([ViewType]) ON DELETE CASCADE
GO
