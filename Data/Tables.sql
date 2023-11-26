-----------------------------------------------
-- Create Tables
-----------------------------------------------

CREATE TABLE IF NOT EXISTS HistoricalSpawnDates
	 (	Civilization TEXT NOT NULL UNIQUE,
		StartYear INTEGER DEFAULT -10000);
		
CREATE TABLE IF NOT EXISTS HistoricalSpawnDates_TrueHSD
	 (	Civilization TEXT NOT NULL UNIQUE,
		StartYear INTEGER DEFAULT -10000);
		
CREATE TABLE IF NOT EXISTS HistoricalSpawnDates_LeaderHSD
	 (	Civilization TEXT NOT NULL UNIQUE,
		StartYear INTEGER DEFAULT -10000);
		
CREATE TABLE IF NOT EXISTS HistoricalSpawnDates_LiteMode
	 (	Civilization TEXT NOT NULL UNIQUE,
		StartYear INTEGER DEFAULT -10000);
		
CREATE TABLE IF NOT EXISTS HistoricalSpawnEras
	 (	Civilization TEXT NOT NULL UNIQUE,
		Era INTEGER DEFAULT 0);
		
CREATE TABLE IF NOT EXISTS HistoricalSpawnEras_LiteMode
	 (	Civilization TEXT NOT NULL UNIQUE,
		Era INTEGER DEFAULT 0);

CREATE TABLE IF NOT EXISTS IsolatedCivs
	 (	Civilization TEXT NOT NULL UNIQUE);
	 
CREATE TABLE IF NOT EXISTS ColonialCivs
	 (	Civilization TEXT NOT NULL UNIQUE);
	 
CREATE TABLE IF NOT EXISTS ColonizerCivs
	 (	Civilization TEXT NOT NULL UNIQUE);
	 
CREATE TABLE IF NOT EXISTS RestrictedSpawns
	 (	Civilization TEXT NOT NULL UNIQUE);
	 
CREATE TABLE IF NOT EXISTS PeacefulSpawns
	 (	Civilization TEXT NOT NULL UNIQUE);
	 
CREATE TABLE IF NOT EXISTS UniqueSpawnZones
	 (	Civilization TEXT NOT NULL UNIQUE);
	 
CREATE TABLE IF NOT EXISTS CivilizationVictories (
    Civilization TEXT,
	Leader TEXT,
    VictoryName TEXT,
    VictoryDescription TEXT
);
