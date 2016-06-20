CREATE TABLE [dbo].[GBL_Admin_Notice]
(
[AdminNoticeID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_GBL_Admin_Notice_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[User_ID] [int] NOT NULL,
[AdminAreaID] [int] NOT NULL,
[RequestDetail] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NOT NULL,
[PROCESSED_DATE] [datetime] NULL,
[PROCESSED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[ActionTaken] [int] NULL,
[ActionNotes] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
ALTER TABLE [dbo].[GBL_Admin_Notice] ADD
CONSTRAINT [FK_GBL_Admin_Notice_GBL_Admin_Area] FOREIGN KEY ([AdminAreaID]) REFERENCES [dbo].[GBL_Admin_Area] ([AdminAreaID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[GBL_Admin_Notice] ADD CONSTRAINT [PK_GBL_Admin_Notice] PRIMARY KEY CLUSTERED  ([AdminNoticeID]) ON [PRIMARY]
GO

ALTER TABLE [dbo].[GBL_Admin_Notice] ADD CONSTRAINT [FK_GBL_Admin_Notice_GBL_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[GBL_Users] ([User_ID])
GO
