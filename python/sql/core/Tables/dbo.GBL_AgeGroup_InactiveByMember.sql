CREATE TABLE [dbo].[GBL_AgeGroup_InactiveByMember]
(
[AgeGroup_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_AgeGroup_InactiveByMember] ADD CONSTRAINT [PK_GBL_AgeGroup_InactiveByMember] PRIMARY KEY CLUSTERED  ([AgeGroup_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_AgeGroup_InactiveByMember] ADD CONSTRAINT [FK_GBL_AgeGroup_InactiveByMember_GBL_AgeGroup] FOREIGN KEY ([AgeGroup_ID]) REFERENCES [dbo].[GBL_AgeGroup] ([AgeGroup_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_AgeGroup_InactiveByMember] ADD CONSTRAINT [FK_GBL_AgeGroup_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[GBL_AgeGroup_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_AgeGroup_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_AgeGroup_InactiveByMember] TO [cioc_login_role]
GO
