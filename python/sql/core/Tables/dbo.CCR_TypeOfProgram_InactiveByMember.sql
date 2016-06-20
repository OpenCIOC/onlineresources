CREATE TABLE [dbo].[CCR_TypeOfProgram_InactiveByMember]
(
[TOP_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_TypeOfProgram_InactiveByMember] ADD CONSTRAINT [PK_CCR_TypeOfProgram_InactiveByMember] PRIMARY KEY CLUSTERED  ([TOP_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_TypeOfProgram_InactiveByMember] ADD CONSTRAINT [FK_CCR_TypeOfProgram_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CCR_TypeOfProgram_InactiveByMember] ADD CONSTRAINT [FK_CCR_TypeOfProgram_InactiveByMember_CCR_TypeOfProgram] FOREIGN KEY ([TOP_ID]) REFERENCES [dbo].[CCR_TypeOfProgram] ([TOP_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CCR_TypeOfProgram_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CCR_TypeOfProgram_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CCR_TypeOfProgram_InactiveByMember] TO [cioc_login_role]
GO
