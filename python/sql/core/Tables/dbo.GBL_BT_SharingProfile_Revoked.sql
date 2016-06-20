CREATE TABLE [dbo].[GBL_BT_SharingProfile_Revoked]
(
[BT_ShareProfile_ID] [int] NOT NULL,
[RevokedDate] [smalldatetime] NOT NULL,
[RevokedBy] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BT_SharingProfile_Revoked] ADD CONSTRAINT [PK_GBL_BT_SharingProfile_Revoked] PRIMARY KEY CLUSTERED  ([BT_ShareProfile_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BT_SharingProfile_Revoked] ADD CONSTRAINT [FK_GBL_BT_SharingProfile_Revoked_GBL_BT_SharingProfile] FOREIGN KEY ([BT_ShareProfile_ID]) REFERENCES [dbo].[GBL_BT_SharingProfile] ([BT_ShareProfile_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_BT_SharingProfile_Revoked] ADD CONSTRAINT [FK_GBL_BT_SharingProfile_Revoked_GBL_Users] FOREIGN KEY ([RevokedBy]) REFERENCES [dbo].[GBL_Users] ([User_ID])
GO
