CREATE TABLE [dbo].[TAX_RelatedConcept_Name]
(
[RC_NAME_ID] [int] NOT NULL IDENTITY(1, 1),
[RC_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[ConceptName] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_RelatedConcept_Name] ADD CONSTRAINT [PK_TAX_RelatedConcept_Name] PRIMARY KEY CLUSTERED  ([RC_NAME_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TAX_RelatedConcept_Name_Name] ON [dbo].[TAX_RelatedConcept_Name] ([LangID], [ConceptName]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TAX_RelatedConcept_Name_IDs] ON [dbo].[TAX_RelatedConcept_Name] ([RC_ID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_RelatedConcept_Name] ADD CONSTRAINT [FK_TAX_RelatedConcept_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[TAX_RelatedConcept_Name] ADD CONSTRAINT [FK_TAX_RelatedConcept_Name_TAX_RelatedConcept] FOREIGN KEY ([RC_ID]) REFERENCES [dbo].[TAX_RelatedConcept] ([RC_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[TAX_RelatedConcept_Name] TO [cioc_cic_search_role]
GO
CREATE FULLTEXT INDEX ON [dbo].[TAX_RelatedConcept_Name] KEY INDEX [PK_TAX_RelatedConcept_Name] ON [Taxonomy] WITH STOPLIST [CIOC_DEFAULT_STOPLIST]
GO
ALTER FULLTEXT INDEX ON [dbo].[TAX_RelatedConcept_Name] ADD ([ConceptName] LANGUAGE 1033)
GO
