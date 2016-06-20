CREATE TABLE [dbo].[GBL_StandardEmailUpdate]
(
[EmailID] [int] NOT NULL IDENTITY(1, 1),
[Domain] [tinyint] NOT NULL,
[StdForMultipleRecords] [bit] NOT NULL CONSTRAINT [DF_GBL_StandardEmailUpdate_StdForMultipleRecords] DEFAULT ((0)),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_StandardEmailUpdate_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_StandardEmailUpdate_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[StdSubjectBilingual] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_GBL_StandardEmailUpdate_StdSubjectBilingual] DEFAULT ('Request to update listing / Demande de mise à jour'),
[DefaultMsg] [bit] NOT NULL CONSTRAINT [DF_GBL_StandardEmailUpdate_DefaultMsg] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_StandardEmailUpdate] WITH NOCHECK ADD CONSTRAINT [CK_GBL_StandardEmailUpdate] CHECK (([Domain]>(0) AND [Domain]<=(2)))
GO
ALTER TABLE [dbo].[GBL_StandardEmailUpdate] ADD CONSTRAINT [PK_GBL_StandardEmailUpdate] PRIMARY KEY CLUSTERED  ([EmailID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_StandardEmailUpdate] ADD CONSTRAINT [FK_GBL_StandardEmailUpdate_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
