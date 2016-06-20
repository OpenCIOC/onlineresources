CREATE TABLE [dbo].[CIC_Activity_Status_Name]
(
[ASTAT_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_Activity_Status_Name_d] ON [dbo].[CIC_Activity_Status_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE astat
	FROM CIC_Activity_Status astat
	INNER JOIN Deleted d
		ON astat.ASTAT_ID=d.ASTAT_ID
	WHERE NOT EXISTS(SELECT * FROM CIC_Activity_Status_Name astatn WHERE astatn.ASTAT_ID=astat.ASTAT_ID)
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CIC_Activity_Status_Name] ADD CONSTRAINT [PK_CIC_Activity_Status_Name] PRIMARY KEY CLUSTERED  ([ASTAT_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_Activity_Status_Name_UniqueName] ON [dbo].[CIC_Activity_Status_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Activity_Status_Name] ADD CONSTRAINT [FK_CIC_Activity_Status_Name_CIC_Activity_Status] FOREIGN KEY ([ASTAT_ID]) REFERENCES [dbo].[CIC_Activity_Status] ([ASTAT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_Activity_Status_Name] ADD CONSTRAINT [FK_CIC_Activity_Status_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_Activity_Status_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Activity_Status_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Activity_Status_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Activity_Status_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_Activity_Status_Name] TO [cioc_login_role]
GO
