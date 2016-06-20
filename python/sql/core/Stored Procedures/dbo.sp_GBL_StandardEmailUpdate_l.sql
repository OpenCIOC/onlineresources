SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_GBL_StandardEmailUpdate_l]
	@MemberID int,
	@Domain int,
	@StdForMultipleRecords bit
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 15-May-2012
	Action: NO ACTION REQUIRED
*/

IF NOT EXISTS(SELECT * FROM GBL_StandardEmailUpdate WHERE Domain=@Domain AND StdForMultipleRecords=@StdForMultipleRecords AND MemberID=@MemberID) BEGIN
	DECLARE
		@EmailID int,
		@SourceEmailID int
	SELECT @SourceEmailID = EmailID
		FROM GBL_StandardEmailUpdate WHERE MemberID IS NULL AND Domain=@Domain AND StdForMultipleRecords=@StdForMultipleRecords
	
	INSERT INTO GBL_StandardEmailUpdate (
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		Domain,
		StdForMultipleRecords,
		MemberID,
		StdSubjectBilingual,
		DefaultMsg
	)
	SELECT	GETDATE(),
			'(Default)',
			GETDATE(),
			'(Default)',
			Domain,
			StdForMultipleRecords,
			@MemberID,
			StdSubjectBilingual,
			1
		FROM GBL_StandardEmailUpdate
	WHERE EmailID=@SourceEmailID
	
	SET @EmailID = SCOPE_IDENTITY()
	
	INSERT INTO GBL_StandardEmailUpdate_Description (
		EmailID,
		LangID,
		MemberID_Cache,
		Name,
		StdSubject,
		StdGreetingStart,
		StdGreetingEnd,
		StdMessageBody,
		StdDetailDesc,
		StdFeedbackDesc,
		StdSuggestOppDesc,
		StdOrgOppsDesc,
		StdContact
	)
	SELECT	@EmailID,
			LangID,
			@MemberID,
			Name,
			StdSubject,
			StdGreetingStart,
			StdGreetingEnd, 
			StdMessageBody,
			StdDetailDesc,
			StdFeedbackDesc,
			StdSuggestOppDesc,
			StdOrgOppsDesc,
			StdContact
		FROM GBL_StandardEmailUpdate_Description
	WHERE EmailID=@SourceEmailID
END

IF NOT EXISTS(SELECT * FROM GBL_StandardEmailUpdate WHERE Domain=@Domain AND StdForMultipleRecords=@StdForMultipleRecords AND MemberID=@MemberID AND DefaultMsg=1) BEGIN
	UPDATE seu
		SET DefaultMsg=1
	FROM GBL_StandardEmailUpdate seu
		WHERE seu.EmailID=(SELECT TOP 1 seu.EmailID
			FROM GBL_StandardEmailUpdate seu
			INNER JOIN GBL_StandardEmailUpdate_Description seud
				ON seu.EmailID=seud.EmailID
					AND LangID=(SELECT TOP 1 LangID FROM GBL_StandardEmailUpdate_Description WHERE EmailID=seud.EmailID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
			WHERE Domain=@Domain
				AND StdForMultipleRecords=@StdForMultipleRecords
				AND MemberID=@MemberID
			ORDER BY seud.Name
			)
END

SELECT seu.EmailID, seu.DefaultMsg, Name
	FROM GBL_StandardEmailUpdate seu
	INNER JOIN GBL_StandardEmailUpdate_Description seud
		ON seu.EmailID=seud.EmailID
			AND LangID=(SELECT TOP 1 LangID FROM GBL_StandardEmailUpdate_Description WHERE EmailID=seud.EmailID ORDER BY CASE WHEN LangID=@@LANGID THEN 0 ELSE 1 END, LangID)
WHERE Domain=@Domain
	AND StdForMultipleRecords=@StdForMultipleRecords
	AND MemberID=@MemberID
ORDER BY DefaultMsg DESC, seud.Name

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_GBL_StandardEmailUpdate_l] TO [cioc_login_role]
GO
