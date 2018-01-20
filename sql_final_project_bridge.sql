-- Ohannes (Hovig) Ohannessian
-- Project: Building a Relational Database Management System

-- create schema organizations;
use organizations;

-- drop schema if exists organizations;
drop table if exists groups;
drop table if exists users;
drop table if exists rooms;
drop table if exists group_rooms_access;

create table groups (
	groupid int auto_increment primary key,
    groupname varchar(25)
);

create table users (
	userid int auto_increment primary key,
    username varchar(25),
    groupid int references groups.groupid
);

create table rooms (
	roomid int auto_increment primary key,
    roomname varchar(25)
);

create table group_rooms_access (
	groupid int references groups.groupid,
    roomid int references rooms.roomid
);

insert into groups (groupname) values 
("I.T."),
("Sales"),
("Administration"),
("Operations");

insert into users (username, groupid) values
("Modesto","1"),
("Ayine","1"),
("Christopher","2"),
("Cheong woo","2"),
("Saulat","3"),
("Heidy", null);

insert into rooms (roomname) values
("101"),
("102"),
("Auditorium A"),
("Auditorium B");

insert into group_rooms_access (groupid,roomid) values
(1,1),
(1,2),
(2,2),
(2,3);

select groups.groupname, users.username from groups left join users on groups.groupid = users.groupid;

select rooms.roomname, groups.groupname from rooms 
left join group_rooms_access on group_rooms_access.roomid = rooms.roomid 
left join groups on groups.groupid = group_rooms_access.groupid;

select users.username, groups.groupname, rooms.roomname from users 
left join groups on groups.groupid = users.groupid
left join group_rooms_access on group_rooms_access.groupid = groups.groupid
left join rooms on rooms.roomid = group_rooms_access.roomid
order by users.username, groups.groupname, rooms.roomname;
