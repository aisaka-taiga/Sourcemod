-- --------------------------------------------------------
-- 호스트:                          127.0.0.1
-- 서버 버전:                        10.5.5-MariaDB - mariadb.org binary distribution
-- 서버 OS:                        Win64
-- HeidiSQL 버전:                  11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- test 데이터베이스 구조 내보내기
CREATE DATABASE IF NOT EXISTS `test` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `test`;

-- 테이블 test.characters 구조 내보내기
CREATE TABLE IF NOT EXISTS `characters` (
  `num` int(11) NOT NULL AUTO_INCREMENT COMMENT '고유식별자',
  `steamauthid` char(50) DEFAULT NULL COMMENT '스팀고번',
  `level` int(11) DEFAULT NULL COMMENT '레벨',
  PRIMARY KEY (`num`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 test.playerinfo 구조 내보내기
CREATE TABLE IF NOT EXISTS `playerinfo` (
  `steamauthid` char(50) NOT NULL DEFAULT '0' COMMENT '스팀고번',
  `nickname` char(50) DEFAULT NULL COMMENT '닉네임',
  `isplayeringame` tinyint(4) DEFAULT NULL COMMENT '플레이어접속유무',
  `joindate` varchar(50) DEFAULT NULL COMMENT '가입일',
  `lastplaydate` varchar(50) DEFAULT NULL COMMENT '최근접속일',
  `maximumchr` int(11) DEFAULT 3 COMMENT '캐릭생성최대치',
  `usenum` int(11) DEFAULT 0 COMMENT '캐릭선택',
  PRIMARY KEY (`steamauthid`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 내보낼 데이터가 선택되어 있지 않습니다.

-- 테이블 test.systemchat 구조 내보내기
CREATE TABLE IF NOT EXISTS `systemchat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `steamid` char(50) DEFAULT NULL,
  `nickname` char(50) DEFAULT NULL,
  `message` char(50) DEFAULT NULL,
  `datetime` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=443 DEFAULT CHARSET=utf8;

-- 내보낼 데이터가 선택되어 있지 않습니다.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
