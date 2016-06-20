CREATE TABLE [dbo].[NAICS]
(
[Code] [varchar] (6) COLLATE Latin1_General_100_CI_AI NOT NULL,
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Parent] [varchar] (6) COLLATE Latin1_General_100_CI_AI NULL,
[CompUS] [bit] NOT NULL CONSTRAINT [DF_BUS_NAICS_CompUS] DEFAULT ((1)),
[CompMex] [bit] NOT NULL CONSTRAINT [DF_BUS_NAICS_CompMex] DEFAULT ((1)),
[Source] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[SearchChildren] [varchar] (6) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NAICS] ADD CONSTRAINT [PK_NAICS] PRIMARY KEY CLUSTERED  ([Code]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_NAICS_Code] ON [dbo].[NAICS] ([Code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NAICS_CodeParent] ON [dbo].[NAICS] ([Code], [Parent]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[NAICS] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[NAICS] TO [cioc_login_role]
GO
