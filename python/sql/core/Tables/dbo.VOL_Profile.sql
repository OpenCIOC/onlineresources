CREATE TABLE [dbo].[VOL_Profile]
(
[ProfileID] [uniqueidentifier] NOT NULL ROWGUIDCOL CONSTRAINT [DF_VOL_Profile_ProfileID] DEFAULT (newid()),
[CREATED_DATE] [smalldatetime] NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MemberID] [int] NOT NULL,
[Email] [varchar] (100) COLLATE Latin1_General_100_CI_AS NOT NULL,
[Password] [varchar] (32) COLLATE Latin1_General_100_CS_AS NULL,
[PasswordHashRepeat] [int] NULL,
[PasswordHashSalt] [varchar] (44) COLLATE Latin1_General_100_CI_AI NULL,
[PasswordHash] [varchar] (44) COLLATE Latin1_General_100_CI_AI NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_Active] DEFAULT ((1)),
[Blocked] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_Blocked] DEFAULT ((0)),
[LoginKey] [char] (32) COLLATE Latin1_General_100_CS_AS NULL,
[FirstName] [nvarchar] (60) COLLATE Latin1_General_100_CI_AI NOT NULL,
[LastName] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Phone] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[Address] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[City] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[Province] [varchar] (2) COLLATE Latin1_General_100_CI_AI NULL,
[PostalCode] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[LangID] [smallint] NOT NULL CONSTRAINT [DF_VOL_Profile_Lang_ID] DEFAULT ((0)),
[BirthDate] [smalldatetime] NULL,
[NotifyNew] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_NotifyNew] DEFAULT ((0)),
[NotifyUpdated] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_NotifyUpdated] DEFAULT ((0)),
[SCH_M_Morning] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_M_Morning] DEFAULT ((0)),
[SCH_M_Afternoon] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_M_Afternoon] DEFAULT ((0)),
[SCH_M_Evening] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_M_Evening] DEFAULT ((0)),
[SCH_TU_Morning] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_TU_Morning] DEFAULT ((0)),
[SCH_TU_Afternoon] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_TU_Afternoon] DEFAULT ((0)),
[SCH_TU_Evening] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_TU_Evening] DEFAULT ((0)),
[SCH_W_Morning] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_W_Morning] DEFAULT ((0)),
[SCH_W_Afternoon] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_W_Afternoon] DEFAULT ((0)),
[SCH_W_Evening] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_W_Evening] DEFAULT ((0)),
[SCH_TH_Morning] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_TH_Morning] DEFAULT ((0)),
[SCH_TH_Afternoon] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_TH_Afternoon] DEFAULT ((0)),
[SCH_TH_Evening] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_TH_Evening] DEFAULT ((0)),
[SCH_F_Morning] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_F_Morning] DEFAULT ((0)),
[SCH_F_Afternoon] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_F_Afternoon] DEFAULT ((0)),
[SCH_F_Evening] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_F_Evening] DEFAULT ((0)),
[SCH_ST_Morning] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_ST_Morning] DEFAULT ((0)),
[SCH_ST_Afternoon] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_ST_Afternoon] DEFAULT ((0)),
[SCH_ST_Evening] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_ST_Evening] DEFAULT ((0)),
[SCH_SN_Morning] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_SN_Morning] DEFAULT ((0)),
[SCH_SN_Afternoon] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_SN_Afternoon] DEFAULT ((0)),
[SCH_SN_Evening] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_SCH_SN_Evening] DEFAULT ((0)),
[OrgCanContact] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_OrgCanContact] DEFAULT ((0)),
[NewEmail] [varchar] (100) COLLATE Latin1_General_100_CS_AS NULL,
[ConfirmationToken] [char] (32) COLLATE Latin1_General_100_CS_AS NULL,
[ConfirmationDate] [smalldatetime] NULL,
[Verified] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_AccountVerified] DEFAULT ((0)),
[AgreedToPrivacyPolicy] [bit] NOT NULL CONSTRAINT [DF_VOL_Profile_AgreeToPrivacyPolicy] DEFAULT ((0)),
[UnsubscribeToken] [uniqueidentifier] NOT NULL CONSTRAINT [DF_VOL_Profile_UnsubscribeKey] DEFAULT (newid()),
[LastSuccessfulLogin] [datetime] NULL,
[LastSuccessfulLoginIP] [varchar] (20) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Profile] ADD CONSTRAINT [PK_VOL_Profile] PRIMARY KEY CLUSTERED ([ProfileID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VOL_Profile_MemberIDInclProfileIDMODIFIEDDATECREATEDDATE] ON [dbo].[VOL_Profile] ([MemberID]) INCLUDE ([ProfileID], [MODIFIED_DATE], [CREATED_DATE]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Profile_UniqueEmail] ON [dbo].[VOL_Profile] ([MemberID], [Email]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Profile] ADD CONSTRAINT [FK_VOL_Profile_STP_Member] FOREIGN KEY ([MemberID]) REFERENCES [dbo].[STP_Member] ([MemberID])
GO
GRANT SELECT ON  [dbo].[VOL_Profile] TO [cioc_login_role]
GO
