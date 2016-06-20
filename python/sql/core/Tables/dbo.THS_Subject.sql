CREATE TABLE [dbo].[THS_Subject]
(
[Subj_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[SubjGUID] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_THS_Subject_SubjGUID] DEFAULT (newid()),
[Authorized] [bit] NOT NULL,
[Used] [bit] NOT NULL CONSTRAINT [DF_THS_Subject_Used] DEFAULT ((0)),
[UseAll] [bit] NOT NULL CONSTRAINT [DF_THS_Subject_UseAll] DEFAULT ((0)),
[SRC_ID] [int] NULL,
[SubjCat_ID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_Subject] ADD CONSTRAINT [CK_THS_Subject_LocalMember] CHECK (([MemberID] IS NULL OR [Authorized]=(0)))
GO
ALTER TABLE [dbo].[THS_Subject] ADD CONSTRAINT [PK_THS_Subject] PRIMARY KEY CLUSTERED  ([Subj_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_Subject] ADD CONSTRAINT [IX_THS_Subject_GUID] UNIQUE NONCLUSTERED  ([SubjGUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_THS_Subject_IncludeAuthorized] ON [dbo].[THS_Subject] ([Subj_ID]) INCLUDE ([Authorized]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_THS_Subject_SubjIDUseAll] ON [dbo].[THS_Subject] ([Subj_ID], [UseAll]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_Subject] ADD CONSTRAINT [FK_THS_Subject_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[THS_Subject] ADD CONSTRAINT [FK_THS_Subject_THS_Source] FOREIGN KEY ([SRC_ID]) REFERENCES [dbo].[THS_Source] ([SRC_ID]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[THS_Subject] ADD CONSTRAINT [FK_THS_Subject_THS_Category] FOREIGN KEY ([SubjCat_ID]) REFERENCES [dbo].[THS_Category] ([SubjCat_ID]) ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[THS_Subject] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[THS_Subject] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[THS_Subject] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[THS_Subject] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[THS_Subject] TO [cioc_login_role]
GO
