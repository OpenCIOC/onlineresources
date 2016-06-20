CREATE TABLE [dbo].[VOL_Skill]
(
[SK_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_VOL_Skill_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Skill] ADD CONSTRAINT [PK_VOL_Skill] PRIMARY KEY CLUSTERED  ([SK_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Skill] ADD CONSTRAINT [FK_VOL_Skill_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[VOL_Skill] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Skill] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_Skill] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_Skill] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Skill] TO [cioc_vol_search_role]
GO
