/*

	Historical Spawn Dates
	by Gedemon (2013-2017)

*/

-------------------------------------------------------------------------------
-- Spawn dates based on the national founding date of countries
-------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS HistoricalSpawnDates_TrueHSD
	 (	Civilization TEXT NOT NULL UNIQUE,
		StartYear INTEGER DEFAULT -10000);


INSERT OR REPLACE INTO HistoricalSpawnDates_TrueHSD
(	Civilization,				StartYear) 
VALUES
-- Major Civilizations
(	'CIVILIZATION_AMERICA',			 1776	),
(	'CIVILIZATION_ARABIA',			 632	),
(	'CIVILIZATION_AUSTRALIA',		 1900	),
(	'CIVILIZATION_AZTEC',			 1250	),
(	'CIVILIZATION_BABYLON_STK',		-2000	),
(	'CIVILIZATION_BRAZIL',			 1822	),
(	'CIVILIZATION_BYZANTIUM',		 330	),
(	'CIVILIZATION_CANADA',		 	1867	),
(	'CIVILIZATION_CHINA',			-2100	),
(	'CIVILIZATION_CREE',			-400	),
(	'CIVILIZATION_ENGLAND',			 900	),
(	'CIVILIZATION_EGYPT',			-3200	),
(	'CIVILIZATION_ETHIOPIA',		-500	),
(	'CIVILIZATION_FRANCE',			481 	),
(	'CIVILIZATION_GAUL',			-1600	),
(	'CIVILIZATION_GEORGIA',			-1600	),
(	'CIVILIZATION_GERMANY',			780		),
(	'CIVILIZATION_GRAN_COLOMBIA',	1820	),
(	'CIVILIZATION_GREECE',			-1600	),
(	'CIVILIZATION_HUNGARY',			   895	),
(	'CIVILIZATION_INCA',			  -750	),
(	'CIVILIZATION_INDIA',			-2500	),
(	'CIVILIZATION_INDONESIA',		 400	),
(	'CIVILIZATION_JAPAN',			 500	),
(	'CIVILIZATION_KHMER',			-100	),
(	'CIVILIZATION_KONGO',			 1375	),
(	'CIVILIZATION_KOREA',			  -500	),
(	'CIVILIZATION_MAPUCHE',			-400	),
(	'CIVILIZATION_MAYA',			-750	),
(	'CIVILIZATION_MACEDON',			  -600	),
(	'CIVILIZATION_MALI',			  -300	),
(	'CIVILIZATION_MAORI',		 	-1200	),
(	'CIVILIZATION_MONGOLIA',		-209	),
(	'CIVILIZATION_NETHERLANDS',		 1590	),
(	'CIVILIZATION_NORWAY',			 700	),
(	'CIVILIZATION_NUBIA',			-2400	),
(	'CIVILIZATION_OTTOMAN',			 1200	),
(	'CIVILIZATION_PERSIA',			-678	),
(	'CIVILIZATION_PHOENICIA',		  -814	),
(	'CIVILIZATION_POLAND',			  966	),
(	'CIVILIZATION_PORTUGAL',			868 ),
(	'CIVILIZATION_ROME',			 -753	),
(	'CIVILIZATION_RUSSIA',			  862	),
(	'CIVILIZATION_SCOTLAND',		843		),
(	'CIVILIZATION_SCYTHIA',			 -800	),
(	'CIVILIZATION_SPAIN',			466		),
(	'CIVILIZATION_SUMERIA',			-4100	),
(	'CIVILIZATION_SWEDEN',			  700	),
(	'CIVILIZATION_VIETNAM',			  -1200	),
(	'CIVILIZATION_ZULU',			 1600	),
-- Minor Civilizations
(	'CIVILIZATION_AKKAD',			 -3960	),
(	'CIVILIZATION_AMSTERDAM',		 1581	),
(	'CIVILIZATION_ANTANANARIVO',	 1625	),
(	'CIVILIZATION_ANTIOCH',			  -2400	),
(	'CIVILIZATION_ARMAGH',			 800	),
(	'CIVILIZATION_AUCKLAND',		1700	),
(	'CIVILIZATION_BABYLON',			 -3960	),
(	'CIVILIZATION_BOLOGNA',		 	-1200	),
(	'CIVILIZATION_BRUSSELS',		  -200	),
(	'CIVILIZATION_BUENOS_AIRES',	 1500	),
(	'CIVILIZATION_CAGUANA',			 600	),
(	'CIVILIZATION_CAHOKIA',			 400	),
(	'CIVILIZATION_CARDIFF',		 	-600	),
(	'CIVILIZATION_CARTHAGE',		 -2000	),
(	'CIVILIZATION_FEZ',		  		-600	),
(	'CIVILIZATION_GENEVA',			 -121	),
(	'CIVILIZATION_GRANADA',			 -600	),
(	'CIVILIZATION_HATTUSA',			-2000	),
(	'CIVILIZATION_HONG_KONG',		 -1000	),
(	'CIVILIZATION_JAKARTA',			  400	),
(	'CIVILIZATION_JERUSALEM',		-3960	),
(	'CIVILIZATION_KABUL',			 -3400	),
(	'CIVILIZATION_KANDY',			 -1000	),
(	'CIVILIZATION_KUMASI',			 -1000	),
(	'CIVILIZATION_LAHORE',			-2500	),
(	'CIVILIZATION_LA_VENTA',		-2400	),
(	'CIVILIZATION_LISBON',			-800	),
(	'CIVILIZATION_MEXICO_CITY',		 1200	),
(	'CIVILIZATION_MOHENJO_DARO',	-3960	),
(	'CIVILIZATION_MUSCAT',			-3960	),
(	'CIVILIZATION_NAN_MADOL',		 1180	),
(	'CIVILIZATION_NAZCA',		 	-3000	),
(	'CIVILIZATION_NGAZARGAMU',		 -2400	),
(	'CIVILIZATION_PALENQUE',		-1600	),
(	'CIVILIZATION_PRESLAV',			  -1600	),
(	'CIVILIZATION_RAPA_NUI',			600	),
(	'CIVILIZATION_SEOUL',			  -1000	),
(	'CIVILIZATION_SINGAPORE',		  200	),
(	'CIVILIZATION_STOCKHOLM',		 -600	),
(	'CIVILIZATION_TARUGA',		 	-1200	),
(	'CIVILIZATION_TORONTO',			 1600	),
(	'CIVILIZATION_VALLETTA',		 -600	),
(	'CIVILIZATION_VATICAN_CITY',	 400	),
(	'CIVILIZATION_VILNIUS',			 800	),
(	'CIVILIZATION_YEREVAN',			-2400	),
(	'CIVILIZATION_ZANZIBAR',		 600	),
--Babylon DLC City States
(	'CIVILIZATION_AYUTTHAYA',		 600	),	
(	'CIVILIZATION_CHINGUETTI',		 -2000	),	
(	'CIVILIZATION_JOHANNESBURG',	1880	),
(	'CIVILIZATION_NALANDA',		 	-600	),
(	'CIVILIZATION_SAMARKAND',		 -800	),
(	'CIVILIZATION_WOLIN',		 		800	),
(	'CIVILIZATION_HUNZA',		 		150	),
(	'END_OF_INSERT',				NULL	);	
-- Remove "END_OF_INSERT" entry 
DELETE from HistoricalSpawnDates_TrueHSD WHERE Civilization ='END_OF_INSERT';

--End