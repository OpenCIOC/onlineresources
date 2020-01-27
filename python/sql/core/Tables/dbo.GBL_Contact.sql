CREATE TABLE [dbo].[GBL_Contact]
(
[ContactID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_Contact_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_Contact_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[GblContactType] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[GblNUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NULL,
[LangID] [smallint] NOT NULL,
[VolContactType] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[VolOPDID] [int] NULL,
[VolVNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[NAME_HONORIFIC] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[NAME_FIRST] [nvarchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[NAME_LAST] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[NAME_SUFFIX] [nvarchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[TITLE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[ORG] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EMAIL] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[FAX_NOTE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[FAX_NO] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[FAX_EXT] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[FAX_CALLFIRST] [bit] NOT NULL CONSTRAINT [DF_GBL_Contact_FAX_CALLFIRST] DEFAULT ((0)),
[PHONE_1_TYPE] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[PHONE_1_NOTE] [nvarchar] (500) COLLATE Latin1_General_100_CI_AI NULL,
[PHONE_1_NO] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[PHONE_1_EXT] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[PHONE_1_OPTION] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[PHONE_2_TYPE] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[PHONE_2_NOTE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[PHONE_2_NO] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[PHONE_2_EXT] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[PHONE_2_OPTION] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[PHONE_3_TYPE] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[PHONE_3_NOTE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[PHONE_3_NO] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[PHONE_3_EXT] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[PHONE_3_OPTION] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_Name] [nvarchar] (500) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_Fax] [nvarchar] (130) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_Phone1] [nvarchar] (500) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_Phone2] [nvarchar] (160) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_Phone3] [nvarchar] (160) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_PhoneFull] [nvarchar] (700) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_Contact_CMP] ON [dbo].[GBL_Contact] 
FOR INSERT, UPDATE AS

SET NOCOUNT ON

IF UPDATE(NAME_HONORIFIC) OR UPDATE(NAME_FIRST) OR UPDATE(NAME_LAST) OR UPDATE(NAME_SUFFIX) BEGIN
	UPDATE c
		SET	CMP_Name = CASE WHEN c.NAME_HONORIFIC IS NULL AND c.NAME_FIRST IS NULL AND c.NAME_LAST IS NULL AND c.NAME_SUFFIX IS NULL
			THEN NULL
			ELSE ISNULL(c.NAME_HONORIFIC,'')
				+ CASE WHEN c.NAME_FIRST IS NULL THEN '' ELSE CASE WHEN c.NAME_HONORIFIC IS NULL THEN '' ELSE ' ' END + c.NAME_FIRST END
				+ CASE WHEN c.NAME_LAST IS NULL THEN '' ELSE CASE WHEN COALESCE(c.NAME_HONORIFIC,c.NAME_FIRST) IS NULL THEN '' ELSE ' ' END + c.NAME_LAST END
				+ CASE WHEN c.NAME_SUFFIX IS NULL THEN '' ELSE CASE WHEN COALESCE(c.NAME_HONORIFIC,c.NAME_FIRST,c.NAME_LAST) IS NULL THEN '' ELSE ' ' END + c.NAME_SUFFIX END
			END
		FROM GBL_Contact c
		INNER JOIN Inserted i
			ON c.ContactID=i.ContactID
END

IF UPDATE(FAX_NOTE) OR UPDATE(FAX_NO) OR UPDATE(FAX_EXT) OR UPDATE(FAX_CALLFIRST) BEGIN
	UPDATE c
		SET	CMP_Fax = CASE WHEN c.FAX_NOTE IS NULL AND c.FAX_NO IS NULL AND c.FAX_EXT IS NULL AND c.FAX_CALLFIRST=0
			THEN NULL
			ELSE CASE WHEN c.FAX_CALLFIRST=0 THEN '' ELSE + '(' + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('please call first',c.LangID) + ')' END
				+ CASE WHEN c.FAX_NOTE IS NULL THEN '' ELSE CASE WHEN c.FAX_CALLFIRST=0 THEN '' ELSE ' ' END + c.FAX_NOTE END
				+ CASE WHEN c.FAX_NO IS NULL THEN '' ELSE CASE WHEN c.FAX_CALLFIRST=0 AND c.FAX_NOTE IS NULL THEN '' ELSE ' ' END + c.FAX_NO END
				+ CASE WHEN c.FAX_EXT IS NULL THEN '' ELSE CASE WHEN c.FAX_CALLFIRST=0 AND c.FAX_NOTE IS NULL AND c.FAX_NO IS NULL THEN '' ELSE ' ' END + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.FAX_EXT END
			END
		FROM GBL_Contact c
		INNER JOIN Inserted i
			ON c.ContactID=i.ContactID
END

IF UPDATE(PHONE_1_NOTE) OR UPDATE(PHONE_1_TYPE) OR UPDATE(PHONE_1_NO) OR UPDATE(PHONE_1_EXT) OR UPDATE(PHONE_1_OPTION) BEGIN
	UPDATE c
		SET	CMP_Phone1 = CASE WHEN c.PHONE_1_NOTE IS NULL AND c.PHONE_1_TYPE IS NULL AND c.PHONE_1_NO IS NULL AND c.PHONE_1_EXT IS NULL AND c.PHONE_1_OPTION IS NULL
			THEN NULL
			ELSE ISNULL(c.PHONE_1_NOTE,'')
				+ CASE WHEN c.PHONE_1_TYPE IS NULL THEN '' ELSE CASE WHEN c.PHONE_1_NOTE IS NULL THEN '' ELSE ' ' END + '(' + c.PHONE_1_TYPE + ')' END
				+ CASE WHEN c.PHONE_1_NO IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_1_NOTE,c.PHONE_1_TYPE) IS NULL THEN '' ELSE ' ' END + c.PHONE_1_NO END
				+ CASE WHEN c.PHONE_1_OPTION IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_1_NOTE,c.PHONE_1_TYPE,c.PHONE_1_NO) IS NULL THEN '' ELSE ' ' END 
					+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('option ',c.LangID) + c.PHONE_1_OPTION END
				+ CASE WHEN c.PHONE_1_EXT IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_1_NOTE,c.PHONE_1_TYPE,c.PHONE_1_NO,c.PHONE_1_OPTION) IS NULL THEN '' ELSE ' ' END 
					+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.PHONE_1_EXT END
			END
		FROM GBL_Contact c
		INNER JOIN Inserted i
			ON c.ContactID=i.ContactID
END

IF UPDATE(PHONE_2_NOTE) OR UPDATE(PHONE_2_TYPE) OR UPDATE(PHONE_2_NO) OR UPDATE(PHONE_2_EXT) OR UPDATE(PHONE_2_OPTION) BEGIN
	UPDATE c
		SET	CMP_Phone2 = CASE WHEN c.PHONE_2_NOTE IS NULL AND c.PHONE_2_TYPE IS NULL AND c.PHONE_2_NO IS NULL AND c.PHONE_2_EXT IS NULL AND c.PHONE_2_OPTION IS NULL
			THEN NULL
			ELSE ISNULL(c.PHONE_2_NOTE,'')
				+ CASE WHEN c.PHONE_2_TYPE IS NULL THEN '' ELSE CASE WHEN c.PHONE_2_NOTE IS NULL THEN '' ELSE ' ' END + '(' + c.PHONE_2_TYPE + ')' END
				+ CASE WHEN c.PHONE_2_NO IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_2_NOTE,c.PHONE_2_TYPE) IS NULL THEN '' ELSE ' ' END + c.PHONE_2_NO END
				+ CASE WHEN c.PHONE_2_OPTION IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_2_NOTE,c.PHONE_2_TYPE,c.PHONE_2_NO) IS NULL THEN '' ELSE ' ' END 
					+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('option ',c.LangID) + c.PHONE_2_OPTION END
				+ CASE WHEN c.PHONE_2_EXT IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_2_NOTE,c.PHONE_2_TYPE,c.PHONE_2_NO,c.PHONE_2_OPTION) IS NULL THEN '' ELSE ' ' END 
					+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.PHONE_2_EXT END
			END
		FROM GBL_Contact c
		INNER JOIN Inserted i
			ON c.ContactID=i.ContactID
END

IF UPDATE(PHONE_3_NOTE) OR UPDATE(PHONE_3_TYPE) OR UPDATE(PHONE_3_NO) OR UPDATE(PHONE_3_EXT) OR UPDATE(PHONE_3_OPTION) BEGIN
	UPDATE c
		SET	CMP_Phone3 = CASE WHEN c.PHONE_3_NOTE IS NULL AND c.PHONE_3_TYPE IS NULL AND c.PHONE_3_NO IS NULL AND c.PHONE_3_EXT IS NULL AND c.PHONE_3_OPTION IS NULL
			THEN NULL
			ELSE ISNULL(c.PHONE_3_NOTE,'')
				+ CASE WHEN c.PHONE_3_TYPE IS NULL THEN '' ELSE CASE WHEN c.PHONE_3_NOTE IS NULL THEN '' ELSE ' ' END + '(' + c.PHONE_3_TYPE + ')' END
				+ CASE WHEN c.PHONE_3_NO IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_3_NOTE,c.PHONE_3_TYPE) IS NULL THEN '' ELSE ' ' END + c.PHONE_3_NO END
				+ CASE WHEN c.PHONE_3_OPTION IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_3_NOTE,c.PHONE_3_TYPE,c.PHONE_3_NO) IS NULL THEN '' ELSE ' ' END 
					+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('option ',c.LangID) + c.PHONE_3_OPTION END
				+ CASE WHEN c.PHONE_3_EXT IS NULL THEN '' ELSE CASE WHEN COALESCE(c.PHONE_3_NOTE,c.PHONE_3_TYPE,c.PHONE_3_NO,c.PHONE_3_OPTION) IS NULL THEN '' ELSE ' ' END 
					+ cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('ext ',c.LangID) + c.PHONE_3_EXT END
			END
		FROM GBL_Contact c
		INNER JOIN Inserted i
			ON c.ContactID=i.ContactID
END

IF UPDATE(CMP_Phone1) OR UPDATE(CMP_Phone2) OR UPDATE(CMP_Phone3) BEGIN
	UPDATE c
	SET	CMP_PhoneFull = CASE WHEN c.CMP_Phone1 IS NULL AND c.CMP_Phone2 IS NULL AND c.CMP_Phone3 IS NULL
		THEN NULL
		ELSE ISNULL(c.CMP_Phone1,'')
			+ CASE WHEN c.CMP_Phone2 IS NULL THEN '' ELSE ' * ' + c.CMP_Phone2 END
			+ CASE WHEN c.CMP_Phone3 IS NULL THEN '' ELSE ' * ' + c.CMP_Phone3 END
		END
	FROM GBL_Contact c
	INNER JOIN Inserted i
		ON c.ContactID=i.ContactID
END

SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_Contact_SRCH] ON [dbo].[GBL_Contact] 
FOR INSERT, UPDATE AS

SET NOCOUNT ON

/* Update "Anywhere" Index */
IF UPDATE(CMP_Name) BEGIN
	UPDATE btd
		SET SRCH_Anywhere_U = 1
	FROM GBL_BaseTable_Description btd
	INNER JOIN Inserted i
		ON btd.NUM=i.GblNUM AND btd.LangID=i.LangID
	WHERE btd.SRCH_Anywhere_U <> 1

	UPDATE vod
		SET	SRCH_Anywhere_U = 1
	FROM 	VOL_Opportunity_Description vod
	INNER JOIN Inserted i
		ON i.VolVNUM = vod.VNUM AND vod.LangID=i.LangID
	WHERE vod.SRCH_Anywhere_U <> 1
END

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[GBL_Contact] ADD CONSTRAINT [CK_GBL_Contact] CHECK (([dbo].[fn_GBL_Contact_CheckModule]([GblContactType],[GblNUM],[VolContactType],[VolVNUM])=(0)))
GO
ALTER TABLE [dbo].[GBL_Contact] ADD CONSTRAINT [PK_GBL_Contact] PRIMARY KEY CLUSTERED  ([ContactID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_Contact_GblNUMGblContactTypeinclLangIDTITLEORGEMAILCMPNameCMPFaxCMPPhoneFull] ON [dbo].[GBL_Contact] ([GblNUM], [GblContactType]) INCLUDE ([CMP_Fax], [CMP_Name], [CMP_PhoneFull], [EMAIL], [LangID], [ORG], [TITLE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_Contact_VolVNUMVolContactTypeinclLangIDTITLEORGEMAILCMPNameCMPFaxCMPPhoneFull] ON [dbo].[GBL_Contact] ([VolVNUM], [VolContactType]) INCLUDE ([CMP_Fax], [CMP_Name], [CMP_PhoneFull], [EMAIL], [LangID], [ORG], [TITLE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Contact] ADD CONSTRAINT [FK_GBL_Contact_GBL_BaseTable_Description] FOREIGN KEY ([GblNUM], [LangID]) REFERENCES [dbo].[GBL_BaseTable_Description] ([NUM], [LangID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Contact] WITH NOCHECK ADD CONSTRAINT [FK_GBL_Contact_GBL_Contact_Honorific] FOREIGN KEY ([NAME_HONORIFIC]) REFERENCES [dbo].[GBL_Contact_Honorific] ([Honorific]) NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[GBL_Contact] ADD CONSTRAINT [FK_GBL_Contact_GBL_FieldOption] FOREIGN KEY ([GblContactType]) REFERENCES [dbo].[GBL_FieldOption] ([FieldName]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Contact] ADD CONSTRAINT [FK_GBL_Contact_VOL_FieldOption] FOREIGN KEY ([VolContactType]) REFERENCES [dbo].[VOL_FieldOption] ([FieldName]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Contact] WITH NOCHECK ADD CONSTRAINT [FK_GBL_Contact_VOL_Opportunity_Description] FOREIGN KEY ([VolVNUM], [LangID]) REFERENCES [dbo].[VOL_Opportunity_Description] ([VNUM], [LangID]) NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[GBL_Contact] ADD CONSTRAINT [FK_GBL_Contact_VOL_Opportunity_Description_OPDID] FOREIGN KEY ([VolOPDID]) REFERENCES [dbo].[VOL_Opportunity_Description] ([OPD_ID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[GBL_Contact] NOCHECK CONSTRAINT [FK_GBL_Contact_GBL_Contact_Honorific]
GO
ALTER TABLE [dbo].[GBL_Contact] NOCHECK CONSTRAINT [FK_GBL_Contact_VOL_Opportunity_Description]
GO
GRANT SELECT ON  [dbo].[GBL_Contact] TO [cioc_cic_search_role]
GO
GRANT DELETE ON  [dbo].[GBL_Contact] TO [cioc_login_role]
GO
GRANT INSERT ON  [dbo].[GBL_Contact] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[GBL_Contact] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[GBL_Contact] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[GBL_Contact] TO [cioc_vol_search_role]
GO
