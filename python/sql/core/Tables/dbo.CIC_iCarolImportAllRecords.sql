CREATE TABLE [dbo].[CIC_iCarolImportAllRecords]
(
[ResourceAgencyNum] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LangID] [smallint] NOT NULL,
[ParentAgencyNum] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[ConnectsToSiteNum] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[ConnectsToProgramNum] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[UniqueIDPriorSystem] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[PublicName] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TaxonomyLevelName] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[iCarolManaged] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[RecordOwner] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[UpdatedOn] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_iCarolImportAllRecords] ADD CONSTRAINT [PK_CIC_iCarolImportAllRecords] PRIMARY KEY CLUSTERED ([ResourceAgencyNum], [LangID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CIC_iCarolImportAllRecords_UniqueIDPriorSystem] ON [dbo].[CIC_iCarolImportAllRecords] ([UniqueIDPriorSystem]) ON [PRIMARY]
GO
