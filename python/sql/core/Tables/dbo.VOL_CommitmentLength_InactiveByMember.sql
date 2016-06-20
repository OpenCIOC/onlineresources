CREATE TABLE [dbo].[VOL_CommitmentLength_InactiveByMember]
(
[CL_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_CommitmentLength_InactiveByMember] ADD CONSTRAINT [PK_VOL_CommitmentLength_InactiveByMember] PRIMARY KEY CLUSTERED  ([CL_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_CommitmentLength_InactiveByMember] ADD CONSTRAINT [FK_VOL_CommitmentLength_InactiveByMember_VOL_CommitmentLength] FOREIGN KEY ([CL_ID]) REFERENCES [dbo].[VOL_CommitmentLength] ([CL_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_CommitmentLength_InactiveByMember] ADD CONSTRAINT [FK_VOL_CommitmentLength_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[VOL_CommitmentLength_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_CommitmentLength_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_CommitmentLength_InactiveByMember] TO [cioc_login_role]
GO
