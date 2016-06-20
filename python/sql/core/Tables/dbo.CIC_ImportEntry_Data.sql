CREATE TABLE [dbo].[CIC_ImportEntry_Data]
(
[ER_ID] [int] NOT NULL IDENTITY(1, 1),
[EF_ID] [int] NOT NULL,
[OWNER] [char] (3) COLLATE Latin1_General_100_CI_AI NOT NULL,
[NUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NULL,
[EXTERNAL_ID] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[PRIVACY_PROFILE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[DATA] [xml] NULL,
[REPORT] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Data] ADD CONSTRAINT [CK_CIC_ImportEntry_Data] CHECK (([NUM] IS NOT NULL OR [EXTERNAL_ID] IS NOT NULL))
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Data] ADD CONSTRAINT [PK_GBL_ImportLoad_Data] PRIMARY KEY CLUSTERED  ([ER_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_ImportEntry_Data_UniqueID] ON [dbo].[CIC_ImportEntry_Data] ([EF_ID], [NUM], [EXTERNAL_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ImportEntry_Data] ADD CONSTRAINT [FK_CIC_ImportEntry_Data_CIC_ImportEntry] FOREIGN KEY ([EF_ID]) REFERENCES [dbo].[CIC_ImportEntry] ([EF_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_ImportEntry_Data] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_ImportEntry_Data] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_ImportEntry_Data] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_ImportEntry_Data] TO [cioc_login_role]
GO
