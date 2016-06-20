CREATE TABLE [dbo].[THS_Subject_Name]
(
[TermLangID] [int] NOT NULL IDENTITY(1, 1),
[Subj_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Notes] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_THS_Subject_Name_d] ON [dbo].[THS_Subject_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE sj
	FROM THS_Subject sj
	INNER JOIN Deleted d
		ON sj.Subj_ID=d.Subj_ID
	WHERE NOT EXISTS(SELECT * FROM THS_Subject_Name sjn WHERE sjn.Subj_ID=sj.Subj_ID)
		AND NOT EXISTS(SELECT * FROM CIC_BT_SBJ pr WHERE pr.Subj_ID=sj.Subj_ID)

INSERT INTO THS_Subject_Name (Subj_ID,LangID,[Name])
	SELECT d.Subj_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM THS_Subject_Name sjn WHERE sjn.Subj_ID=d.Subj_ID)
			AND EXISTS(SELECT * FROM CIC_BT_SBJ pr WHERE pr.Subj_ID=d.Subj_ID)
	
SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_THS_Subject_Name_u] ON [dbo].[THS_Subject_Name]
FOR UPDATE AS

SET NOCOUNT ON

UPDATE cbtd
	SET SRCH_Subjects_U = 1
	FROM CIC_BaseTable_Description cbtd
	INNER JOIN CIC_BT_SBJ pr
		ON cbtd.NUM=pr.NUM
	INNER JOIN Inserted i
		ON pr.Subj_ID=i.Subj_ID

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[THS_Subject_Name] ADD CONSTRAINT [PK_THS_Subject_Name] PRIMARY KEY CLUSTERED  ([TermLangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_THS_Subject_Name_UniqueName] ON [dbo].[THS_Subject_Name] ([LangID], [Name]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_THS_Subject_Name] ON [dbo].[THS_Subject_Name] ([Subj_ID], [LangID]) INCLUDE ([Name]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_144719568_3_1] ON [dbo].[THS_Subject_Name] ([LangID], [TermLangID])
GO
CREATE STATISTICS [_dta_stat_144719568_4_3_1] ON [dbo].[THS_Subject_Name] ([LangID], [TermLangID], [Name])
GO
CREATE STATISTICS [_dta_stat_144719568_2_3_1_4] ON [dbo].[THS_Subject_Name] ([Subj_ID], [LangID], [TermLangID], [Name])
GO
CREATE STATISTICS [IX_THS_Subject_Name_SubjIDName] ON [dbo].[THS_Subject_Name] ([Subj_ID], [Name])
GO
CREATE STATISTICS [_dta_stat_144719568_2_1] ON [dbo].[THS_Subject_Name] ([Subj_ID], [TermLangID])
GO
CREATE STATISTICS [_dta_stat_144719568_1_4] ON [dbo].[THS_Subject_Name] ([TermLangID], [Name])
GO
ALTER TABLE [dbo].[THS_Subject_Name] ADD CONSTRAINT [FK_THS_Subject_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[THS_Subject_Name] ADD CONSTRAINT [FK_THS_Subject_Name_THS_Subject] FOREIGN KEY ([Subj_ID]) REFERENCES [dbo].[THS_Subject] ([Subj_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[THS_Subject_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[THS_Subject_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[THS_Subject_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[THS_Subject_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[THS_Subject_Name] TO [cioc_login_role]
GO
CREATE FULLTEXT INDEX ON [dbo].[THS_Subject_Name] KEY INDEX [PK_THS_Subject_Name] ON [Thesaurus] WITH STOPLIST [CIOC_DEFAULT_STOPLIST]
GO
ALTER FULLTEXT INDEX ON [dbo].[THS_Subject_Name] ADD ([Name] LANGUAGE 0)
GO
ALTER FULLTEXT INDEX ON [dbo].[THS_Subject_Name] ADD ([Notes] LANGUAGE 0)
GO
