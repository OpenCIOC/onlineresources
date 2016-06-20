CREATE TABLE [dbo].[CCR_TypeOfCare_Name]
(
[TOC_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CCR_TypeOfCare_Name_d] ON [dbo].[CCR_TypeOfCare_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE toc
	FROM CCR_TypeOfCare toc
	INNER JOIN Deleted d
		ON toc.TOC_ID=d.TOC_ID
	WHERE NOT EXISTS(SELECT * FROM CCR_TypeOfCare_Name tocn WHERE tocn.TOC_ID=toc.TOC_ID)
		AND NOT EXISTS(SELECT * FROM CCR_BT_TOC pr WHERE pr.TOC_ID=toc.TOC_ID)

INSERT INTO CCR_TypeOfCare_Name (TOC_ID,LangID,[Name])
	SELECT d.TOC_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM CCR_TypeOfCare_Name tocn WHERE tocn.TOC_ID=d.TOC_ID)
			AND EXISTS(SELECT * FROM CCR_BT_TOC pr WHERE pr.TOC_ID=d.TOC_ID)

UPDATE btd
		SET SRCH_Anywhere_U = 1
	FROM GBL_BaseTable_Description btd
	INNER JOIN CCR_BT_TOC pr
		ON btd.NUM=pr.NUM
	WHERE	btd.SRCH_Anywhere_U <> 1
		AND (EXISTS(SELECT * FROM Inserted i WHERE pr.TOC_ID=i.TOC_ID AND btd.LangID=i.LangID)
		OR EXISTS(SELECT * FROM Deleted d WHERE pr.TOC_ID=d.TOC_ID AND btd.LangID=d.LangID))
	
SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CCR_TypeOfCare_Name_u] ON [dbo].[CCR_TypeOfCare_Name] 
FOR UPDATE AS

SET NOCOUNT ON

UPDATE btd
	SET SRCH_Anywhere_U = 1
	FROM GBL_BaseTable_Description btd
	INNER JOIN CCR_BT_TOC pr
		ON btd.NUM=pr.NUM
	WHERE	btd.SRCH_Anywhere_U <> 1
		AND (EXISTS(SELECT * FROM Inserted i WHERE i.LangID=btd.LangID AND i.TOC_ID=pr.TOC_ID)
		OR EXISTS(SELECT * FROM Deleted d WHERE d.LangID=btd.LangID AND d.TOC_ID=pr.TOC_ID))

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CCR_TypeOfCare_Name] ADD CONSTRAINT [PK_CCR_TypeOfCare_Name] PRIMARY KEY CLUSTERED  ([TOC_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CCR_TypeOfCare_Name_UniqueName] ON [dbo].[CCR_TypeOfCare_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_TypeOfCare_Name] ADD CONSTRAINT [FK_CCR_TypeOfCare_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CCR_TypeOfCare_Name] ADD CONSTRAINT [FK_CCR_TypeOfCare_Name_CCR_TypeOfCare] FOREIGN KEY ([TOC_ID]) REFERENCES [dbo].[CCR_TypeOfCare] ([TOC_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CCR_TypeOfCare_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CCR_TypeOfCare_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CCR_TypeOfCare_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CCR_TypeOfCare_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CCR_TypeOfCare_Name] TO [cioc_login_role]
GO
