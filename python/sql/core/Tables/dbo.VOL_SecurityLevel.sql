CREATE TABLE [dbo].[VOL_SecurityLevel]
(
[SL_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[Owner] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[ViewType] [int] NOT NULL,
[CanAccessProfiles] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_CanAccessProfiles] DEFAULT ((0)),
[CanAddRecord] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_CanAddRecord] DEFAULT ((0)),
[CanAddSQL] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_CanAddSQL] DEFAULT ((0)),
[CanAssignFeedback] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_CanAssignFeedback] DEFAULT ((0)),
[CanCopyRecord] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_CanCopyRecord] DEFAULT ((0)),
[CanDeleteRecord] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_CanDeleteRecord] DEFAULT ((0)),
[CanDoBulkOps] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_CanDoBulkOps] DEFAULT ((0)),
[CanDoFullUpdate] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_CanDoFullUpdate] DEFAULT ((0)),
[CanEditRecord] [tinyint] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_CanEditRecord] DEFAULT ((0)),
[EditByViewList] [bit] NULL,
[CanManageMembers] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_CanManageMembers] DEFAULT ((0)),
[CanManageReferrals] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_CanManageReferrals] DEFAULT ((0)),
[CanManageUsers] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_CanManageUsers] DEFAULT ((0)),
[CanRequestUpdate] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_CanRequestUpdate] DEFAULT ((0)),
[CanViewStats] [tinyint] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_CanViewStats] DEFAULT ((0)),
[SuppressNotifyEmail] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_SuppressNotifyEmail] DEFAULT ((0)),
[FeedbackAlert] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_FeedbackAlert] DEFAULT ((0)),
[CommentAlert] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_CommentAlert] DEFAULT ((0)),
[WebDeveloper] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_WebDeveloper] DEFAULT ((0)),
[SuperUser] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_SuperUser] DEFAULT ((0)),
[SuperUserGlobal] [bit] NOT NULL CONSTRAINT [DF_VOL_SecurityLevel_SuperUserGlobal] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_SecurityLevel] WITH NOCHECK ADD CONSTRAINT [CK_VOL_SecurityLevel_CanEditRecord] CHECK (([CanEditRecord]>=(0) AND [CanEditRecord]<=(3)))
GO
ALTER TABLE [dbo].[VOL_SecurityLevel] ADD CONSTRAINT [CK_VOL_SecurityLevel_GlobalSuperIsSuper] CHECK (([SuperUserGlobal]=(0) OR [SuperUser]=(1)))
GO
ALTER TABLE [dbo].[VOL_SecurityLevel] ADD CONSTRAINT [CK_VOL_SecurityLevel_WebDevOrSuper] CHECK (([WebDeveloper]=(0) OR [SuperUser]=(0)))
GO
ALTER TABLE [dbo].[VOL_SecurityLevel] ADD CONSTRAINT [PK_VOL_SecurityLevel] PRIMARY KEY CLUSTERED  ([SL_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_SecurityLevel] ADD CONSTRAINT [FK_VOL_SecurityLevel_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[VOL_SecurityLevel] ADD CONSTRAINT [FK_VOL_SecurityLevel_GBL_Agency] FOREIGN KEY ([Owner]) REFERENCES [dbo].[GBL_Agency] ([AgencyCode]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_SecurityLevel] WITH NOCHECK ADD CONSTRAINT [FK_VOL_SecurityLevel_VOL_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[VOL_View] ([ViewType])
GO
GRANT SELECT ON  [dbo].[VOL_SecurityLevel] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_SecurityLevel] TO [cioc_vol_search_role]
GO
