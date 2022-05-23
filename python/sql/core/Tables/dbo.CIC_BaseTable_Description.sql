CREATE TABLE [dbo].[CIC_BaseTable_Description]
(
[CBTD_ID] [int] NOT NULL IDENTITY(1, 1),
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_CIC_BaseTable_Description_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_CIC_BaseTable_Description_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[ACTIVITY_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AFTER_HRS_PHONE] [nvarchar] (1000) COLLATE Latin1_General_100_CI_AI NULL,
[APPLICATION] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AREAS_SERVED_NOTES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[BOUNDARIES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[COMMENTS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CRISIS_PHONE] [nvarchar] (1000) COLLATE Latin1_General_100_CI_AI NULL,
[DATES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[ELIGIBILITY_NOTES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[ELECTIONS] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[FEE_ASSISTANCE_FOR] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[FEE_ASSISTANCE_FROM] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[FEE_NOTES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[FUNDING_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[HOURS] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[INTERSECTION] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[LANGUAGE_NOTES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[LOGO_ADDRESS] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[LOGO_ADDRESS_LINK] [varchar] (255) COLLATE Latin1_General_100_CS_AS NULL,
[MEETINGS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MEMBERSHIP_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PUBLIC_COMMENTS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PRINT_MATERIAL] [nvarchar] (1000) COLLATE Latin1_General_100_CI_AI NULL,
[RESOURCES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SITE_LOCATION] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[SUP_DESCRIPTION] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TDD_PHONE] [nvarchar] (1000) COLLATE Latin1_General_100_CI_AI NULL,
[TRANSPORTATION] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[VACANCY_NOTES] [nvarchar] (4000) COLLATE Latin1_General_100_CI_AI NULL,
[BUS_ROUTE_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ACCREDITATION_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DOCUMENTS_REQUIRED] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_AreasServed] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_Fees] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_Funding] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_Languages] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_NAICS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_Subjects] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_SubjectsWeb] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_Taxonomy] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_TaxonomyWeb] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_TaxonomyWebStaff] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CMP_InternalMemo] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SRCH_Subjects] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SRCH_Subjects_U] [bit] NOT NULL CONSTRAINT [DF_CIC_BaseTable_Description_SRCH_Subjects_U] DEFAULT ((1)),
[SRCH_Taxonomy] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SRCH_Taxonomy_U] [bit] NOT NULL CONSTRAINT [DF_CIC_BaseTable_Description_SRCH_Taxonomy_U] DEFAULT ((1)),
[LOGO_ADDRESS_PROTOCOL] [varchar] (8) COLLATE Latin1_General_100_CI_AI NULL,
[LOGO_ADDRESS_LINK_PROTOCOL] [varchar] (8) COLLATE Latin1_General_100_CI_AI NULL,
[LOGO_ADDRESS_HOVER_TEXT] [nvarchar] (500) COLLATE Latin1_General_100_CI_AI NULL,
[LOGO_ADDRESS_ALT_TEXT] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[AREAS_SERVED_ONLY_DISPLAY_NOTES] [bit] NOT NULL CONSTRAINT [DF_CIC_BaseTable_Description_AREAS_SERVED_DISPLAY_ONLY_NOTES] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_BaseTable_Description_CMP] ON [dbo].[CIC_BaseTable_Description]
FOR INSERT, UPDATE AS

SET NOCOUNT ON

IF  UPDATE(AREAS_SERVED_NOTES) OR UPDATE(AREAS_SERVED_ONLY_DISPLAY_NOTES) BEGIN
	UPDATE cbtd
		SET	CMP_AreasServed = dbo.fn_CIC_NUMToAreasServed(cbtd.NUM,cbtd.AREAS_SERVED_NOTES,cbtd.LangID, cbtd.AREAS_SERVED_ONLY_DISPLAY_NOTES)
	FROM CIC_BaseTable_Description cbtd
	INNER JOIN Inserted i
		ON i.CBTD_ID=cbtd.CBTD_ID
END

IF  UPDATE(FEE_NOTES)
	OR UPDATE(FEE_ASSISTANCE_FOR)
	OR UPDATE(FEE_ASSISTANCE_FROM)
BEGIN
	UPDATE cbtd
		SET	CMP_Fees = dbo.fn_CIC_NUMToFeeType(cbtd.NUM,cbtd.FEE_NOTES,cbt.FEE_ASSISTANCE_AVAILABLE,cbtd.FEE_ASSISTANCE_FOR,cbtd.FEE_ASSISTANCE_FROM,cbtd.LangID)
	FROM CIC_BaseTable cbt
	INNER JOIN CIC_BaseTable_Description cbtd
		ON cbt.NUM=cbtd.NUM
	INNER JOIN Inserted i
		ON i.CBTD_ID=cbtd.CBTD_ID
END

IF UPDATE(FUNDING_NOTES) BEGIN
	UPDATE cbtd
		SET	CMP_Funding = dbo.fn_CIC_NUMToFunding(cbtd.NUM,cbtd.FUNDING_NOTES,cbtd.LangID)
	FROM CIC_BaseTable_Description cbtd
	INNER JOIN Inserted i
		ON i.CBTD_ID=cbtd.CBTD_ID
END

IF  UPDATE(LANGUAGE_NOTES) BEGIN
	UPDATE cbtd
		SET	CMP_Languages = dbo.fn_CIC_NUMToLanguages(cbtd.NUM,cbtd.LANGUAGE_NOTES,cbtd.LangID)
	FROM CIC_BaseTable_Description cbtd
	INNER JOIN Inserted i
		ON i.CBTD_ID=cbtd.CBTD_ID
END

SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_BaseTable_Description_d] ON [dbo].[CIC_BaseTable_Description]
FOR DELETE AS

SET NOCOUNT ON

DELETE pr
	FROM CIC_BT_ACT_Notes prn
	INNER JOIN CIC_BT_ACT pr
		ON prn.BT_ACT_ID=pr.BT_ACT_ID
	INNER JOIN Deleted d
		ON pr.NUM=d.NUM AND prn.LangID=d.LangID

DELETE pr
	FROM CIC_BT_CM_Notes prn
	INNER JOIN CIC_BT_CM pr
		ON prn.BT_CM_ID=pr.BT_CM_ID
	INNER JOIN Deleted d
		ON pr.NUM=d.NUM AND prn.LangID=d.LangID

DELETE pr
	FROM CIC_BT_FD_Notes prn
	INNER JOIN CIC_BT_FD pr
		ON prn.BT_FD_ID=pr.BT_FD_ID
	INNER JOIN Deleted d
		ON pr.NUM=d.NUM AND prn.LangID=d.LangID

DELETE pr
	FROM CIC_BT_LN_Notes prn
	INNER JOIN CIC_BT_LN pr
		ON prn.BT_LN_ID=pr.BT_LN_ID
	INNER JOIN Deleted d
		ON pr.NUM=d.NUM AND prn.LangID=d.LangID

DELETE pr
	FROM CIC_BT_VUT_Notes prn
	INNER JOIN CIC_BT_VUT pr
		ON prn.BT_VUT_ID=pr.BT_VUT_ID
	INNER JOIN Deleted d
		ON pr.NUM=d.NUM AND prn.LangID=d.LangID

SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_BaseTable_Description_iu] ON [dbo].[CIC_BaseTable_Description]
FOR INSERT, UPDATE AS

SET NOCOUNT ON

IF UPDATE (MODIFIED_DATE) BEGIN
	IF EXISTS(SELECT * FROM GBL_BaseTable_Description btd INNER JOIN Inserted i ON btd.NUM=i.NUM AND btd.LangID=i.LangID WHERE btd.MODIFIED_DATE <= i.MODIFIED_DATE) BEGIN
		UPDATE btd
			SET	MODIFIED_DATE=i.MODIFIED_DATE,
				MODIFIED_BY=i.MODIFIED_BY
		FROM GBL_BaseTable_Description btd
		INNER JOIN Inserted i
			ON btd.NUM=i.NUM AND btd.LangID=i.LangID
		WHERE btd.MODIFIED_DATE < i.MODIFIED_DATE
	END
END

SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CIC_BaseTable_Description_SRCH] ON [dbo].[CIC_BaseTable_Description]
FOR INSERT, UPDATE AS

SET NOCOUNT ON

IF UPDATE (SRCH_Subjects)
	OR UPDATE (SRCH_Taxonomy)
	OR UPDATE (CMP_AreasServed)
	OR UPDATE (CMP_Fees)
	OR UPDATE (CMP_Funding)
	OR UPDATE (CMP_Languages)
	OR UPDATE (SUP_DESCRIPTION)
	OR UPDATE (INTERSECTION)
	OR UPDATE (SITE_LOCATION)
	OR UPDATE (ELIGIBILITY_NOTES)
BEGIN
	UPDATE btd
		SET SRCH_Anywhere_U = 1
	FROM GBL_BaseTable_Description btd
	INNER JOIN Inserted i
		ON btd.NUM=i.NUM AND btd.LangID=i.LangID
	WHERE btd.SRCH_Anywhere_U <> 1
END

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CIC_BaseTable_Description] ADD CONSTRAINT [PK_CIC_BaseTable_Description] PRIMARY KEY CLUSTERED ([CBTD_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BaseTable_Description] ADD CONSTRAINT [IX_CIC_BaseTable_Description] UNIQUE NONCLUSTERED ([NUM], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_BaseTable_Description_NUMLangIDCBTDIDinclCOMMENTS] ON [dbo].[CIC_BaseTable_Description] ([NUM], [LangID], [CBTD_ID]) INCLUDE ([COMMENTS]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_BaseTable_Description] ADD CONSTRAINT [FK_CIC_BaseTable_Description_CIC_BaseTable] FOREIGN KEY ([NUM]) REFERENCES [dbo].[CIC_BaseTable] ([NUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_BaseTable_Description] ADD CONSTRAINT [FK_CIC_BaseTable_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CIC_BaseTable_Description] TO [cioc_cic_search_role]
GO
GRANT DELETE ON  [dbo].[CIC_BaseTable_Description] TO [cioc_login_role]
GO
GRANT INSERT ON  [dbo].[CIC_BaseTable_Description] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[CIC_BaseTable_Description] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[CIC_BaseTable_Description] TO [cioc_login_role]
GO
CREATE FULLTEXT INDEX ON [dbo].[CIC_BaseTable_Description] KEY INDEX [PK_CIC_BaseTable_Description] ON [GBLRecord]
GO
ALTER FULLTEXT INDEX ON [dbo].[CIC_BaseTable_Description] ADD ([CMP_Languages] LANGUAGE 1033)
GO
ALTER FULLTEXT INDEX ON [dbo].[CIC_BaseTable_Description] ADD ([SRCH_Subjects] LANGUAGE 0)
GO
ALTER FULLTEXT INDEX ON [dbo].[CIC_BaseTable_Description] ADD ([SRCH_Taxonomy] LANGUAGE 0)
GO
ALTER FULLTEXT INDEX ON [dbo].[CIC_BaseTable_Description] ADD ([CMP_Languages] LANGUAGE 1033)
GO
ALTER FULLTEXT INDEX ON [dbo].[CIC_BaseTable_Description] ADD ([SRCH_Subjects] LANGUAGE 0)
GO
ALTER FULLTEXT INDEX ON [dbo].[CIC_BaseTable_Description] ADD ([SRCH_Taxonomy] LANGUAGE 0)
GO
