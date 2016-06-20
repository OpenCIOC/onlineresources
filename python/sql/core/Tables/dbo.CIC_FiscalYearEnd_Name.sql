CREATE TABLE [dbo].[CIC_FiscalYearEnd_Name]
(
[FYE_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_FiscalYearEnd_Name_d] ON [dbo].[CIC_FiscalYearEnd_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE fye
	FROM CIC_FiscalYearEnd fye
	INNER JOIN Deleted d
		ON fye.FYE_ID=d.FYE_ID
	WHERE NOT EXISTS(SELECT * FROM CIC_FiscalYearEnd_Name fyen WHERE fyen.FYE_ID=fye.FYE_ID)
		AND NOT EXISTS(SELECT * FROM CIC_BaseTable cbt WHERE cbt.FISCAL_YEAR_END=fye.FYE_ID)

INSERT INTO CIC_FiscalYearEnd_Name (FYE_ID,LangID,[Name])
	SELECT d.FYE_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM CIC_FiscalYearEnd_Name fyen WHERE fyen.FYE_ID=d.FYE_ID)
			AND EXISTS(SELECT * FROM CIC_BaseTable cbt WHERE cbt.FISCAL_YEAR_END=d.FYE_ID)
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CIC_FiscalYearEnd_Name] ADD CONSTRAINT [PK_CIC_FiscalYearEnd_Name] PRIMARY KEY CLUSTERED  ([FYE_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_FiscalYearEnd_Name] ADD CONSTRAINT [FK_CIC_FiscalYearEnd_Name_CIC_FiscalYearEnd] FOREIGN KEY ([FYE_ID]) REFERENCES [dbo].[CIC_FiscalYearEnd] ([FYE_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_FiscalYearEnd_Name] ADD CONSTRAINT [FK_CIC_FiscalYearEnd_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_FiscalYearEnd_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_FiscalYearEnd_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_FiscalYearEnd_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_FiscalYearEnd_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_FiscalYearEnd_Name] TO [cioc_login_role]
GO
