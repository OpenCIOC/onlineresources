
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_Feedback_l_NUM]
	@NUM varchar(8),
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 28-Sep-2014
	Action: NO ACTION REQUIRED
*/

DECLARE @ExtraFieldSQL	nvarchar(max),
		@HeadingFieldSQL nvarchar(max)

SELECT @ExtraFieldSQL = COALESCE(@ExtraFieldSQL + ', ','')
		+ '(SELECT [Value] FROM CIC_Feedback_Extra fbex WHERE fbex.FB_ID=fbe.FB_ID AND fbex.FieldName=''' + FieldName + ''') AS [' + FieldName + ']'
	FROM GBL_FieldOption fo
WHERE ExtraFieldType IN ('a','d','e','l','p','r','t','w')
	AND EXISTS(SELECT *
		FROM CIC_View_UpdateField vf
		INNER JOIN CIC_View_DisplayFieldGroup vfg
			ON vf.DisplayFieldGroupID=vfg.DisplayFieldGroupID
				AND vfg.ViewType=@ViewType
		)

IF @ExtraFieldSQL IS NOT NULL BEGIN
	SET @ExtraFieldSQL = ',' + @ExtraFieldSQL
END ELSE BEGIN
	SET @ExtraFieldSQL = ''
END

SELECT @HeadingFieldSQL = COALESCE(@HeadingFieldSQL + ', ','')
		+ '(SELECT GeneralHeadings FROM CIC_Feedback_Publication pfb WHERE pfb.FB_ID=fbe.FB_ID AND pfb.BT_PB_ID=' + CAST(pr.BT_PB_ID AS varchar) + ' AND pfb.GeneralHeadings IS NOT NULL) AS [' + FieldName + ']'
	FROM GBL_FieldOption fo
	INNER JOIN CIC_BT_PB pr
		ON fo.PB_ID=pr.PB_ID
			AND pr.NUM=@NUM
WHERE fo.CanUseUpdate=1
	AND fo.FieldName LIKE '%HEADINGS%'
	AND EXISTS(SELECT *
		FROM CIC_View_UpdateField vf
		INNER JOIN CIC_View_DisplayFieldGroup vfg
			ON vf.DisplayFieldGroupID=vfg.DisplayFieldGroupID
				AND vfg.ViewType=@ViewType
		)
		
IF @HeadingFieldSQL IS NOT NULL BEGIN
	SET @HeadingFieldSQL = ',' + @HeadingFieldSQL
END ELSE BEGIN
	SET @HeadingFieldSQL = ''
END

SET @ExtraFieldSQL = 'SELECT ''SUBMITTED_BY'' = CASE WHEN u.User_ID IS NULL
		THEN ISNULL(fbe.SOURCE_NAME, ''['' + cioc_shared.dbo.fn_SHR_STP_ObjectName(''Unknown'') + '']'')
		ELSE u.FirstName + '' '' + u.LastName + '' ('' + u.Agency + '')'' END, 
	''SUBMITTED_BY_EMAIL'' = CASE WHEN u.User_ID IS NULL THEN fbe.SOURCE_EMAIL ELSE u.Email END,
	sl.Culture,
	sl.LanguageName,
	fbe.*, fb.*, cfb.*, ccfb.*' + @ExtraFieldSQL + @HeadingFieldSQL + '
	FROM GBL_FeedbackEntry fbe
	LEFT JOIN GBL_Feedback fb ON fbe.FB_ID=fb.FB_ID
	LEFT JOIN CIC_Feedback cfb ON fbe.FB_ID=cfb.FB_ID
	LEFT JOIN CCR_Feedback ccfb ON fbe.FB_ID=ccfb.FB_ID
	LEFT JOIN GBL_Users u ON fbe.User_ID=u.User_ID
	INNER JOIN STP_Language sl
		ON fbe.LangID=sl.LangID
WHERE fbe.NUM=@NUM'

PRINT @ExtraFieldSQL

EXEC sp_executesql @ExtraFieldSQL, N'@NUM varchar(8)', @NUM

SET NOCOUNT OFF





GO

GRANT EXECUTE ON  [dbo].[sp_CIC_Feedback_l_NUM] TO [cioc_login_role]
GO
