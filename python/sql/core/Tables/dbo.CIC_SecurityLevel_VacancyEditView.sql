CREATE TABLE [dbo].[CIC_SecurityLevel_VacancyEditView]
(
[SL_ID] [int] NOT NULL,
[ViewType] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_VacancyEditView] ADD CONSTRAINT [PK_CIC_SecurityLevel_VacancyEditView] PRIMARY KEY CLUSTERED  ([SL_ID], [ViewType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_VacancyEditView] ADD CONSTRAINT [FK_CIC_SecurityLevel_VacancyEditView_CIC_SecurityLevel] FOREIGN KEY ([SL_ID]) REFERENCES [dbo].[CIC_SecurityLevel] ([SL_ID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CIC_SecurityLevel_VacancyEditView] ADD CONSTRAINT [FK_CIC_SecurityLevel_VacancyEditView_CIC_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[CIC_View] ([ViewType]) ON DELETE CASCADE
GO
