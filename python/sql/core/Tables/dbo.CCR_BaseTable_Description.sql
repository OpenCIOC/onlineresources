CREATE TABLE [dbo].[CCR_BaseTable_Description]
(
[CCBTD_ID] [int] NOT NULL IDENTITY(1, 1),
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_CCR_BaseTable_Description_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_CCR_BaseTable_Description_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[BEST_TIME_TO_CALL] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[LC_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SCHOOL_ESCORT_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SCHOOLS_IN_AREA_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SPACE_AVAILABLE_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TYPE_OF_CARE_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SUBSIDY_NAMED_PROGRAM_NOTES] [nvarchar] (1000) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CCR_BaseTable_Description_d] ON [dbo].[CCR_BaseTable_Description]
FOR DELETE AS

SET NOCOUNT ON

DELETE pr
	FROM CCR_BT_SCH_Notes prn
	INNER JOIN CCR_BT_SCH pr
		ON prn.BT_SCH_ID=pr.BT_SCH_ID
	INNER JOIN Deleted d
		ON pr.NUM=d.NUM AND prn.LangID=d.LangID

DELETE pr
	FROM CCR_BT_TOC_Notes prn
	INNER JOIN CCR_BT_TOC pr
		ON prn.BT_TOC_ID=pr.BT_TOC_ID
	INNER JOIN Deleted d
		ON pr.NUM=d.NUM AND prn.LangID=d.LangID

SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_CCR_BaseTable_Description_iu] ON [dbo].[CCR_BaseTable_Description]
FOR INSERT, UPDATE AS

SET NOCOUNT ON

IF UPDATE (MODIFIED_DATE) BEGIN
	IF EXISTS(SELECT * FROM GBL_BaseTable_Description btd INNER JOIN Inserted i ON btd.NUM=i.NUM AND btd.LangID=i.LangID WHERE btd.MODIFIED_DATE < i.MODIFIED_DATE) BEGIN
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
ALTER TABLE [dbo].[CCR_BaseTable_Description] ADD CONSTRAINT [PK_CCR_BaseTable_Description] PRIMARY KEY CLUSTERED ([CCBTD_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CCR_BaseTable_Description] ON [dbo].[CCR_BaseTable_Description] ([NUM], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_BaseTable_Description] ADD CONSTRAINT [FK_CCR_BaseTable_Description_CCR_BaseTable] FOREIGN KEY ([NUM]) REFERENCES [dbo].[CCR_BaseTable] ([NUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CCR_BaseTable_Description] ADD CONSTRAINT [FK_CCR_BaseTable_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[CCR_BaseTable_Description] TO [cioc_cic_search_role]
GO
GRANT DELETE ON  [dbo].[CCR_BaseTable_Description] TO [cioc_login_role]
GO
GRANT INSERT ON  [dbo].[CCR_BaseTable_Description] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[CCR_BaseTable_Description] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[CCR_BaseTable_Description] TO [cioc_login_role]
GO
