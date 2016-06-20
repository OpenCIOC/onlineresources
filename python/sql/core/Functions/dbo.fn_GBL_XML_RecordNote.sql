SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_XML_RecordNote](
	@NoteType varchar(100),
	@NUM varchar(8),
	@HasEnglish bit,
	@HasFrench bit
)
RETURNS [xml] WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @xmlReturn [xml]

SET @xmlReturn = (SELECT
				[GUID] AS "@GID",
				rn.CREATED_DATE AS "@CREATED",
				rn.CREATED_BY AS "@CREATEDBY",
				rn.MODIFIED_DATE AS "@MOD",
				rn.MODIFIED_BY AS "@MODBY",
				CASE WHEN LangID=0 THEN 'E' WHEN LangID=2 THEN 'F' ELSE '?' END AS "@LANG",
				Code AS "@CD",
				[Value] AS "@V"
			FROM GBL_RecordNote rn
			LEFT JOIN GBL_RecordNote_Type nt
				ON rn.NoteTypeID=nt.NoteTypeID
			WHERE GblNoteType=@NoteType
				AND GblNUM=@NUM
				AND ((@HasEnglish=1 AND LangID=0) OR (@HasFrench=1 AND LangID=2))
			FOR XML PATH('N'), TYPE)

RETURN @xmlReturn

END
GO
