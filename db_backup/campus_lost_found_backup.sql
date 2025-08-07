-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: localhost    Database: campus_lost_found
-- ------------------------------------------------------
-- Server version	8.0.42

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `admin_id` int NOT NULL,
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `target_id` int DEFAULT NULL,
  `action_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `admin_id` (`admin_id`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,1,'Updated claim ID 1 to \'approved\'','claim',1,'2025-07-22 16:07:49');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (4,'Bags & Wallets'),(6,'Books & Notes'),(5,'Clothing'),(1,'Electronics'),(2,'ID Cards & Documents'),(3,'Keys'),(7,'Others');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `claims`
--

DROP TABLE IF EXISTS `claims`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `claims` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `claimant_user_id` int NOT NULL,
  `status` enum('pending','approved','rejected') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `item_id` (`item_id`),
  KEY `claimant_user_id` (`claimant_user_id`),
  CONSTRAINT `claims_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `claims_ibfk_2` FOREIGN KEY (`claimant_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `claims`
--

LOCK TABLES `claims` WRITE;
/*!40000 ALTER TABLE `claims` DISABLE KEYS */;
INSERT INTO `claims` VALUES (1,6,2,'approved','2025-07-22 15:29:58');
/*!40000 ALTER TABLE `claims` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_logs`
--

DROP TABLE IF EXISTS `email_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sender_user_id` int DEFAULT NULL,
  `recipient_email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_id` int DEFAULT NULL,
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_body` text COLLATE utf8mb4_unicode_ci,
  `sent_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `sender_email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `sender_user_id` (`sender_user_id`),
  KEY `item_id` (`item_id`),
  CONSTRAINT `email_logs_ibfk_1` FOREIGN KEY (`sender_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `email_logs_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_logs`
--

LOCK TABLES `email_logs` WRITE;
/*!40000 ALTER TABLE `email_logs` DISABLE KEYS */;
INSERT INTO `email_logs` VALUES (1,NULL,'user1@gmail.com',2,'Inquiry about your found item: Watch',NULL,'2025-07-22 15:28:19','user2@gmail.com','trytae'),(2,NULL,'mrtarikulislamtarek@gmail.com',6,'Inquiry about your found item: Neckband',NULL,'2025-07-22 15:30:04','user1@gmail.com','reeeeeeeeeeeeeeeeet'),(3,NULL,'mrtarikulislamtarek@gmail.com',6,'Inquiry about your found item: Neckband',NULL,'2025-07-22 16:05:10','mrtarikulislamtarek69@gmail.com','1'),(4,NULL,'mrtarikulislamtarek69@gmail.com',7,'Inquiry about your found item: Headphone',NULL,'2025-07-22 16:16:58','mrtarikulislamtarek@gmail.com','hi');
/*!40000 ALTER TABLE `email_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feedback`
--

DROP TABLE IF EXISTS `feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedback` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `reviewer_id` int NOT NULL,
  `reviewed_id` int NOT NULL,
  `rating` tinyint NOT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `item_id` (`item_id`),
  KEY `reviewer_id` (`reviewer_id`),
  KEY `reviewed_id` (`reviewed_id`),
  CONSTRAINT `feedback_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `feedback_ibfk_2` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `feedback_ibfk_3` FOREIGN KEY (`reviewed_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedback`
--

LOCK TABLES `feedback` WRITE;
/*!40000 ALTER TABLE `feedback` DISABLE KEYS */;
/*!40000 ALTER TABLE `feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item_images`
--

DROP TABLE IF EXISTS `item_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `item_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `image_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `item_id` (`item_id`),
  CONSTRAINT `item_images_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_images`
--

LOCK TABLES `item_images` WRITE;
/*!40000 ALTER TABLE `item_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `item_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item_tags`
--

DROP TABLE IF EXISTS `item_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `item_tags` (
  `item_id` int NOT NULL,
  `tag_id` int NOT NULL,
  PRIMARY KEY (`item_id`,`tag_id`),
  KEY `tag_id` (`tag_id`),
  CONSTRAINT `item_tags_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`id`) ON DELETE CASCADE,
  CONSTRAINT `item_tags_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_tags`
--

LOCK TABLES `item_tags` WRITE;
/*!40000 ALTER TABLE `item_tags` DISABLE KEYS */;
INSERT INTO `item_tags` VALUES (1,1),(2,2),(3,3),(4,4),(5,5);
/*!40000 ALTER TABLE `item_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `category_id` int NOT NULL,
  `location_id` int NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `item_type` enum('lost','found') COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('reported','claimed','retrieved') COLLATE utf8mb4_unicode_ci DEFAULT 'reported',
  `reported_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `category_id` (`category_id`),
  KEY `location_id` (`location_id`),
  CONSTRAINT `items_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `items_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `items_ibfk_3` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `items`
--

LOCK TABLES `items` WRITE;
/*!40000 ALTER TABLE `items` DISABLE KEYS */;
INSERT INTO `items` VALUES (1,2,1,2,'Laptop','Black','lost','reported','2025-07-22 15:24:51'),(2,2,1,5,'Watch','White','found','reported','2025-07-22 15:25:19'),(3,3,6,3,'Book','Deleloper Book','lost','reported','2025-07-22 15:26:03'),(4,3,1,2,'Mobile','Xiaomi','found','reported','2025-07-22 15:26:31'),(5,3,4,2,'Wallet','Brown','lost','reported','2025-07-22 15:27:05'),(6,1,1,2,'Neckband','Black','found','retrieved','2025-07-22 15:29:11'),(7,4,1,2,'Headphone','Black','found','reported','2025-07-22 16:16:31');
/*!40000 ALTER TABLE `items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locations`
--

LOCK TABLES `locations` WRITE;
/*!40000 ALTER TABLE `locations` DISABLE KEYS */;
INSERT INTO `locations` VALUES (2,'Canteen'),(6,'Indoor Building'),(1,'Library'),(3,'New Campus'),(4,'Old Campus'),(5,'Sports Ground');
/*!40000 ALTER TABLE `locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `claim_id` int NOT NULL,
  `sender_id` int NOT NULL,
  `recipient_id` int NOT NULL,
  `body` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `sent_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_read` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `claim_id` (`claim_id`),
  KEY `sender_id` (`sender_id`),
  KEY `recipient_id` (`recipient_id`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`claim_id`) REFERENCES `claims` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_ibfk_3` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (2,'admin'),(1,'user');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tags` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
INSERT INTO `tags` VALUES (3,'book'),(1,'laptop'),(4,'mobile'),(5,'wallet'),(2,'watch');
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `user_id` int NOT NULL,
  `role_id` int NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` VALUES (1,1),(2,1),(3,1),(4,1),(1,2);
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contact_info` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `secondary_email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `reset_token` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_token_expiration` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Tarikul Islam','mrtarikulislamtarek@gmail.com','scrypt:32768:8:1$RNB19ihJEI3mlJrK$76f6a24c2e1e9f0abffbf03eb5d818cff3cf5147930d42bd12faf44817f1330c5fd24c6e776a9b8d6b9802266742bd748b7340e8147e40075d99dbce67743331',NULL,NULL,NULL,'2025-07-22 15:20:27',NULL,NULL),(2,'User 1','user1@gmail.com','scrypt:32768:8:1$tSv4uelQorATPXJ1$0b0b544b7cabcb263e5deba3acaee390bec63e7abef795a7eb60723f69d6ef17267451f6844f069faa8ca5604bc14e800189f6efbcce5cc1abacf49bf0ca76e3',NULL,NULL,NULL,'2025-07-22 15:23:41',NULL,NULL),(3,'User 2','user2@gmail.com','scrypt:32768:8:1$BI0J3TgdpCg24fqv$8f40540278454a2281ddefa8537a98b767cdcfbec627df535fd7a481983daa141d72da450ed871eecce11848231aa475af315d8ef6cec21a951d1403cbe1e244',NULL,NULL,NULL,'2025-07-22 15:24:05',NULL,NULL),(4,'Tarikul Islam 2','mrtarikulislamtarek69@gmail.com','scrypt:32768:8:1$M6UKLUxwtcuFSXAZ$5f8c0ae62284cf8b621154dabb641218983ce8db44b58e764dd2a8b640e0bbcb6ad7e5595e454f34538110123fdd25d81ac77e10c070b2ed624ee0da82c2e729',NULL,NULL,NULL,'2025-07-22 16:04:41',NULL,NULL);
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

-- Dump completed on 2025-07-22 23:34:34
