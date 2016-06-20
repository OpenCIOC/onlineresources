CREATE TABLE [dbo].[GBL_Community_AIRSType]
(
[AIRSExportType] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Order] [tinyint] NOT NULL CONSTRAINT [DF_GBL_Community_AIRSType_Order] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Community_AIRSType] ADD CONSTRAINT [PK_GBL_Community_AIRSType] PRIMARY KEY CLUSTERED  ([AIRSExportType]) ON [PRIMARY]
GO
