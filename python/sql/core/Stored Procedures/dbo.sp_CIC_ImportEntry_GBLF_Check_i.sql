SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_GBLF_Check_i]
	@MemberID int,
	@NUM varchar(8)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.5.1
	Checked by: KL
	Checked on: 10-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @Error int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

DECLARE @tmpOwner char(3)
SET @tmpOwner = LEFT(@NUM,3)

EXEC sp_CIC_ImportEntry_GBL_Check_i @MemberID, @NUM OUTPUT, NULL, @tmpOwner, 0, 0

INSERT INTO GBL_BaseTable_Description (NUM,LangID,CREATED_BY)
SELECT NUM, 2, '(Import)'
	FROM GBL_BaseTable bt
WHERE NUM=@NUM
	AND bt.MemberID=@MemberID
	AND NOT EXISTS(SELECT * FROM GBL_BaseTable_Description WHERE NUM=bt.NUM AND LangID=2)

SET NOCOUNT OFF



GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_GBLF_Check_i] TO [cioc_login_role]
GO
