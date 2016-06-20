SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_ImportEntry_i]
	@MemberID int,
	@MODIFIED_BY varchar(50),
	@FileName varchar(255),
	@DisplayName varchar(255),
	@EF_ID int OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 25-Mar-2012
	Action: NO ACTION REQUIRED
*/

DECLARE 	@Error	int
SET @Error = 0

-- Member ID given ?
IF @MemberID IS NULL BEGIN
	SET @Error = 10 -- Required Field
-- Member ID exists ?
END ELSE IF NOT EXISTS(SELECT * FROM STP_Member WHERE MemberID=@MemberID) BEGIN
	SET @Error = 3 -- No Such Record
	SET @MemberID = NULL
END

IF @DisplayName = '' SET @DisplayName = NULL

IF @MemberID IS NOT NULL BEGIN
	INSERT INTO CIC_ImportEntry (
		CREATED_DATE,
		CREATED_BY,
		MODIFIED_DATE,
		MODIFIED_BY,
		MemberID,
		[FileName],
		DisplayName
	) VALUES (
		GETDATE(),
		@MODIFIED_BY,
		GETDATE(),
		@MODIFIED_BY,
		@MemberID,
		@FileName,
		@DisplayName
	)
	SET @EF_ID = SCOPE_IDENTITY()
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_ImportEntry_i] TO [cioc_login_role]
GO
