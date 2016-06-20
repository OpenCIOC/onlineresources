SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_DisplayCertification](@CRT_ID int, @LangID smallint)
RETURNS nvarchar(200) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Certification	nvarchar(200)

SELECT @Certification = crtn.Name
	FROM CIC_Certification crt
	INNER JOIN CIC_Certification_Name crtn
		ON crt.CRT_ID=crtn.CRT_ID AND LangID=@LangID
WHERE crt.CRT_ID=@CRT_ID

IF @Certification = '' SET @Certification = NULL

RETURN @Certification

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayCertification] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayCertification] TO [cioc_login_role]
GO
