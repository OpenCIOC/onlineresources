SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToAreasServed](
	@NUM varchar(8),
	@Notes nvarchar(max),
	@LangID smallint
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 17-Jul-2012
	Action: NO ACTION REQUIRED
*/

DECLARE	@conStr nvarchar(3),
		@returnStr nvarchar(max)

SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' ; ',@LangID)

SELECT @returnStr =  COALESCE(@returnStr + @conStr,'') 
		+ cmn.Name
		+ CASE WHEN prn.Notes IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' - ',@LangID) + prn.Notes END
	FROM CIC_BT_CM pr
	LEFT JOIN CIC_BT_CM_Notes prn
		ON pr.BT_CM_ID=prn.BT_CM_ID AND prn.LangID=@LangID
	INNER JOIN GBL_Community cm
		ON pr.CM_ID=cm.CM_ID
	INNER JOIN GBL_Community_Name cmn
		ON cm.CM_ID=cmn.CM_ID
			AND cmn.LangID=(SELECT TOP 1 LangID FROM GBL_Community_Name WHERE CM_ID=cm.CM_ID ORDER BY CASE WHEN LangID=@LangID THEN 0 ELSE 1 END, LangID)
	WHERE NUM = @NUM
ORDER BY cmn.Name

IF @returnStr IS NULL SET @returnStr = ''
IF @returnStr = '' SET @conStr = ''

IF @Notes IS NOT NULL BEGIN
	SELECT @returnStr = @returnStr + @conStr + @Notes
END

IF @returnStr = '' SET @returnStr = NULL
RETURN @returnStr
END



GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToAreasServed] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToAreasServed] TO [cioc_login_role]
GO
