CREATE TABLE [dbo].[GBL_PrintProfile]
(
[ProfileID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[Domain] [tinyint] NOT NULL,
[StyleSheet] [varchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[TableClass] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MsgBeforeRecord] [bit] NOT NULL CONSTRAINT [DF_GBL_PrintProfile_MsgBeforeRecord] DEFAULT ((0)),
[Separator] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[PageBreak] [bit] NOT NULL CONSTRAINT [DF_GBL_PrintProfile_PageBreak] DEFAULT ((0)),
[Public] [bit] NOT NULL CONSTRAINT [DF_GBL_PrintProfile_Public] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrintProfile] WITH NOCHECK ADD CONSTRAINT [CK_GBL_PrintProfile] CHECK (([Domain]>(0) AND [Domain]<=(2)))
GO
ALTER TABLE [dbo].[GBL_PrintProfile] ADD CONSTRAINT [PK_GBL_PrintProfile] PRIMARY KEY CLUSTERED  ([ProfileID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_PrintProfile] ADD CONSTRAINT [FK_GBL_PrintProfile_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
