CREATE TABLE [dbo].[GBL_RecordNote_Type]
(
[NoteTypeID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_RecordNote_Type_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_RecordNote_Type_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[HighPriority] [bit] NOT NULL CONSTRAINT [DF_GBL_NoteType_HighPriority] DEFAULT ((0)),
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_RecordNote_Type] ADD CONSTRAINT [PK_GBL_RecordNote_Type] PRIMARY KEY CLUSTERED  ([NoteTypeID]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_RecordNote_Type] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_RecordNote_Type] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_RecordNote_Type] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_RecordNote_Type] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_RecordNote_Type] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_RecordNote_Type] TO [cioc_vol_search_role]
GO
