CREATE USER docker_mysql_user IDENTIFIED BY 'docker_mysql_user_password';

GRANT ALL PRIVILEGES ON *.* TO 'docker_mysql_user'@'%';
FLUSH PRIVILEGES;

DROP DATABASE IF EXISTS docker_mysql;
CREATE DATABASE docker_mysql
  CHARACTER SET = 'utf8mb4'
  COLLATE = 'utf8mb4_unicode_ci';