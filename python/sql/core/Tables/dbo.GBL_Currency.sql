CREATE TABLE [dbo].[GBL_Currency]
(
[CUR_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[Currency] [char] (3) COLLATE Latin1_General_100_CI_AI NOT NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_GBL_Currency_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Currency] ADD CONSTRAINT [PK_GBL_Currency] PRIMARY KEY CLUSTERED  ([CUR_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_Currency] ON [dbo].[GBL_Currency] ([Currency]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Currency] ADD CONSTRAINT [FK_GBL_Currency_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[GBL_Currency] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_Currency] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_Currency] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_Currency] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_Currency] TO [cioc_login_role]
GO
