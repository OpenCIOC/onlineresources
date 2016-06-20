SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Subject_i]
	@NUM varchar(8),
	@SubjectTermEn nvarchar(200),
	@SubjectTermFr nvarchar(200),
	@Subj_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT TOP 1 @Subj_ID = Subj_ID
	FROM THS_Subject_Name
WHERE [Name]=@SubjectTermEn OR [Name]=@SubjectTermFr
	ORDER BY CASE
		WHEN [Name]=@SubjectTermEn AND LangID=0 THEN 0
		WHEN [Name]=@SubjectTermFr AND LangID=2 THEN 1
		ELSE 2
	END

IF @Subj_ID IS NOT NULL BEGIN
	EXEC sp_CIC_ImportEntry_CIC_Check_i @NUM
	
	INSERT INTO CIC_BT_SBJ (
		NUM,
		Subj_ID
	)
	SELECT	NUM,
				@Subj_ID
		FROM GBL_BaseTable
	WHERE NUM=@NUM
		AND NOT EXISTS(SELECT * FROM CIC_BT_SBJ WHERE NUM=@NUM AND Subj_ID=@Subj_ID)
	
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Subject_i] TO [cioc_login_role]
GO
