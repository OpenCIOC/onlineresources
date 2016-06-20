SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GBL_FullContact](
	@ContactType varchar(100),
	@NUM varchar(8),
	@VNUM varchar(10)
)
RETURNS nvarchar(1200) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.6
	Checked by: CL
	Checked on: 27-Sep-2014
	Action: TESTING REQUIRED
*/

DECLARE	@colonStr nvarchar(3),
		@commaStr nvarchar(3),
		@semiColonStr nvarchar(3),
		@returnStr	nvarchar(1200)

SET @returnStr = ''
SET @colonStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(': ')
SET @commaStr = cioc_shared.dbo.fn_SHR_STP_ObjectName(', ')
SET @semiColonStr = cioc_shared.dbo.fn_SHR_STP_ObjectName('; ')


SELECT @returnStr = ISNULL(CMP_Name,'')
		+ CASE WHEN TITLE IS NULL THEN '' ELSE CASE WHEN CMP_Name IS NULL THEN '' ELSE @commaStr END + TITLE END
		+ CASE WHEN ORG IS NULL THEN '' ELSE CASE WHEN COALESCE(CMP_Name,TITLE) IS NULL THEN '' ELSE @commaStr END + ORG END
		+ CASE WHEN CMP_PhoneFull IS NULL THEN '' ELSE CASE WHEN COALESCE(CMP_Name,TITLE,ORG) IS NULL THEN '' ELSE @semiColonStr END + cioc_shared.dbo.fn_SHR_STP_ObjectName('Phone') + @colonStr + CMP_PhoneFull END
		+ CASE WHEN CMP_Fax IS NULL THEN '' ELSE CASE WHEN COALESCE(CMP_Name,TITLE,ORG,CMP_PhoneFull) IS NULL THEN '' ELSE @semiColonStr END + cioc_shared.dbo.fn_SHR_STP_ObjectName('Fax') + @colonStr + CMP_Fax END
		+ CASE WHEN EMAIL IS NULL THEN '' ELSE CASE WHEN COALESCE(CMP_Name,TITLE,ORG,CMP_PhoneFull,CMP_Fax) IS NULL THEN '' ELSE @semiColonStr END + cioc_shared.dbo.fn_SHR_STP_ObjectName('Email') + @colonStr + EMAIL END
FROM GBL_Contact c
	WHERE (
			(@NUM IS NOT NULL AND GblContactType=@ContactType AND GblNUM=@NUM)
			OR (@VNUM IS NOT NULL AND VolContactType=@ContactType AND VolVNUM=@VNUM)
		)
		AND c.LangID=@@LANGID
	
IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_GBL_FullContact] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FullContact] TO [cioc_login_role]
GRANT EXECUTE ON  [dbo].[fn_GBL_FullContact] TO [cioc_vol_search_role]
GO
