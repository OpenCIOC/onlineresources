CREATE TABLE [dbo].[VOL_Interest_InactiveByMember]
(
[AI_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Interest_InactiveByMember] ADD CONSTRAINT [PK_VOL_Interest_InactiveByMember] PRIMARY KEY CLUSTERED  ([AI_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Interest_InactiveByMember] ADD CONSTRAINT [FK_VOL_Interest_InactiveByMember_VOL_Interest] FOREIGN KEY ([AI_ID]) REFERENCES [dbo].[VOL_Interest] ([AI_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_Interest_InactiveByMember] ADD CONSTRAINT [FK_VOL_Interest_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[VOL_Interest_InactiveByMember] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Interest_InactiveByMember] TO [cioc_vol_search_role]
GO
