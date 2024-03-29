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
(	'CIVILIZATION_CREE',			1300	),
(	'CIVILIZATION_ENGLAND',			 900	),
(	'CIVILIZATION_EGYPT',			-3200	),
(	'CIVILIZATION_ETHIOPIA',		-500	),
(	'CIVILIZATION_FRANCE',			481 	),
(	'CIVILIZATION_GAUL',			-1200	),
(	'CIVILIZATION_GEORGIA',			800		),
(	'CIVILIZATION_GERMANY',			936		),
(	'CIVILIZATION_GRAN_COLOMBIA',	1819	),
(	'CIVILIZATION_GREECE',			-1600	),
(	'CIVILIZATION_HUNGARY',			   895	),
(	'CIVILIZATION_INCA',			  -750	),
(	'CIVILIZATION_INDIA',			-2500	),
(	'CIVILIZATION_INDONESIA',		 1000	),
(	'CIVILIZATION_JAPAN',			 500	),
(	'CIVILIZATION_KHMER',			800		),
(	'CIVILIZATION_KONGO',			 1375	),
(	'CIVILIZATION_KOREA',			  -200	),
(	'CIVILIZATION_MAPUCHE',			-400	),
(	'CIVILIZATION_MAYA',			250		),
(	'CIVILIZATION_MACEDON',			  -600	),
(	'CIVILIZATION_MALI',			  800	),
(	'CIVILIZATION_MAORI',		 	1200	),
(	'CIVILIZATION_MONGOLIA',		1162	),
(	'CIVILIZATION_NETHERLANDS',		 1559	),
(	'CIVILIZATION_NORWAY',			 700	),
(	'CIVILIZATION_NUBIA',			-2400	),
(	'CIVILIZATION_OTTOMAN',			 1200	),
(	'CIVILIZATION_PERSIA',			-678	),
(	'CIVILIZATION_PHOENICIA',		  -814	),
(	'CIVILIZATION_POLAND',			  966	),
(	'CIVILIZATION_PORTUGAL',			868 ),
(	'CIVILIZATION_ROME',			 -753	),
(	'CIVILIZATION_RUSSIA',			  1263	),
(	'CIVILIZATION_SCOTLAND',		843		),
(	'CIVILIZATION_SCYTHIA',			 -800	),
(	'CIVILIZATION_SPAIN',			466		),
(	'CIVILIZATION_SUMERIA',			-4100	),
(	'CIVILIZATION_SWEDEN',			  700	),
(	'CIVILIZATION_VIETNAM',			  -1200	),
(	'CIVILIZATION_ZULU',			 1600	),
-- Minor Civilizations
(	'CIVILIZATION_AKKAD',			 -2334	),
(	'CIVILIZATION_AMSTERDAM',		 1581	),
(	'CIVILIZATION_ANTANANARIVO',	 1625	),
(	'CIVILIZATION_ANTIOCH',			  697	),
(	'CIVILIZATION_ARMAGH',			 800	),
(	'CIVILIZATION_AUCKLAND',		1840	),
(	'CIVILIZATION_AYUTTHAYA',		 1351	),	
(	'CIVILIZATION_BABYLON',			 -3960	),
(	'CIVILIZATION_BOLOGNA',		 	-510	),
(	'CIVILIZATION_BRUSSELS',		  979	),
(	'CIVILIZATION_BUENOS_AIRES',	 1816	),
(	'CIVILIZATION_CAGUANA',			 600	),
(	'CIVILIZATION_CAHOKIA',			 400	),
(	'CIVILIZATION_CARDIFF',		 	1081	),
(	'CIVILIZATION_CARTHAGE',		 -814	),
(	'CIVILIZATION_CHINGUETTI',		 777	),	
(	'CIVILIZATION_FEZ',		  		789		),
(	'CIVILIZATION_GENEVA',			 1536	),
(	'CIVILIZATION_GRANADA',			 1230	),
(	'CIVILIZATION_HATTUSA',			-2000	),
(	'CIVILIZATION_HONG_KONG',		 1840	),
(	'CIVILIZATION_HUNZA',		 		150	),
(	'CIVILIZATION_JAKARTA',			  800	),
(	'CIVILIZATION_JERUSALEM',		-3960	),
(	'CIVILIZATION_JOHANNESBURG',	1880	),
(	'CIVILIZATION_KABUL',			 -3400	),
(	'CIVILIZATION_KANDY',			 -1000	),
(	'CIVILIZATION_KUMASI',			 1695	),
(	'CIVILIZATION_LAHORE',			-2500	),
(	'CIVILIZATION_LA_VENTA',		-2400	),
(	'CIVILIZATION_LISBON',			-800	),
(	'CIVILIZATION_MEXICO_CITY',		 1200	),
(	'CIVILIZATION_MOHENJO_DARO',	-3960	),
(	'CIVILIZATION_MUSCAT',			-3960	),
(	'CIVILIZATION_NALANDA',		 	-600	),
(	'CIVILIZATION_NAN_MADOL',		 1180	),
(	'CIVILIZATION_NAZCA',		 	-100	),
(	'CIVILIZATION_NGAZARGAMU',		 1460	),
(	'CIVILIZATION_PALENQUE',		-300	),
(	'CIVILIZATION_PRESLAV',			  800	),
(	'CIVILIZATION_RAPA_NUI',			900	),
(	'CIVILIZATION_SAMARKAND',		 -800	),
(	'CIVILIZATION_SEOUL',			  -1000	),
(	'CIVILIZATION_SINGAPORE',		  1819	),
(	'CIVILIZATION_STOCKHOLM',		 1252	),
(	'CIVILIZATION_TARUGA',		 	-1200	),
(	'CIVILIZATION_TORONTO',			 1750	),
(	'CIVILIZATION_VALLETTA',		 1566	),
(	'CIVILIZATION_VATICAN_CITY',	 400	),
(	'CIVILIZATION_VILNIUS',			 1323	),
(	'CIVILIZATION_WOLIN',		 		800	),
(	'CIVILIZATION_YEREVAN',			-2400	),
(	'CIVILIZATION_ZANZIBAR',		 600	),

-- DO NOT DELETE OR EDIT THE LINES BELOW
(	'END_OF_INSERT',				NULL	);	
-- Remove "END_OF_INSERT" entry 
DELETE from HistoricalSpawnDates_TrueHSD WHERE Civilization ='END_OF_INSERT';

--End