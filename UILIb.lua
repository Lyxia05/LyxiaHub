local LOCATION_LIST = {
    ["Anvil Crafting"] = CFrame.new(-3159.99512, -744.132935, 1678.68799, 1, 0, 0, 0, 1, 0, 0, 0, 1),
    ["Moosewood"] = CFrame.new(379.349854, 135.981995, 252.739365, 0.0654996559, -0.0129965823, 0.997767866, -4.99083885e-09, 0.999915063, 0.0130246123, -0.997852504, -0.000853108766, 0.0654940978),
    ["Enchant"] = CFrame.new(1308.83472, -803.820496, -99.0600815, -0.999974251, -7.29177846e-05, 0.00716413045, -6.87956012e-11, 0.999948204, 0.0101777008, -0.00716450112, 0.0101773795, -0.999922514),
    ["Sundial Totem"] = CFrame.new(-1150, 135, -1075),
    ["Aurora Totem"] = CFrame.new(-2028.35901, 131.533112, 564.018127, -0.998990774, -0.000520529575, 0.0449121669, 1.14976054e-07, 0.999932766, 0.0115917837, -0.0449151769, 0.0115800304, -0.998923659),
}

local FISHING_LOCATION = {
    ["CurrentLocation"] = CFrame.new(0, 0, 0),
    ["Forsaken"] = CFrame.new(-2677.74146, 166.230133, 1751.73364, 0.172691628, -0.0184644088, 0.984802723, -0.00562378066, 0.999789417, 0.0197316147, -0.984959722, -0.00894575007, 0.172551438),
    ["Vertigo"] = CFrame.new(-108.59536, -732.282532, 1213.84302, -0.98443377, 0.00203714357, -0.175743878, 4.63249439e-10, 0.999932766, 0.0115908245, 0.17575568, 0.0114103416, -0.984367669),
    ["The Deep"] = CFrame.new(882.475342, -729.294128, 1413.83472, -0.999941826, -0.00624589343, -0.00878501311, -0.00643274561, 0.999750137, 0.0214039907, 0.00864913687, 0.0214592069, -0.999732316),
    ["Desolate Deep"] = CFrame.new(-1506.9646, -233.237518, -2869.48242, 0.656646132, 0.00910964701, -0.754143715, 3.0863287e-08, 0.999926984, 0.0120786615, 0.75419873, -0.00793139171, 0.65659827),
    ["Brine Pool"] = CFrame.new(-1788.32031, -141.208832, -3365.67188, 0.00191510259, 0.0108346511, -0.999939382, 1.43107526e-09, 0.99994123, 0.0108347302, 0.999998093, -2.07509383e-05, 0.00191499013),
    ["Snowcap"] = CFrame.new(2819, 131.978271, 2691.18872, 0.409354925, 2.59049784e-06, -0.912375212, 4.81721258e-07, 0.99999994, 3.11049507e-06, 0.912375212, -1.68074405e-06, 0.409354925),
    ["Pearl"] = CFrame.new(-2018.13025, 131.915344, 564.669495, -0.0474863201, 0.012981114, -0.998787463, -1.68957648e-08, 0.999915481, 0.0129958345, 0.998871803, 0.000617138459, -0.047482308),
    ["Volcano"] = CFrame.new(-1919.41553, 160.595612, 270.138641, 0.349687845, -0.0114463959, 0.936796367, 3.9331681e-08, 0.999925315, 0.0122177927, -0.936866224, -0.00427235616, 0.349661767),
    ["Ancient Isle"] = CFrame.new(5840.41064, 153.466324, 351.904907, -0.804206133, -0.00721050566, 0.594306648, 1.36345224e-09, 0.999926329, 0.0121318027, -0.594350398, 0.00975642353, -0.804146945)
}

--
getgenv().AutoFish = false
getgenv().Shiny = false
getgenv().Sparkling = false
getgenv().AutoAppraise = false
getgenv().FishName = ""
getgenv().FishMutation = ""
getgenv().RodName = "Training Rod"
getgenv().FishingDelay = 1
getgenv().FishWeight = 1
getgenv().FishingLocation = FISHING_LOCATION.Forsaken

--
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer.Backpack
local PlayerGui = LocalPlayer.PlayerGui
local LastShake = os.clock()

--
local function AntiAfk()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        task.wait(5)
        VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end

local function GetRod()
    return LocalPlayer.Character:FindFirstChild(getgenv().RodName)
end

local function StartFishing()
    local Rod = GetRod()
    
    if not Rod then
        return
    end

    Rod.events.cast:FireServer(math.random(95, 99))
end

local function CatchFish()
    game:GetService("ReplicatedStorage").events.reelfinished:FireServer(100, true)
end

local function Reset()
    local Rod = GetRod()
    
    if not Rod then
        return
    end

    Rod.events.reset:FireServer()
end

local function GetRodList()
    local RodList = {}

    for index, value in ReplicatedStorage.playerstats[LocalPlayer.Name].Rods:GetChildren() do
        table.insert(RodList, value.Name)
    end

    return RodList
end

local function GetEquippedRod()
    return ReplicatedStorage.playerstats[LocalPlayer.Name].Stats.rod.Value
end

local function GetFish()
    local Fish = nil

    for index, value in pairs(Backpack:GetChildren()) do
        if value.Name == getgenv().FishName then
            Fish = value
            break
        end
    end

    return Fish
end

local function GetFishWeight(Fish)
    return Fish.link.Value.Weight.Value
end

local function GetFishSparkling(Fish)
    return Fish.link.Value:FindFirstChild("Sparkling")
end

local function GetFishShiny(Fish)
    return Fish.link.Value:FindFirstChild("Shiny")
end

local function GetMutation(Fish)
    local mutation = ""

    if Fish.link.Value:FindFirstChild("Mutation") then
        mutation = Fish.link.Value.Mutation.Value
    end

    return mutation
end

local function AppraiseFish()
    workspace.world.npcs.Appraiser.appraiser.appraise:InvokeServer()
end

local function EquipFish(Fish)
    LocalPlayer.PlayerGui.hud.safezone.backpack.events.equip:FireServer(Fish)
end

local function AutoAppraise()
    local targetCFrame = CFrame.new(447.473022, 152.031845, 209.498581, 0.0391362868, 0.0121867256, -0.999159515, 3.22212728e-08, 0.999925554, 0.0121961292, 0.999233842, -0.00047734112, 0.0391333774)
    local distance = (LocalPlayer.Character:GetPivot().Position - targetCFrame.Position).Magnitude

    if distance >= 5 then
        LocalPlayer.Character:PivotTo(targetCFrame)
        fireproximityprompt(workspace.world.npcs.Appraiser.dialogprompt, 5)
    end

    local Fish = GetFish()

    if Fish == nil then
        return
    end

    local FishWeight = GetFishWeight(Fish)
    local FishMutation = GetMutation(Fish)

    if FishWeight >= getgenv().FishWeight and FishMutation == getgenv().FishMutation then
        local isSparkling = getgenv().Sparkling
        local isShiny = getgenv().Shiny
        local sparklingCheck = isSparkling and GetFishSparkling(Fish)
        local shinyCheck = isShiny and GetFishShiny(Fish)

        if (isSparkling and isShiny and sparklingCheck and shinyCheck) or
            (isSparkling and not isShiny and sparklingCheck) or
            (isShiny and not isSparkling and shinyCheck) or
            (not isSparkling and not isShiny) then
            return "Success"
        end
    end

    EquipFish(Fish)

    local success, err = pcall(function()
        return AppraiseFish()
    end)

    if not success then
        warn("Failed to appraise")
    end
end

local function SellAllFish()
    for index, value in pairs(workspace.world.npcs:GetDescendants()) do
        if value.Name == "sellall" then
            value:InvokeServer()
        end
    end
end

--
for index, value in pairs(workspace.world.spawns.TpSpots:GetChildren()) do
    LOCATION_LIST[value.Name] = value.CFrame
end

-- Init Anti AFK
AntiAfk()
getgenv().RodName = GetEquippedRod()

-- Auto Appraise Function
local function StartAutoAppraise()
    task.spawn(function()
        while getgenv().AutoAppraise do
            local Appraise = AutoAppraise()

            if Appraise == "Success" then
                break
            end

            task.wait(0.1)
        end
    end)
end

-- Auto Fish Function
local function StartAutoFish()
    task.spawn(function()
        while getgenv().AutoFish == true do
            local shakeui = PlayerGui:FindFirstChild("shakeui")
            local reel = PlayerGui:FindFirstChild("reel")
            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:wait()

            if Character and not Character:FindFirstChild(getgenv().RodName) then
                Character.Humanoid:EquipTool(LocalPlayer.Backpack[getgenv().RodName])
            end

            if os.clock() - LastShake >= 30 then
                LocalPlayer.Character:PivotTo(getgenv().FishingLocation)
            end
            
            if not shakeui and not reel then
                Reset()
                StartFishing()
                task.wait(1)
            end
        
            if reel then
                LastShake = os.clock()
                CatchFish()
            end

            if shakeui and shakeui:FindFirstChild("safezone") and shakeui.safezone:FindFirstChild("button") then
                local button = shakeui.safezone.button

                -- Get button's relative position (UDim2)
                local screenSize = workspace.CurrentCamera.ViewportSize -- Get screen size
                local absolutePosition = button.AbsolutePosition -- Absolute position of the button
                local absoluteSize = button.AbsoluteSize -- Size of the button
                
                -- Calculate normalized position (scale-based)
                local normalizedPosition = Vector2.new(
                    absolutePosition.X / screenSize.X,
                    absolutePosition.Y / screenSize.Y
                )
            
                -- Recalculate screen position for any resolution
                local recalculatedPosition = Vector2.new(
                    normalizedPosition.X * screenSize.X,
                    normalizedPosition.Y * screenSize.Y
                )
            
                -- Simulate a click at the recalculated position
                VirtualInputManager:SendMouseButtonEvent(
                    recalculatedPosition.X + (absoluteSize.X / 2), -- Center the click horizontally
                    recalculatedPosition.Y + (absoluteSize.Y / 2), -- Center the click vertically
                    0, -- Mouse button (0 = left-click)
                    true, -- Button down
                    game, -- Target instance
                    0 -- UserInputType (default 0 for mouse)
                )
                VirtualInputManager:SendMouseButtonEvent(
                    recalculatedPosition.X + (absoluteSize.X / 2),
                    recalculatedPosition.Y + (absoluteSize.Y / 2),
                    0,
                    false, -- Button up
                    game,
                    0
                )
                task.wait(0.5)
            else
                task.wait(getgenv().FishingDelay)
            end
        end
    end)

    task.spawn(function()
        while getgenv().AutoFish == true do
            local distance = (LocalPlayer.Character:GetPivot().Position - getgenv().FishingLocation.Position).Magnitude

            if distance >= 5 then
                LocalPlayer.Character:PivotTo(getgenv().FishingLocation)
            end
            task.wait()
        end
    end)
end

local function FixAllTreasuremap()
    for index, value in pairs(LocalPlayer.Backpack:GetChildren()) do
        if string.find(value.Name, "Treasure Map") then
            LocalPlayer.Character:PivotTo(CFrame.new(-2828.38818, 216.270752, 1522.24451, 0.768027484, -0.00830379128, 0.640362918, 1.23069333e-09, 0.999915898, 0.0129662883, -0.640416741, -0.00995841902, 0.767962933))
            LocalPlayer.PlayerGui.hud.safezone.backpack.events.equip:FireServer(value)
            workspace.world.npcs:FindFirstChild("Jack Marrow").treasure.repairmap:InvokeServer()
        end
    end
end

local function CollectAllTreasureMap()
    for index, value in pairs(game.ReplicatedStorage.playerstats.kerse.Inventory:GetChildren()) do
        if string.find(value.Name, "Treasure Map") then
            LocalPlayer.Character:PivotTo(CFrame.new(value.x.value, value.y.value, value.z.value))
            game:GetService("ReplicatedStorage").events.open_treasure:FireServer({
                ["y"] = value.y.value,
                ["x"] = value.x.value,
                ["z"] = value.z.value
            })
            task.wait(1)
        end
    end
end

local function TeleportToMeteor()
    LocalPlayer.Character:PivotTo(CFrame.new(5650.33887, 157.592697, 586.069824, -0.9396106, 0.0037273597, -0.342224866, 2.18440501e-08, 0.999940574, 0.0108909048, 0.342245162, 0.0102331471, -0.93955487) * CFrame.new(0, 5, 0))
end

local function GetFishingLocationList()
    local LocationList = {}
    
    for index, value in FISHING_LOCATION do
        table.insert(LocationList, index)
    end

    return LocationList
end

local function GetTeleportListLocation()
    local LocationList = {}
    
    for index, value in LOCATION_LIST do
        table.insert(LocationList, index)
    end

    return LocationList
end

local function TeleportToLocation(locationName: string)
    LocalPlayer.Character:PivotTo(LOCATION_LIST[locationName] * CFrame.new(0, 5, 0))
end

-- UI Library Import
local OrionLib = loadstring(game:HttpGet(("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua")))()
local Window = OrionLib:CreateWindow({
   Name = "Lyxia Hub",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Welcome to Lyxia Hub",
   LoadingSubtitle = "by Lyxia",
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Lyxia Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
      RememberJoins = false -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

-- Main Tab Section
local MainTab = Window:CreateTab("Main")
MainTab:CreateDropdown({
	Name = "Fishing Rod",
    Options = GetRodList(),
	CurrentOption = {GetEquippedRod()},
    MultipleOptions = false,
    Flag = "Dropdown Fishing Rod",
	Callback = function(Value)
		getgenv().RodName = Value[1]
        ReplicatedStorage.events.equiprod:FireServer(Value[1])
	end    
})
MainTab:CreateDropdown({
	Name = "Fishing Area",
    Options = GetFishingLocationList(),
	CurrentOption = {"Forsaken"},
    MultipleOptions = false,
    Flag = "Dropdown Fishing Area",
	Callback = function(Value)
        if Value[1] == "CurrentLocation" then
            FISHING_LOCATION["CurrentLocation"] = LocalPlayer.Character:GetPivot()
        end
		getgenv().FishingLocation = FISHING_LOCATION[Value[1]]
	end
})
MainTab:CreateSlider({
    Name = "Auto Fish Delay",
    Range = {0.5, 10},
    Increment = 0.5,
    Suffix = "Seconds",
    CurrentValue = getgenv().FishingDelay,
    Flag = "Auto Fish Delay Slider",
    Callback = function(Value)
        getgenv().FishingDelay = Value
    end
})
MainTab:CreateToggle({
    Name = "Auto Fish",
    CurrentValue = getgenv().AutoFish,
    Flag = "Auto Fish Toggle",
    Callback = function(state)
        getgenv().AutoFish = state
        if state then
            StartAutoFish()
        end
    end
})
MainTab:CreateButton({
    Name = "Sell Fish",
    Callback = function()
         SellAllFish()
    end,
 })


-- Auto Appraise Tab
local AppraiseTab = Window:CreateTab("Appraise")
AppraiseTab:CreateInput({
   Name = "Fish Name",
   CurrentValue = getgenv().FishName,
   PlaceholderText = "Input Here",
   RemoveTextAfterFocusLost = false,
   Flag = "Fish Name Text Box",
   Callback = function(Text)
        getgenv().FishName = Text
   end,
})
AppraiseTab:CreateInput({
   Name = "Fish Weight",
   CurrentValue = getgenv().FishWeight,
   PlaceholderText = "Input Here",
   RemoveTextAfterFocusLost = false,
   Flag = "Fish Weight Text Box",
   Callback = function(Text)
        getgenv().FishWeight = tonumber(Text)
   end,
})
AppraiseTab:CreateInput({
   Name = "Fish Mutation",
   CurrentValue = getgenv().FishMutation,
   PlaceholderText = "Input Here",
   RemoveTextAfterFocusLost = false,
   Flag = "Fish Mutation Text Box",
   Callback = function(Text)
        getgenv().FishMutation = Text
   end,
})
AppraiseTab:CreateToggle({
    Name = "Sparkling",
    CurrentValue = getgenv().Sparkling,
    Flag = "Sparkling Appraise Toggle",
    Callback = function(state)
        getgenv().Sparkling = state
    end
})
AppraiseTab:CreateToggle({
    Name = "Shiny",
    CurrentValue = getgenv().Shiny,
    Flag = "Shiny Appraise Toggle",
    Callback = function(state)
        getgenv().Shiny = state
    end
})
AppraiseTab:CreateToggle({
    Name = "Auto Appraise",
    CurrentValue = getgenv().AutoAppraise,
    Flag = "Auto Appraise Toggle",
    Callback = function(state)
        getgenv().AutoAppraise = state
        if state then
            StartAutoAppraise()
        end
    end
})
AppraiseTab:CreateButton({
   Name = "Appraise",
   Callback = function()
        AutoAppraise()
   end,
})

-- ETC Tab
local ETCTab = Window:CreateTab("Etc")
ETCTab:CreateDropdown({
	Name = "Teleport",
    Options = GetTeleportListLocation(),
	CurrentOption = {"Anvil Crafting"},
    MultipleOptions = false,
    Flag = "Teleport to Area",
	Callback = function(Value)
		TeleportToLocation(Value[1])
	end
})
ETCTab:CreateButton({
   Name = "Fix TreasureMap",
   Callback = function()
        FixAllTreasuremap()
   end,
})
ETCTab:CreateButton({
   Name = "Collect TreasureMap",
   Callback = function()
        CollectAllTreasureMap()
   end,
})

ETCTab:CreateButton({
    Name = "Meteor",
    Callback = function()
        TeleportToMeteor()
    end,
 })
