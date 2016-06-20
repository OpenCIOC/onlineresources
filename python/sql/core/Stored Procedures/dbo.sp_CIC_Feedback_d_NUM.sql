SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Feedback_d_NUM]
	@NUM varchar(8),
	@LangID smallint,
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jun-2012
	Action: NO ACTION REQUIRED
*/

IF @NUM IS NOT NULL BEGIN
	DELETE ccfb
	FROM CCR_Feedback ccfb
	INNER JOIN GBL_FeedbackEntry fbe
		ON ccfb.FB_ID=fbe.FB_ID
	WHERE NUM=@NUM
		AND (LangID=@LangID OR @LangID IS NULL)

	DELETE cfb
	FROM CIC_Feedback cfb
	INNER JOIN GBL_FeedbackEntry fbe
		ON cfb.FB_ID=fbe.FB_ID
	WHERE NUM=@NUM
		AND (LangID=@LangID OR @LangID IS NULL)
		
	DELETE pfb
	FROM CIC_Feedback_Publication pfb
	INNER JOIN GBL_FeedbackEntry fbe
		ON pfb.FB_ID=fbe.FB_ID
	INNER JOIN CIC_BT_PB pr
		ON pfb.BT_PB_ID=pr.BT_PB_ID
	WHERE fbe.NUM=@NUM
		AND (LangID=@LangID OR @LangID IS NULL)
		AND (
			pfb.GeneralHeadings IS NOT NULL
			AND pfb.Description IS NULL
			AND EXISTS(SELECT *
					FROM GBL_FieldOption fo
					INNER JOIN CIC_View_UpdateField uf
						ON fo.FieldID = uf.FieldID
					INNER JOIN CIC_View_DisplayFieldGroup fg
						ON uf.DisplayFieldGroupID=fg.DisplayFieldGroupID
							AND fg.ViewType=@ViewType
					WHERE fo.PB_ID=pr.PB_ID
					)
		)

	DELETE fb
	FROM GBL_Feedback fb
	INNER JOIN GBL_FeedbackEntry fbe
		ON fb.FB_ID=fbe.FB_ID
	WHERE NUM=@NUM
		AND (LangID=@LangID OR @LangID IS NULL)
END

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_Feedback_d_NUM] TO [cioc_login_role]
GO
