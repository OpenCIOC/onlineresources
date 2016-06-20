CREATE TABLE [dbo].[VOL_Transportation_Name]
(
[TRP_ID] [int] NOT NULL,
[LangID] [smallint] NOT NULL,
[Name] [nvarchar] (200) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_VOL_Transportation_Name_d] ON [dbo].[VOL_Transportation_Name]
FOR DELETE AS

SET NOCOUNT ON

DELETE trp
	FROM VOL_Transportation trp
	INNER JOIN Deleted d
		ON trp.TRP_ID=d.TRP_ID
	WHERE NOT EXISTS(SELECT * FROM VOL_Transportation_Name trpn WHERE trpn.TRP_ID=trp.TRP_ID)
		AND NOT EXISTS(SELECT * FROM VOL_OP_TRP pr WHERE pr.TRP_ID=trp.TRP_ID)

INSERT INTO VOL_Transportation_Name (TRP_ID,LangID,[Name])
	SELECT d.TRP_ID,d.LangID,d.[Name]
		FROM Deleted d
		WHERE NOT EXISTS(SELECT * FROM VOL_Transportation_Name trpn WHERE trpn.TRP_ID=d.TRP_ID)
			AND EXISTS(SELECT * FROM VOL_OP_TRP pr WHERE pr.TRP_ID=d.TRP_ID)
	
SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[VOL_Transportation_Name] ADD CONSTRAINT [PK_VOL_Transportation_Name] PRIMARY KEY CLUSTERED  ([TRP_ID], [LangID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VOL_Transportation_Name_UniqueName] ON [dbo].[VOL_Transportation_Name] ([LangID], [Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_Transportation_Name] ADD CONSTRAINT [FK_VOL_Transportation_Name_STP_Language] FOREIGN KEY ([LangID]) REFERENCES [dbo].[STP_Language] ([LangID])
GO
ALTER TABLE [dbo].[VOL_Transportation_Name] ADD CONSTRAINT [FK_VOL_Transportation_Name_VOL_Transportation] FOREIGN KEY ([TRP_ID]) REFERENCES [dbo].[VOL_Transportation] ([TRP_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[VOL_Transportation_Name] TO [cioc_login_role]
GRANT INSERT ON  [dbo].[VOL_Transportation_Name] TO [cioc_login_role]
GRANT DELETE ON  [dbo].[VOL_Transportation_Name] TO [cioc_login_role]
GRANT UPDATE ON  [dbo].[VOL_Transportation_Name] TO [cioc_login_role]
GRANT SELECT ON  [dbo].[VOL_Transportation_Name] TO [cioc_vol_search_role]
GO
