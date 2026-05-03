-- Clean init script for SJSUMarketplace
-- Run with: mysql -u root -p < initdb.sql

CREATE DATABASE IF NOT EXISTS `team_9`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE `team_9`;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `Favorites`;
DROP TABLE IF EXISTS `Friends`;
DROP TABLE IF EXISTS `Reports`;
DROP TABLE IF EXISTS `Transactions`;
DROP TABLE IF EXISTS `Messages`;
DROP TABLE IF EXISTS `Posts`;
DROP TABLE IF EXISTS `Administrators`;
DROP TABLE IF EXISTS `MeetupLocation`;
DROP TABLE IF EXISTS `Categories`;
DROP TABLE IF EXISTS `Users`;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE `Users` (
  `email` varchar(255) NOT NULL,
  `username` varchar(45) NOT NULL,
  `password` varchar(100) NOT NULL,
  PRIMARY KEY (`email`),
  UNIQUE KEY `username_UNIQUE` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Administrators` (
  `email` varchar(255) NOT NULL,
  `admin_id` int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`email`),
  UNIQUE KEY `admin_id_UNIQUE` (`admin_id`),
  CONSTRAINT `fk_admin_user_email`
    FOREIGN KEY (`email`) REFERENCES `Users` (`email`)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `MeetupLocation` (
  `meetupID` int NOT NULL AUTO_INCREMENT,
  `meetup_location` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`meetupID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Posts` (
  `post_ID` int NOT NULL AUTO_INCREMENT,
  `title` varchar(45) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `description` longtext,
  `picture` longtext,
  `location_details_specific` varchar(255) DEFAULT NULL,
  `item_status` varchar(45) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `meetup_id` int DEFAULT NULL,
  PRIMARY KEY (`post_ID`),
  KEY `meetup_id_idx` (`meetup_id`),
  KEY `category_id_idx` (`category_id`),
  KEY `user_id_idx` (`email`),
  CONSTRAINT `fk_posts_category`
    FOREIGN KEY (`category_id`) REFERENCES `Categories` (`category_id`),
  CONSTRAINT `fk_posts_meetup`
    FOREIGN KEY (`meetup_id`) REFERENCES `MeetupLocation` (`meetupID`),
  CONSTRAINT `fk_posts_user_email`
    FOREIGN KEY (`email`) REFERENCES `Users` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Messages` (
  `message_id`     int NOT NULL AUTO_INCREMENT,
  `sender_email`   varchar(255) NOT NULL,
  `receiver_email` varchar(255) NOT NULL,
  `body`           longtext NOT NULL,
  `date_sent`      datetime DEFAULT CURRENT_TIMESTAMP,
  `is_read`        tinyint(1) NOT NULL DEFAULT 0,
  `is_reported`    tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`message_id`),
  KEY `sender_idx`   (`sender_email`),
  KEY `receiver_idx` (`receiver_email`),
  CONSTRAINT `fk_msg_sender`
    FOREIGN KEY (`sender_email`)   REFERENCES `Users` (`email`) ON DELETE CASCADE,
  CONSTRAINT `fk_msg_receiver`
    FOREIGN KEY (`receiver_email`) REFERENCES `Users` (`email`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Transactions` (
  `transaction_id`   int NOT NULL AUTO_INCREMENT,
  `transaction_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `sale_price`       decimal(10,2) NOT NULL,
  `buyer_email`      varchar(255) NOT NULL,
  `seller_email`     varchar(255) NOT NULL,
  `post_ID`          int NOT NULL,
  PRIMARY KEY (`transaction_id`),
  KEY `buyer_idx`  (`buyer_email`),
  KEY `seller_idx` (`seller_email`),
  KEY `post_idx`   (`post_ID`),
  CONSTRAINT `fk_tx_buyer`
    FOREIGN KEY (`buyer_email`)  REFERENCES `Users` (`email`),
  CONSTRAINT `fk_tx_seller`
    FOREIGN KEY (`seller_email`) REFERENCES `Users` (`email`),
  CONSTRAINT `fk_tx_post`
    FOREIGN KEY (`post_ID`)      REFERENCES `Posts` (`post_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Favorites` (
  `email` varchar(255) NOT NULL,
  `post_ID` int NOT NULL,
  `saved_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`email`, `post_ID`),
  CONSTRAINT `fk_favorites_user_email`
    FOREIGN KEY (`email`) REFERENCES `Users` (`email`),
  CONSTRAINT `fk_favorites_post_id`
    FOREIGN KEY (`post_ID`) REFERENCES `Posts` (`post_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Friends` (
  `user_email1` varchar(255) NOT NULL,
  `user_email2` varchar(255) NOT NULL,
  PRIMARY KEY (`user_email1`, `user_email2`),
  KEY `friend_key_idx` (`user_email2`),
  CONSTRAINT `fk_friends_user_email1`
    FOREIGN KEY (`user_email1`) REFERENCES `Users` (`email`),
  CONSTRAINT `fk_friends_user_email2`
    FOREIGN KEY (`user_email2`) REFERENCES `Users` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Reports` (
  `report_id` int NOT NULL AUTO_INCREMENT,
  `category` varchar(45) DEFAULT NULL,
  `description` longtext,
  `status` varchar(45) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `user_email` varchar(255) DEFAULT NULL,
  `admin_email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`report_id`),
  KEY `user_email_foreign_idx` (`user_email`),
  KEY `admin_email_foreign_idx` (`admin_email`),
  CONSTRAINT `fk_reports_user_email`
    FOREIGN KEY (`user_email`) REFERENCES `Users` (`email`),
  CONSTRAINT `fk_reports_admin_email`
    FOREIGN KEY (`admin_email`) REFERENCES `Administrators` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `Users` (`email`, `username`, `password`) VALUES
  ('testing@sjsu.edu', 'testing', '73ceb15f18bb0a313c8880abe54bf61a529dd8f1e75b084dd39926a1518d3d2f');

INSERT INTO `Administrators` (`email`) VALUES
  ('testing@sjsu.edu');

INSERT INTO `MeetupLocation` (`meetup_location`) VALUES
  ('MacQuarrie Hall'),
  ('Student Union'),
  ('SRAC (Spartan Recreation)'),
  ('Engineering Building'),
  ('Dr. Martin Luther King Jr. Library'),
  ('Tower Hall'),
  ('Duncan Hall'),
  ('Yoshihiro Uchida Hall'),
  ('Campus Village Bookstore'),
  ('7th Street Plaza');
