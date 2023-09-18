DROP TABLE IF EXISTS `weapon_shop`;
CREATE TABLE IF NOT EXISTS `weapon_shop` (
  `shopid` varchar(255) NOT NULL,
  `jobaccess` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `displayname` varchar(255) NOT NULL,
  `money` double(11,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`shopid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

INSERT INTO `weapon_shop` (`shopid`, `jobaccess`, `displayname`, `money`) VALUES
('valweaponshop', 'valweaponsmith', 'Valentine Weapon Shop', 0),
('rhoweaponshop', 'rhoweaponsmith', 'Rhodes Weapon Shop', 0),
('stdweaponshop', 'stdweaponsmith', 'Staint Denis Weapon Shop', 0),
('tumweaponshop', 'tumweaponsmith', 'Tumbleweed Weapon Shop', 0),
('annweaponshop', 'annweaponsmith', 'Annesburg Weapon Shop', 0);

DROP TABLE IF EXISTS `weapon_stock`;
CREATE TABLE `weapon_stock` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shopid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `items` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `price` double(11,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
