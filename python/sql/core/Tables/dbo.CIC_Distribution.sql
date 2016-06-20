CREATE TABLE [dbo].[CIC_Distribution]
(
[DST_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[DistCode] [varchar] (20) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Distribution] ADD CONSTRAINT [PK_CIC_Distribution] PRIMARY KEY CLUSTERED  ([DST_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_Distribution] ON [dbo].[CIC_Distribution] ([DistCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Distribution] ADD CONSTRAINT [FK_CIC_Distribution_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_Distribution] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Distribution] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Distribution] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_Distribution] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_Distribution] TO [cioc_login_role]
GO
