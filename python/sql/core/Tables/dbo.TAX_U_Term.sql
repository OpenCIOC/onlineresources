CREATE TABLE [dbo].[TAX_U_Term]
(
[TM_ID] [int] NOT NULL IDENTITY(1, 1),
[Code] [varchar] (21) COLLATE Latin1_General_100_CI_AI NOT NULL,
[CREATED_DATE] [datetime] NOT NULL CONSTRAINT [DF_TAX_U_Term_DateCreated] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [datetime] NOT NULL CONSTRAINT [DF_TAX_U_Term_DateModified] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[CdLvl1] [char] (1) COLLATE Latin1_General_100_CI_AI NOT NULL,
[CdLvl2] [varchar] (1) COLLATE Latin1_General_100_CI_AI NULL,
[CdLvl3] [varchar] (4) COLLATE Latin1_General_100_CI_AI NULL,
[CdLvl4] [varchar] (4) COLLATE Latin1_General_100_CI_AI NULL,
[CdLvl5] [varchar] (3) COLLATE Latin1_General_100_CI_AI NULL,
[CdLvl6] [varchar] (2) COLLATE Latin1_General_100_CI_AI NULL,
[CdLocal] [varchar] (1) COLLATE Latin1_General_100_CI_AI NULL,
[ParentCode] [varchar] (16) COLLATE Latin1_General_100_CI_AI NULL,
[CdLvl] [tinyint] NOT NULL CONSTRAINT [DF_TAX_U_Term_CdLvl] DEFAULT ((0)),
[Term_en] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Term_fr] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Authorized] [bit] NOT NULL CONSTRAINT [DF_TAX_U_Term_Authorized] DEFAULT ((0)),
[Active] [bit] NULL CONSTRAINT [DF_TAX_U_Term_Active] DEFAULT ((1)),
[Source] [int] NULL,
[Definition_en] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Definition_fr] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Facet] [int] NULL,
[Comments_en] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Comments_fr] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AltTerm_en] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[AltTerm_fr] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[AltDefinition_en] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AltDefinition_fr] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[BiblioRef_en] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[BiblioRef_fr] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[IconURL] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_U_Term] WITH NOCHECK ADD CONSTRAINT [CK_TAX_U_Term_CdLocal] CHECK (([dbo].[fn_TAX_CheckLocal]([CdLocal],[Authorized])=(0)))
GO
ALTER TABLE [dbo].[TAX_U_Term] WITH NOCHECK ADD CONSTRAINT [CK_TAX_U_Term_CdLvl] CHECK (([CdLvl]>=(1) AND [CdLvl]<=(6)))
GO
ALTER TABLE [dbo].[TAX_U_Term] WITH NOCHECK ADD CONSTRAINT [CK_TAX_U_Term_CdLvl1] CHECK (([CdLvl1] like '[A-Z]'))
GO
ALTER TABLE [dbo].[TAX_U_Term] WITH NOCHECK ADD CONSTRAINT [CK_TAX_U_Term_CdLvl2] CHECK (([CdLvl2] like '[A-Z]'))
GO
ALTER TABLE [dbo].[TAX_U_Term] WITH NOCHECK ADD CONSTRAINT [CK_TAX_U_Term_CdLvl3] CHECK (([CdLvl3] like '[0-9][0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[TAX_U_Term] WITH NOCHECK ADD CONSTRAINT [CK_TAX_U_Term_CdLvl4] CHECK (([CdLvl4] like '[0-9][0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[TAX_U_Term] WITH NOCHECK ADD CONSTRAINT [CK_TAX_U_Term_CdLvl5] CHECK (([CdLvl5] like '[0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[TAX_U_Term] WITH NOCHECK ADD CONSTRAINT [CK_TAX_U_Term_CdLvl6] CHECK (([CdLvl6] like '[0-9][0-9]'))
GO
ALTER TABLE [dbo].[TAX_U_Term] WITH NOCHECK ADD CONSTRAINT [CK_TAX_U_Term_HasName] CHECK (([Term_en] IS NOT NULL OR [Term_fr] IS NOT NULL))
GO
ALTER TABLE [dbo].[TAX_U_Term] ADD CONSTRAINT [PK_TAX_U_Term] PRIMARY KEY CLUSTERED ([Code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_U_Term] ADD CONSTRAINT [IX_TAX_U_Term_Code] UNIQUE NONCLUSTERED ([CdLvl1], [CdLvl2], [CdLvl3], [CdLvl4], [CdLvl5], [CdLvl6], [CdLocal]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_U_Term] ADD CONSTRAINT [IX_TAX_U_Term_FullCode] UNIQUE NONCLUSTERED ([Code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_U_Term] WITH NOCHECK ADD CONSTRAINT [FK_TAX_U_Term_TAX_U_Facet] FOREIGN KEY ([Facet]) REFERENCES [dbo].[TAX_U_Facet] ([FC_ID]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[TAX_U_Term] WITH NOCHECK ADD CONSTRAINT [FK_TAX_U_Term_TAX_U_SourceType] FOREIGN KEY ([Source]) REFERENCES [dbo].[TAX_U_Source] ([TAX_SRC_ID])
GO
