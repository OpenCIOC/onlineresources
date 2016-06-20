CREATE TABLE [dbo].[CIC_ExtraDropDown_InactiveByMember]
(
[EXD_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExtraDropDown_InactiveByMember] ADD CONSTRAINT [PK_CIC_ExtraDropDown_InactiveByMember] PRIMARY KEY CLUSTERED  ([EXD_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExtraDropDown_InactiveByMember] ADD CONSTRAINT [FK_CIC_ExtraDropDown_InactiveByMember_CIC_ExtraDropDown] FOREIGN KEY ([EXD_ID]) REFERENCES [dbo].[CIC_ExtraDropDown] ([EXD_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_ExtraDropDown_InactiveByMember] ADD CONSTRAINT [FK_CIC_ExtraDropDown_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_ExtraDropDown_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_ExtraDropDown_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_ExtraDropDown_InactiveByMember] TO [cioc_login_role]
GO
