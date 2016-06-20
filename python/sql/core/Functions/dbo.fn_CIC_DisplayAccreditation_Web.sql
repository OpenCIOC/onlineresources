SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_DisplayAccreditation_Web](
	@ACR_ID int,
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

DECLARE	@Accreditation	nvarchar(1000)

SELECT @Accreditation = acrn.Name
	FROM CIC_Accreditation acr
	INNER JOIN CIC_Accreditation_Name acrn
		ON acr.ACR_ID=acrn.ACR_ID AND LangID=@@LANGID
WHERE acr.ACR_ID=@ACR_ID

IF @Accreditation = ''
	SET @Accreditation = NULL
ELSE
	SET @Accreditation = cioc_shared.dbo.fn_SHR_CIC_Link_Accreditation(@ACR_ID,@Accreditation,@HTTPVals,@PathToStart)
RETURN @Accreditation

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayAccreditation_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayAccreditation_Web] TO [cioc_login_role]
GO
