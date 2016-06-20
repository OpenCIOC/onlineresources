CREATE TABLE [dbo].[THS_SBJ_UseInstead]
(
[UITerm_ID] [int] NOT NULL IDENTITY(1, 1),
[Subj_ID] [int] NOT NULL,
[UsedSubj_ID] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_THS_SBJ_UseInstead_iud] ON [dbo].[THS_SBJ_UseInstead]
FOR INSERT, UPDATE, DELETE AS

SET NOCOUNT ON

UPDATE cbtd
	SET SRCH_Subjects_U = 1
	FROM CIC_BaseTable_Description cbtd
	INNER JOIN CIC_BT_SBJ pr
		ON cbtd.NUM=pr.NUM
WHERE cbtd.SRCH_Subjects_U <> 1
	AND (EXISTS(SELECT * FROM Inserted i WHERE i.UsedSubj_ID=pr.Subj_ID)
		OR EXISTS(SELECT * FROM Deleted d WHERE d.UsedSubj_ID=pr.Subj_ID))

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[THS_SBJ_UseInstead] ADD CONSTRAINT [CK_THS_SBJ_UseInstead] CHECK (([Subj_ID]<>[UsedSubj_ID]))
GO
ALTER TABLE [dbo].[THS_SBJ_UseInstead] ADD CONSTRAINT [PK_THS_SBJ_UseInstead] PRIMARY KEY CLUSTERED  ([UITerm_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_SBJ_UseInstead] ADD CONSTRAINT [IX_THS_SBJ_UseInstead_UniquePair] UNIQUE NONCLUSTERED  ([Subj_ID], [UsedSubj_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[THS_SBJ_UseInstead] ADD CONSTRAINT [FK_THS_SBJ_UseInstead_THS_Subject] FOREIGN KEY ([Subj_ID]) REFERENCES [dbo].[THS_Subject] ([Subj_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[THS_SBJ_UseInstead] ADD CONSTRAINT [FK_THS_SBJ_UseInstead_THS_Subject1] FOREIGN KEY ([UsedSubj_ID]) REFERENCES [dbo].[THS_Subject] ([Subj_ID])
GO
GRANT SELECT ON  [dbo].[THS_SBJ_UseInstead] TO [cioc_cic_search_role]
GRANT SELECT ON  [dbo].[THS_SBJ_UseInstead] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[THS_SBJ_UseInstead] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[THS_SBJ_UseInstead] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[THS_SBJ_UseInstead] TO [cioc_login_role]
GO
