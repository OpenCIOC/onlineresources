CREATE TABLE [dbo].[TAX_SeeAlso]
(
[SA_ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL,
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL,
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[Code] [varchar] (21) COLLATE Latin1_General_100_CI_AI NOT NULL,
[SA_Code] [varchar] (21) COLLATE Latin1_General_100_CI_AI NOT NULL,
[Authorized] [bit] NOT NULL CONSTRAINT [DF_TAX_SeeAlso_Authorized] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_TAX_MaintainSeeAlsoReciprocal_Delete] ON [dbo].[TAX_SeeAlso]
FOR DELETE AS

SET NOCOUNT ON

/* Remove any defunct reciprocal relationships after a reference was removed */

IF EXISTS(SELECT * FROM TAX_SeeAlso sa INNER JOIN Deleted d	ON sa.Code=d.SA_Code AND sa.SA_Code=d.Code) 
	AND NOT EXISTS(SELECT * FROM TAX_SeeAlso sa INNER JOIN Deleted d ON sa.Code=d.Code AND sa.SA_Code=d.SA_Code) BEGIN

	DELETE FROM sa
		FROM TAX_SeeAlso sa
		INNER JOIN Deleted d
			ON sa.Code=d.SA_Code AND sa.SA_Code=d.Code
	WHERE NOT EXISTS(SELECT * FROM TAX_SeeAlso sar INNER JOIN Deleted d ON sar.Code=d.Code AND sar.SA_Code=d.SA_Code)

END

SET NOCOUNT OFF
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_TAX_MaintainSeeAlsoReciprocal_Insert] ON [dbo].[TAX_SeeAlso]
FOR INSERT AS
BEGIN

SET NOCOUNT ON

/* Add any new reciprocal relationships required by new additions */

IF EXISTS(SELECT * FROM Inserted i WHERE NOT EXISTS(SELECT * FROM TAX_SeeAlso sa WHERE sa.Code=i.SA_Code AND sa.SA_Code=i.Code)) BEGIN
	INSERT INTO TAX_SeeAlso (Code,SA_Code,Authorized)
		SELECT SA_Code AS Code, Code AS SA_Code, Authorized
			FROM Inserted i
			WHERE NOT EXISTS(SELECT * FROM TAX_SeeAlso sa WHERE sa.Code=i.SA_Code AND sa.SA_Code=i.Code)

END

SET NOCOUNT OFF

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_TAX_MaintainSeeAlsoReciprocal_Update] ON [dbo].[TAX_SeeAlso]
FOR UPDATE AS
BEGIN

/*
	Checked for Release: 3.5.2
	Checked by: KL
	Checked on: 21-May-2014
	Action: NO ACTION REQUIRED
*/

SET NOCOUNT ON

/* Update any existing reciprocal relationships */
IF UPDATE(Code) OR UPDATE(SA_Code) BEGIN

	-- If there is no old reciprocal version to update, insert new reciprocal See Also
	IF EXISTS(SELECT * FROM Deleted d WHERE NOT EXISTS(SELECT * FROM TAX_SeeAlso sa WHERE sa.Code=d.SA_Code AND sa.SA_Code=d.Code)) BEGIN
		INSERT INTO TAX_SeeAlso (Code, SA_Code, Authorized)
		SELECT DISTINCT SA_Code, Code, Authorized
		FROM Inserted i
		WHERE EXISTS(SELECT * FROM Deleted d WHERE d.SA_ID=i.SA_ID
					AND NOT EXISTS(SELECT * FROM TAX_SeeAlso sa WHERE sa.Code=d.SA_Code AND sa.SA_Code=d.Code))
			AND NOT EXISTS(SELECT * FROM TAX_SeeAlso sa WHERE sa.Code=i.SA_Code AND sa.SA_Code=i.Code)
	END

	-- If an old reciprocal version exists, update it
	IF EXISTS(SELECT * FROM Inserted i WHERE NOT EXISTS(SELECT * FROM TAX_SeeAlso sa WHERE sa.Code=i.SA_Code AND sa.SA_Code=i.Code)) BEGIN
		UPDATE sa
			SET SA_Code=i.Code,
				Code=i.SA_Code
			FROM TAX_SeeAlso sa
			INNER JOIN Deleted d
				ON sa.Code=d.SA_Code AND sa.SA_Code=d.Code
			INNER JOIN Inserted i
				ON d.SA_ID=i.SA_ID
			WHERE sa.SA_Code <> i.Code OR sa.Code <> i.SA_Code
				AND NOT EXISTS(SELECT * FROM TAX_SeeAlso sa WHERE sa.Code=i.SA_Code AND sa.SA_Code=i.Code)

		DELETE sa
			FROM TAX_SeeAlso sa
			INNER JOIN Deleted d
				ON sa.Code=d.SA_Code AND sa.SA_Code=d.Code
			INNER JOIN Inserted i
				ON d.SA_ID=i.SA_ID
			WHERE EXISTS(SELECT * FROM TAX_SeeAlso sa WHERE sa.Code=i.SA_Code AND sa.SA_Code=i.SA_Code)
	END
END

IF UPDATE(Authorized) AND EXISTS(SELECT * FROM TAX_SeeAlso sa INNER JOIN Inserted i ON sa.SA_Code=i.Code AND sa.Code=i.SA_Code AND sa.Authorized<>i.Authorized) BEGIN
	UPDATE sa
		SET Authorized=i.Authorized
		FROM TAX_SeeAlso sa
		INNER JOIN Deleted d
			ON sa.Code=d.SA_Code AND sa.SA_Code=d.Code
		INNER JOIN Inserted i
			ON d.SA_ID=i.SA_ID
		WHERE sa.Authorized <> i.Authorized
END

SET NOCOUNT OFF

END
GO
ALTER TABLE [dbo].[TAX_SeeAlso] WITH NOCHECK ADD CONSTRAINT [CK_TAX_SeeAlso_SelfReference] CHECK (([Code]<>[SA_Code]))
GO
ALTER TABLE [dbo].[TAX_SeeAlso] ADD CONSTRAINT [PK_TAX_SeeAlso] PRIMARY KEY CLUSTERED  ([SA_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TAX_SeeAlso_UniquePair] ON [dbo].[TAX_SeeAlso] ([Code], [SA_Code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAX_SeeAlso] WITH NOCHECK ADD CONSTRAINT [FK_TAX_SeeAlso_TAX_Term] FOREIGN KEY ([Code]) REFERENCES [dbo].[TAX_Term] ([Code]) ON DELETE CASCADE ON UPDATE CASCADE NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[TAX_SeeAlso] WITH NOCHECK ADD CONSTRAINT [FK_TAX_SeeAlso_TAX_Term_SeeAlso] FOREIGN KEY ([SA_Code]) REFERENCES [dbo].[TAX_Term] ([Code]) NOT FOR REPLICATION
GO
ALTER TABLE [dbo].[TAX_SeeAlso] NOCHECK CONSTRAINT [FK_TAX_SeeAlso_TAX_Term]
GO
ALTER TABLE [dbo].[TAX_SeeAlso] NOCHECK CONSTRAINT [FK_TAX_SeeAlso_TAX_Term_SeeAlso]
GO
GRANT SELECT ON  [dbo].[TAX_SeeAlso] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[TAX_SeeAlso] TO [cioc_login_role]
GO
