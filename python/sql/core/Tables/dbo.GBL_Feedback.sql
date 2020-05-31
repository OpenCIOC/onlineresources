CREATE TABLE [dbo].[GBL_Feedback]
(
[FB_ID] [int] NOT NULL,
[ACCESSIBILITY] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ALT_ORG] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[BILLING_ADDRESSES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[COLLECTED_DATE] [nvarchar] (25) COLLATE Latin1_General_100_CI_AI NULL,
[COLLECTED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_1_NAME] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_1_TITLE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_1_ORG] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_1_PHONE1] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_1_PHONE2] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_1_PHONE3] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_1_FAX] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_1_EMAIL] [nvarchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_2_NAME] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_2_TITLE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_2_ORG] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_2_PHONE1] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_2_PHONE3] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_2_PHONE2] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_2_FAX] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CONTACT_2_EMAIL] [nvarchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[CONTRACT_SIGNATURE] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DESCRIPTION] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ESTABLISHED] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[E_MAIL] [varchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[EVENT_SCHEDULE] [xml] NULL,
[EXEC_1_NAME] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXEC_1_TITLE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXEC_1_ORG] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXEC_1_PHONE1] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXEC_1_PHONE2] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXEC_1_PHONE3] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXEC_1_FAX] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXEC_1_EMAIL] [nvarchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[EXEC_2_NAME] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXEC_2_TITLE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXEC_2_ORG] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXEC_2_PHONE1] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXEC_2_PHONE2] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXEC_2_PHONE3] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXEC_2_FAX] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXEC_2_EMAIL] [nvarchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[FAX] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[FORMER_ORG] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[GEOCODE_NOTES] [nvarchar] (255) COLLATE Latin1_General_CI_AS NULL,
[GEOCODE_TYPE] [tinyint] NULL,
[LATITUDE] [decimal] (11, 7) NULL,
[LONGITUDE] [decimal] (11, 7) NULL,
[LEGAL_ORG] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[LOCATED_IN_CM] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LOCATION_DESCRIPTION] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LOCATION_NAME] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[MAIL_CARE_OF] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[MAIL_BOX_TYPE] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[MAIL_PO_BOX] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[MAIL_BUILDING] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[MAIL_STREET_NUMBER] [nvarchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[MAIL_STREET] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[MAIL_STREET_TYPE] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[MAIL_STREET_TYPE_AFTER] [bit] NULL,
[MAIL_STREET_DIR] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[MAIL_SUFFIX] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[MAIL_CITY] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[MAIL_PROVINCE] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[MAIL_COUNTRY] [nvarchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[MAIL_POSTAL_CODE] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[MAP_LINK] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[NO_UPDATE_EMAIL] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[NON_PUBLIC] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[OFFICE_PHONE] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ORG_DESCRIPTION] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ORG_LEVEL_1] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[ORG_LEVEL_2] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[ORG_LEVEL_3] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[ORG_LEVEL_4] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[ORG_LEVEL_5] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[SERVICE_NAME_LEVEL_1] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[SERVICE_NAME_LEVEL_2] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[SITE_BUILDING] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[SITE_STREET_NUMBER] [nvarchar] (30) COLLATE Latin1_General_100_CI_AI NULL,
[SITE_STREET] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[SITE_STREET_TYPE] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[SITE_STREET_TYPE_AFTER] [bit] NULL,
[SITE_STREET_DIR] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[SITE_SUFFIX] [nvarchar] (150) COLLATE Latin1_General_100_CI_AI NULL,
[SITE_CITY] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[SITE_PROVINCE] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[SITE_COUNTRY] [nvarchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[SITE_POSTAL_CODE] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[SOCIAL_MEDIA] [xml] NULL,
[SORT_AS] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[TOLL_FREE_PHONE] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[UPDATE_EMAIL] [nvarchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[VOLCONTACT_NAME] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[VOLCONTACT_TITLE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[VOLCONTACT_ORG] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[VOLCONTACT_PHONE1] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[VOLCONTACT_PHONE2] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[VOLCONTACT_PHONE3] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[VOLCONTACT_FAX] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[VOLCONTACT_EMAIL] [nvarchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[WWW_ADDRESS] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[MAIL_LINE_1] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[MAIL_LINE_2] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[SITE_LINE_1] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[SITE_LINE_2] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Last Modified:		09-Feb-2009
Last Modified By:	Katherine Lambacher
*/
CREATE TRIGGER [dbo].[tr_GBL_Feedback_Cleanup] ON [dbo].[GBL_Feedback] 
FOR DELETE 
AS

SET NOCOUNT ON

DELETE fbe
	FROM GBL_FeedbackEntry fbe
	INNER JOIN Deleted d
		ON fbe.FB_ID=d.FB_ID
	WHERE NOT (
		EXISTS(SELECT * FROM CIC_Feedback f WHERE f.FB_ID=fbe.FB_ID)
		OR EXISTS(SELECT * FROM CCR_Feedback f WHERE f.FB_ID=fbe.FB_ID)
		OR EXISTS(SELECT * FROM CIC_Feedback_Publication f WHERE f.FB_ID=fbe.FB_ID)
		)

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[GBL_Feedback] ADD CONSTRAINT [PK_GBL_Feedback] PRIMARY KEY CLUSTERED  ([FB_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GBL_Feedback_FBID] ON [dbo].[GBL_Feedback] ([FB_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Feedback] WITH NOCHECK ADD CONSTRAINT [FK_GBL_Feedback_GBL_FeedbackEntry] FOREIGN KEY ([FB_ID]) REFERENCES [dbo].[GBL_FeedbackEntry] ([FB_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT INSERT ON  [dbo].[GBL_Feedback] TO [cioc_cic_search_role]
GO
GRANT SELECT ON  [dbo].[GBL_Feedback] TO [cioc_cic_search_role]
GO
GRANT INSERT ON  [dbo].[GBL_Feedback] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[GBL_Feedback] TO [cioc_login_role]
GO
