CREATE TABLE [dbo].[GBL_SignatureStatus]
(
[SIG_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_GBL_SignatureStatus_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_SignatureStatus] ADD CONSTRAINT [PK_GBL_Signature] PRIMARY KEY CLUSTERED  ([SIG_ID]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_SignatureStatus] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_SignatureStatus] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_SignatureStatus] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_SignatureStatus] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_SignatureStatus] TO [cioc_login_role]
GO
