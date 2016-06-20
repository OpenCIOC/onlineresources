CREATE TABLE [dbo].[VOL_Training_Name]
(
[TRN_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_VOL_Training_Name_d] ON [dbo].[VOL_Training_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE trn
	FROM VOL_Training trn
	INNER JOIN Deleted d
		ON trn.TRN_ID=d.TRN_ID
	WHERE NOT EXISTS(SELECT * FROM VOL_Training_Name trnn WHERE trnn.TRN_ID=trn.TRN_ID)
		AND NOT EXISTS(SELECT * FROM VOL_OP_TRN pr WHERE pr.TRN_ID=trn.TRN_ID)

INSERT INTO VOL_Training_Name (TRN_ID,LangID,[Name])
	SELECT d.TRN_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM VOL_Training_Name trnn WHERE trnn.TRN_ID=d.TRN_ID)
			AND EXISTS(SELECT * FROM VOL_OP_TRN pr WHERE pr.TRN_ID=d.TRN_ID)
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[VOL_Training_Name] ADD CONSTRAINT [PK_VOL_Training_Name] PRIMARY KEY CLUSTERED  ([TRN_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Training_Name_UniqueName] ON [dbo].[VOL_Training_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Training_Name] ADD CONSTRAINT [FK_VOL_Training_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_Training_Name] ADD CONSTRAINT [FK_VOL_Training_Name_VOL_Training] FOREIGN KEY ([TRN_ID]) REFERENCES [dbo].[VOL_Training] ([TRN_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Training_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Training_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_Training_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_Training_Name] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Training_Name] TO [cioc_vol_search_role]
GO
