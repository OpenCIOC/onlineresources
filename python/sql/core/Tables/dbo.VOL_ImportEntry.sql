CREATE TABLE [dbo].[VOL_ImportEntry]
(
[EF_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[FileName] [varchar] (255) COLLATE Latin1_General_100_CI_AS NOT NULL,
[DisplayName] [varchar] (255) COLLATE Latin1_General_100_CI_AS NULL,
[LoadDate] [datetime] NOT NULL CONSTRAINT [DF_VOL_ImportEntry_LoadDate] DEFAULT (getdate()),
[LoadedBy] [varchar] (50) COLLATE Latin1_General_100_CI_AS NULL,
[QDate] [datetime] NULL,
[QBy] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[QOwnerConflict] [smallint] NULL,
[QImportSourceDbInfo] [bit] NOT NULL CONSTRAINT [DF_VOL_ImportEntry_QImportSourceDbInfo] DEFAULT ((0)),
[QPublicConflict] [smallint] NULL,
[QDeletedConflict] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_ImportEntry] ADD CONSTRAINT [PK_VOL_ImportEntry] PRIMARY KEY CLUSTERED  ([EF_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_ImportEntry] ADD CONSTRAINT [FK_VOL_ImportEntry_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
