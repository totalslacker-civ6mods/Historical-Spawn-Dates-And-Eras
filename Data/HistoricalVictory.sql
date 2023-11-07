-- Credit: Wonder Victory Mod by Luke ✞ Jesus Saves ✞

-- Kinds
INSERT INTO Types(Type, Kind) VALUES
	('BUILDING_HISTORICAL_VICTORY', 'KIND_BUILDING'),
    ('PROJECT_HISTORICAL_VICTORY', 'KIND_PROJECT'),
    ('HISTORICAL_VICTORY_MODIFIER_GRANT_PROJECT', 'KIND_MODIFIER'),
    ('VICTORY_HISTORICAL_VICTORY', 'KIND_VICTORY');

-- Historical Victory Building (unlocks project)
INSERT INTO Buildings (BuildingType, Name, Description, PrereqDistrict, ObsoleteEra, Cost) VALUES
	('BUILDING_HISTORICAL_VICTORY', 'LOC_BUILDING_HISTORICAL_VICTORY_NAME', 'LOC_BUILDING_HISTORICAL_VICTORY_DESC', 'DISTRICT_CITY_CENTER', 'ERA_ANCIENT', 1);

-- Historical Victory Project
INSERT INTO Projects(ProjectType, Name, ShortName, Description, Cost, CostProgressionModel, MaxPlayerInstances) VALUES
    ('PROJECT_HISTORICAL_VICTORY', 'LOC_PROJECT_HISTORICAL_VICTORY_NAME', 'LOC_PROJECT_HISTORICAL_VICTORY_NAME_SHORT', 'LOC_PROJECT_HISTORICAL_VICTORY_DESC', 50, 'NO_PROGRESSION_MODEL', 1);
INSERT INTO Projects_XP2(ProjectType, UnlocksFromEffect) VALUES
    ('PROJECT_HISTORICAL_VICTORY', 1);

---- Unlock victory project when the historical victory building is detected
INSERT INTO DynamicModifiers(ModifierType, CollectionType, EffectType) VALUES
    ('HISTORICAL_VICTORY_MODIFIER_GRANT_PROJECT', 'COLLECTION_OWNER', 'EFFECT_ADD_PLAYER_PROJECT_AVAILABILITY');

INSERT INTO Requirements(RequirementId, RequirementType)
    SELECT 'HISTORICAL_VICTORY_REQ_HAS_' || BuildingType, 'REQUIREMENT_PLAYER_HAS_BUILDING'
    FROM Buildings
    WHERE BuildingType='BUILDING_HISTORICAL_VICTORY';

INSERT INTO RequirementArguments(RequirementId, Name, Value)
    SELECT 'HISTORICAL_VICTORY_REQ_HAS_' || BuildingType, 'BuildingType', BuildingType
    FROM Buildings
    WHERE BuildingType='BUILDING_HISTORICAL_VICTORY';

INSERT INTO RequirementSets(RequirementSetId, RequirementSetType) VALUES
    ('HISTORICAL_VICTORY_ALL_WONDERS', 'REQUIREMENTSET_TEST_ALL');

INSERT INTO RequirementSetRequirements(RequirementSetId, RequirementId)
    SELECT 'HISTORICAL_VICTORY_ALL_WONDERS', 'HISTORICAL_VICTORY_REQ_HAS_' || BuildingType
    FROM Buildings WHERE BuildingType='BUILDING_HISTORICAL_VICTORY';

INSERT INTO Modifiers(ModifierId, ModifierType, SubjectRequirementSetId) VALUES
    ('MODIFIER_HISTORICAL_VICTORY_GRANT_PROJECT', 'HISTORICAL_VICTORY_MODIFIER_GRANT_PROJECT', 'HISTORICAL_VICTORY_ALL_WONDERS');
INSERT INTO ModifierArguments(ModifierId, Name, Value) VALUES
    ('MODIFIER_HISTORICAL_VICTORY_GRANT_PROJECT', 'ProjectType', 'PROJECT_HISTORICAL_VICTORY');

INSERT INTO TraitModifiers('TraitType', 'ModifierId') VALUES
    ('TRAIT_LEADER_MAJOR_CIV', 'MODIFIER_HISTORICAL_VICTORY_GRANT_PROJECT');

-- Victory
INSERT INTO Requirements(RequirementId, RequirementType) VALUES
    ('HISTORICAL_VICTORY_COMPLETED_PROJECT', 'REQUIREMENT_PLAYER_HAS_COMPLETED_PROJECT');
INSERT INTO RequirementArguments(RequirementId, Name, Value) VALUES
    ('HISTORICAL_VICTORY_COMPLETED_PROJECT', 'ProjectType', 'PROJECT_HISTORICAL_VICTORY');
INSERT INTO RequirementSets(RequirementSetId, RequirementSetType) VALUES
    ('HISTORICAL_VICTORY_VICTORY_REQS', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements(RequirementSetId, RequirementId) VALUES
    ('HISTORICAL_VICTORY_VICTORY_REQS', 'HISTORICAL_VICTORY_COMPLETED_PROJECT');

INSERT INTO Victories("VictoryType", "Name", "Blurb", "RequirementSetId", "CriticalPercentage") VALUES
    ('VICTORY_HISTORICAL_VICTORY', 'LOC_HISTORICAL_VICTORY_NAME', 'LOC_HISTORICAL_VICTORY_TEXT', 'HISTORICAL_VICTORY_VICTORY_REQS', 50);