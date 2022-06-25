CREATE DATABASE [DB_SQL_Test]
GO
USE DB_SQL_Test
GO
--Таблица Авиакомпаний
CREATE TABLE Air_Company
(
	[air_company_id] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[aircompany_name] VARCHAR(200) NOT NULL
)
GO
--Таблица Типов товаров
CREATE TABLE Good_Type
(
	[good_type_id] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[good_type_name] VARCHAR(200) NOT NULL
);
GO
--Таблица Должностей
CREATE TABLE Position
(
	[position_id] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[position_name] VARCHAR(200) NOT NULL
);
GO
--Таблица Компаний 
CREATE TABLE Workplace
(
	[workplace_id] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[workplace_name] VARCHAR(100) NOT NULL,
	[address] VARCHAR(100) NOT NULL,
	[floor] INT NOT NULL
);
GO
--Таблица Товаров
CREATE TABLE Good
(
	[good_id] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[good_name] VARCHAR(100) NOT NULL,
	[type] INT NOT NULL,
	FOREIGN KEY ([type]) REFERENCES Good_Type([good_type_id]) ON DELETE CASCADE ON UPDATE CASCADE

);
GO
-- Таблица Платежи по покупкам
CREATE TABLE Payment
(
	[payment_id] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[good] INT NOT NULL,
	[amount] INT NOT NULL,
	[unit_price] INT NOT NULL,
	[date] DATETIME NOT NULL,
	FOREIGN KEY ([good]) REFERENCES Good([good_id]) ON DELETE CASCADE ON UPDATE CASCADE
);
GO
-- Таблица Пассажиров, купивших билет
CREATE TABLE Passenger
(
	[passenger_id] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[name] VARCHAR(100) NOT NULL,
	[position] INT NOT NULL,
	[workplace] INT NOT NULL,
	[payment] INT NOT NULL,
	[birthday] DATETIME,
	FOREIGN KEY ([position]) REFERENCES Position([position_id]) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY ([workplace]) REFERENCES Workplace([workplace_id]) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (payment) REFERENCES Payment([payment_id]) ON DELETE CASCADE ON UPDATE CASCADE
);
GO
-- Таблица купленных билетов
CREATE TABLE Trip
(
	[trip_id] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[air_company] INT NOT NULL,
	[plane] VARCHAR(100) NOT NULL,
	[town_from] VARCHAR(100) NOT NULL,
	[town_to] VARCHAR(100) NOT NULL,
	[time_out] DATETIME NOT NULL,
	[time_in] DATETIME NOT NULL,
	FOREIGN KEY ([air_company]) REFERENCES Air_Company([air_company_id]) ON DELETE CASCADE ON UPDATE CASCADE
);
-- Таблица, связывающая купленные билеты с пассажирами
CREATE TABLE Pass_in_trip
(
	[id] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[trip] INT NOT NULL,
	[passenger] INT NOT NULL,
	[place] VARCHAR(100) NOT NULL,
	FOREIGN KEY ([trip]) REFERENCES Trip([trip_id]) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY ([passenger]) REFERENCES Passenger([passenger_id]) ON DELETE CASCADE ON UPDATE CASCADE
)






