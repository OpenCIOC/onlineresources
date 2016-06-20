CREATE TABLE [dbo].[CIC_Vacancy_ServiceTitle_InactiveByMember]
(
[VST_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Vacancy_ServiceTitle_InactiveByMember] ADD CONSTRAINT [PK_CIC_Vacancy_ServiceTitle_InactiveByMember] PRIMARY KEY CLUSTERED  ([VST_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Vacancy_ServiceTitle_InactiveByMember] ADD CONSTRAINT [FK_CIC_Vacancy_ServiceTitle_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CIC_Vacancy_ServiceTitle_InactiveByMember] ADD CONSTRAINT [FK_CIC_Vacancy_ServiceTitle_InactiveByMember_CIC_Vacancy_ServiceTitle] FOREIGN KEY ([VST_ID]) REFERENCES [dbo].[CIC_Vacancy_ServiceTitle] ([VST_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_Vacancy_ServiceTitle_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Vacancy_ServiceTitle_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Vacancy_ServiceTitle_InactiveByMember] TO [cioc_login_role]
GO
