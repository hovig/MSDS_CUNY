-- Ohannes (Hovig) Ohannessian
-- Assignment 2 - DATA 607
-- Feb 02, 2018

-- on the 1st run of this script, un-comment 
-- the following line to create the database 
#create database movies;
use movies;

drop table if exists movies;
drop table if exists ratings;

create table movies (
    movie_id int auto_increment primary key,
    movie_title varchar(50) not null
);

create table ratings (
    rating_id int auto_increment primary key,
    movie_id int not null references movies,
    rating_value float not null,
    rating_owner varchar(25) not null
);

insert into movies (movie_title) values 
    ("Wormwood"),
    ("Lady Macbeth"),
    ("Dunkirk"),
    ("Marjorie Prime"),
    ("Columbus"),
    ("Her")
;

insert into ratings (movie_id, rating_value, rating_owner) values
    (1, 3.5, "John"),
    (2, 2.0, "Caroline"),
    (3, 5.0, "Hovig"),
    (4, 3.0, "Ghazo"),
    (5, 4.5, "Hagop"),
    (6, 3.0, "Ani"),
    (6, 4.5, "Garo"),
    (5, 3.5, "Kevo"),
    (4, 3.0, "Margo"),
    (3, 4.5, "Natalie"),
    (2, 1.0, "Daron"),
    (1, 5.0, "Raffi")
;
