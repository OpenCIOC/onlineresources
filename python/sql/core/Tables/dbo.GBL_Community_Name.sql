CREATE TABLE [dbo].[GBL_Community_Name]
(
[CM_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Display] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[ProvinceStateCache] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_Community_Name_d] ON [dbo].[GBL_Community_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE cm
	FROM GBL_Community cm
	INNER JOIN Deleted d
		ON cm.CM_ID=d.CM_ID
	WHERE NOT EXISTS(SELECT * FROM GBL_Community_Name cmn WHERE cmn.CM_ID=cm.CM_ID)
		AND NOT EXISTS(SELECT * FROM CIC_BT_CM pr WHERE pr.CM_ID=cm.CM_ID)

INSERT INTO GBL_Community_Name (CM_ID,LangID,[Name])
	SELECT d.CM_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM GBL_Community_Name cmn WHERE cmn.CM_ID=d.CM_ID)
			AND EXISTS(SELECT * FROM CIC_BT_CM pr WHERE pr.CM_ID=d.CM_ID)
	
SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_Community_Name_u] ON [dbo].[GBL_Community_Name] 
FOR UPDATE AS

SET NOCOUNT ON

UPDATE cbtd
	SET	CMP_AreasServed = dbo.fn_CIC_NUMToAreasServed(cbtd.NUM,cbtd.AREAS_SERVED_NOTES,cbtd.LangID)
	FROM CIC_BaseTable_Description cbtd
	INNER JOIN CIC_BaseTable cbt
		ON cbtd.NUM=cbt.NUM
	INNER JOIN CIC_BT_CM pr
		ON cbt.NUM=pr.NUM
	INNER JOIN Inserted i
		ON pr.CM_ID=i.CM_ID
	INNER JOIN Deleted d
		ON pr.CM_ID=d.CM_ID
	WHERE i.LangID=cbtd.LangID OR d.LangID=cbtd.LangID

UPDATE btd
	SET	CMP_LocatedIn = dbo.fn_GBL_DisplayCommunity(bt.LOCATED_IN_CM,btd.LangID)
	FROM GBL_BaseTable_Description btd
	INNER JOIN GBL_BaseTable bt
		ON btd.NUM=bt.NUM
	INNER JOIN Inserted i
		ON bt.LOCATED_IN_CM=i.CM_ID
	INNER JOIN Deleted d
		ON bt.LOCATED_IN_CM=d.CM_ID
	WHERE i.LangID=btd.LangID OR d.LangID=btd.LangID

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[GBL_Community_Name] ADD CONSTRAINT [PK_GBL_Community_Name] PRIMARY KEY CLUSTERED  ([CM_ID], [LangID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_Community_Name_CMIDInclLangID] ON [dbo].[GBL_Community_Name] ([CM_ID]) INCLUDE ([LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_CommunityName_CMIDLangIDProvStateInclNameDisplay] ON [dbo].[GBL_Community_Name] ([CM_ID], [LangID], [ProvinceStateCache]) INCLUDE ([Display], [Name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_Community_Name_UniqueName] ON [dbo].[GBL_Community_Name] ([LangID], [Name], [ProvinceStateCache]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_Community_Name_NameLangIDProvStateInclCMID] ON [dbo].[GBL_Community_Name] ([Name], [LangID], [ProvinceStateCache]) INCLUDE ([CM_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Community_Name] ADD CONSTRAINT [FK_GBL_Community_Name_GBL_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[GBL_Community] ([CM_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Community_Name] ADD CONSTRAINT [FK_GBL_Community_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[GBL_Community_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_Community_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_Community_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_Community_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_Community_Name] TO [cioc_login_role]
GO
