
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Language_i]
	@NUM varchar(8),
	@HAS_ENGLISH bit,
	@HAS_FRENCH bit,
	@Languages [xml]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.7
	Checked by: KL
	Checked on: 11-Aug-2015
	Action: NO ACTION REQUIRED
*/

DECLARE @LN_TABLE table (
	LN_ID int INDEX IX_LN_TABLE_LNID,
	Code varchar(20),
	NameEn nvarchar(200),
	NameFr nvarchar(200),
	NotesEn nvarchar(500),
	NotesFr nvarchar(500),
	DetailXML xml
)

DECLARE @LN_LND table (
	LN_ID int INDEX IX_LN_LND_LNID,
	LN_NameEn nvarchar(200),
	LND_ID int,
	Code varchar(20),
	NameEn nvarchar(200),
	NameFr nvarchar(200)
)

DECLARE @NotMatchedDetails table (
	Name nvarchar(200)
)

DECLARE @NotMatchedLanguages table (
	LanguageEn nvarchar(200),
	LanguageFr nvarchar(200),
	NoteEn nvarchar(500),
	NoteFr nvarchar(500)
)

INSERT INTO @LN_TABLE
SELECT LN_ID, x.LanguageCode, x.LanguageNameEn, x.LanguageNameFr, x.NotesEn, x.NotesFr, x.DetailXML
FROM (SELECT 
	N.value('@CD', 'nvarchar(20)') AS LanguageCode,
	N.value('@V', 'nvarchar(200)') AS LanguageNameEn,
	N.value('@VF', 'nvarchar(200)') AS LanguageNameFr,
	CASE WHEN @HAS_ENGLISH=1 THEN N.value('@N', 'nvarchar(255)') ELSE NULL END AS NotesEn,
	CASE WHEN @HAS_FRENCH=1 THEN N.value('@NF', 'nvarchar(255)') ELSE NULL END AS NotesFr,
	CASE WHEN N2.exist('./SERVICE_TYPE')=1 THEN N2.query('./SERVICE_TYPE') ELSE NULL END	AS DetailXML
	FROM @Languages.nodes('//CHK') AS T(N)
	OUTER APPLY N.nodes('.') AS T2(N2)) x
	OUTER APPLY (SELECT TOP 1 ln.LN_ID FROM GBL_Language ln LEFT JOIN GBL_Language_Name lnn ON ln.LN_ID=lnn.LN_ID
	WHERE (Name=LanguageNameEn AND LangID=0) OR (Name=LanguageNameFr AND LangID=2) OR Code=LanguageCode
	ORDER BY CASE WHEN Code=LanguageCode THEN 0 WHEN (Name=LanguageNameEn AND LangID=0) OR (Name=LanguageNameFr AND LangID=2) THEN LangiD+1 ELSE 4 END
) iq

INSERT INTO @LN_LND
SELECT LN_ID,
	ln.NameEn,
	iqd.LND_ID,
	N.value('@CD', 'nvarchar(20)') AS DetailsCode,
	N.value('@V', 'nvarchar(200)') AS DetailsNameEn,
	N.value('@VF', 'nvarchar(200)') AS DetailsNameFr
FROM @LN_TABLE ln
CROSS APPLY DetailXML.nodes('/SERVICE_TYPE') AS Details(N)
OUTER APPLY (SELECT TOP 1 lnd.LND_ID FROM GBL_Language_Details lnd LEFT JOIN GBL_Language_Details_Name lndn ON lnd.LND_ID=lndn.LND_ID
	WHERE (Name=N.value('@V', 'nvarchar(200)') AND LangID=0) OR (Name=N.value('@VF', 'nvarchar(200)') AND LangID=2) OR Code=N.value('@CD', 'nvarchar(20)')
	ORDER BY CASE WHEN Code=N.value('@CD', 'nvarchar(20)') THEN 0 WHEN (Name=N.value('@V', 'nvarchar(200)') AND LangID=0) OR (Name=N.value('@VF', 'nvarchar(200)') AND LangID=2) THEN LangiD+1 ELSE 4 END
) iqd
WHERE ln.DetailXML IS NOT NULL

UPDATE ln SET
	NotesEn = STUFF((SELECT ', ' + Note
	FROM (
		SELECT lnd.LN_ID, lnd.LN_NameEn, ISNULL(lnd.NameEn,lnd.Code) AS Note, 0 AS IsNote
			FROM @LN_LND lnd
		WHERE (lnd.LND_ID IS NULL OR lnd.LN_ID IS NULL) AND ISNULL(lnd.NameEn,lnd.Code) IS NOT NULL AND @HAS_ENGLISH=1
		UNION SELECT LN_ID, ln.NameEn, ln.NotesEn, 1
			FROM @LN_TABLE ln
		WHERE ln.NotesEn IS NOT NULL
		) x
		WHERE x.LN_ID = ln.LN_ID OR (ln.LN_ID IS NULL AND x.LN_ID IS NULL AND ln.NameEn=x.LN_NameEn)
		ORDER BY IsNote, Note
		FOR XML PATH('')),1,2,''),
	NotesFr = STUFF((SELECT ', ' + Note
	FROM (
		SELECT lnd.LN_ID, lnd.LN_NameEn, ISNULL(lnd.NameFr,lnd.Code) AS Note, 0 AS IsNote
			FROM @LN_LND lnd
		WHERE (lnd.LND_ID IS NULL OR lnd.LN_ID IS NULL) AND COALESCE(lnd.NameFr,lnd.Code,lnd.NameEn) IS NOT NULL AND @HAS_FRENCH=1
		UNION SELECT LN_ID, ln.NameFr, ln.NotesFr, 1
			FROM @LN_TABLE ln
		WHERE ln.NotesFr IS NOT NULL
		) x
		WHERE x.LN_ID = ln.LN_ID OR (ln.LN_ID IS NULL AND x.LN_ID IS NULL AND ln.NameEn=x.LN_NameEn)
		ORDER BY IsNote, Note
		FOR XML PATH('')),1,2,'')
FROM @LN_TABLE ln

INSERT INTO @NotMatchedDetails
SELECT DISTINCT lnd.NameEn
FROM @LN_LND lnd
WHERE lnd.LND_ID IS NULL

DELETE FROM @LN_LND WHERE LND_ID IS NULL OR LN_ID IS NULL

INSERT INTO @NotMatchedLanguages
        ( LanguageEn ,
          LanguageFr ,
          NoteEn ,
          NoteFr
		  )
SELECT ln.NameEn ,
       ln.NameFr ,
       ln.NotesEn ,
       ln.NotesFr
FROM @LN_TABLE ln
WHERE ln.LN_ID IS NULL

DELETE FROM @LN_TABLE WHERE LN_ID IS NULL

MERGE INTO CIC_BT_LN dst
USING @LN_TABLE src
	ON src.LN_ID=dst.LN_ID AND dst.NUM=@NUM
WHEN NOT MATCHED BY TARGET THEN
	INSERT (NUM, LN_ID) VALUES (@NUM, src.LN_ID)
WHEN NOT MATCHED BY SOURCE AND dst.NUM=@NUM THEN
	DELETE
	;


MERGE INTO CIC_BT_LN_Notes dst
USING (SELECT BT_LN_ID, LangID, Note
	FROM (SELECT LN_ID, 0 AS LangID, NotesEn AS Note FROM @LN_TABLE WHERE NotesEn IS NOT NULL
		UNION SELECT LN_ID, 2 AS LangID, NotesFr AS Note FROM @LN_TABLE WHERE NotesFr IS NOT NULL)
	nt
	INNER JOIN CIC_BT_LN ln
		ON ln.NUM=@NUM AND ln.LN_ID=nt.LN_ID
) src
	ON src.BT_LN_ID=dst.BT_LN_ID AND src.LangID=dst.LangID
WHEN MATCHED AND dst.Notes <> src.Note THEN
	UPDATE SET Notes=src.Note
WHEN NOT MATCHED BY TARGET THEN
	INSERT (BT_LN_ID, LangID, Notes) VALUES (src.BT_LN_ID, src.LangID, src.Note)
WHEN NOT MATCHED BY SOURCE AND EXISTS(SELECT * FROM CIC_BT_LN WHERE BT_LN_ID=dst.BT_LN_ID AND NUM=@NUM) THEN
	DELETE
	;

INSERT INTO CIC_BT_LN_LND
		(BT_LN_ID, LND_ID)
SELECT BT_LN_ID, LND_ID
	FROM @LN_LND nt
	INNER JOIN CIC_BT_LN ln
		ON ln.NUM=@NUM AND ln.LN_ID = nt.LN_ID
WHERE NOT EXISTS(SELECT * FROM CIC_BT_LN_LND WHERE ln.BT_LN_ID=BT_LN_ID AND nt.LND_ID=LND_ID)

SELECT * FROM @NotMatchedDetails

SELECT * FROM @NotMatchedLanguages

SET NOCOUNT OFF
GO


GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Language_i] TO [cioc_login_role]
GO
