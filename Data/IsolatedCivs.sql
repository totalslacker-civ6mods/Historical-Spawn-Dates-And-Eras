-------------------------------------------------------------------------------
-- Civilizations that don't receive start bonuses (Isolated civs)
-- The necessary matching LeaderTraits are assigned below
--
-- Note: This list is only used by this mod to detect if the listed Civilization is in the game,
-- it is not used by game core functions, so it is safe to include Expansion and DLC content
-- without special checks for compatibility.
--
-- You can insert modded civilizations here too. The last line must end with a semicolon ( ; ) 
-------------------------------------------------------------------------------
INSERT OR REPLACE INTO IsolatedCivs (Civilization) 
VALUES
		('CIVILIZATION_AZTEC'),
		('CIVILIZATION_INCA'),
		('CIVILIZATION_MAORI'),
		('CIVILIZATION_MAPUCHE'),
		('CIVILIZATION_MAYA'),
		('CIVILIZATION_CREE'),
		--City states (do not receive bonus but are counted in Lite Mode)
		('CIVILIZATION_ANTANANARIVO'),
		('CIVILIZATION_CAGUANA'),
		('CIVILIZATION_CAHOKIA'),
		('CIVILIZATION_HUNZA'),
		('CIVILIZATION_LA_VENTA'),
		('CIVILIZATION_NAN_MADOL'),
		('CIVILIZATION_NAZCA'),
		('CIVILIZATION_PALENQUE'),
		('CIVILIZATION_RAPA_NUI');

-------------------------------------------------------------------------------
-- Civilizations that receive an Era Building that provides bonus yields in every new city (Colonial Civs)
-- The necessary matching LeaderTraits are assigned below
-- These civilizations will also start the game with Democracy government unlocked 
-- (this is done via a function in ScriptHSD.lua, not a modifier, but it uses this list)
--
-- Note: This list is only used by this mod to detect if the listed Civilization is in the game,
-- it is not used by game core functions, so it is safe to include Expansion and DLC content
-- without special checks for compatibility
--
-- You can insert modded civilizations here too. The last line must end with a semicolon ( ; ) 
-------------------------------------------------------------------------------
INSERT OR REPLACE INTO ColonialCivs (Civilization) 
VALUES
		('CIVILIZATION_AMERICA'),
		('CIVILIZATION_AUSTRALIA'),
		('CIVILIZATION_BRAZIL'),
		('CIVILIZATION_CANADA'),
		('CIVILIZATION_GRAN_COLOMBIA'),
		--City states (do not receive bonus but are counted in Lite Mode)
		('CIVILIZATION_BUENOS_AIRES'),
		('CIVILIZATION_JOHANNESBURG');

-------------------------------------------------------------------------------
-- Colonizers (Civs in this list will participate in Colonization mode)
-------------------------------------------------------------------------------
INSERT OR REPLACE INTO ColonizerCivs (Civilization) 
VALUES
		('CIVILIZATION_ENGLAND'),
		('CIVILIZATION_FRANCE'),
		('CIVILIZATION_GERMANY'),
		('CIVILIZATION_NETHERLANDS'),
		('CIVILIZATION_PORTUGAL'),
		('CIVILIZATION_SCOTLAND'),
		('CIVILIZATION_SPAIN');
		
-------------------------------------------------------------------------------
-- Restricted Spawn Range (Civs in this list will only flip their capital city, use for small Civs like Netherlands)
-------------------------------------------------------------------------------
INSERT OR REPLACE INTO RestrictedSpawns (Civilization) 
VALUES
		('CIVILIZATION_KOREA'),
		('CIVILIZATION_NETHERLANDS'),
		('CIVILIZATION_PORTUGAL'),
		('CIVILIZATION_GEORGIA');
		
-------------------------------------------------------------------------------
-- Peaceful Spawns (Civs in this list can convert cities but will never declare war)
-------------------------------------------------------------------------------
INSERT OR REPLACE INTO PeacefulSpawns (Civilization) 
VALUES
		('CIVILIZATION_AUSTRALIA'),
		('CIVILIZATION_NETHERLANDS'),
		('CIVILIZATION_PORTUGAL'),
		('CIVILIZATION_CANADA');
		
-------------------------------------------------------------------------------
-- Unique Spawn Zones (Civs in this list must have a unique spawn zone defined in function GetUniqueSpawnZone)
-------------------------------------------------------------------------------
INSERT OR REPLACE INTO UniqueSpawnZones (Civilization) 
VALUES
		('CIVILIZATION_AUSTRALIA'),
		('CIVILIZATION_CANADA');