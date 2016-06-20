CREATE TABLE [dbo].[GBL_BoxType]
(
[BT_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[BoxType] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BoxType] ADD CONSTRAINT [PK_GBL_BoxType] PRIMARY KEY CLUSTERED  ([BT_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_BoxType] ADD CONSTRAINT [IX_GBL_BoxType] UNIQUE NONCLUSTERED  ([BoxType]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_BoxType] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_BoxType] TO [cioc_vol_search_role]
GO
