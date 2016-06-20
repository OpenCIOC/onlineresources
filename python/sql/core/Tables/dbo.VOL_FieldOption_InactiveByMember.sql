CREATE TABLE [dbo].[VOL_FieldOption_InactiveByMember]
(
[FieldID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_FieldOption_InactiveByMember] ADD CONSTRAINT [PK_VOL_FieldOption_InactiveByMember] PRIMARY KEY CLUSTERED  ([FieldID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_FieldOption_InactiveByMember] ADD CONSTRAINT [FK_VOL_FieldOption_InactiveByMember_VOL_FieldOption] FOREIGN KEY ([FieldID]) REFERENCES [dbo].[VOL_FieldOption] ([FieldID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_FieldOption_InactiveByMember] ADD CONSTRAINT [FK_VOL_FieldOption_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
