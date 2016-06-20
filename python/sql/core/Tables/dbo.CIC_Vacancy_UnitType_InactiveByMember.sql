CREATE TABLE [dbo].[CIC_Vacancy_UnitType_InactiveByMember]
(
[VUT_ID] [int] NOT NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Vacancy_UnitType_InactiveByMember] ADD CONSTRAINT [PK_CIC_Vacancy_UnitType_InactiveByMember] PRIMARY KEY CLUSTERED  ([VUT_ID], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Vacancy_UnitType_InactiveByMember] ADD CONSTRAINT [FK_CIC_Vacancy_UnitType_InactiveByMember_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CIC_Vacancy_UnitType_InactiveByMember] ADD CONSTRAINT [FK_CIC_Vacancy_UnitType_InactiveByMember_CIC_Vacancy_UnitType] FOREIGN KEY ([VUT_ID]) REFERENCES [dbo].[CIC_Vacancy_UnitType] ([VUT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_Vacancy_UnitType_InactiveByMember] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Vacancy_UnitType_InactiveByMember] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Vacancy_UnitType_InactiveByMember] TO [cioc_login_role]
GO
