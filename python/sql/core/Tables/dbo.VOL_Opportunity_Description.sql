CREATE TABLE [dbo].[VOL_Opportunity_Description]
(
[OPD_ID] [int] NOT NULL IDENTITY(1, 1),
[VNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_VOL_Opportunity_Description_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_VOL_Opportunity_Description_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[NON_PUBLIC] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_Description_NonPublic] DEFAULT ((0)),
[UPDATE_DATE] [smalldatetime] NULL,
[UPDATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[UPDATE_SCHEDULE] [smalldatetime] NULL,
[UPDATE_HISTORY] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DELETION_DATE] [smalldatetime] NULL,
[DELETED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[POSITION_TITLE] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NOT NULL,
[ACCESSIBILITY_NOTES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[ADDITIONAL_REQUIREMENTS] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[BENEFITS] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[CLIENTS] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[COMMITMENT_LENGTH_NOTES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[COST] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[DUTIES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[INTERACTION_LEVEL_NOTES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[LOCATION] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[MORE_INFO_URL] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[NUM_NEEDED_NOTES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[PROGRAM] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[PUBLIC_COMMENTS] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[SCH_M_Time] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[SCH_TU_Time] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[SCH_W_Time] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[SCH_TH_Time] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[SCH_F_Time] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[SCH_ST_Time] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[SCH_SN_Time] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[SCHEDULE_NOTES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[SEASONS_NOTES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[SKILLS_NOTES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_PUBLICATION] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_PUBLICATION_DATE] [smalldatetime] NULL,
[SOURCE_NAME] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_TITLE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_ORG] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_PHONE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_FAX] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SOURCE_EMAIL] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[TRAINING_NOTES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[TRANSPORTATION_NOTES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_Interests] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_InternalMemo] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SRCH_Anywhere] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SRCH_Anywhere_U] [bit] NOT NULL CONSTRAINT [DF_VOL_Opportunity_Description_SRCH_Anywhere_U] DEFAULT ((0)),
[MORE_INFO_URL_PROTOCOL] [varchar] (8) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_VOL_Opportunity_Description_DELETIONDATE] ON [dbo].[VOL_Opportunity_Description] ([DELETION_DATE]) ON [PRIMARY]

ALTER TABLE [dbo].[VOL_Opportunity_Description] ADD 
CONSTRAINT [PK_VOL_Opportunity_Description] PRIMARY KEY CLUSTERED  ([OPD_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Opportunity_Description] ADD CONSTRAINT [IX_VOL_Opportunity_Description] UNIQUE NONCLUSTERED  ([VNUM], [LangID]) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_VOL_Opportunity_Description_VNUMDELETIONDATE] ON [dbo].[VOL_Opportunity_Description] ([VNUM], [DELETION_DATE]) ON [PRIMARY]

CREATE FULLTEXT INDEX ON [dbo].[VOL_Opportunity_Description] KEY INDEX [PK_VOL_Opportunity_Description] ON [VOLRecord] WITH STOPLIST [CIOC_DEFAULT_STOPLIST]
GO

ALTER FULLTEXT INDEX ON [dbo].[VOL_Opportunity_Description] ENABLE
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_VOL_Opportunity_Description_d] ON [dbo].[VOL_Opportunity_Description]
FOR DELETE AS

SET NOCOUNT ON

DELETE vo
	FROM VOL_Opportunity vo
	INNER JOIN Deleted d
		ON vo.VNUM=d.VNUM
	WHERE NOT EXISTS(SELECT * FROM VOL_Opportunity_Description vod WHERE vod.VNUM=vo.VNUM)

DELETE pr
	FROM VOL_OP_AC_Notes prn
	INNER JOIN VOL_OP_AC pr
		ON prn.OP_AC_ID=pr.OP_AC_ID
	INNER JOIN Deleted d
		ON pr.VNUM=d.VNUM AND prn.LangID=d.LangID
		
DELETE pr
	FROM VOL_OP_CL_Notes prn
	INNER JOIN VOL_OP_CL pr
		ON prn.OP_CL_ID=pr.OP_CL_ID
	INNER JOIN Deleted d
		ON pr.VNUM=d.VNUM AND prn.LangID=d.LangID

DELETE pr
	FROM VOL_OP_IL_Notes prn
	INNER JOIN VOL_OP_IL pr
		ON prn.OP_IL_ID=pr.OP_IL_ID
	INNER JOIN Deleted d
		ON pr.VNUM=d.VNUM AND prn.LangID=d.LangID
	
DELETE pr
	FROM VOL_OP_SB_Notes prn
	INNER JOIN VOL_OP_SB pr
		ON prn.OP_SB_ID=pr.OP_SB_ID
	INNER JOIN Deleted d
		ON pr.VNUM=d.VNUM AND prn.LangID=d.LangID

DELETE pr
	FROM VOL_OP_SSN_Notes prn
	INNER JOIN VOL_OP_SSN pr
		ON prn.OP_SSN_ID=pr.OP_SSN_ID
	INNER JOIN Deleted d
		ON pr.VNUM=d.VNUM AND prn.LangID=d.LangID

DELETE pr
	FROM VOL_OP_TRN_Notes prn
	INNER JOIN VOL_OP_TRN pr
		ON prn.OP_TRN_ID=pr.OP_TRN_ID
	INNER JOIN Deleted d
		ON pr.VNUM=d.VNUM AND prn.LangID=d.LangID

DELETE pr
	FROM VOL_OP_TRP_Notes prn
	INNER JOIN VOL_OP_TRP pr
		ON prn.OP_TRP_ID=pr.OP_TRP_ID
	INNER JOIN Deleted d
		ON pr.VNUM=d.VNUM AND prn.LangID=d.LangID

INSERT INTO VOL_Opportunity_Description (
		VNUM,
		LangID,
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		DELETION_DATE,
		NON_PUBLIC,
		POSITION_TITLE
	)
	SELECT
		vo.VNUM,
		d.LangID,
		d.CREATED_DATE,
		d.CREATED_BY,
		d.MODIFIED_DATE,
		d.MODIFIED_BY,
		d.DELETION_DATE,
		d.NON_PUBLIC,
		d.POSITION_TITLE
	FROM Deleted d
	INNER JOIN VOL_Opportunity vo
		ON d.VNUM=vo.VNUM
	WHERE NOT EXISTS(SELECT * FROM VOL_Opportunity_Description vod WHERE vod.VNUM=d.VNUM)
	
SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[tr_VOL_Opportunity_Description_SRCH] ON [dbo].[VOL_Opportunity_Description]
FOR INSERT, UPDATE AS

SET NOCOUNT ON

IF UPDATE(POSITION_TITLE) OR UPDATE(LOCATION) OR UPDATE(DUTIES)OR UPDATE(BENEFITS) OR UPDATE(CLIENTS)
		OR UPDATE(ADDITIONAL_REQUIREMENTS) OR UPDATE(SKILLS_NOTES) OR UPDATE(CMP_Interests) BEGIN
	UPDATE vod
		SET	SRCH_Anywhere_U = 1
	FROM 	VOL_Opportunity_Description vod
	INNER JOIN Inserted i
		ON i.VNUM = vod.VNUM
	WHERE vod.SRCH_Anywhere_U <> 1
END

SET NOCOUNT OFF

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_VOL_Opportunity_Description_u] ON [dbo].[VOL_Opportunity_Description]
FOR UPDATE AS

SET NOCOUNT ON

IF UPDATE(VNUM) BEGIN
	UPDATE dst
		SET VolVNUM=i.VNUM
	FROM GBL_Contact dst
	INNER JOIN Inserted i ON i.OPD_ID=dst.VolOPDID

	UPDATE dst
		SET VolVNUM=i.VNUM
	FROM GBL_RecordNote dst
	INNER JOIN Inserted i ON i.OPD_ID=dst.VolOPDID
END

SET NOCOUNT OFF
GO

ALTER TABLE [dbo].[VOL_Opportunity_Description] ADD CONSTRAINT [FK_VOL_Opportunity_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_Opportunity_Description] ADD CONSTRAINT [FK_VOL_Opportunity_Description_VOL_Opportunity] FOREIGN KEY ([VNUM]) REFERENCES [dbo].[VOL_Opportunity] ([VNUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Opportunity_Description] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[VOL_Opportunity_Description] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Opportunity_Description] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_Opportunity_Description] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Opportunity_Description] TO [cioc_vol_search_role]
GO

ALTER FULLTEXT INDEX ON [dbo].[VOL_Opportunity_Description] ADD ([POSITION_TITLE] LANGUAGE 0)
GO

ALTER FULLTEXT INDEX ON [dbo].[VOL_Opportunity_Description] ADD ([CMP_Interests] LANGUAGE 0)
GO

ALTER FULLTEXT INDEX ON [dbo].[VOL_Opportunity_Description] ADD ([SRCH_Anywhere] LANGUAGE 0)
GO
