CREATE TABLE [dbo].[VOL_View]
(
[ViewType] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[CommunitySetID] [int] NOT NULL,
[CanSeeNonPublic] [bit] NOT NULL CONSTRAINT [DF_VOL_View_CanSeeNonPublic] DEFAULT ((0)),
[CanSeeDeleted] [bit] NOT NULL CONSTRAINT [DF_VOL_View_CanSeeDeleted] DEFAULT ((0)),
[CanSeeExpired] [bit] NOT NULL CONSTRAINT [DF_VOL_View_CanSeeExpired] DEFAULT ((0)),
[HidePastDueBy] [int] NULL,
[AlertColumn] [bit] NOT NULL CONSTRAINT [DF_VOL_View_AlertColumn] DEFAULT ((0)),
[Template] [int] NOT NULL,
[PrintTemplate] [int] NULL,
[PrintVersionResults] [bit] NOT NULL CONSTRAINT [DF_VOL_View_PrintVersionResults] DEFAULT ((1)),
[DataMgmtFields] [bit] NOT NULL CONSTRAINT [DF_VOL_View_DataMgmtFields] DEFAULT ((0)),
[LastModifiedDate] [bit] NOT NULL CONSTRAINT [DF_VOL_View_LastModifiedDate] DEFAULT ((1)),
[SocialMediaShare] [bit] NOT NULL CONSTRAINT [DF_VOL_View_SocialMediaShare] DEFAULT ((0)),
[CommSrchWrapAt] [tinyint] NOT NULL CONSTRAINT [DF_VOL_View_CommSrchWrapAt] DEFAULT ((2)),
[SuggestOpLink] [bit] NOT NULL CONSTRAINT [DF_VOL_View_SuggestOpLink] DEFAULT ((1)),
[BSrchAutoComplete] [bit] NOT NULL CONSTRAINT [DF_VOL_View_BSrchAutoComplete] DEFAULT ((0)),
[BSrchBrowseAll] [bit] NOT NULL CONSTRAINT [DF_VOL_View_BSrchHideMenuBrowseAll] DEFAULT ((1)),
[BSrchBrowseByInterest] [bit] NOT NULL CONSTRAINT [DF_VOL_View_BSearchBrowseByInterest] DEFAULT ((1)),
[BSrchBrowseByOrg] [bit] NOT NULL CONSTRAINT [DF_VOL_View_BSrchBrowseByOrg] DEFAULT ((1)),
[BSrchKeywords] [bit] NOT NULL CONSTRAINT [DF_VOL_View_BSrchKeyword] DEFAULT ((1)),
[BSrchStepByStep] [bit] NOT NULL CONSTRAINT [DF_VOL_View_BSrchStepByStep] DEFAULT ((1)),
[BSrchStudent] [bit] NOT NULL CONSTRAINT [DF_VOL_View_BSrchStudent] DEFAULT ((1)),
[BSrchWhatsNew] [bit] NOT NULL CONSTRAINT [DF_VOL_View_BSrchWhatsNew] DEFAULT ((1)),
[BSrchDefaultTab] [tinyint] NULL,
[BSrchCommunity] [bit] NOT NULL CONSTRAINT [DF_VOL_View_BSrchCommunity] DEFAULT ((1)),
[BSrchCommitmentLength] [bit] NOT NULL CONSTRAINT [DF_VOL_View_BSrchDuration] DEFAULT ((1)),
[BSrchSuitableFor] [bit] NOT NULL CONSTRAINT [DF_VOL_View_BSrchSuitableFor] DEFAULT ((1)),
[ASrchAges] [bit] NOT NULL CONSTRAINT [DF_VOL_View_ASrchAges] DEFAULT ((1)),
[ASrchBool] [bit] NOT NULL CONSTRAINT [DF_VOL_View_ASrchBool] DEFAULT ((0)),
[ASrchDatesTimes] [bit] NOT NULL CONSTRAINT [DF_VOL_View_ASrchDatesTimes] DEFAULT ((1)),
[ASrchEmail] [bit] NOT NULL CONSTRAINT [DF_VOL_View_ASrchEmail] DEFAULT ((1)),
[ASrchLastRequest] [bit] NOT NULL CONSTRAINT [DF_VOL_View_ASrchLastRequest] DEFAULT ((1)),
[ASrchOwner] [bit] NOT NULL CONSTRAINT [DF_VOL_View_ASrchOwner] DEFAULT ((1)),
[ASrchOSSD] [bit] NOT NULL CONSTRAINT [DF_VOL_View_ASrchOSSD] DEFAULT ((1)),
[SSrchIndividualCount] [bit] NOT NULL CONSTRAINT [DF_VOL_View_IndividualCount] DEFAULT ((1)),
[SSrchDatesTimes] [bit] NOT NULL CONSTRAINT [DF_VOL_View_SSrchDatesTimes] DEFAULT ((1)),
[UseProfilesView] [bit] NOT NULL CONSTRAINT [DF_VOL_View_UseProfilesView] DEFAULT ((0)),
[DataUseAuth] [bit] NOT NULL CONSTRAINT [DF_VOL_View_DataUseAuth] DEFAULT ((0)),
[Owner] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[MyList] [bit] NOT NULL CONSTRAINT [DF_VOL_View_MyList] DEFAULT ((0)),
[ViewOtherLangs] [bit] NOT NULL CONSTRAINT [DF_VOL_View_ViewOtherLangs] DEFAULT ((1)),
[AllowFeedbackNotInView] [bit] NOT NULL CONSTRAINT [DF_VOL_View_AllowFeedbackNotInView] DEFAULT ((1)),
[AssignSuggestionsTo] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[AllowPDF] [bit] NOT NULL CONSTRAINT [DF_VOL_View_AllowPDF] DEFAULT ((0)),
[GoogleTranslateWidget] [bit] NOT NULL CONSTRAINT [DF_VOL_View_GoogleTranslateWidget] DEFAULT ((0)),
[DataUseAuthPhone] [bit] NOT NULL CONSTRAINT [DF_VOL_View_DataUseAuthPhone] DEFAULT ((1)),
[DefaultPrintProfile] [int] NULL,
[AcceptCookiePrompt] [bit] NOT NULL CONSTRAINT [DF_VOL_View_AcceptCookiePrompt] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View] ADD CONSTRAINT [PK_VOL_View] PRIMARY KEY CLUSTERED ([ViewType]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_View_ViewTypeInclViewCriteria] ON [dbo].[VOL_View] ([ViewType]) INCLUDE ([MemberID], [CanSeeNonPublic], [CanSeeDeleted], [CanSeeExpired], [HidePastDueBy]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_View] ADD CONSTRAINT [FK_VOL_View_GBL_Agency] FOREIGN KEY ([Owner]) REFERENCES [dbo].[GBL_Agency] ([AgencyCode]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[VOL_View] ADD CONSTRAINT [FK_VOL_View_GBL_PrintProfile] FOREIGN KEY ([DefaultPrintProfile]) REFERENCES [dbo].[GBL_PrintProfile] ([ProfileID])
GO
ALTER TABLE [dbo].[VOL_View] ADD CONSTRAINT [FK_VOL_View_GBL_Template] FOREIGN KEY ([Template]) REFERENCES [dbo].[GBL_Template] ([Template_ID])
GO
ALTER TABLE [dbo].[VOL_View] ADD CONSTRAINT [FK_VOL_View_GBL_Template_Print] FOREIGN KEY ([PrintTemplate]) REFERENCES [dbo].[GBL_Template] ([Template_ID])
GO
ALTER TABLE [dbo].[VOL_View] ADD CONSTRAINT [FK_VOL_View_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT DELETE ON  [dbo].[VOL_View] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[VOL_View] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[VOL_View] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[VOL_View] TO [cioc_vol_search_role]
GO
