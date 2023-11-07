-- ===========================================================================
--	Historical Victory Data
-- ===========================================================================
print("Loading HistoricalVictory_Data.lua")

-- Insert Civilizations or Leaders into this table for custom historical victories
-- Civs or Leaders not in this table will use the generic conditions
-- This table tracks the index and objective count for each challenge, to be used to generate text and check properties
HSD_Victory_civilizationData = {
    ["CIVILIZATION_ROME"] = 
		{ 
			{ victory = 1, objectives = 3 },
			{ victory = 2, objectives = 2 },
			{ victory = 3, objectives = 1 },
		},
	["CIVILIZATION_EGYPT"] = {
			{ victory = 1, objectives = 3 },
			{ victory = 2, objectives = 3 },
			{ victory = 3, objectives = 3 },
	},
	["CIVILIZATION_BRAZIL"] = {
			{ victory = 1, objectives = 1 },
			{ victory = 2, objectives = 1 }
	},
    ["LEADER_JULIUS_CAESAR"] = 
		{ 
			{ victory = 1, objectives = 1 },
			{ victory = 2, objectives = 1 },
			{ victory = 3, objectives = 1 },
	}
}