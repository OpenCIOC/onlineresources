SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_NUMVNUMToRecordNote_rst](
	@NoteType varchar(100),
	@NUM varchar(8),
	@VNUM varchar(10),
	@LangID smallint
)
RETURNS @RecordNotes TABLE (
	[MODIFIED_DATE] smalldatetime NULL,
	[MODIFIED_BY] varchar(50) COLLATE Latin1_General_100_CI_AI NULL,
	[NoteTypeCode] varchar(20) COLLATE Latin1_General_100_CI_AI NULL,
	[NoteTypeName] nvarchar(200) COLLATE Latin1_General_100_CI_AI NULL,
	[NoteTypeHighPriority] bit,
	[Value] nvarchar(max) COLLATE Latin1_General_100_CI_AI
) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

INSERT INTO @RecordNotes
	SELECT rn.MODIFIED_DATE, rn.MODIFIED_BY, nt.Code, ntn.Name, ISNULL(nt.HighPriority,0), rn.Value
	FROM GBL_RecordNote rn
	LEFT JOIN GBL_RecordNote_Type nt
		ON rn.NoteTypeID=nt.NoteTypeID
	LEFT JOIN GBL_RecordNote_Type_Name ntn
		ON nt.NoteTypeID=ntn.NoteTypeID AND ntn.LangID=@LangId
	WHERE rn.CANCELLED_DATE IS NULL
		AND ((GblNUM=@NUM AND GblNoteType=@NoteType) OR (VolVNUM=@VNUM AND VolNoteType=@NoteType))
		AND rn.LangID=@LangID
	ORDER BY CASE WHEN nt.HighPriority=1 THEN 0 ELSE 1 END, rn.MODIFIED_DATE DESC

RETURN

END

GO
GRANT SELECT ON  [dbo].[fn_GBL_NUMVNUMToRecordNote_rst] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[fn_GBL_NUMVNUMToRecordNote_rst] TO [cioc_vol_search_role]
GO
