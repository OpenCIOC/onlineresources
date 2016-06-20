CREATE TABLE [dbo].[CIC_Quality]
(
[RQ_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[Quality] [char] (1) COLLATE Latin1_General_100_CI_AI NOT NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_CIC_Quality_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Quality] ADD CONSTRAINT [PK_CIC_Quality] PRIMARY KEY CLUSTERED  ([RQ_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_Quality] ON [dbo].[CIC_Quality] ([Quality]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Quality] ADD CONSTRAINT [FK_CIC_Quality_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_Quality] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Quality] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Quality] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Quality] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_Quality] TO [cioc_login_role]
GO
