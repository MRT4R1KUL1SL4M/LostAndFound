CREATE DATABASE  IF NOT EXISTS `test` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `test`;
-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: gateway01.ap-southeast-1.prod.aws.tidbcloud.com    Database: test
-- ------------------------------------------------------
-- Server version	8.0.11-TiDB-v7.5.2-serverless

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `announcements`
--

DROP TABLE IF EXISTS `announcements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `announcements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_1` (`admin_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`admin_id`) REFERENCES `test`.`users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin AUTO_INCREMENT=150001;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcements`
--

LOCK TABLES `announcements` WRITE;
/*!40000 ALTER TABLE `announcements` DISABLE KEYS */;
INSERT INTO `announcements` VALUES (120002,4,'Hey Welcome! I am proudly presenting my project today, 10 August 2025.',1,'2025-08-09 23:59:07');
/*!40000 ALTER TABLE `announcements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL,
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `target_id` int(11) DEFAULT NULL,
  `action_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  KEY `admin_id` (`admin_id`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `test`.`users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=240002;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (30002,4,'Edited user details for user ID: 30005','user',30005,'2025-08-05 14:04:47'),(60002,4,'Deleted item ID: 60008','item',60008,'2025-08-06 08:08:55'),(90002,4,'Posted new announcement: hi...','announcement',NULL,'2025-08-07 00:05:57'),(90003,4,'Deactivated announcement ID: 1','announcement',1,'2025-08-07 00:06:12'),(120002,4,'Posted new announcement: HI...','announcement',NULL,'2025-08-08 22:53:10'),(120003,4,'Deactivated announcement ID: 30001','announcement',30001,'2025-08-08 22:58:12'),(120004,4,'Updated claim ID 30002 to \'approved\'','claim',30002,'2025-08-08 23:10:54'),(150002,4,'Posted new announcement: 1...','announcement',NULL,'2025-08-09 22:59:56'),(150003,4,'Posted new announcement: 2...','announcement',NULL,'2025-08-09 22:59:58'),(150004,4,'Posted new announcement: 3...','announcement',NULL,'2025-08-09 23:00:01'),(150005,4,'Posted new announcement: re...','announcement',NULL,'2025-08-09 23:10:45'),(150006,4,'Posted new announcement: re...','announcement',NULL,'2025-08-09 23:10:50'),(180002,4,'Posted new announcement: sd...','announcement',NULL,'2025-08-09 23:27:00'),(180003,4,'Activated announcement ID: 60005','announcement',60005,'2025-08-09 23:29:55'),(180004,4,'Edited announcement ID: 90001','announcement',90001,'2025-08-09 23:31:36'),(210002,4,'Deleted announcement ID: 1','announcement',1,'2025-08-09 23:45:41'),(210003,4,'Deleted announcement ID: 30001','announcement',30001,'2025-08-09 23:46:06'),(210004,4,'Deleted announcement ID: 60004','announcement',60004,'2025-08-09 23:46:12'),(210005,4,'Activated announcement ID: 60003','announcement',60003,'2025-08-09 23:46:20'),(210006,4,'Deleted announcement ID: 90001','announcement',90001,'2025-08-09 23:46:24'),(210007,4,'Deleted announcement ID: 60005','announcement',60005,'2025-08-09 23:46:28'),(210008,4,'Posted new announcement: h...','announcement',NULL,'2025-08-09 23:46:47'),(210009,4,'Activated announcement ID: 60003','announcement',60003,'2025-08-09 23:46:52'),(210010,4,'Deleted announcement ID: 120001','announcement',120001,'2025-08-09 23:46:56'),(210011,4,'Posted new announcement: I am proudly presenting my pro...','announcement',NULL,'2025-08-09 23:59:08'),(210012,4,'Deleted announcement ID: 60001','announcement',60001,'2025-08-09 23:59:12'),(210013,4,'Deleted announcement ID: 60003','announcement',60003,'2025-08-09 23:59:17'),(210014,4,'Deleted announcement ID: 60002','announcement',60002,'2025-08-09 23:59:20'),(210015,4,'Edited announcement ID: 120002','announcement',120002,'2025-08-09 23:59:38');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=30008;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Electronics'),(2,'ID Cards & Documents'),(3,'Keys'),(4,'Bags & Wallets'),(5,'Clothing'),(6,'Books & Notes'),(7,'Others');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `claims`
--

DROP TABLE IF EXISTS `claims`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `claims` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_id` int(11) NOT NULL,
  `claimant_user_id` int(11) NOT NULL,
  `status` enum('pending','approved','rejected') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `claim_description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  KEY `item_id` (`item_id`),
  KEY `claimant_user_id` (`claimant_user_id`),
  CONSTRAINT `claims_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `test`.`items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `claims_ibfk_2` FOREIGN KEY (`claimant_user_id`) REFERENCES `test`.`users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=60002;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `claims`
--

LOCK TABLES `claims` WRITE;
/*!40000 ALTER TABLE `claims` DISABLE KEYS */;
INSERT INTO `claims` VALUES (30002,90008,4,'approved','2025-08-08 23:10:29','hi');
/*!40000 ALTER TABLE `claims` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_logs`
--

DROP TABLE IF EXISTS `email_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_user_id` int(11) DEFAULT NULL,
  `recipient_email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_id` int(11) DEFAULT NULL,
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_body` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sent_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `sender_email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  KEY `sender_user_id` (`sender_user_id`),
  KEY `item_id` (`item_id`),
  CONSTRAINT `email_logs_ibfk_1` FOREIGN KEY (`sender_user_id`) REFERENCES `test`.`users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `email_logs_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `test`.`items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=90005;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_logs`
--

LOCK TABLES `email_logs` WRITE;
/*!40000 ALTER TABLE `email_logs` DISABLE KEYS */;
INSERT INTO `email_logs` VALUES (1,NULL,'user1@gmail.com',2,'Inquiry about your found item: Watch',NULL,'2025-07-22 15:28:19','user2@gmail.com','trytae'),(4,NULL,'mrtarikulislamtarek69@gmail.com',7,'Inquiry about your found item: Headphone',NULL,'2025-07-22 16:16:58','mrtarikulislamtarek@gmail.com','hi'),(30005,NULL,'mrtarikulislamtarek@gmail.com',NULL,'Password Reset Code Sent',NULL,'2025-08-05 12:02:48','mrtarikulislamtarekgcolab@gmail.com','Password reset code sent to mrtarikulislamtarek@gmail.com.'),(60005,NULL,'akmkonok37@gmail.com',90008,'Inquiry about your item: LAPTOP',NULL,'2025-08-08 22:56:16','mrtarikulislamtarek69@gmail.com','HI');
/*!40000 ALTER TABLE `email_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feedback`
--

DROP TABLE IF EXISTS `feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedback` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_id` int(11) NOT NULL,
  `reviewer_id` int(11) NOT NULL,
  `reviewed_id` int(11) NOT NULL,
  `rating` tinyint(4) NOT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  KEY `item_id` (`item_id`),
  KEY `reviewer_id` (`reviewer_id`),
  KEY `reviewed_id` (`reviewed_id`),
  CONSTRAINT `feedback_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `test`.`items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `feedback_ibfk_2` FOREIGN KEY (`reviewer_id`) REFERENCES `test`.`users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `feedback_ibfk_3` FOREIGN KEY (`reviewed_id`) REFERENCES `test`.`users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=30001;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedback`
--

LOCK TABLES `feedback` WRITE;
/*!40000 ALTER TABLE `feedback` DISABLE KEYS */;
INSERT INTO `feedback` VALUES (1,90008,4,90006,5,'Thanks','2025-08-10 00:18:48');
/*!40000 ALTER TABLE `feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item_images`
--

DROP TABLE IF EXISTS `item_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `item_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_id` int(11) NOT NULL,
  `image_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  KEY `item_id` (`item_id`),
  CONSTRAINT `item_images_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `test`.`items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=30001;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_images`
--

LOCK TABLES `item_images` WRITE;
/*!40000 ALTER TABLE `item_images` DISABLE KEYS */;
INSERT INTO `item_images` VALUES (1,30008,'/static/uploads/30008_20250805115327_WhatsApp_Image_2025-04-21_at_14.44.39_83eae25c.jpg');
/*!40000 ALTER TABLE `item_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item_tags`
--

DROP TABLE IF EXISTS `item_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `item_tags` (
  `item_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL,
  PRIMARY KEY (`item_id`,`tag_id`) /*T![clustered_index] CLUSTERED */,
  KEY `tag_id` (`tag_id`),
  CONSTRAINT `item_tags_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `test`.`items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `item_tags_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `test`.`tags` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_tags`
--

LOCK TABLES `item_tags` WRITE;
/*!40000 ALTER TABLE `item_tags` DISABLE KEYS */;
INSERT INTO `item_tags` VALUES (1,1),(2,2),(3,3),(4,4),(5,5),(30008,30006),(90008,1),(90009,1);
/*!40000 ALTER TABLE `item_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `location_id` int(11) NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` enum('lost','found') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('reported','claimed','retrieved') COLLATE utf8mb4_unicode_ci DEFAULT 'reported',
  `reported_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  KEY `user_id` (`user_id`),
  KEY `category_id` (`category_id`),
  KEY `location_id` (`location_id`),
  CONSTRAINT `items_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `test`.`users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `items_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `test`.`categories` (`id`),
  CONSTRAINT `items_ibfk_3` FOREIGN KEY (`location_id`) REFERENCES `test`.`locations` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=120008;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `items`
--

LOCK TABLES `items` WRITE;
/*!40000 ALTER TABLE `items` DISABLE KEYS */;
INSERT INTO `items` VALUES (1,2,1,2,'Laptop','Black','lost','reported','2025-07-22 15:24:51'),(2,2,1,5,'Watch','White','found','reported','2025-07-22 15:25:19'),(3,3,6,3,'Book','Deleloper Book','lost','reported','2025-07-22 15:26:03'),(4,3,1,2,'Mobile','Xiaomi','found','reported','2025-07-22 15:26:31'),(5,3,4,2,'Wallet','Brown','lost','reported','2025-07-22 15:27:05'),(7,4,1,2,'Headphone','Black','found','reported','2025-07-22 16:16:31'),(30008,30005,1,3,'phone','redmi 10c','lost','reported','2025-08-05 11:53:27'),(90008,90006,1,2,'LAPTOP','LAPTOP','found','retrieved','2025-08-08 22:55:31'),(90009,90008,1,2,'Laptop','paisibutbackhobena,sorry','found','reported','2025-08-08 22:56:37');
/*!40000 ALTER TABLE `items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=30007;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locations`
--

LOCK TABLES `locations` WRITE;
/*!40000 ALTER TABLE `locations` DISABLE KEYS */;
INSERT INTO `locations` VALUES (1,'Library'),(2,'Canteen'),(3,'New Campus'),(4,'Old Campus'),(5,'Sports Ground'),(6,'Indoor Building');
/*!40000 ALTER TABLE `locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lost_item_alerts`
--

DROP TABLE IF EXISTS `lost_item_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lost_item_alerts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `location_id` int(11) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `alert_date` timestamp DEFAULT CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_1` (`user_id`),
  KEY `fk_2` (`category_id`),
  KEY `fk_3` (`location_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`user_id`) REFERENCES `test`.`users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_2` FOREIGN KEY (`category_id`) REFERENCES `test`.`categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_3` FOREIGN KEY (`location_id`) REFERENCES `test`.`locations` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin AUTO_INCREMENT=60001;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lost_item_alerts`
--

LOCK TABLES `lost_item_alerts` WRITE;
/*!40000 ALTER TABLE `lost_item_alerts` DISABLE KEYS */;
INSERT INTO `lost_item_alerts` VALUES (1,4,1,3,'Laptop','1111111','2025-08-06 19:36:17',1),(30001,4,1,2,'LAPTOP','LAPTOP','2025-08-08 22:54:36',1);
/*!40000 ALTER TABLE `lost_item_alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `claim_id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `recipient_id` int(11) NOT NULL,
  `body` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `sent_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `is_read` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  KEY `claim_id` (`claim_id`),
  KEY `sender_id` (`sender_id`),
  KEY `recipient_id` (`recipient_id`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`claim_id`) REFERENCES `test`.`claims` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `test`.`users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_ibfk_3` FOREIGN KEY (`recipient_id`) REFERENCES `test`.`users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=60001;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (1,30002,4,90006,'kire konok, laptop de','2025-08-08 23:11:23',1),(2,30002,90006,4,'ekn e doure aisa niye ja\r\n','2025-08-08 23:12:13',1),(3,30002,4,90006,'jassi, ok, bye','2025-08-08 23:13:14',1),(4,30002,90006,4,'ay','2025-08-08 23:13:57',1),(30001,30002,4,90006,'hi','2025-08-10 00:12:08',0);
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `link` varchar(255) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  KEY `fk_1` (`user_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`user_id`) REFERENCES `test`.`users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin AUTO_INCREMENT=60001;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,4,'An item matching your alert \'Laptop\' has been found: \'LAPTOP\'. Check it out!','/item/90008',1,'2025-08-08 22:55:32'),(2,4,'An item matching your alert \'LAPTOP\' has been found: \'LAPTOP\'. Check it out!','/item/90008',1,'2025-08-08 22:55:32'),(3,4,'An item matching your alert \'Laptop\' has been found: \'Laptop\'. Check it out!','/item/90009',1,'2025-08-08 22:56:38'),(4,4,'An item matching your alert \'LAPTOP\' has been found: \'Laptop\'. Check it out!','/item/90009',1,'2025-08-08 22:56:39'),(5,90006,'\'Tarikul Islam\' has submitted a claim for your item: \'LAPTOP\'.','/admin/claims',1,'2025-08-08 23:10:29'),(6,4,'Your claim for the item \'LAPTOP\' has been approved.','/messages',1,'2025-08-08 23:10:54'),(7,90006,'You have a new message from Tarikul Islam regarding \'LAPTOP\'.','/messages/claim/30002',1,'2025-08-08 23:11:23'),(8,4,'You have a new message from anisretuttut regarding \'LAPTOP\'.','/messages/claim/30002',1,'2025-08-08 23:12:13'),(9,90006,'You have a new message from Tarikul Islam regarding \'LAPTOP\'.','/messages/claim/30002',0,'2025-08-08 23:13:14'),(10,4,'You have a new message from anisretuttut regarding \'LAPTOP\'.','/messages/claim/30002',1,'2025-08-08 23:13:58'),(30001,90006,'You have a new message from Tarikul Islam regarding \'LAPTOP\'.','/messages/claim/30002',0,'2025-08-10 00:12:08');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=30003;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'user'),(2,'admin');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=60006;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
INSERT INTO `tags` VALUES (1,'laptop'),(2,'watch'),(3,'book'),(4,'mobile'),(5,'wallet'),(30006,'redmi');
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `user_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`) /*T![clustered_index] CLUSTERED */,
  KEY `role_id` (`role_id`),
  CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `test`.`users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `test`.`roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` VALUES (2,1),(3,1),(4,2),(30005,1),(60005,1),(90005,1),(90006,1),(90007,1),(90008,1),(90009,1);
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_info` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `secondary_email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `reset_token` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_token_expiration` datetime DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  PRIMARY KEY (`id`) /*T![clustered_index] CLUSTERED */,
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci AUTO_INCREMENT=120005;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (2,'User 1','user1@gmail.com','scrypt:32768:8:1$tSv4uelQorATPXJ1$0b0b544b7cabcb263e5deba3acaee390bec63e7abef795a7eb60723f69d6ef17267451f6844f069faa8ca5604bc14e800189f6efbcce5cc1abacf49bf0ca76e3',NULL,NULL,NULL,'2025-07-22 15:23:41',NULL,NULL,'active'),(3,'User 2','user2@gmail.com','scrypt:32768:8:1$BI0J3TgdpCg24fqv$8f40540278454a2281ddefa8537a98b767cdcfbec627df535fd7a481983daa141d72da450ed871eecce11848231aa475af315d8ef6cec21a951d1403cbe1e244',NULL,NULL,NULL,'2025-07-22 15:24:05',NULL,NULL,'active'),(4,'Tarikul Islam','mrtarikulislamtarek69@gmail.com','scrypt:32768:8:1$M6UKLUxwtcuFSXAZ$5f8c0ae62284cf8b621154dabb641218983ce8db44b58e764dd2a8b640e0bbcb6ad7e5595e454f34538110123fdd25d81ac77e10c070b2ed624ee0da82c2e729','','','','2025-07-22 16:04:41',NULL,NULL,'active'),(30005,'Ratul','miratul846@gmail.com','scrypt:32768:8:1$Br3Z35lVWivWSn7v$701a563ff71dd7a0815abd3896725550a5430864d0f4a5bdc81c90fad99713f2d87409d6e16938eec4a1ebadfd65f3c0a3f02bca204d8d36cfadc498640f46b7','12345678','','','2025-08-05 11:51:42',NULL,NULL,'active'),(60005,'Tarikul Islam','mcconnoyepic@gmail.com','scrypt:32768:8:1$IAhdzgaax4ogfNZ1$83e0b3381dbaac0a929766db7c517c8a833f5315e65425dc5147b3541361c7dd77d0b0cfb4c889badb904ba34d503d6be2d8af79786965500e35f1991ec99fac',NULL,NULL,NULL,'2025-08-05 19:09:14',NULL,NULL,'active'),(90005,'Muna','munaghosh636@gmail.com','scrypt:32768:8:1$OLZl3xP2AZmuMRoj$96f6adc0f797d078dd4a2d3c4a73c3dbd6279b62e8d8532222b717e465108bf85ccf372850b1e01c9f00ba20c35c245294448e4974a1e9657e2792418232a74e',NULL,NULL,NULL,'2025-08-08 22:51:17',NULL,NULL,'active'),(90006,'anisretuttut','akmkonok37@gmail.com','scrypt:32768:8:1$FTDwRVeXj38mRkRc$701d3b792eca674cf3d8ab62073022e42db88ab99945b9bf29fece96b13bd2a255fd48652db38f5d758f2a32e6dd438536167a4fe280721ce5f8dc8236fdd9d8',NULL,NULL,NULL,'2025-08-08 22:51:18',NULL,NULL,'active'),(90007,'TARIKUL','mrtarikulislamtarek@gmail.com','scrypt:32768:8:1$xRbn3IT31NtcFZst$021420a11e2ea2abeea6ca0e80d69ab054d078547c90f39f37b5514a0aac0dbd7b95df77bf913461f6162040e13f08ecc294912e0138e8e631bd355a07f3dc28',NULL,NULL,NULL,'2025-08-08 22:51:38',NULL,NULL,'active'),(90008,'Rojoni','raziarahmanrojoni@gmail.com','scrypt:32768:8:1$XdRx9M5CiTc5RGlk$61ecc7a1164246aae5e90d45c7c2ccc3a268d597ce5e6345151dcb8233e8fd225780fe452917e7c1352379d6a7865fa67fed8ee714b16cf90c431025b8df86a0',NULL,NULL,NULL,'2025-08-08 22:53:05',NULL,NULL,'active'),(90009,'md anis ahmed','mdanisahmed7921@gmail.com','scrypt:32768:8:1$xzGkcI13uC7iQJIK$b24bdd854611c5fd65e4526234623c52aa8a967f1f3f5cd976d3d637c645d1282280f6da49fae685947aa48dccbb66af55a18d2b9414daef07eaf0f37cbc4945',NULL,NULL,NULL,'2025-08-08 22:54:09',NULL,NULL,'active');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-08-10  7:14:05
