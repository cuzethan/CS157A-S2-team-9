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

/* the password is password */

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

INSERT INTO `Categories` (`category_name`) VALUES
('Textbooks'),          
('Tech & Electronics'), 
('Sports & Outdoors'), 
('Furniture'),         
('School Supplies'),    
('Clothing'),          
('Bikes & Scooters'),   
('Housing & Subleases'),
('Tutoring Services'),  
('Other');      

/* 2. Insert 10 Dummy Posts distributed across categories */
INSERT INTO `Posts` 
(`title`, `price`, `description`, `item_status`, `email`, `category_id`, `meetup_id`) 
VALUES
('Calculus: Early Transcendentals', 55.00, 'Hardcover, 8th Edition. Minimal wear.', 'Available', 'blue.spartan@sjsu.edu', 1, 5),
('Gaming Monitor 27"', 140.00, '144Hz refresh rate, 1ms response time.', 'Available', 'silicon.valley@sjsu.edu', 2, 4),
('iPhone 13 Case', 10.00, 'Clear silicone case, brand new.', 'Available', 'starlight.dev@sjsu.edu', 3, 2),
('Study Desk', 40.00, 'Small wooden desk, fits perfect in CV2 dorms.', 'Available', 'tower.hall@sjsu.edu', 4, 1),
('Organic Chem Notebook', 5.00, 'Unused, 100 pages of hex grid paper.', 'Available', 'urban.explorer@sjsu.edu', 5, 7),
('SJSU Varsity Jacket', 60.00, 'Vintage style, size Medium.', 'Available', 'golden.gate@sjsu.edu', 6, 9),
('Road Bike - 21 Speed', 120.00, 'Great for commuting to campus. Includes lock.', 'Available', 'speedy.sammy@sjsu.edu', 7, 10),
('Summer Sublease - 1bd/1ba', 1100.00, 'Right across from campus, June-August.', 'Available', 'cloud.hiker@sjsu.edu', 8, 5),
('Java Programming Tutor', 30.00, 'Help with CS46A/B assignments. $30/hr.', 'Available', 'coding.bear@sjsu.edu', 9, 5),
('Lost AirPods Case', 0.00, 'Found near the fountain. DM to identify.', 'Available', 'retro.gamer@sjsu.edu', 10, 10);