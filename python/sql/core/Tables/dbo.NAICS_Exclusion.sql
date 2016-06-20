CREATE TABLE [dbo].[NAICS_Exclusion]
(
[Exclusion_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Code] [varchar] (6) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[Description] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Establishment] [bit] NOT NULL CONSTRAINT [DF_BUS_NAICS_Exception_Establishment] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NAICS_Exclusion] ADD CONSTRAINT [PK_NAICS_Exception] PRIMARY KEY CLUSTERED  ([Exclusion_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NAICS_Exclusion] ADD CONSTRAINT [IX_BUS_NAICS_Exception] UNIQUE NONCLUSTERED  ([Code], [Description]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NAICS_Exclusion] WITH NOCHECK ADD CONSTRAINT [FK_NAICS_Exclusion_NAICS] FOREIGN KEY ([Code]) REFERENCES [dbo].[NAICS] ([Code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[NAICS_Exclusion] ADD CONSTRAINT [FK_NAICS_Exclusion_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[NAICS_Exclusion] TO [cioc_cic_search_role]
GO
