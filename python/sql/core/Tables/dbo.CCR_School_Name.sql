CREATE TABLE [dbo].[CCR_School_Name]
(
[SCH_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CCR_School_Name_d] ON [dbo].[CCR_School_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE sch
	FROM CCR_School sch
	INNER JOIN Deleted d
		ON sch.SCH_ID=d.SCH_ID
	WHERE NOT EXISTS(SELECT * FROM CCR_School_Name schn WHERE schn.SCH_ID=sch.SCH_ID)
		AND NOT EXISTS(SELECT * FROM CCR_BT_SCH pr WHERE pr.SCH_ID=sch.SCH_ID)

INSERT INTO CCR_School_Name (SCH_ID,LangID,[Name])
	SELECT d.SCH_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM CCR_School_Name schn WHERE schn.SCH_ID=d.SCH_ID)
			AND EXISTS(SELECT * FROM CCR_BT_SCH pr WHERE pr.SCH_ID=d.SCH_ID)
	
SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CCR_School_Name_u] ON [dbo].[CCR_School_Name]
FOR UPDATE AS
SET NOCOUNT ON

UPDATE btd
		SET SRCH_Anywhere_U = 1
	FROM GBL_BaseTable_Description btd
	INNER JOIN CCR_BT_SCH pr
		ON btd.NUM=pr.NUM
	WHERE	btd.SRCH_Anywhere_U <> 1
		AND pr.InArea=1
		AND (EXISTS(SELECT * FROM Inserted i WHERE pr.SCH_ID=i.SCH_ID AND btd.LangID=i.LangID)
		OR EXISTS(SELECT * FROM Deleted d WHERE pr.SCH_ID=d.SCH_ID AND btd.LangID=d.LangID))
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CCR_School_Name] ADD CONSTRAINT [PK_CCR_School_Name] PRIMARY KEY CLUSTERED  ([SCH_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_School_Name] ADD CONSTRAINT [FK_CCR_School_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[CCR_School_Name] ADD CONSTRAINT [FK_CCR_School_Name_CCR_School] FOREIGN KEY ([SCH_ID]) REFERENCES [dbo].[CCR_School] ([SCH_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CCR_School_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CCR_School_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CCR_School_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CCR_School_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CCR_School_Name] TO [cioc_login_role]
GO
