SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToTaxTerms_Link_Web](
	@BT_TAX_ID int,
	@TermLink bit,
	@LangID smallint,
	@HTTPVals varchar(500),
	@PathToStart varchar(50)
)
RETURNS varchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 08-Apr-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@returnStr	varchar(max),
		@TermLinkStr	varchar(max)

SELECT @returnStr =  COALESCE(@returnStr + ' ~ ','') + 
		CASE WHEN @TermLink=1
			THEN cioc_shared.dbo.fn_SHR_TAX_Link_Code_Search(Code,Term,'results.asp',@HTTPVals,@PathToStart)
			ELSE cioc_shared.dbo.fn_SHR_TAX_Link_Code_Browse(Code,Term,'tresults.asp',@HTTPVals,@PathToStart)
		END,
		@TermLinkStr = COALESCE(@TermLinkStr + '~','') + Code
	FROM fn_CIC_NUMToTaxTerms_Link_rst(@BT_TAX_ID,@LangID)
ORDER BY Code

IF @returnStr = '' BEGIN
	SET @returnStr = NULL
END ELSE IF @TermLink=1 AND @TermLinkStr LIKE '%~%' BEGIN
	/* Create a hyperlink that will search for all the given Terms linked together */
	SET @returnStr = @returnStr + ' ' + cioc_shared.dbo.fn_SHR_TAX_Link_Code_Search(@TermLinkStr,'[+]','results.asp',@HTTPVals,@PathToStart)
END

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToTaxTerms_Link_Web] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToTaxTerms_Link_Web] TO [cioc_login_role]
GO
