-- Create Leader Start Date list <Row ParameterId="InputHSD" Name="LOC_HSD_INPUT_NAME" Description=""	Domain="bool" 	DefaultValue="0" 	ConfigurationGroup="Map" 	ConfigurationId="InputHSD" 	GroupId="AdvancedOptions" 	SortIndex="311"/>
	
INSERT OR REPLACE INTO Parameters (ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
	SELECT	'HSD' || '_' || LeaderType, LeaderName, CivilizationName, 'text', 0, 'Map', 'HSD' || '_' || LeaderType, 'AdvancedOptions', 315
	FROM Players WHERE Domain='Players:Expansion2_Players';
	
INSERT OR REPLACE INTO Parameters (ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
	SELECT	'HSD' || '_' || CivilizationType, Name, Name, 'text', 0, 'Map', 'HSD' || '_' || CivilizationType, 'AdvancedOptions', 316
	FROM CityStates WHERE Domain='Expansion2CityStates';

INSERT OR REPLACE INTO ParameterDependencies (ParameterId, ConfigurationGroup, ConfigurationId, Operator, ConfigurationValue)
	SELECT	'HSD' || '_' || LeaderType, 'Map', 'InputHSD', 'Equals', '1'
	FROM Players WHERE Domain='Players:Expansion2_Players';
	
INSERT OR REPLACE INTO ParameterDependencies (ParameterId, ConfigurationGroup, ConfigurationId, Operator, ConfigurationValue)
	SELECT	'HSD' || '_' || CivilizationType, 'Map', 'InputHSD', 'Equals', '1'
	FROM CityStates WHERE Domain='Expansion2CityStates';
	
UPDATE Parameters SET DefaultValue = (SELECT StartYear FROM HistoricalSpawnDates WHERE Civilization = ParameterId) WHERE ParameterId = (SELECT Civilization FROM HistoricalSpawnDates WHERE Civilization = ParameterId);
	
-- INSERT OR REPLACE INTO ParameterDependencies (ParameterId, ConfigurationGroup, ConfigurationId, Operator, ConfigurationValue)
	-- SELECT	'HSD' || Domain || LeaderType, 'Map', 'RULESET', 'Equals', 'RULESET_STANDARD'
	-- FROM Players WHERE Domain='Players:StandardPlayers';
	
-- INSERT OR REPLACE INTO ParameterDependencies (ParameterId, ConfigurationGroup, ConfigurationId, Operator, ConfigurationValue)
	-- SELECT	'HSD' || Domain || LeaderType, 'Map', 'RULESET', 'Equals', 'RULESET_EXPANSION_1'
	-- FROM Players WHERE Domain='Players:Expansion1_Players';
	
-- INSERT OR REPLACE INTO ParameterDependencies (ParameterId, ConfigurationGroup, ConfigurationId, Operator, ConfigurationValue)
	-- SELECT	'HSD' || Domain || LeaderType, 'Map', 'RULESET', 'Equals', 'RULESET_EXPANSION_2'
	-- FROM Players WHERE Domain='Players:Expansion2_Players';