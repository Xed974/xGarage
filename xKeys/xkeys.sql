CREATE TABLE `xkeys` (
  `id` int(11) NOT NULL,
  `identifier` varchar(60) NOT NULL,
  `other_users` longtext NOT NULL DEFAULT '[]',
  `plate` varchar(8) NOT NULL,
  `model` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `xkeys`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `xkeys`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

--- Xed#1188 | https://discord.gg/HvfAsbgVpM