--Работники библиотеки
CREATE TABLE Сотрудник (
    ИдСотрудника INT PRIMARY KEY,
    ФИО VARCHAR(100) NOT NULL,
    Логин VARCHAR(20) NOT NULL UNIQUE,
    Пароль VARCHAR(20) NOT NULL,
    Должность VARCHAR(20) NOT NULL,
    Телефон VARCHAR(20) NOT NULL UNIQUE,
    ДатаПриёма DATE NOT NULL,
    ДатаУвольнения DATE NULL,
    CONSTRAINT chk_Должность CHECK (Должность IN ('Библиотекарь', 'Директор')),
    CONSTRAINT chk_Даты CHECK (ДатаУвольнения IS NULL OR ДатаУвольнения >= ДатаПриёма)
);

--Картотека читателей
CREATE TABLE Читатель (
    НомБилета INT PRIMARY KEY,
    ИдСотрудника INT NOT NULL,
    ФИО VARCHAR(100) NOT NULL,
    ДатаРождения DATE NOT NULL,
    Телефон VARCHAR(20) NOT NULL UNIQUE,
    ДатаРегистрации DATE NOT NULL,
    CONSTRAINT fk_Читатель_Сотрудник FOREIGN KEY (ИдСотрудника)
        REFERENCES Сотрудник(ИдСотрудника),
    CONSTRAINT chk_Возраст CHECK (DATEADD(YEAR, 6, ДатаРождения) <= GETDATE())
);

--Закупки и поступления книг
CREATE TABLE Поступление (
    ИдПоступления INT PRIMARY KEY,
    ИдСотрудника INT NOT NULL,
    ДатаПоступление DATE NOT NULL,
    Поставщик VARCHAR(50) NOT NULL,
    CONSTRAINT fk_Поступление_Сотрудник FOREIGN KEY (ИдСотрудника)
        REFERENCES Сотрудник(ИдСотрудника),
    CONSTRAINT chk_ДатаПоступления CHECK (ДатаПоступление <= GETDATE())
);

--Книги в фонде библиотеки
CREATE TABLE Издание (
    ШифрКниги INT PRIMARY KEY,
    ИдПоступления INT NOT NULL,
    Название VARCHAR(100) NOT NULL,
    Автор VARCHAR(100) NOT NULL,
    ГодИздания INT NOT NULL,
    Категория VARCHAR(50) NOT NULL,
    ВозрастОгр VARCHAR(3) NOT NULL,
    МестоХранения VARCHAR(50) NOT NULL,
    Статус VARCHAR(10) NOT NULL,
    CONSTRAINT fk_Издание_Поступление FOREIGN KEY (ИдПоступления)
        REFERENCES Поступление(ИдПоступления),
    CONSTRAINT chk_Год CHECK (ГодИздания <= YEAR(GETDATE())),
    CONSTRAINT chk_ВозрастОгр CHECK (ВозрастОгр IN ('0+', '6+', '12+', '16+', '18+')),
    CONSTRAINT chk_Статус CHECK (Статус IN ('В фонде', 'Выдано', 'Списано'))
);

--Операции выдачи изданий читателям
CREATE TABLE Выдача (
    ИдВыдачи INT PRIMARY KEY,
    НомБилета INT NOT NULL,
    ШифрКниги INT NOT NULL,
    ИдСотрудника INT NOT NULL,
    ДатаВыдачи DATE NOT NULL,
    ПлановыйВозврат DATE NOT NULL,
    ФактВозврат VARCHAR(3) NOT NULL,
    CONSTRAINT fk_Выдача_Читатель FOREIGN KEY (НомБилета)
        REFERENCES Читатель(НомБилета),
    CONSTRAINT fk_Выдача_Издание FOREIGN KEY (ШифрКниги)
        REFERENCES Издание(ШифрКниги),
    CONSTRAINT fk_Выдача_Сотрудник FOREIGN KEY (ИдСотрудника)
        REFERENCES Сотрудник(ИдСотрудника),
    CONSTRAINT chk_СрокВозврата CHECK (ПлановыйВозврат > ДатаВыдачи),
    CONSTRAINT chk_ФактВозврат CHECK (ФактВозврат IN ('Да', 'Нет'))
);

--Акты списания изданий
CREATE TABLE Списание (
    ИдСписания INT PRIMARY KEY,
    ИдСотрудника INT NOT NULL,
    ДатаСписания DATE NOT NULL,
    ПричинаСписания VARCHAR(20) NOT NULL,
    CONSTRAINT fk_Списание_Сотрудник FOREIGN KEY (ИдСотрудника)
        REFERENCES Сотрудник(ИдСотрудника),
    CONSTRAINT chk_Причина CHECK (ПричинаСписания IN ('Утеряно', 'Испорчено', 'Изношено'))
);

--Списание_Издания
CREATE TABLE Списание_Издания (
    ИдСписания INT NOT NULL,
    ШифрКниги INT NOT NULL,
    PRIMARY KEY (ИдСписания, ШифрКниги),
    CONSTRAINT fk_СпИзд_Списание FOREIGN KEY (ИдСписания)
        REFERENCES Списание(ИдСписания),
    CONSTRAINT fk_СпИзд_Издание FOREIGN KEY (ШифрКниги)
        REFERENCES Издание(ШифрКниги)
);