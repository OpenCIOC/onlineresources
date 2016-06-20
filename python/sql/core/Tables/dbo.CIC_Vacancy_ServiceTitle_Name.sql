CREATE TABLE [dbo].[CIC_Vacancy_ServiceTitle_Name]
(
[VST_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_Vacancy_ServiceTitle_Name_d] ON [dbo].[CIC_Vacancy_ServiceTitle_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE vst
	FROM CIC_Vacancy_ServiceTitle vst
	INNER JOIN Deleted d
		ON vst.VST_ID=d.VST_ID
	WHERE NOT EXISTS(SELECT * FROM CIC_Vacancy_ServiceTitle_Name vstn WHERE vstn.VST_ID=vst.VST_ID)
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CIC_Vacancy_ServiceTitle_Name] ADD CONSTRAINT [PK_CIC_Vacancy_ServiceTitle_Name] PRIMARY KEY CLUSTERED  ([VST_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_Vacancy_ServiceTitle_Name_UniqueName] ON [dbo].[CIC_Vacancy_ServiceTitle_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Vacancy_ServiceTitle_Name] ADD CONSTRAINT [FK_CIC_Vacancy_ServiceTitle_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CIC_Vacancy_ServiceTitle_Name] ADD CONSTRAINT [FK_CIC_Vacancy_ServiceTitle_Name_CIC_Vacancy_ServiceTitle] FOREIGN KEY ([VST_ID]) REFERENCES [dbo].[CIC_Vacancy_ServiceTitle] ([VST_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_Vacancy_ServiceTitle_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Vacancy_ServiceTitle_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Vacancy_ServiceTitle_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Vacancy_ServiceTitle_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_Vacancy_ServiceTitle_Name] TO [cioc_login_role]
GO
