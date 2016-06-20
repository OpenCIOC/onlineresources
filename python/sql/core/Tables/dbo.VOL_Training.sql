CREATE TABLE [dbo].[VOL_Training]
(
[TRN_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_VOL_Training_CREATED_BY] DEFAULT (getdate()),
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL CONSTRAINT [DF_VOL_Training_MODIFIED_BY] DEFAULT (getdate()),
[MemberID] [int] NULL,
[Code] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[DisplayOrder] [tinyint] NOT NULL CONSTRAINT [DF_VOL_Training_DisplayOrder] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Training] ADD CONSTRAINT [PK_VOL_Training] PRIMARY KEY CLUSTERED  ([TRN_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Training] ADD CONSTRAINT [FK_VOL_Training_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[VOL_Training] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Training] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_Training] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_Training] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Training] TO [cioc_vol_search_role]
GO
