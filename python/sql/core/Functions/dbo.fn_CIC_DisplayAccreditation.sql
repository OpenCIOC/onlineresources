SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_DisplayAccreditation](
	@ACR_ID int,
	@LangID smallint
)
RETURNS nvarchar(200) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 03-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@Accreditation	nvarchar(200)

SELECT @Accreditation = acrn.Name
	FROM CIC_Accreditation acr
	INNER JOIN CIC_Accreditation_Name acrn
		ON acr.ACR_ID=acrn.ACR_ID AND LangID=@LangID
WHERE acr.ACR_ID=@ACR_ID

IF @Accreditation = '' SET @Accreditation = NULL

RETURN @Accreditation

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayAccreditation] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_DisplayAccreditation] TO [cioc_login_role]
GO
