CREATE TABLE [dbo].[CIC_ServiceLevel]
(
[SL_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[ServiceLevelCode] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ServiceLevel] ADD CONSTRAINT [CK_CIC_ServiceLevel] CHECK (([ServiceLevelCode]>(0) AND [ServiceLevelCode]<(100)))
GO
ALTER TABLE [dbo].[CIC_ServiceLevel] ADD CONSTRAINT [PK_CIC_ServiceLevel] PRIMARY KEY CLUSTERED  ([SL_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ServiceLevel] ADD CONSTRAINT [IX_CIC_ServiceLevel_Code] UNIQUE NONCLUSTERED  ([ServiceLevelCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_ServiceLevel] ADD CONSTRAINT [FK_CIC_ServiceLevel_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_ServiceLevel] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_ServiceLevel] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_ServiceLevel] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_ServiceLevel] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_ServiceLevel] TO [cioc_login_role]
GO
