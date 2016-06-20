CREATE TABLE [dbo].[CIC_Funding_Name]
(
[FD_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_Funding_Name_d] ON [dbo].[CIC_Funding_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE fd
	FROM CIC_Funding fd
	INNER JOIN Deleted d
		ON fd.FD_ID=d.FD_ID
	WHERE NOT EXISTS(SELECT * FROM CIC_Funding_Name fdn WHERE fdn.FD_ID=fd.FD_ID)
		AND NOT EXISTS(SELECT * FROM CIC_BT_FD pr WHERE pr.FD_ID=fd.FD_ID)

INSERT INTO CIC_Funding_Name (FD_ID,LangID,[Name])
	SELECT d.FD_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM CIC_Funding_Name fdn WHERE fdn.FD_ID=d.FD_ID)
			AND EXISTS(SELECT * FROM CIC_BT_FD pr WHERE pr.FD_ID=d.FD_ID)
	
SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[tr_CIC_Funding_Name_u] ON [dbo].[CIC_Funding_Name]
FOR UPDATE AS

SET NOCOUNT ON

UPDATE cbtd
	SET	CMP_Funding = dbo.fn_CIC_NUMToFunding(cbtd.NUM,cbtd.FUNDING_NOTES,cbtd.LangID)
	FROM CIC_BaseTable_Description cbtd
	INNER JOIN CIC_BaseTable cbt
		ON cbtd.NUM=cbt.NUM
	INNER JOIN CIC_BT_FD pr
		ON cbt.NUM=pr.NUM
	INNER JOIN Inserted i
		ON pr.FD_ID=i.FD_ID
	INNER JOIN Deleted d
		ON pr.FD_ID=d.FD_ID
	WHERE i.LangID=cbtd.LangID OR d.LangID=cbtd.LangID

SET NOCOUNT OFF

GO
ALTER TABLE [dbo].[CIC_Funding_Name] ADD CONSTRAINT [PK_CIC_Funding_Name] PRIMARY KEY CLUSTERED  ([FD_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_Funding_Name_UniqueName] ON [dbo].[CIC_Funding_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Funding_Name] ADD CONSTRAINT [FK_CIC_Funding_Name_CIC_Funding] FOREIGN KEY ([FD_ID]) REFERENCES [dbo].[CIC_Funding] ([FD_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_Funding_Name] ADD CONSTRAINT [FK_CIC_Funding_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_Funding_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Funding_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Funding_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Funding_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_Funding_Name] TO [cioc_login_role]
GO
