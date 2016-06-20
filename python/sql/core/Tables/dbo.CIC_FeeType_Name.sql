CREATE TABLE [dbo].[CIC_FeeType_Name]
(
[FT_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_FeeType_Name_d] ON [dbo].[CIC_FeeType_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE ft
	FROM CIC_FeeType ft
	INNER JOIN Deleted d
		ON ft.FT_ID=d.FT_ID
	WHERE NOT EXISTS(SELECT * FROM CIC_FeeType_Name ftn WHERE ftn.FT_ID=ft.FT_ID)
		AND NOT EXISTS(SELECT * FROM CIC_BT_FT pr WHERE pr.FT_ID=ft.FT_ID)

INSERT INTO CIC_FeeType_Name (FT_ID,LangID,[Name])
	SELECT d.FT_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM CIC_FeeType_Name ftn WHERE ftn.FT_ID=d.FT_ID)
			AND EXISTS(SELECT * FROM CIC_BT_FT pr WHERE pr.FT_ID=d.FT_ID)
	
SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_FeeType_Name_u] ON [dbo].[CIC_FeeType_Name] 
FOR UPDATE AS

SET NOCOUNT ON

UPDATE cbtd
	SET	CMP_Fees = dbo.fn_CIC_NUMToFeeType(cbtd.NUM,cbtd.FEE_NOTES,cbt.FEE_ASSISTANCE_AVAILABLE,cbtd.FEE_ASSISTANCE_FOR,cbtd.FEE_ASSISTANCE_FROM,cbtd.LangID)
	FROM CIC_BaseTable cbt
	INNER JOIN CIC_BaseTable_Description cbtd
		ON cbt.NUM=cbtd.NUM
	INNER JOIN CIC_BT_FT pr
		ON cbtd.NUM=pr.NUM
	INNER JOIN Inserted i
		ON pr.FT_ID=i.FT_ID
	INNER JOIN Deleted d
		ON pr.FT_ID=d.FT_ID
	WHERE i.LangID=cbtd.LangID OR d.LangID=cbtd.LangID

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CIC_FeeType_Name] ADD CONSTRAINT [PK_CIC_FeeType_Name] PRIMARY KEY CLUSTERED  ([FT_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_FeeType_Name_UniqueName] ON [dbo].[CIC_FeeType_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_FeeType_Name] ADD CONSTRAINT [FK_CIC_FeeType_Name_CIC_FeeType] FOREIGN KEY ([FT_ID]) REFERENCES [dbo].[CIC_FeeType] ([FT_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_FeeType_Name] ADD CONSTRAINT [FK_CIC_FeeType_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_FeeType_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_FeeType_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_FeeType_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_FeeType_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_FeeType_Name] TO [cioc_login_role]
GO
