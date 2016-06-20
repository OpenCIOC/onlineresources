CREATE TABLE [dbo].[CIC_Activity_Status]
(
[ASTAT_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_CIC_Activity_Status_DisplayOrder] DEFAULT ((0)),
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Activity_Status] ADD CONSTRAINT [PK_CIC_Activity_Status] PRIMARY KEY CLUSTERED  ([ASTAT_ID]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[CIC_Activity_Status] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Activity_Status] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Activity_Status] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Activity_Status] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_Activity_Status] TO [cioc_login_role]
GO
