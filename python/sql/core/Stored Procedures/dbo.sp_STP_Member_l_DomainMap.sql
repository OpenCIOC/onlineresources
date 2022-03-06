
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_STP_Member_l_DomainMap]
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 30-Dec-2011
	Action: NO ACTION REQUIRED
*/

SELECT m.*
	FROM GBL_View_DomainMap m

SET NOCOUNT OFF





GO

GRANT EXECUTE ON  [dbo].[sp_STP_Member_l_DomainMap] TO [cioc_login_role]
GO
