CREATE TABLE [dbo].[GBL_SavedSearch]
(
[SSRCH_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[User_ID] [int] NOT NULL,
[SearchName] [varchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Domain] [tinyint] NOT NULL,
[LangID] [smallint] NOT NULL CONSTRAINT [DF_GBL_SavedSearch_Equivalent] DEFAULT ((0)),
[WhereClause] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NOT NULL,
[IncludeDeleted] [bit] NOT NULL CONSTRAINT [DF_GBL_SavedSearch_IncludeDeleted] DEFAULT ((0)),
[Notes] [varchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[UpgradeVerified] [bit] NOT NULL CONSTRAINT [DF_GBL_SavedSearch_UpgradeVerfied] DEFAULT ((0))
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SavedSearch] WITH NOCHECK ADD CONSTRAINT [CK_GBL_SavedSearch] CHECK (([Domain]>(0) AND [Domain]<=(2)))
GO
ALTER TABLE [dbo].[GBL_SavedSearch] ADD CONSTRAINT [PK_GBL_SavedSearch] PRIMARY KEY CLUSTERED  ([SSRCH_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SavedSearch] ADD CONSTRAINT [FK_GBL_SavedSearch_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_SavedSearch] WITH NOCHECK ADD CONSTRAINT [FK_GBL_SavedSearch_GBL_Users] FOREIGN KEY ([User_ID]) REFERENCES [dbo].[GBL_Users] ([User_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[GBL_SavedSearch] TO [cioc_login_role]
GO
