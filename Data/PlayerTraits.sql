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
-- Major Civilizations on the colonials list will receive the Colonial trait
-- WARNING: These values are included in the game database and used by game core functions,
-- compatibility checks are necessary for players without Expansion or DLC content, or for modded civilizations
-------------------------------------------------------------------------------

INSERT OR REPLACE INTO CivilizationTraits	(CivilizationType, TraitType)
	SELECT Civilization, 'TRAIT_LEADER_COLONIAL'
	FROM ColonialCivs WHERE EXISTS (SELECT * FROM Civilizations WHERE ColonialCivs.Civilization = Civilizations.CivilizationType AND StartingCivilizationLevelType = 'CIVILIZATION_LEVEL_FULL_CIV');

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
-- Major Civilizations on the isolated list will receive the Isolated trait
-- WARNING: These values are included in the game database and used by game core functions,
-- compatibility checks are necessary for players without Expansion or DLC content
-------------------------------------------------------------------------------

INSERT OR REPLACE INTO CivilizationTraits	(CivilizationType, TraitType)
	SELECT Civilization, 'TRAIT_LEADER_ISOLATED'
	FROM IsolatedCivs WHERE EXISTS (SELECT * FROM Civilizations WHERE IsolatedCivs.Civilization = Civilizations.CivilizationType AND StartingCivilizationLevelType = 'CIVILIZATION_LEVEL_FULL_CIV');