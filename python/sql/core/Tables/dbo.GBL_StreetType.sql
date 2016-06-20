CREATE TABLE [dbo].[GBL_StreetType]
(
[SType_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[StreetType] [nvarchar] (20) COLLATE Latin1_General_100_CS_AS NOT NULL,
[LangID] [smallint] NOT NULL CONSTRAINT [DF_GBL_StreetType_French] DEFAULT ((0)),
[AfterName] [bit] NOT NULL CONSTRAINT [DF_GBL_StreetType_Orientation] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_StreetType] ADD CONSTRAINT [PK_GBL_StreetType] PRIMARY KEY CLUSTERED  ([SType_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_StreetType] ADD CONSTRAINT [IX_GBL_StreetType] UNIQUE NONCLUSTERED  ([StreetType], [LangID], [AfterName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_StreetType_StreetTypeLangIDInclDefaultOrientation] ON [dbo].[GBL_StreetType] ([StreetType], [LangID]) INCLUDE ([AfterName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_StreetType] ADD CONSTRAINT [FK_GBL_StreetType_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
GRANT SELECT ON  [dbo].[GBL_StreetType] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_StreetType] TO [cioc_vol_search_role]
GO
