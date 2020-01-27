CREATE TABLE [dbo].[GBL_BaseTable]
(
[RSN] [int] NOT NULL IDENTITY(1, 1),
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL,
[MemberID] [int] NOT NULL,
[NUM_Agency] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[NUM_Number] [int] NULL,
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_BaseTable_CREATED] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_BaseTable_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[RECORD_OWNER] [char] (3) COLLATE Latin1_General_100_CI_AI NOT NULL,
[GEOCODE_TYPE] [tinyint] NOT NULL CONSTRAINT [DF_GBL_BaseTable_GEOCODE_TYPE] DEFAULT ((0)),
[LATITUDE] [decimal] (11, 7) NULL,
[LONGITUDE] [decimal] (11, 7) NULL,
[LOCATED_IN_CM] [int] NULL,
[MAP_PIN] [int] NOT NULL CONSTRAINT [DF_GBL_BaseTable_MAP_PIN] DEFAULT ((1)),
[MAIL_POSTAL_CODE] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[PRIVACY_PROFILE] [int] NULL,
[SITE_POSTAL_CODE] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[UPDATE_EMAIL] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[NO_UPDATE_EMAIL] [bit] NULL CONSTRAINT [DF_GBL_BaseTable_NO_UPDATE_EMAIL] DEFAULT ((0)),
[EMAIL_UPDATE_DATE] [smalldatetime] NULL,
[EMAIL_UPDATE_DATE_VOL] [smalldatetime] NULL,
[UPDATE_PASSWORD] [varchar] (20) COLLATE Latin1_General_CI_AS NULL,
[UPDATE_PASSWORD_REQUIRED] [bit] NULL,
[FBKEY] [char] (6) COLLATE Latin1_General_100_CI_AI NOT NULL CONSTRAINT [DF_GBL_BaseTable_FBKEY] DEFAULT (CONVERT([varchar](max),Crypt_Gen_Random((3)),(2))),
[ORG_NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NULL,
[DISPLAY_ORG_NAME] [bit] NOT NULL CONSTRAINT [DF_GBL_BaseTable_DISPLAY_ORG_NAME] DEFAULT ((0)),
[EXTERNAL_ID] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[DISPLAY_LOCATION_NAME] [bit] NOT NULL CONSTRAINT [DF_GBL_BaseTable_DISPLAY_LOCATION_NAME] DEFAULT ((1))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_BaseTable_CMP] ON [dbo].[GBL_BaseTable]
FOR INSERT, UPDATE AS

SET NOCOUNT ON

IF	UPDATE(MAIL_POSTAL_CODE) BEGIN
	UPDATE btd
		SET CMP_MailAddress = dbo.fn_GBL_FullAddress(NULL,NULL,btd.MAIL_LINE_1,btd.MAIL_LINE_2,btd.MAIL_BUILDING,btd.MAIL_STREET_NUMBER,btd.MAIL_STREET,btd.MAIL_STREET_TYPE,btd.MAIL_STREET_TYPE_AFTER,btd.MAIL_STREET_DIR,btd.MAIL_SUFFIX,btd.MAIL_CITY,btd.MAIL_PROVINCE,btd.MAIL_COUNTRY,bt.MAIL_POSTAL_CODE,btd.MAIL_CARE_OF,btd.MAIL_BOX_TYPE,btd.MAIL_PO_BOX,NULL,NULL,btd.LangID,0)
		FROM GBL_BaseTable_Description btd
		INNER JOIN GBL_BaseTable bt
			ON btd.NUM=bt.NUM
		INNER JOIN Inserted i
			ON btd.NUM=i.NUM
END

IF	UPDATE(SITE_POSTAL_CODE) 
		OR UPDATE(LATITUDE)
		OR UPDATE(LONGITUDE) BEGIN
	UPDATE btd
		SET CMP_SiteAddress = dbo.fn_GBL_FullAddress(bt.NUM,bt.RSN,btd.SITE_LINE_1,btd.SITE_LINE_2,btd.SITE_BUILDING,btd.SITE_STREET_NUMBER,btd.SITE_STREET,btd.SITE_STREET_TYPE,btd.SITE_STREET_TYPE_AFTER,btd.SITE_STREET_DIR,btd.SITE_SUFFIX,btd.SITE_CITY,btd.SITE_PROVINCE,btd.SITE_COUNTRY,bt.SITE_POSTAL_CODE,NULL,NULL,NULL,bt.LATITUDE,bt.LONGITUDE,btd.LangID,0),
			CMP_SiteAddressWeb = dbo.fn_GBL_FullAddress(bt.NUM,bt.RSN,btd.SITE_LINE_1,btd.SITE_LINE_2,btd.SITE_BUILDING,btd.SITE_STREET_NUMBER,btd.SITE_STREET,btd.SITE_STREET_TYPE,btd.SITE_STREET_TYPE_AFTER,btd.SITE_STREET_DIR,btd.SITE_SUFFIX,btd.SITE_CITY,btd.SITE_PROVINCE,btd.SITE_COUNTRY,bt.SITE_POSTAL_CODE,NULL,NULL,NULL,bt.LATITUDE,bt.LONGITUDE,btd.LangID,1)
		FROM GBL_BaseTable_Description btd
		INNER JOIN GBL_BaseTable bt
			ON btd.NUM=bt.NUM
		INNER JOIN Inserted i
			ON btd.NUM=i.NUM
END

IF	UPDATE(LOCATED_IN_CM) BEGIN
	UPDATE btd
		SET CMP_LocatedIn = dbo.fn_GBL_DisplayCommunity(bt.LOCATED_IN_CM, btd.LangID)
		FROM GBL_BaseTable_Description btd
		INNER JOIN GBL_BaseTable bt
			ON btd.NUM=bt.NUM
		INNER JOIN Inserted i
			ON btd.NUM=i.NUM
END

SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_BaseTable_d] ON [dbo].[GBL_BaseTable]
FOR DELETE AS

SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 31-Jan-2014
	Action:	NO ACTION REQUIRED
*/

UPDATE ag
	SET AgencyNUMCIC=NULL
FROM GBL_Agency ag
INNER JOIN Deleted d ON d.NUM=ag.AgencyNUMCIC

UPDATE ag
	SET AgencyNUMVOL=NULL
FROM GBL_Agency ag
INNER JOIN Deleted d ON d.NUM=ag.AgencyNUMVOL

DELETE fbe
	FROM GBL_FeedbackEntry fbe
INNER JOIN Deleted d ON d.NUM=fbe.NUM

DELETE ls
	FROM GBL_BT_LOCATION_SERVICE ls
INNER JOIN Deleted d ON d.NUM=ls.SERVICE_NUM

SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_BaseTable_iu] ON [dbo].[GBL_BaseTable]
FOR INSERT, UPDATE AS

SET NOCOUNT ON

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 09-Mar-2014
	Action:	NO ACTION REQUIRED
*/

IF UPDATE (MODIFIED_DATE) BEGIN
	UPDATE btd
		SET	MODIFIED_DATE=i.MODIFIED_DATE,
			MODIFIED_BY=i.MODIFIED_BY
	FROM GBL_BaseTable_Description btd
	INNER JOIN Inserted i
		ON btd.NUM=i.NUM
	WHERE btd.MODIFIED_DATE < i.MODIFIED_DATE
END

IF UPDATE (NUM) BEGIN
	UPDATE bt
		SET NUM_Agency=LEFT(bt.NUM,3),
			NUM_Number=CAST(RIGHT(bt.NUM,LEN(bt.NUM)-3) AS int)
	FROM GBL_BaseTable bt
	LEFT JOIN Inserted i
		ON bt.NUM=i.NUM
	WHERE i.NUM IS NOT NULL OR bt.NUM_Agency IS NULL OR bt.NUM_Number IS NULL
END

IF UPDATE(ORG_NUM) OR UPDATE(DISPLAY_ORG_NAME) BEGIN
	UPDATE btd
		SET	ORG_LEVEL_1=obtd.ORG_LEVEL_1,
			ORG_LEVEL_2=obtd.ORG_LEVEL_2, O2_PUBLISH=0,
			ORG_LEVEL_3=obtd.ORG_LEVEL_3, O3_PUBLISH=0,
			ORG_LEVEL_4=obtd.ORG_LEVEL_4, O4_PUBLISH=0,
			ORG_LEVEL_5=obtd.ORG_LEVEL_5, O5_PUBLISH=0
	FROM GBL_BaseTable_Description btd
	INNER JOIN GBL_BaseTable bt
		ON btd.NUM=bt.NUM AND bt.DISPLAY_ORG_NAME=1
	INNER JOIN Inserted i
		ON bt.NUM=i.NUM
	INNER JOIN GBL_BaseTable_Description obtd
		ON bt.ORG_NUM=obtd.NUM AND obtd.LangID=(SELECT TOP 1 LangID FROM GBL_BaseTable_Description WHERE NUM=obtd.NUM ORDER BY CASE WHEN LangID=btd.LangID THEN 0 ELSE 1 END, LangID)
		
	IF EXISTS(SELECT * FROM GBL_BaseTable bt WHERE bt.DISPLAY_ORG_NAME=1 AND NOT EXISTS(SELECT * FROM GBL_BaseTable obt WHERE obt.NUM=bt.ORG_NUM)) BEGIN
		UPDATE bt
			SET	DISPLAY_ORG_NAME = 0
		FROM GBL_BaseTable bt
		WHERE bt.DISPLAY_ORG_NAME = 1
			AND NOT EXISTS(SELECT * FROM GBL_BaseTable obt WHERE obt.NUM=bt.ORG_NUM)
	END
END

IF UPDATE(EXTERNAL_ID) AND
	EXISTS(SELECT * FROM GBL_BaseTable bt INNER JOIN Inserted i ON bt.ORG_NUM=i.EXTERNAL_ID AND bt.NUM<>i.NUM) BEGIN
	
	UPDATE bt
		SET ORG_NUM=i.NUM
	FROM GBL_BaseTable bt
	INNER JOIN Inserted i
		ON i.EXTERNAL_ID=bt.ORG_NUM AND bt.NUM<>i.NUM
	WHERE NOT EXISTS(SELECT * FROM GBL_BaseTable bt2 WHERE NUM=bt.ORG_NUM)
END

SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_BaseTable_u] ON [dbo].[GBL_BaseTable]
FOR UPDATE AS

SET NOCOUNT ON

IF UPDATE(NUM) BEGIN
	UPDATE ag
		SET AgencyNUMCIC=i.NUM
	FROM GBL_Agency ag
	INNER JOIN Deleted d ON d.NUM=ag.AgencyNUMCIC
	INNER JOIN Inserted i ON d.RSN=i.RSN

	UPDATE ag
		SET AgencyNUMVOL=i.NUM
	FROM GBL_Agency ag
	INNER JOIN Deleted d ON d.NUM=ag.AgencyNUMVOL
	INNER JOIN Inserted i ON d.RSN=i.RSN
	
	UPDATE fbe
		SET NUM=i.NUM
	FROM GBL_FeedbackEntry fbe
	INNER JOIN Deleted d ON d.NUM=fbe.NUM
	INNER JOIN Inserted i ON d.RSN=i.RSN

	
	UPDATE ls
		SET SERVICE_NUM=i.NUM
	FROM GBL_BT_LOCATION_SERVICE ls
	INNER JOIN Deleted d ON d.NUM=ls.SERVICE_NUM
	INNER JOIN Inserted i ON d.RSN=i.RSN

END

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[GBL_BaseTable] WITH NOCHECK ADD CONSTRAINT [CK_GBL_BaseTable] CHECK (([NUM] like '[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9]' OR [NUM] like '[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[GBL_BaseTable] ADD CONSTRAINT [CK_GBL_BaseTable_DISPLAY_ORG_NAME] CHECK (([DISPLAY_ORG_NAME]=(0) OR [ORG_NUM] IS NOT NULL))
GO
ALTER TABLE [dbo].[GBL_BaseTable] ADD CONSTRAINT [CK_GBL_BaseTable_GEOCODE_TYPE] CHECK (([GEOCODE_TYPE]>=(0) AND [GEOCODE_TYPE]<=(3)))
GO
ALTER TABLE [dbo].[GBL_BaseTable] ADD CONSTRAINT [CK_GBL_BaseTable_LATITUDE] CHECK (([LATITUDE]>=((-180)) AND [LATITUDE]<=(180)))
GO
ALTER TABLE [dbo].[GBL_BaseTable] ADD CONSTRAINT [CK_GBL_BaseTable_LONGITUDE] CHECK (([LONGITUDE]>=((-180)) AND [LONGITUDE]<=(180)))
GO
ALTER TABLE [dbo].[GBL_BaseTable] ADD CONSTRAINT [CK_GBL_BaseTable_ORG_NUM] CHECK (([NUM]<>[ORG_NUM] OR [ORG_NUM] IS NULL))
GO
ALTER TABLE [dbo].[GBL_BaseTable] ADD CONSTRAINT [PK_GBL_BaseTable] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING ON
GO
SET ANSI_WARNINGS ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET ARITHABORT ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE NONCLUSTERED INDEX [IX_GBL_BaseTable_ExternalIDInclNUM] ON [dbo].[GBL_BaseTable] ([EXTERNAL_ID]) INCLUDE ([NUM]) WHERE ([EXTERNAL_ID] IS NOT NULL) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_BaseTable_LOCATEDINCMMemberDINUM] ON [dbo].[GBL_BaseTable] ([LOCATED_IN_CM], [MemberID], [NUM]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_BaseTable_MemberIDNUMinclROLatLngMapPin] ON [dbo].[GBL_BaseTable] ([MemberID], [NUM]) INCLUDE ([DISPLAY_LOCATION_NAME], [DISPLAY_ORG_NAME], [LATITUDE], [LONGITUDE], [MAP_PIN], [RECORD_OWNER]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_BaseTable_NUM] ON [dbo].[GBL_BaseTable] ([NUM]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_BaseTable_NUMInclMemberID] ON [dbo].[GBL_BaseTable] ([NUM]) INCLUDE ([MemberID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_BaseTable_NUMInclORGNUM] ON [dbo].[GBL_BaseTable] ([NUM]) INCLUDE ([ORG_NUM]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_BaseTable_NUMDISPLAYORGNAMEInclDISPLAYLOCATIONNAME] ON [dbo].[GBL_BaseTable] ([NUM], [DISPLAY_ORG_NAME]) INCLUDE ([DISPLAY_LOCATION_NAME]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_BaseTable_NUMMemberID] ON [dbo].[GBL_BaseTable] ([NUM], [MemberID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_BaseTable_NUMORGNUM] ON [dbo].[GBL_BaseTable] ([NUM], [ORG_NUM]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_BaseTable_NUMRSNDISPLAYLOCATIONNAMEDISPLAYORGNAME] ON [dbo].[GBL_BaseTable] ([NUM], [RSN], [DISPLAY_LOCATION_NAME], [DISPLAY_ORG_NAME]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_BaseTable_ORGNUM] ON [dbo].[GBL_BaseTable] ([ORG_NUM]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_BaseTable_RecordOwner] ON [dbo].[GBL_BaseTable] ([RECORD_OWNER]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BaseTable] ADD CONSTRAINT [IX_GBL_BaseTable_RSN] UNIQUE NONCLUSTERED  ([RSN]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BaseTable] WITH NOCHECK ADD CONSTRAINT [FK_GBL_BaseTable_GBL_Agency] FOREIGN KEY ([RECORD_OWNER]) REFERENCES [dbo].[GBL_Agency] ([AgencyCode]) NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[GBL_BaseTable] ADD CONSTRAINT [FK_GBL_BaseTable_GBL_MappingCategory] FOREIGN KEY ([MAP_PIN]) REFERENCES [dbo].[GBL_MappingCategory] ([MapCatID])
GO
ALTER TABLE [dbo].[GBL_BaseTable] ADD CONSTRAINT [FK_GBL_BaseTable_GBL_PrivacyProfile] FOREIGN KEY ([PRIVACY_PROFILE]) REFERENCES [dbo].[GBL_PrivacyProfile] ([ProfileID])
GO
ALTER TABLE [dbo].[GBL_BaseTable] ADD CONSTRAINT [FK_GBL_BaseTable_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[GBL_BaseTable] NOCHECK CONSTRAINT [FK_GBL_BaseTable_GBL_Agency]
GO
GRANT SELECT ON  [dbo].[GBL_BaseTable] TO [cioc_cic_search_role]
GO
GRANT INSERT ON  [dbo].[GBL_BaseTable] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[GBL_BaseTable] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[GBL_BaseTable] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[GBL_BaseTable] TO [cioc_vol_search_role]
GO
