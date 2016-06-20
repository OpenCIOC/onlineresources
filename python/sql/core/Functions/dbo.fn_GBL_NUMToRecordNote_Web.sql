
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GBL_NUMToRecordNote_Web](
	@MemberID int,
	@NoteType varchar(100),
	@NUM varchar(8),
	@LangID smallint
)
RETURNS nvarchar(MAX) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: KL
	Checked on: 02-Oct-2014
	Action: TESTING REQUIRED
*/

DECLARE	@conStr	nvarchar(50),
		@returnStr	nvarchar(MAX),
		@colon nvarchar(3),
		@baseURL	varchar(100)

SELECT @baseURL = BaseURLVOL
	FROM STP_Member
WHERE MemberID=@MemberID

SET @conStr = N'<br>'
SET @colon = cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')

SELECT @returnStr =  STUFF(
	(SELECT @conStr + N'<div>'
		+ CASE WHEN nt.HighPriority=1 THEN cioc_shared.dbo.fn_SHR_GBL_Link_Image_Relative('/images/alert.gif',NULL,NULL) + ' ' ELSE '' END
		+ CASE
			WHEN ntn.Name IS NULL
			THEN N''
			ELSE N'<strong>' + ntn.Name + N'</strong>' + @colon
			END
		+ rn.Value
		+ N' ['
			+ CASE WHEN rn.MODIFIED_BY IS NULL THEN '' ELSE rn.MODIFIED_BY + ', ' END
			+ cioc_shared.dbo.fn_SHR_GBL_DateString(rn.MODIFIED_DATE)
			+ N']</div>'
	FROM GBL_RecordNote rn
	LEFT JOIN GBL_RecordNote_Type nt
		ON rn.NoteTypeID=nt.NoteTypeID
	LEFT JOIN GBL_RecordNote_Type_Name ntn
		ON nt.NoteTypeID=ntn.NoteTypeID AND ntn.LangID=@LangId
	WHERE rn.CANCELLED_DATE IS NULL
		AND GblNUM=@NUM AND GblNoteType=@NoteType AND rn.LangID=@LangID
	ORDER BY CASE WHEN nt.HighPriority=1 THEN 0 ELSE 1 END, rn.MODIFIED_DATE DESC
	FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)')
	,1, 4,'')

IF @returnStr = ''
	SET @returnStr = NULL

RETURN @returnStr
END



GO


GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToRecordNote_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToRecordNote_Web] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_NUMToRecordNote_Web] TO [cioc_vol_search_role]
GO
