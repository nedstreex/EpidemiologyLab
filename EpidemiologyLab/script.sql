IF DB_ID('EpidemiologyDB') IS NOT NULL
BEGIN
    ALTER DATABASE EpidemiologyDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE EpidemiologyDB;
END
GO

CREATE DATABASE EpidemiologyDB;
GO
USE EpidemiologyDB;
GO

CREATE TABLE dbo.Person (
    PersonID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Age INT CHECK (Age > 0 AND Age < 120),
    City NVARCHAR(50),
    TestResult NVARCHAR(20) CHECK (TestResult IN ('Positive', 'Negative', 'Pending', 'Recovered'))
) AS NODE;

CREATE TABLE dbo.Place (
    PlaceID INT IDENTITY(1,1) PRIMARY KEY,
    PlaceName NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200),
    PlaceType NVARCHAR(50) CHECK (PlaceType IN ('Restaurant', 'Hospital', 'Office', 'Mall', 'School', 'Transport', 'Home')),
    RiskLevel NVARCHAR(20) CHECK (RiskLevel IN ('Low', 'Medium', 'High', 'Critical'))
) AS NODE;

CREATE TABLE dbo.Virus (
    VirusID INT IDENTITY(1,1) PRIMARY KEY,
    VirusName NVARCHAR(100) NOT NULL,
    Strain NVARCHAR(100),
    OriginCountry NVARCHAR(50),
    R0 FLOAT CHECK (R0 > 0)
) AS NODE;

CREATE TABLE dbo.Symptom (
    SymptomID INT IDENTITY(1,1) PRIMARY KEY,
    SymptomName NVARCHAR(100) NOT NULL,
    Severity NVARCHAR(20) CHECK (Severity IN ('Mild', 'Moderate', 'Severe', 'Critical')),
    Category NVARCHAR(50)
) AS NODE;

CREATE TABLE dbo.ContactedWith (
    EdgeID INT IDENTITY(1,1) PRIMARY KEY,
    ContactDate DATE NOT NULL,
    ContactDuration INT,
    ContactType NVARCHAR(20) CHECK (ContactType IN ('Direct', 'Indirect', 'Aerosol')),
    Weight DECIMAL(3,2) DEFAULT 1.0
) AS EDGE;

ALTER TABLE dbo.ContactedWith
ADD CONSTRAINT EC_ContactedWith
CONNECTION (Person TO Person);

CREATE TABLE dbo.VisitedPlace (
    EdgeID INT IDENTITY(1,1) PRIMARY KEY,
    VisitDate DATE NOT NULL,
    DurationMinutes INT,
    WoreMask BIT DEFAULT 0,
    Notes NVARCHAR(200)
) AS EDGE;

ALTER TABLE dbo.VisitedPlace
ADD CONSTRAINT EC_VisitedPlace
CONNECTION (Person TO Place);

CREATE TABLE dbo.InfectedWith (
    EdgeID INT IDENTITY(1,1) PRIMARY KEY,
    DiagnosisDate DATE NOT NULL,
    SymptomsOnsetDate DATE,
    Severity NVARCHAR(20) CHECK (Severity IN ('Asymptomatic', 'Mild', 'Moderate', 'Severe', 'Critical')),
    Outcome NVARCHAR(20) CHECK (Outcome IN ('Active', 'Recovered', 'Deceased'))
) AS EDGE;

ALTER TABLE dbo.InfectedWith
ADD CONSTRAINT EC_InfectedWith
CONNECTION (Person TO Virus);

CREATE TABLE dbo.ShowsSymptom (
    EdgeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstReportedDate DATE NOT NULL,
    DurationDays INT,
    Intensity NVARCHAR(20) CHECK (Intensity IN ('Mild', 'Moderate', 'Severe'))
) AS EDGE;

ALTER TABLE dbo.ShowsSymptom
ADD CONSTRAINT EC_ShowsSymptom
CONNECTION (Person TO Symptom);

CREATE TABLE dbo.PlaceContaminatedWith (
    EdgeID INT IDENTITY(1,1) PRIMARY KEY,
    DetectionDate DATE NOT NULL,
    ContaminationLevel NVARCHAR(20) CHECK (ContaminationLevel IN ('Low', 'Medium', 'High', 'Critical')),
    SurfaceType NVARCHAR(50)
) AS EDGE;

ALTER TABLE dbo.PlaceContaminatedWith
ADD CONSTRAINT EC_PlaceContaminatedWith
CONNECTION (Place TO Virus);

INSERT INTO dbo.Person (FullName, Age, City, TestResult) VALUES
(N'Иванов Иван Иванович', 34, N'Москва', 'Positive'),
(N'Петров Петр Петрович', 28, N'Москва', 'Positive'),
(N'Сидорова Анна Сергеевна', 45, N'Москва', 'Negative'),
(N'Кузнецов Дмитрий Алексеевич', 52, N'Санкт-Петербург', 'Positive'),
(N'Смирнова Ольга Викторовна', 31, N'Санкт-Петербург', 'Recovered'),
(N'Васильев Алексей Павлович', 23, N'Казань', 'Positive'),
(N'Федорова Елена Николаевна', 41, N'Казань', 'Pending'),
(N'Морозов Игорь Андреевич', 37, N'Новосибирск', 'Positive'),
(N'Волкова Мария Дмитриевна', 29, N'Новосибирск', 'Negative'),
(N'Соколов Никита Сергеевич', 19, N'Москва', 'Positive'),
(N'Козлова Алина Романовна', 63, N'Москва', 'Recovered'),
(N'Новиков Артем Викторович', 48, N'Екатеринбург', 'Positive'),
(N'Лебедева Татьяна Игоревна', 35, N'Екатеринбург', 'Positive'),
(N'Григорьев Павел Станиславович', 55, N'Сочи', 'Negative'),
(N'Зайцева Екатерина Валерьевна', 26, N'Сочи', 'Positive'),
(N'Макаров Денис Евгеньевич', 42, N'Владивосток', 'Pending'),
(N'Богданова Светлана Олеговна', 39, N'Владивосток', 'Positive'),
(N'Тимофеев Роман Александрович', 31, N'Москва', 'Negative'),
(N'Борисова Наталья Ильинична', 47, N'Казань', 'Recovered'),
(N'Яковлев Сергей Константинович', 58, N'Новосибирск', 'Positive');

INSERT INTO dbo.Place (PlaceName, Address, PlaceType, RiskLevel) VALUES
(N'Ресторан ВкусВилл', N'ул. Тверская, д.15', 'Restaurant', 'High'),
(N'Городская больница №1', N'ул. Ленина, д.100', 'Hospital', 'Critical'),
(N'Офис ТехноПарк', N'БЦ Высота, этаж 12', 'Office', 'Medium'),
(N'ТЦ Мега', N'ул. Новая, д.25', 'Mall', 'High'),
(N'Школа №5', N'ул. Садовая, д.8', 'School', 'Medium'),
(N'Метро Площадь Ленина', N'ст. Площадь Ленина', 'Transport', 'High'),
(N'Квартира №45', N'ул. Мира, д.10, кв.45', 'Home', 'Low'),
(N'Аэропорт Домодедово', N'г. Домодедово', 'Transport', 'High'),
(N'Кафе Матрёшка', N'ул. Арбат, д.20', 'Restaurant', 'Medium'),
(N'Поликлиника №3', N'ул. Зеленая, д.5', 'Hospital', 'High'),
(N'Фитнес-клуб Заря', N'ул. Спортивная, д.30', 'Office', 'Medium'),
(N'ТЦ Колизей', N'ул. Главная, д.50', 'Mall', 'High'),
(N'Ж/д вокзал', N'пл. Вокзальная, д.1', 'Transport', 'High'),
(N'Жилой дом №7', N'ул. Парковая, д.7', 'Home', 'Medium'),
(N'Ресторан Панорама', N'ул. Набережная, д.3', 'Restaurant', 'High');

INSERT INTO dbo.Virus (VirusName, Strain, OriginCountry, R0) VALUES
(N'SARS-CoV-2', N'Альфа', N'Великобритания', 3.5),
(N'SARS-CoV-2', N'Дельта', N'Индия', 5.8),
(N'SARS-CoV-2', N'Омикрон', N'Южная Африка', 7.2),
(N'SARS-CoV-2', N'Бета', N'Южная Африка', 4.2),
(N'SARS-CoV-2', N'Гамма', N'Бразилия', 5.0),
(N'Грипп А', N'H1N1', N'Мексика', 1.8),
(N'Грипп B', N'Victoria', N'Китай', 1.5),
(N'Норовирус', N'GII.4', N'Австралия', 2.3),
(N'Ротавирус', N'G1', N'США', 1.9),
(N'Вирус гепатита А', N'IA', N'Египет', 1.1);

INSERT INTO dbo.Symptom (SymptomName, Severity, Category) VALUES
(N'Кашель', 'Moderate', 'Respiratory'),
(N'Температура 38+', 'Moderate', 'General'),
(N'Потеря обоняния', 'Moderate', 'Neurological'),
(N'Одышка', 'Severe', 'Respiratory'),
(N'Утомляемость', 'Mild', 'General'),
(N'Головная боль', 'Moderate', 'Neurological'),
(N'Боль в горле', 'Mild', 'Respiratory'),
(N'Пневмония', 'Critical', 'Respiratory'),
(N'Диарея', 'Moderate', 'Digestive'),
(N'Тошнота', 'Mild', 'Digestive'),
(N'Боль в мышцах', 'Moderate', 'General'),
(N'Спутанность сознания', 'Severe', 'Neurological');

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-01', 120, 'Direct', 0.9
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 1 AND p2.PersonID = 2;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-02', 60, 'Direct', 0.8
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 2 AND p2.PersonID = 3;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-03', 45, 'Aerosol', 0.5
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 3 AND p2.PersonID = 4;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-04', 90, 'Direct', 1.0
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 1 AND p2.PersonID = 5;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-05', 30, 'Indirect', 0.3
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 5 AND p2.PersonID = 6;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-06', 120, 'Direct', 0.9
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 6 AND p2.PersonID = 7;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-07', 75, 'Aerosol', 0.7
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 7 AND p2.PersonID = 8;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-08', 40, 'Direct', 0.6
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 8 AND p2.PersonID = 9;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-09', 110, 'Direct', 0.8
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 10 AND p2.PersonID = 11;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-10', 80, 'Direct', 0.7
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 12 AND p2.PersonID = 13;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-11', 55, 'Indirect', 0.4
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 14 AND p2.PersonID = 15;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-12', 100, 'Aerosol', 0.8
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 16 AND p2.PersonID = 17;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-13', 45, 'Direct', 0.5
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 18 AND p2.PersonID = 19;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-14', 60, 'Direct', 0.6
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 20 AND p2.PersonID = 1;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-15', 90, 'Direct', 0.9
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 3 AND p2.PersonID = 10;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-16', 70, 'Indirect', 0.5
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 4 AND p2.PersonID = 12;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-17', 30, 'Aerosol', 0.3
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 6 AND p2.PersonID = 16;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-18', 120, 'Direct', 1.0
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 9 AND p2.PersonID = 17;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-19', 45, 'Direct', 0.7
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 11 AND p2.PersonID = 18;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p1.$node_id, p2.$node_id, '2024-12-20', 50, 'Direct', 0.6
FROM dbo.Person p1, dbo.Person p2 WHERE p1.PersonID = 13 AND p2.PersonID = 20;

INSERT INTO dbo.ContactedWith ($from_id, $to_id, ContactDate, ContactDuration, ContactType, Weight)
SELECT p2.$node_id, p1.$node_id, ContactDate, ContactDuration, ContactType, Weight
FROM dbo.ContactedWith c
JOIN dbo.Person p1 ON c.$from_id = p1.$node_id
JOIN dbo.Person p2 ON c.$to_id = p2.$node_id;

INSERT INTO dbo.VisitedPlace ($from_id, $to_id, VisitDate, DurationMinutes, WoreMask)
SELECT p.$node_id, pl.$node_id, '2024-12-01', 90, 0
FROM dbo.Person p, dbo.Place pl WHERE p.PersonID = 1 AND pl.PlaceID = 1;

INSERT INTO dbo.VisitedPlace ($from_id, $to_id, VisitDate, DurationMinutes, WoreMask)
SELECT p.$node_id, pl.$node_id, '2024-12-02', 180, 1
FROM dbo.Person p, dbo.Place pl WHERE p.PersonID = 2 AND pl.PlaceID = 2;

INSERT INTO dbo.VisitedPlace ($from_id, $to_id, VisitDate, DurationMinutes, WoreMask)
SELECT p.$node_id, pl.$node_id, '2024-12-03', 480, 0
FROM dbo.Person p, dbo.Place pl WHERE p.PersonID = 3 AND pl.PlaceID = 3;

INSERT INTO dbo.VisitedPlace ($from_id, $to_id, VisitDate, DurationMinutes, WoreMask)
SELECT p.$node_id, pl.$node_id, '2024-12-04', 120, 0
FROM dbo.Person p, dbo.Place pl WHERE p.PersonID = 4 AND pl.PlaceID = 4;

INSERT INTO dbo.VisitedPlace ($from_id, $to_id, VisitDate, DurationMinutes, WoreMask)
SELECT p.$node_id, pl.$node_id, '2024-12-05', 360, 1
FROM dbo.Person p, dbo.Place pl WHERE p.PersonID = 5 AND pl.PlaceID = 5;

INSERT INTO dbo.VisitedPlace ($from_id, $to_id, VisitDate, DurationMinutes, WoreMask)
SELECT p.$node_id, pl.$node_id, '2024-12-06', 45, 0
FROM dbo.Person p, dbo.Place pl WHERE p.PersonID = 6 AND pl.PlaceID = 6;

INSERT INTO dbo.VisitedPlace ($from_id, $to_id, VisitDate, DurationMinutes, WoreMask)
SELECT p.$node_id, pl.$node_id, '2024-12-07', 1440, 0
FROM dbo.Person p, dbo.Place pl WHERE p.PersonID = 7 AND pl.PlaceID = 7;

INSERT INTO dbo.VisitedPlace ($from_id, $to_id, VisitDate, DurationMinutes, WoreMask)
SELECT p.$node_id, pl.$node_id, '2024-12-08', 90, 0
FROM dbo.Person p, dbo.Place pl WHERE p.PersonID = 8 AND pl.PlaceID = 8;

INSERT INTO dbo.VisitedPlace ($from_id, $to_id, VisitDate, DurationMinutes, WoreMask)
SELECT p.$node_id, pl.$node_id, '2024-12-09', 60, 1
FROM dbo.Person p, dbo.Place pl WHERE p.PersonID = 9 AND pl.PlaceID = 9;

INSERT INTO dbo.VisitedPlace ($from_id, $to_id, VisitDate, DurationMinutes, WoreMask)
SELECT p.$node_id, pl.$node_id, '2024-12-10', 120, 0
FROM dbo.Person p, dbo.Place pl WHERE p.PersonID = 10 AND pl.PlaceID = 10;

INSERT INTO dbo.VisitedPlace ($from_id, $to_id, VisitDate, DurationMinutes, WoreMask)
SELECT p.$node_id, pl.$node_id, '2024-12-11', 240, 0
FROM dbo.Person p, dbo.Place pl WHERE p.PersonID = 11 AND pl.PlaceID = 1;

INSERT INTO dbo.VisitedPlace ($from_id, $to_id, VisitDate, DurationMinutes, WoreMask)
SELECT p.$node_id, pl.$node_id, '2024-12-12', 30, 1
FROM dbo.Person p, dbo.Place pl WHERE p.PersonID = 12 AND pl.PlaceID = 12;

INSERT INTO dbo.VisitedPlace ($from_id, $to_id, VisitDate, DurationMinutes, WoreMask)
SELECT p.$node_id, pl.$node_id, '2024-12-13', 180, 0
FROM dbo.Person p, dbo.Place pl WHERE p.PersonID = 14 AND pl.PlaceID = 13;

INSERT INTO dbo.VisitedPlace ($from_id, $to_id, VisitDate, DurationMinutes, WoreMask)
SELECT p.$node_id, pl.$node_id, '2024-12-14', 1440, 1
FROM dbo.Person p, dbo.Place pl WHERE p.PersonID = 16 AND pl.PlaceID = 14;

INSERT INTO dbo.VisitedPlace ($from_id, $to_id, VisitDate, DurationMinutes, WoreMask)
SELECT p.$node_id, pl.$node_id, '2024-12-15', 90, 0
FROM dbo.Person p, dbo.Place pl WHERE p.PersonID = 18 AND pl.PlaceID = 15;

INSERT INTO dbo.InfectedWith ($from_id, $to_id, DiagnosisDate, SymptomsOnsetDate, Severity, Outcome)
SELECT p.$node_id, v.$node_id, '2024-12-03', '2024-12-01', 'Moderate', 'Active'
FROM dbo.Person p, dbo.Virus v WHERE p.PersonID = 1 AND v.VirusID = 1;

INSERT INTO dbo.InfectedWith ($from_id, $to_id, DiagnosisDate, SymptomsOnsetDate, Severity, Outcome)
SELECT p.$node_id, v.$node_id, '2024-12-04', '2024-12-02', 'Mild', 'Recovered'
FROM dbo.Person p, dbo.Virus v WHERE p.PersonID = 2 AND v.VirusID = 2;

INSERT INTO dbo.InfectedWith ($from_id, $to_id, DiagnosisDate, SymptomsOnsetDate, Severity, Outcome)
SELECT p.$node_id, v.$node_id, '2024-12-05', '2024-12-03', 'Severe', 'Active'
FROM dbo.Person p, dbo.Virus v WHERE p.PersonID = 4 AND v.VirusID = 1;

INSERT INTO dbo.InfectedWith ($from_id, $to_id, DiagnosisDate, SymptomsOnsetDate, Severity, Outcome)
SELECT p.$node_id, v.$node_id, '2024-12-06', '2024-12-04', 'Moderate', 'Recovered'
FROM dbo.Person p, dbo.Virus v WHERE p.PersonID = 5 AND v.VirusID = 3;

INSERT INTO dbo.InfectedWith ($from_id, $to_id, DiagnosisDate, SymptomsOnsetDate, Severity, Outcome)
SELECT p.$node_id, v.$node_id, '2024-12-07', '2024-12-05', 'Mild', 'Active'
FROM dbo.Person p, dbo.Virus v WHERE p.PersonID = 6 AND v.VirusID = 2;

INSERT INTO dbo.InfectedWith ($from_id, $to_id, DiagnosisDate, SymptomsOnsetDate, Severity, Outcome)
SELECT p.$node_id, v.$node_id, '2024-12-08', '2024-12-06', 'Critical', 'Deceased'
FROM dbo.Person p, dbo.Virus v WHERE p.PersonID = 8 AND v.VirusID = 1;

INSERT INTO dbo.InfectedWith ($from_id, $to_id, DiagnosisDate, SymptomsOnsetDate, Severity, Outcome)
SELECT p.$node_id, v.$node_id, '2024-12-09', '2024-12-07', 'Moderate', 'Active'
FROM dbo.Person p, dbo.Virus v WHERE p.PersonID = 10 AND v.VirusID = 2;

INSERT INTO dbo.InfectedWith ($from_id, $to_id, DiagnosisDate, SymptomsOnsetDate, Severity, Outcome)
SELECT p.$node_id, v.$node_id, '2024-12-10', '2024-12-08', 'Mild', 'Recovered'
FROM dbo.Person p, dbo.Virus v WHERE p.PersonID = 12 AND v.VirusID = 3;

INSERT INTO dbo.InfectedWith ($from_id, $to_id, DiagnosisDate, SymptomsOnsetDate, Severity, Outcome)
SELECT p.$node_id, v.$node_id, '2024-12-11', '2024-12-09', 'Severe', 'Active'
FROM dbo.Person p, dbo.Virus v WHERE p.PersonID = 13 AND v.VirusID = 1;

INSERT INTO dbo.InfectedWith ($from_id, $to_id, DiagnosisDate, SymptomsOnsetDate, Severity, Outcome)
SELECT p.$node_id, v.$node_id, '2024-12-12', '2024-12-10', 'Mild', 'Active'
FROM dbo.Person p, dbo.Virus v WHERE p.PersonID = 15 AND v.VirusID = 5;

INSERT INTO dbo.InfectedWith ($from_id, $to_id, DiagnosisDate, SymptomsOnsetDate, Severity, Outcome)
SELECT p.$node_id, v.$node_id, '2024-12-13', '2024-12-11', 'Moderate', 'Active'
FROM dbo.Person p, dbo.Virus v WHERE p.PersonID = 17 AND v.VirusID = 6;

INSERT INTO dbo.InfectedWith ($from_id, $to_id, DiagnosisDate, SymptomsOnsetDate, Severity, Outcome)
SELECT p.$node_id, v.$node_id, '2024-12-14', '2024-12-12', 'Asymptomatic', 'Active'
FROM dbo.Person p, dbo.Virus v WHERE p.PersonID = 18 AND v.VirusID = 7;

INSERT INTO dbo.InfectedWith ($from_id, $to_id, DiagnosisDate, SymptomsOnsetDate, Severity, Outcome)
SELECT p.$node_id, v.$node_id, '2024-12-15', '2024-12-13', 'Mild', 'Active'
FROM dbo.Person p, dbo.Virus v WHERE p.PersonID = 20 AND v.VirusID = 8;

INSERT INTO dbo.ShowsSymptom ($from_id, $to_id, FirstReportedDate, DurationDays, Intensity)
SELECT p.$node_id, s.$node_id, '2024-12-02', 7, 'Moderate'
FROM dbo.Person p, dbo.Symptom s WHERE p.PersonID = 1 AND s.SymptomID = 1;

INSERT INTO dbo.ShowsSymptom ($from_id, $to_id, FirstReportedDate, DurationDays, Intensity)
SELECT p.$node_id, s.$node_id, '2024-12-02', 5, 'Moderate'
FROM dbo.Person p, dbo.Symptom s WHERE p.PersonID = 1 AND s.SymptomID = 2;

INSERT INTO dbo.ShowsSymptom ($from_id, $to_id, FirstReportedDate, DurationDays, Intensity)
SELECT p.$node_id, s.$node_id, '2024-12-03', 10, 'Severe'
FROM dbo.Person p, dbo.Symptom s WHERE p.PersonID = 4 AND s.SymptomID = 4;

INSERT INTO dbo.ShowsSymptom ($from_id, $to_id, FirstReportedDate, DurationDays, Intensity)
SELECT p.$node_id, s.$node_id, '2024-12-05', 4, 'Mild'
FROM dbo.Person p, dbo.Symptom s WHERE p.PersonID = 6 AND s.SymptomID = 3;

INSERT INTO dbo.ShowsSymptom ($from_id, $to_id, FirstReportedDate, DurationDays, Intensity)
SELECT p.$node_id, s.$node_id, '2024-12-06', 8, 'Severe'
FROM dbo.Person p, dbo.Symptom s WHERE p.PersonID = 8 AND s.SymptomID = 8;

INSERT INTO dbo.ShowsSymptom ($from_id, $to_id, FirstReportedDate, DurationDays, Intensity)
SELECT p.$node_id, s.$node_id, '2024-12-07', 6, 'Moderate'
FROM dbo.Person p, dbo.Symptom s WHERE p.PersonID = 10 AND s.SymptomID = 1;

INSERT INTO dbo.ShowsSymptom ($from_id, $to_id, FirstReportedDate, DurationDays, Intensity)
SELECT p.$node_id, s.$node_id, '2024-12-08', 3, 'Mild'
FROM dbo.Person p, dbo.Symptom s WHERE p.PersonID = 12 AND s.SymptomID = 7;

INSERT INTO dbo.ShowsSymptom ($from_id, $to_id, FirstReportedDate, DurationDays, Intensity)
SELECT p.$node_id, s.$node_id, '2024-12-09', 5, 'Moderate'
FROM dbo.Person p, dbo.Symptom s WHERE p.PersonID = 13 AND s.SymptomID = 6;

INSERT INTO dbo.ShowsSymptom ($from_id, $to_id, FirstReportedDate, DurationDays, Intensity)
SELECT p.$node_id, s.$node_id, '2024-12-10', 4, 'Mild'
FROM dbo.Person p, dbo.Symptom s WHERE p.PersonID = 15 AND s.SymptomID = 9;

INSERT INTO dbo.ShowsSymptom ($from_id, $to_id, FirstReportedDate, DurationDays, Intensity)
SELECT p.$node_id, s.$node_id, '2024-12-12', 7, 'Moderate'
FROM dbo.Person p, dbo.Symptom s WHERE p.PersonID = 17 AND s.SymptomID = 11;

INSERT INTO dbo.PlaceContaminatedWith ($from_id, $to_id, DetectionDate, ContaminationLevel, SurfaceType)
SELECT pl.$node_id, v.$node_id, '2024-12-05', 'High', N'Столы'
FROM dbo.Place pl, dbo.Virus v WHERE pl.PlaceID = 1 AND v.VirusID = 1;

INSERT INTO dbo.PlaceContaminatedWith ($from_id, $to_id, DetectionDate, ContaminationLevel, SurfaceType)
SELECT pl.$node_id, v.$node_id, '2024-12-06', 'Critical', N'Медицинское оборудование'
FROM dbo.Place pl, dbo.Virus v WHERE pl.PlaceID = 2 AND v.VirusID = 1;

INSERT INTO dbo.PlaceContaminatedWith ($from_id, $to_id, DetectionDate, ContaminationLevel, SurfaceType)
SELECT pl.$node_id, v.$node_id, '2024-12-07', 'Medium', N'Поручни'
FROM dbo.Place pl, dbo.Virus v WHERE pl.PlaceID = 6 AND v.VirusID = 2;

INSERT INTO dbo.PlaceContaminatedWith ($from_id, $to_id, DetectionDate, ContaminationLevel, SurfaceType)
SELECT pl.$node_id, v.$node_id, '2024-12-08', 'High', N'Кресла'
FROM dbo.Place pl, dbo.Virus v WHERE pl.PlaceID = 8 AND v.VirusID = 3;

INSERT INTO dbo.PlaceContaminatedWith ($from_id, $to_id, DetectionDate, ContaminationLevel, SurfaceType)
SELECT pl.$node_id, v.$node_id, '2024-12-09', 'Low', N'Дверные ручки'
FROM dbo.Place pl, dbo.Virus v WHERE pl.PlaceID = 4 AND v.VirusID = 4;

INSERT INTO dbo.PlaceContaminatedWith ($from_id, $to_id, DetectionDate, ContaminationLevel, SurfaceType)
SELECT pl.$node_id, v.$node_id, '2024-12-10', 'High', N'Посуда'
FROM dbo.Place pl, dbo.Virus v WHERE pl.PlaceID = 9 AND v.VirusID = 5;

INSERT INTO dbo.PlaceContaminatedWith ($from_id, $to_id, DetectionDate, ContaminationLevel, SurfaceType)
SELECT pl.$node_id, v.$node_id, '2024-12-11', 'Medium', N'Игровое оборудование'
FROM dbo.Place pl, dbo.Virus v WHERE pl.PlaceID = 5 AND v.VirusID = 6;

INSERT INTO dbo.PlaceContaminatedWith ($from_id, $to_id, DetectionDate, ContaminationLevel, SurfaceType)
SELECT pl.$node_id, v.$node_id, '2024-12-12', 'High', N'Кнопки лифта'
FROM dbo.Place pl, dbo.Virus v WHERE pl.PlaceID = 12 AND v.VirusID = 7;

SELECT 
    p1.FullName AS Источник,
    p1.City AS Город_источника,
    p2.FullName AS Контакт,
    v.VirusName AS Вирус,
    v.Strain AS Штамм,
    pl.PlaceName AS Место_контакта,
    cw.ContactDate AS Дата_контакта
FROM dbo.Person p1, dbo.ContactedWith cw, dbo.Person p2,
     dbo.InfectedWith iw, dbo.Virus v,
     dbo.VisitedPlace vp, dbo.Place pl
WHERE MATCH(p1-(cw)->p2
      AND p2-(iw)->v
      AND p2-(vp)->pl)
  AND v.Strain = N'Омикрон'
  AND pl.PlaceType = 'Restaurant';

SELECT 
    p.FullName AS Пациент,
    s.SymptomName AS Симптом,
    v.VirusName AS Вирус,
    v.R0 AS Индекс_заразности,
    pl.PlaceName AS Посещённое_место,
    pl.PlaceType AS Тип_места
FROM dbo.Person p, dbo.ShowsSymptom ss, dbo.Symptom s,
     dbo.InfectedWith iw, dbo.Virus v,
     dbo.VisitedPlace vp, dbo.Place pl
WHERE MATCH(p-(ss)->s
      AND p-(iw)->v
      AND p-(vp)->pl)
  AND s.SymptomName = N'Кашель'
  AND v.R0 > 5;

SELECT 
    p1.FullName AS Источник_с_симптомом,
    s.SymptomName AS Симптом,
    pl.PlaceName AS Общее_место,
    pl.RiskLevel AS Уровень_риска,
    p2.FullName AS Возможный_контакт,
    cw.ContactDate AS Дата_контакта
FROM dbo.Person p1, dbo.ShowsSymptom ss, dbo.Symptom s,
     dbo.VisitedPlace vp1, dbo.Place pl,
     dbo.VisitedPlace vp2, dbo.Person p2,
     dbo.ContactedWith cw
WHERE MATCH(p1-(ss)->s
      AND p1-(vp1)->pl<-(vp2)-p2
      AND p1-(cw)->p2)
  AND pl.RiskLevel = 'High';

SELECT 
    p_dead.FullName AS Летальный_случай,
    p_contact.FullName AS Контактное_лицо,
    cw.ContactDate AS Дата_контакта,
    cw.ContactDuration AS Длительность_мин,
    v.VirusName AS Вирус,
    iw.DiagnosisDate AS Дата_диагноза
FROM dbo.Person p_dead, dbo.InfectedWith iw, dbo.Virus v,
     dbo.ContactedWith cw, dbo.Person p_contact
WHERE MATCH(p_dead-(iw)->v
      AND p_dead-(cw)->p_contact)
  AND iw.Outcome = 'Deceased';

SELECT 
    p_source.FullName AS Заразивший,
    v.VirusName AS Вирус,
    v.Strain AS Штамм,
    pl.PlaceName AS Место_передачи,
    pl.PlaceType AS Тип_места,
    p_target.FullName AS Заразившийся,
    s.SymptomName AS Проявленный_симптом,
    iw_target.DiagnosisDate AS Дата_диагноза_цели
FROM dbo.Person p_source, dbo.InfectedWith iw_source, dbo.Virus v,
     dbo.VisitedPlace vp_source, dbo.Place pl,
     dbo.VisitedPlace vp_target, dbo.Person p_target,
     dbo.InfectedWith iw_target, dbo.ShowsSymptom ss, dbo.Symptom s
WHERE MATCH(p_source-(iw_source)->v
      AND p_source-(vp_source)->pl<-(vp_target)-p_target
      AND p_target-(iw_target)->v
      AND p_target-(ss)->s)
  AND p_source.PersonID != p_target.PersonID
  AND s.Severity IN ('Severe', 'Critical');

SELECT 
    p_start.FullName AS Начальный_узел,
    (SELECT FullName FROM dbo.Person WHERE $node_id = LAST_VALUE(p_mid.$node_id) WITHIN GROUP (GRAPH PATH)) AS Конечный_узел,
    STRING_AGG(p_mid.FullName, ' -> ') WITHIN GROUP (GRAPH PATH) AS Путь_заражения,
    COUNT(p_mid.PersonID) WITHIN GROUP (GRAPH PATH) AS Длина_пути
FROM 
    dbo.Person AS p_start,
    dbo.ContactedWith FOR PATH AS cw,
    dbo.Person FOR PATH AS p_mid
WHERE MATCH(
    SHORTEST_PATH(p_start(-(cw)->p_mid)+)
)
AND p_start.PersonID = 1;

SELECT 
    p_start.FullName AS Источник,
    STRING_AGG(p_mid.FullName, ' -> ') WITHIN GROUP (GRAPH PATH) AS Промежуточные_узлы,
    COUNT(p_mid.PersonID) WITHIN GROUP (GRAPH PATH) AS Длина_пути
FROM 
    dbo.Person AS p_start,
    dbo.ContactedWith FOR PATH AS cw,
    dbo.Person FOR PATH AS p_mid
WHERE MATCH(
    SHORTEST_PATH(p_start(-(cw)->p_mid){1,5})
)
AND p_start.PersonID = 8;