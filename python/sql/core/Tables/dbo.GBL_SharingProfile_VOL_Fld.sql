CREATE TABLE [dbo].[GBL_SharingProfile_VOL_Fld]
(
[ProfileID] [int] NOT NULL,
[FieldID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SharingProfile_VOL_Fld] ADD CONSTRAINT [CK_GBL_SharingProfile_VOL_Fld_IsVOL] CHECK (([dbo].[fn_GBL_SharingProfileToDomain]([ProfileID])=(2)))
GO
ALTER TABLE [dbo].[GBL_SharingProfile_VOL_Fld] ADD CONSTRAINT [PK_GBL_SharingProfile_VOL_Fld] PRIMARY KEY CLUSTERED  ([ProfileID], [FieldID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SharingProfile_VOL_Fld] ADD CONSTRAINT [FK_GBL_SharingProfile_VOL_Fld_VOL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[VOL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_SharingProfile_VOL_Fld] ADD CONSTRAINT [FK_GBL_SharingProfile_VOL_Fld_GBL_SharingProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[GBL_SharingProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
