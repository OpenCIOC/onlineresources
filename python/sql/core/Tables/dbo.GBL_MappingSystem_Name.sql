CREATE TABLE [dbo].[GBL_MappingSystem_Name]
(
[MAP_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Label] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL,
[String] [varchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_MappingSystem_Name_d] ON [dbo].[GBL_MappingSystem_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE map
	FROM GBL_MappingSystem map
	INNER JOIN Deleted d
		ON map.MAP_ID=d.MAP_ID
	WHERE NOT EXISTS(SELECT * FROM GBL_MappingSystem_Name mapn WHERE mapn.MAP_ID=map.MAP_ID)
		AND NOT EXISTS(SELECT * FROM GBL_BT_MAP pr WHERE pr.MAP_ID=map.MAP_ID)

INSERT INTO GBL_MappingSystem_Name (MAP_ID,LangID,[Name],Label,String)
	SELECT d.MAP_ID,d.LangID,d.[Name],d.Label,d.String
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM GBL_MappingSystem_Name mapn WHERE mapn.MAP_ID=d.MAP_ID)
			AND EXISTS(SELECT * FROM GBL_BT_MAP pr WHERE pr.MAP_ID=d.MAP_ID)
	
SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_MappingSystem_Name_u] ON [dbo].[GBL_MappingSystem_Name]
FOR UPDATE AS

SET NOCOUNT ON

IF UPDATE(Label) OR
	UPDATE(String) BEGIN
UPDATE btd
	SET CMP_SiteAddressWeb = dbo.fn_GBL_FullAddress(bt.NUM,bt.RSN,btd.SITE_LINE_1,btd.SITE_LINE_2,btd.SITE_BUILDING,btd.SITE_STREET_NUMBER,btd.SITE_STREET,btd.SITE_STREET_TYPE,btd.SITE_STREET_TYPE_AFTER,btd.SITE_STREET_DIR,btd.SITE_SUFFIX,btd.SITE_CITY,btd.SITE_PROVINCE,btd.SITE_COUNTRY,bt.SITE_POSTAL_CODE,NULL,NULL,NULL,bt.LATITUDE,bt.LONGITUDE,btd.LangID,1)
	FROM GBL_BaseTable_Description btd
	INNER JOIN GBL_BaseTable bt
		ON btd.NUM=bt.NUM
	INNER JOIN GBL_BT_MAP pr
		ON btd.NUM=pr.NUM
	INNER JOIN Inserted i
		ON pr.MAP_ID=i.MAP_ID
END

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[GBL_MappingSystem_Name] ADD CONSTRAINT [PK_GBL_MappingSystem_Name] PRIMARY KEY CLUSTERED  ([MAP_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_MappingSystem_Name_UniqueName] ON [dbo].[GBL_MappingSystem_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_MappingSystem_Name] ADD CONSTRAINT [FK_GBL_MappingSystem_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_MappingSystem_Name] ADD CONSTRAINT [FK_GBL_MappingSystem_Name_GBL_MappingSystem] FOREIGN KEY ([MAP_ID]) REFERENCES [dbo].[GBL_MappingSystem] ([MAP_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_MappingSystem_Name] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_MappingSystem_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_MappingSystem_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_MappingSystem_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_MappingSystem_Name] TO [cioc_login_role]
GO
