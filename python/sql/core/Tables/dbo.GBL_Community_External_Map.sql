CREATE TABLE [dbo].[GBL_Community_External_Map]
(
[CM_ID] [int] NOT NULL,
[SystemCode] [varchar] (30) COLLATE Latin1_General_100_CI_AI NOT NULL,
[RollUp] [bit] NOT NULL CONSTRAINT [DF_GBL_Community_External_Map_RollUp] DEFAULT ((1)),
[MapOneEXTID] [int] NULL
) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_Community_External_Map] TO [cioc_cic_search_role]
GO

ALTER TABLE [dbo].[GBL_Community_External_Map] ADD CONSTRAINT [PK_GBL_Community_External_Map] PRIMARY KEY CLUSTERED  ([CM_ID], [SystemCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Community_External_Map] ADD CONSTRAINT [FK_GBL_Community_External_Map_GBL_Community] FOREIGN KEY ([CM_ID]) REFERENCES [dbo].[GBL_Community] ([CM_ID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[GBL_Community_External_Map] ADD CONSTRAINT [FK_GBL_Community_External_Map_GBL_Community_External_Community] FOREIGN KEY ([MapOneEXTID]) REFERENCES [dbo].[GBL_Community_External_Community] ([EXT_ID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[GBL_Community_External_Map] ADD CONSTRAINT [FK_GBL_Community_External_Map_GBL_Community_External_System] FOREIGN KEY ([SystemCode]) REFERENCES [dbo].[GBL_Community_External_System] ([SystemCode])
GO
