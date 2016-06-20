SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CIC_NUMActivity_u]
	@BT_ACT_ID int,
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

IF EXISTS(SELECT * FROM CIC_BT_ACT WHERE BT_ACT_ID=@BT_ACT_ID) BEGIN
	UPDATE CIC_BT_ACT SET 
		ASTAT_ID	= CASE WHEN EXISTS(SELECT * FROM CIC_Activity_Status WHERE ASTAT_ID=@ASTAT_ID) THEN @ASTAT_ID ELSE ASTAT_ID END
	WHERE BT_ACT_ID = @BT_ACT_ID

	IF NOT EXISTS(SELECT * FROM CIC_BT_ACT_Notes WHERE BT_ACT_ID=@BT_ACT_ID AND LangID=@@LANGID) BEGIN
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
	END ELSE BEGIN
		UPDATE CIC_BT_ACT_Notes SET 
			ActivityName		= @ActivityName,
			ActivityDescription	= @ActivityDescription,
			Notes				= @Notes
		WHERE BT_ACT_ID=@BT_ACT_ID
			AND LangID=@@LANGID
	END

END

SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_CIC_NUMActivity_u] TO [cioc_login_role]
GO
