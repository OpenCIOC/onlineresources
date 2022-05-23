CREATE TABLE [dbo].[GBL_Template_Description]
(
[Template_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Name] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Logo] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[LogoAltText] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[LogoLink] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[LogoMobile] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Banner] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[CopyrightNotice] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[headerGroup1] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[headerGroup2] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[headerGroup3] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[footerGroup1] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[footerGroup2] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[footerGroup3] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[cicsearchGroup1] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[cicsearchGroup2] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[cicsearchGroup3] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[volsearchGroup1] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[volsearchGroup2] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[volsearchGroup3] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[Agency] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Address] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Phone] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Email] [varchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[Web] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Facebook] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Twitter] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Instagram] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[LinkedIn] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[YouTube] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[TermsOfUseLink] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[TermsOfUseLabel] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[FooterNotice] [nvarchar] (3000) COLLATE Latin1_General_100_CI_AI NULL,
[FooterNotice2] [nvarchar] (2000) COLLATE Latin1_General_100_CI_AI NULL,
[FooterNoticeContact] [nvarchar] (2000) COLLATE Latin1_General_100_CI_AI NULL,
[HeaderNotice] [nvarchar] (2000) COLLATE Latin1_General_100_CI_AI NULL,
[HeaderNoticeMobile] [nvarchar] (1000) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Template_Description] ADD CONSTRAINT [PK_GBL_Template_Description] PRIMARY KEY CLUSTERED ([Template_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Template_Description] ADD CONSTRAINT [FK_GBL_Template_Description_GBL_Template] FOREIGN KEY ([Template_ID]) REFERENCES [dbo].[GBL_Template] ([Template_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[GBL_Template_Description] ADD CONSTRAINT [FK_GBL_Template_Description_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
