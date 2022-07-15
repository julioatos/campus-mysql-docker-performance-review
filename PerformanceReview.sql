CREATE TABLE IF NOT EXISTS `User` (
     Id INT NOT NULL AUTO_INCREMENT,
     Name CHAR(30) NOT NULL,
     FechaNacimiento DATE NOT NULL,
     Edad INT,
     CreateDate DATETIME,
     PRIMARY KEY (Id)
);
------------------------------------------------------------------------------------


CREATE TABLE IF NOT EXISTS `Role`
(
  	Id INT NOT NULL AUTO_INCREMENT,
    ProfileName CHAR(50),
    PRIMARY KEY(Id)
);
------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `UserRole`
(
	Id INT NOT NULL AUTO_INCREMENT,
    IdUser INT NOT NULL,
    IdRole INT NOT NULL,
    PRIMARY KEY(Id),
    CONSTRAINT FK_User
    FOREIGN KEY (IdUser) 
    REFERENCES User(Id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT FK_Role
    FOREIGN KEY (IdRole) 
    REFERENCES Role(Id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

------------------------------------------------------------------------------------

DELIMITER $$

CREATE TRIGGER After_Users_Insert
AFTER INSERT
ON User FOR EACH ROW
BEGIN
    IF NEW.Edad IS NULL THEN
        declare edad int;
        declare anioNacimiento int;
        declare anioActual int;
        select @anioNacimiento = SELECT YEAR(NEW.FechaNacimiento) from User;
        select @anioActual = SELECT YEAR(CURRENT_DATE());
        
        set @edad = @anioActual - @anioNacimiento;
        
        UPDATE `User` SET edad WHERE Id = NEW.Id;
        
    END IF;
END$$

------------------------------------------------------------------------------------

DELIMITER ;

DELIMITER //

CREATE TRIGGER User_After_Insert
BEFORE INSERT
   ON `User` FOR EACH ROW

BEGIN
   DECLARE edad int;
   DECLARE anioNacimiento int;
   DECLARE anioActual int;
   -- Find username of person performing the INSERT into table
   SELECT YEAR(NEW.FechaNacimiento) INTO anioNacimiento;
   SELECT YEAR(CURRENT_DATE()) INTO anioActual;
   -- Insert record into audit table
   SET edad = anioActual - anioNacimiento;
   SET NEW.Edad = edad;
END; //
DELIMITER ;
------------------------------------------------------------------------------------


INSERT INTO `User`(
    NAME,
    FechaNacimiento,
    CreateDate
)
VALUES(
    'Daniel Sebastiao',
    '1984-10-25',
    CURRENT_DATE())
	
INSERT INTO `User`(
    NAME,
    FechaNacimiento,
    CreateDate
)
VALUES
	('Edwin Julian', '1992-08-05', CURRENT_DATE()),
    ('Mariano Pacienza', '1972-09-02', CURRENT_DATE()),
    ('Saulo Villasenor', '1985-08-05', CURRENT_DATE()),
    ('Hector Cisnero', '1985-09-15', CURRENT_DATE()),
    ('Horeb Gastelum', '1992-10-15', CURRENT_DATE())
------------------------------------------------------------------------------------

	
INSERT INTO `Role`(ProfileName)
VALUES('Admin'),('RH'),('Student'),('Squad')
------------------------------------------------------------------------------------

INSERT INTO `UserRole`(IdUser, IdRole)
VALUES(1, 1),(2, 1),(3, 2),(5, 4),(6, 3)
------------------------------------------------------------------------------------

SELECT * FROM `User`;
SELECT * FROM `Role`;

SELECT u.Name, u.FechaNacimiento FROM `UserRole` ur INNER JOIN `User` u on ur.IdUser = u.Id group by u.Id;
SELECT u.Name, u.FechaNacimiento FROM `User` u WHERE Id NOT IN (SELECT IdUser FROM `UserRole`);

SELECT SUM(Edad) FROM `User`;
SELECT COUNT(*) FROM `User`;
SELECT COUNT(*) FROM `Role`;
SELECT COUNT(*) FROM `UserRole`;

------------------------------------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE `sp_AddNewUser`(IN `name` CHAR(30), IN `fechaNacimiento` DATE)
BEGIN
    insert into `User` (Name, FechaNacimiento, CreateDate) values (name, fechaNacimiento, CURRENT_DATE());
END$$
DELIMITER ;
------------------------------------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE `sp_AddNewRole`(IN `profileName` CHAR(30))
BEGIN
    insert into `Role` (ProfileName) values (profileName);
END$$
DELIMITER ;
------------------------------------------------------------------------------------

DELIMITER $$
CREATE PROCEDURE `sp_AddNewUserRole`(IN `idUser` INT, IN `idRole` INT)
BEGIN
    insert into `UserRole` (IdUser, IdRole) values (idUser, idRole);
END$$
DELIMITER ;
---------------------------------  VISTA  ---------------------------------------------------

CREATE VIEW UserView AS
SELECT u.Id, u.Name, count(ur.IdUser) as Roles, timestampdiff(YEAR, u.FechaNacimiento, curdate()) as Age
FROM User u LEFT JOIN UserRole ur ON u.Id = ur.IdUser group by u.Id;

------------------------------------------------------------------------------------