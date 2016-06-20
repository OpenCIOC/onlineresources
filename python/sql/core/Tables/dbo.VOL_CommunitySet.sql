CREATE TABLE [dbo].[VOL_CommunitySet]
(
[CommunitySetID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_VOL_CommunitySet_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_VOL_CommunitySet_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_CommunitySet] ADD CONSTRAINT [PK_VOL_Community_Set] PRIMARY KEY CLUSTERED  ([CommunitySetID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_CommunitySet] ADD CONSTRAINT [FK_VOL_CommunitySet_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_CommunitySet] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_CommunitySet] TO [cioc_vol_search_role]
GO
