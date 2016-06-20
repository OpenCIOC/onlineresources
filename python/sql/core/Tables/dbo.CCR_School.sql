CREATE TABLE [dbo].[CCR_School]
(
[SCH_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[SchoolBoard] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_School] ADD CONSTRAINT [PK_CCR_School] PRIMARY KEY CLUSTERED  ([SCH_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_School] ADD CONSTRAINT [FK_CCR_School_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[CCR_School] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CCR_School] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CCR_School] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CCR_School] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CCR_School] TO [cioc_login_role]
GO
