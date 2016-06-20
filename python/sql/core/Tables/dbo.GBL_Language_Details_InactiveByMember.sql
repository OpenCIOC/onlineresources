CREATE TABLE [dbo].[GBL_Language_Details_InactiveByMember]
(
[LND_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Language_Details_InactiveByMember] ADD CONSTRAINT [PK_GBL_Language_Details_InactiveByMember] PRIMARY KEY CLUSTERED  ([LND_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Language_Details_InactiveByMember] ADD CONSTRAINT [FK_GBL_Language_Details_InactiveByMember_GBL_Language_Details] FOREIGN KEY ([LND_ID]) REFERENCES [dbo].[GBL_Language_Details] ([LND_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Language_Details_InactiveByMember] ADD CONSTRAINT [FK_GBL_Language_Details_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[GBL_Language_Details_InactiveByMember] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_Language_Details_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_Language_Details_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_Language_Details_InactiveByMember] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_Language_Details_InactiveByMember] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_Language_Details_InactiveByMember] TO [cioc_vol_search_role]
GO
