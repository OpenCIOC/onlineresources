CREATE TABLE [dbo].[VOL_OP_SharingProfile_Revoked]
(
[OP_ShareProfile_ID] [int] NOT NULL,
[RevokedDate] [smalldatetime] NOT NULL,
[RevokedBy] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_OP_SharingProfile_Revoked] ADD CONSTRAINT [PK_VOL_OP_SharingProfile_Revoked] PRIMARY KEY CLUSTERED  ([OP_ShareProfile_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_OP_SharingProfile_Revoked] ADD CONSTRAINT [FK_VOL_OP_SharingProfile_Revoked_VOL_OP_SharingProfile] FOREIGN KEY ([OP_ShareProfile_ID]) REFERENCES [dbo].[VOL_OP_SharingProfile] ([OP_ShareProfile_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_OP_SharingProfile_Revoked] ADD CONSTRAINT [FK_VOL_OP_SharingProfile_Revoked_GBL_Users] FOREIGN KEY ([RevokedBy]) REFERENCES [dbo].[GBL_Users] ([User_ID])
GO
