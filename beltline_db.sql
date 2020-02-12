CREATE DATABASE IF NOT EXISTS phase2;
USE phase2;

DROP TABLE IF EXISTS transit;
CREATE TABLE transit (
    transit_name VARCHAR(128),
    transit_type VARCHAR(10),
    price DECIMAL(6,2) NOT NULL,
    PRIMARY KEY (transit_name, transit_type)
);

DROP TABLE IF EXISTS user;
CREATE TABLE user (
    username VARCHAR(128),
    password VARCHAR(128) NOT NULL,
    fname VARCHAR(128) NOT NULL,
    lname VARCHAR(128) NOT NULL,
    status VARCHAR(10) NOT NULL,
    PRIMARY KEY (username)
);

DROP TABLE IF EXISTS visitor;
CREATE TABLE visitor (
    username VARCHAR(128),
    PRIMARY KEY (username),
    CONSTRAINT fk_visitor_user FOREIGN KEY (username) REFERENCES user (username) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS employee;
CREATE TABLE employee (
    username VARCHAR(128) ,
    phone DECIMAL(10,0) NOT NULL,
    emp_id INT NOT NULL,
    emp_address VARCHAR(128) NOT NULL,
    city VARCHAR(128) NOT NULL,
    state CHAR(2) NOT NULL,
    emp_zip INT NOT NULL,
    PRIMARY KEY (username),
    UNIQUE KEY (phone),
    UNIQUE KEY (emp_id),
    CONSTRAINT fk_employee_user FOREIGN KEY (username) REFERENCES user (username) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS administrator;
CREATE TABLE administrator (
    username VARCHAR(128),
    PRIMARY KEY (username),
    CONSTRAINT fk_administrator_employee FOREIGN KEY (username) REFERENCES employee (username) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS manager;
CREATE TABLE manager (
    username VARCHAR(128),
    PRIMARY KEY (username),
    CONSTRAINT fk_manager_employee FOREIGN KEY (username) REFERENCES employee (username) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS staff;
CREATE TABLE staff (
    username VARCHAR(128) ,
    PRIMARY KEY (username),
    CONSTRAINT fk_staff_employee FOREIGN KEY (username) REFERENCES employee (username) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS site;
CREATE TABLE site (
    site_name VARCHAR(128) NOT NULL,
    zip INT NOT NULL,
    address VARCHAR(128),
    open_everyday BOOLEAN NOT NULL,
    manager VARCHAR(128) NOT NULL,
    PRIMARY KEY (site_name),
    CONSTRAINT fk_site_manager FOREIGN KEY (manager) REFERENCES manager (username) ON UPDATE CASCADE
);

DROP TABLE IF EXISTS event;
CREATE TABLE event (
    event_name VARCHAR(128) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    price DECIMAL(6,2) NOT NULL,
    capacity INT NOT NULL,
    min_staff INT NOT NULL,
    descript VARCHAR(128) NOT NULL,
    site_name VARCHAR(128) NOT NULL,
    PRIMARY KEY (event_name, start_date, site_name),
    CONSTRAINT fk_event_site FOREIGN KEY (site_name) REFERENCES site (site_name) ON UPDATE CASCADE
);

DROP TABLE IF EXISTS email;
CREATE TABLE email (
    username VARCHAR(128) NOT NULL,
    email VARCHAR(128),
    PRIMARY KEY (email),
    CONSTRAINT fk_email_user FOREIGN KEY (username) REFERENCES user (username) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS take;
CREATE TABLE take (
    date_taken DATE NOT NULL,
    transit_type VARCHAR(10) NOT NULL,
    transit_name VARCHAR(128) NOT NULL,
    username VARCHAR(128) NOT NULL,
    PRIMARY KEY (date_taken, transit_type, transit_name, username),
    CONSTRAINT fk_take_transit FOREIGN KEY (transit_name, transit_type) REFERENCES transit (transit_name, transit_type) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_take_user FOREIGN KEY (username) references user (username) ON UPDATE CASCADE
);

DROP TABLE IF EXISTS visit_site;
CREATE TABLE visit_site (
    visit_date DATE NOT NULL,
    site_name VARCHAR(128) NOT NULL,
    visitor_username VARCHAR(128) NOT NULL,
    PRIMARY KEY (visit_date, site_name, visitor_username),
    CONSTRAINT fk_svisit_site FOREIGN KEY (site_name) REFERENCES site (site_name) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT  fk_svisit_visitor FOREIGN KEY (visitor_username) REFERENCES visitor (username) ON UPDATE CASCADE
);

DROP TABLE IF EXISTS connect;
CREATE TABLE connect (
    transit_name VARCHAR(64) NOT NULL,
    transit_type VARCHAR(10) NOT NULL,
    site_name VARCHAR(128) NOT NULL,
    PRIMARY KEY (transit_name, transit_type, site_name),
    CONSTRAINT fk_connect_transit FOREIGN KEY (transit_name, transit_type) REFERENCES transit (transit_name, transit_type) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_connect_site FOREIGN KEY (site_name) REFERENCES site (site_name) ON UPDATE CASCADE
);

DROP TABLE IF EXISTS visit_event;
CREATE TABLE visit_event (
    visit_date DATE NOT NULL,
    visitor_username VARCHAR(128) NOT NULL,
    event_name VARCHAR(128) NOT NULL,
    event_start_date DATE NOT NULL,
    event_site_name VARCHAR(128) NOT NULL,
    PRIMARY KEY (visit_date, visitor_username, event_name, event_start_date, event_site_name),
    CONSTRAINT fk_evisit_visitor FOREIGN KEY (visitor_username) REFERENCES visitor (username) ON UPDATE CASCADE,
    CONSTRAINT fk_evisit_event FOREIGN KEY (event_name, event_start_date, event_site_name) REFERENCES event (event_name, start_date, site_name) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS assign_to;
CREATE TABLE assign_to (
    staff_username VARCHAR(128) NOT NULL,
    event_name VARCHAR(128) NOT NULL,
    event_start_date DATE NOT NULL,
    event_site_name VARCHAR(128) NOT NULL,
    PRIMARY KEY (staff_username, event_name, event_start_date, event_site_name),
    CONSTRAINT fk_assign_staff FOREIGN KEY (staff_username) REFERENCES staff (username) ON UPDATE CASCADE,
    CONSTRAINT fk_assign_event FOREIGN KEY (event_name, event_start_date, event_site_name) REFERENCES event (event_name, start_date, site_name) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE DEFINER=`root`@`localhost` PROCEDURE `addVisitor`(in my_username varchar(20), in my_password varchar(20), in my_fname varchar(20), in my_lname varchar(20), in my_status varchar(10))
BEGIN
    call addUser(my_username, my_password, my_fname, my_lname, my_status);
    insert into visitor(username)
    values (my_username);
END

CREATE DEFINER=`root`@`localhost` PROCEDURE `addUser`(in my_username varchar(20), in my_password varchar(20), in my_fname varchar(20), in my_lname varchar(20), in my_status varchar(10))
BEGIN
    insert into user (username, password, fname, lname, status)
    values (my_username, my_password, my_fname, my_lname, my_status);
END

CREATE DEFINER=`root`@`localhost` PROCEDURE `addStaffVisitor`(in my_username varchar(20), in my_password varchar(20), in my_fname varchar(20), in my_lname varchar(20), in my_status varchar(10), in my_phone decimal(10, 0), in my_id int(11), in my_address varchar(128),in my_city varchar(128), in my_state char(2), in my_zip int(11))
BEGIN
    call addStaff(my_username, my_password, my_fname, my_lname, my_status, my_phone, my_id, my_address, my_city, my_state, my_zip);
    insert into visitor(username)
    values (my_username);
END

CREATE DEFINER=`root`@`localhost` PROCEDURE `addStaff`(in my_username varchar(20), in my_password varchar(20), in my_fname varchar(20), in my_lname varchar(20), in my_status varchar(10), in my_phone decimal(10, 0), in my_id int(11), in my_address varchar(128),in my_city varchar(128), in my_state char(2), in my_zip int(11))
BEGIN
    call addEmployee(my_username, my_password, my_fname, my_lname, my_status, my_phone, my_id, my_address, my_city, my_state, my_zip);
    insert into staff (username)
    values (my_username);
END

CREATE DEFINER=`root`@`localhost` PROCEDURE `addManagerVisitor`(in my_username varchar(20), in my_password varchar(20), in my_fname varchar(20), in my_lname varchar(20), in my_status varchar(10), in my_phone decimal(10, 0), in my_id int(11), in my_address varchar(128),in my_city varchar(128), in my_state char(2), in my_zip int(11))
BEGIN
    call addManager(my_username, my_password, my_fname, my_lname, my_status, my_phone, my_id, my_address, my_city, my_state, my_zip);
    insert into visitor(username)
    values (my_username);
END

CREATE DEFINER=`root`@`localhost` PROCEDURE `addManager`(in my_username varchar(20), in my_password varchar(20), in my_fname varchar(20), in my_lname varchar(20), in my_status varchar(10), in my_phone decimal(10, 0), in my_id int(11), in my_address varchar(128),in my_city varchar(128), in my_state char(2), in my_zip int(11))
BEGIN
    call addEmployee(my_username, my_password, my_fname, my_lname, my_status, my_phone, my_id, my_address, my_city, my_state, my_zip);
    insert into manager (username)
    values (my_username);
END

CREATE DEFINER=`root`@`localhost` PROCEDURE `addEmployee`(in my_username varchar(20), in my_password varchar(20), in my_fname varchar(20), in my_lname varchar(20), in my_status varchar(10), in my_phone decimal(10, 0), in my_id int(11), in my_address varchar(128),in my_city varchar(128), in my_state char(2), in my_zip int(11))
BEGIN
    call addUser(my_username, my_password, my_fname, my_lname, my_status);
    insert into
    employee (username, phone, emp_id, emp_address, city, state, emp_zip)
    values (my_username, my_phone, my_id, my_address, my_city, my_state, my_zip);
END

CREATE DEFINER=`root`@`localhost` PROCEDURE `addAdminVisitor`(in my_username varchar(20), in my_password varchar(20), in my_fname varchar(20), in my_lname varchar(20), in my_status varchar(10), in my_phone decimal(10, 0), in my_id int(11), in my_address varchar(128),in my_city varchar(128), in my_state char(2), in my_zip int(11))
BEGIN
    call addAdmin(my_username, my_password, my_fname, my_lname, my_status, my_phone, my_id, my_address, my_city, my_state, my_zip);
    insert into visitor(username)
    values (my_username);
END

CREATE DEFINER=`root`@`localhost` PROCEDURE `addAdmin`(in my_username varchar(20), in my_password varchar(20), in my_fname varchar(20), in my_lname varchar(20), in my_status varchar(10), in my_phone decimal(10, 0), in my_id int(11), in my_address varchar(128),in my_city varchar(128), in my_state char(2), in my_zip int(11))
BEGIN
    call addEmployee(my_username, my_password, my_fname, my_lname, my_status, my_phone, my_id, my_address, my_city, my_state, my_zip);
    insert into administrator (username)
    values (my_username);
END
