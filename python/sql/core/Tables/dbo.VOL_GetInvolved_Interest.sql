CREATE TABLE [dbo].[VOL_GetInvolved_Interest]
(
[GIInterestID] [int] NOT NULL IDENTITY(1, 1),
[GIInterestGroup] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL,
[GIInterestName] [nvarchar] (100) COLLATE Latin1_General_100_CI_AI NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOL_GetInvolved_Interest] ADD CONSTRAINT [PK_VOL_GetInvolved_Interest] PRIMARY KEY CLUSTERED  ([GIInterestID]) ON [PRIMARY]
GO
