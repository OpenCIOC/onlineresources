
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GBL_VNUMToRecordNote](
	@NoteType varchar(100),
	@VNUM varchar(10),
	@LangID smallint
)
RETURNS nvarchar(MAX) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@conStr	nvarchar(4),
		@colon nvarchar(3),
		@returnStr	nvarchar(MAX)

SET @conStr = CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
SET @colon = cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')

SELECT @returnStr =  STUFF(
	(SELECT @conStr
		+ CASE
			WHEN ntn.Name IS NULL
			THEN ''
			ELSE ntn.Name + @colon
			END
		+ rn.Value
		+ ' ['
			+ CASE WHEN rn.MODIFIED_BY IS NULL THEN '' ELSE rn.MODIFIED_BY + ', ' END
			+ cioc_shared.dbo.fn_SHR_GBL_DateString(rn.MODIFIED_DATE)
			+ ']'

	FROM GBL_RecordNote rn
	LEFT JOIN GBL_RecordNote_Type nt
		ON rn.NoteTypeID=nt.NoteTypeID
	LEFT JOIN GBL_RecordNote_Type_Name ntn
		ON nt.NoteTypeID=ntn.NoteTypeID AND ntn.LangID=@LangId
	WHERE rn.CANCELLED_DATE IS NULL
		AND VolVNUM=@VNUM AND VolNoteType=@NoteType AND rn.LangID=@LangID
	ORDER BY CASE WHEN nt.HighPriority=1 THEN 0 ELSE 1 END, rn.MODIFIED_DATE DESC
	FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)')
	,1, 4, '')

IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr
END


GO


GRANT EXECUTE ON  [dbo].[fn_GBL_VNUMToRecordNote] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_VNUMToRecordNote] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_VNUMToRecordNote] TO [cioc_vol_search_role]
GO
