CREATE TABLE [dbo].[CIC_View_ExportProfile]
(
[VT_PF_ID] [int] NOT NULL IDENTITY(1, 1),
[ViewType] [int] NOT NULL,
[ProfileID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_ExportProfile] ADD CONSTRAINT [PK_CIC_View_ExportProfile] PRIMARY KEY CLUSTERED  ([VT_PF_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_View_ExportProfile] ADD CONSTRAINT [FK_CIC_View_ExportProfile_CIC_ExportProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[CIC_ExportProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View_ExportProfile] WITH NOCHECK ADD CONSTRAINT [FK_CIC_View_ExportProfile_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE
GO
