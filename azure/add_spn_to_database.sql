create user your_user with password = 'yourStrongPa22word!';
alter role db_datareader add your_user;
alter role db_datawriter add your_user;

create user your_app_regitration from external provider;
alter role db_datareader add member your_app_regitration;
alter role db_datawriter add member your_app_regitration;
