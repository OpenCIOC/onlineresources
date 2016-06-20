SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_NUMToPublicationDescription](
	@MemberID int,
	@NUM varchar(8),
	@PB_ID int
)
RETURNS nvarchar(max) WITH EXECUTE AS CALLER
AS 
BEGIN 

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 28-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @returnStr nvarchar(max)

IF @PB_ID IS NOT NULL BEGIN
	SELECT @returnStr = Description
		FROM CIC_BT_PB pr
		INNER JOIN CIC_BT_PB_Description prd
			ON pr.BT_PB_ID=prd.BT_PB_ID AND LangID=@@LANGID
	WHERE NUM=@NUM
		AND PB_ID=@PB_ID
END

RETURN @returnStr

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToPublicationDescription] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_NUMToPublicationDescription] TO [cioc_login_role]
GO
