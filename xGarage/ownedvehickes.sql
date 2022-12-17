CREATE TABLE `owned_vehicles` (
  `owner` varchar(60) NOT NULL,
  `job` varchar(20) DEFAULT NULL,
  `plate` varchar(12) NOT NULL,
  `vehicle` longtext DEFAULT NULL,
  `stored` int(1) NOT NULL DEFAULT 0,
  `lieu` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `owned_vehicles`
  ADD PRIMARY KEY (`plate`);
COMMIT;

--- Xed#1188 | https://discord.gg/HvfAsbgVpM