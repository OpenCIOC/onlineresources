CREATE TABLE [dbo].[THS_Subject_InactiveByMember]
(
[Subj_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_Subject_InactiveByMember] ADD CONSTRAINT [PK_THS_Subject_InactiveByMember] PRIMARY KEY CLUSTERED  ([Subj_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_Subject_InactiveByMember] ADD CONSTRAINT [FK_THS_Subject_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[THS_Subject_InactiveByMember] ADD CONSTRAINT [FK_THS_Subject_InactiveByMember_THS_Subject] FOREIGN KEY ([Subj_ID]) REFERENCES [dbo].[THS_Subject] ([Subj_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[THS_Subject_InactiveByMember] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[THS_Subject_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[THS_Subject_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[THS_Subject_InactiveByMember] TO [cioc_login_role]
GO
