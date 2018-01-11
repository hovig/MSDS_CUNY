-- ################################################
-- # Ohannes (Hovig) Ohannessian
-- # 01/08/2018
-- # Assignment SQL Week 2: SQL One to Many Relationships
-- ################################################

-- # In this assignment, we’ll practice working with one-to-many relationships in SQL. Suppose you are tasked with keeping
-- # track of a database that contain the best “how-to” videos on MySQL.
-- # You may want to first create a new database (schema) for this assignment.

CREATE DATABASE videos;
USE videos;

DROP TABLE IF EXISTS videos;
DROP TABLE IF EXISTS reviewers;


-- # 1. Videos table. Create one table to keep track of the videos. This table should include a unique ID, the title of the
-- #		video, the length in minutes, and the URL. Populate the table with at least three related videos from YouTube or
-- #		other publicly available resources.

CREATE TABLE videos (
	ID int AUTO_INCREMENT PRIMARY KEY,
    title varchar(100) NOT NULL,
    length float NOT NULL,
    url varchar(255) NOT NULL
);

INSERT INTO videos (title,length,url) VALUES 
("Upload and analyze an image using Functions, Node-RED, Node.js & IoT Platform", 0.19, "https://www.youtube.com/watch?v=WKnrbA-N13A"),
("Upload and analyze an image using Functions, Node-RED, Node.js & IoT Platform", 0.24, "https://www.youtube.com/watch?v=57CWYSV5K3E"),
("Create, connect and simulate devices with Watson Data Platform and Node-Red", 14.23, "https://www.youtube.com/watch?v=TufD9akAaXY&t=24s");


-- # 2. Create and populate Reviewers table. Create a second table that provides at least two user reviews for each of
-- #		at least two of the videos. These should be imaginary reviews that include columns for the user’s name
-- #		(“Asher”, “Cyd”, etc.), the rating (which could be NULL, or a number between 0 and 5), and a short text review
-- #		(“Loved it!”). There should be a column that links back to the ID column in the table of videos.

CREATE TABLE reviewers (
	reviewer_id int AUTO_INCREMENT PRIMARY KEY,
    video_id int NOT NULL REFERENCES videos,
	reviewer varchar(100) NOT NULL,
    rating integer,
    review varchar(255)
);

INSERT INTO reviewers (video_id, reviewer, rating, review) VALUES
(3,"Raffi Y.",4,"Great job!"),
(1,"Daron",5,"Loved it!"),
(2,"Ani Z.",4,"Great work!");


-- # 3. Report on Video Reviews. Write a JOIN statement that shows information from both tables.

SELECT ID, title, reviewer, rating, review FROM videos INNER JOIN reviewers WHERE video_id = ID ORDER BY rating DESC;

