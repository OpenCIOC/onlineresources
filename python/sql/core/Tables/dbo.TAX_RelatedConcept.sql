CREATE TABLE [dbo].[TAX_RelatedConcept]
(
[RC_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_TAX_RelatedConcept_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_TAX_RelatedConcept_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Code] [varchar] (6) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Authorized] [bit] NOT NULL CONSTRAINT [DF_TAX_RelatedConcept_Authorized] DEFAULT ((0)),
[Source] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_RelatedConcept] WITH NOCHECK ADD CONSTRAINT [CK_TAX_RelatedConcept_Code] CHECK (([Code] like '[A-Z][A-Z]' OR [Code] like '[A-Z][A-Z]-[0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[TAX_RelatedConcept] ADD CONSTRAINT [PK_TAX_RelatedConcept] PRIMARY KEY CLUSTERED  ([RC_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_RelatedConcept] ADD CONSTRAINT [IX_TAX_RelatedConcept_Code] UNIQUE NONCLUSTERED  ([Code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_RelatedConcept] WITH NOCHECK ADD CONSTRAINT [FK_TAX_RelatedConcept_TAX_Source] FOREIGN KEY ([Source]) REFERENCES [dbo].[TAX_Source] ([TAX_SRC_ID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[TAX_RelatedConcept] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[TAX_RelatedConcept] TO [cioc_login_role]
GO
