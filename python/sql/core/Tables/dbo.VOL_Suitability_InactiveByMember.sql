CREATE TABLE [dbo].[VOL_Suitability_InactiveByMember]
(
[SB_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Suitability_InactiveByMember] ADD CONSTRAINT [PK_VOL_Suitability_InactiveByMember] PRIMARY KEY CLUSTERED  ([SB_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Suitability_InactiveByMember] ADD CONSTRAINT [FK_VOL_Suitability_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[VOL_Suitability_InactiveByMember] ADD CONSTRAINT [FK_VOL_Suitability_InactiveByMember_VOL_Suitability] FOREIGN KEY ([SB_ID]) REFERENCES [dbo].[VOL_Suitability] ([SB_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Suitability_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Suitability_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_Suitability_InactiveByMember] TO [cioc_login_role]
GO
