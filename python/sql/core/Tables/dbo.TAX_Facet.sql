CREATE TABLE [dbo].[TAX_Facet]
(
[FC_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_Facet] ADD CONSTRAINT [PK_TAX_Facet] PRIMARY KEY CLUSTERED  ([FC_ID]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[TAX_Facet] TO [cioc_cic_search_role]
GO
