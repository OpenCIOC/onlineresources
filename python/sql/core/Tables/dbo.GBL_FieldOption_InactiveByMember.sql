CREATE TABLE [dbo].[GBL_FieldOption_InactiveByMember]
(
[FieldID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_FieldOption_InactiveByMember] ADD CONSTRAINT [PK_GBL_FieldOption_InactiveByMember] PRIMARY KEY CLUSTERED  ([FieldID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_FieldOption_InactiveByMember] ADD CONSTRAINT [FK_GBL_FieldOption_InactiveByMember_GBL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[GBL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_FieldOption_InactiveByMember] ADD CONSTRAINT [FK_GBL_FieldOption_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
