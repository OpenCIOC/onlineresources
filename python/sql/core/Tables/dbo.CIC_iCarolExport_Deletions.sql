CREATE TABLE [dbo].[CIC_iCarolExport_Deletions]
(
[EXTERNAL_ID] [varchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NOT NULL,
[OLS_ID] [int] NOT NULL,
[DELETION_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_CIC_iCarolExport_Deletions_DELETION_DATE] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_iCarolExport_Deletions] ADD CONSTRAINT [PK_CIC_iCarolExport_Deletions] PRIMARY KEY CLUSTERED ([EXTERNAL_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_iCarolExport_Deletions] ADD CONSTRAINT [FK_CIC_iCarolExport_Deletions_GBL_OrgLocationService] FOREIGN KEY ([OLS_ID]) REFERENCES [dbo].[GBL_OrgLocationService] ([OLS_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
