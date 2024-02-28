-- 
type Teleport = {
	Type : string,
	Studs : number
}

-- SETTINGS --
local TeleportSettings : Teleport = {
	Type = "Above",
	Studs = 5
}


--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--
local LocalPlayer = Players.LocalPlayer

--
local RayfieldLibrary = loadstring(game:HttpGet('https://raw.githubusercontent.com/Lyxia1/LyxiaHub/main/UILIb.lua'))()




--
local function GetMobList()
	local MobList = {}

	for index, mob in pairs(workspace.MobSpawns:GetChildren()) do
		table.insert(MobList, mob.Name)
	end

	for index, mob in pairs(workspace.BossArenas:GetChildren()) do
		table.insert(MobList, mob.Name)
	end

	return MobList
end

local function GetQuestList()
	local QuestList = {}
	local QuestListModule = require(ReplicatedStorage.Systems.Quests.QuestList)

	for index, quest in QuestListModule do
		table.insert(QuestList, tostring(index))
	end

	return QuestList
end

local function GetCharacter()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function KillMob( Mob : Instance )
	local Event = game:GetService("ReplicatedStorage").Systems.Combat.PlayerAttack
	Event:FireServer(Mob)
end

local function ConvertSettingsToCFrame()
	if TeleportSettings.Type == "Bellow" then
		return CFrame.new(0, TeleportSettings.Studs * -1, 0)
	else
		return CFrame.new(0, TeleportSettings.Studs, 0)
	end
end

local function TeleportToMob( Mob : Instance)
	local Character = GetCharacter()

	if not Character then
		return
	end

	Character:PivotTo(Mob.CFrame * ConvertSettingsToCFrame())

end

local function TakeQuest( QuestNumber : string )
	local Event = game:GetService("ReplicatedStorage").Systems.Quests.AcceptQuest
	Event:FireServer(QuestNumber)
end




--
local Window = RayfieldLibrary:CreateWindow({
	Name = "Lyxia Hub",
	LoadingTitle = "Swordburst 3",
	LoadingSubtitle = "by Lyxia",
	ConfigurationSaving = {
		Enabled = false,
		FolderName = "LyxiaHub", -- Create a custom folder for your hub/game
		FileName = "Config"
	},
})

--
local AutofarmTab = Window:CreateTab("Autofarm", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

-- AutoFarm
local Section = AutofarmTab:CreateSection("Mob and Quest")
local QuestDropDown = AutofarmTab:CreateDropdown({
	Name = "Select Quest",
	Options = GetQuestList(),
	CurrentOption = {"None"},
	MultipleOptions = false,
	Flag = "QuestDropDown",
	Callback = function(Option)

	end,
})
local MobDropDown = AutofarmTab:CreateDropdown({
	Name = "Select Mob",
	Options = GetMobList(),
	CurrentOption = {"None"},
	MultipleOptions = true,
	Flag = "MobDropDown",
	Callback = function(Option)

	end,
})
local AutofarmToggle = AutofarmTab:CreateToggle({
	Name = "Autofarm",
	CurrentValue = false,
	Flag = "Autofarm",
	Callback = function(Value)

	end,
})
local AutoquestToggle = AutofarmTab:CreateToggle({
	Name = "AutoQuest",
	CurrentValue = false,
	Flag = "AutoQuest",
	Callback = function(Value)

	end,
})
local AutofarmStudsSlider = AutofarmTab:CreateSlider({
	Name = "Studs",
	Range = {1, 10},
	Increment = 1,
	CurrentValue = 10,
	Flag = "StudsSlider",
	Callback = function(Value)
		print(Value)
	end,
})
local AutofarmTypeDropdown =AutofarmTab:CreateDropdown({
	Name = "Type",
	Options = {"Above", "Bellow"},
	CurrentOption = {"Above"},
	MultipleOptions = false,
	Flag = "TypeDropDown",
	Callback = function(Option)

	end,
})

-- Kill Aura
local Section = AutofarmTab:CreateSection("Kill Aura")
local killauraToggle = AutofarmTab:CreateToggle({
	Name = "Kill Aura",
	CurrentValue = false,
	Flag = "KAToggle",
	Callback = function(Value)

	end,
})
local killauraDelaySlider = AutofarmTab:CreateSlider({
	Name = "Delay",
	Range = {0.2, 0.5},
	Increment = 0.01,
	CurrentValue = 0.5,
	Flag = "KADelay",
	Callback = function(Value)
		print(Value)
	end,
})

-- AutoCollect
local Section = AutofarmTab:CreateSection("AutoCollect")
local AutoCollectToggle = AutofarmTab:CreateToggle({
	Name = "AutoCollect",
	CurrentValue = false,
	Flag = "AutoCollectToggle",
	Callback = function(Value)

	end,
})
