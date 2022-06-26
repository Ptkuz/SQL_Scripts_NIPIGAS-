USE DB_SQL_Test
-- ЧАСТЬ ПЕРВАЯ

--	Написать запрос, в результате которого можно ответить на вопрос: В какие города можно
--улететь из Воронежа и сколько будет длиться полет?
--Поля в результирующей таблице: town_to, flight_time.
-- 	Используйте имя «flight_time» для вывода необходимого времени полета.
-- 	Формат для вывода времени: HH:MM:SS.
GO
SELECT town_from, town_to, 
CONVERT(varchar(5), DATEDIFF(S, time_out, time_in)/3600)+':'
+CONVERT(varchar(5),DATEDIFF(S,time_out, time_in)%3600/60)+':'
+convert(varchar(5),(DateDiff(s,time_out, time_in)%60)) as [flight_time]
FROM Trip WHERE town_from = 'Воронеж'

--	Написать запрос, в результате которого вывести пассажиров с самым длинным именем.
--Поле в результирующей таблице: name.

GO
-- Я специально добавил несколько пассажиров с одинаковыми именами
SELECT [name] FROM Passenger
WHERE LEN([name]) = (SELECT MAX(LEN([name])) FROM Passenger)
GO
--	Написать запрос, с помощью которого можно найти среднюю стоимость билетов на транспорт в Москве. 
--В базе данных хранятся данных о покупке билетов на метро и автобус.
--Поле в результирующей таблице: cost.
-- 	Используйте имя «cost» для столбца с результатом агрегатной функции подсчета средней цены билетов.

GO
SELECT AVG(unit_price) AS [cost]
FROM Passenger, Pass_in_trip, Payment, Good, Good_Type
WHERE Passenger.passenger_id=Pass_in_trip.passenger AND
Passenger.payment=Payment.payment_id AND
Good.good_id = Payment.good AND
Good_Type.good_type_id = Good.type AND 
place = 'Москва' AND good_type_name = 'Билеты на транспорт'

-------------------------------------------------------------------------------------------------------------------------
--Часть ВТОРАЯ

	--Напишите запрос, который перенесет расписание всех рейсов в Санкт-Петербург на полчаса.
 --	Учитывайте, что длительность перелета не меняется.
GO
UPDATE Trip SET time_in=DATEADD(mi,30,time_in), time_out=DATEADD(mi,30,time_out) WHERE town_to = 'Санкт-Петербург'


--	Напишите запрос и с его помощью определите, сколько потратил в 2021 году каждый пассажир.
--Поля в результирующей таблице: name, position_name, costs.
-- 	Используйте имя costs для отображения затраченной суммы пассажиром.

GO
SELECT [name], Position.position_name, SUM(amount*unit_price) AS [costs] FROM Passenger 
JOIN Position ON Passenger.position = Position.position_id 
JOIN Payment ON Passenger.payment = Payment.payment_id
WHERE Payment.[date] BETWEEN Convert(datetime, '2021-01-01' ) AND Convert(datetime, '2021-31-12' ) 
GROUP BY [passenger_id], [name], [position_name]

	--Напишите запрос, с помощью которого определите: Сколько лет самому молодому пассажиру?
 --	Используйте имя «year» для указания возраста пассажира.

GO
-- Может быть несколько неловек с одинаковой датой рождения. А значит, нужно 
--выводить несколько человек, а не одного, как сказано в задании
SELECT name, MIN(DATEDIFF(YEAR, birthday, GETDATE())) AS [year]
FROM Passenger
where birthday = (SELECT max(birthday) FROM Passenger )
GROUP BY name



--Напишите запрос для добавления товара с именем «Курс по SQL запросам» и типом «Обучение» в список товаров (Good).
GO
INSERT Good VALUES ('Курс по SQL запросам',6)



--	Напишите запрос, который выведет отсортированный по количеству перелетов (по убыванию)
--	и имени (по возрастанию) список пассажиров, совершивших хотя бы 1 полет.
--Поля в результирующей таблице: name, count.
-- 	Используйте имя «count» для столбца с результатом агрегатной функции подсчета количества перелетов.
GO
-- Так как имена могут повторяться, то группировать будем по ID пассажира, а потом уже по имени
SELECT Passenger.passenger_id, Passenger.name, COUNT(Pass_in_trip.passenger) AS [count] FROM Pass_in_trip
JOIN Passenger ON Passenger.passenger_id = Pass_in_trip.passenger
GROUP BY Passenger.passenger_id, Passenger.name
ORDER BY [count] DESC, Passenger.name ASC



--	Напишите запрос, в результате которого можно ответить на вопрос: Сколько и кто из пассажиров потратил на «Обучение».
--	Вывести должность и имя пассажира, а также сумму затрат.
--Поля в результирующей таблице: position_name, name, costs.
GO
SELECT Position.position_name, Passenger.name, SUM(amount*unit_price) AS [costs] 
FROM Payment, Good, Passenger, Good_Type, Position
WHERE Good.good_id=Payment.good AND 
Passenger.payment = Payment.payment_id AND 
Good_Type.good_type_id = Good.type AND 
Position.position_id=Passenger.position AND
good_type_name='Обучение'
GROUP BY Passenger.name, Position.position_name





--	Напишите запрос, с помощью которого можно определить группы товаров, которые
--не приобретались в 2021 году (но покупались когда либо).
--Поля в результирующей таблице: good_type_name.

GO
SELECT DISTINCT Good_Type.good_type_name FROM Good JOIN Good_Type ON Good.type=Good_Type.good_type_id
WHERE Good_Type.good_type_name NOT IN
(SELECT good_type_name FROM Good 
JOIN Payment ON Good.good_id=Payment.good
JOIN Good_Type ON Good.type=Good_Type.good_type_id
WHERE Payment.date BETWEEN '2021-01-01' AND '2021-31-12'
GROUP BY good_type_name)

--------------------------------------------------------------------------------------------------------------------
--Часть ТРЕТЬЯ

--	С помощью SQL запроса найдите максимальный возраст (количество лет) среди менеджеров.
--Поля в результирующей таблице: max_year.
-- 	Используйте имя «max_year» для указания максимального возраста в годах.
GO
SELECT MAX(DATEDIFF(YEAR, birthday, GETDATE())) AS [max_year] FROM Passenger
JOIN Position ON Passenger.position=Position.position_id
WHERE birthday=(SELECT MIN(birthday) FROM Passenger) AND Position.position_name = 'Менеджер'


--	Напишите запрос, в результате которого можно ответить на вопрос: 
--	Какие города пользуются самым большим спросом (в эти направления чаще направляются самолеты) для пассажиров?
--Поле в результирующей таблице: city.

GO
SELECT town_to AS[city] FROM Trip
GROUP BY town_to
ORDER BY COUNT(town_to) DESC




--С помощью SQL запроса удалите компании, совершившие наименьшее количество рейсов.
 --	Учитывайте, что информация о компаниях может храниться не в одной таблице (см. ERD диаграмму).
GO
-- Заранее было предусмотрено каскадное обновление и удаление данных при создании таблиц
WITH Trip_Company AS (
    SELECT air_company, COUNT(trip_id) AS num_trips FROM Trip GROUP BY air_company
)

,Company_Min_Trips AS (
    SELECT air_company
    FROM Trip_Company
    WHERE num_trips = (SELECT MIN(num_trips) FROM Trip_Company)
)

DELETE Air_Company
FROM Air_Company
JOIN Company_Min_Trips
ON Air_Company.air_company_id = Company_Min_Trips.air_company;



	--Напишите запрос и с его помощью выведите идентификаторы пассажиров, которые хотя бы 1 раз за все время работали на втором этаже.
GO
-- Не совсем понял суть задания. Что значит "Хотя бы 1 раз за все время работали на втором этаже"?. 
-- Ведь у одного пассажира может быть только одно место работы. Он работает один раз на одном этаже. 
-- Но сделал вот так.
SELECT Passenger.passenger_id FROM Passenger
JOIN Workplace ON Passenger.workplace=Workplace.workplace_id
WHERE [floor]=2

GO


--Напишите запрос, который выведет имена всех пар пассажиров, которые летели на одном 
--рейсе три или более раз, и количество таких совместных рейсов. В passenger1 разместите имя пассажира с наименьшим идентификатором.
--Поля в результирующей таблице: passenger1, passenger2, count.
-- 	Используйте конструкции «as passenger1» и «as passenger2» для вывода имен пассажиров.
-- 	Используйте конструкцию «as count» для агрегатной функции подсчета количества рейсов.

GO
SELECT passenger1, passenger2, COUNT(trip1) AS [count]
FROM (SELECT Passenger.passenger_id AS p1, name AS passenger1, trip AS trip1 FROM Passenger 
    INNER JOIN Pass_in_trip ON Passenger.passenger_id = Pass_in_trip.passenger 
    GROUP BY Passenger.passenger_id, name, trip) AS gp1 
    INNER JOIN (
        SELECT Passenger.passenger_id AS p2, name AS passenger2, trip AS trip2 
        FROM Passenger 
        INNER JOIN Pass_in_trip ON Passenger.passenger_id = Pass_in_trip.passenger
        GROUP BY Passenger.passenger_id, name, trip) AS gp2 
    ON gp1.trip1 = gp2.trip2
WHERE (p1<p2) GROUP BY passenger1, passenger2 HAVING (COUNT(trip2)>1);

---------------------------------------------------------------------------------------------------------------------------
-- Часть ЧЕТВЕРТАЯ


--Создайте хранимую процедуру, которая будет искать места работы (компании) нужного пассажира по имени (name)
--и этажу, на котором располагается компания. 
-- Для этого необходимо в качестве параметров получать искомое имя (name), этаж (floor) и использовать их во время поиска.
GO
CREATE PROCEDURE SearchWorkplace
(
	@name VARCHAR(100),
	@floor INT
)
AS
BEGIN
SELECT Workplace.workplace_name FROM Passenger
JOIN Workplace ON Passenger.workplace=Workplace.workplace_id
WHERE Passenger.[name]=@name AND [floor]=@floor
END



--Вызовите написанную хранимую процедуру (в качестве параметров используйте любое имя и любой этаж).
GO
DECLARE @RC int
DECLARE @name varchar(100)
DECLARE @floor int

SET @name = 'Джон Шепард'
SET @floor = 2
-- TODO: задайте здесь значения параметров.

EXECUTE @RC = [dbo].[SearchWorkplace] 
   @name
  ,@floor




--Создайте пользовательскую функцию с именем «ConvertBirthday», которая преобразовывает 
--формат даты рождения пассажира из «2007-05-08 12:35:29.123» в «8 мая 2007, вторник».
GO
CREATE FUNCTION dbo.ConvertBirthday(@birthday AS DATETIME)
RETURNS NVARCHAR(200)
AS
BEGIN
DECLARE @ret NVARCHAR(200);  
DECLARE @ret1 NVARCHAR(200);  
DECLARE @result NVARCHAR(200);  
SET @ret = REPLACE(CONVERT(varchar(11), @birthday, 106), '-', ' ')
SET @ret1 = DATENAME(dw,@birthday)
SET @result = @ret + ', ' + @ret1
RETURN @result
END


--Напишите запрос с использованием функции «ConvertBirthday», результатом которого является перечень пассажиров
--и их дат рождения в новом формате.
-- Поля в результирующей таблице: name, convert_bday.

GO
SELECT Passenger.[name], dbo.ConvertBirthday(birthday) AS [convert_bday] FROM Passenger








