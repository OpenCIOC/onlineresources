CREATE TABLE [dbo].[NAICS_Exclusion_Use]
(
[ExcUse_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Exclusion_ID] [int] NOT NULL,
[UseCode] [varchar] (6) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NAICS_Exclusion_Use] ADD CONSTRAINT [PK_NAICS_Exclusion_Use] PRIMARY KEY CLUSTERED  ([ExcUse_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NAICS_Exclusion_Use] ADD CONSTRAINT [IX_NAICS_Exception_Use_UniquePair] UNIQUE NONCLUSTERED  ([Exclusion_ID], [UseCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NAICS_Exclusion_Use] WITH NOCHECK ADD CONSTRAINT [FK_NAICS_Exclusion_Use_NAICS_Exclusion] FOREIGN KEY ([Exclusion_ID]) REFERENCES [dbo].[NAICS_Exclusion] ([Exclusion_ID])
GO
ALTER TABLE [dbo].[NAICS_Exclusion_Use] WITH NOCHECK ADD CONSTRAINT [FK_NAICS_Exclusion_Use_NAICS] FOREIGN KEY ([UseCode]) REFERENCES [dbo].[NAICS] ([Code]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[NAICS_Exclusion_Use] TO [cioc_cic_search_role]
GO
