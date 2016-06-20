CREATE TABLE [dbo].[GBL_BT_SharingProfile]
(
[BT_ShareProfile_ID] [int] NOT NULL IDENTITY(1, 1),
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL,
[ProfileID] [int] NOT NULL,
[ShareMemberID_Cache] [int] NOT NULL,
[CREATED_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_GBL_BT_SharingProfile_CREATED_DATE] DEFAULT (getdate())
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_GBL_BT_SharingProfile_CREATED_DATE] ON [dbo].[GBL_BT_SharingProfile] ([CREATED_DATE]) ON [PRIMARY]

GO
CREATE STATISTICS [_dta_stat_395148453_4_3] ON [dbo].[GBL_BT_SharingProfile] ([ShareMemberID_Cache], [ProfileID])

CREATE NONCLUSTERED INDEX [IX_GBL_BT_SharingProfile_ProfileIDNUM] ON [dbo].[GBL_BT_SharingProfile] ([ProfileID], [NUM]) ON [PRIMARY]

GO
ALTER TABLE [dbo].[GBL_BT_SharingProfile] ADD CONSTRAINT [CK_GBL_BT_SharingProfile_Ownership] CHECK (([dbo].[fn_GBL_NUMToMemberID]([NUM])=[dbo].[fn_GBL_SharingProfileToMemberID]([ProfileID])))
GO
ALTER TABLE [dbo].[GBL_BT_SharingProfile] ADD CONSTRAINT [PK_GBL_BT_SharingProfile] PRIMARY KEY CLUSTERED  ([BT_ShareProfile_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_BT_SharingProfile_NUMShareMemberIDInclProfileID] ON [dbo].[GBL_BT_SharingProfile] ([NUM], [ShareMemberID_Cache]) INCLUDE ([ProfileID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BT_SharingProfile] ADD CONSTRAINT [FK_GBL_BT_SharingProfile_GBL_BaseTable] FOREIGN KEY ([NUM]) REFERENCES [dbo].[GBL_BaseTable] ([NUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_BT_SharingProfile] ADD CONSTRAINT [FK_GBL_BT_SharingProfile_GBL_SharingProfile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[GBL_SharingProfile] ([ProfileID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_BT_SharingProfile] ADD CONSTRAINT [FK_GBL_BT_SharingProfile_STP_Member] FOREIGN KEY ([ShareMemberID_Cache]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[GBL_BT_SharingProfile] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_BT_SharingProfile] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_BT_SharingProfile] TO [cioc_vol_search_role]
GO
