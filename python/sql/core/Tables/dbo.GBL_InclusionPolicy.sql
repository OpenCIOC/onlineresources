CREATE TABLE [dbo].[GBL_InclusionPolicy]
(
[InclusionPolicyID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[PolicyTitle] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[PolicyText] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_InclusionPolicy] ADD CONSTRAINT [PK_GBL_InclusionPolicy] PRIMARY KEY CLUSTERED  ([InclusionPolicyID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_InclusionPolicy] ON [dbo].[GBL_InclusionPolicy] ([PolicyTitle], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_InclusionPolicy] ADD CONSTRAINT [FK_GBL_InclusionPolicy_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_InclusionPolicy] ADD CONSTRAINT [FK_GBL_InclusionPolicy_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[GBL_InclusionPolicy] TO [cioc_login_role]
GO
