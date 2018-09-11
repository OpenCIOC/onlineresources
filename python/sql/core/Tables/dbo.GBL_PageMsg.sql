CREATE TABLE [dbo].[GBL_PageMsg]
(
[PageMsgID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[MsgTitle] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[PageMsg] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NOT NULL,
[VisiblePrintMode] [bit] NOT NULL CONSTRAINT [DF_GBL_PageMsg_VisiblePrintMode] DEFAULT ((1)),
[Bottom] [bit] NOT NULL CONSTRAINT [DF_GBL_PageMsg_Top] DEFAULT ((0)),
[LoginOnly] [bit] NOT NULL CONSTRAINT [DF_GBL_PageMsg_LoginOnly] DEFAULT ((0)),
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_GBL_PageMsg_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PageMsg] ADD CONSTRAINT [PK_STP_Page_Message] PRIMARY KEY CLUSTERED  ([PageMsgID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_PageMsg] ON [dbo].[GBL_PageMsg] ([MemberID], [MsgTitle]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PageMsg] ADD CONSTRAINT [FK_GBL_PageMsg_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_PageMsg] ADD CONSTRAINT [FK_GBL_PageMsg_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
