--
getgenv().Type = "Above"
getgenv().Studs = 10
getgenv().Mobs = {"None"}
getgenv().Quest = 0
getgenv().AutoFarm = false
getgenv().AutoQuest = false
getgenv().KillAura = false
getgenv().AutoCollect = false
getgenv().KillAuraDelay = 0.5
getgenv().MobObject = "None"


--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--
local LocalPlayer = Players.LocalPlayer

--
local MobsFolder : Folder = workspace.Mobs




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

local function KillMob()
	local result = {}
	local Event = game:GetService("ReplicatedStorage").Systems.Combat.PlayerAttack
	for index, mob in pairs(MobsFolder:GetChildren()) do
		local Character = GetCharacter()
		local MobHRP = mob:FindFirstChild("HumanoidRootPart")
		if Character and MobHRP then
			local Range = (Character.HumanoidRootPart.Position - MobHRP.Position).Magnitude
			if Range <= 50 then
				table.insert(result, mob)
			end
		end
	end
	Event:FireServer(result)
end

local function GetMobs()
	local result = nil

	for _, value in getgenv().Mobs do
		local Mobs = MobsFolder:FindFirstChild(value)
		if Mobs then
			result = Mobs
		end
	end

	return result
end

local function ConvertSettingsToCFrame()
	if getgenv().Type == "Bellow" then
		return CFrame.new(0, getgenv().Studs * -1, 0)
	else
		return CFrame.new(0, getgenv().Studs, 0)
	end
end

local function TeleportToMob( Mob : Instance )
	local Character = GetCharacter()

	if not Character then
		return
	end

	Character:PivotTo(Mob.HumanoidRootPart.CFrame * ConvertSettingsToCFrame())
end

local function TakeQuest()
	local Event = game:GetService("ReplicatedStorage").Systems.Quests.AcceptQuest
	Event:FireServer(getgenv().Quest)
end

local function FinishQuest()
	local Event = game:GetService("ReplicatedStorage").Systems.Quests.CompleteQuest
	Event:FireServer(getgenv().Quest)
end

local function LootItems( Items : Instance )
	local Event = game:GetService("ReplicatedStorage").Systems.Drops.Pickup
	Event:FireServer(loot)
end



-- Kill Aura Loops
task.spawn(function()
	while true do
		if getgenv().KillAura == true then
			KillMob()
		end
		task.wait(getgenv().KillAuraDelay)
	end
end)

-- Auto Farm Loops
task.spawn(function()
	while true do
		if getgenv().AutoFarm == true then
			local Mobs = GetMobs()

			if Mobs then
				getgenv().MobObject = Mobs
				TeleportToMob(Mobs)
			end

		end
		task.wait()
	end
end)

-- Auto Quest Loops
task.spawn(function()
	while true do
		if getgenv().AutoQuest == true then
			TakeQuest()
			FinishQuest()
		end
		task.wait(1)
	end
end)





-- GUI SECTIONS
local RayfieldLibrary = loadstring(game:HttpGet('https://raw.githubusercontent.com/Lyxia1/LyxiaHub/main/UILIb.lua'))()
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
		getgenv().Quest = tonumber(Option)
	end,
})
local MobDropDown = AutofarmTab:CreateDropdown({
	Name = "Select Mob",
	Options = GetMobList(),
	CurrentOption = {"None"},
	MultipleOptions = true,
	Flag = "MobDropDown",
	Callback = function(Option)
		getgenv().Mobs = Option
	end,
})
local AutofarmToggle = AutofarmTab:CreateToggle({
	Name = "Autofarm",
	CurrentValue = false,
	Flag = "Autofarm",
	Callback = function(Value)
		getgenv().AutoFarm = Value
	end,
})
local AutoquestToggle = AutofarmTab:CreateToggle({
	Name = "AutoQuest",
	CurrentValue = false,
	Flag = "AutoQuest",
	Callback = function(Value)
		getgenv().AutoQuest = Value
	end,
})
local AutofarmStudsSlider = AutofarmTab:CreateSlider({
	Name = "Studs",
	Range = {1, 10},
	Increment = 1,
	CurrentValue = 10,
	Flag = "StudsSlider",
	Callback = function(Value)
		getgenv().Studs = Value
	end,
})
local AutofarmTypeDropdown =AutofarmTab:CreateDropdown({
	Name = "Type",
	Options = {"Above", "Bellow"},
	CurrentOption = {"Above"},
	MultipleOptions = false,
	Flag = "TypeDropDown",
	Callback = function(Option)
		getgenv().Type = Option
	end,
})

-- Kill Aura
local Section = AutofarmTab:CreateSection("Kill Aura")
local killauraToggle = AutofarmTab:CreateToggle({
	Name = "Kill Aura",
	CurrentValue = false,
	Flag = "KAToggle",
	Callback = function(Value)
		getgenv().KillAura = Value
	end,
})
local killauraDelaySlider = AutofarmTab:CreateSlider({
	Name = "Delay",
	Range = {0.2, 0.5},
	Increment = 0.01,
	CurrentValue = 0.5,
	Flag = "KADelay",
	Callback = function(Value)
		getgenv().KillAuraDelay = Value
	end,
})

-- AutoCollect
local Section = AutofarmTab:CreateSection("AutoCollect")
local AutoCollectToggle = AutofarmTab:CreateToggle({
	Name = "AutoCollect",
	CurrentValue = false,
	Flag = "AutoCollectToggle",
	Callback = function(Value)
		getgenv().AutoCollect = Value
	end,
})
