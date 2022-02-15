/*
	Historical Spawn Dates
	by Gedemon (2017)
	
*/

INSERT OR REPLACE INTO GlobalParameters (Name, Value) VALUES ('HSD_VERSION', '1.3.1');

/* Obselete code, leaving for posterity or in case it needs to be used again */

-- DELETE FROM MajorStartingUnits WHERE Unit="UNIT_SETTLER";
-- UPDATE StartingBuildings SET Era="ERA_CLASSICAL" WHERE Building="BUILDING_WALLS";
-- UPDATE StartingBuildings SET Era="ERA_MEDIEVAL" WHERE Building="BUILDING_GRANARY";

-------------------------------------------------------------------------------
--	Optional remove envoy from first encounter with city-state
--	To prevent early Civs from receiving too many bonuses 
--	Uncomment below to activate
-------------------------------------------------------------------------------

-- UPDATE GlobalParameters SET Value = 0 WHERE Name ='INFLUENCE_TOKENS_FREE_FOR_FIRST_PLAYER_MEET';

-------------------------------------------------------------------------------.
--	HSD_SettlerEra
--
--	Settlers are spawned for new civilizations AFTER this era
-- 	0 - Ancient Era
-- 	1 - Classical Era
-- 	2 - Medieval Era
-- 	3 - Renaissance Era
-- 	4 - Industrial Era
-- 	5 - Modern Era
-- 	6 - Atomic Era
-- 	7 - Digital Era
-- 	8 - Future Era
-------------------------------------------------------------------------------

INSERT OR REPLACE INTO GlobalParameters (Name, Value) VALUES ('HSD_SettlerEra', '1');

-------------------------------------------------------------------------------
--	Super Monument 
-------------------------------------------------------------------------------
--	Adds bonus loyalty to new Civs
INSERT INTO BuildingModifiers	(BuildingType,	ModifierId)
VALUES	('BUILDING_SUPER_MONUMENT',		'SUPER_MONUMENT_LOYALTY');

INSERT INTO Modifiers			(ModifierId,	ModifierType)
VALUES	('SUPER_MONUMENT_LOYALTY',	'MODIFIER_PLAYER_CITIES_ADJUST_IDENTITY_PER_CITIZEN');

INSERT INTO ModifierArguments	(ModifierId,	Name,	Value)
VALUES	('SUPER_MONUMENT_LOYALTY',	'Amount',	'2');

-- Adds production boost to districts
INSERT INTO BuildingModifiers	(BuildingType,	ModifierId)
VALUES	('BUILDING_SUPER_MONUMENT',		'SUPER_MONUMENT_DISTRICTS');

INSERT INTO Modifiers			(ModifierId,	ModifierType)
VALUES	('SUPER_MONUMENT_DISTRICTS',	'MODIFIER_ALL_CITIES_ATTACH_MODIFIER'),
		('SUPER_MONUMENT_DISTRICTS_MODIFIER', 'MODIFIER_SINGLE_CITY_ADJUST_DISTRICT_PRODUCTION_MODIFIER');

INSERT INTO ModifierArguments	(ModifierId,	Name,	Value)
VALUES	('SUPER_MONUMENT_DISTRICTS',	'ModifierId',	'SUPER_MONUMENT_DISTRICTS_MODIFIER'),
		('SUPER_MONUMENT_DISTRICTS_MODIFIER',	'Amount',	'50');
		
-- Adds production boost to traders
INSERT INTO BuildingModifiers	(BuildingType,	ModifierId)
VALUES	('BUILDING_SUPER_MONUMENT',		'SUPER_MONUMENT_TRADERS');

INSERT INTO Modifiers			(ModifierId,	ModifierType)
VALUES	('SUPER_MONUMENT_TRADERS',	'MODIFIER_PLAYER_UNITS_ADJUST_UNIT_PRODUCTION');

INSERT INTO ModifierArguments	(ModifierId,	Name,	Value)
VALUES	('SUPER_MONUMENT_TRADERS',	'UnitType',	'UNIT_TRADER'),
		('SUPER_MONUMENT_TRADERS',	'Amount',	'50');

-------------------------------------------------------------------------------
-- Barbarian Traits
-- Not currently enabled. Gives barbarians Lautaro's loyalty sapping ability. Requires Rise and Fall
-------------------------------------------------------------------------------
-- INSERT INTO CivilizationTraits	(CivilizationType, TraitType)
-- VALUES	('CIVILIZATION_BARBARIAN',		'TRAIT_LEADER_LAUTARO_ABILITY');