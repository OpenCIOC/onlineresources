SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_RecordNote_i]
	@NUM [varchar](8),
	@HAS_ENGLISH [bit],
	@HAS_FRENCH [bit],
	@RecordNoteType [varchar](100),
	@RecordNotes [xml]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 27-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @RecordNoteTable TABLE (
	[RecordNoteID] int IDENTITY(1,1) NOT NULL,
	[GUID] [uniqueidentifier] NOT NULL,
	[CREATED_DATE] smalldatetime NULL,
	[CREATED_BY] varchar(50) NULL,
	[MODIFIED_DATE] smalldatetime NULL,
	[MODIFIED_BY] varchar(50) NULL,
	[NoteTypeID] int NULL,
	[LangID] smallint NULL,
	[Value] nvarchar(4000) NOT NULL
)

INSERT INTO @RecordNoteTable (
	[GUID],
	CREATED_DATE,
	CREATED_BY,
	MODIFIED_DATE,
	MODIFIED_BY,
	NoteTypeID,
	LangID,
	Value
)
SELECT
	N.value('@GID', 'uniqueidentifier') AS GUID,
	N.value('@CREATED', 'smalldatetime') AS CREATED_DATE,
	N.value('@CREATEDBY', 'varchar(50)') AS CREATED_BY,
	N.value('@MOD', 'smalldatetime') AS MODIFIED_DATE,
	N.value('@MODBY', 'varchar(50)') AS MODIFIED_BY,
	(SELECT NoteTypeID FROM GBL_RecordNote_Type WHERE Code=N.value('@CD', 'varchar(20)')) AS NoteTypeID,
	CASE WHEN N.value('@LANG', 'char(1)') = 'F' THEN 2 ELSE 0 END AS LangID,
	N.value('@V', 'nvarchar(4000)') AS Value
FROM @RecordNotes.nodes('//N') as T(N)

UPDATE rn
SET 
	CREATED_DATE = tm.CREATED_DATE,
	CREATED_BY = tm.CREATED_BY,
	MODIFIED_DATE = tm.MODIFIED_DATE,
	MODIFIED_BY = tm.MODIFIED_BY,
	NoteTypeID = tm.NoteTypeID,
	Value = tm.Value
FROM GBL_RecordNote rn
INNER JOIN @RecordNoteTable tm
	ON rn.[GUID]=tm.[GUID] AND rn.[LangID]=tm.[LangID]
WHERE rn.GblNUM=@NUM AND rn.GblNoteType=@RecordNoteType
	AND (
			rn.CREATED_DATE<>tm.CREATED_DATE OR
			rn.CREATED_BY<>tm.CREATED_BY OR (rn.CREATED_BY IS NULL AND tm.CREATED_BY IS NOT NULL) OR (rn.CREATED_BY IS NOT NULL AND tm.CREATED_BY IS NULL) OR
			rn.MODIFIED_DATE<>tm.MODIFIED_DATE OR
			rn.MODIFIED_BY<>tm.MODIFIED_BY OR (rn.MODIFIED_BY IS NULL AND tm.MODIFIED_BY IS NOT NULL) OR (rn.MODIFIED_BY IS NOT NULL AND tm.MODIFIED_BY IS NULL) OR
			rn.NoteTypeID<>tm.NoteTypeID OR (rn.NoteTypeID IS NULL AND tm.NoteTypeID IS NOT NULL) OR (rn.NoteTypeID IS NOT NULL AND tm.NoteTypeID IS NULL) OR
			rn.Value<>tm.Value
		)

INSERT INTO GBL_RecordNote (
	[GUID],
	CREATED_DATE,
	CREATED_BY,
	MODIFIED_DATE,
	MODIFIED_BY,
	NoteTypeID,
	GblNoteType,
	GblNUM,
	LangID,
	Value
)
SELECT 
	[GUID],
	CREATED_DATE,
	CREATED_BY,
	MODIFIED_DATE,
	MODIFIED_BY,
	NoteTypeID,
	@RecordNoteType,
	@NUM,
	LangID,
	Value
FROM @RecordNoteTable tm
WHERE ((tm.LangID=0 AND @HAS_ENGLISH=1) OR (tm.LangID=2 AND @HAS_FRENCH=1))
	AND EXISTS(SELECT * FROM GBL_BaseTable_Description btd WHERE btd.NUM=@NUM AND btd.LangID=tm.LangID)
	AND NOT EXISTS(SELECT * FROM GBL_RecordNote rn WHERE rn.[GUID]=tm.[GUID])

DELETE rn
FROM GBL_RecordNote rn
WHERE rn.GblNUM=@NUM
	AND ((rn.LangID=0 AND @HAS_ENGLISH=1) OR (rn.LangID=2 AND @HAS_FRENCH=1))
	AND NOT EXISTS(SELECT * FROM @RecordNoteTable tm WHERE tm.[GUID]=rn.[GUID])

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_RecordNote_i] TO [cioc_login_role]
GO
