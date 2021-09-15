CREATE DATABASE  IF NOT EXISTS `crc_fleet` /*!40100 DEFAULT CHARACTER SET utf8 */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `crc_fleet`;
-- MySQL dump 10.13  Distrib 8.0.22, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: crc_fleet
-- ------------------------------------------------------
-- Server version	8.0.22

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
-- Table structure for table `car`
--

DROP TABLE IF EXISTS `car`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `car` (
  `VIN` varchar(45) NOT NULL,
  `Description` varchar(45) NOT NULL,
  `Color` varchar(45) NOT NULL,
  `Brand` varchar(45) NOT NULL,
  `Model` varchar(45) NOT NULL,
  `Purchase_Date` date NOT NULL,
  `Category_ID` varchar(45) NOT NULL,
  PRIMARY KEY (`VIN`),
  KEY `Category_ID_idx` (`Category_ID`),
  CONSTRAINT `Category_ID` FOREIGN KEY (`Category_ID`) REFERENCES `category` (`Category_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `car`
--

LOCK TABLES `car` WRITE;
/*!40000 ALTER TABLE `car` DISABLE KEYS */;
INSERT INTO `car` VALUES ('1FAFP42R14F135005','reservations to golden customers only','Black','FORD','2004MUSTANG','2014-05-20','Categ_1'),('1FAHP35N59W183237','family car','Black','FORD','2009FOCUS','2011-07-19','Categ_6'),('1FTYR44U64PA70824','perfect condition','Silver','FORD','2004RANGER','2004-05-03','Categ_6'),('1G1PG5SB9E7371588','great contition, new tires','Gold','CHEVROLET','2014CRUZE','2015-10-22','Categ_1'),('1G1ZB5E10BF127193','turbo engine','Blue','CHEVROLET','2011MALIBU','2011-08-16','Categ_1'),('1G6KF52Y3RU230535','old car','Red','CADILLAC','1994DEVILLE','1995-01-10','Categ_5'),('1GKDS13S322424265','has two big scratches','Black','GMC','2002ENVOY','2002-02-10','Categ_3'),('1GNLVFED5AS121133','luxurious','Silver','CHEVROLET','2010TRAVERSE','2011-08-07','Categ_1'),('1HGCM56457A009744','Economy-great condition','Beige','HONDA','2007ACCORD','2008-08-08','Categ_9'),('1HGEM21271L042737','has one big scratch','Blue','HONDA','2001CIVIC','2002-06-15','Categ_4'),('2G2WP552061172513','very good condition','White','PONTIAC','2006GRANDPRIX','2007-06-15','Categ_2'),('2GCEC13J981259223','good condition','Silver','CHEVROLET','2008SILVERADO','2009-08-13','Categ_8'),('2T2BK1BA1DC199677','very good condition','Black','LEXUS','2013RX','2013-09-09','Categ_3'),('3FA6P0LU4ER196350','good condition','Blueblack','Ford','2014FUSION','2015-07-22','Categ_1'),('3GNCA23B89S633314','available upon request','Black','CHEVROLET','2009HHR','2010-05-20','Categ_6'),('5FNRL3H23AB090544','good condition, suggested for road trips','Black','HONDA','2010ODYSSEY','2011-05-16','Categ_9'),('JA4MW51R72J005049','perfect for off road','Red','MITSUBISHI','2002MONTERO','2007-09-09','Categ_2'),('JH2PC37096M306944','excellent condition','Blue','BMW','2008528I','2009-03-19','Categ_7'),('JTDKN3DU2E1820025','new tires and engine','Red','TOYOTA','2014PRIUS','2014-10-20','Categ_10'),('WVWAA71F48V001339','good condition','Black','VOLKSWAGEN','2008EOS','2009-07-20','Categ_2');
/*!40000 ALTER TABLE `car` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `Category_ID` varchar(45) NOT NULL,
  `Label` varchar(45) NOT NULL,
  `Description` varchar(45) NOT NULL,
  PRIMARY KEY (`Category_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES ('Categ_1','Luxury','high-end features'),('Categ_10','Economy','eco-friendly'),('Categ_2','Minivan','usually prefered by up to 4 people'),('Categ_3','SUV','road and off-road features'),('Categ_4','Sports','dynamic performance'),('Categ_5','OffRoad','prefered for mountain destinations'),('Categ_6','Family','normally-sized cars'),('Categ_7','HyperCar','high speed cars'),('Categ_8','Convertible','cars without roof'),('Categ_9','Compact','small family car');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer`
--

DROP TABLE IF EXISTS `customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer` (
  `Customer_ID` varchar(45) NOT NULL,
  `SSN` varchar(45) NOT NULL,
  `First_Name` varchar(45) NOT NULL,
  `Last_Name` varchar(45) NOT NULL,
  `Email` varchar(45) NOT NULL,
  `Mobile_Phone` varchar(45) NOT NULL,
  `State` varchar(45) NOT NULL,
  `Country` varchar(45) NOT NULL,
  PRIMARY KEY (`Customer_ID`),
  UNIQUE KEY `SSN_UNIQUE` (`SSN`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer`
--

LOCK TABLES `customer` WRITE;
/*!40000 ALTER TABLE `customer` DISABLE KEYS */;
INSERT INTO `customer` VALUES ('C1','148-06-4921','James','Lucero','JamesLucero@gmail.com','202-555-0194','AK','USA'),('C10','1048-06-4929','Charles','Keller','CharlesKeller@gmail.com','202-555-0108','HI','USA'),('C100','10048-06-4963','Catherine','Summers','CatherineSummers@gmail.com','202-555-0162','ME','USA'),('C11','1148-06-4930','Christopher','Howell','ChristopherHowell@gmail.com','202-555-0132','ID','USA'),('C12','1248-06-4931','Daniel','Castro','DanielCastro@gmail.com','202-555-0142','IL','USA'),('C13','1348-06-4932','Matthew','Yu','MatthewYu@gmail.com','202-555-0160','IN','USA'),('C14','1448-06-4933','Anthony','Lawrence','AnthonyLawrence@gmail.com','202-555-0161','IA','USA'),('C15','1548-06-4934','Donald','Lindsey','DonaldLindsey@gmail.com','202-555-0159','KS','USA'),('C16','1648-06-4935','Mark','Holder','MarkHolder@gmail.com','202-555-0141','KY','USA'),('C17','1748-06-4936','Paul','Huerta','PaulHuerta@gmail.com','202-555-0195','LA','USA'),('C18','1848-06-4937','Steven','Simon','StevenSimon@gmail.com','202-555-0147','ME','USA'),('C19','1948-06-4938','Andrew','Reilly','AndrewReilly@gmail.com','202-555-0157','MD','USA'),('C2','248-06-4921','John','Compton','JohnCompton@gmail.com','202-555-0176','AZ','USA'),('C20','2048-06-4939','Kenneth','Hartman','KennethHartman@gmail.com','202-555-0140','MA','USA'),('C21','2148-06-4940','Joshua','Aguirre','JoshuaAguirre@gmail.com','202-555-0157','MI','USA'),('C22','2248-06-4941','Kevin','Simmons','KevinSimmons@gmail.com','202-555-0178','MN','USA'),('C23','2348-06-4942','Brian','Holloway','BrianHolloway@gmail.com','202-555-0151','MS','USA'),('C24','2448-06-4943','George','Patton','GeorgePatton@gmail.com','202-555-0188','MO','USA'),('C25','2548-06-4944','Edward','George','EdwardGeorge@gmail.com','202-555-0198','MT','USA'),('C26','2648-06-4945','Ronald','Bolton','RonaldBolton@gmail.com','202-555-0118','NE','USA'),('C27','2748-06-4946','Timothy','Livingston','TimothyLivingston@gmail.com','202-555-0119','NV','USA'),('C28','2848-06-4947','Jason','Gaines','JasonGaines@gmail.com','202-555-0162','NH','USA'),('C29','2948-06-4948','Jeffrey','Short','JeffreyShort@gmail.com','202-555-0161','NJ','USA'),('C3','348-06-4922','Robert','Douglas','RobertDouglas@gmail.com','202-555-0113','AR','USA'),('C30','3048-06-4949','Ryan','Miller','RyanMiller@gmail.com','202-555-0107','NM','USA'),('C31','3148-06-4950','Jacob','Griffin','JacobGriffin@gmail.com','202-555-0120','NY','USA'),('C32','3248-06-4951','Gary','Herring','GaryHerring@gmail.com','202-555-0168','NC','USA'),('C33','3348-06-4952','Nicholas','Shannon','NicholasShannon@gmail.com','202-555-0130','ND','USA'),('C34','3448-06-4953','Eric','Rivas','EricRivas@gmail.com','202-555-0198','OH','USA'),('C35','3548-06-4954','Jonathan','Drake','JonathanDrake@gmail.com','202-555-0159','OK','USA'),('C36','3648-06-4955','Stephen','Bishop','StephenBishop@gmail.com','202-555-0110','OR','USA'),('C37','3748-06-4956','Larry','Frey','LarryFrey@gmail.com','202-555-0142','PA','USA'),('C38','3848-06-4957','Justin','Odonnell','JustinOdonnell@gmail.com','202-555-0181','RI','USA'),('C39','3948-06-4958','Scott','Bowen','ScottBowen@gmail.com','202-555-0174','SC','USA'),('C4','448-06-4923','Michael','Hart','MichaelHart@gmail.com','202-555-0191','CA','USA'),('C40','4048-06-4959','Brandon','Wu','BrandonWu@gmail.com','202-555-0173','SD','USA'),('C41','4148-06-4960','Benjamin','Andrews','BenjaminAndrews@gmail.com','202-555-0137','TN','USA'),('C42','4248-06-4961','Samuel','Simpson','SamuelSimpson@gmail.com','202-555-0128','TX','USA'),('C43','4348-06-4962','Frank','Summers','FrankSummers@gmail.com','202-555-0149','UT','USA'),('C44','4448-06-4963','Gregory','Booth','GregoryBooth@gmail.com','202-555-0196','VT','USA'),('C45','4548-06-4964','Raymond','Barber','RaymondBarber@gmail.com','202-555-0168','VA','USA'),('C46','4648-06-4965','Alexander','Harris','AlexanderHarris@gmail.com','202-555-0170','WA','USA'),('C47','4748-06-4966','Patrick','Daniels','PatrickDaniels@gmail.com','202-555-0109','WV','USA'),('C48','4848-06-4967','Jack','Solomon','JackSolomon@gmail.com','202-555-0193','WI','USA'),('C49','4948-06-4968','Dennis','Randall','DennisRandall@gmail.com','202-555-0184','WY','USA'),('C5','548-06-4924','William','Underwood','WilliamUnderwood@gmail.com','202-555-0107','CO','USA'),('C50','5048-06-4969','Jerry','Wang','JerryWang@gmail.com','202-555-0140','NJ','USA'),('C51','5148-06-4970','Tyler','Odonnell','TylerOdonnell@gmail.com','202-555-0197','NM','USA'),('C52','5248-06-4971','Aaron','Leon','AaronLeon@gmail.com','202-555-0195','NY','USA'),('C53','5348-06-4972','Jose','Moyer','JoseMoyer@gmail.com','202-555-0139','NC','USA'),('C54','5448-06-4973','Henry','Mccullough','HenryMccullough@gmail.com','202-555-0115','ND','USA'),('C55','5548-06-4974','Adam','Ferguson','AdamFerguson@gmail.com','202-555-0176','OH','USA'),('C56','5648-06-4975','Mary','Huang','MaryHuang@gmail.com','202-555-0123','OK','USA'),('C57','5748-06-4921','Patricia','Hughes','PatriciaHughes@gmail.com','202-555-0186','RI','USA'),('C58','5848-06-4921','Jennifer','Mullen','JenniferMullen@gmail.com','202-555-0174','SC','USA'),('C59','5948-06-4922','Linda','Gregory','LindaGregory@gmail.com','202-555-0142','SD','USA'),('C6','648-06-4925','David','Garrison','DavidGarrison@gmail.com','202-555-0118','CT','USA'),('C60','6048-06-4923','Elizabeth','Callahan','ElizabethCallahan@gmail.com','202-555-0151','TN','USA'),('C61','6148-06-4924','Barbara','Parks','BarbaraParks@gmail.com','202-555-0188','TX','USA'),('C62','6248-06-4925','Susan','Beltran','SusanBeltran@gmail.com','202-555-0198','UT','USA'),('C63','6348-06-4926','Jessica','Munoz','JessicaMunoz@gmail.com','202-555-0118','VT','USA'),('C64','6448-06-4927','Sarah','Byrd','SarahByrd@gmail.com','202-555-0119','LA','USA'),('C65','6548-06-4928','Karen','Nielsen','KarenNielsen@gmail.com','202-555-0162','ME','USA'),('C66','6648-06-4929','Nancy','Le','NancyLe@gmail.com','202-555-0161','MD','USA'),('C67','6748-06-4930','Lisa','Peters','LisaPeters@gmail.com','202-555-0107','MA','USA'),('C68','6848-06-4931','Margaret','English','MargaretEnglish@gmail.com','202-555-0120','MI','USA'),('C69','6948-06-4932','Betty','Joseph','BettyJoseph@gmail.com','202-555-0168','MN','USA'),('C7','748-06-4926','Richard','Mcbride','RichardMcbride@gmail.com','202-555-0115','DE','USA'),('C70','7048-06-4933','Sandra','Lucero','SandraLucero@gmail.com','202-555-0130','MS','USA'),('C71','7148-06-4934','Ashley','Pratt','AshleyPratt@gmail.com','202-555-0198','MO','USA'),('C72','7248-06-4935','Dorothy','Adkins','DorothyAdkins@gmail.com','202-555-0159','MT','USA'),('C73','7348-06-4936','Kimberly','Hahn','KimberlyHahn@gmail.com','202-555-0110','NE','USA'),('C74','7448-06-4937','Emily','Harrington','EmilyHarrington@gmail.com','202-555-0142','NV','USA'),('C75','7548-06-4938','Donna','Herring','DonnaHerring@gmail.com','202-555-0181','AR','USA'),('C76','7648-06-4939','Michelle','Murillo','MichelleMurillo@gmail.com','202-555-0174','CA','USA'),('C77','7748-06-4940','Carol','Liu','CarolLiu@gmail.com','202-555-0173','CO','USA'),('C78','7848-06-4941','Amanda','Norman','AmandaNorman@gmail.com','202-555-0137','CT','USA'),('C79','7948-06-4942','Melissa','Potter','MelissaPotter@gmail.com','202-555-0128','DE','USA'),('C8','848-06-4927','Joseph','Watts','JosephWatts@gmail.com','202-555-0191','FL','USA'),('C80','8048-06-4943','Deborah','Black','DeborahBlack@gmail.com','202-555-0191','FL','USA'),('C81','8148-06-4944','Stephanie','Miller','StephanieMiller@gmail.com','202-555-0135','GA','USA'),('C82','8248-06-4945','Rebecca','Lara','RebeccaLara@gmail.com','202-555-0108','NE','USA'),('C83','8348-06-4946','Laura','Molina','LauraMolina@gmail.com','202-555-0132','NV','USA'),('C84','8448-06-4947','Sharon','Matthews','SharonMatthews@gmail.com','202-555-0142','NH','USA'),('C85','8548-06-4948','Cynthia','Li','CynthiaLi@gmail.com','202-555-0160','NJ','USA'),('C86','8648-06-4949','Kathleen','Tapia','KathleenTapia@gmail.com','202-555-0161','NM','USA'),('C87','8748-06-4950','Amy','Gardner','AmyGardner@gmail.com','202-555-0159','NY','USA'),('C88','8848-06-4951','Shirley','Bryant','ShirleyBryant@gmail.com','202-555-0141','NC','USA'),('C89','8948-06-4952','Angela','Phillips','AngelaPhillips@gmail.com','202-555-0195','ND','USA'),('C9','948-06-4928','Thomas','Briggs','ThomasBriggs@gmail.com','202-555-0135','GA','USA'),('C90','9048-06-4953','Helen','Walls','HelenWalls@gmail.com','202-555-0147','OH','USA'),('C91','9148-06-4954','Anna','Petty','AnnaPetty@gmail.com','202-555-0157','OK','USA'),('C92','9248-06-4955','Brenda','Owen','BrendaOwen@gmail.com','202-555-0140','OR','USA'),('C93','9348-06-4956','Pamela','Shannon','PamelaShannon@gmail.com','202-555-0157','ID','USA'),('C94','9448-06-4957','Nicole','Mclean','NicoleMclean@gmail.com','202-555-0178','IL','USA'),('C95','9548-06-4958','Samantha','Patterson','SamanthaPatterson@gmail.com','202-555-0151','IN','USA'),('C96','9648-06-4959','Katherine','Chavez','KatherineChavez@gmail.com','202-555-0188','IA','USA'),('C97','9748-06-4960','Emma','Stevens','EmmaStevens@gmail.com','202-555-0198','KS','USA'),('C98','9848-06-4961','Ruth','Barron','RuthBarron@gmail.com','202-555-0118','KY','USA'),('C99','9948-06-4962','Christine','Bailey','ChristineBailey@gmail.com','202-555-0119','LA','USA');
/*!40000 ALTER TABLE `customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locations` (
  `Location_ID` varchar(45) NOT NULL,
  `Street` varchar(45) NOT NULL,
  `Number` varchar(45) NOT NULL,
  `City` varchar(45) NOT NULL,
  `State` varchar(45) NOT NULL,
  `Country` varchar(45) NOT NULL,
  `Phone` varchar(45) NOT NULL,
  PRIMARY KEY (`Location_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locations`
--

LOCK TABLES `locations` WRITE;
/*!40000 ALTER TABLE `locations` DISABLE KEYS */;
INSERT INTO `locations` VALUES ('L1','Atlantic St.','49','Boston','MA','USA','203-555-0574'),('L10','Creekside Road','552','Miami','FL','USA','202-555-5784'),('L2','Mayfield St.','22','Newport','RI','USA','204-555-0259,202-555-0108'),('L3','Locust St.','37','Columbia','SC','USA','202-555-0246,202-555-1684'),('L4','East High Noon St.','115','Rapid City','SD','USA','202-555-0753'),('L5','Bohemian Avenue','87','Newark','NJ','USA','202-555-2468'),('L6','South Poplar Street','55','Huston','TX','USA','202-555-1354'),('L7','Prince St.','482','Salt Lake','UT','USA','202-555-2378'),('L8','Williams Rd.','119','New York','NY','USA','202-555-2357'),('L9','Berkshire Court','338','Los Angeles','CA','USA','202-555-1479');
/*!40000 ALTER TABLE `locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reservations`
--

DROP TABLE IF EXISTS `reservations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservations` (
  `Reservation_ID` varchar(45) NOT NULL,
  `Amount` decimal(10,0) NOT NULL,
  `Pickup_Date` date NOT NULL,
  `Return_Date` date DEFAULT NULL,
  `Pickup_Location_ID` varchar(45) NOT NULL,
  `Return_Location_ID` varchar(45) DEFAULT NULL,
  `Customer_ID` varchar(45) NOT NULL,
  `Car_ID` varchar(45) NOT NULL,
  PRIMARY KEY (`Reservation_ID`),
  KEY `Car_ID_idx` (`Car_ID`),
  KEY `Customer_ID_idx` (`Customer_ID`),
  KEY `Pickup_Location_ID_idx` (`Pickup_Location_ID`),
  KEY `Return_Location_ID_idx` (`Return_Location_ID`),
  CONSTRAINT `Car_ID` FOREIGN KEY (`Car_ID`) REFERENCES `car` (`VIN`),
  CONSTRAINT `Customer_ID` FOREIGN KEY (`Customer_ID`) REFERENCES `customer` (`Customer_ID`),
  CONSTRAINT `Pickup_Location_ID` FOREIGN KEY (`Pickup_Location_ID`) REFERENCES `locations` (`Location_ID`),
  CONSTRAINT `Return_Location_ID` FOREIGN KEY (`Return_Location_ID`) REFERENCES `locations` (`Location_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reservations`
--

LOCK TABLES `reservations` WRITE;
/*!40000 ALTER TABLE `reservations` DISABLE KEYS */;
INSERT INTO `reservations` VALUES ('100R',637,'2015-12-16','2015-12-25','L6','L1','C61','2G2WP552061172513'),('10R',245,'2014-04-03','2014-04-20','L3','L5','C71','2G2WP552061172513'),('11R',242,'2014-04-05','2014-04-20','L5','L3','C72','2GCEC13J981259223'),('12R',357,'2014-04-15','2014-05-01','L2','L5','C44','1G6KF52Y3RU230535'),('13R',878,'2014-04-17','2014-05-19','L3','L2','C45','1G1ZB5E10BF127193'),('14R',468,'2014-05-19','2014-05-29','L1','L3','C46','1FTYR44U64PA70824'),('15R',264,'2014-05-01','2014-05-11','L3','L1','C47','1GKDS13S322424265'),('16R',368,'2014-05-19','2014-05-21','L5','L3','C48','1HGEM21271L042737'),('17R',2356,'2014-05-20','2014-06-01','L7','L3','C49','JTDKN3DU2E1820025'),('18R',25,'2014-05-20','2014-06-19','L9','L5','C50','JH2PC37096M306944'),('19R',242,'2014-05-01','2014-06-01','L10','L7','C51','1G1ZB5E10BF127193'),('1R',125,'2014-01-01','2014-01-29','L3','L5','C1','JTDKN3DU2E1820025'),('20R',567,'2014-06-19','2014-07-19','L3','L9','C52','1G1PG5SB9E7371588'),('21R',343,'2014-06-29','2014-07-19','L8','L10','C23','3GNCA23B89S633314'),('22R',578,'2014-06-30','2014-07-01','L9','L3','C24','2G2WP552061172513'),('23R',563,'2014-06-30','2014-07-19','L6','L8','C25','1FAFP42R14F135005'),('24R',567,'2014-07-01','2014-07-19','L10','L9','C26','JH2PC37096M306944'),('25R',327,'2014-07-19','2014-08-19','L2','L6','C27','1FTYR44U64PA70824'),('26R',835,'2014-07-01','2014-08-01','L3','L2','C28','1FAFP42R14F135005'),('27R',375,'2014-07-19','2014-08-19','L8','L1','C29','1HGCM56457A009744'),('28R',247,'2014-08-19','2014-09-29','L6','L3','C30','5FNRL3H23AB090544'),('29R',972,'2014-05-01','2014-09-30','L7','L5','C78','JTDKN3DU2E1820025'),('2R',300,'2014-01-02','2014-01-31','L6','L2','C2','1HGEM21271L042737'),('30R',478,'2014-09-19','2014-09-30','L2','L4','C79','1FTYR44U64PA70824'),('31R',2356,'2014-08-19','2014-09-11','L5','L5','C80','1FAFP42R14F135005'),('32R',235,'2014-08-19','2014-09-12','L7','L3','C81','JTDKN3DU2E1820025'),('33R',278,'2014-09-01','2014-09-14','L9','L4','C82','1G6KF52Y3RU230535'),('34R',573,'2014-09-19','2014-09-25','L10','L5','C83','1G1ZB5E10BF127193'),('35R',468,'2014-10-29','2014-11-30','L3','L7','C84','1FAFP42R14F135005'),('36R',368,'2014-10-31','2014-11-02','L8','L9','C85','1G1ZB5E10BF127193'),('37R',367,'2014-10-31','2014-11-12','L2','L10','C86','1GKDS13S322424265'),('38R',222,'2014-11-11','2014-11-15','L1','L3','C89','JH2PC37096M306944'),('39R',863,'2014-11-12','2014-11-16','L3','L8','C90','1G1PG5SB9E7371588'),('3R',245,'2014-01-19','2014-02-03','L3','L3','C3','1FTYR44U64PA70824'),('40R',964,'2014-11-14','2014-11-17','L5','L2','C91','3GNCA23B89S633314'),('41R',246,'2014-11-25','2014-12-17','L4','L1','C92','2GCEC13J981259223'),('42R',567,'2014-11-30','2014-12-17','L5','L3','C93','1HGCM56457A009744'),('43R',234,'2014-12-02','2014-12-11','L7','L8','C94','5FNRL3H23AB090544'),('44R',65,'2014-12-12','2014-12-17','L9','L9','C95','1G1ZB5E10BF127193'),('45R',436,'2014-12-15','2014-12-17','L10','L6','C96','1FAFP42R14F135005'),('46R',79,'2014-12-16','2014-12-25','L3','L3','C97','JTDKN3DU2E1820025'),('47R',42,'2014-12-17','2014-12-31','L8','L8','C98','1HGEM21271L042737'),('48R',787,'2014-12-17','2015-01-19','L2','L9','C34','1FTYR44U64PA70824'),('49R',643,'2014-12-17','2015-01-01','L1','L10','C35','1GKDS13S322424265'),('4R',235,'2014-01-19','2014-02-05','L2','L1','C65','1FAFP42R14F135005'),('50R',796,'2014-12-11','2015-01-19','L3','L3','C36','3GNCA23B89S633314'),('51R',346,'2014-12-12','2015-01-19','L8','L8','C37','1G6KF52Y3RU230535'),('52R',987,'2014-12-14','2015-01-19','L9','L2','C38','1G1PG5SB9E7371588'),('53R',63,'2014-12-25','2015-02-01','L6','L1','C39','1FAFP42R14F135005'),('54R',646,'2014-12-31','2015-02-19','L4','L3','C40','5FNRL3H23AB090544'),('55R',634,'2015-01-19','2015-03-29','L5','L5','C41','1G1PG5SB9E7371588'),('56R',902,'2015-01-01','2015-03-31','L3','L4','C42','3GNCA23B89S633314'),('57R',462,'2015-01-19','2015-04-03','L5','L5','C43','2G2WP552061172513'),('58R',657,'2015-01-19','2015-04-05','L2','L7','C44','1HGCM56457A009744'),('59R',952,'2015-01-19','2015-04-15','L3','L3','C3','1G1ZB5E10BF127193'),('5R',753,'2014-01-19','2014-02-15','L1','L3','C66','2G2WP552061172513'),('60R',664,'2015-02-01','2015-04-17','L1','L8','C4','1GKDS13S322424265'),('61R',673,'2015-02-19','2015-05-19','L3','L2','C5','5FNRL3H23AB090544'),('62R',242,'2015-03-29','2015-05-01','L3','L1','C6','1G1PG5SB9E7371588'),('63R',478,'2015-03-31','2015-05-19','L2','L3','C7','3GNCA23B89S633314'),('64R',574,'2015-04-03','2015-05-20','L1','L8','C8','2G2WP552061172513'),('65R',375,'2015-04-05','2015-05-20','L3','L9','C9','1G1PG5SB9E7371588'),('66R',573,'2015-04-15','2015-05-01','L5','L6','C10','1FAFP42R14F135005'),('67R',573,'2015-04-17','2015-06-19','L4','L4','C11','1G1ZB5E10BF127193'),('68R',357,'2015-05-19','2015-06-29','L5','L5','C12','1GKDS13S322424265'),('69R',853,'2015-05-01','2015-06-30','L8','L3','C33','1HGCM56457A009744'),('6R',658,'2014-02-01','2014-02-17','L3','L3','C67','1G6KF52Y3RU230535'),('70R',584,'2015-05-19','2015-06-30','L8','L2','C34','1HGCM56457A009744'),('71R',457,'2015-05-20','2015-07-01','L5','L1','C35','1FAFP42R14F135005'),('72R',246,'2015-05-20','2015-07-19','L9','L3','C36','2GCEC13J981259223'),('73R',266,'2015-05-20','2015-07-01','L9','L5','C37','1FAFP42R14F135005'),('74R',462,'2015-05-20','2015-07-19','L8','L4','C38','1FAFP42R14F135005'),('75R',84,'2015-06-29','2015-08-19','L1','L5','C39','2G2WP552061172513'),('76R',462,'2015-06-30','2015-05-01','L3','L10','C40','1G1PG5SB9E7371588'),('77R',469,'2015-06-30','2015-09-19','L5','L2','C41','3GNCA23B89S633314'),('78R',362,'2015-07-01','2015-08-19','L4','L3','C42','5FNRL3H23AB090544'),('79R',467,'2015-07-19','2015-08-19','L5','L8','C43','1G1PG5SB9E7371588'),('7R',462,'2014-02-19','2014-03-19','L5','L2','C68','1FAFP42R14F135005'),('80R',246,'2015-07-18','2015-09-01','L7','L6','C44','1FAFP42R14F135005'),('81R',375,'2015-08-19','2015-09-19','L9','L7','C45','1G6KF52Y3RU230535'),('82R',473,'2015-08-19','2015-10-29','L10','L1','C46','1HGCM56457A009744'),('83R',563,'2015-05-01','2015-10-31','L7','L3','C47','1FTYR44U64PA70824'),('84R',966,'2015-09-19','2015-10-31','L5','L5','C48','1FAFP42R14F135005'),('85R',537,'2015-08-19','2015-11-11','L2','L9','C49','2G2WP552061172513'),('86R',573,'2015-08-19','2015-11-12','L3','L10','C50','1HGCM56457A009744'),('87R',846,'2015-09-01','2015-11-14','L1','L7','C66','1G6KF52Y3RU230535'),('88R',357,'2015-09-19','2015-11-25','L3','L5','C67','JTDKN3DU2E1820025'),('89R',135,'2015-10-29','2015-11-30','L3','L2','C68','1HGEM21271L042737'),('8R',326,'2014-03-29','2014-04-01','L4','L5','C69','1G1ZB5E10BF127193'),('90R',747,'2015-10-31','2015-12-02','L2','L3','C69','3GNCA23B89S633314'),('91R',95,'2015-10-31','2015-12-12','L5','L3','C70','2G2WP552061172513'),('92R',245,'2015-11-11','2015-12-15','L4','L2','C71','1G1PG5SB9E7371588'),('93R',532,'2015-11-12','2015-12-16','L5','L5','C72','3GNCA23B89S633314'),('94R',52,'2015-11-14','2015-12-17','L3','L4','C73','5FNRL3H23AB090544'),('95R',457,'2015-11-25','2015-12-17','L5','L5','C74','1FAFP42R14F135005'),('96R',246,'2015-11-30','2015-12-17','L2','L3','C57','1G1ZB5E10BF127193'),('97R',266,'2015-12-02','2015-12-11','L3','L5','C58','1GKDS13S322424265'),('98R',462,'2015-12-12','2015-12-12','L1','L2','C59','5FNRL3H23AB090544'),('99R',84,'2015-12-15','2015-12-14','L3','L3','C60','1G1PG5SB9E7371588'),('9R',2425,'2014-03-31','2014-04-19','L5','L4','C70','1FTYR44U64PA70824');
/*!40000 ALTER TABLE `reservations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'crc_fleet'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-11-15 15:19:10
