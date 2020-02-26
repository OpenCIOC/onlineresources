CREATE TABLE [dbo].[CIC_Feedback]
(
[FB_ID] [int] NOT NULL,
[ACCREDITED] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[ACTIVITY_INFO] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AFTER_HRS_PHONE] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[APPLICATION] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[AREAS_SERVED] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[BOUNDARIES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[BUS_ROUTES] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[CERTIFIED] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[COMMENTS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[CORP_REG_NO] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[CRISIS_PHONE] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[DATES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[DD_CODE] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[DISTRIBUTION] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ELECTIONS] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[ELIGIBILITY_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[EMPLOYEES_FT] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[EMPLOYEES_PT] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[EMPLOYEES_TOTAL] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[EMPLOYEES_RANGE] [nvarchar] (20) COLLATE Latin1_General_100_CI_AI NULL,
[FEES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[FISCAL_YEAR_END] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[FUNDING] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[HOURS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[INTERNAL_MEMO] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[INTERSECTION] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[LANGUAGES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LOGO_ADDRESS] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[LOGO_ADDRESS_LINK] [nvarchar] (200) COLLATE Latin1_General_100_CS_AS NULL,
[MAX_AGE] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[MIN_AGE] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[MEETINGS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[MEMBERSHIP] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[NAICS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[OCG_NO] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[OTHER_ADDRESSES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PAYMENT_TERMS] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[PREF_CURRENCY] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[PREF_PAYMENT_METHOD] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NULL,
[PRINT_MATERIAL] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[PUBLIC_COMMENTS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[QUALITY] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[RECORD_TYPE] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[RESOURCES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SERVICE_LEVEL] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SITE_LOCATION] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[SUBJECTS] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SUP_DESCRIPTION] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TAX_REG_NO] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[TAXONOMY] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[TDD_PHONE] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[TRANSPORTATION] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[VACANCY_INFO] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[WARD] [nvarchar] (10) COLLATE Latin1_General_100_CI_AI NULL,
[WCB_NO] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXTRA_CONTACT_A_NAME] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXTRA_CONTACT_A_TITLE] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXTRA_CONTACT_A_ORG] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXTRA_CONTACT_A_PHONE1] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXTRA_CONTACT_A_PHONE2] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXTRA_CONTACT_A_PHONE3] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXTRA_CONTACT_A_FAX] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NULL,
[EXTRA_CONTACT_A_EMAIL] [nvarchar] (60) COLLATE Latin1_General_100_CI_AI NULL,
[LOGO_ADDRESS_HOVER_TEXT] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[LOGO_ADDRESS_ALT_TEXT] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL
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
CREATE TRIGGER [dbo].[tr_CIC_Feedback_Cleanup] ON [dbo].[CIC_Feedback] 
FOR DELETE AS

SET NOCOUNT ON

DELETE fbe
	FROM GBL_FeedbackEntry fbe
	INNER JOIN Deleted d
		ON fbe.FB_ID=d.FB_ID
	WHERE NOT (
		EXISTS(SELECT * FROM GBL_Feedback f WHERE f.FB_ID=fbe.FB_ID)
		OR EXISTS(SELECT * FROM CCR_Feedback f WHERE f.FB_ID=fbe.FB_ID)
		OR EXISTS(SELECT * FROM CIC_Feedback_Publication f WHERE f.FB_ID=fbe.FB_ID)
	)
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CIC_Feedback] ADD CONSTRAINT [PK_CIC_Feedback] PRIMARY KEY CLUSTERED  ([FB_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Feedback] WITH NOCHECK ADD CONSTRAINT [FK_CIC_Feedback_GBL_FeedbackEntry] FOREIGN KEY ([FB_ID]) REFERENCES [dbo].[GBL_FeedbackEntry] ([FB_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT INSERT ON  [dbo].[CIC_Feedback] TO [cioc_cic_search_role]
GO
GRANT SELECT ON  [dbo].[CIC_Feedback] TO [cioc_cic_search_role]
GO
GRANT INSERT ON  [dbo].[CIC_Feedback] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[CIC_Feedback] TO [cioc_login_role]
GO
