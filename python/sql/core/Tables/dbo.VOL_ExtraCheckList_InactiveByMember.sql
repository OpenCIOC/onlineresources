CREATE TABLE [dbo].[VOL_ExtraCheckList_InactiveByMember]
(
[EXC_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_ExtraCheckList_InactiveByMember] ADD CONSTRAINT [PK_VOL_ExtraCheckList_InactiveByMember] PRIMARY KEY CLUSTERED  ([EXC_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_ExtraCheckList_InactiveByMember] ADD CONSTRAINT [FK_VOL_ExtraCheckList_InactiveByMember_VOL_ExtraCheckList] FOREIGN KEY ([EXC_ID]) REFERENCES [dbo].[VOL_ExtraCheckList] ([EXC_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_ExtraCheckList_InactiveByMember] ADD CONSTRAINT [FK_VOL_ExtraCheckList_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[VOL_ExtraCheckList_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_ExtraCheckList_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_ExtraCheckList_InactiveByMember] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_ExtraCheckList_InactiveByMember] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_ExtraCheckList_InactiveByMember] TO [cioc_vol_search_role]
GO
