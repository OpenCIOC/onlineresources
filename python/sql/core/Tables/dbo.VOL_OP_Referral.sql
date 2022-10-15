CREATE TABLE [dbo].[VOL_OP_Referral]
(
[REF_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MemberID] [int] NOT NULL,
[VNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NOT NULL,
[ViewType] [int] NULL,
[AccessURL] [varchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[LangID] [smallint] NOT NULL CONSTRAINT [DF_VOL_OP_Referral_LangID] DEFAULT ((0)),
[ReferralDate] [smalldatetime] NOT NULL CONSTRAINT [DF_VOL_Referral_ReferralDate] DEFAULT (getdate()),
[FollowUpFlag] [bit] NOT NULL CONSTRAINT [DF_VOL_OP_Referral_FollowUpFlag] DEFAULT ((0)),
[ProfileID] [uniqueidentifier] NULL,
[VolunteerName] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[VolunteerPhone] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[VolunteerEmail] [varchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[VolunteerAddress] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[VolunteerCity] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[VolunteerPostalCode] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[VolunteerNotes] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[NotifyOrgType] [int] NULL,
[NotifyOrgDate] [smalldatetime] NULL,
[VolunteerContactType] [int] NULL,
[VolunteerContactDate] [smalldatetime] NULL,
[SuccessfulPlacement] [bit] NULL,
[OutcomeNotes] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[VolunteerSuccessfulPlacement] [bit] NULL,
[VolunteerOutcomeNotes] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[VolunteerHideReferral] [bit] NOT NULL CONSTRAINT [DF_VOL_OP_Referral_VolunteerHideReferral] DEFAULT ((0)),
[IPAddress] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[Question1Answer] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Question2Answer] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[Question3Answer] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_OP_Referral] WITH NOCHECK ADD CONSTRAINT [CK_VOL_OP_Referral_ContactRequired] CHECK ((NOT ([VolunteerPhone] IS NULL AND [VolunteerEmail] IS NULL AND [VolunteerAddress] IS NULL)))
GO
ALTER TABLE [dbo].[VOL_OP_Referral] ADD CONSTRAINT [PK_VOL_Referral] PRIMARY KEY CLUSTERED ([REF_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VOL_Referral] ON [dbo].[VOL_OP_Referral] ([VNUM]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_OP_Referral] ADD CONSTRAINT [FK_VOL_OP_Referral_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_OP_Referral] ADD CONSTRAINT [FK_VOL_OP_Referral_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
ALTER TABLE [dbo].[VOL_OP_Referral] ADD CONSTRAINT [FK_VOL_OP_Referral_VOL_Profile] FOREIGN KEY ([ProfileID]) REFERENCES [dbo].[VOL_Profile] ([ProfileID])
GO
ALTER TABLE [dbo].[VOL_OP_Referral] ADD CONSTRAINT [FK_VOL_OP_Referral_VOL_View] FOREIGN KEY ([ViewType]) REFERENCES [dbo].[VOL_View] ([ViewType]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[VOL_OP_Referral] WITH NOCHECK ADD CONSTRAINT [FK_VOL_Referral_VOL_Opportunity] FOREIGN KEY ([VNUM]) REFERENCES [dbo].[VOL_Opportunity] ([VNUM]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_OP_Referral] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[VOL_OP_Referral] TO [cioc_login_role]
GO
GRANT SELECT ([REF_ID]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([MODIFIED_DATE]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([MODIFIED_BY]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([VNUM]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([ViewType]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([AccessURL]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([ReferralDate]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([FollowUpFlag]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([ProfileID]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([VolunteerName]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([VolunteerPhone]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([VolunteerEmail]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([VolunteerAddress]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([VolunteerCity]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([VolunteerPostalCode]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([VolunteerNotes]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([NotifyOrgType]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([NotifyOrgDate]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([VolunteerContactType]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([VolunteerContactDate]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([SuccessfulPlacement]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([OutcomeNotes]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
GRANT SELECT ([VolunteerHideReferral]) ON [dbo].[VOL_OP_Referral] TO [cioc_vol_search_role]
GO
