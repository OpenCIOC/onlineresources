CREATE TABLE [dbo].[GBL_SearchTips]
(
[SearchTipsID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[Domain] [tinyint] NOT NULL,
[LangID] [smallint] NOT NULL,
[PageTitle] [varchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[PageText] [varchar] (max) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SearchTips] ADD CONSTRAINT [CK_GBL_SearchTips] CHECK (([Domain]>(0) AND [Domain]<=(2)))
GO
ALTER TABLE [dbo].[GBL_SearchTips] ADD CONSTRAINT [PK_GBL_SearchTips] PRIMARY KEY CLUSTERED  ([SearchTipsID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_SearchTips] ON [dbo].[GBL_SearchTips] ([PageTitle], [MemberID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SearchTips] ADD CONSTRAINT [FK_GBL_SearchTips_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_SearchTips] ADD CONSTRAINT [FK_GBL_SearchTips_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[GBL_SearchTips] TO [cioc_login_role]
GO
