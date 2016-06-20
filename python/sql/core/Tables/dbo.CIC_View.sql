CREATE TABLE [dbo].[CIC_View]
(
[ViewType] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_CIC_View_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_CIC_View_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[CanSeeNonPublic] [bit] NOT NULL CONSTRAINT [DF_CIC_View_CanSeeNonPublic] DEFAULT ((0)),
[CanSeeDeleted] [bit] NOT NULL CONSTRAINT [DF_CIC_View_CanSeeDeleted] DEFAULT ((0)),
[HidePastDueBy] [int] NULL,
[AlertColumn] [bit] NOT NULL CONSTRAINT [DF_CIC_View_AlertColumn] DEFAULT ((0)),
[Template] [int] NOT NULL,
[PrintTemplate] [int] NULL,
[PrintVersionResults] [bit] NOT NULL CONSTRAINT [DF_CIC_View_PrintVersionResults] DEFAULT ((1)),
[DataMgmtFields] [bit] NOT NULL CONSTRAINT [DF_CIC_View_DataMgmtFields] DEFAULT ((0)),
[LastModifiedDate] [bit] NOT NULL CONSTRAINT [DF_CIC_View_LastModifiedDate] DEFAULT ((1)),
[SocialMediaShare] [bit] NOT NULL CONSTRAINT [DF_CIC_View_SocialMedia] DEFAULT ((0)),
[CommSrchWrapAt] [tinyint] NOT NULL CONSTRAINT [DF_CIC_View_CommSrchWrapAt] DEFAULT ((3)),
[CommSrchDropDown] [bit] NOT NULL CONSTRAINT [DF_CIC_View_CommSrchDropDown] DEFAULT ((0)),
[CommSrchWithin] [bit] NOT NULL CONSTRAINT [DF_CIC_View_CommSrchWithin] DEFAULT ((0)),
[OtherCommunity] [bit] NOT NULL CONSTRAINT [DF_CIC_View_OtherCommunity] DEFAULT ((0)),
[SrchCommunityDefault] [bit] NOT NULL CONSTRAINT [DF_CIC_View_SearchCommunityDefault] DEFAULT ((0)),
[RespectPrivacyProfile] [bit] NOT NULL CONSTRAINT [DF_CIC_View_RespectPrivacyProfile] DEFAULT ((1)),
[PB_ID] [int] NULL,
[LimitedView] [bit] NOT NULL CONSTRAINT [DF_CIC_View_LimitedView] DEFAULT ((0)),
[VolunteerLink] [bit] NOT NULL CONSTRAINT [DF_CIC_View_VolunteerLink] DEFAULT ((1)),
[ASrchAddress] [bit] NOT NULL CONSTRAINT [DF_CIC_View_ASrchAddress] DEFAULT ((1)),
[ASrchAges] [bit] NOT NULL CONSTRAINT [DF_CIC_View_ASrchAges] DEFAULT ((1)),
[ASrchBool] [bit] NOT NULL CONSTRAINT [DF_CIC_View_ASrchBool] DEFAULT ((0)),
[ASrchDist] [bit] NOT NULL CONSTRAINT [DF_CIC_View_ASrchDist] DEFAULT ((1)),
[ASrchEmail] [bit] NOT NULL CONSTRAINT [DF_CIC_View_ASrchEmail] DEFAULT ((1)),
[ASrchEmployee] [bit] NOT NULL CONSTRAINT [DF_CIC_View_ASRchEmployee] DEFAULT ((0)),
[ASrchLastRequest] [bit] NOT NULL CONSTRAINT [DF_CIC_View_ASrchLastRequest] DEFAULT ((1)),
[ASrchNear] [bit] NOT NULL CONSTRAINT [DF_CIC_View_ASrchNear] DEFAULT ((0)),
[ASrchOwner] [bit] NOT NULL CONSTRAINT [DF_CIC_View_ASrchOwner] DEFAULT ((1)),
[ASrchVacancy] [bit] NOT NULL CONSTRAINT [DF_CIC_View_ASrchVacancy] DEFAULT ((0)),
[ASrchVOL] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSrchVOL1] DEFAULT ((1)),
[BSrchAutoComplete] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSrchAutoComplete] DEFAULT ((0)),
[BSrchAges] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSrchAges] DEFAULT ((0)),
[BSrchBrowseByOrg] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSrchBrowseByOrg] DEFAULT ((1)),
[BSrchLanguage] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSrchLanguage] DEFAULT ((0)),
[BSrchNUM] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSrchNUM] DEFAULT ((1)),
[BSrchOCG] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSrchOCG] DEFAULT ((0)),
[BSrchKeywords] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSrchKeywords] DEFAULT ((1)),
[BSrchVacancy] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSrchVacancy] DEFAULT ((0)),
[BSrchVOL] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSrchVOL] DEFAULT ((1)),
[BSrchWWW] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSrchWWW] DEFAULT ((1)),
[BSrchDefaultTab] [tinyint] NULL,
[CSrch] [bit] NOT NULL CONSTRAINT [DF_CIC_View_CSrch] DEFAULT ((0)),
[CSrchBusRoute] [bit] NOT NULL CONSTRAINT [DF_CIC_View_CSrchBusRoute] DEFAULT ((1)),
[CSrchKeywords] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSrchKeywords1] DEFAULT ((1)),
[CSrchLanguages] [bit] NOT NULL CONSTRAINT [DF_CIC_View_CSrchLanguages] DEFAULT ((0)),
[CSrchNear] [bit] NOT NULL CONSTRAINT [DF_CIC_View_CSrchNear] DEFAULT ((0)),
[CSrchSchoolEscort] [bit] NOT NULL CONSTRAINT [DF_CIC_View_CSrchSchoolEscort] DEFAULT ((1)),
[CSrchSchoolsInArea] [bit] NOT NULL CONSTRAINT [DF_CIC_View_CSrchSchoolsInArea] DEFAULT ((1)),
[CSrchSpaceAvailable] [bit] NOT NULL CONSTRAINT [DF_CIC_View_CSrchSpaceAvailable] DEFAULT ((1)),
[CSrchSubsidy] [bit] NOT NULL CONSTRAINT [DF_CIC_View_CSrchSubsidy] DEFAULT ((1)),
[CSrchTypeOfProgram] [bit] NOT NULL CONSTRAINT [DF_CIC_View_CSrchTypeOfProgram] DEFAULT ((1)),
[CCRFields] [bit] NOT NULL CONSTRAINT [DF_CIC_View_CCRFields] DEFAULT ((0)),
[QuickListDropDown] [tinyint] NOT NULL CONSTRAINT [DF_CIC_View_QuickListDropDown] DEFAULT ((1)),
[QuickListWrapAt] [int] NOT NULL CONSTRAINT [DF_CIC_View_QuickListWrapAt] DEFAULT ((2)),
[QuickListMatchAll] [bit] NOT NULL CONSTRAINT [DF_CIC_View_QuickListMatchAll] DEFAULT ((0)),
[QuickListSearchGroups] [bit] NOT NULL CONSTRAINT [DF_CIC_View_QuickListSearchGroups] DEFAULT ((0)),
[QuickListPubHeadings] [int] NULL,
[LinkOrgLevels] [bit] NOT NULL CONSTRAINT [DF_CIC_View_LinkOrgLevels] DEFAULT ((1)),
[CanSeeNonPublicPub] [bit] NULL CONSTRAINT [DF_CIC_View_CanSeeNonPublicPub] DEFAULT ((0)),
[UsePubNamesOnly] [bit] NOT NULL CONSTRAINT [DF_CIC_View_UsePubNamesOnly] DEFAULT ((1)),
[UseNAICSView] [bit] NOT NULL CONSTRAINT [DF_CIC_View_UseNAICSView] DEFAULT ((1)),
[UseTaxonomyView] [bit] NOT NULL CONSTRAINT [DF_CIC_View_UseTaxonomyView] DEFAULT ((0)),
[TaxDefnLevel] [int] NOT NULL CONSTRAINT [DF_CIC_View_TaxDefnLevel] DEFAULT ((0)),
[UseThesaurusView] [bit] NOT NULL CONSTRAINT [DF_CIC_View_UseThesaurusView] DEFAULT ((1)),
[UseLocalSubjects] [bit] NOT NULL CONSTRAINT [DF_CIC_View_UseLocalSubjects] DEFAULT ((0)),
[UseZeroSubjects] [bit] NOT NULL CONSTRAINT [DF_CIC_View_UseZeroSubjects] DEFAULT ((1)),
[AlsoNotify] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[NoProcessNotify] [bit] NOT NULL CONSTRAINT [DF_CIC_View_NoProcessNotify] DEFAULT ((0)),
[UseSubmitChangesTo] [bit] NOT NULL CONSTRAINT [DF_CIC_View_UseSubmitChangesTo] DEFAULT ((0)),
[DataUseAuth] [bit] NOT NULL CONSTRAINT [DF_CIC_View_DataUseAuth] DEFAULT ((0)),
[DataUseAuthPhone] [bit] NOT NULL CONSTRAINT [DF_CIC_View_DataUseAuthPhone] DEFAULT ((1)),
[MapSearchResults] [bit] NOT NULL CONSTRAINT [DF_CIC_View_MapSearchResults] DEFAULT ((0)),
[Owner] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[MyList] [bit] NOT NULL CONSTRAINT [DF_CIC_View_MyList] DEFAULT ((0)),
[ViewOtherLangs] [bit] NOT NULL CONSTRAINT [DF_CIC_View_ViewOtherLangs] DEFAULT ((1)),
[AllowFeedbackNotInView] [bit] NOT NULL CONSTRAINT [DF_CIC_View_AllowFeedbackNotInView] DEFAULT ((1)),
[AssignSuggestionsTo] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[ResultsPageSize] [smallint] NULL,
[AllowPDF] [bit] NOT NULL CONSTRAINT [DF_CIC_View_AllowPDF] DEFAULT ((0)),
[ShowRecordDetailsSidebar] [bit] NOT NULL CONSTRAINT [DF_CIC_View_ShowASSSidebar] DEFAULT ((0)),
[GoogleTranslateWidget] [bit] NOT NULL CONSTRAINT [DF_CIC_View_GoogleTranslateWidget] DEFAULT ((0)),
[BSrchNear5] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSearchNear05] DEFAULT ((0)),
[BSrchNear10] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSearchNear10] DEFAULT ((0)),
[BSrchNear15] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSearchNear15] DEFAULT ((0)),
[BSrchNear25] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSearchNear25] DEFAULT ((0)),
[BSrchNear50] [bit] NOT NULL CONSTRAINT [DF_CIC_View_BSearchNear50] DEFAULT ((0))
) ON [PRIMARY]
ALTER TABLE [dbo].[CIC_View] ADD 
CONSTRAINT [PK_CIC_View] PRIMARY KEY CLUSTERED  ([ViewType]) ON [PRIMARY]
CREATE UNIQUE NONCLUSTERED INDEX [IX_CIC_View_ViewTypeInclViewCriteria] ON [dbo].[CIC_View] ([ViewType]) INCLUDE ([CanSeeDeleted], [CanSeeNonPublic], [HidePastDueBy], [MemberID], [PB_ID]) ON [PRIMARY]

ALTER TABLE [dbo].[CIC_View] WITH NOCHECK ADD
CONSTRAINT [CK_CIC_View_TaxDefnLevel] CHECK (([TaxDefnLevel]>=(0) AND [TaxDefnLevel]<=(5)))
ALTER TABLE [dbo].[CIC_View] ADD
CONSTRAINT [FK_CIC_View_CIC_Publication_Quicklist] FOREIGN KEY ([QuickListPubHeadings]) REFERENCES [dbo].[CIC_Publication] ([PB_ID])
















GO

ALTER TABLE [dbo].[CIC_View] ADD CONSTRAINT [FK_CIC_View_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[CIC_View] ADD CONSTRAINT [FK_CIC_View_GBL_Agency] FOREIGN KEY ([Owner]) REFERENCES [dbo].[GBL_Agency] ([AgencyCode]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[CIC_View] WITH NOCHECK ADD CONSTRAINT [FK_CIC_View_CIC_Publication] FOREIGN KEY ([PB_ID]) REFERENCES [dbo].[CIC_Publication] ([PB_ID])
GO
ALTER TABLE [dbo].[CIC_View] ADD CONSTRAINT [FK_CIC_View_GBL_Template_Print] FOREIGN KEY ([PrintTemplate]) REFERENCES [dbo].[GBL_Template] ([Template_ID])
GO
ALTER TABLE [dbo].[CIC_View] ADD CONSTRAINT [FK_CIC_View_GBL_Template] FOREIGN KEY ([Template]) REFERENCES [dbo].[GBL_Template] ([Template_ID])
GO
GRANT SELECT ON  [dbo].[CIC_View] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_View] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[CIC_View] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[CIC_View] TO [cioc_login_role]
GO
