USE DB_SQL_Test
-- ����� ������

--	�������� ������, � ���������� �������� ����� �������� �� ������: � ����� ������ �����
--������� �� �������� � ������� ����� ������� �����?
--���� � �������������� �������: town_to, flight_time.
-- 	����������� ��� �flight_time� ��� ������ ������������ ������� ������.
-- 	������ ��� ������ �������: HH:MM:SS.
GO
SELECT town_from, town_to, 
CONVERT(varchar(5), DATEDIFF(S, time_out, time_in)/3600)+':'
+CONVERT(varchar(5),DATEDIFF(S,time_out, time_in)%3600/60)+':'
+convert(varchar(5),(DateDiff(s,time_out, time_in)%60)) as [flight_time]
FROM Trip WHERE town_from = '�������'

--	�������� ������, � ���������� �������� ������� ���������� � ����� ������� ������.
--���� � �������������� �������: name.

GO
-- � ���������� ������� ��������� ���������� � ����������� �������
SELECT [name] FROM Passenger
WHERE LEN([name]) = (SELECT MAX(LEN([name])) FROM Passenger)
GO
--	�������� ������, � ������� �������� ����� ����� ������� ��������� ������� �� ��������� � ������. 
--� ���� ������ �������� ������ � ������� ������� �� ����� � �������.
--���� � �������������� �������: cost.
-- 	����������� ��� �cost� ��� ������� � ����������� ���������� ������� �������� ������� ���� �������.

GO
SELECT AVG(unit_price) AS [cost]
FROM Passenger, Pass_in_trip, Payment, Good, Good_Type
WHERE Passenger.passenger_id=Pass_in_trip.passenger AND
Passenger.payment=Payment.payment_id AND
Good.good_id = Payment.good AND
Good_Type.good_type_id = Good.type AND 
place = '������' AND good_type_name = '������ �� ���������'

-------------------------------------------------------------------------------------------------------------------------
--����� ������

	--�������� ������, ������� ��������� ���������� ���� ������ � �����-��������� �� �������.
 --	����������, ��� ������������ �������� �� ��������.
GO
UPDATE Trip SET time_in=DATEADD(mi,30,time_in), time_out=DATEADD(mi,30,time_out) WHERE town_to = '�����-���������'


--	�������� ������ � � ��� ������� ����������, ������� �������� � 2021 ���� ������ ��������.
--���� � �������������� �������: name, position_name, costs.
-- 	����������� ��� costs ��� ����������� ����������� ����� ����������.

GO
SELECT [name], Position.position_name, SUM(amount*unit_price) AS [costs] FROM Passenger 
JOIN Position ON Passenger.position = Position.position_id 
JOIN Payment ON Passenger.payment = Payment.payment_id
WHERE Payment.[date] BETWEEN Convert(datetime, '2021-01-01' ) AND Convert(datetime, '2021-31-12' ) 
GROUP BY [passenger_id], [name], [position_name]

	--�������� ������, � ������� �������� ����������: ������� ��� ������ �������� ���������?
 --	����������� ��� �year� ��� �������� �������� ���������.

GO
-- ����� ���� ��������� ������� � ���������� ����� ��������. � ������, ����� 
--�������� ��������� �������, � �� ������, ��� ������� � �������
SELECT name, MIN(DATEDIFF(YEAR, birthday, GETDATE())) AS [year]
FROM Passenger
where birthday = (SELECT max(birthday) FROM Passenger )
GROUP BY name



--�������� ������ ��� ���������� ������ � ������ ����� �� SQL �������� � ����� ��������� � ������ ������� (Good).
GO
INSERT Good VALUES ('���� �� SQL ��������',6)



--	�������� ������, ������� ������� ��������������� �� ���������� ��������� (�� ��������)
--	� ����� (�� �����������) ������ ����������, ����������� ���� �� 1 �����.
--���� � �������������� �������: name, count.
-- 	����������� ��� �count� ��� ������� � ����������� ���������� ������� �������� ���������� ���������.
GO
-- ��� ��� ����� ����� �����������, �� ������������ ����� �� ID ���������, � ����� ��� �� �����
SELECT Passenger.passenger_id, Passenger.name, COUNT(Pass_in_trip.passenger) AS [count] FROM Pass_in_trip
JOIN Passenger ON Passenger.passenger_id = Pass_in_trip.passenger
GROUP BY Passenger.passenger_id, Passenger.name
ORDER BY [count] DESC, Passenger.name ASC



--	�������� ������, � ���������� �������� ����� �������� �� ������: ������� � ��� �� ���������� �������� �� ���������.
--	������� ��������� � ��� ���������, � ����� ����� ������.
--���� � �������������� �������: position_name, name, costs.
GO
SELECT Position.position_name, Passenger.name, SUM(amount*unit_price) AS [costs] 
FROM Payment, Good, Passenger, Good_Type, Position
WHERE Good.good_id=Payment.good AND 
Passenger.payment = Payment.payment_id AND 
Good_Type.good_type_id = Good.type AND 
Position.position_id=Passenger.position AND
good_type_name='��������'
GROUP BY Passenger.name, Position.position_name





--	�������� ������, � ������� �������� ����� ���������� ������ �������, �������
--�� ������������� � 2021 ���� (�� ���������� ����� ����).
--���� � �������������� �������: good_type_name.

GO
SELECT DISTINCT Good_Type.good_type_name FROM Good JOIN Good_Type ON Good.type=Good_Type.good_type_id
WHERE Good_Type.good_type_name NOT IN
(SELECT good_type_name FROM Good 
JOIN Payment ON Good.good_id=Payment.good
JOIN Good_Type ON Good.type=Good_Type.good_type_id
WHERE Payment.date BETWEEN '2021-01-01' AND '2021-31-12'
GROUP BY good_type_name)

--------------------------------------------------------------------------------------------------------------------
--����� ������

--	� ������� SQL ������� ������� ������������ ������� (���������� ���) ����� ����������.
--���� � �������������� �������: max_year.
-- 	����������� ��� �max_year� ��� �������� ������������� �������� � �����.
GO
SELECT MAX(DATEDIFF(YEAR, birthday, GETDATE())) AS [max_year] FROM Passenger
JOIN Position ON Passenger.position=Position.position_id
WHERE birthday=(SELECT MIN(birthday) FROM Passenger) AND Position.position_name = '��������'


--	�������� ������, � ���������� �������� ����� �������� �� ������: 
--	����� ������ ���������� ����� ������� ������� (� ��� ����������� ���� ������������ ��������) ��� ����������?
--���� � �������������� �������: city.

GO
SELECT town_to AS[city] FROM Trip
GROUP BY town_to
ORDER BY COUNT(town_to) DESC




--� ������� SQL ������� ������� ��������, ����������� ���������� ���������� ������.
 --	����������, ��� ���������� � ��������� ����� ��������� �� � ����� ������� (��. ERD ���������).
GO
-- ������� ���� ������������� ��������� ���������� � �������� ������ ��� �������� ������
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



	--�������� ������ � � ��� ������� �������� �������������� ����������, ������� ���� �� 1 ��� �� ��� ����� �������� �� ������ �����.
GO
-- �� ������ ����� ���� �������. ��� ������ "���� �� 1 ��� �� ��� ����� �������� �� ������ �����"?. 
-- ���� � ������ ��������� ����� ���� ������ ���� ����� ������. �� �������� ���� ��� �� ����� �����. 
-- �� ������ ��� ���.
SELECT Passenger.passenger_id FROM Passenger
JOIN Workplace ON Passenger.workplace=Workplace.workplace_id
WHERE [floor]=2

GO


--�������� ������, ������� ������� ����� ���� ��� ����������, ������� ������ �� ����� 
--����� ��� ��� ����� ���, � ���������� ����� ���������� ������. � passenger1 ���������� ��� ��������� � ���������� ���������������.
--���� � �������������� �������: passenger1, passenger2, count.
-- 	����������� ����������� �as passenger1� � �as passenger2� ��� ������ ���� ����������.
-- 	����������� ����������� �as count� ��� ���������� ������� �������� ���������� ������.

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
-- ����� ���������


--�������� �������� ���������, ������� ����� ������ ����� ������ (��������) ������� ��������� �� ����� (name)
--� �����, �� ������� ������������� ��������. 
-- ��� ����� ���������� � �������� ���������� �������� ������� ��� (name), ���� (floor) � ������������ �� �� ����� ������.
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



--�������� ���������� �������� ��������� (� �������� ���������� ����������� ����� ��� � ����� ����).
GO
DECLARE @RC int
DECLARE @name varchar(100)
DECLARE @floor int

SET @name = '���� ������'
SET @floor = 2
-- TODO: ������� ����� �������� ����������.

EXECUTE @RC = [dbo].[SearchWorkplace] 
   @name
  ,@floor




--�������� ���������������� ������� � ������ �ConvertBirthday�, ������� ��������������� 
--������ ���� �������� ��������� �� �2007-05-08 12:35:29.123� � �8 ��� 2007, �������.
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


--�������� ������ � �������������� ������� �ConvertBirthday�, ����������� �������� �������� �������� ����������
--� �� ��� �������� � ����� �������.
-- ���� � �������������� �������: name, convert_bday.

GO
SELECT Passenger.[name], dbo.ConvertBirthday(birthday) AS [convert_bday] FROM Passenger








