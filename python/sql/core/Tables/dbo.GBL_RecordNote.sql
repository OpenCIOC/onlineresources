CREATE TABLE [dbo].[GBL_RecordNote]
(
[RecordNoteID] [int] NOT NULL IDENTITY(1, 1),
[GUID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_GBL_RecordNote_GUID] DEFAULT (newid()),
[CREATED_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_GBL_RecordNote_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_GBL_RecordNote_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[CANCELLED_DATE] [smalldatetime] NULL,
[CANCELLED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[CancelError] [bit] NOT NULL CONSTRAINT [DF_GBL_RecordNote_CancelError] DEFAULT ((0)),
[NoteTypeID] [int] NULL,
[GblNoteType] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[GblNUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NULL,
[VolNoteType] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[VolOPDID] [int] NULL,
[VolVNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[LangID] [smallint] NOT NULL,
[Value] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_GBL_RecordNote_VolVNUMLangID] ON [dbo].[GBL_RecordNote] ([VolVNUM], [LangID]) WHERE ([VolVNUM] IS NOT NULL) ON [PRIMARY]

GO
EXEC sp_addextendedproperty N'MS_Description', N'Suggested for missing indexes for Ontario CIOC', 'SCHEMA', N'dbo', 'TABLE', N'GBL_RecordNote', 'INDEX', N'IX_GBL_RecordNote_VolVNUMLangID'
GO

CREATE NONCLUSTERED INDEX [IX_GBL_RecordNote_GblNUMLangID] ON [dbo].[GBL_RecordNote] ([GblNUM], [LangID]) WHERE ([GblNUM] IS NOT NULL) ON [PRIMARY]

GO
EXEC sp_addextendedproperty N'MS_Description', N'Suggested for missing indexes for Ontario CIOC', 'SCHEMA', N'dbo', 'TABLE', N'GBL_RecordNote', 'INDEX', N'IX_GBL_RecordNote_GblNUMLangID'
GO

ALTER TABLE [dbo].[GBL_RecordNote] WITH NOCHECK ADD
CONSTRAINT [FK_GBL_RecordNote_VOL_Opportunity_Description] FOREIGN KEY ([VolVNUM], [LangID]) REFERENCES [dbo].[VOL_Opportunity_Description] ([VNUM], [LangID]) NOT FOR REPLICATION
ALTER TABLE [dbo].[GBL_RecordNote] NOCHECK CONSTRAINT [FK_GBL_RecordNote_VOL_Opportunity_Description]
ALTER TABLE [dbo].[GBL_RecordNote] ADD 
CONSTRAINT [PK_GBL_RecordNote] PRIMARY KEY CLUSTERED  ([RecordNoteID]) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_GBL_RecordNote] ON [dbo].[GBL_RecordNote] ([GUID]) ON [PRIMARY]

ALTER TABLE [dbo].[GBL_RecordNote] ADD
CONSTRAINT [CK_GBL_RecordNote] CHECK (([dbo].[fn_GBL_RecordNote_CheckModule]([GblNoteType],[GblNUM],[VolNoteType],[VolVNUM])=(0)))
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_GBL_RecordNote_iud] ON [dbo].[GBL_RecordNote]
FOR INSERT, UPDATE, DELETE AS

SET NOCOUNT ON

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 05-Aug-2015
	Action: TESTING REQUIRED
*/

UPDATE cbtd
	SET	CMP_InternalMemo=dbo.fn_GBL_NUMToRecordNote('INTERNAL_MEMO',NUM,LangID)
	FROM CIC_BaseTable_Description cbtd
	WHERE EXISTS(SELECT * FROM Inserted i WHERE i.GblNUM=cbtd.NUM AND i.LangID=cbtd.LangID)
		OR EXISTS(SELECT * FROM Deleted d WHERE d.GblNUM=cbtd.NUM AND d.LangID=cbtd.LangID)

INSERT INTO dbo.CIC_BaseTable
        ( NUM )
SELECT DISTINCT i.GblNUM
	FROM Inserted i
WHERE i.GblNUM IS NOT NULL
	AND NOT EXISTS(SELECT * FROM dbo.CIC_BaseTable cbt WHERE cbt.NUM=i.GblNUM)

INSERT INTO dbo.CIC_BaseTable_Description
        ( NUM ,
          LangID ,
          CMP_InternalMemo
        )
SELECT DISTINCT i.GblNUM, i.LangID,
		dbo.fn_GBL_NUMToRecordNote('INTERNAL_MEMO',i.GblNUM,LangID)
	FROM Inserted i
WHERE i.GblNUM IS NOT NULL
	AND NOT EXISTS(SELECT * FROM dbo.CIC_BaseTable_Description cbtd WHERE cbtd.NUM=i.GblNUM AND cbtd.LangID=i.LangID)

UPDATE vod
	SET	CMP_InternalMemo=dbo.fn_GBL_VNUMToRecordNote('INTERNAL_MEMO',VNUM,LangID)
	FROM VOL_Opportunity_Description vod
	WHERE EXISTS(SELECT * FROM Inserted i WHERE i.VolVNUM=vod.VNUM AND i.LangID=vod.LangID)
		OR EXISTS(SELECT * FROM Deleted d WHERE d.VolVNUM=vod.VNUM AND d.LangID=vod.LangID)

SET NOCOUNT OFF
GO



ALTER TABLE [dbo].[GBL_RecordNote] ADD CONSTRAINT [FK_GBL_RecordNote_GBL_FieldOption] FOREIGN KEY ([GblNoteType]) REFERENCES [dbo].[GBL_FieldOption] ([FieldName]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_RecordNote] ADD CONSTRAINT [FK_GBL_RecordNote_GBL_BaseTable_Description] FOREIGN KEY ([GblNUM], [LangID]) REFERENCES [dbo].[GBL_BaseTable_Description] ([NUM], [LangID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_RecordNote] WITH NOCHECK ADD CONSTRAINT [FK_GBL_RecordNote_GBL_RecordNote_Type] FOREIGN KEY ([NoteTypeID]) REFERENCES [dbo].[GBL_RecordNote_Type] ([NoteTypeID]) ON DELETE SET NULL NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[GBL_RecordNote] ADD CONSTRAINT [FK_GBL_RecordNote_VOL_FieldOption] FOREIGN KEY ([VolNoteType]) REFERENCES [dbo].[VOL_FieldOption] ([FieldName]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_RecordNote] ADD CONSTRAINT [FK_GBL_RecordNote_VOL_Opportunity_Description_OPDID] FOREIGN KEY ([VolOPDID]) REFERENCES [dbo].[VOL_Opportunity_Description] ([OPD_ID]) ON DELETE CASCADE


GO
ALTER TABLE [dbo].[GBL_RecordNote] NOCHECK CONSTRAINT [FK_GBL_RecordNote_GBL_RecordNote_Type]
GO
GRANT SELECT ON  [dbo].[GBL_RecordNote] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_RecordNote] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_RecordNote] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_RecordNote] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_RecordNote] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_RecordNote] TO [cioc_vol_search_role]
GO
