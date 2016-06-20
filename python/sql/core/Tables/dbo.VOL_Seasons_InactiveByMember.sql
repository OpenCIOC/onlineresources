CREATE TABLE [dbo].[VOL_Seasons_InactiveByMember]
(
[SSN_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Seasons_InactiveByMember] ADD CONSTRAINT [PK_VOL_Seasons_InactiveByMember] PRIMARY KEY CLUSTERED  ([SSN_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Seasons_InactiveByMember] ADD CONSTRAINT [FK_VOL_Seasons_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[VOL_Seasons_InactiveByMember] ADD CONSTRAINT [FK_VOL_Seasons_InactiveByMember_VOL_Seasons] FOREIGN KEY ([SSN_ID]) REFERENCES [dbo].[VOL_Seasons] ([SSN_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Seasons_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Seasons_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_Seasons_InactiveByMember] TO [cioc_login_role]
GO
