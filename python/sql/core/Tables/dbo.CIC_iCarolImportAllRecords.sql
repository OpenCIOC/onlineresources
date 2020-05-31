CREATE TABLE [dbo].[CIC_iCarolImportAllRecords]
(
[ResourceAgencyNum] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[ParentAgencyNum] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ConnectsToSiteNum] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ConnectsToProgramNum] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[UniqueIDPriorSystem] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PublicName] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TaxonomyLevelName] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[iCarolManaged] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[RecordOwner] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[UpdatedOn] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_iCarolImportAllRecords] ADD CONSTRAINT [PK_CIC_iCarolImportAllRecords] PRIMARY KEY CLUSTERED  ([ResourceAgencyNum], [LangID]) ON [PRIMARY]
GO
