CREATE TABLE [dbo].[CCR_TypeOfProgram_Name]
(
[TOP_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CCR_TypeOfProgram_Name_d] ON [dbo].[CCR_TypeOfProgram_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE [top]
	FROM CCR_TypeOfProgram [top]
	INNER JOIN Deleted d
		ON [top].TOP_ID=d.TOP_ID
	WHERE NOT EXISTS(SELECT * FROM CCR_TypeOfProgram_Name topn WHERE topn.TOP_ID=[top].TOP_ID)
		AND NOT EXISTS(SELECT * FROM CCR_BaseTable ccbt WHERE ccbt.TYPE_OF_PROGRAM=[top].TOP_ID)

INSERT INTO CCR_TypeOfProgram_Name (TOP_ID,LangID,[Name])
	SELECT d.TOP_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM CCR_TypeOfProgram_Name topn WHERE topn.TOP_ID=d.TOP_ID)
			AND EXISTS(SELECT * FROM CCR_BaseTable ccbt WHERE ccbt.TYPE_OF_PROGRAM=d.TOP_ID)
	
SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CCR_TypeOfProgram_Name_u] ON [dbo].[CCR_TypeOfProgram_Name] 
FOR UPDATE AS

SET NOCOUNT ON

UPDATE btd
	SET SRCH_Anywhere_U = 1
	FROM GBL_BaseTable_Description btd
	INNER JOIN GBL_BaseTable bt
		ON btd.NUM=btd.NUM
	INNER JOIN CCR_BaseTable ccbt
		ON btd.NUM=ccbt.NUM
	WHERE	btd.SRCH_Anywhere_U <> 1
		AND (EXISTS(SELECT * FROM Inserted i WHERE i.LangID=btd.LangID AND ccbt.TYPE_OF_PROGRAM=i.TOP_ID)
		OR EXISTS(SELECT * FROM Deleted d WHERE d.LangID=btd.LangID AND ccbt.TYPE_OF_PROGRAM=d.TOP_ID))

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CCR_TypeOfProgram_Name] ADD CONSTRAINT [PK_CCR_TypeOfProgram_Name] PRIMARY KEY CLUSTERED  ([TOP_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CCR_TypeOfProgram_Name_UniqueName] ON [dbo].[CCR_TypeOfProgram_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_TypeOfProgram_Name] ADD CONSTRAINT [FK_CCR_TypeOfProgram_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CCR_TypeOfProgram_Name] ADD CONSTRAINT [FK_CCR_TypeOfProgram_Name_CCR_TypeOfProgram] FOREIGN KEY ([TOP_ID]) REFERENCES [dbo].[CCR_TypeOfProgram] ([TOP_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CCR_TypeOfProgram_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CCR_TypeOfProgram_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CCR_TypeOfProgram_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CCR_TypeOfProgram_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CCR_TypeOfProgram_Name] TO [cioc_login_role]
GO
