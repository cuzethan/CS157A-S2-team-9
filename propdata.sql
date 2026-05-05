INSERT INTO `Users` (`email`, `username`, `password`) VALUES
('blue.spartan@sjsu.edu', 'BlueSpartan', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('golden.gate@sjsu.edu', 'GoldenGate', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('silicon.valley@sjsu.edu', 'SiliconValley', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('tower.hall@sjsu.edu', 'TowerHall', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('digital.knight@sjsu.edu', 'DigitalKnight', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('speedy.sammy@sjsu.edu', 'SpeedySammy', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('cloud.hiker@sjsu.edu', 'CloudHiker', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('pixel.master@sjsu.edu', 'PixelMaster', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('coding.bear@sjsu.edu', 'CodingBear', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('urban.explorer@sjsu.edu', 'UrbanExplorer', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('logic.ninja@sjsu.edu', 'LogicNinja', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('data.wizard@sjsu.edu', 'DataWizard', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('retro.gamer@sjsu.edu', 'RetroGamer', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('coffee.coder@sjsu.edu', 'CoffeeCoder', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('alpha.beta@sjsu.edu', 'AlphaBeta', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('starlight.dev@sjsu.edu', 'StarlightDev', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('binary.beast@sjsu.edu', 'BinaryBeast', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('quantum.user@sjsu.edu', 'QuantumUser', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('neon.spartan@sjsu.edu', 'NeonSpartan', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8'),
('swift.ocean@sjsu.edu', 'SwiftOcean', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8');

/* the password is "password" */

/* Promoting the first 10 random users to Administrators */
INSERT INTO `Administrators` (`email`) VALUES
('blue.spartan@sjsu.edu'),
('golden.gate@sjsu.edu'),
('silicon.valley@sjsu.edu'),
('tower.hall@sjsu.edu'),
('digital.knight@sjsu.edu'),
('speedy.sammy@sjsu.edu'),
('cloud.hiker@sjsu.edu'),
('pixel.master@sjsu.edu'),
('coding.bear@sjsu.edu'),
('urban.explorer@sjsu.edu');

INSERT INTO `Posts` 
(`title`, `price`, `description`, `picture`, `item_status`, `email`, `category_id`, `meetup_id`) 
VALUES
('Calculus: Early Transcendentals', 55.00, 'Hardcover, 8th Edition. Minimal wear.', 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400', 'Available', 'blue.spartan@sjsu.edu', 1, 5),
('Gaming Monitor 27"', 140.00, '144Hz refresh rate, 1ms response time.', 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=400', 'Available', 'silicon.valley@sjsu.edu', 2, 4),
('iPhone 13 Case', 10.00, 'Clear silicone case, brand new.', 'https://images.unsplash.com/photo-1603313011101-31c7365a538a?w=400', 'Available', 'starlight.dev@sjsu.edu', 3, 2),
('Study Desk', 40.00, 'Small wooden desk, fits perfect in CV2 dorms.', 'https://images.unsplash.com/photo-1518455027359-f3f816b1a23a?w=400', 'Available', 'tower.hall@sjsu.edu', 4, 1),
('Organic Chem Notebook', 5.00, 'Unused, 100 pages of hex grid paper.', 'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400', 'Available', 'urban.explorer@sjsu.edu', 5, 7),
('SJSU Varsity Jacket', 60.00, 'Vintage style, size Medium.', 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400', 'Available', 'golden.gate@sjsu.edu', 6, 9),
('Road Bike - 21 Speed', 120.00, 'Great for commuting to campus. Includes lock.', 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=400', 'Available', 'speedy.sammy@sjsu.edu', 7, 10),
('Summer Sublease - 1bd/1ba', 1100.00, 'Right across from campus, June-August.', 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400', 'Available', 'cloud.hiker@sjsu.edu', 8, 5),
('Java Programming Tutor', 30.00, 'Help with CS46A/B assignments. $30/hr.', 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400', 'Available', 'coding.bear@sjsu.edu', 9, 5),
('Lost AirPods Case', 0.00, 'Found near the fountain. DM to identify.', 'https://images.unsplash.com/photo-1588423770670-f8999f85ff35?w=400', 'Available', 'retro.gamer@sjsu.edu', 10, 10);

/* Inserting 10 reports based on your hard-coded categories */
INSERT INTO `Reports` 
(`category`, `description`, `status`, `created_at`, `user_email`, `admin_email`) 
VALUES
('Scam/Fraud', 'User asked for payment via outside link before meeting.', 'Pending', NOW(), 'blue.spartan@sjsu.edu', 'golden.gate@sjsu.edu'),
('Inappropriate Language/Hate Speech', 'The description for the textbook contains offensive slurs.', 'Resolved', NOW(), 'silicon.valley@sjsu.edu', 'tower.hall@sjsu.edu'),
('Counterfeit Item', 'The iPhone case appears to be a cheap knockoff, not genuine.', 'Under Review', NOW(), 'starlight.dev@sjsu.edu', 'digital.knight@sjsu.edu'),
('Prohibited Item', 'User is trying to sell laboratory chemicals which are not allowed.', 'Pending', NOW(), 'urban.explorer@sjsu.edu', 'blue.spartan@sjsu.edu'),
('Harassment', 'Seller is sending aggressive messages after I declined the offer.', 'Resolved', NOW(), 'speedy.sammy@sjsu.edu', 'speedy.sammy@sjsu.edu'),
('No-Show', 'Buyer did not show up to the MLK Library at the agreed time.', 'Pending', NOW(), 'cloud.hiker@sjsu.edu', 'coding.bear@sjsu.edu'),
('Incorrect Category', 'This sublease should be in Housing, not Textbooks.', 'Resolved', NOW(), 'retro.gamer@sjsu.edu', 'urban.explorer@sjsu.edu'),
('Spam', 'User posted the same ad for a bike 15 times in one hour.', 'Pending', NOW(), 'coding.bear@sjsu.edu', 'silicon.valley@sjsu.edu'),
('Stolen Property', 'This bike looks exactly like the one stolen from my dorm yesterday.', 'Under Review', NOW(), 'golden.gate@sjsu.edu', 'digital.knight@sjsu.edu'),
('Broken Link/Image', 'The picture for the laptop is just a broken placeholder.', 'Pending', NOW(), 'digital.knight@sjsu.edu', 'blue.spartan@sjsu.edu');

/* Sample chat between testing1 and speedy.sammy */
INSERT INTO `Messages` 
(`sender_email`, `receiver_email`, `body`, `date_sent`, `is_read`) 
VALUES
('testing1@sjsu.edu', 'speedy.sammy@sjsu.edu', 'Hey! Is the road bike still available?', '2026-05-04 10:00:00', 1),
('speedy.sammy@sjsu.edu', 'testing1@sjsu.edu', 'Yes, it is! Had a few people ask but no one has come to see it yet.', '2026-05-04 10:05:00', 1),
('testing1@sjsu.edu', 'speedy.sammy@sjsu.edu', 'Awesome. Does the lock come with the keys, or is it a combination?', '2026-05-04 10:10:00', 1),
('speedy.sammy@sjsu.edu', 'testing1@sjsu.edu', 'It is a U-lock with two keys. I have both of them.', '2026-05-04 10:12:00', 1),
('testing1@sjsu.edu', 'speedy.sammy@sjsu.edu', 'Cool. Would you take $100 for it? I can meet today.', '2026-05-04 10:15:00', 1),
('speedy.sammy@sjsu.edu', 'testing1@sjsu.edu', 'I am firm on $120 for now since it is in really good shape.', '2026-05-04 10:20:00', 1),
('testing1@sjsu.edu', 'speedy.sammy@sjsu.edu', 'Totally understand. I can do $120. Can we meet at the Library?', '2026-05-04 10:25:00', 1),
('speedy.sammy@sjsu.edu', 'testing1@sjsu.edu', 'The MLK Library works for me. Are you free around 3 PM?', '2026-05-04 10:30:00', 1),
('testing1@sjsu.edu', 'speedy.sammy@sjsu.edu', '3 PM is perfect. I will be near the fourth-floor elevators.', '2026-05-04 10:35:00', 0),
('speedy.sammy@sjsu.edu', 'testing1@sjsu.edu', 'Sounds like a plan. See you then!', '2026-05-04 10:40:00', 0);

/* Inserting 10 favorites for testing1 */
INSERT INTO `Favorites` (`email`, `post_ID`, `saved_at`) VALUES
('testing1@sjsu.edu', 1,  '2026-05-04 10:00:00'),
('testing1@sjsu.edu', 2,  '2026-05-04 10:05:00'),
('testing1@sjsu.edu', 3,  '2026-05-04 10:10:00'),
('testing1@sjsu.edu', 4,  '2026-05-04 10:15:00'),
('testing1@sjsu.edu', 5,  '2026-05-04 10:20:00'),
('testing1@sjsu.edu', 6,  '2026-05-04 10:25:00'),
('testing1@sjsu.edu', 7,  '2026-05-04 10:30:00'),
('testing1@sjsu.edu', 8,  '2026-05-04 10:35:00'),
('testing1@sjsu.edu', 9,  '2026-05-04 10:40:00'),
('testing1@sjsu.edu', 10, '2026-05-04 10:45:00');

/* Generate transcation data by actually buying/selling items */