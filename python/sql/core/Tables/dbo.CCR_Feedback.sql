CREATE TABLE [dbo].[CCR_Feedback]
(
[FB_ID] [int] NOT NULL,
[TYPE_OF_PROGRAM] [int] NULL,
[BEST_TIME_TO_CALL] [nvarchar] (255) COLLATE Latin1_General_100_CI_AI NULL,
[TYPE_OF_CARE] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[ESCORT] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SUBSIDY] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[SPACE_AVAILABLE] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[SPACE_AVAILABLE_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SPACE_AVAILABLE_DATE] [nvarchar] (25) COLLATE Latin1_General_CI_AS NULL,
[LICENSE_NUMBER] [nvarchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[LICENSE_RENEWAL] [nvarchar] (25) COLLATE Latin1_General_CI_AS NULL,
[LC_TOTAL] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[LC_INFANT] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[LC_TODDLER] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[LC_PRESCHOOL] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[LC_KINDERGARTEN] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[LC_SCHOOLAGE] [nvarchar] (20) COLLATE Latin1_General_CI_AS NULL,
[LC_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[SCHOOLS_IN_AREA] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[SCHOOL_ESCORT] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[SUBSIDY_NAMED_PROGRAM] [nvarchar] (100) COLLATE Latin1_General_CI_AS NULL,
[SUBSIDY_NAMED_PROGRAM_NOTES] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
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
CREATE TRIGGER [dbo].[tr_CCR_Feedback_Cleanup] ON [dbo].[CCR_Feedback] 
FOR DELETE AS

SET NOCOUNT ON

DELETE fbe
	FROM GBL_FeedbackEntry fbe
	INNER JOIN Deleted d
		ON fbe.FB_ID=d.FB_ID
	WHERE NOT (
		EXISTS(SELECT * FROM GBL_Feedback f WHERE f.FB_ID=fbe.FB_ID)
		OR EXISTS(SELECT * FROM CIC_Feedback f WHERE f.FB_ID=fbe.FB_ID)
		OR EXISTS(SELECT * FROM CIC_Feedback_Publication f WHERE f.FB_ID=fbe.FB_ID)
	)
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CCR_Feedback] ADD CONSTRAINT [PK_CCR_Feedback] PRIMARY KEY CLUSTERED ([FB_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCR_Feedback] ADD CONSTRAINT [FK_CCR_Feedback_GBL_FeedbackEntry] FOREIGN KEY ([FB_ID]) REFERENCES [dbo].[GBL_FeedbackEntry] ([FB_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT INSERT ON  [dbo].[CCR_Feedback] TO [cioc_cic_search_role]
GO
GRANT SELECT ON  [dbo].[CCR_Feedback] TO [cioc_cic_search_role]
GO
GRANT INSERT ON  [dbo].[CCR_Feedback] TO [cioc_login_role]
GO
GRANT SELECT ON  [dbo].[CCR_Feedback] TO [cioc_login_role]
GO
