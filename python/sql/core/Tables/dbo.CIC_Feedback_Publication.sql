CREATE TABLE [dbo].[CIC_Feedback_Publication]
(
[PB_FB_ID] [int] NOT NULL IDENTITY(1, 1),
[FB_ID] [int] NOT NULL,
[BT_PB_ID] [int] NOT NULL,
[Description] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL,
[GeneralHeadings] [nvarchar] (max) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Last Modified:		09-Feb-2009
Last Modified By:	Katherine Lambacher
*/
CREATE TRIGGER [dbo].[tr_CIC_Feedback_Publication_Cleanup] ON [dbo].[CIC_Feedback_Publication] 
FOR DELETE AS

SET NOCOUNT ON

DELETE fbe
	FROM GBL_FeedbackEntry fbe
	INNER JOIN Deleted d
		ON fbe.FB_ID=d.FB_ID
	WHERE NOT (
		EXISTS(SELECT * FROM GBL_Feedback f WHERE f.FB_ID=fbe.FB_ID)
		OR EXISTS(SELECT * FROM CIC_Feedback f WHERE f.FB_ID=fbe.FB_ID)
		OR EXISTS(SELECT * FROM CCR_Feedback f WHERE f.FB_ID=fbe.FB_ID)
		)

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[CIC_Feedback_Publication] ADD CONSTRAINT [PK_CIC_Feedback_Publications] PRIMARY KEY CLUSTERED  ([PB_FB_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CIC_Feedback_Publication] ADD CONSTRAINT [FK_CIC_Feedback_Publications_CIC_BT_PB] FOREIGN KEY ([BT_PB_ID]) REFERENCES [dbo].[CIC_BT_PB] ([BT_PB_ID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CIC_Feedback_Publication] ADD CONSTRAINT [FK_CIC_Feedback_Publication_GBL_FeedbackEntry] FOREIGN KEY ([FB_ID]) REFERENCES [dbo].[GBL_FeedbackEntry] ([FB_ID]) ON DELETE CASCADE
GO
GRANT SELECT ON  [dbo].[CIC_Feedback_Publication] TO [cioc_cic_search_role]
GRANT INSERT ON  [dbo].[CIC_Feedback_Publication] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[CIC_Feedback_Publication] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[CIC_Feedback_Publication] TO [cioc_login_role]
GO
