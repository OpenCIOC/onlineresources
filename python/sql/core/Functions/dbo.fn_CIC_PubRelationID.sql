SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CIC_PubRelationID](
	@NUM varchar(8),
	@PB_ID int
)
RETURNS int WITH EXECUTE AS CALLER
AS 
BEGIN

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 04-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @BT_PB_ID int

SELECT @BT_PB_ID = BT_PB_ID
	FROM CIC_BT_PB
WHERE NUM=@NUM AND PB_ID=@PB_ID

RETURN @BT_PB_ID

END

GO
GRANT EXECUTE ON  [dbo].[fn_CIC_PubRelationID] TO [cioc_cic_search_role]
GRANT EXECUTE ON  [dbo].[fn_CIC_PubRelationID] TO [cioc_login_role]
GO
