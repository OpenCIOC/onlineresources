CREATE TABLE [dbo].[CIC_SecurityLevel_VacancyEditAgency]
(
[SL_ID] [int] NOT NULL,
[AgencyCode] [char] (3) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_VacancyEditAgency] ADD CONSTRAINT [PK_CIC_SecurityLevel_VacancyEditAgency] PRIMARY KEY CLUSTERED  ([SL_ID], [AgencyCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_VacancyEditAgency] ADD CONSTRAINT [FK_CIC_SecurityLevel_VacancyEditAgency_GBL_Agency] FOREIGN KEY ([AgencyCode]) REFERENCES [dbo].[GBL_Agency] ([AgencyCode]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_VacancyEditAgency] ADD CONSTRAINT [FK_CIC_SecurityLevel_VacancyEditAgency_CIC_SecurityLevel] FOREIGN KEY ([SL_ID]) REFERENCES [dbo].[CIC_SecurityLevel] ([SL_ID]) ON DELETE CASCADE
GO
