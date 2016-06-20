SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_DisplayCertification_Web](
	@CRT_ID int,
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
)
RETURNS nvarchar(1000) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Certification	nvarchar(1000)

SELECT @Certification = crtn.Name
	FROM CIC_Certification crt
	INNER JOIN CIC_Certification_Name crtn
		ON crt.CRT_ID=crtn.CRT_ID AND LangID=@@LANGID
WHERE crt.CRT_ID=@CRT_ID

IF @Certification = ''
	SET @Certification = NULL
ELSE
	SET @Certification = cioc_shared.dbo.fn_SHR_CIC_Link_Certification(@CRT_ID,@Certification,@HTTPVals,@PathToStart)
RETURN @Certification

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayCertification_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayCertification_Web] TO [cioc_login_role]
GO
