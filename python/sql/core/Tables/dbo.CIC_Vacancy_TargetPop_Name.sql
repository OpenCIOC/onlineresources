CREATE TABLE [dbo].[CIC_Vacancy_TargetPop_Name]
(
[VTP_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_Vacancy_TargetPop_Name_d] ON [dbo].[CIC_Vacancy_TargetPop_Name]
FOR DELETE AS

SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jun-2012
	Action: NO ACTION REQUIRED
*/

DELETE vtp
	FROM CIC_Vacancy_TargetPop vtp
	INNER JOIN Deleted d
		ON vtp.VTP_ID=d.VTP_ID
	WHERE NOT EXISTS(SELECT * FROM CIC_Vacancy_TargetPop_Name vtpn WHERE vtpn.VTP_ID=vtp.VTP_ID)
		AND NOT EXISTS(SELECT * FROM CIC_BT_VUT_TP pr WHERE pr.VTP_ID=vtp.VTP_ID)

INSERT INTO CIC_Vacancy_TargetPop_Name (VTP_ID,LangID,[Name])
	SELECT d.VTP_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM CIC_Vacancy_TargetPop_Name vtpn WHERE vtpn.VTP_ID=d.VTP_ID)
			AND EXISTS(SELECT * FROM CIC_BT_VUT_TP pr WHERE pr.VTP_ID=d.VTP_ID)
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CIC_Vacancy_TargetPop_Name] ADD CONSTRAINT [PK_CIC_Vacancy_TargetPop_Name] PRIMARY KEY CLUSTERED  ([VTP_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_Vacancy_TargetPop_Name_UniqueName] ON [dbo].[CIC_Vacancy_TargetPop_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Vacancy_TargetPop_Name] ADD CONSTRAINT [FK_CIC_Vacancy_TargetPop_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CIC_Vacancy_TargetPop_Name] ADD CONSTRAINT [FK_CIC_Vacancy_TargetPop_Name_CIC_Vacancy_TargetPop] FOREIGN KEY ([VTP_ID]) REFERENCES [dbo].[CIC_Vacancy_TargetPop] ([VTP_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_Vacancy_TargetPop_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Vacancy_TargetPop_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Vacancy_TargetPop_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Vacancy_TargetPop_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_Vacancy_TargetPop_Name] TO [cioc_login_role]
GO
