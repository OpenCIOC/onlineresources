CREATE TABLE [dbo].[TAX_U_RelatedConcept]
(
[RC_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [datetime] NOT NULL CONSTRAINT [DF_TAX_U_RelatedConcept_DateCreated] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [datetime] NOT NULL CONSTRAINT [DF_TAX_U_RelatedConcept_DateModified] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Code] [varchar] (6) COLLATE Latin1_General_100_CI_AI NOT NULL,
[ConceptName_en] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[ConceptName_fr] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[Authorized] [bit] NOT NULL CONSTRAINT [DF_TAX_U_RelatedConcept_Authorized] DEFAULT ((0)),
[Source] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_U_RelatedConcept] WITH NOCHECK ADD CONSTRAINT [CK_TAX_U_RelatedConcept_Code] CHECK (([Code] like '[A-Z][A-Z]' OR [Code] like '[A-Z][A-Z]-[0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[TAX_U_RelatedConcept] WITH NOCHECK ADD CONSTRAINT [CK_TAX_U_RelatedConcept_HasName] CHECK (([ConceptName_fr] IS NOT NULL OR [ConceptName_en] IS NOT NULL))
GO
ALTER TABLE [dbo].[TAX_U_RelatedConcept] ADD CONSTRAINT [PK_TAX_U_RelatedConcept] PRIMARY KEY CLUSTERED ([RC_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_U_RelatedConcept] ADD CONSTRAINT [IX_TAX_U_RelatedConcept_Code] UNIQUE NONCLUSTERED ([Code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_U_RelatedConcept] ADD CONSTRAINT [IX_TAX_U_RelatedConcept_Name] UNIQUE NONCLUSTERED ([ConceptName_en], [ConceptName_fr]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_U_RelatedConcept] WITH NOCHECK ADD CONSTRAINT [FK_TAX_U_RelatedConcept_TAX_U_Source] FOREIGN KEY ([Source]) REFERENCES [dbo].[TAX_U_Source] ([TAX_SRC_ID]) ON UPDATE CASCADE
GO
