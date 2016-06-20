CREATE TABLE [dbo].[CIC_Vacancy_UnitType]
(
[VUT_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_CIC_Vacancy_UnitType_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Vacancy_UnitType] ADD CONSTRAINT [PK_CIC_Vacancy_UnitType] PRIMARY KEY CLUSTERED  ([VUT_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Vacancy_UnitType] ADD CONSTRAINT [FK_CIC_Vacancy_UnitType_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_Vacancy_UnitType] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Vacancy_UnitType] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Vacancy_UnitType] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Vacancy_UnitType] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_Vacancy_UnitType] TO [cioc_login_role]
GO
