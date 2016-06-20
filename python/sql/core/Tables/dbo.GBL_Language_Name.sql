CREATE TABLE [dbo].[GBL_Language_Name]
(
[LN_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_Language_Name_d] ON [dbo].[GBL_Language_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE ln
	FROM GBL_Language ln
	INNER JOIN Deleted d
		ON ln.LN_ID=d.LN_ID
	WHERE NOT EXISTS(SELECT * FROM GBL_Language_Name lnn WHERE lnn.LN_ID=ln.LN_ID)
		AND NOT EXISTS(SELECT * FROM CIC_BT_LN pr WHERE pr.LN_ID=ln.LN_ID)

INSERT INTO GBL_Language_Name (LN_ID,LangID,[Name])
	SELECT d.LN_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM GBL_Language_Name lnn WHERE lnn.LN_ID=d.LN_ID)
			AND EXISTS(SELECT * FROM CIC_BT_LN pr WHERE pr.LN_ID=d.LN_ID)
	
SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_Language_Name_u] ON [dbo].[GBL_Language_Name] 
FOR UPDATE AS

SET NOCOUNT ON

UPDATE cbtd
	SET	CMP_Languages = dbo.fn_CIC_NUMToLanguages(cbtd.NUM,cbtd.LANGUAGE_NOTES,cbtd.LangID)
	FROM CIC_BaseTable_Description cbtd
	INNER JOIN CIC_BaseTable cbt
		ON cbtd.NUM=cbt.NUM
	INNER JOIN CIC_BT_LN pr
		ON cbt.NUM=pr.NUM
	INNER JOIN Inserted i
		ON pr.LN_ID=i.LN_ID
	INNER JOIN Deleted d
		ON pr.LN_ID=d.LN_ID
	WHERE i.LangID=cbtd.LangID OR d.LangID=cbtd.LangID

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[GBL_Language_Name] ADD CONSTRAINT [PK_GBL_Language_Name] PRIMARY KEY CLUSTERED  ([LN_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_Language_Name_UniqueName] ON [dbo].[GBL_Language_Name] ([LangID], [Name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_Language_Name_LNIDInclLangID] ON [dbo].[GBL_Language_Name] ([LN_ID]) INCLUDE ([LangID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_Language_Name_LNIDLangIDInclName] ON [dbo].[GBL_Language_Name] ([LN_ID], [LangID]) INCLUDE ([Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Language_Name] ADD CONSTRAINT [FK_GBL_Language_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_Language_Name] ADD CONSTRAINT [FK_GBL_Language_Name_GBL_Language] FOREIGN KEY ([LN_ID]) REFERENCES [dbo].[GBL_Language] ([LN_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_Language_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_Language_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_Language_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_Language_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_Language_Name] TO [cioc_login_role]
GO
