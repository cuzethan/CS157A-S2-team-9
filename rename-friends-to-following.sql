-- Rename the Friends table to Following on an existing database.
-- Run with: mysql -u root -p team_9 < rename-friends-to-following.sql

USE `team_9`;

RENAME TABLE `Friends` TO `Following`;

ALTER TABLE `Following`
  DROP FOREIGN KEY `fk_friends_user_email1`,
  DROP FOREIGN KEY `fk_friends_user_email2`,
  DROP KEY `friend_key_idx`;

ALTER TABLE `Following`
  ADD KEY `following_key_idx` (`user_email2`),
  ADD CONSTRAINT `fk_following_user_email1`
    FOREIGN KEY (`user_email1`) REFERENCES `Users` (`email`),
  ADD CONSTRAINT `fk_following_user_email2`
    FOREIGN KEY (`user_email2`) REFERENCES `Users` (`email`);
