CREATE TABLE [dbo].[TAX_U_Source]
(
[TAX_SRC_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [datetime] NOT NULL CONSTRAINT [DF_TAX_U_Source_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [datetime] NOT NULL CONSTRAINT [DF_TAX_U_Source_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[SourceName_en] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL,
[SourceName_fr] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_U_Source] ADD CONSTRAINT [PK_TAX_U_SourceType] PRIMARY KEY CLUSTERED ([TAX_SRC_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_U_Source] ADD CONSTRAINT [IX_TAX_U_Source] UNIQUE NONCLUSTERED ([SourceName_en]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_U_Source] ADD CONSTRAINT [IX_TAX_U_Source_Name] UNIQUE NONCLUSTERED ([SourceName_en], [SourceName_fr]) ON [PRIMARY]
GO