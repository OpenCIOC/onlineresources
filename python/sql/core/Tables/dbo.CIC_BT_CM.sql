CREATE TABLE [dbo].[CIC_BT_CM]
(
[BT_CM_ID] [int] NOT NULL IDENTITY(1, 1),
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL,
[CM_ID] [int] NOT NULL
) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_BT_CM_CMIDNUM] ON [dbo].[CIC_BT_CM] ([CM_ID], [NUM]) ON [PRIMARY]

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_BT_CM_iud] ON [dbo].[CIC_BT_CM] 
FOR INSERT, UPDATE, DELETE AS
SET NOCOUNT ON

IF EXISTS(SELECT * FROM Inserted i INNER JOIN GBL_BaseTable_Description btd ON btd.NUM = i.NUM
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BaseTable_Description cbtd WHERE cbtd.NUM=btd.NUM AND cbtd.LangID=btd.LangID)) BEGIN
	INSERT INTO CIC_BaseTable_Description (NUM, LangID)
	SELECT DISTINCT btd.NUM, btd.LangID
		FROM GBL_BaseTable_Description btd
		INNER JOIN Inserted i
			ON i.NUM = btd.NUM
	WHERE NOT EXISTS(SELECT * FROM dbo.CIC_BaseTable_Description cbtd WHERE cbtd.NUM=btd.NUM AND cbtd.LangID=btd.LangID)
END

UPDATE cbtd
	SET	CMP_AreasServed = dbo.fn_CIC_NUMToAreasServed(cbtd.NUM,cbtd.AREAS_SERVED_NOTES,cbtd.LangID,cbtd.AREAS_SERVED_ONLY_DISPLAY_NOTES)
	FROM CIC_BaseTable_Description cbtd
	WHERE cbtd.AREAS_SERVED_ONLY_DISPLAY_NOTES=0 AND (EXISTS(SELECT * FROM Inserted i WHERE i.NUM=cbtd.NUM)
		OR EXISTS(SELECT * FROM Deleted d WHERE d.NUM=cbtd.NUM))

SET NOCOUNT OFF
GO

ALTER TABLE [dbo].[CIC_BT_CM] ADD CONSTRAINT [PK_CIC_BT_CM] PRIMARY KEY CLUSTERED  ([BT_CM_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_BT_CM_CMID] ON [dbo].[CIC_BT_CM] ([CM_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_BT_CM_UniquePair] ON [dbo].[CIC_BT_CM] ([NUM], [CM_ID]) ON [PRIMARY]
GO
CREATE STATISTICS [_dta_stat_1803153469_3_2_1] ON [dbo].[CIC_BT_CM] ([BT_CM_ID], [CM_ID], [NUM])
GO
CREATE STATISTICS [_dta_stat_1803153469_1_2] ON [dbo].[CIC_BT_CM] ([BT_CM_ID], [NUM])
GO
ALTER TABLE [dbo].[CIC_BT_CM] ADD CONSTRAINT [FK_CIC_BT_CM_GBL_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[GBL_Community] ([CM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_BT_CM] ADD CONSTRAINT [FK_CIC_BT_CM_CIC_BaseTable] FOREIGN KEY ([NUM]) REFERENCES [dbo].[CIC_BaseTable] ([NUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_BT_CM] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_BT_CM] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_BT_CM] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_BT_CM] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_BT_CM] TO [cioc_login_role]
GO
