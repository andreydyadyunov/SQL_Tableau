CREATE TABLE [Match] (
  [Match_ID] int NOT NULL IDENTITY (1, 1) ,
  [Tour] int NOT NULL ,
  [Date_Time] datetime NOT NULL ,
  [Home_ID] int NOT NULL ,
  [Away_ID] int NOT NULL ,
  [Jour_ID] int NOT NULL ,
  [Ref_ID] int NOT NULL ,
  [Field_ID] int NOT NULL , 
 PRIMARY KEY ([Match_ID])
) ON [PRIMARY]
;
CREATE TABLE [Team] (
  [Team_ID] int NOT NULL IDENTITY (1, 1) ,
  [Name] varchar(50) NOT NULL , 
 PRIMARY KEY ([Team_ID])
) ON [PRIMARY]
;
CREATE TABLE [Player] (
  [Player_ID] int NOT NULL IDENTITY (1, 1) ,
  [First_Name] varchar(50) ,
  [Last_Name] varchar(50) NOT NULL ,
  [Captain] bit NOT NULL ,
  [Number] int NOT NULL ,
  [Team_ID] int NOT NULL ,
  [Role_ID] int NOT NULL , 
 PRIMARY KEY ([Player_ID])
) ON [PRIMARY]
;

CREATE TABLE [Role] (
  [Role_ID] int IDENTITY (1, 1) ,
  [Role_Type] int NOT NULL , 
 PRIMARY KEY ([Role_ID])
) ON [PRIMARY]
;

CREATE TABLE [Coach] (
  [Coach_ID] int NOT NULL IDENTITY (1, 1) ,
  [First_Name] varchar(50) NOT NULL ,
  [Last_Name] varchar(50) NOT NULL ,
  [Team_ID] int NOT NULL , 
 PRIMARY KEY ([Coach_ID])
) ON [PRIMARY]
;

CREATE TABLE [Goal] (
  [Goal_ID] int NOT NULL IDENTITY (1, 1) ,
  [Time] int NOT NULL ,
  [Player_ID] int NOT NULL ,
  [Assistent_ID] int NOT NULL ,
  [Match_ID] int NOT NULL , 
 PRIMARY KEY ([Goal_ID])
) ON [PRIMARY]
;

CREATE TABLE [Card] (
  [Card_ID] int IDENTITY (1, 1) ,
  [Type_ID] int ,
  [Player_ID] int ,
  [Time] tinyint ,
  [Match_ID] int , 
 PRIMARY KEY ([Card_ID])
) ON [PRIMARY]
;

CREATE TABLE [Card_Type] (
  [Type_ID] int NOT NULL IDENTITY (1, 1) ,
  [Type] varchar(50) NOT NULL , 
 PRIMARY KEY ([Type_ID])
) ON [PRIMARY]
;

CREATE TABLE [Reffere] (
  [Ref_ID] int NOT NULL IDENTITY (1, 1) ,
  [First_Name] varchar(50) NOT NULL ,
  [Last_Name] varchar(50) NOT NULL , 
 PRIMARY KEY ([Ref_ID])
) ON [PRIMARY]
;

CREATE TABLE [Journalist] (
  [Jour_ID] int NOT NULL IDENTITY (1, 1) ,
  [First_Name] varchar(50) NOT NULL ,
  [Last_Name] varchar NOT NULL , 
 PRIMARY KEY ([Jour_ID])
) ON [PRIMARY]
;

CREATE TABLE [Field] (
  [Field_ID] int NOT NULL IDENTITY (1, 1) ,
  [Stad_ID] int NOT NULL ,
  [Grass] int NOT NULL , 
 PRIMARY KEY ([Field_ID])
) ON [PRIMARY],
FOREIGN KEY (Grass) REFERENCES Field_Type(Type_ID)
;

CREATE TABLE [Stadium] (
  [Stad_ID] int NOT NULL IDENTITY (1, 1) ,
  [Name] varchar(50) NOT NULL , 
 PRIMARY KEY ([Stad_ID])
) ON [PRIMARY]
;


CREATE TABLE [Corner]
(
  [Freekick_ID] INT NOT NULL IDENTITY (1, 1),
  [Time] INT NOT NULL,
  [Team_ID] INT NOT NULL,
  [Match_ID INT] NOT NULL,
  PRIMARY KEY (Freekick_ID) ON [PRIMARY],
  FOREIGN KEY (Team_ID) REFERENCES Team(Team_ID),
  FOREIGN KEY (Match_ID) REFERENCES Match(Match_ID)
);

CREATE TABLE [Injury]
(
  [Injury_ID] INT NOT NULL IDENTITY (1, 1),
  [Time] INT NOT NULL,
  [Player_ID] INT NOT NULL,
  [Match_ID] INT NOT NULL,
  PRIMARY KEY (Injury_ID) ON [PRIMARY],
  FOREIGN KEY (Player_ID) REFERENCES Player(Player_ID),
  FOREIGN KEY (Match_ID) REFERENCES Match(Match_ID)
);

CREATE TABLE [Freekick]
(
  [Freekick_ID] INT NOT NULL IDENTITY (1, 1),
  [Time] INT NOT NULL,
  [Match_ID] INT NOT NULL,
  [Team_ID] INT NOT NULL,
  PRIMARY KEY (Freekick_ID) ON [PRIMARY],
  FOREIGN KEY (Match_ID) REFERENCES Match(Match_ID),
  FOREIGN KEY (Team_ID) REFERENCES Team(Team_ID)
);

CREATE TABLE [Field_Type] 
(
  Type_ID INT NOT NULL IDENTITY (1, 1),
  Type INT NOT NULL, 
  PRIMARY KEY (Type_ID) ON [PRIMARY]
);

ALTER TABLE [Match] ADD FOREIGN KEY (Home_ID) REFERENCES [Team] ([Team_ID]);
				
ALTER TABLE [Match] ADD FOREIGN KEY (Away_ID) REFERENCES [Team] ([Team_ID]);
				
ALTER TABLE [Match] ADD FOREIGN KEY (Jour_ID) REFERENCES [Journalist] ([Jour_ID]);
				
ALTER TABLE [Match] ADD FOREIGN KEY (Ref_ID) REFERENCES [Reffere] ([Ref_ID]);
				
ALTER TABLE [Match] ADD FOREIGN KEY (Field_ID) REFERENCES [Field] ([Field_ID]);
				
ALTER TABLE [Player] ADD FOREIGN KEY (Team_ID) REFERENCES [Team] ([Team_ID]);
				
ALTER TABLE [Player] ADD FOREIGN KEY (Role_ID) REFERENCES [Role] ([Role_ID]);
				
ALTER TABLE [Coach] ADD FOREIGN KEY (Team_ID) REFERENCES [Team] ([Team_ID]);
				
ALTER TABLE [Goal] ADD FOREIGN KEY (Player_ID) REFERENCES [Player] ([Player_ID]);
				
ALTER TABLE [Goal] ADD FOREIGN KEY (Assistent_ID) REFERENCES [Player] ([Player_ID]);
				
ALTER TABLE [Goal] ADD FOREIGN KEY (Match_ID) REFERENCES [Match] ([Match_ID]);
				
ALTER TABLE [Card] ADD FOREIGN KEY (Type_ID) REFERENCES [Card_Type] ([Type_ID]);
				
ALTER TABLE [Card] ADD FOREIGN KEY (Player_ID) REFERENCES [Player] ([Player_ID]);
				
ALTER TABLE [Card] ADD FOREIGN KEY (Match_ID) REFERENCES [Match] ([Match_ID]);
				
ALTER TABLE [Field] ADD FOREIGN KEY (Stad_ID) REFERENCES [Stadium] ([Stad_ID]);







