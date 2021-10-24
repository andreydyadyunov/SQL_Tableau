
--Запросы
-- Посмотреть голы матча--
SELECT Tour,home.Name as Home_Team,away.Name AS Away_Name, goalie.Last_Name as Goalie , asist.Last_Name as Asistent,t.Name as Team_Goal,DATEADD (MINUTE , g.[Time] , m.Date_Time )
FROM [Match] m 
JOIN Goal g ON m.Match_ID=g.Match_ID 
JOIN Player goalie  ON goalie.Player_ID = g.Player_ID
JOIN Player asist  ON asist.Player_ID = g.Assistent_ID 
JOIN Team t ON goalie.Team_ID = t.Team_ID 
JOIN Team home ON home.Team_ID = m.Home_ID
JOIN Team away ON away.Team_ID = m.Away_ID;


--Простой запрос с условием и формулами в SELECT (2/2)
--1) Выборка всех полузащитников с номерами
SELECT Player_ID, CONCAT(Last_Name ,' ' ,[Number]) 
FROM Player p 
WHERE Role_ID = 3;

--2) Выборка всех капитанов--

SELECT p.Player_ID, CONCAT(Last_Name ,' ' ,[Number]) 
FROM Player p 
WHERE p.Captain = 1	
;
--Запрос с коррелированным подзапросом в SELECT (2/2)
--1) Показать самое позднее время гола для каждого игрока

SELECT Last_Name, [Number], (SELECT (MAX(g.[Time])) FROM Goal g WHERE g.Player_ID = p.Player_ID)
FROM Player p ;

--2) Показать количество карточек для каждого игрока
SELECT Last_Name, [Number], (SELECT COUNT(Card_ID) FROM Card c  WHERE c.Player_ID = p.Player_ID)
FROM Player p ;

--Запрос с подзапросом в FROM (2/2)

--1) Показать игры второго круга которые судил рефери под индексом 1

SELECT Date_Time, Home,Away
FROM (SELECT m.Date_Time,h.Name as Home,a.Name as Away  FROM [Match] m 
JOIN Team h ON h.Team_ID = m.Home_ID 
JOIN Team a ON a.Team_ID = m.Away_ID 
WHERE m.Tour > 12 AND m.Ref_ID = 1) f

--2) Показать игры, на которых травмировались игроки во втором тайме
SELECT *
FROM (SELECT DISTINCT m.Match_ID FROM Injury i 
JOIN [Match] m ON m.Match_ID = i.Injury_ID 
WHERE i.[Time] > 30) f

--Запрос с подзапросом в FROM, агрегированием, группировкой и сортировкой (2/2)

--1)Матчи, где было совершено более 10 угловых

SELECT Home,Away,DT
FROM (SELECT m.Date_Time as DT,h.Name as Home,a.Name as Away, C.Corner_ID as C_ID,C.Match_ID as M_ID FROM Corner c
JOIN [Match] m ON m.Match_ID = c.Match_ID 
JOIN Team h ON h.Team_ID = m.Home_ID 
JOIN Team a ON a.Team_ID = m.Away_ID) f 
GROUP BY M_ID,Home,Away,DT
HAVING COUNT(C_ID) > 10
ORDER BY DT ASC

--2) Матчи, где было забито больше 6 голов
SELECT Home,Away,DT, COUNT(G_ID)
FROM (SELECT m.Date_Time as DT,h.Name as Home,a.Name as Away, g.Goal_ID as G_ID,g.Match_ID as M_ID FROM Goal g 
JOIN [Match] m ON m.Match_ID = g.Match_ID 
JOIN Team h ON h.Team_ID = m.Home_ID 
JOIN Team a ON a.Team_ID = m.Away_ID) f 
GROUP BY M_ID,Home,Away,DT
HAVING COUNT(G_ID) > 6
ORDER BY COUNT(G_ID) DESC;

--Запрос с коррелированным подзапросом в WHERE (2/2)

--1) Игроки которые забивали на последних минутах
SELECT Player_ID,  Last_Name , [Number] 
FROM Player p 
WHERE Player_ID in (SELECT Player_ID  FROM Goal g WHERE g.[Time] = 60 
AND Player_ID=g.Player_ID);

--2) Команды, которые играли на 4 поле дома
SELECT Name 
FROM Team t 
WHERE Team_ID in (SELECT Team_ID FROM [Match] m 
					WHERE m.Field_ID = 4
					AND Team_ID = m.Home_ID)
					
-- Запрос, использующий оконную функцию LAG или LEAD для выполнения сравнения данных в разных периодах (1/1)
--1) Сравнение количества голов по месяцам
SELECT DISTINCT MONTH(m.Date_Time) as Month_Number, COUNT(g.Goal_ID) AS This_Month ,
LAG (COUNT(g.Goal_ID) , 1,0) OVER (ORDER BY MONTH(m.Date_Time)) AS Previous_Month
FROM [Match] m JOIN Goal g ON m.Match_ID = g.Match_ID
GROUP BY MONTH(m.Date_Time);

--Запрос с агрегированием и выражением JOIN, включающим не менее 2 таблиц (2/3)
--1) Количество игроков в каждой команде
SELECT t.Name ,COUNT(p.Player_ID)
FROM Team t
JOIN Player p ON t.Team_ID = p.Team_ID
GROUP BY t.Name

--2) Список бомбардиров
SELECT p.Last_Name, COUNT(g.Goal_ID) 
FROM Goal g 
JOIN Player p ON g.Player_ID = p.Player_ID
GROUP BY p.Last_Name 
ORDER BY COUNT(g.Goal_ID) DESC

--3) Количество травм по минутам
SELECT i.[Time], COUNT(i.Injury_ID) 
FROM [Match] m 
JOIN Injury i ON m.Match_ID = i.Match_ID 
GROUP BY i.[Time] 
ORDER BY COUNT(i.Injury_ID)  DESC

--Запрос с EXISTS (1/1)
--1) Голы, который забивал Рубцов
SELECT t.Name as HOME, t2.Name as AWAY, g.[Time], p.Last_Name 
FROM [Match] m 
JOIN Goal g ON m.Match_ID = g.Match_ID 
JOIN Player p ON g.Player_ID = p.Player_ID 
JOIN Team t ON t.Team_ID = m.Home_ID 
JOIN Team t2 ON t2.Team_ID = m.Away_ID 
WHERE EXISTS (SELECT g2.Player_ID FROM Goal g2 JOIN Player p2 ON p2.Player_ID = g2.Player_ID 
				WHERE g.Player_ID = g2.Player_ID AND p2.Last_Name = 'Рубцов') 
ORDER BY m.Tour, g.[Time]

--Запрос, использующий манипуляции с множествами (1/1)
--1) Список ассистентов (без защитников)
SELECT * FROM 
(SELECT p.Last_Name, COUNT(g.Goal_ID) as Asists
FROM Goal g 
	  JOIN Player p ON g.Assistent_ID = p.Player_ID 
	  JOIN [Role] r ON r.Role_ID = p.Role_ID
	  GROUP BY p.Last_Name
EXCEPT 
	  SELECT p.Last_Name, COUNT(g.Goal_ID) as Asists
	  FROM  Goal g 
	  JOIN Player p ON g.Assistent_ID = p.Player_ID 
	  JOIN [Role] r ON r.Role_ID = p.Role_ID 
	  WHERE r.Role_Type = 'Защитник'
	  GROUP BY p.Last_Name
	 ) t 
ORDER BY 2 desc, 1 asc


--Запрос с агрегированием и выражением JOIN, включающим не менее 3 таблиц/выражений (1/1)
--1) Список ассистентов команды Майти в первом круге
SELECT p.Last_Name, COUNT(g.Goal_ID)
FROM [Match] m 
JOIN Goal g ON g.Match_ID = m.Match_ID 
JOIN Player p ON p.Player_ID = g.Assistent_ID 
WHERE p.Team_ID = 1  AND m.Tour BETWEEN 1 AND 12
GROUP BY p.Last_Name
ORDER BY COUNT(g.Goal_ID) DESC

--Запрос с CASE (IIF) и агрегированием (1/1)
--1) Матчи, счет, исход
SELECT DISTINCT m.Match_ID,home.Name, away.Name ,homes_g.Home_Goals,aways_g.Away_Goals,
CASE WHEN homes_g.Home_Goals = aways_g.Away_Goals THEN 'Ничья'
	WHEN homes_g.Home_Goals > aways_g.Away_Goals THEN 'Победа хозяев'
	ELSE 'Победа гостей'
	END 

FROM [Match] m 
JOIN GOAL g ON g.Match_ID = m.Match_ID
JOIN Team home ON home.Team_ID = m.Home_ID
JOIN Team away ON away.Team_ID = m.Away_ID

JOIN (SELECT m2.Match_ID, COUNT(g2.Goal_ID) as Home_Goals
FROM [Match] m2 
JOIN GOAL g2 ON g2.Match_ID = m2.Match_ID
JOIN Player p ON p.Player_ID = g2.Player_ID 
WHERE p.Team_ID = m2.Home_ID
GROUP BY m2.Match_ID) homes_g ON homes_g.Match_ID = m.Match_ID

JOIN (SELECT m3.Match_ID, COUNT(g3.Goal_ID) as Away_Goals
FROM [Match] m3
JOIN GOAL g3 ON g3.Match_ID = m3.Match_ID
JOIN Player p3 ON p3.Player_ID = g3.Player_ID 
WHERE p3.Team_ID = m3.Away_ID
GROUP BY m3.Match_ID) aways_g ON aways_g.Match_ID = m.Match_ID

ORDER BY  m.Match_ID

--Запрос с HAVING и агрегированием (1/1)
--1) Матчи, в которых было показано более 3 карточек
SELECT m.Match_ID , t.Name as HOME, t2.Name as AWAY, COUNT(c.Card_ID) as Card_Count
FROM [Match] m 
JOIN Card c ON c.Match_ID = m.Match_ID 
JOIN Team t ON t.Team_ID = m.Home_ID 
JOIN Team t2 ON t2.Team_ID = m.Away_ID 
GROUP BY m.Match_ID, t.Name,t2.Name
HAVING COUNT(c.Card_ID) > 3

--Запрос SELECT INTO для подготовки выгрузки (1/1) 

create table Results (Match_ID int, Home nvarchar(50), AWAY nvarchar(50), h_goals int, a_goals int, res nvarchar(50)) ;

INSERT INTO Results (Match_ID , Home , AWAY , h_goals, a_goals,res )
SELECT DISTINCT m.Match_ID,home.Name, away.Name ,homes_g.Home_Goals,aways_g.Away_Goals,
CASE WHEN homes_g.Home_Goals = aways_g.Away_Goals THEN 'Ничья'
	WHEN homes_g.Home_Goals > aways_g.Away_Goals THEN 'Победа хозяев'
	ELSE 'Победа гостей'
	END 

FROM [Match] m 
JOIN GOAL g ON g.Match_ID = m.Match_ID
JOIN Team home ON home.Team_ID = m.Home_ID
JOIN Team away ON away.Team_ID = m.Away_ID

JOIN (SELECT m2.Match_ID, COUNT(g2.Goal_ID) as Home_Goals
FROM [Match] m2 
JOIN GOAL g2 ON g2.Match_ID = m2.Match_ID
JOIN Player p ON p.Player_ID = g2.Player_ID 
WHERE p.Team_ID = m2.Home_ID
GROUP BY m2.Match_ID) homes_g ON homes_g.Match_ID = m.Match_ID

JOIN (SELECT m3.Match_ID, COUNT(g3.Goal_ID) as Away_Goals
FROM [Match] m3
JOIN GOAL g3 ON g3.Match_ID = m3.Match_ID
JOIN Player p3 ON p3.Player_ID = g3.Player_ID 
WHERE p3.Team_ID = m3.Away_ID
GROUP BY m3.Match_ID) aways_g ON aways_g.Match_ID = m.Match_ID

ORDER BY  m.Match_ID


--Запрос с PIVOT для проведения анализа данных (1/1)
--2) Количество игр по месяцам в 2021 году
SELECT year as year_month,  [01], [02], [03], [04], [05], [06], [07],
[08], [09], [10], [11], [12] from (select year(m.Date_Time) as year, month(m.Date_Time) as month, m.Match_ID from [Match] m) ff
PIVOT
(count(Match_ID)for month in ([01], [02], [03], [04], [05], [06], [07],
[08], [09], [10], [11], [12])) as f

--Запрос с внешним соединением и проверкой на наличие NULL(1/1)
--1) Список  людей, которые не получили ни одной карточки 
SELECT DISTINCT p2.Last_Name 
FROM [Match] m 
LEFT OUTER JOIN Card c ON c.Match_ID = m.Match_ID 
RIGHT OUTER JOIN Player p2 ON p2.Player_ID = c.Player_ID 
WHERE m.Match_ID IS NULL




--PROCEDURE

--Функция добавляющая игрока

CREATE PROCEDURE AddPlayer
@LastName varchar(50), 
@Captain bit, 
@Role int, 
@Number int,
@Team_ID int
AS 
BEGIN 
INSERT INTO Player(Last_Name,Captain,Role_ID,Number,Team_ID) VALUES(@LastName,@Captain,@Role,@Number,@Team_ID) 
END;

--Функция добавляющая гол
CREATE PROCEDURE AddGoal
@Match_ID int,
@Player_ID int,
@Assistent_ID int,
@Time int
AS 
BEGIN 
IF EXISTS (SELECT * FROM Goal g WHERE g.Match_ID = @Match_ID)
AND EXISTS (SELECT * FROM Player p where p.Player_ID = @Player_ID)
AND EXISTS (SELECT * FROM Player p where p.Player_ID = @Assistent_ID)
AND NOT EXISTS (SELECT * FROM Goal g WHERE g.Match_ID = @Match_ID AND g.Time = @Time)
INSERT INTO Goal(Match_ID,Player_ID,Assistent_ID,[Time]) VALUES(@Match_ID,@Player_ID,@Assistent_ID,@Time) 
END
;

--Функция добавляющая капитана 
CREATE PROCEDURE  AddCaptain
@LastName varchar(50), 
@Role int, 
@Number int,
@Team_ID int
AS
BEGIN
	DECLARE @cap int
	SET @cap = (SELECT p.Player_ID FROM Player p WHERE p.Team_ID = @Team_ID AND p.Captain = 1)
	UPDATE Player 
	SET Player.Captain = 0
	WHERE Player.Player_ID = @cap
	INSERT INTO Player(Last_Name,Captain,Role_ID,Number,Team_ID) VALUES(@LastName,1,@Role,@Number,@Team_ID)
END;




--Функция, добавляющая карточку

CREATE PROCEDURE AddCard
@Match_ID int,
@Player_ID int,
@Card_type int,
@Time int
AS 
BEGIN 
BEGIN TRY 
BEGIN TRAN 
INSERT INTO Card (Match_ID,Player_ID,Card_ID,[Time]) VALUES( @Match_ID,@Player_ID ,@Card_type ,@Time ) 
COMMIT TRAN 
END TRY 
BEGIN CATCH 
ROLLBACK TRAN 
END CATCH; 
END;


--Процедура, добавляющая угловой 
CREATE PROCEDURE AddCorner
@Match_ID int,
@Team_ID int,
@Time int
AS
BEGIN 
INSERT INTO Corner(Match_ID,Team_ID ,[Time]) VALUES(@Match_ID,@Team_ID,@Time) 
END;

--Функции

--Функция, считающая количество очков
CREATE FUNCTION points (@Team_ID int)
returns int
begin
DECLARE @points int
SET @points = 

(SELECT SUM(CASE WHEN Home = @Team_ID THEN Home_Points
			ELSE Away_Points END)

FROM (SELECT DISTINCT m.HOME_ID as Home , m.AWAY_ID as Away,Home_Goals,Away_Goals ,
CASE WHEN Home_Goals = aways_g.Away_Goals THEN 1
	WHEN Home_Goals > aways_g.Away_Goals THEN 3
	ELSE 0
	END AS Home_Points,
CASE WHEN Home_Goals = aways_g.Away_Goals THEN 1
	WHEN Home_Goals > aways_g.Away_Goals THEN 0
	ELSE 3
	END AS Away_Points



FROM [Match] m 
JOIN GOAL g ON g.Match_ID = m.Match_ID


JOIN (SELECT m2.Match_ID, COUNT(g2.Goal_ID) as Home_Goals
FROM [Match] m2 
JOIN GOAL g2 ON g2.Match_ID = m2.Match_ID
JOIN Player p ON p.Player_ID = g2.Player_ID 
WHERE p.Team_ID = m2.Home_ID
GROUP BY m2.Match_ID) homes_g ON homes_g.Match_ID = m.Match_ID

JOIN (SELECT m3.Match_ID, COUNT(g3.Goal_ID) as Away_Goals
FROM [Match] m3
JOIN GOAL g3 ON g3.Match_ID = m3.Match_ID
JOIN Player p3 ON p3.Player_ID = g3.Player_ID 
WHERE p3.Team_ID = m3.Away_ID
GROUP BY m3.Match_ID) aways_g ON aways_g.Match_ID = m.Match_ID

WHERE m.Home_ID = @Team_ID OR m.Away_ID = @Team_ID) f)
return @points
END;


--Функция, считающие разницу мячей (забитые минус пропущенные)
CREATE FUNCTION goals_dif (@Team_ID int)
returns int
begin
DECLARE @goalsdif int
SET @goalsdif = 

(SELECT SUM(CASE WHEN Home = @Team_ID THEN Home_dif
			ELSE Away_dif END)

FROM (SELECT DISTINCT m.HOME_ID as Home , m.AWAY_ID as Away,Home_Goals,Away_Goals ,
		(Home_Goals - Away_Goals) AS Home_dif, (Away_Goals - Home_Goals ) AS Away_dif

FROM [Match] m 
JOIN GOAL g ON g.Match_ID = m.Match_ID

JOIN (SELECT m2.Match_ID, COUNT(g2.Goal_ID) as Home_Goals
FROM [Match] m2 
JOIN GOAL g2 ON g2.Match_ID = m2.Match_ID
JOIN Player p ON p.Player_ID = g2.Player_ID 
WHERE p.Team_ID = m2.Home_ID
GROUP BY m2.Match_ID) homes_g ON homes_g.Match_ID = m.Match_ID

JOIN (SELECT m3.Match_ID, COUNT(g3.Goal_ID) as Away_Goals
FROM [Match] m3
JOIN GOAL g3 ON g3.Match_ID = m3.Match_ID
JOIN Player p3 ON p3.Player_ID = g3.Player_ID 
WHERE p3.Team_ID = m3.Away_ID
GROUP BY m3.Match_ID) aways_g ON aways_g.Match_ID = m.Match_ID

WHERE m.Home_ID = @Team_ID OR m.Away_ID = @Team_ID) f)
return @goalsdif
END;


SELECT t.Team_ID, Football_HSE.dbo.points(t.Team_ID), Football_HSE.dbo.goals_dif(t.Team_ID)
FROM Team t 
ORDER BY  Football_HSE.dbo.points(t.Team_ID) DESC, Football_HSE.dbo.goals_dif(t.Team_ID) DESC

--Функция, считающие количество забитых голов 
CREATE FUNCTION zabit_goals (@Team_ID int)
returns int
begin
DECLARE @zabit_goals int
SET @zabit_goals = 

(SELECT SUM(CASE WHEN Home = @Team_ID THEN Home_Goals
			ELSE Away_Goals END)

FROM (SELECT DISTINCT m.HOME_ID as Home , m.AWAY_ID as Away,Home_Goals,Away_Goals 


FROM [Match] m 
JOIN GOAL g ON g.Match_ID = m.Match_ID

JOIN (SELECT m2.Match_ID, COUNT(g2.Goal_ID) as Home_Goals
FROM [Match] m2 
JOIN GOAL g2 ON g2.Match_ID = m2.Match_ID
JOIN Player p ON p.Player_ID = g2.Player_ID 
WHERE p.Team_ID = m2.Home_ID
GROUP BY m2.Match_ID) homes_g ON homes_g.Match_ID = m.Match_ID

JOIN (SELECT m3.Match_ID, COUNT(g3.Goal_ID) as Away_Goals
FROM [Match] m3
JOIN GOAL g3 ON g3.Match_ID = m3.Match_ID
JOIN Player p3 ON p3.Player_ID = g3.Player_ID 
WHERE p3.Team_ID = m3.Away_ID
GROUP BY m3.Match_ID) aways_g ON aways_g.Match_ID = m.Match_ID

WHERE m.Home_ID = @Team_ID OR m.Away_ID = @Team_ID) f)
return @zabit_goals
END;

--Функция, считающие количество пропущенных голов
CREATE FUNCTION prop_goals (@Team_ID int)
returns int
begin
DECLARE @prop_goals int
SET @prop_goals = 

(SELECT SUM(CASE WHEN Home = @Team_ID THEN Away_Goals
			ELSE Home_Goals END)

FROM (SELECT DISTINCT m.HOME_ID as Home , m.AWAY_ID as Away,Home_Goals,Away_Goals 


FROM [Match] m 
JOIN GOAL g ON g.Match_ID = m.Match_ID

JOIN (SELECT m2.Match_ID, COUNT(g2.Goal_ID) as Home_Goals
FROM [Match] m2 
JOIN GOAL g2 ON g2.Match_ID = m2.Match_ID
JOIN Player p ON p.Player_ID = g2.Player_ID 
WHERE p.Team_ID = m2.Home_ID
GROUP BY m2.Match_ID) homes_g ON homes_g.Match_ID = m.Match_ID

JOIN (SELECT m3.Match_ID, COUNT(g3.Goal_ID) as Away_Goals
FROM [Match] m3
JOIN GOAL g3 ON g3.Match_ID = m3.Match_ID
JOIN Player p3 ON p3.Player_ID = g3.Player_ID 
WHERE p3.Team_ID = m3.Away_ID
GROUP BY m3.Match_ID) aways_g ON aways_g.Match_ID = m.Match_ID

WHERE m.Home_ID = @Team_ID OR m.Away_ID = @Team_ID) f)
return @prop_goals
END;

DROP TABLE Results



--Представления 

--Представление турнирной таблицы
CREATE VIEW Rate_Table
AS 
SELECT t.Name, Football_HSE.dbo.points(t.Team_ID) AS points ,
Football_HSE.dbo.zabit_goals(t.Team_ID) AS Goals_Scored,
Football_HSE.dbo.prop_goals(t.Team_ID) AS Goals_Conceded, 
Football_HSE.dbo.goals_dif(t.Team_ID) AS Goal_Different
FROM Team t

--Представление топа бомбардиров
CREATE VIEW Top_Scorers
AS
SELECT p.Last_Name, COUNT(g.Goal_ID) AS Goals
FROM Goal g 
JOIN Player p ON p.Player_ID = g.Player_ID 
GROUP BY p.Last_Name


--Представление топа ассистентов
CREATE VIEW Top_Assists
AS
SELECT p.Last_Name, COUNT(g.Goal_ID) AS Assists
FROM Goal g 
JOIN Player p ON p.Player_ID = g.Assistent_ID 
GROUP BY p.Last_Name

SELECT a.Last_Name, Goals, Assists, (Assists + Goals) AS Goal_Pass
FROM Top_Assists a
JOIN Top_Scorers s ON  a.Last_Name = s.Last_Name
ORDER BY Goals DESC,Assists DESC

--Для отчета
SELECT *
FROM
(SELECT m.Match_ID, g.Goal_ID ,m.Tour , t.Name , p.Last_Name, g.[Time],a.Last_Name AS Assistent
FROM 
[Match] m 
JOIN Player p ON m.Home_ID = p.Team_ID 
JOIN Team t ON t.Team_ID = m.Home_ID 
JOIN Goal g ON m.Match_ID  = g.Match_ID AND g.Player_ID = p.Player_ID
JOIN Player a ON g.Assistent_ID = a.Player_ID
UNION 
SELECT m2.Match_ID ,g2.Goal_ID ,m2.Tour , t2.Name , p2.Last_Name, g2.[Time],a2.Last_Name AS Assistent
FROM [Match] m2
JOIN Player p2 ON m2.AWAY_ID = p2.Team_ID 
JOIN Team t2 ON t2.Team_ID = m2.Away_ID 
JOIN Goal g2 ON m2.Match_ID  = g2.Match_ID AND g2.Player_ID = p2.Player_ID 
JOIN Player a2 ON g2.Assistent_ID = a2.Player_ID) f


--Для отчета
SELECT CONCAT( r.First_Name,' ', r.Last_Name) AS Name, c.[Time], c.Card_ID 
FROM [Match] m 
JOIN Reffere r ON r.Ref_ID = m.Ref_ID 
JOIN Card c ON c.Match_ID = m.Match_ID 

--Представление всех событий
CREATE VIEW All_Events AS
SELECT *
FROM
(SELECT m.Match_ID as Match_ID, Date_Time ,CONCAT(h.Name,'-',aw.Name) AS Teams ,'Гол' AS Event, m.Tour AS Tour , t.Name AS Team , p.Last_Name AS Player , g.[Time] AS Time, a.Last_Name AS Assistent
FROM 
[Match] m 
JOIN Player p ON m.Home_ID = p.Team_ID 
JOIN Team t ON t.Team_ID = m.Home_ID 
JOIN Goal g ON m.Match_ID  = g.Match_ID AND g.Player_ID = p.Player_ID
JOIN Player a ON g.Assistent_ID = a.Player_ID
JOIN Team h ON h.Team_ID = m.Home_ID 
JOIN Team aw ON aw.Team_ID = m.Away_ID 
UNION 
SELECT m2.Match_ID as Match_ID, Date_Time , CONCAT(h2.Name,'-',aw2.Name) AS Teams ,'Гол' AS Event, m2.Tour AS Tour , t2.Name AS Team , p2.Last_Name AS Player , g2.[Time] AS Time, a2.Last_Name AS Assistent
FROM [Match] m2
JOIN Player p2 ON m2.AWAY_ID = p2.Team_ID 
JOIN Team t2 ON t2.Team_ID = m2.Away_ID 
JOIN Goal g2 ON m2.Match_ID  = g2.Match_ID AND g2.Player_ID = p2.Player_ID 
JOIN Player a2 ON g2.Assistent_ID = a2.Player_ID
JOIN Team h2 ON h2.Team_ID = m2.Home_ID 
JOIN Team aw2 ON aw2.Team_ID = m2.Away_ID 
UNION
SELECT m3.Match_ID  as Match_ID, Date_Time , CONCAT(h3.Name,'-',aw3.Name) AS Teams, CONCAT('Карточка','(',ct3.[Type] ,')')AS Event, m3.Tour AS Tour, t3.Name AS Team , p3.Last_Name AS Player, c3.[Time] AS Time, '' AS Assistent
FROM 
[Match] m3
JOIN Player p3 ON m3.Home_ID = p3.Team_ID 
JOIN Team t3 ON t3.Team_ID = m3.Home_ID 
JOIN Card c3 ON m3.Match_ID  = c3.Match_ID AND c3.Player_ID = p3.Player_ID
JOIN Team h3 ON h3.Team_ID = m3.Home_ID 
JOIN Team aw3 ON aw3.Team_ID = m3.Away_ID
JOIN Card_Type ct3 ON ct3.Type_ID = c3.Type_ID 
UNION
SELECT m3.Match_ID  as Match_ID, Date_Time , CONCAT(h3.Name,'-',aw3.Name) AS Teams, CONCAT('Карточка','(',ct3.[Type] ,')') AS Event, m3.Tour AS Tour, t3.Name AS Team , p3.Last_Name AS Player, c3.[Time] AS Time, '' AS Assistent
FROM 
[Match] m3
JOIN Player p3 ON m3.Away_ID = p3.Team_ID 
JOIN Team t3 ON t3.Team_ID = m3.Away_ID 
JOIN Card c3 ON m3.Match_ID  = c3.Match_ID AND c3.Player_ID = p3.Player_ID
JOIN Team h3 ON h3.Team_ID = m3.Home_ID 
JOIN Team aw3 ON aw3.Team_ID = m3.Away_ID 
JOIN Card_Type ct3 ON ct3.Type_ID = c3.Type_ID 
UNION
SELECT m4.Match_ID  as Match_ID,  Date_Time ,CONCAT(h4.Name,'-',aw4.Name) AS Teams, 'Штрафной' AS Event, m4.Tour AS Tour, t4.Name AS Team , '' AS Player, f4.[Time] AS Time, '' AS Assistent
FROM 
[Match] m4
JOIN Team t4 ON t4.Team_ID = m4.Home_ID 
JOIN Freekick f4 ON m4.Match_ID  = f4.Match_ID AND f4.Team_ID = m4.Home_ID 
JOIN Team h4 ON h4.Team_ID = m4.Home_ID 
JOIN Team aw4 ON aw4.Team_ID = m4.Away_ID 
UNION 
SELECT m5.Match_ID  as Match_ID, Date_Time ,CONCAT(h5.Name,'-',aw5.Name) AS Teams, 'Штрафной' AS Event, m5.Tour AS Tour, t5.Name AS Team , '' AS Player, f5.[Time] AS Time, '' AS Assistent
FROM 
[Match] m5
JOIN Team t5 ON t5.Team_ID = m5.Away_ID 
JOIN Freekick f5 ON m5.Match_ID  = f5.Match_ID AND f5.Team_ID = m5.Away_ID 
JOIN Team h5 ON h5.Team_ID = m5.Home_ID 
JOIN Team aw5 ON aw5.Team_ID = m5.Away_ID 
UNION
SELECT m6.Match_ID  as Match_ID, Date_Time , CONCAT(h6.Name,'-',aw6.Name) AS Teams, 'Травма' AS Event, m6.Tour AS Tour, t6.Name AS Team , p6.Last_Name AS Player, i6.[Time] AS Time, '' AS Assistent
FROM
[Match] m6
JOIN Player p6 ON m6.Home_ID = p6.Team_ID 
JOIN Team t6 ON t6.Team_ID = m6.Home_ID 
JOIN Injury i6 ON m6.Match_ID  = i6.Match_ID AND i6.Player_ID = p6.Player_ID
JOIN Team h6 ON h6.Team_ID = m6.Home_ID 
JOIN Team aw6 ON aw6.Team_ID = m6.Away_ID 
UNION
SELECT m7.Match_ID  as Match_ID, Date_Time ,CONCAT(h7.Name,'-',aw7.Name) AS Teams, 'Травма' AS Event, m7.Tour AS Tour, t7.Name AS Team , p7.Last_Name AS Player, i7.[Time] AS Time, '' AS Assistent
FROM
[Match] m7
JOIN Player p7 ON m7.Away_ID = p7.Team_ID 
JOIN Team t7 ON t7.Team_ID = m7.Away_ID 
JOIN Injury i7 ON m7.Match_ID  = i7.Match_ID AND i7.Player_ID = p7.Player_ID
JOIN Team h7 ON h7.Team_ID = m7.Home_ID 
JOIN Team aw7 ON aw7.Team_ID = m7.Away_ID 
) f


--Для отчета
SELECT m.Date_Time ,'Голы' AS Type, g.Goal_ID AS Number 
FROM [Match] m 
JOIN Goal g ON g.Match_ID = m.Match_ID 
UNION 
SELECT m.Date_Time ,'Штрафные' AS Type, f.Freekick_ID  AS Number
FROM [Match] m 
JOIN Freekick f ON f.Match_ID = m.Match_ID
UNION
SELECT m.Date_Time ,'Карточки' AS Type, c.Card_ID AS Number
FROM [Match] m 
JOIN Card c ON c.Match_ID = m.Match_ID 
UNION
SELECT m.Date_Time ,'Травмы' AS Type, i.Injury_ID AS Number
FROM [Match] m 
JOIN Injury i ON i.Match_ID = m.Match_ID





--Триггер
--Автоматическое присвоение красной карточки
CREATE TRIGGER Red_Card
ON [Card]
INSTEAD OF INSERT AS 
BEGIN 
	DECLARE @match int
	SET @match = (SELECT Match_ID FROM inserted)
	
	DECLARE @player int
	SET @player = (SELECT Player_ID FROM inserted)
	
	DECLARE @type_card int 
	SET @type_card = (SELECT Type_ID FROM inserted)
	
	IF (@type_card = 1)

	IF EXISTS 
	
	(SELECT Match_ID,Player_ID
	FROM Card 
	WHERE Type_ID = 1 AND Match_ID=@match AND Player_ID=@player 
	GROUP BY Match_ID,Player_ID 
	HAVING COUNT(Card_ID) > 1
	UNION 
	SELECT Match_ID,Player_ID
	FROM Card 
	WHERE Type_ID = 2 AND Match_ID=@match AND Player_ID=@player)
	
	BEGIN 
		PRINT 'The player was canceled from this match'
       	rollback transaction;
	END
	
	ElSE
		IF EXISTS 
	
		(SELECT Match_ID,Player_ID
		FROM Card 
		WHERE Type_ID = 1 AND Match_ID=@match AND Player_ID=@player 
		GROUP BY Match_ID,Player_ID 
		HAVING COUNT(Card_ID) = 1)	
		
	begin 
		
		INSERT INTO Card (Match_ID,Player_ID,Type_ID,[Time])
		Select Match_ID , Player_ID , Type_ID , [Time] 
		FROM inserted
		
		INSERT INTO Card (Match_ID,Player_ID,Type_ID,[Time])
		Select Match_ID , Player_ID , 2 , [Time] 
		FROM inserted
	end
		ELSE 
			begin
				INSERT INTO Card (Match_ID,Player_ID,Type_ID,[Time])
				Select Match_ID , Player_ID , Type_ID , [Time] 
				FROM inserted
			end
	ELSE 
	IF EXISTS (	
	
	SELECT Match_ID,Player_ID
	FROM Card 
	WHERE Type_ID = 2 AND Match_ID=@match AND Player_ID=@player)
	
	BEGIN 
		PRINT 'The player was canceled from this match'
       	rollback transaction;
		END 
	ELSE 
				begin
				INSERT INTO Card (Match_ID,Player_ID,Type_ID,[Time])
				Select Match_ID , Player_ID , Type_ID , [Time] 
				FROM inserted
				end
	END;
























	  




















