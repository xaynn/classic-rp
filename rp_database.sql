-- phpMyAdmin SQL Dump
-- version 5.2.1deb3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Wrz 28, 2025 at 02:37 PM
-- Wersja serwera: 10.11.13-MariaDB-0ubuntu0.24.04.1
-- Wersja PHP: 8.3.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `rp_database`
--

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `admins`
--

CREATE TABLE `admins` (
  `id` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `perms` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`perms`)),
  `dutyTime` int(100) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `account_id`, `perms`, `dutyTime`) VALUES
(1, 1, '[ { \"creatingCorners\": true, \"fightstyles\": true, \"vehicleFix\": true, \"vehicleCreate\": true, \"creatingItems\": true, \"resetpassword\": true, \"vehicleSpawn\": true, \"tpInteriors\": true, \"creatingInteriors\": true, \"fly\": true, \"searchPlayer\": true, \"creatingAtms\": true, \"createShops\": true, \"giveRank\": true, \"openInteriors\": true, \"unban\": true, \"ban\": true, \"ninja\": true, \"spec\": true, \"vehicleBring\": true, \"displayName\": true, \"deleteItems\": true, \"creatingGroups\": true, \"bw\": true, \"tpToPlayer\": true, \"kick\": true, \"charBlock\": true, \"globalChats\": true, \"cash\": true } ]', 159),
(2, 3, '[ { \"creatingCorners\": true, \"fightstyles\": true, \"vehicleFix\": true, \"vehicleCreate\": true, \"creatingItems\": true, \"cash\": true, \"creatingInteriors\": true, \"fly\": true, \"searchPlayer\": true, \"tpToPlayer\": true, \"createShops\": true, \"tpInteriors\": true, \"openInteriors\": true, \"globalChats\": true, \"ban\": true, \"unban\": true, \"spec\": true, \"vehicleBring\": true, \"displayName\": true, \"deleteItems\": true, \"creatingGroups\": true, \"bw\": true, \"ninja\": true, \"kick\": true, \"charBlock\": true, \"creatingAtms\": true, \"vehicleSpawn\": true } ]', 0),
(3, 4, '[ { \"creatingCorners\": true, \"fightstyles\": true, \"vehicleFix\": true, \"creatingAtms\": true, \"searchPlayer\": true, \"cash\": true, \"creatingInteriors\": true, \"fly\": true, \"creatingItems\": true, \"tpToPlayer\": true, \"createShops\": true, \"tpInteriors\": true, \"openInteriors\": true, \"globalChats\": true, \"creatingGroups\": true, \"ninja\": true, \"spec\": true, \"ban\": true, \"displayName\": true, \"deleteItems\": true, \"vehicleBring\": true, \"bw\": true, \"unban\": true, \"kick\": true, \"charBlock\": true, \"vehicleCreate\": true, \"vehicleSpawn\": true } ]', 0),
(4, 5, '[ { \"creatingCorners\": true, \"fightstyles\": true, \"vehicleFix\": true, \"vehicleCreate\": true, \"creatingItems\": true, \"resetpassword\": true, \"vehicleSpawn\": true, \"tpInteriors\": true, \"creatingInteriors\": true, \"fly\": true, \"searchPlayer\": true, \"creatingAtms\": true, \"createShops\": true, \"giveRank\": true, \"openInteriors\": true, \"unban\": true, \"ban\": true, \"ninja\": true, \"spec\": true, \"vehicleBring\": true, \"displayName\": true, \"deleteItems\": true, \"creatingGroups\": true, \"bw\": true, \"tpToPlayer\": true, \"kick\": true, \"charBlock\": true, \"globalChats\": true, \"cash\": true } ]', 0),
(5, 8, '[ { \"creatingCorners\": true, \"fightstyles\": true, \"tpToPlayer\": true, \"vehicleCreate\": true, \"creatingItems\": true, \"cash\": true, \"searchPlayer\": true, \"creatingInteriors\": true, \"fly\": true, \"resetpassword\": true, \"vehicleFix\": true, \"tpInteriors\": true, \"createShops\": true, \"openInteriors\": true, \"unban\": true, \"creatingGroups\": true, \"ninja\": true, \"spec\": true, \"globalChats\": true, \"displayName\": true, \"deleteItems\": true, \"vehicleBring\": true, \"bw\": true, \"ban\": true, \"kick\": true, \"charBlock\": true, \"creatingAtms\": true, \"vehicleSpawn\": true } ]', 0),
(6, 10, '[ { \"creatingCorners\": true, \"fightstyles\": true, \"tpToPlayer\": true, \"vehicleCreate\": true, \"creatingItems\": true, \"cash\": true, \"searchPlayer\": true, \"creatingInteriors\": true, \"fly\": true, \"resetpassword\": true, \"vehicleFix\": true, \"tpInteriors\": true, \"createShops\": true, \"openInteriors\": true, \"unban\": true, \"creatingGroups\": true, \"ninja\": true, \"spec\": true, \"globalChats\": true, \"displayName\": true, \"deleteItems\": true, \"vehicleBring\": true, \"bw\": true, \"ban\": true, \"kick\": true, \"charBlock\": true, \"creatingAtms\": true, \"vehicleSpawn\": true } ]', 0);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `atms`
--

CREATE TABLE `atms` (
  `id` int(11) NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `r` float NOT NULL,
  `dimension` int(11) NOT NULL,
  `interior` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `atms`
--

INSERT INTO `atms` (`id`, `x`, `y`, `z`, `r`, `dimension`, `interior`) VALUES
(2, 1484.78, -1772.31, 18.4458, 181.467, 0, 0),
(4, 2288.48, -1910.93, 19.823, 331.905, 0, 0),
(5, 2177.92, -1767.72, 13.1933, 87.2081, 0, 0),
(6, 1928.58, -1773.73, 13.1969, 93.4484, 0, 0),
(7, 2228.36, -1715.73, 13.2234, 270.21, 0, 0),
(8, 1314.35, -1367.87, 13.1991, 5.08401, 0, 0),
(9, 1075.78, -1385.84, 13.5039, 0.359802, 0, 0),
(10, 985.801, -1295.93, 13.1969, 1.431, 0, 0),
(11, 1117.83, 0.77832, 1000.36, 93.4044, 12, 12);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `characters`
--

CREATE TABLE `characters` (
  `id` int(11) NOT NULL,
  `account_id` int(50) NOT NULL,
  `name` varchar(25) NOT NULL,
  `surname` varchar(25) NOT NULL,
  `age` int(10) NOT NULL,
  `sex` int(2) NOT NULL,
  `statistics` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '[ { "money": 300, "hp": 100, "y": 0, "x": 0, "int": 0, "z": 0, "armor": 0, "bankmoney": 1000, "dim": 0 } ]',
  `ck` int(11) NOT NULL DEFAULT 0,
  `playtime` int(100) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `characters`
--

INSERT INTO `characters` (`id`, `account_id`, `name`, `surname`, `age`, `sex`, `statistics`, `ck`, `playtime`) VALUES
(1, 1, 'Jacek', 'Muranski', 20, 0, '[ { \"parttimejob\": 3, \"skinColor\": \"Czarny\", \"bwtime\": 0, \"walkingStyle\": 128, \"hp\": 169, \"int\": 0, \"skin\": 165, \"fitness\": 1.834200000000023, \"money\": 9045, \"bankmoney\": 108, \"strength\": 100, \"licenses\": [ \"prawko\" ], \"y\": -2086.5185546875, \"x\": 383.9482421875, \"dim\": 0, \"z\": 7.8359375, \"height\": 165, \"jailtime\": 0, \"fightstyles\": [ ], \"weight\": 65 } ]', 0, 366277),
(2, 3, 'Karol', 'Nawrocki', 21, 0, '[ { \"parttimejob\": 0, \"skinColor\": \"Czarny\", \"bwtime\": 0, \"walkingStyle\": 118, \"hp\": 100, \"bankmoney\": 1000, \"skin\": 70162, \"fitness\": 0, \"money\": 50200, \"weight\": 73, \"strength\": 0, \"fightstyles\": [ ], \"y\": -1106.2294921875, \"x\": 2232.6162109375, \"dim\": 17, \"z\": 1050.8828125, \"height\": 185, \"jailtime\": 0, \"licenses\": [ ], \"int\": 5 } ]', 0, 21396),
(3, 4, 'Jakub', 'DDD', 36, 0, '[ { \"parttimejob\": 3, \"skinColor\": \"Czarny\", \"bwtime\": 0, \"walkingStyle\": 128, \"hp\": 100, \"bankmoney\": 1000, \"skin\": 165, \"fitness\": 0, \"money\": 28089, \"weight\": 150, \"strength\": 0, \"fightstyles\": [ ], \"y\": -1734.20703125, \"x\": 1572.3359375, \"dim\": 0, \"z\": 13.48574733734131, \"height\": 150, \"jailtime\": 0, \"licenses\": [ ], \"int\": 0 } ]', 0, 165565),
(4, 5, 'Natalia', 'Sadowska', 80, 0, '[ { \"parttimejob\": 0, \"fightstyles\": [ ], \"bwtime\": 281, \"walkingStyle\": 133, \"hp\": 0, \"int\": 5, \"weight\": 80, \"fitness\": 0, \"money\": 6000, \"skin\": \"43\", \"strength\": 0, \"skinColor\": \"Biały\", \"y\": -1106.9736328125, \"x\": 2234.6748046875, \"dim\": 17, \"z\": 1050.8828125, \"height\": 200, \"jailtime\": 0, \"licenses\": [ ], \"bankmoney\": 1000 } ]', 0, 7734),
(5, 8, 'Pablo', 'Foluson', 80, 0, '[ { \"parttimejob\": 0, \"fightstyles\": [ ], \"bwtime\": 0, \"walkingStyle\": 118, \"hp\": 38, \"bankmoney\": 1000, \"weight\": 150, \"fitness\": 0, \"money\": 240500, \"int\": 0, \"strength\": 0, \"licenses\": [ ], \"y\": -399.7138671875, \"x\": -1498.05859375, \"dim\": 0, \"z\": 28.29029273986816, \"height\": 154, \"jailtime\": 0, \"skinColor\": \"Czarny\", \"skin\": \"18\" } ]', 0, 6930),
(6, 9, 'Test', 'Ziomek', 20, 0, '[ { \"parttimejob\": 0, \"skinColor\": \"Czarny\", \"bwtime\": 0, \"walkingStyle\": 118, \"hp\": 100, \"int\": 0, \"skin\": \"20\", \"fitness\": 0, \"money\": 300, \"bankmoney\": 1000, \"strength\": 0, \"licenses\": [ ], \"y\": -1742.4736328125, \"x\": 1475.6767578125, \"dim\": 0, \"z\": 13.546875, \"height\": 168, \"jailtime\": 0, \"fightstyles\": [ ], \"weight\": 60 } ]', 0, 73),
(7, 10, 'Kutasw', 'Asdad', 18, 0, '[ { \"parttimejob\": 0, \"fightstyles\": [ ], \"bwtime\": 0, \"walkingStyle\": 118, \"hp\": 100, \"bankmoney\": 1000, \"weight\": 120, \"fitness\": 0, \"money\": 3000, \"int\": 0, \"strength\": 0, \"licenses\": [ ], \"y\": -1731.662109375, \"x\": 1538.4140625, \"dim\": 0, \"z\": 13.28079032897949, \"height\": 190, \"jailtime\": 0, \"skinColor\": \"Czarny\", \"skin\": \"7\" } ]', 0, 29981);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `corner_zones`
--

CREATE TABLE `corner_zones` (
  `id` int(11) NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `bonus` int(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `corner_zones`
--

INSERT INTO `corner_zones` (`id`, `x`, `y`, `z`, `bonus`) VALUES
(1, 2041.17, -1741.27, 12.6469, 0);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `groups`
--

CREATE TABLE `groups` (
  `id` int(11) NOT NULL,
  `name` varchar(40) NOT NULL,
  `type` int(2) NOT NULL,
  `owner` int(3) NOT NULL,
  `perms` longtext NOT NULL,
  `members` longtext NOT NULL,
  `TAG` varchar(4) NOT NULL DEFAULT 'BRAK',
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `rgb` longtext NOT NULL DEFAULT '[ [ 255, 255, 255 ] ]'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `groups`
--

INSERT INTO `groups` (`id`, `name`, `type`, `owner`, `perms`, `members`, `TAG`, `createdAt`, `rgb`) VALUES
(1, 'LSPD', 2, 1, '[ { \"weeding\": true, \"radar\": true, \"vehicleAccess\": true, \"CK\": true, \"kickDoor\": true, \"steal\": true, \"drug\": true, \"undercover\": true, \"heal\": true, \"roadblock\": true, \"megafon\": true, \"kickPlayerFromVehicle\": true, \"repairVehicle\": true, \"gagPlayer\": true, \"Shop4\": true, \"news\": true, \"vehicleTuning\": true, \"detox\": true, \"cuffPlayer\": true, \"invite\": true, \"disposalItems\": true, \"spawnintek\": true, \"gasMask\": true, \"flashbang\": true, \"searchInterior\": true, \"OOC\": true, \"panicButton\": true, \"blockVehicleWheel\": true, \"mdt\": true, \"Shop5\": true, \"pagera\": true, \"usepapiren\": true, \"911\": true, \"jail\": true, \"corner\": true, \"vehicleGPS\": true, \"adv\": true, \"tag\": true } ]', '[ [ 5 ] ]', 'LSPD', '2025-06-30 13:04:37', '[ [ 0, 96, 255 ] ]'),
(2, 'TWSP', 1, 1, '[ { \"invite\": true } ]', '[ [ ] ]', 'BRAK', '2025-06-09 12:10:15', '[ [ 255, 255, 255 ] ]');

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `interiors`
--

CREATE TABLE `interiors` (
  `id` int(11) NOT NULL,
  `name` varchar(25) NOT NULL,
  `type` int(2) NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `owner` int(10) NOT NULL,
  `interior` int(10) NOT NULL,
  `intx` float NOT NULL,
  `inty` float NOT NULL,
  `intz` float NOT NULL,
  `dimensionwithin` int(10) NOT NULL,
  `interiorwithin` int(10) NOT NULL,
  `angle` int(10) NOT NULL,
  `angleexit` int(10) NOT NULL,
  `description` varchar(100) NOT NULL,
  `objects` int(10) NOT NULL,
  `objectData` longtext NOT NULL DEFAULT '[ [ ] ]',
  `lastObjectID` int(10) NOT NULL DEFAULT 0,
  `price` int(20) NOT NULL,
  `garage` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `interiors`
--

INSERT INTO `interiors` (`id`, `name`, `type`, `x`, `y`, `z`, `owner`, `interior`, `intx`, `inty`, `intz`, `dimensionwithin`, `interiorwithin`, `angle`, `angleexit`, `description`, `objects`, `objectData`, `lastObjectID`, `price`, `garage`) VALUES
(1, 'Urząd', 3, 1480.99, -1772.31, 18.7958, 1, 3, 390.44, 173.91, 1008.38, 0, 0, 90, 179, 'Dynamiczny urząd świadczący kompleksowe usługi', 0, '[ [ ] ]', 0, 0, 0),
(9, 'Magazyn', 3, 2330.19, -2315.28, 13.5469, 1, 18, 1306.86, 6.83, 1001.02, 0, 0, 90, 328, 'Magazyn pracowników', 0, '[ [ ] ]', 0, 0, 0),
(10, 'Ganton Gym', 3, 2115.41, -1743.89, 13.5547, 1, 7, 773.93, -78.49, 1000.66, 0, 0, 0, 37, 'Zwykła siłownia', 30, '[ [ { \"rotation\": [ 0, 0, 0 ], \"position\": [ 772.62378, -71.766991, 1000.6578 ], \"id\": 8086, \"lastObjectID\": 49, \"textures\": { \"a\": \"files\\/images\\/31.jpg\", \"b\": \"files\\/images\\/31.jpg\" } }, { \"rotation\": [ 272.66064, 0, 181.56036 ], \"position\": [ 764.46033, -73.681091, 1000.6563 ], \"id\": 8086, \"lastObjectID\": 50, \"textures\": { \"a\": \"files\\/images\\/31.jpg\", \"b\": \"files\\/images\\/31.jpg\" } }, { \"rotation\": [ 263.93213, 299.00647, 0 ], \"position\": [ 760.8858, -62.465874, 1000.6563 ], \"id\": 8086, \"lastObjectID\": 51, \"textures\": { \"a\": \"files\\/images\\/31.jpg\", \"b\": \"files\\/images\\/31.jpg\" } }, { \"lastObjectID\": 52, \"position\": [ 761.15601, -68.118172, 1001.0018 ], \"id\": 8086, \"textures\": { \"a\": \"files\\/images\\/31.jpg\", \"b\": \"files\\/images\\/31.jpg\" }, \"rotation\": [ 0, 0, 0 ] }, { \"rotation\": [ 0, 0, 0 ], \"position\": [ 767.4913299999999, -74.264336, 1000.6635 ], \"id\": 8086, \"lastObjectID\": 53, \"textures\": { \"a\": \"files\\/images\\/167.jpg\", \"b\": \"files\\/images\\/145.jpg\" } }, { \"rotation\": [ 0, 0, 0 ], \"position\": [ 772.3537, -69.27059199999999, 1000.0735 ], \"id\": 7572, \"lastObjectID\": 54, \"textures\": { \"a\": \"files\\/images\\/8.jpg\", \"b\": \"files\\/images\\/16.jpg\" } } ] ]', 54, 0, 0),
(11, 'LSPD', 3, 1554.09, -1675.46, 16.1953, 1, 6, 246.85, 62.49, 1003.64, 0, 0, 0, 271, 'Stacja policji', 0, '[ [ ] ]', 0, 0, 0),
(12, 'Kasyno', 3, 2069.74, -1773.53, 13.559, 1, 12, 1133.25, -15.26, 1000.67, 0, 0, 0, 101, '', 0, '[ [ ] ]', 0, 0, 0),
(13, 'Crackhouse', 1, 1520.23, -1719.38, 13.5469, 1, 5, 318.55, 1114.47, 1083.88, 0, 0, 0, 275, 'test', 0, '[ [ ] ]', 0, 0, 1),
(14, 'test', 1, 1522.33, -1724.83, 13.5469, 1, 2, 2541.72, -1303.89, 1025.07, 0, 0, 265, 247, 'd', 0, '[ [ ] ]', 0, 0, 0),
(15, 'dd', 1, 1526.52, -1726.59, 13.3906, 1, 8, -42.65, 1405.46, 1084.42, 0, 0, 0, 354, 'd', 0, '[ [ ] ]', 0, 0, 0),
(16, 'ddasd', 1, 1531.63, -1726.42, 13.3828, 1, 9, 260.67, 1237.32, 1084.25, 0, 0, 0, 289, 'd', 0, '[ [ ] ]', 0, 0, 0),
(17, 'Grand Hotel', 1, -2720.01, -318.488, 7.84375, 1, 5, 2233.53, -1115.26, 1050.88, 0, 0, 0, 178, 'dada', 0, '[ [ ] ]', 0, 0, 0),
(18, 'TWSP', 3, 2105.49, -1806.45, 13.5547, 2, 5, 372.18, -133.28, 1001.49, 0, 0, 0, 276, 'Czuć zapach pizzy', 0, '[ [ ] ]', 0, 0, 0);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `items`
--

CREATE TABLE `items` (
  `id` int(11) NOT NULL,
  `name` varchar(30) NOT NULL,
  `ownerType` int(11) NOT NULL,
  `owner` int(11) NOT NULL,
  `itemType` int(11) NOT NULL,
  `itemCount` int(11) NOT NULL,
  `var1` int(11) NOT NULL,
  `var2` varchar(150) NOT NULL,
  `var3` int(11) NOT NULL,
  `var4` longtext NOT NULL DEFAULT '[ { "settings": [ { "ringtone": 1, "wallpaper": 1 } ], "contacts": [ ] } ]',
  `x` float NOT NULL DEFAULT 0,
  `y` float NOT NULL DEFAULT 0,
  `z` float NOT NULL DEFAULT 0,
  `interior` int(10) NOT NULL DEFAULT 0,
  `dimension` int(10) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `items`
--

INSERT INTO `items` (`id`, `name`, `ownerType`, `owner`, `itemType`, `itemCount`, `var1`, `var2`, `var3`, `var4`, `x`, `y`, `z`, `interior`, `dimension`) VALUES
(1, 'Kamera', 1, 1, 2, 1, 43, 'pro', 30, '[ [ ] ]', 0, 0, 0, 0, 0),
(2, 'Ciuch - 25101', 1, 1, 11, 1, 25101, '1', 1, '[ [ ] ]', 0, 0, 0, 0, 0),
(3, 'Deagle', 1, 1, 2, 1, 24, 'pro', 0, '[ [ ] ]', 0, 0, 0, 0, 0),
(5, 'Ciuch - 25234', 1, 1, 11, 1, 25234, '1', 1, '[ [ ] ]', 0, 0, 0, 0, 0),
(6, 'Ciuch - 25234', 1, 1, 11, 1, 25234, '1', 1, '[ [ ] ]', 0, 0, 0, 0, 0),
(7, 'Ciuch - 25234', 1, 1, 11, 1, 25234, '1', 1, '[ [ ] ]', 0, 0, 0, 0, 0),
(9, 'Stek', 1, 1, 1, 8, 32, '1', 1, '[ [ ] ]', 0, 0, 0, 0, 0),
(12, 'Telefon', 1, 1, 17, 1, 0, '0', 200, '[ { \"settings\": [ { \"ringtone\": \"3\", \"notes\": [ \"asdasd\" ], \"messages\": [ ], \"wallpaper\": \"2\", \"mute\": false, \"telegram\": [ ], \"number\": 108916, \"hidecallerid\": false } ], \"contacts\": [ ] } ]', 0, 0, 0, 0, 0),
(13, 'Kominiarka', 1, 1, 3, 1, 14, '1', 1, '[ [ ] ]', 2325.4, -1391.33, 24.0067, 0, 0),
(14, 'MP5', 1, 5, 2, 1, 29, 'pro', 0, '[ [ ] ]', 0, 0, 0, 0, 0),
(15, 'M4', 1, 5, 2, 1, 31, 'pro', 0, '[ [ ] ]', 0, 0, 0, 0, 0),
(16, 'Magazynek AK47', 1, 5, 4, 3, 40, '30', 1, '[ [ ] ]', 0, 0, 0, 0, 0),
(17, 'Magazynek Combat Shotgun', 1, 5, 4, 3, 40, '27', 1, '[ [ ] ]', 0, 0, 0, 0, 0),
(24, 'AK47', 1, 1, 2, 1, 30, 'pro', 139, '[ [ ] ]', 0, 0, 0, 0, 0),
(25, 'Łuska: AK-47', 1, 1, 999, 1, 0, 'Zbliżona godzina: 23:22 brak odcisku', 0, '[ [ ] ]', 1820.86, -1686.79, 13.3828, 0, 0);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `mdt`
--

CREATE TABLE `mdt` (
  `id` int(11) NOT NULL,
  `fullName` varchar(30) NOT NULL,
  `wanted` int(1) NOT NULL,
  `logs` longtext NOT NULL,
  `type` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `playergroupperms`
--

CREATE TABLE `playergroupperms` (
  `id` int(11) NOT NULL,
  `characterID` int(11) NOT NULL,
  `perms` longtext NOT NULL,
  `skin` int(19) NOT NULL DEFAULT 7,
  `groupID` int(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `playergroupperms`
--

INSERT INTO `playergroupperms` (`id`, `characterID`, `perms`, `skin`, `groupID`) VALUES
(1, 1, '[ { \"weeding\": true, \"radar\": true, \"vehicleAccess\": true, \"CK\": true, \"kickDoor\": true, \"steal\": true, \"drug\": true, \"undercover\": true, \"heal\": true, \"roadblock\": true, \"megafon\": true, \"kickPlayerFromVehicle\": true, \"repairVehicle\": true, \"gagPlayer\": true, \"Shop4\": true, \"news\": true, \"vehicleTuning\": true, \"detox\": true, \"cuffPlayer\": true, \"invite\": true, \"disposalItems\": true, \"spawnintek\": true, \"gasMask\": true, \"flashbang\": true, \"searchInterior\": true, \"OOC\": true, \"panicButton\": true, \"blockVehicleWheel\": true, \"mdt\": true, \"Shop5\": true, \"pagera\": true, \"usepapiren\": true, \"911\": true, \"jail\": true, \"corner\": true, \"vehicleGPS\": true, \"adv\": true, \"tag\": true } ]', 7, 1),
(2, 1, '[ { \"invite\": true } ]', 7, 2),
(3, 5, '[ { \"weeding\": true, \"radar\": true, \"corner\": true, \"panicButton\": true, \"kickDoor\": true, \"steal\": true, \"drug\": true, \"undercover\": true, \"heal\": true, \"roadblock\": true, \"megafon\": true, \"kickPlayerFromVehicle\": true, \"repairVehicle\": true, \"gagPlayer\": true, \"Shop4\": true, \"news\": true, \"vehicleTuning\": true, \"detox\": true, \"cuffPlayer\": true, \"invite\": true, \"disposalItems\": true, \"spawnintek\": true, \"gasMask\": true, \"flashbang\": true, \"searchInterior\": true, \"OOC\": true, \"CK\": true, \"blockVehicleWheel\": true, \"mdt\": true, \"Shop5\": true, \"pagera\": true, \"usepapiren\": true, \"911\": true, \"jail\": true, \"vehicleAccess\": true, \"vehicleGPS\": true, \"adv\": true, \"tag\": true } ]', 7, 1);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `shops`
--

CREATE TABLE `shops` (
  `id` int(11) NOT NULL,
  `name` varchar(20) NOT NULL,
  `shopType` int(1) NOT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `z` float NOT NULL,
  `dimension` int(5) NOT NULL,
  `interior` int(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `shops`
--

INSERT INTO `shops` (`id`, `name`, `shopType`, `x`, `y`, `z`, `dimension`, `interior`) VALUES
(1, 'Ammunation', 3, 1367.8, -1279.69, 12.6469, 0, 0),
(2, 'Stacja', 1, 1929.11, -1776.31, 12.6469, 0, 0),
(3, 'Narzędzia', 2, 2070.95, -1784.37, 12.6591, 0, 0),
(5, 'Gang-Shop', 5, 1673.76, -2072.83, 12.7248, 0, 0),
(6, 'ZGP', 4, 1952.62, 669.474, 9.92031, 0, 0),
(7, 'Binco', 6, 2244.74, -1663.9, 14.5766, 0, 0);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(30) NOT NULL,
  `password` varchar(100) NOT NULL,
  `experience` int(5) NOT NULL,
  `adminlevel` int(5) NOT NULL,
  `registerDate` varchar(30) NOT NULL,
  `serial` varchar(40) NOT NULL,
  `ip` varchar(40) NOT NULL,
  `ban_reason` varchar(100) NOT NULL DEFAULT '0',
  `ban_timestamp` bigint(20) NOT NULL DEFAULT 0,
  `discordID` varchar(20) NOT NULL DEFAULT '0',
  `premium_timestamp` bigint(20) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `experience`, `adminlevel`, `registerDate`, `serial`, `ip`, `ban_reason`, `ban_timestamp`, `discordID`, `premium_timestamp`) VALUES
(1, 'insane', '$2y$10$Ah3kWn0zOHy/iM1dQylweu2lgqo16aARAcQztyD9fz9ecn3XkXw5u', 0, 3, '1731015500', 'BB00B07575F429F2510EDD60F650A953', '127.0.0.1', 'onExplosion', 0, '324843824645931008', 1777208540),
(3, 'George', '$2y$10$GVpER4g/lTN.mvWZ8Z3rtecx8kZLEuzhv3N9kn0AXrdwBXhS5jTWe', 0, 3, '1747925413', '4A7F2A5D0A68B7EDA0CB7BDA930ECD03', '127.0.0.1', 'onExplosion', 0, '402850470454099968', 0),
(4, 'kutaskozla', '$2y$10$HBLmHSvbinkVoF4yVmFq/.QXAZJurI/69WuWKMEH/Q9xo9FPQRcc6', 0, 3, '1748611711', '817576A5213C328EAF38A768345CAB63', '127.0.0.1', 'Manipulate Event', 0, '321601291375738891', 0),
(5, 'pizdapizda', '$2y$10$L9Fq7TyYRAIawCzQg4F0xe.ypWrM0pCiG7hSZKmKVS8aoR25q06Ba', 0, 3, '1748896615', '141BA1A7D0697D3CDC6C917DF525CC04', '127.0.0.1', 'onExplosion', 0, '763740495313895425', 1751584907),
(8, 'pawel33', '$2y$10$uf9SKonUUZahpOvkBlsu6unMTyVSjDvwCqnJ/d1XIPz4IE13joARS', 0, 3, '1751288050', 'E1EB6944834BD4E3C07A2E55E8B7C572', '127.0.0.1', 'onExplosion', 0, '345585522074189828', 0),
(10, 'kutaswfolusiaku', '$2y$10$HBLmHSvbinkVoF4yVmFq/.QXAZJurI/69WuWKMEH/Q9xo9FPQRcc6', 0, 3, '1748611711', '817576A5213C328EAF38A768345CAB63', '127.0.0.1', 'Invalid Event', 0, '321601291375738891', 0);

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `vehicles`
--

CREATE TABLE `vehicles` (
  `id` int(11) NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`data`)),
  `owner` int(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vehicles`
--

INSERT INTO `vehicles` (`id`, `data`, `owner`) VALUES
(1, '[ { \"fuel\": 50.7000000000001, \"tuning\": [ 1003, 1019, 1084, 8003, 1007, 1078 ], \"color\": [ 78, 106, 235, 0, 0, 0, 255, 0, 5, 0, 0, 0, 255, 0, 0 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"CA-EJT1\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 1, \"rotation\": [ 358.428955078125, 356.7425537109375, 210.0091552734375 ], \"x\": 2076.521484375, \"dim\": 0, \"z\": 13.26336002349854, \"mileage\": 0, \"owner_type\": 1, \"model\": 491, \"y\": -1830.25 } ]', 1),
(2, '[ { \"fuel\": 48.69999980000032, \"tuning\": [ 8001, 8002, 8003 ], \"color\": [ \"0\", \"0\", \"0\", 255, 255, 255, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"panel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel2\": 0, \"wheel3\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": -1828.3271484375, \"rotation\": [ 359.40673828125, 359.989013671875, 304.4476318359375 ], \"x\": 2081.4658203125, \"dim\": 0, \"z\": 13.0957727432251, \"model\": 596, \"owner_type\": 1, \"mileage\": 0, \"uid\": 2 } ]', 1),
(3, '[ { \"fuel\": 57.90000000000002, \"tuning\": [ ], \"color\": [ 242, 186, 228, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 910.5, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 2, \"panel0\": 0, \"panel5\": 1, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 3, \"rotation\": [ 359.6923828125, 359.9285888671875, 359.97802734375 ], \"x\": 2095.7958984375, \"dim\": 0, \"z\": 13.50554275512695, \"mileage\": 0, \"owner_type\": 1, \"model\": 40008, \"y\": -1750.263671875 } ]', 1),
(4, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 56, 249, 93, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 2, \"y\": 0, \"x\": 0, \"dim\": 13, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 410, \"mileage\": 0 } ]', 2),
(5, '[ { \"fuel\": 59.7, \"tuning\": [ ], \"color\": [ 115, 121, 168, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 5, \"y\": 0, \"x\": 0, \"dim\": 8354, \"z\": 0.5, \"mileage\": 0, \"owner_type\": 1, \"model\": 411, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(6, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 239, 210, 78, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 2, \"y\": 0, \"x\": 0, \"dim\": 6216, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 411, \"mileage\": 0 } ]', 2),
(7, '[ { \"fuel\": 54.00000000000006, \"tuning\": [ 1002, 1010, 1045, 1048, 1054, 1080, 1152, 8003 ], \"color\": [ 11, 127, 249, 0, 0, 0, 6, 129, 255, 0, 0, 0, 0, 203, 255 ], \"hp\": 276, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 2, \"wheel3\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 2, \"panel0\": 2, \"panel5\": 3, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 2, \"door5\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 1 }, \"owner\": 1, \"rotation\": [ 359.6044921875, 0, 180.4669189453125 ], \"y\": -1832.533203125, \"x\": 2078.2138671875, \"dim\": 0, \"z\": 13.01045322418213, \"model\": 565, \"owner_type\": 1, \"mileage\": 0, \"uid\": 7 } ]', 1),
(8, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 189, 98, 34, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 2, \"y\": 0, \"x\": 0, \"dim\": 4432, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40011, \"mileage\": 0 } ]', 2),
(9, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 151, 216, 104, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"panel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel2\": 0, \"wheel3\": 0, \"door3\": 0 }, \"owner\": 2, \"rotation\": [ 0, 0, 0 ], \"y\": -1143.223470564861, \"x\": 2131.452287061227, \"dim\": 7704, \"z\": 24.61459732055664, \"model\": 40017, \"owner_type\": 1, \"mileage\": 0, \"uid\": 9 } ]', 2),
(10, '[ { \"fuel\": 27.30000000000025, \"tuning\": [ ], \"color\": [ 22, 250, 131, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 958, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"panel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 1, \"door0\": 0, \"panel0\": 0, \"panel5\": 1, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel2\": 0, \"wheel3\": 0, \"door3\": 1 }, \"owner\": 3, \"rotation\": [ 0, 0, 0 ], \"y\": -2308.755084611852, \"x\": -2160.628163016477, \"dim\": 206, \"z\": 30.15149307250977, \"model\": 439, \"owner_type\": 1, \"mileage\": 0, \"uid\": 10 } ]', 3),
(11, '[ { \"fuel\": 50.70000000000009, \"tuning\": [ ], \"color\": [ 211, 249, 148, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"panel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel2\": 0, \"wheel3\": 0, \"door3\": 0 }, \"owner\": 1, \"rotation\": [ 0, 0, 0 ], \"y\": -1736.2216796875, \"x\": 1490.8623046875, \"dim\": 0, \"z\": 13.8828125, \"model\": 416, \"owner_type\": 1, \"mileage\": 0, \"uid\": 11 } ]', 1),
(12, '[ { \"fuel\": 51.30000000000008, \"tuning\": [ ], \"color\": [ \"0\", \"0\", \"0\", 255, 255, 255, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 341, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 1, \"door0\": 3, \"panel0\": 2, \"panel5\": 2, \"door1\": 2, \"panel6\": 1, \"wheel4\": 0, \"panel4\": 2, \"door4\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 2, \"uid\": 12, \"rotation\": [ 0, 0, 0 ], \"x\": 2131.457169873727, \"dim\": 8631, \"z\": 24.61874008178711, \"mileage\": 0, \"owner_type\": 1, \"model\": 40017, \"y\": -1143.185384627361 } ]', 2),
(13, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 99, 192, 191, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 4, \"y\": 0, \"x\": 0, \"dim\": 679, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 439, \"mileage\": 0 } ]', 4),
(14, '[ { \"fuel\": 52.50000000000007, \"tuning\": [ ], \"color\": [ 16, 62, 92, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 725, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 4, \"uid\": 14, \"rotation\": [ 0, 0, 0 ], \"x\": 1530.4580078125, \"dim\": 0, \"z\": 13.8828125, \"mileage\": 0, \"owner_type\": 1, \"model\": 560, \"y\": -1718.8515625 } ]', 4),
(15, '[ { \"fuel\": 36.00000000000023, \"tuning\": [ ], \"color\": [ 131, 57, 198, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 2, \"uid\": 15, \"rotation\": [ 0, 0, 0 ], \"x\": 2129.416090395579, \"dim\": 7867, \"z\": 24.54191970825195, \"mileage\": 0, \"owner_type\": 1, \"model\": 522, \"y\": -1144.94872195163 } ]', 2),
(16, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 188, 70, 183, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"panel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel2\": 0, \"wheel3\": 0, \"door3\": 0 }, \"owner\": 2, \"rotation\": [ 0, 0, 0 ], \"y\": -1144.295117404721, \"x\": 2133.522091066738, \"dim\": 4118, \"z\": 24.52223587036133, \"model\": 510, \"owner_type\": 1, \"mileage\": 0, \"uid\": 16 } ]', 2),
(17, '[ { \"fuel\": 56.10000000000005, \"tuning\": [ 8001, 8002, 8003 ], \"color\": [ 164, 46, 172, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 17, \"y\": -1138.676613860551, \"x\": 2129.334640340892, \"dim\": 4978, \"z\": 25.13022232055664, \"mileage\": 0, \"owner_type\": 1, \"model\": 40017, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(18, '[ { \"fuel\": 58.80000000000001, \"tuning\": [ ], \"color\": [ 220, 110, 78, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 4, \"uid\": 18, \"y\": -1144.11614167241, \"x\": 2130.114112523436, \"dim\": 4930, \"z\": 24.62040710449219, \"mileage\": 0, \"owner_type\": 1, \"model\": 468, \"rotation\": [ 0, 0, 0 ] } ]', 4),
(19, '[ { \"fuel\": 42.00000000000017, \"tuning\": [ 8001, 8002, 8003 ], \"color\": [ 83, 35, 254, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 614.5, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 2, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 2, \"panel6\": 2, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"rotation\": [ 1.065673828125, 0, 47.5323486328125 ], \"y\": -1832.5537109375, \"x\": 2080.91796875, \"dim\": 0, \"z\": 13.0255241394043, \"model\": 40057, \"owner_type\": 1, \"mileage\": 0, \"uid\": 19 } ]', 1),
(20, '[ { \"fuel\": 44.10000000000015, \"tuning\": [ 8003, 8002, 8001 ], \"color\": [ 149, 149, 129, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 793, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 2, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 3, \"panel6\": 1, \"wheel4\": 0, \"panel4\": 0, \"door4\": 1, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 20, \"rotation\": [ 1.318359375, 359.9945068359375, 65.5499267578125 ], \"x\": -348.7646484375, \"dim\": 0, \"z\": 47.00836181640625, \"mileage\": 0, \"owner_type\": 1, \"model\": 40032, \"y\": -851.109375 } ]', 1),
(21, '[ { \"fuel\": 59.7, \"tuning\": [ ], \"color\": [ 70, 168, 107, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 21, \"y\": -1139.357417269066, \"x\": 2129.999116786614, \"dim\": 4488, \"z\": 25.00617790222168, \"mileage\": 0, \"owner_type\": 1, \"model\": 40056, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(22, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 5, 85, 166, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 22, \"y\": -1139.095703707529, \"x\": 2131.740317961036, \"dim\": 7902, \"z\": 25.05094337463379, \"mileage\": 0, \"owner_type\": 1, \"model\": 40008, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(23, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 6, 102, 37, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 23, \"y\": -1139.965669243642, \"x\": 2126.373825839101, \"dim\": 7902, \"z\": 25.2391529083252, \"mileage\": 0, \"owner_type\": 1, \"model\": 40009, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(24, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 31, 41, 164, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40011, \"mileage\": 0 } ]', 1),
(25, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 70, 25, 212, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40014, \"mileage\": 0 } ]', 1),
(26, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 101, 17, 248, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40015, \"mileage\": 0 } ]', 1),
(27, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 201, 10, 158, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40016, \"mileage\": 0 } ]', 1),
(28, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 20, 202, 53, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40017, \"mileage\": 0 } ]', 1),
(29, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 208, 139, 164, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40018, \"mileage\": 0 } ]', 1),
(30, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 171, 176, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40019, \"mileage\": 0 } ]', 1),
(31, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 208, 63, 29, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40020, \"mileage\": 0 } ]', 1),
(32, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 133, 54, 191, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40021, \"mileage\": 0 } ]', 1),
(33, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 36, 12, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40022, \"mileage\": 0 } ]', 1),
(34, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 226, 117, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40023, \"mileage\": 0 } ]', 1),
(35, '[ { \"fuel\": 59.40000000000001, \"tuning\": [ ], \"color\": [ 137, 214, 119, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 35, \"y\": -1141.253579869744, \"x\": 2128.80551518559, \"dim\": 7902, \"z\": 24.80189895629883, \"mileage\": 0, \"owner_type\": 1, \"model\": 40024, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(36, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 44, 240, 243, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40025, \"mileage\": 0 } ]', 1),
(37, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 9, 81, 113, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40026, \"mileage\": 0 } ]', 1),
(38, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 92, 206, 166, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40027, \"mileage\": 0 } ]', 1),
(39, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 198, 65, 214, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40028, \"mileage\": 0 } ]', 1),
(40, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 67, 194, 33, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40029, \"mileage\": 0 } ]', 1),
(41, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 37, 123, 51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40030, \"mileage\": 0 } ]', 1),
(42, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 126, 96, 189, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40031, \"mileage\": 0 } ]', 1),
(43, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 95, 122, 138, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40032, \"mileage\": 0 } ]', 1),
(44, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 250, 45, 145, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40033, \"mileage\": 0 } ]', 1),
(45, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 103, 139, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40034, \"mileage\": 0 } ]', 1),
(46, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 115, 9, 89, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40035, \"mileage\": 0 } ]', 1),
(47, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 5, 232, 136, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40036, \"mileage\": 0 } ]', 1),
(48, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 7, 153, 115, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40037, \"mileage\": 0 } ]', 1),
(49, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 210, 210, 242, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40038, \"mileage\": 0 } ]', 1),
(50, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 181, 87, 209, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40039, \"mileage\": 0 } ]', 1),
(51, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 27, 161, 96, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40040, \"mileage\": 0 } ]', 1),
(52, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 210, 167, 222, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40041, \"mileage\": 0 } ]', 1),
(53, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 56, 9, 191, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40042, \"mileage\": 0 } ]', 1),
(54, '[ { \"fuel\": 57.90000000000002, \"tuning\": [ ], \"color\": [ 72, 118, 167, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 54, \"y\": -1978.123022108873, \"x\": 2214.933011119288, \"dim\": 7902, \"z\": 14.46697902679443, \"mileage\": 0, \"owner_type\": 1, \"model\": 40043, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(55, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 15, 26, 199, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 55, \"y\": -1978.133832726609, \"x\": 2215.023824926973, \"dim\": 7902, \"z\": 13.3906192779541, \"mileage\": 0, \"owner_type\": 1, \"model\": 40044, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(56, '[ { \"fuel\": 59.7, \"tuning\": [ ], \"color\": [ 186, 63, 145, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 56, \"y\": -1978.178754601609, \"x\": 2215.096090551973, \"dim\": 7902, \"z\": 13.3906192779541, \"mileage\": 0, \"owner_type\": 1, \"model\": 40045, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(57, '[ { \"fuel\": 59.7, \"tuning\": [ ], \"color\": [ 98, 183, 144, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 57, \"y\": -1978.049848351609, \"x\": 2215.189840551973, \"dim\": 7902, \"z\": 13.3906192779541, \"mileage\": 0, \"owner_type\": 1, \"model\": 40046, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(58, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 240, 37, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 58, \"y\": -1978.050824914109, \"x\": 2215.189840551973, \"dim\": 7902, \"z\": 13.3906192779541, \"mileage\": 0, \"owner_type\": 1, \"model\": 40047, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(59, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 4, 114, 74, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 59, \"y\": -1129.999808540939, \"x\": 2133.205074354971, \"dim\": 7902, \"z\": 25.37563133239746, \"mileage\": 0, \"owner_type\": 1, \"model\": 40048, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(60, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 9, 121, 109, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 60, \"y\": -1129.976371040939, \"x\": 2133.160152479971, \"dim\": 7902, \"z\": 25.37712669372559, \"mileage\": 0, \"owner_type\": 1, \"model\": 40049, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(61, '[ { \"fuel\": 59.7, \"tuning\": [ ], \"color\": [ 21, 160, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 61, \"y\": -1130.251761665939, \"x\": 2132.257808729971, \"dim\": 7902, \"z\": 25.43185424804688, \"mileage\": 0, \"owner_type\": 1, \"model\": 40050, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(62, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 34, 33, 174, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 62, \"y\": -1130.608206978439, \"x\": 2131.041988417471, \"dim\": 7902, \"z\": 25.41062545776367, \"mileage\": 0, \"owner_type\": 1, \"model\": 40051, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(63, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 185, 17, 73, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 1, \"y\": 0, \"x\": 0, \"dim\": 7902, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 40052, \"mileage\": 0 } ]', 1),
(64, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 162, 58, 182, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 64, \"y\": -1134.114265757876, \"x\": 2125.143486119654, \"dim\": 7902, \"z\": 25.42303085327148, \"mileage\": 0, \"owner_type\": 1, \"model\": 40053, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(65, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 211, 186, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 65, \"y\": -1138.289062586173, \"x\": 2128.802991884012, \"dim\": 7902, \"z\": 24.87617683410645, \"mileage\": 0, \"owner_type\": 1, \"model\": 40055, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(66, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 188, 39, 112, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 66, \"y\": -1137.106866947959, \"x\": 2125.154693734145, \"dim\": 7902, \"z\": 25.40802764892578, \"mileage\": 0, \"owner_type\": 1, \"model\": 40056, \"rotation\": [ 0, 0, 0 ] } ]', 1),
(67, '[ { \"fuel\": 57.30000000000003, \"tuning\": [ 8001, 8002, 8003, 1010, 1074 ], \"color\": [ 0, 0, 0, 0, 0, 0, 255, 12, 12, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door5\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door4\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 1, \"uid\": 67, \"y\": -2013.0576171875, \"x\": 2822.599609375, \"dim\": 0, \"z\": 10.57674312591553, \"mileage\": 0, \"owner_type\": 1, \"model\": 40057, \"rotation\": [ 1.065673828125, 359.9945068359375, 180.0164794921875 ] } ]', 1),
(68, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 95, 254, 209, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 5, \"y\": 0, \"x\": 0, \"dim\": 28, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 549, \"mileage\": 0 } ]', 5),
(69, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 204, 199, 122, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 5, \"y\": -1134.95703125, \"x\": 2132.9453125, \"dim\": 0, \"z\": 26.18745613098145, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 411, \"mileage\": 0 } ]', 5),
(70, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 222, 59, 232, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 5, \"y\": -1135.947265625, \"x\": 2129.8115234375, \"dim\": 0, \"z\": 26.13957786560059, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 411, \"mileage\": 0 } ]', 5),
(71, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 207, 173, 202, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 5, \"y\": -1142.0078125, \"x\": 2126.1796875, \"dim\": 0, \"z\": 25.54575729370117, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 559, \"mileage\": 0 } ]', 5),
(72, '[ { \"fuel\": 55.20000000000005, \"tuning\": [ 8003, 1138, 1010 ], \"color\": [ 120, 224, 41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 913.5, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel3\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"panel2\": 0, \"wheel2\": 0, \"door3\": 0 }, \"owner\": 5, \"y\": -1991.630859375, \"rotation\": [ 1.065673828125, 359.9945068359375, 84.3695068359375 ], \"x\": 2782.380859375, \"dim\": 0, \"z\": 13.02202415466309, \"model\": 40057, \"owner_type\": 1, \"mileage\": 0, \"uid\": 72 } ]', 5),
(73, '[ { \"fuel\": 57.90000000000002, \"tuning\": [ ], \"color\": [ 127, 79, 136, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 862, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 2, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 1 }, \"owner\": 3, \"y\": -1730.693359375, \"x\": 1554.263671875, \"dim\": 0, \"z\": 13.8828125, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 500, \"mileage\": 0 } ]', 3),
(74, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 10, 100, 112, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 6, \"y\": 0, \"x\": 0, \"dim\": 596, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 529, \"mileage\": 0 } ]', 6),
(75, '[ { \"fuel\": 60, \"tuning\": [ ], \"color\": [ 64, 47, 161, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255 ], \"hp\": 1000, \"blockedWheel\": false, \"int\": 0, \"plate\": \"BRAK\", \"damage\": { \"panel3\": 0, \"door2\": 0, \"wheel2\": 0, \"wheel1\": 0, \"door4\": 0, \"panel1\": 0, \"door0\": 0, \"panel0\": 0, \"panel5\": 0, \"door1\": 0, \"panel6\": 0, \"wheel4\": 0, \"panel4\": 0, \"door5\": 0, \"wheel3\": 0, \"panel2\": 0, \"door3\": 0 }, \"owner\": 7, \"y\": 0, \"x\": 0, \"dim\": 573, \"z\": 0.5, \"rotation\": [ 0, 0, 0 ], \"owner_type\": 1, \"model\": 439, \"mileage\": 0 } ]', 7);

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `atms`
--
ALTER TABLE `atms`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `characters`
--
ALTER TABLE `characters`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `corner_zones`
--
ALTER TABLE `corner_zones`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `groups`
--
ALTER TABLE `groups`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `interiors`
--
ALTER TABLE `interiors`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `mdt`
--
ALTER TABLE `mdt`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `playergroupperms`
--
ALTER TABLE `playergroupperms`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `shops`
--
ALTER TABLE `shops`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `atms`
--
ALTER TABLE `atms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `characters`
--
ALTER TABLE `characters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `corner_zones`
--
ALTER TABLE `corner_zones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `groups`
--
ALTER TABLE `groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `interiors`
--
ALTER TABLE `interiors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `items`
--
ALTER TABLE `items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `mdt`
--
ALTER TABLE `mdt`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `playergroupperms`
--
ALTER TABLE `playergroupperms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `shops`
--
ALTER TABLE `shops`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=76;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
