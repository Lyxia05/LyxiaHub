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
getgenv().MobObject = nil


--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--
local LocalPlayer = Players.LocalPlayer

--
local MobsFolder = workspace.Mobs




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
	local Event = game:GetService("ReplicatedStorage").Systems.Combat.PlayerAttack
	local result = {}

	for index, value in MobsFolder:GetChildren() do
		local Character = GetCharacter()
		local mobHRP = value:FindFirstChild("HumanoidRootPart")
		if Character and mobHRP then
			local Distance = (Character.HumanoidRootPart.Position - mobHRP.Position).Magnitude
			if Distance <= 50 then
				table.insert(result, value)
			end
		end
	end
	Event:FireServer(result)
end

local function ConvertSettingsToCFrame()
	if getgenv().Type == "Bellow" then
		return CFrame.new(0, getgenv().Studs * -1, 0)
	else
		return CFrame.new(0, getgenv().Studs, 0)
	end
end

local function TeleportToMob( Mob )
	local Character = GetCharacter()

	if not Character then
		return
	end

	local mobHRP = Mob:FindFirstChild("HumanoidRootPart")

	if not mobHRP then
		return
	end

	Character:PivotTo(mobHRP.CFrame * ConvertSettingsToCFrame())
end

local function TakeQuest()
	local Event = game:GetService("ReplicatedStorage").Systems.Quests.AcceptQuest
	Event:FireServer(getgenv().Quest)
end

local function FinishQuest()
	local Event = game:GetService("ReplicatedStorage").Systems.Quests.CompleteQuest
	Event:FireServer(getgenv().Quest)
end




-- Auto Loot
ReplicatedStorage.Drops.ChildAdded:Connect(function(child)
	if getgenv().AutoCollect == false then
		return
	end

	if not child:IsA("Folder") then
		return
	end

	local Event = game:GetService("ReplicatedStorage").Systems.Drops.Pickup
	Event:FireServer(child)
end)

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
			for _, value in pairs(MobsFolder:GetChildren()) do
				for _, value2 in getgenv().Mobs do
					if value.Name:find(value2) then
						local HumanoidRootPart = value:FindFirstChild("HumanoidRootPart")
						local HealthBar = value:FindFirstChild("Healthbar")
						if HumanoidRootPart and HealthBar then
							TeleportToMob(value)
						end
					end
		
				end
			end
		end
		task.wait()
	end
end)

-- Auto Quest Loops
task.spawn(function()
	while true do
		if getgenv().AutoQuest == true then
			if ReplicatedStorage.Profiles[LocalPlayer.Name].Quests.Active.Count >= 5 then
				FinishQuest()
			end
			TakeQuest()
		end
		task.wait(0.5)
	end
end)





-- GUI SECTIONS
local RayfieldLibrary = loadstring(game:HttpGet('https://raw.githubusercontent.com/Lyxia1/LyxiaHub/main/UILIb.lua'))()
local Window = RayfieldLibrary:CreateWindow({
	Name = "Lyxia Hub",
	LoadingTitle = "Swordburst 3",
	LoadingSubtitle = "by Lyxia",
	ConfigurationSaving = {
		Enabled = true,
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
		getgenv().Quest = tonumber(Option[1])
	end,
})
local MobDropDown = AutofarmTab:CreateDropdown({
	Name = "Select Mob",
	Options = GetMobList(),
	CurrentOption = {"None"},
	MultipleOptions = false,
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
		getgenv().Type = Option[1]
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

-- Server Hop
local ServerHopButton = TeleportTab:CreateButton({
	Name = "Teleport Low player server",
	Callback = function ()
		local TeleportService = game:GetService("TeleportService")
		local HttpService = game:GetService("HttpService")
		local Site = HttpService:JSONDecode(game.HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))

		local result = ""

		for i,v in pairs(Site.data) do
			if result ~= "" then
				break
			end
	
			if v.playing <= 2 then 
				result = v.id
			end
		end
		TeleportService:TeleportToPlaceInstance(game.PlaceId, result, game.Players.LocalPlayer)
	end
})
