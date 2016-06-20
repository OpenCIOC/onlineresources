CREATE TABLE [dbo].[CIC_Publication_InactiveByMember]
(
[PB_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Publication_InactiveByMember] ADD CONSTRAINT [PK_CIC_Publication_InactiveByMember] PRIMARY KEY CLUSTERED  ([PB_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Publication_InactiveByMember] ADD CONSTRAINT [FK_CIC_Publication_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CIC_Publication_InactiveByMember] ADD CONSTRAINT [FK_CIC_Publication_InactiveByMember_CIC_Publication] FOREIGN KEY ([PB_ID]) REFERENCES [dbo].[CIC_Publication] ([PB_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
