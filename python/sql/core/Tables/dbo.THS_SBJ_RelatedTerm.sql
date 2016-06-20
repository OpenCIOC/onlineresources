CREATE TABLE [dbo].[THS_SBJ_RelatedTerm]
(
[RLTerm_ID] [int] NOT NULL IDENTITY(1, 1),
[Subj_ID] [int] NOT NULL,
[RelatedSubj_ID] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Last Modified:		09-Feb-2009
Last Modified By:	Katherine Lambacher
*/
CREATE TRIGGER [dbo].[tr_THS_SBJ_RelatedTerm_Pair] ON [dbo].[THS_SBJ_RelatedTerm]
FOR INSERT, UPDATE, DELETE AS

SET NOCOUNT ON

IF EXISTS(SELECT rt.* FROM THS_SBJ_RelatedTerm rt
	INNER JOIN Deleted d
		ON rt.Subj_ID=d.RelatedSubj_ID AND rt.RelatedSubj_ID=d.Subj_ID) BEGIN
DELETE FROM rt
	FROM THS_SBJ_RelatedTerm rt
	INNER JOIN Deleted d
		ON rt.Subj_ID=d.RelatedSubj_ID AND rt.RelatedSubj_ID=d.Subj_ID
END

IF EXISTS(SELECT * FROM Inserted i
	WHERE NOT EXISTS(SELECT * FROM THS_SBJ_RelatedTerm WHERE Subj_ID=i.RelatedSubj_ID AND RelatedSubj_ID=i.Subj_ID)) BEGIN

INSERT INTO THS_SBJ_RelatedTerm (Subj_ID,RelatedSubj_ID)

SELECT RelatedSubj_ID AS Subj_ID, Subj_ID AS RelatedSubj_ID
	FROM Inserted i
	WHERE NOT EXISTS(SELECT * FROM THS_SBJ_RelatedTerm WHERE Subj_ID=i.RelatedSubj_ID AND RelatedSubj_ID=i.Subj_ID)
	
END

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[THS_SBJ_RelatedTerm] ADD CONSTRAINT [CK_THS_SBJ_RelatedTerm] CHECK (([Subj_ID]<>[RelatedSubj_ID]))
GO
ALTER TABLE [dbo].[THS_SBJ_RelatedTerm] ADD CONSTRAINT [PK_THS_SBJ_RelatedTerm] PRIMARY KEY CLUSTERED  ([RLTerm_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_SBJ_RelatedTerm] ADD CONSTRAINT [IX_THS_SBJ_RelatedTerm_UniquePair] UNIQUE NONCLUSTERED  ([Subj_ID], [RelatedSubj_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_SBJ_RelatedTerm] ADD CONSTRAINT [FK_THS_SBJ_RelatedTerm_THS_Subject1] FOREIGN KEY ([RelatedSubj_ID]) REFERENCES [dbo].[THS_Subject] ([Subj_ID])
GO
ALTER TABLE [dbo].[THS_SBJ_RelatedTerm] ADD CONSTRAINT [FK_THS_SBJ_RelatedTerm_THS_Subject] FOREIGN KEY ([Subj_ID]) REFERENCES [dbo].[THS_Subject] ([Subj_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[THS_SBJ_RelatedTerm] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[THS_SBJ_RelatedTerm] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[THS_SBJ_RelatedTerm] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[THS_SBJ_RelatedTerm] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[THS_SBJ_RelatedTerm] TO [cioc_login_role]
GO
