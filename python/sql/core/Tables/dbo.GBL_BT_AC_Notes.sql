CREATE TABLE [dbo].[GBL_BT_AC_Notes]
(
[BT_AC_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Notes] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_BT_AC_Notes_iud] ON [dbo].[GBL_BT_AC_Notes]
FOR INSERT, UPDATE, DELETE AS

SET NOCOUNT ON

IF (SELECT COUNT(*) FROM Inserted) > 0 BEGIN
	DELETE prn
	FROM GBL_BT_AC_Notes prn
	INNER JOIN Inserted i
		ON prn.BT_AC_ID = i.BT_AC_ID AND prn.LangID=i.LangID
	WHERE prn.Notes IS NULL
END

UPDATE btd
	SET	CMP_Accessibility = dbo.fn_GBL_NUMToAccessibility(btd.NUM,btd.ACCESSIBILITY_NOTES,btd.LangID)
	FROM GBL_BaseTable_Description btd
	INNER JOIN GBL_BaseTable bt
		ON btd.NUM=bt.NUM
	WHERE EXISTS(SELECT * FROM GBL_BT_AC pr INNER JOIN Inserted i ON pr.BT_AC_ID=i.BT_AC_ID WHERE pr.NUM=bt.NUM)
		OR EXISTS(SELECT * FROM GBL_BT_AC pr INNER JOIN Deleted d ON pr.BT_AC_ID=d.BT_AC_ID WHERE pr.NUM=bt.NUM)

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[GBL_BT_AC_Notes] ADD CONSTRAINT [PK_GBL_BT_AC_Notes] PRIMARY KEY CLUSTERED  ([BT_AC_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_BT_AC_Notes] ON [dbo].[GBL_BT_AC_Notes] ([BT_AC_ID], [LangID]) INCLUDE ([Notes]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BT_AC_Notes] ADD CONSTRAINT [FK_GBL_BT_AC_Notes_GBL_BT_AC] FOREIGN KEY ([BT_AC_ID]) REFERENCES [dbo].[GBL_BT_AC] ([BT_AC_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_BT_AC_Notes] ADD CONSTRAINT [FK_GBL_BT_AC_Notes_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[GBL_BT_AC_Notes] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_BT_AC_Notes] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_BT_AC_Notes] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_BT_AC_Notes] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_BT_AC_Notes] TO [cioc_login_role]
GO
