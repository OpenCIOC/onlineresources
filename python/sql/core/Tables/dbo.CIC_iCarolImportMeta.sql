CREATE TABLE [dbo].[CIC_iCarolImportMeta]
(
[Mechanism] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LastFetched] [smalldatetime] NULL,
[ExtraCriteria] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CIC_iCarolImportMeta] TO [cioc_login_role]
GO
GRANT INSERT ON  [dbo].[CIC_iCarolImportMeta] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[CIC_iCarolImportMeta] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[CIC_iCarolImportMeta] TO [cioc_login_role]
GO
