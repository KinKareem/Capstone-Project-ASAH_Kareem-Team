-- MySQL dump combined for db_mining_app (COMPLETE VERSION)
-- Server version 9.4.0

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

-- =======================================================
-- BAGIAN 1: TABEL MASTER INDEPENDEN (Tanpa Foreign Key)
-- =======================================================

-- 1. Table: tb_roles (User Management)
DROP TABLE IF EXISTS `tb_roles`;
CREATE TABLE `tb_roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 2. Table: employees (Master Karyawan)
DROP TABLE IF EXISTS `employees`;
CREATE TABLE `employees` (
  `employee_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `position` varchar(50) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `competency` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3. Table: heavy_equipment (Master Alat Berat Core)
DROP TABLE IF EXISTS `heavy_equipment`;
CREATE TABLE `heavy_equipment` (
  `equipment_id` int NOT NULL AUTO_INCREMENT,
  `unit_code` varchar(50) DEFAULT NULL,
  `equipment_type` enum('Crusher','Shiploader','Shovel','Haul Truck') DEFAULT NULL,
  `capacity` float DEFAULT NULL,
  `default_status` enum('ready','standby','maintenance') DEFAULT 'ready',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`equipment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 4. Table: tb_equipment (Master Alat Berat App Baru)
DROP TABLE IF EXISTS `tb_equipment`;
CREATE TABLE `tb_equipment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `unit_id` varchar(20) NOT NULL,
  `type` varchar(50) NOT NULL,
  `location` varchar(100) DEFAULT 'Workshop',
  `status` enum('Available','Breakdown','Maintenance','Standby') DEFAULT 'Available',
  `is_available` tinyint(1) DEFAULT '1',
  `productivity_rate` decimal(6,2) DEFAULT '0.00',
  `last_update` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unit_id` (`unit_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 5. Table: weekly_periods (Periode Mingguan)
DROP TABLE IF EXISTS `weekly_periods`;
CREATE TABLE `weekly_periods` (
  `period_id` int NOT NULL AUTO_INCREMENT,
  `period_code` varchar(50) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `target_tonnage` float DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`period_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 6. Table: weekly_plan (Rencana Mingguan - Standalone)
DROP TABLE IF EXISTS `weekly_plan`;
CREATE TABLE `weekly_plan` (
  `plan_id` char(10) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `production_target_tons` int DEFAULT NULL,
  `stockpile_tons` int DEFAULT NULL,
  `plan_status` varchar(50) DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 7. Table: locations (Lokasi Tambang)
DROP TABLE IF EXISTS `locations`;
CREATE TABLE `locations` (
  `location_id` int NOT NULL AUTO_INCREMENT,
  `location_name` varchar(100) DEFAULT NULL,
  `location_type` enum('pit','disposal','hauling','workshop','stockpile') DEFAULT NULL,
  PRIMARY KEY (`location_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 8. Table: shifts (Jadwal Shift)
DROP TABLE IF EXISTS `shifts`;
CREATE TABLE `shifts` (
  `shift_id` int NOT NULL AUTO_INCREMENT,
  `shift_name` varchar(50) DEFAULT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  PRIMARY KEY (`shift_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 9. Table: weather (Data Cuaca)
DROP TABLE IF EXISTS `weather`;
CREATE TABLE `weather` (
  `date` date NOT NULL,
  `rainfall_mm` float DEFAULT '0',
  `road_condition` enum('Flooded','Very Slippery','Slippery','Wet','Dry') DEFAULT NULL,
  `max_wave_m` float DEFAULT '0',
  `port_status` enum('Closed','Restricted','Open') DEFAULT NULL,
  `effective_working_hours` int DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`date`),
  UNIQUE KEY `date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 10. Table: shipping_schedule (Jadwal Kapal)
DROP TABLE IF EXISTS `shipping_schedule`;
CREATE TABLE `shipping_schedule` (
  `vessel_id` char(20) NOT NULL,
  `vessel_name` varchar(100) DEFAULT NULL,
  `eta_date` date DEFAULT NULL,
  `latest_berthing` date DEFAULT NULL,
  `target_load_tons` int DEFAULT NULL,
  `shipping_notes` text,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`vessel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 11. Table: fleet_master (Master Armada)
DROP TABLE IF EXISTS `fleet_master`;
CREATE TABLE `fleet_master` (
  `asset_id` char(20) NOT NULL,
  `equipment_type` char(50) DEFAULT NULL,
  `model` char(50) DEFAULT NULL,
  `capacity` smallint DEFAULT NULL,
  `capacity_unit` char(20) DEFAULT NULL,
  `current_status` char(50) DEFAULT NULL,
  `location` char(50) DEFAULT NULL,
  `planner_notes` text,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`asset_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 12. Table: tb_blending_plan (Rencana Blending)
DROP TABLE IF EXISTS `tb_blending_plan`;
CREATE TABLE `tb_blending_plan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `plan_week` int NOT NULL,
  `plan_year` int NOT NULL,
  `target_tonnage_weekly` int NOT NULL,
  `target_calori` decimal(6,2) DEFAULT '4800.00',
  `target_ash_max` decimal(4,2) DEFAULT '12.00',
  `initial_ash_draft` decimal(4,2) DEFAULT '12.50',
  `final_ash_result` decimal(4,2) DEFAULT NULL,
  `is_approved_mine` tinyint(1) DEFAULT '0',
  `is_approved_shipping` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 13. Table: plan_optimization_log (Log Optimasi)
DROP TABLE IF EXISTS `plan_optimization_log`;
CREATE TABLE `plan_optimization_log` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `plan_id` varchar(50) NOT NULL,
  `version` int DEFAULT '1',
  `summary_json` json DEFAULT NULL,
  `scenarios_json` json DEFAULT NULL,
  `selected_scenario_id` json DEFAULT NULL,
  `rejection_note` text,
  `current_step` enum('DRAFTING_MINE','DRAFTING_SHIP','SCENARIO_SELECTION','FINAL_APPROVAL','COMPLETED','REJECTED') DEFAULT 'DRAFTING_MINE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- =======================================================
-- BAGIAN 2: TABEL DEPENDENSI (Memiliki Foreign Keys)
-- =======================================================

-- 14. Table: tb_users (Depends on tb_roles)
DROP TABLE IF EXISTS `tb_users`;
CREATE TABLE `tb_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `pass` varchar(255) NOT NULL,
  `role_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `role_fk` (`role_id`),
  CONSTRAINT `fk_role` FOREIGN KEY (`role_id`) REFERENCES `tb_roles` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 15. Table: tb_karyawan (Depends on tb_equipment)
DROP TABLE IF EXISTS `tb_karyawan`;
CREATE TABLE `tb_karyawan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nama` varchar(100) NOT NULL,
  `user_id` int DEFAULT NULL,
  `competency` varchar(150) NOT NULL,
  `current_unit_id` int DEFAULT NULL,
  `current_shift` varchar(20) DEFAULT 'Day 1',
  `presence` enum('Hadir','Absen','Sakit','Cuti') DEFAULT 'Hadir',
  PRIMARY KEY (`id`),
  KEY `unit_fk` (`current_unit_id`),
  CONSTRAINT `tb_karyawan_ibfk_1` FOREIGN KEY (`current_unit_id`) REFERENCES `tb_equipment` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 16. Table: weekly_schedule (Multi-dependency: periods, employees, equipment, shifts, locations)
DROP TABLE IF EXISTS `weekly_schedule`;
CREATE TABLE `weekly_schedule` (
  `schedule_id` int NOT NULL AUTO_INCREMENT,
  `period_id` int DEFAULT NULL,
  `date` date DEFAULT NULL,
  `employee_id` int DEFAULT NULL,
  `equipment_id` int DEFAULT NULL,
  `shift_id` int DEFAULT NULL,
  `location_id` int DEFAULT NULL,
  `notes` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`schedule_id`),
  KEY `period_id` (`period_id`),
  KEY `employee_id` (`employee_id`),
  KEY `equipment_id` (`equipment_id`),
  KEY `shift_id` (`shift_id`),
  KEY `location_id` (`location_id`),
  CONSTRAINT `weekly_schedule_ibfk_1` FOREIGN KEY (`period_id`) REFERENCES `weekly_periods` (`period_id`),
  CONSTRAINT `weekly_schedule_ibfk_2` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`),
  CONSTRAINT `weekly_schedule_ibfk_3` FOREIGN KEY (`equipment_id`) REFERENCES `heavy_equipment` (`equipment_id`),
  CONSTRAINT `weekly_schedule_ibfk_4` FOREIGN KEY (`shift_id`) REFERENCES `shifts` (`shift_id`),
  CONSTRAINT `weekly_schedule_ibfk_5` FOREIGN KEY (`location_id`) REFERENCES `locations` (`location_id`)
) ENGINE=InnoDB AUTO_INCREMENT=211 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 17. Table: daily_attendance (Depends on employees)
DROP TABLE IF EXISTS `daily_attendance`;
CREATE TABLE `daily_attendance` (
  `attendance_id` int NOT NULL AUTO_INCREMENT,
  `date` date DEFAULT NULL,
  `employee_id` int DEFAULT NULL,
  `attendance_status` enum('present','sick','permission','absent','leave') DEFAULT 'present',
  `remarks` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`attendance_id`),
  KEY `employee_id` (`employee_id`),
  CONSTRAINT `daily_attendance_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 18. Table: daily_equipment_status (Depends on heavy_equipment)
DROP TABLE IF EXISTS `daily_equipment_status`;
CREATE TABLE `daily_equipment_status` (
  `status_id` int NOT NULL AUTO_INCREMENT,
  `date` date DEFAULT NULL,
  `equipment_id` int DEFAULT NULL,
  `equipment_status` enum('ready','breakdown','maintenance','standby') DEFAULT 'ready',
  `remarks` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`status_id`),
  KEY `equipment_id` (`equipment_id`),
  CONSTRAINT `daily_equipment_status_ibfk_1` FOREIGN KEY (`equipment_id`) REFERENCES `heavy_equipment` (`equipment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 19. Table: daily_reports (Depends on weekly_periods)
DROP TABLE IF EXISTS `daily_reports`;
CREATE TABLE `daily_reports` (
  `report_id` int NOT NULL AUTO_INCREMENT,
  `period_id` int DEFAULT NULL,
  `date` date DEFAULT NULL,
  `daily_tonnage` float DEFAULT NULL,
  `total_employees_present` int DEFAULT NULL,
  `total_equipment_ready` int DEFAULT NULL,
  `notes` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`report_id`),
  KEY `period_id` (`period_id`),
  CONSTRAINT `daily_reports_ibfk_1` FOREIGN KEY (`period_id`) REFERENCES `weekly_periods` (`period_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 20. Table: daily_report_details (Depends on daily_reports, heavy_equipment, employees)
DROP TABLE IF EXISTS `daily_report_details`;
CREATE TABLE `daily_report_details` (
  `detail_id` int NOT NULL AUTO_INCREMENT,
  `report_id` int DEFAULT NULL,
  `equipment_id` int DEFAULT NULL,
  `employee_id` int DEFAULT NULL,
  `tonnage` float DEFAULT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  PRIMARY KEY (`detail_id`),
  KEY `report_id` (`report_id`),
  KEY `equipment_id` (`equipment_id`),
  KEY `employee_id` (`employee_id`),
  CONSTRAINT `daily_report_details_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `daily_reports` (`report_id`),
  CONSTRAINT `daily_report_details_ibfk_2` FOREIGN KEY (`equipment_id`) REFERENCES `heavy_equipment` (`equipment_id`),
  CONSTRAINT `daily_report_details_ibfk_3` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed