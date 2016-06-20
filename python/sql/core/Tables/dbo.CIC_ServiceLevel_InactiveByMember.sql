CREATE TABLE [dbo].[CIC_ServiceLevel_InactiveByMember]
(
[SL_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ServiceLevel_InactiveByMember] ADD CONSTRAINT [PK_CIC_ServiceLevel_InactiveByMember] PRIMARY KEY CLUSTERED  ([SL_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ServiceLevel_InactiveByMember] ADD CONSTRAINT [FK_CIC_ServiceLevel_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CIC_ServiceLevel_InactiveByMember] ADD CONSTRAINT [FK_CIC_ServiceLevel_InactiveByMember_CIC_ServiceLevel] FOREIGN KEY ([SL_ID]) REFERENCES [dbo].[CIC_ServiceLevel] ([SL_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_ServiceLevel_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_ServiceLevel_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_ServiceLevel_InactiveByMember] TO [cioc_login_role]
GO
