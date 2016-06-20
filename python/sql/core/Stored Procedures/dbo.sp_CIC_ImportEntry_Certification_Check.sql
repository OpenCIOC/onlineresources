SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_Certification_Check]
	@CertificationEn nvarchar(200),
	@CertificationFr nvarchar(200),
	@CRT_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

SELECT TOP 1 @CRT_ID = CRT_ID
	FROM CIC_Certification_Name
WHERE [Name]=@CertificationEn OR [Name]=@CertificationFr
	ORDER BY CASE
		WHEN [Name]=@CertificationEn AND LangID=0 THEN 0
		WHEN [Name]=@CertificationFr AND LangID=2 THEN 1
		ELSE 2
	END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_Certification_Check] TO [cioc_login_role]
GO
