CREATE TABLE [dbo].[GBL_Community_Type]
(
[Code] [varchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL,
[AIRSExportType] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Order] [tinyint] NOT NULL CONSTRAINT [DF_GBL_Community_Type_Order_1] DEFAULT ((0))
) ON [PRIMARY]
ALTER TABLE [dbo].[GBL_Community_Type] ADD 
CONSTRAINT [PK_GBL_Community_Type] PRIMARY KEY CLUSTERED  ([Code]) ON [PRIMARY]
GO
