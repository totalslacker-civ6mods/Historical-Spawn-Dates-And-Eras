-- Add default starting dates to timeline for missing players

INSERT OR REPLACE INTO HistoricalSpawnDates_TrueHSD (StartYear, Civilization)
	SELECT '-4100', LeaderType
	FROM CivilizationLeaders WHERE EXISTS (SELECT * FROM Civilizations WHERE CivilizationLeaders.CivilizationType = Civilizations.CivilizationType AND StartingCivilizationLevelType = 'CIVILIZATION_LEVEL_FULL_CIV') AND NOT EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType) AND NOT EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = LeaderType);
	
INSERT OR REPLACE INTO HistoricalSpawnDates_TrueHSD (StartYear, Civilization)
	SELECT '-4100', LeaderType
	FROM CivilizationLeaders WHERE EXISTS (SELECT * FROM Civilizations WHERE CivilizationLeaders.CivilizationType = Civilizations.CivilizationType AND StartingCivilizationLevelType = 'CIVILIZATION_LEVEL_CITY_STATE') AND NOT EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType) AND NOT EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = LeaderType);

-- Civilizations

INSERT OR REPLACE INTO Types (Type, Kind)
	SELECT	'TRAIT_HSD' || '_' || LeaderType, 'KIND_TRAIT'
	FROM Leaders WHERE InheritFrom='LEADER_DEFAULT';
	
INSERT OR REPLACE INTO Traits (TraitType, Name, Description)
	SELECT	'TRAIT_HSD' || '_' || LeaderType, 'LOC_HSD_NAME', (SELECT StartYear FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = LeaderType)
	FROM Leaders WHERE InheritFrom='LEADER_DEFAULT' AND EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = LeaderType);
	
INSERT OR REPLACE INTO Traits (TraitType, Name, Description)
	SELECT	'TRAIT_HSD' || '_' || LeaderType, 'LOC_HSD_NAME', (SELECT StartYear FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType)
	FROM CivilizationLeaders WHERE EXISTS (SELECT * FROM Civilizations WHERE CivilizationLeaders.CivilizationType = Civilizations.CivilizationType AND StartingCivilizationLevelType = 'CIVILIZATION_LEVEL_FULL_CIV') AND EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType) AND NOT EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = LeaderType);
	
INSERT OR REPLACE INTO LeaderTraits	(LeaderType, TraitType)
	SELECT	LeaderType, 'TRAIT_HSD' || '_' || LeaderType
	FROM Leaders WHERE InheritFrom='LEADER_DEFAULT' AND EXISTS (SELECT * FROM Traits WHERE TraitType = 'TRAIT_HSD' || '_' || LeaderType);
	
-- City States

INSERT OR REPLACE INTO Types (Type, Kind)
	SELECT	'TRAIT_HSD' || '_' || LeaderType, 'KIND_TRAIT'
	FROM Leaders WHERE InheritFrom IN ('LEADER_MINOR_CIV_CULTURAL', 'LEADER_MINOR_CIV_INDUSTRIAL', 'LEADER_MINOR_CIV_MILITARISTIC', 'LEADER_MINOR_CIV_RELIGIOUS', 'LEADER_MINOR_CIV_SCIENTIFIC', 'LEADER_MINOR_CIV_TRADE');
	
INSERT OR REPLACE INTO Traits (TraitType, Name, Description)
	SELECT	'TRAIT_HSD' || '_' || LeaderType, 'LOC_HSD_NAME', (SELECT StartYear FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = LeaderType)
	FROM Leaders WHERE InheritFrom IN ('LEADER_MINOR_CIV_CULTURAL', 'LEADER_MINOR_CIV_INDUSTRIAL', 'LEADER_MINOR_CIV_MILITARISTIC', 'LEADER_MINOR_CIV_RELIGIOUS', 'LEADER_MINOR_CIV_SCIENTIFIC', 'LEADER_MINOR_CIV_TRADE') AND EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = LeaderType);
	
INSERT OR REPLACE INTO Traits (TraitType, Name, Description)
	SELECT	'TRAIT_HSD' || '_' || LeaderType, 'LOC_HSD_NAME', (SELECT StartYear FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType)
	FROM CivilizationLeaders WHERE EXISTS (SELECT * FROM Civilizations WHERE CivilizationLeaders.CivilizationType = Civilizations.CivilizationType AND StartingCivilizationLevelType = 'CIVILIZATION_LEVEL_CITY_STATE') AND EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = CivilizationType) AND NOT EXISTS (SELECT * FROM HistoricalSpawnDates_TrueHSD WHERE Civilization = LeaderType);
	
INSERT OR REPLACE INTO LeaderTraits	(LeaderType, TraitType)
	SELECT	LeaderType, 'TRAIT_HSD' || '_' || LeaderType
	FROM Leaders WHERE InheritFrom IN ('LEADER_MINOR_CIV_CULTURAL', 'LEADER_MINOR_CIV_INDUSTRIAL', 'LEADER_MINOR_CIV_MILITARISTIC', 'LEADER_MINOR_CIV_RELIGIOUS', 'LEADER_MINOR_CIV_SCIENTIFIC', 'LEADER_MINOR_CIV_TRADE') AND EXISTS (SELECT * FROM Traits WHERE TraitType = 'TRAIT_HSD' || '_' || LeaderType);