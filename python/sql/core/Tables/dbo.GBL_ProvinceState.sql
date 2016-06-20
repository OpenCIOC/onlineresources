CREATE TABLE [dbo].[GBL_ProvinceState]
(
[ProvID] [int] NOT NULL IDENTITY(1, 1),
[NameOrCode] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[Country] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Authorized] [bit] NOT NULL CONSTRAINT [DF_GBL_ProvinceState_Authorized] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_ProvinceState] ADD CONSTRAINT [PK_GBL_ProvinceState] PRIMARY KEY CLUSTERED  ([ProvID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GBL_ProvinceState] ON [dbo].[GBL_ProvinceState] ([Country], [NameOrCode]) ON [PRIMARY]
GO
