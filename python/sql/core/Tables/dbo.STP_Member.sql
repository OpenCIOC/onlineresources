CREATE TABLE [dbo].[STP_Member]
(
[MemberID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF_STP_Member_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_STP_Member_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_STP_Member_Active] DEFAULT ((1)),
[DatabaseCode] [varchar] (15) COLLATE Latin1_General_100_CI_AI NOT NULL CONSTRAINT [DF_STP_Member_DatabaseName] DEFAULT ('CIOCDB'),
[DefaultLangID] [smallint] NOT NULL CONSTRAINT [DF_STP_Member_DefaultLangID] DEFAULT ((0)),
[AllowPublicAccess] [bit] NOT NULL CONSTRAINT [DF_STP_Member_AllowPublicAccess] DEFAULT ((1)),
[DefaultTemplate] [int] NOT NULL,
[DefaultPrintTemplate] [int] NULL,
[PrintModePublic] [bit] NOT NULL CONSTRAINT [DF_STP_Member_PrintModePublic] DEFAULT ((0)),
[TrainingMode] [bit] NOT NULL CONSTRAINT [DF_STP_Member_TrainingMode] DEFAULT ((1)),
[UseInitials] [bit] NOT NULL CONSTRAINT [DF_STP_Member_UseInitials] DEFAULT ((1)),
[DaysSinceLastEmail] [smallint] NOT NULL CONSTRAINT [DF_STP_Member_DaysSinceLastEmail] DEFAULT ((14)),
[DefaultEmailTech] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[ClientTrackerIP] [varchar] (500) COLLATE Latin1_General_100_CI_AI NULL,
[ClientTrackerRpcURL] [varchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[DefaultGCType] [tinyint] NOT NULL CONSTRAINT [DF_STP_Member_DefaultGCType] DEFAULT ((0)),
[DefaultCountry] [nvarchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[NoEmail] [bit] NOT NULL CONSTRAINT [DF_STP_Member_NoEmail] DEFAULT ((0)),
[DownloadUncompressed] [bit] NOT NULL CONSTRAINT [DF_STP_Member_DownloadUncompressed] DEFAULT ((0)),
[UseCIC] [bit] NOT NULL CONSTRAINT [DF_STP_Member_UseCIC] DEFAULT ((0)),
[DefaultViewCIC] [int] NULL,
[BaseURLCIC] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[DefaultEmailCIC] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[DefaultEmailNameCIC] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SiteCodeLength] [tinyint] NOT NULL CONSTRAINT [DF_STP_Member_SiteCodeLength] DEFAULT ((0)),
[UseTaxonomy] [bit] NOT NULL CONSTRAINT [DF_STP_Member_UseTaxonomy] DEFAULT ((0)),
[VacancyFundedCapacity] [bit] NOT NULL CONSTRAINT [DF_STP_Member_VacancyFundedCapacity] DEFAULT ((0)),
[VacancyServiceHours] [bit] NOT NULL CONSTRAINT [DF_STP_Member_VacancyServiceHours] DEFAULT ((0)),
[VacancyServiceDays] [bit] NOT NULL CONSTRAINT [DF_STP_Member_VacancyServiceDays] DEFAULT ((0)),
[VacancyServiceWeeks] [bit] NOT NULL CONSTRAINT [DF_STP_Member_VacancyServiceWeeks] DEFAULT ((0)),
[VacancyServiceFTE] [bit] NOT NULL CONSTRAINT [DF_STP_Member_VacancyServiceFTE] DEFAULT ((0)),
[CanDeleteRecordNoteCIC] [tinyint] NOT NULL CONSTRAINT [DF_STP_Member_CanDeleteRecordNoteCIC] DEFAULT ((1)),
[CanUpdateRecordNoteCIC] [tinyint] NOT NULL CONSTRAINT [DF_STP_Member_CanUpdateRecordNoteCIC] DEFAULT ((1)),
[RecordNoteTypeOptionalCIC] [bit] NOT NULL CONSTRAINT [DF_STP_Member_RecordNoteTypeOptionalCIC] DEFAULT ((1)),
[PreventDuplicateOrgNames] [tinyint] NOT NULL CONSTRAINT [DF_STP_Member_PreventDuplicateOrgNames] DEFAULT ((0)),
[UseLowestNUM] [bit] NOT NULL CONSTRAINT [DF_STP_Member_UseLowestNUM] DEFAULT ((1)),
[UseOfflineTools] [bit] NOT NULL CONSTRAINT [DF_STP_Member_UseOfflineTools] DEFAULT ((0)),
[UseVOL] [bit] NOT NULL CONSTRAINT [DF_STP_Member_UseVOL] DEFAULT ((0)),
[DefaultViewVOL] [int] NULL,
[BaseURLVOL] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[DefaultEmailVOL] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[DefaultEmailNameVOL] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[UseVolunteerProfiles] [bit] NOT NULL CONSTRAINT [DF_STP_Member_UseVolunteerProfiles] DEFAULT ((0)),
[LastVolProfileEmailDate] [smalldatetime] NULL,
[DefaultEmailVOLProfile] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[CanDeleteRecordNoteVOL] [tinyint] NOT NULL CONSTRAINT [DF_STP_Member_CanDeleteRecordNoteVOL] DEFAULT ((1)),
[CanUpdateRecordNoteVOL] [tinyint] NOT NULL CONSTRAINT [DF_STP_Member_CanUpdateRecordNoteVOL] DEFAULT ((1)),
[RecordNoteTypeOptionalVOL] [bit] NOT NULL CONSTRAINT [DF_STP_Member_RecordNoteTypeOptionalVOL] DEFAULT ((1)),
[DownloadPasswordCIC] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[DownloadPasswordVOL] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[OnlySpecificInterests] [bit] NOT NULL CONSTRAINT [DF_STP_Member_OnlySpecificInterests] DEFAULT ((0)),
[LoginRetryLimit] [tinyint] NULL,
[DefaultProvince] [varchar] (2) COLLATE Latin1_General_100_CI_AI NULL,
[UseLowestVNUM] [bit] NOT NULL CONSTRAINT [DF_STP_Member_UseLowestVNUM] DEFAULT ((1)),
[UseMemberNameAsSourceDB] [bit] NOT NULL CONSTRAINT [DF_STP_Member_UseMembershipNameAsSourceDatabaseName] DEFAULT ((0)),
[GlobalGoogleAnalyticsCode] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[GlobalGoogleAnalyticsAgencyDimension] [tinyint] NULL,
[GlobalGoogleAnalyticsLanguageDimension] [tinyint] NULL,
[GlobalGoogleAnalyticsDomainDimension] [tinyint] NULL,
[GlobalGoogleAnalyticsResultsCountMetric] [tinyint] NULL,
[BillingInfoPassword] [varchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[ImportNotificationEmailCIC] [varchar] (1000) COLLATE Latin1_General_100_CI_AI NULL,
[ImportNotificationEmailCICErrors] [varchar] (1000) COLLATE Latin1_General_100_CI_AI NULL,
[ContactOrgCIC] [bit] NOT NULL CONSTRAINT [DF_STP_Member_ContactOrgCIC] DEFAULT ((1)),
[ContactPhone1CIC] [bit] NOT NULL CONSTRAINT [DF_STP_Member_ContactPhone2CIC1] DEFAULT ((1)),
[ContactPhone2CIC] [bit] NOT NULL CONSTRAINT [DF_STP_Member_ContactPhone2CIC] DEFAULT ((1)),
[ContactPhone3CIC] [bit] NOT NULL CONSTRAINT [DF_STP_Member_ContactPhone3CIC] DEFAULT ((1)),
[ContactFaxCIC] [bit] NOT NULL CONSTRAINT [DF_STP_Member_ContactFaxCIC] DEFAULT ((1)),
[ContactEmailCIC] [bit] NOT NULL CONSTRAINT [DF_STP_Member_ContactEmailCIC] DEFAULT ((1)),
[ContactOrgVOL] [bit] NOT NULL CONSTRAINT [DF_STP_Member_ContactOrgVOL] DEFAULT ((1)),
[ContactPhone1VOL] [bit] NOT NULL CONSTRAINT [DF_STP_Member_ContactPhone1CIC1] DEFAULT ((1)),
[ContactPhone2VOL] [bit] NOT NULL CONSTRAINT [DF_STP_Member_ContactPhone2CIC1_1] DEFAULT ((1)),
[ContactPhone3VOL] [bit] NOT NULL CONSTRAINT [DF_STP_Member_ContactPhone3CIC1] DEFAULT ((1)),
[ContactFaxVOL] [bit] NOT NULL CONSTRAINT [DF_STP_Member_ContactFaxCIC1] DEFAULT ((1)),
[ContactEmailVOL] [bit] NOT NULL CONSTRAINT [DF_STP_Member_ContactEmailCIC1] DEFAULT ((1))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_STP_Member_u] ON [dbo].[STP_Member]
FOR UPDATE AS

SET NOCOUNT ON

IF UPDATE(Active) BEGIN
	UPDATE shp
		SET RevokedDate	= GETDATE(),
			Active		= 0
	FROM GBL_SharingProfile shp
	INNER JOIN Inserted i
		ON i.Active=0
			AND (i.MemberID=shp.MemberID OR i.MemberID=shp.ShareMemberID)
END
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[STP_Member] ADD CONSTRAINT [CK_STP_Member_CanDeleteRecordNoteCIC] CHECK (([CanDeleteRecordNoteCIC]>=(0) AND [CanDeleteRecordNoteCIC]<(3)))
GO
ALTER TABLE [dbo].[STP_Member] ADD CONSTRAINT [CK_STP_Member_CanDeleteRecordNoteVOL] CHECK (([CanDeleteRecordNoteVOL]>=(0) AND [CanDeleteRecordNoteVOL]<(3)))
GO
ALTER TABLE [dbo].[STP_Member] ADD CONSTRAINT [CK_STP_Member_CanUpdateRecordNoteCIC] CHECK (([CanUpdateRecordNoteCIC]>=(0) AND [CanUpdateRecordNoteCIC]<(3)))
GO
ALTER TABLE [dbo].[STP_Member] ADD CONSTRAINT [CK_STP_Member_CanUpdateRecordNoteVOL] CHECK (([CanUpdateRecordNoteVOL]>=(0) AND [CanUpdateRecordNoteVOL]<(3)))
GO
ALTER TABLE [dbo].[STP_Member] ADD CONSTRAINT [CK_STP_Member_DefaultGCType] CHECK (([DefaultGCType]>=(0) AND [DefaultGCType]<(3)))
GO
ALTER TABLE [dbo].[STP_Member] ADD CONSTRAINT [CK_STP_Member_NoEmail] CHECK (([NoEmail]=(0) OR [UseVolunteerProfiles]=(0)))
GO
ALTER TABLE [dbo].[STP_Member] ADD CONSTRAINT [CK_STP_Member_SiteCodeLength] CHECK (([SiteCodeLength]>=(0) AND [SiteCodeLength]<=(100)))
GO
ALTER TABLE [dbo].[STP_Member] ADD CONSTRAINT [PK_STP_Member] PRIMARY KEY CLUSTERED ([MemberID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_STP_Member] ON [dbo].[STP_Member] ([DatabaseCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STP_Member] WITH NOCHECK ADD CONSTRAINT [FK_STP_Member_CIC_View] FOREIGN KEY ([DefaultViewCIC]) REFERENCES [dbo].[CIC_View] ([ViewType])
GO
ALTER TABLE [dbo].[STP_Member] ADD CONSTRAINT [FK_STP_Member_GBL_Template] FOREIGN KEY ([DefaultTemplate]) REFERENCES [dbo].[GBL_Template] ([Template_ID])
GO
ALTER TABLE [dbo].[STP_Member] ADD CONSTRAINT [FK_STP_Member_GBL_Template1] FOREIGN KEY ([DefaultPrintTemplate]) REFERENCES [dbo].[GBL_Template] ([Template_ID])
GO
ALTER TABLE [dbo].[STP_Member] ADD CONSTRAINT [FK_STP_Member_STP_Language] FOREIGN KEY ([DefaultLangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[STP_Member] ADD CONSTRAINT [FK_STP_Member_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[STP_Member] WITH NOCHECK ADD CONSTRAINT [FK_STP_Member_VOL_View] FOREIGN KEY ([DefaultViewVOL]) REFERENCES [dbo].[VOL_View] ([ViewType])
GO
GRANT SELECT ON  [dbo].[STP_Member] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[STP_Member] TO [cioc_login_role]
GO
