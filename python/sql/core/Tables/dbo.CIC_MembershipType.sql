CREATE TABLE [dbo].[CIC_MembershipType]
(
[MT_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_BUS_MembershipType_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_MembershipType] ADD CONSTRAINT [PK_CIC_MembershipType] PRIMARY KEY CLUSTERED  ([MT_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_MembershipType] ADD CONSTRAINT [FK_CIC_MembershipType_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CIC_MembershipType] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_MembershipType] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_MembershipType] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_MembershipType] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_MembershipType] TO [cioc_login_role]
GO
