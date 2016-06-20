SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToFeeType](
	@NUM varchar(8),
	@Notes nvarchar(max),
	@AssistanceAvailable bit,
	@AssistanceFor nvarchar(200),
	@AssistanceFrom nvarchar(200),
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
		+ ftn.Name
		+ CASE WHEN prn.Notes IS NULL THEN '' ELSE cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' - ',@LangID) + prn.Notes END
	FROM CIC_BT_FT pr
	LEFT JOIN CIC_BT_FT_Notes prn
		ON pr.BT_FT_ID=prn.BT_FT_ID AND prn.LangID=@LangID
	INNER JOIN CIC_FeeType ft
		ON pr.FT_ID=ft.FT_ID
	INNER JOIN CIC_FeeType_Name ftn
		ON ft.FT_ID=ftn.FT_ID AND ftn.LangID=@LangID
	WHERE NUM = @NUM
ORDER BY ft.DisplayOrder, ftn.Name

IF @returnStr IS NULL SET @returnStr = ''
IF @returnStr = '' SET @conStr = ''

IF @Notes IS NOT NULL BEGIN
	SET @returnStr = @returnStr + @conStr + @Notes
	SET @conStr = cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' * ',@LangID)
END

IF @AssistanceAvailable <> 0 BEGIN
	SET @returnStr = @returnStr + @conStr + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('Fee assistance available',@LangID)
	IF @AssistanceFor  = '' SET @AssistanceFor = NULL
	IF @AssistanceFor IS NOT NULL BEGIN
		SET @returnStr = @returnStr + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' for /assistance',@LangID) + @AssistanceFor
	END
	IF @AssistanceFrom  = '' SET @AssistanceFrom = NULL
	IF @AssistanceFrom IS NOT NULL BEGIN
		SET @returnStr = @returnStr + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang(' ; ',@LangID) + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('assistance is provided by ',@LangID) + @AssistanceFrom
	END
	SET @returnStr = @returnStr + cioc_shared.dbo.fn_SHR_STP_ObjectName_Lang('.',@LangID)
END

IF @returnStr = '' SET @returnStr = NULL

RETURN @returnStr

END


GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToFeeType] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToFeeType] TO [cioc_login_role]
GO
