CREATE TABLE [dbo].[GBL_ProvinceState_Name]
(
[ProvID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_ProvinceState_Name] ADD CONSTRAINT [PK_GBL_ProvinceState_Name] PRIMARY KEY CLUSTERED  ([ProvID], [LangID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_ProvinceState_Name] ADD CONSTRAINT [FK_GBL_ProvinceState_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[GBL_ProvinceState_Name] ADD CONSTRAINT [FK_GBL_ProvinceState_Name_GBL_ProvinceState] FOREIGN KEY ([ProvID]) REFERENCES [dbo].[GBL_ProvinceState] ([ProvID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
