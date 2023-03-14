CREATE USER 'vmodev'@'%' IDENTIFIED BY 'vmodev';

GRANT CREATE, CREATE USER, SELECT, RELOAD  ON *.* TO 'vmodev'@'%';

GRANT EXECUTE, SELECT, SHOW VIEW, ALTER, ALTER ROUTINE, CREATE, CREATE ROUTINE, CREATE TEMPORARY TABLES, CREATE VIEW, DELETE, DROP, EVENT, INDEX, INSERT, REFERENCES, TRIGGER, UPDATE, LOCK TABLES  ON user_registration.* TO 'vmodev'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;