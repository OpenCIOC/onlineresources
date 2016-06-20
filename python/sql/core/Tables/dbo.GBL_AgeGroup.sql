CREATE TABLE [dbo].[GBL_AgeGroup]
(
[AgeGroup_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[MinAge] [decimal] (5, 2) NULL,
[MaxAge] [decimal] (5, 2) NULL,
[CCR] [bit] NOT NULL CONSTRAINT [DF_GBL_AgeGroup_CCR] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_AgeGroup] ADD CONSTRAINT [PK_GBL_AgeGroups] PRIMARY KEY CLUSTERED  ([AgeGroup_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_AgeGroup] ADD CONSTRAINT [FK_GBL_AgeGroup_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[GBL_AgeGroup] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[GBL_AgeGroup] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[GBL_AgeGroup] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[GBL_AgeGroup] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[GBL_AgeGroup] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[GBL_AgeGroup] TO [cioc_vol_search_role]
GO
