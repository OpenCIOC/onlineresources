CREATE TABLE [dbo].[CIC_ExtraCheckList_InactiveByMember]
(
[EXC_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[CIC_ExtraCheckList_InactiveByMember] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_ExtraCheckList_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_ExtraCheckList_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_ExtraCheckList_InactiveByMember] TO [cioc_login_role]
GO

ALTER TABLE [dbo].[CIC_ExtraCheckList_InactiveByMember] ADD CONSTRAINT [PK_CIC_ExtraCheckList_InactiveByMember] PRIMARY KEY CLUSTERED  ([EXC_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ExtraCheckList_InactiveByMember] ADD CONSTRAINT [FK_CIC_ExtraCheckList_InactiveByMember_CIC_ExtraCheckList] FOREIGN KEY ([EXC_ID]) REFERENCES [dbo].[CIC_ExtraCheckList] ([EXC_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_ExtraCheckList_InactiveByMember] ADD CONSTRAINT [FK_CIC_ExtraCheckList_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
