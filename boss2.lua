local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MobsFolder = workspace.Mobs
local KillAuraEvent = ReplicatedStorage.Systems.Combat.PlayerAttack
local CompleteEvent = ReplicatedStorage.Systems.Quests.CompleteQuest
local AcceptEvent = ReplicatedStorage.Systems.Quests.AcceptQuest

local Mobs = nil
local Time = os.clock()

local result = {}

local function GetCharacter()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function KillAura()
    while true do
        table.clear(result)
        for index, value in pairs(MobsFolder:GetChildren()) do
            if value:FindFirstChild("HumanoidRootPart") and value:FindFirstChild("Healthbar") then
                local Character = GetCharacter()
                if Character and Character:FindFirstChild("HumanoidRootPart") then
                    local Distance = (Character.HumanoidRootPart.Position - value.HumanoidRootPart.Position).Magnitude
                    if Distance <= 40 then
                        table.insert(result, value)
                    end
                end
            end
        end
        KillAuraEvent:FireServer(result)
        task.wait(0.3)
    end
end

local function GetMobs()
    for index, value in pairs(MobsFolder:GetChildren()) do
        if value.Name:find('Elize') then
            if value:FindFirstChild("HumanoidRootPart") and value:FindFirstChild("Healthbar") then
                Mobs = value
		Time = os.clock()
                break
            end
        end
    end
end

local function AutoFarm()
    while true do
        AcceptEvent:FireServer(29)
        CompleteEvent:FireServer(29)

	if os.clock() - Time >= 10 then
		GetMobs()
	end

        if Mobs == nil then
            GetMobs()
        elseif Mobs ~= nil and Mobs:FindFirstChild("HumanoidRootPart") and Mobs:FindFirstChild("Healthbar") then
            local Character = GetCharacter()
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                Character.HumanoidRootPart.CFrame = Mobs.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)
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

game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.BossArenas["Elize The Siren"].Spawn.CFrame

game.Players.LocalPlayer.CharacterAdded:Connect(function()
  wait(3)
  game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.BossArenas["Elize The Siren"].Spawn.CFrame
end)
