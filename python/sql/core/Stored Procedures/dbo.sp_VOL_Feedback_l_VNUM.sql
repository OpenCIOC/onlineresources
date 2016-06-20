
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_VOL_Feedback_l_VNUM]
	@VNUM varchar(10),
	@ViewType int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 25-Feb-2015
	Action: TESTING REQUIRED
*/

DECLARE @ExtraFieldSQL	nvarchar(max),
		@HeadingFieldSQL nvarchar(max)

SELECT @ExtraFieldSQL = COALESCE(@ExtraFieldSQL + ', ','')
		+ '(SELECT [Value] FROM VOL_Feedback_Extra fbex WHERE fbex.FB_ID=fb.FB_ID AND fbex.FieldName=''' + FieldName + ''') AS [' + FieldName + ']'
	FROM VOL_FieldOption fo
WHERE ExtraFieldType IN ('a','d','e','l','p','r','t','w')
	AND EXISTS(SELECT *
		FROM VOL_View_UpdateField vf
		WHERE vf.ViewType=@ViewType
		)

IF @ExtraFieldSQL IS NOT NULL BEGIN
	SET @ExtraFieldSQL = ',' + @ExtraFieldSQL
END ELSE BEGIN
	SET @ExtraFieldSQL = ''
END

SET @ExtraFieldSQL = 'SELECT ''SUBMITTED_BY'' = CASE WHEN u.User_ID IS NULL
		THEN ISNULL(fb.SOURCE_NAME, ''['' + cioc_shared.dbo.fn_SHR_STP_ObjectName(''Unknown'') + '']'')
		ELSE u.FirstName + '' '' + u.LastName + '' ('' + u.Agency + '')'' END, 
	''SUBMITTED_BY_EMAIL'' = CASE WHEN u.User_ID IS NULL THEN fb.SOURCE_EMAIL ELSE u.Email END,
	sl.Culture,
	sl.LanguageName,
	fb.*' + @ExtraFieldSQL + '
	FROM VOL_Feedback fb
	LEFT JOIN GBL_Users u
		ON fb.User_ID=u.User_ID
	INNER JOIN STP_Language sl
		ON fb.LangID=sl.LangID
WHERE VNUM=@VNUM'

EXEC sp_executesql @ExtraFieldSQL, N'@VNUM varchar(10)', @VNUM

SET NOCOUNT OFF


GO

GRANT EXECUTE ON  [dbo].[sp_VOL_Feedback_l_VNUM] TO [cioc_login_role]
GO
