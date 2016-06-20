CREATE TABLE [dbo].[GBL_Accessibility_Name]
(
[AC_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_Accessibility_Name_d] ON [dbo].[GBL_Accessibility_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE ac
	FROM GBL_Accessibility ac
	INNER JOIN Deleted d
		ON ac.AC_ID=d.AC_ID
	WHERE NOT EXISTS(SELECT * FROM GBL_Accessibility_Name acn WHERE acn.AC_ID=ac.AC_ID)
		AND NOT EXISTS(SELECT * FROM VOL_OP_AC pr WHERE pr.AC_ID=ac.AC_ID)
		AND NOT EXISTS(SELECT * FROM GBL_BT_AC pr WHERE pr.AC_ID=ac.AC_ID)

INSERT INTO GBL_Accessibility_Name (AC_ID,LangID,[Name])
	SELECT d.AC_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM GBL_Accessibility_Name acn WHERE acn.AC_ID=d.AC_ID)
			AND (EXISTS(SELECT * FROM VOL_OP_AC pr WHERE pr.AC_ID=d.AC_ID)
				OR EXISTS(SELECT * FROM GBL_BT_AC pr WHERE pr.AC_ID=d.AC_ID))
	
SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_Accessibility_Name_u] ON [dbo].[GBL_Accessibility_Name]
FOR UPDATE AS

SET NOCOUNT ON

UPDATE btd
	SET	CMP_Accessibility = dbo.fn_GBL_NUMToAccessibility(btd.NUM,btd.ACCESSIBILITY_NOTES,btd.LangID)
	FROM GBL_BaseTable_Description btd
	INNER JOIN GBL_BaseTable bt
		ON btd.NUM=btd.NUM
	INNER JOIN GBL_BT_AC pr 
		ON btd.NUM = pr.NUM
		INNER JOIN Inserted i
			ON pr.AC_ID=i.AC_ID
		INNER JOIN Deleted d
			ON pr.AC_ID=d.AC_ID
		WHERE i.LangID=btd.LangID OR d.LangID=btd.LangID

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[GBL_Accessibility_Name] ADD CONSTRAINT [PK_GBL_Accessibility_Name] PRIMARY KEY CLUSTERED  ([AC_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_Accessibility_Name_UniqueName] ON [dbo].[GBL_Accessibility_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Accessibility_Name] ADD CONSTRAINT [FK_GBL_Accessibility_Name_GBL_Accessibility] FOREIGN KEY ([AC_ID]) REFERENCES [dbo].[GBL_Accessibility] ([AC_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Accessibility_Name] ADD CONSTRAINT [FK_GBL_Accessibility_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[GBL_Accessibility_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_Accessibility_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_Accessibility_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_Accessibility_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_Accessibility_Name] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_Accessibility_Name] TO [cioc_vol_search_role]
GO
