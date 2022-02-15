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
		('CIVILIZATION_CREE');

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
INSERT OR REPLACE INTO EraBuildingCivs (Civilization) 
VALUES
		('CIVILIZATION_AMERICA'),
		('CIVILIZATION_AUSTRALIA'),
		('CIVILIZATION_BRAZIL'),
		('CIVILIZATION_CANADA'),
		('CIVILIZATION_GRAN_COLOMBIA');

-------------------------------------------------------------------------------
-- Colonial Civilization Modifier (copy of the Grand Embassy modifier with a different description)
-- Do not make changes here unless you fully understand the modifier system
-------------------------------------------------------------------------------
INSERT INTO Types	(Type, Kind)
VALUES	('TRAIT_LEADER_COLONIAL',	'KIND_TRAIT');

INSERT INTO Traits	(TraitType, Name, Description)
VALUES	('TRAIT_LEADER_COLONIAL',	'LOC_TRAIT_LEADER_COLONIAL',	'LOC_TRAIT_LEADER_COLONIAL_DESC');

INSERT INTO TraitModifiers		(TraitType,		ModifierId)
VALUES	('TRAIT_LEADER_COLONIAL',	'TRAIT_ADJUST_PROGRESS_COLONIAL_CIV');

INSERT INTO Modifiers			(ModifierId,	ModifierType)
VALUES	('TRAIT_ADJUST_PROGRESS_COLONIAL_CIV',	'MODIFIER_PLAYER_ADJUST_PROGRESS_DIFF_TRADE_BONUS');

INSERT INTO ModifierArguments	(ModifierId,	Name,	Value)
VALUES	('TRAIT_ADJUST_PROGRESS_COLONIAL_CIV',	'TechCivicsPerYield',	'3');

-------------------------------------------------------------------------------
-- Civilizations that receive the Colonial trait
-- WARNING: These values are included in the game database and used by game core functions,
-- compatibility checks are necessary for players without Expansion or DLC content, or for modded civilizations
-------------------------------------------------------------------------------
/* INSERT OR REPLACE INTO LeaderTraits		(LeaderType, TraitType)
VALUES
		('LEADER_T_ROOSEVELT', 		'TRAIT_LEADER_COLONIAL'),
		('LEADER_PEDRO',			'TRAIT_LEADER_COLONIAL');
		
INSERT OR REPLACE INTO LeaderTraits 	(LeaderType, TraitType)
SELECT ('LEADER_JOHN_CURTIN'), ('TRAIT_LEADER_COLONIAL')
WHERE EXISTS (SELECT * FROM Leaders WHERE LeaderType =  'LEADER_JOHN_CURTIN');

INSERT OR REPLACE INTO LeaderTraits 	(LeaderType, TraitType)
SELECT ('LEADER_LAURIER'), ('TRAIT_LEADER_COLONIAL')
WHERE EXISTS (SELECT * FROM Leaders WHERE LeaderType =  'LEADER_LAURIER');

INSERT OR REPLACE INTO LeaderTraits 	(LeaderType, TraitType)
SELECT ('LEADER_SIMON_BOLIVAR'), ('TRAIT_LEADER_COLONIAL')
WHERE EXISTS (SELECT * FROM Leaders WHERE LeaderType =  'LEADER_SIMON_BOLIVAR'); */

INSERT OR REPLACE INTO CivilizationTraits		(CivilizationType, TraitType)
VALUES
		('CIVILIZATION_AMERICA', 		'TRAIT_LEADER_COLONIAL'),
		('CIVILIZATION_BRAZIL',			'TRAIT_LEADER_COLONIAL');
		
INSERT OR REPLACE INTO CivilizationTraits 	(CivilizationType, TraitType)
SELECT ('CIVILIZATION_AUSTRALIA'), ('TRAIT_LEADER_COLONIAL')
WHERE EXISTS (SELECT * FROM Civilizations WHERE CivilizationType =  'CIVILIZATION_AUSTRALIA');

INSERT OR REPLACE INTO CivilizationTraits 	(CivilizationType, TraitType)
SELECT ('CIVILIZATION_CANADA'), ('TRAIT_LEADER_COLONIAL')
WHERE EXISTS (SELECT * FROM Civilizations WHERE CivilizationType =  'CIVILIZATION_CANADA');

INSERT OR REPLACE INTO CivilizationTraits 	(CivilizationType, TraitType)
SELECT ('CIVILIZATION_GRAN_COLOMBIA'), ('TRAIT_LEADER_COLONIAL')
WHERE EXISTS (SELECT * FROM Civilizations WHERE CivilizationType =  'CIVILIZATION_GRAN_COLOMBIA');

-------------------------------------------------------------------------------
-- Isolated Civilization Modifier (more powerful Grand Embassy - 1 Tech/Civic per Yield instead of 3)
-- Do not make changes here unless you fully understand the modifier system
-------------------------------------------------------------------------------
INSERT INTO Types	(Type, Kind)
VALUES	('TRAIT_LEADER_ISOLATED',	'KIND_TRAIT');

INSERT INTO Traits	(TraitType, Name, Description)
VALUES	('TRAIT_LEADER_ISOLATED',	'LOC_TRAIT_LEADER_ISOLATED',	'LOC_TRAIT_LEADER_ISOLATED_DESC');

INSERT INTO TraitModifiers		(TraitType,		ModifierId)
VALUES	('TRAIT_LEADER_ISOLATED',	'TRAIT_ADJUST_PROGRESS_ISOLATED_CIV');

INSERT INTO Modifiers			(ModifierId,	ModifierType)
VALUES	('TRAIT_ADJUST_PROGRESS_ISOLATED_CIV',	'MODIFIER_PLAYER_ADJUST_PROGRESS_DIFF_TRADE_BONUS');

INSERT INTO ModifierArguments	(ModifierId,	Name,	Value)
VALUES	('TRAIT_ADJUST_PROGRESS_ISOLATED_CIV',	'TechCivicsPerYield',	'1');

-------------------------------------------------------------------------------
-- Civilizations that receive the Isolated trait
-- WARNING: These values are included in the game database and used by game core functions,
-- compatibility checks are necessary for players without Expansion or DLC content
-------------------------------------------------------------------------------
/* INSERT OR REPLACE INTO LeaderTraits 	(LeaderType, TraitType)
SELECT ('LEADER_MONTEZUMA'), ('TRAIT_LEADER_ISOLATED')
WHERE EXISTS (SELECT * FROM Leaders WHERE LeaderType =  'LEADER_MONTEZUMA');

INSERT OR REPLACE INTO LeaderTraits 	(LeaderType, TraitType)
SELECT ('LEADER_KUPE'), ('TRAIT_LEADER_ISOLATED')
WHERE EXISTS (SELECT * FROM Leaders WHERE LeaderType =  'LEADER_KUPE');

INSERT OR REPLACE INTO LeaderTraits 	(LeaderType, TraitType)
SELECT ('LEADER_LAUTARO'), ('TRAIT_LEADER_ISOLATED')
WHERE EXISTS (SELECT * FROM Leaders WHERE LeaderType =  'LEADER_LAUTARO');

INSERT OR REPLACE INTO LeaderTraits 	(LeaderType, TraitType)
SELECT ('LEADER_LADY_SIX_SKY'), ('TRAIT_LEADER_ISOLATED')
WHERE EXISTS (SELECT * FROM Leaders WHERE LeaderType =  'LEADER_LADY_SIX_SKY');

INSERT OR REPLACE INTO LeaderTraits 	(LeaderType, TraitType)
SELECT ('LEADER_PACHACUTI'), ('TRAIT_LEADER_ISOLATED')
WHERE EXISTS (SELECT * FROM Leaders WHERE LeaderType =  'LEADER_PACHACUTI');

INSERT OR REPLACE INTO LeaderTraits 	(LeaderType, TraitType)
SELECT ('LEADER_POUNDMAKER'), ('TRAIT_LEADER_ISOLATED')
WHERE EXISTS (SELECT * FROM Leaders WHERE LeaderType =  'LEADER_POUNDMAKER'); */

INSERT OR REPLACE INTO CivilizationTraits 	(CivilizationType, TraitType)
SELECT ('CIVILIZATION_AZTEC'), ('TRAIT_LEADER_ISOLATED')
WHERE EXISTS (SELECT * FROM Civilizations WHERE CivilizationType =  'CIVILIZATION_AZTEC');

INSERT OR REPLACE INTO CivilizationTraits 	(CivilizationType, TraitType)
SELECT ('CIVILIZATION_MAORI'), ('TRAIT_LEADER_ISOLATED')
WHERE EXISTS (SELECT * FROM Civilizations WHERE CivilizationType =  'CIVILIZATION_MAORI');

INSERT OR REPLACE INTO CivilizationTraits 	(CivilizationType, TraitType)
SELECT ('CIVILIZATION_MAPUCHE'), ('TRAIT_LEADER_ISOLATED')
WHERE EXISTS (SELECT * FROM Civilizations WHERE CivilizationType =  'CIVILIZATION_MAPUCHE');

INSERT OR REPLACE INTO CivilizationTraits 	(CivilizationType, TraitType)
SELECT ('CIVILIZATION_MAYA'), ('TRAIT_LEADER_ISOLATED')
WHERE EXISTS (SELECT * FROM Civilizations WHERE CivilizationType =  'CIVILIZATION_MAYA');

INSERT OR REPLACE INTO CivilizationTraits 	(CivilizationType, TraitType)
SELECT ('CIVILIZATION_INCA'), ('TRAIT_LEADER_ISOLATED')
WHERE EXISTS (SELECT * FROM Civilizations WHERE CivilizationType =  'CIVILIZATION_INCA');

INSERT OR REPLACE INTO CivilizationTraits 	(CivilizationType, TraitType)
SELECT ('CIVILIZATION_CREE'), ('TRAIT_LEADER_ISOLATED')
WHERE EXISTS (SELECT * FROM Civilizations WHERE CivilizationType =  'CIVILIZATION_CREE');

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
		('CIVILIZATION_NETHERLANDS'),
		('CIVILIZATION_PORTUGAL');
		
-------------------------------------------------------------------------------
-- Peaceful Spawns (Civs in this list can convert cities but will never declare war)
-------------------------------------------------------------------------------
INSERT OR REPLACE INTO PeacefulSpawns (Civilization) 
VALUES
		('CIVILIZATION_AUSTRALIA'),
		('CIVILIZATION_CANADA');
		
-------------------------------------------------------------------------------
-- Unique Spawn Zones (Civs in this list must have a unique spawn zone defined in function GetUniqueSpawnZone)
-------------------------------------------------------------------------------
INSERT OR REPLACE INTO UniqueSpawnZones (Civilization) 
VALUES
		('CIVILIZATION_AUSTRALIA'),
		('CIVILIZATION_CANADA');