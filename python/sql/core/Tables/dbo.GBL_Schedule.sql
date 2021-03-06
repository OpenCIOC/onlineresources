CREATE TABLE [dbo].[GBL_Schedule]
(
[SchedID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NULL CONSTRAINT [DF__GBL_Sched__CREAT__7C5FB486] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF__GBL_Sched__MODIF__7D53D8BF] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[START_DATE] [date] NOT NULL,
[END_DATE] [date] NULL,
[START_TIME] [time] NULL,
[END_TIME] [time] NULL,
[RECURS_EVERY] [tinyint] NOT NULL,
[RECURS_DAY_OF_WEEK] [bit] NOT NULL,
[RECURS_WEEKDAY_1] [bit] NOT NULL CONSTRAINT [DF__GBL_Sched__RECUR__7E47FCF8] DEFAULT ((0)),
[RECURS_WEEKDAY_2] [bit] NOT NULL CONSTRAINT [DF__GBL_Sched__RECUR__7F3C2131] DEFAULT ((0)),
[RECURS_WEEKDAY_3] [bit] NOT NULL CONSTRAINT [DF__GBL_Sched__RECUR__0030456A] DEFAULT ((0)),
[RECURS_WEEKDAY_4] [bit] NOT NULL CONSTRAINT [DF__GBL_Sched__RECUR__012469A3] DEFAULT ((0)),
[RECURS_WEEKDAY_5] [bit] NOT NULL CONSTRAINT [DF__GBL_Sched__RECUR__02188DDC] DEFAULT ((0)),
[RECURS_WEEKDAY_6] [bit] NOT NULL CONSTRAINT [DF__GBL_Sched__RECUR__030CB215] DEFAULT ((0)),
[RECURS_WEEKDAY_7] [bit] NOT NULL CONSTRAINT [DF__GBL_Sched__RECUR__0400D64E] DEFAULT ((0)),
[RECURS_DAY_OF_MONTH] [tinyint] NULL,
[RECURS_XTH_WEEKDAY_OF_MONTH] [tinyint] NULL,
[GblNUM] [varchar] (8) COLLATE Latin1_General_100_CI_AI NULL,
[VolVNUM] [varchar] (10) COLLATE Latin1_General_100_CI_AI NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GBL_Schedule] ADD CONSTRAINT [PK_GBL_Schedule] PRIMARY KEY CLUSTERED  ([SchedID]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[GBL_Schedule] TO [cioc_login_role]
GO
GRANT INSERT ON  [dbo].[GBL_Schedule] TO [cioc_login_role]
GO
GRANT DELETE ON  [dbo].[GBL_Schedule] TO [cioc_login_role]
GO
GRANT UPDATE ON  [dbo].[GBL_Schedule] TO [cioc_login_role]
GO
