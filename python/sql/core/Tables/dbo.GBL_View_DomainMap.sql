CREATE TABLE [dbo].[GBL_View_DomainMap]
(
[DMAP_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_View_DomainMap_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_GBL_View_DomainMap_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[DomainName] [varchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[PathToStart] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[DefaultLangID] [smallint] NOT NULL,
[CICViewType] [int] NULL,
[VOLViewType] [int] NULL,
[SecondaryName] [bit] NOT NULL CONSTRAINT [DF_GBL_View_DomainMap_SecondaryName] DEFAULT ((0)),
[GoogleMapsAPIKeyCIC] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[GoogleMapsClientIDCIC] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[GoogleMapsChannelCIC] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[GoogleMapsAPIKeyVOL] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[GoogleMapsClientIDVOL] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[GoogleMapsChannelVOL] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[GoogleAnalyticsCode] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[GoogleAnalyticsAgencyDimension] [tinyint] NULL,
[GoogleAnalyticsLanguageDimension] [tinyint] NULL,
[GoogleAnalyticsDomainDimension] [tinyint] NULL,
[GoogleAnalyticsResultsCountMetric] [tinyint] NULL,
[SecondGoogleAnalyticsCode] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[SecondGoogleAnalyticsAgencyDimension] [tinyint] NULL,
[SecondGoogleAnalyticsLanguageDimension] [tinyint] NULL,
[SecondGoogleAnalyticsDomainDimension] [tinyint] NULL,
[SecondGoogleAnalyticsResultsCountMetric] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_View_DomainMap] ADD CONSTRAINT [PK_GBL_View_DomainMap] PRIMARY KEY CLUSTERED  ([DMAP_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_View_DomainMap] ADD CONSTRAINT [IX_GBL_View_DomainMap] UNIQUE NONCLUSTERED  ([DomainName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_View_DomainMap] WITH NOCHECK ADD CONSTRAINT [FK_GBL_View_DomainMap_CIC_View] FOREIGN KEY ([CICViewType]) REFERENCES [dbo].[CIC_View] ([ViewType])
GO
ALTER TABLE [dbo].[GBL_View_DomainMap] ADD CONSTRAINT [FK_GBL_View_DomainMap_STP_Language] FOREIGN KEY ([DefaultLangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_View_DomainMap] ADD CONSTRAINT [FK_GBL_View_DomainMap_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[GBL_View_DomainMap] WITH NOCHECK ADD CONSTRAINT [FK_GBL_View_DomainMap_VOL_View] FOREIGN KEY ([VOLViewType]) REFERENCES [dbo].[VOL_View] ([ViewType])
GO
ALTER TABLE [dbo].[GBL_View_DomainMap] NOCHECK CONSTRAINT [FK_GBL_View_DomainMap_CIC_View]
GO
ALTER TABLE [dbo].[GBL_View_DomainMap] NOCHECK CONSTRAINT [FK_GBL_View_DomainMap_VOL_View]
GO
