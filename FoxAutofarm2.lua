local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MobsFolder = workspace.Mobs
local KillAuraEvent = ReplicatedStorage.Systems.Combat.PlayerAttack
local CompleteEvent = ReplicatedStorage.Systems.Quests.CompleteQuest
local AcceptEvent = ReplicatedStorage.Systems.Quests.AcceptQuest

local Mobs = nil

local function GetCharacter()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function KillAura()
    while true do
        if Mobs ~= nil then
            KillAuraEvent:FireServer({Mobs})
        end
        task.wait(0.25)
    end
end

local function GetMobs()
    for index, value in pairs(MobsFolder:GetChildren()) do
        if value.Name:find('Kitsu') then
            if value:FindFirstChild("HumanoidRootPart") and value:FindFirstChild("Healthbar") then
                Mobs = value
                break
            end
        end
    end
end

local function AutoFarm()
    while true do
        AcceptEvent:FireServer(29)
        CompleteEvent:FireServer(29)

        if Mobs == nil then
            GetMobs()
        elseif Mobs ~= nil and Mobs:FindFirstChild("HumanoidRootPart") and Mobs:FindFirstChild("Healthbar") then
            local Character = GetCharacter()
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                Character.HumanoidRootPart.CFrame = Mobs.HumanoidRootPart.CFrame * CFrame.new(0, -5, 0)
            end
        elseif Mobs ~= nil and not Mobs:FindFirstChild("Healthbar") then
            GetMobs()
        end
        task.wait()
    end
end

task.spawn(KillAura)
task.spawn(AutoFarm)

ReplicatedStorage.Drops.ChildAdded:Connect(function(child)
	if not child:IsA("Folder") then
		return
	end

	local Event = game:GetService("ReplicatedStorage").Systems.Drops.Pickup
	Event:FireServer(child)
end)

LocalPlayer.Idled:Connect(function()
	game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-251, 100, -1165)

game.Players.LocalPlayer.CharacterAdded:Connect(function()
  wait(3)
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-251, 100, -1165)
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local DismantleEvent = ReplicatedStorage.Systems.Crafting.Dismantle
local Inventory = ReplicatedStorage.Profiles[LocalPlayer.Name].Inventory

Inventory.ChildAdded:Connect(function(child)
    if child.Name == "Fox Tail" or child.Name == "Quartz" or child.Name == "Mammoth Trunk" then
        return
    end
    DismantleEvent:FireServer(child)
end)
