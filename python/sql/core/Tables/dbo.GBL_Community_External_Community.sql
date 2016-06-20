CREATE TABLE [dbo].[GBL_Community_External_Community]
(
[EXT_ID] [int] NOT NULL IDENTITY(1, 1),
[EXT_GUID] [uniqueidentifier] NOT NULL,
[SystemCode] [varchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL,
[AreaName] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL,
[PrimaryAreaType] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[SubAreaType] [varchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[AIRSExportType] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[ProvinceState] [int] NULL,
[Parent_ID] [int] NULL
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_Community_External_Community] TO [cioc_cic_search_role]
GO

ALTER TABLE [dbo].[GBL_Community_External_Community] ADD CONSTRAINT [PK_GBL_Community_External_Community] PRIMARY KEY CLUSTERED  ([EXT_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_Community_External_Community] ON [dbo].[GBL_Community_External_Community] ([EXT_GUID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Community_External_Community] ADD CONSTRAINT [FK_GBL_Community_External_Community_GBL_ProvinceState] FOREIGN KEY ([ProvinceState]) REFERENCES [dbo].[GBL_ProvinceState] ([ProvID])
GO
ALTER TABLE [dbo].[GBL_Community_External_Community] ADD CONSTRAINT [FK_GBL_Community_External_Community_GBL_Community_External_System] FOREIGN KEY ([SystemCode]) REFERENCES [dbo].[GBL_Community_External_System] ([SystemCode])
GO
