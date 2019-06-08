CREATE TABLE `cu_bans` (
  `steamid32` char(255) NOT NULL UNIQUE,
  `name` char(255) NOT NULL,
  `steamid64` char(255) NOT NULL,
  `reason` text NOT NULL,
  `startTime` int(11) NOT NULL,
  `endtime` int(11) NOT NULL,
  `admin` char(255) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE `cu_groups` (
  `name` char(255) NOT NULL UNIQUE,
  `display` char(255) NOT NULL,
  `colorHex` int(11) NOT NULL,
  `inherit` char(255) NOT NULL,
  `perm` text NOT NULL,
  `immunity` int(11) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE `cu_users` (
  `steamid32` char(255) NOT NULL UNIQUE,
  `steamid64` char(255) NOT NULL,
  `groupid` char(255) NOT NULL,
  `added` int(11) NOT NULL,
  `lastConnected` int(11) NOT NULL,
  `perm` text NOT NULL,
) ENGINE=InnoDB;
