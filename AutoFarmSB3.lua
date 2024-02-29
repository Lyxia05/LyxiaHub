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

local function AutoFarm()
    while true do
        AcceptEvent:FireServer(24)
        CompleteEvent:FireServer(24)
        for index, value in pairs(MobsFolder:GetChildren()) do
            if value.Name:find('Hell') then
                local Character = GetCharacter()
                if Character then
                    if value:FindFirstChild("HumanoidRootPart") and value:FindFirstChild("Healthbar") then
                        Character.HumanoidRootPart.CFrame = value.HumanoidRootPart.CFrame * CFrame.new(0, -5, 0)
                        Mobs = value
                    end
                end
            end
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
