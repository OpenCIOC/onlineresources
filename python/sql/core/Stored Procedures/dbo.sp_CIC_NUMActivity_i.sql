SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMActivity_i]
	@NUM varchar(8),
	@ASTAT_ID int,
	@ActivityName nvarchar(100),
	@ActivityDescription nvarchar(2000),
	@Notes nvarchar(2000)
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 3.1
	Checked by: KL
	Checked on: 18-Jan-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @BT_ACT_ID int

SET @ASTAT_ID = CASE WHEN EXISTS(SELECT * FROM CIC_Activity_Status WHERE ASTAT_ID=@ASTAT_ID) THEN @ASTAT_ID ELSE NULL END

INSERT INTO CIC_BT_ACT (
	NUM,
	ASTAT_ID
) VALUES (
	@NUM,
	@ASTAT_ID
)
SET @BT_ACT_ID = SCOPE_IDENTITY()

IF EXISTS(SELECT * FROM CIC_BT_ACT WHERE BT_ACT_ID=@BT_ACT_ID) BEGIN
	INSERT INTO CIC_BT_ACT_Notes (
		BT_ACT_ID,
		LangID,
		ActivityName,
		ActivityDescription,
		Notes
	)
	VALUES (
		@BT_ACT_ID,
		@@LANGID,
		@ActivityName,
		@ActivityDescription,
		@Notes
	)
END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMActivity_i] TO [cioc_login_role]
GO
