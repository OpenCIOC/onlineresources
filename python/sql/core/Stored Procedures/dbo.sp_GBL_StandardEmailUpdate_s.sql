SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GBL_StandardEmailUpdate_s]
	@MemberID int,
	@Domain int,
	@StdForMultipleRecords bit,
	@EmailID int
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 15-May-2012
	Action: NO ACTION REQUIRED
*/

IF @EmailID IS NULL
		OR NOT EXISTS(SELECT * FROM GBL_StandardEmailUpdate seu WHERE Domain=@Domain AND StdForMultipleRecords=@StdForMultipleRecords AND MemberID=@MemberID) BEGIN
	SELECT TOP 1 @EmailID=seu.EmailID
		FROM GBL_StandardEmailUpdate seu
		INNER JOIN GBL_StandardEmailUpdate_Description seud
		ON seu.EmailID=seud.EmailID
			AND LangID=(SELECT TOP 1 LangID FROM GBL_StandardEmailUpdate_Description WHERE EmailID=seud.EmailID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
	WHERE Domain=@Domain
		AND StdForMultipleRecords=@StdForMultipleRecords
		AND MemberID=@MemberID
	ORDER BY DefaultMsg DESC, seud.Name
END

SELECT seu.*
	FROM GBL_StandardEmailUpdate seu
WHERE Domain=@Domain
	AND StdForMultipleRecords=@StdForMultipleRecords
	AND MemberID=@MemberID
	AND EmailID=@EmailID

SELECT seud.*, l.Culture
	FROM GBL_StandardEmailUpdate_Description seud
	INNER JOIN STP_Language l
		ON seud.LangID=l.LangID
WHERE EmailID=@EmailID

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_StandardEmailUpdate_s] TO [cioc_login_role]
GO
