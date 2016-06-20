CREATE TABLE [dbo].[GBL_SharingProfile_CIC_View]
(
[ProfileID] [int] NOT NULL,
[ViewType] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SharingProfile_CIC_View] ADD CONSTRAINT [CK_GBL_SharingProfile_CIC_View_IsCIC] CHECK (([dbo].[fn_GBL_SharingProfileToDomain]([ProfileID])=(1)))
GO
ALTER TABLE [dbo].[GBL_SharingProfile_CIC_View] ADD CONSTRAINT [PK_GBL_SharingProfile_CIC_View] PRIMARY KEY CLUSTERED  ([ProfileID], [ViewType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SharingProfile_CIC_View] ADD CONSTRAINT [FK_GBL_SharingProfile_View_GBL_SharingProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[GBL_SharingProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_SharingProfile_CIC_View] ADD CONSTRAINT [FK_GBL_SharingProfile_View_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_SharingProfile_CIC_View] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_SharingProfile_CIC_View] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_SharingProfile_CIC_View] TO [cioc_vol_search_role]
GO
