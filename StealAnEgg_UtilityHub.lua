local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local values = {}
local currentEggType = "Common"

local defaultSettings = {
    WalkSpeed = 16,
    JumpPower = 50,
    Noclip = false,
    InfiniteJump = false,
    AutoSteal = false,
    AutoHatch = false,
    AutoTrain = false,
    ESPEggs = false,
    ESPBase = false,
    DelaySteal = 0.25,
    DelayHatch = 0.35,
    DelayTrain = 0.2
}

for k,v in pairs(defaultSettings) do
    values[k] = v
end

-- ==================== ORION LIB ====================
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
	Name = "GUI Utility Hub - Steal An Egg",
	HidePremium = false,
	SaveConfig = true,
	ConfigFolder = "OrionConfig"
})

-- ==================== HELPERS ====================
local function getRootPart(char)
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart
    end
end

local function fireProximityPrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        prompt:InputHoldBegin()
        task.wait(0.08)
        prompt:InputHoldEnd()
    end
end

local function findEggs()
    local found = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("egg", 1, true) or name:find("crate", 1, true) or name:find("nest", 1, true) then
                local parent = obj.Parent
                if parent and parent:IsA("Model") then
                    if not table.find(found, parent) then
                        table.insert(found, parent)
                    end
                end
            end
        end
    end
    return found
end

local function findRareEggs()
    local found = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        local isRare = name:find("rare", 1, true) or name:find("legend", 1, true) or name:find("gold", 1, true) or name:find("diamond", 1, true) or name:find("myth", 1, true)
        if isRare and obj:IsA("BasePart") then
            local parent = obj.Parent
            if parent and parent:IsA("Model") then
                if not table.find(found, parent) then
                    table.insert(found, parent)
                end
            end
        end
    end
    return found
end

local function findTrainStation()
    local candidates = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if obj:IsA("BasePart") and (name:find("treadmill", 1, true) or name:find("train", 1, true) or name:find("speed", 1, true) or name:find("boost", 1, true) or name:find("station", 1, true)) then
            table.insert(candidates, obj)
        end
    end

    table.sort(candidates, function(a, b)
        local plr = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not plr then return false end
        return (a.Position - plr.Position).Magnitude < (b.Position - plr.Position).Magnitude
    end)

    return candidates[1]
end

local function findBase()
    local candidates = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if obj:IsA("BasePart") and (name:find("base", 1, true) or name:find("spawn", 1, true) or name:find("hub", 1, true) or name:find("portal", 1, true) or name:find("pickup", 1, true) or name:find("deposit", 1, true)) then
            table.insert(candidates, obj)
        end
    end

    table.sort(candidates, function(a, b)
        local plr = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not plr then return false end
        return (a.Position - plr.Position).Magnitude < (b.Position - plr.Position).Magnitude
    end)

    return candidates[1]
end

local function getNearestProximityPromptFromModel(model)
    if not model then return nil end
    local nearestPrompt = nil
    local nearestDist = math.huge
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            local pos = child.Parent and child.Parent.Position or (child.Parent and child.Parent.PrimaryPart and child.Parent.PrimaryPart.Position)
            if pos then
                local root = getRootPart(localPlayer.Character)
                if root then
                    local dist = (root.Position - pos).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestPrompt = child
                    end
                end
            end
        end
    end
    return nearestPrompt, nearestDist
end

-- ==================== ESP ====================
local espObjects = {}

local function clearEsp()
    for _, v in ipairs(espObjects) do
        if v and v.Parent then
            pcall(function() v:Destroy() end)
        end
    end
    espObjects = {}
end

local function addEspLabel(obj, color, text)
    if not obj or not obj.Parent then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPLabel"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = obj
    billboard.Parent = obj

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0.4
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = frame

    table.insert(espObjects, billboard)
end

local function updateEsp()
    clearEsp()

    if values.ESPEggs then
        local eggs = findEggs()
        local rareEggs = findRareEggs()

        for _, egg in ipairs(eggs) do
            local primary = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
            if primary then
                addEspLabel(primary, Color3.fromRGB(0, 255, 150), "[EGG]")
            end
        end

        for _, egg in ipairs(rareEggs) do
            local primary = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
            if primary then
                addEspLabel(primary, Color3.fromRGB(255, 200, 0), "[RARE]")
            end
        end
    end

    if values.ESPBase then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                addEspLabel(root, Color3.fromRGB(255, 85, 85), "[" .. player.Name .. "]")
            end
        end
    end
end

-- ==================== PLAYER MODS ====================
local function applyPlayerMods()
    if not localPlayer.Character then return end
    local char = localPlayer.Character
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if hum then
        hum.WalkSpeed = values.WalkSpeed
        hum.JumpPower = values.JumpPower
    end

    if values.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- ==================== LOOPS ====================
local function autoStealLoop()
    while true do
        if values.AutoSteal and localPlayer.Character then
            local root = getRootPart(localPlayer.Character)
            if root then
                local nearestEgg = nil
                local nearestDist = math.huge

                for _, egg in ipairs(findEggs()) do
                    local part = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local dist = (root.Position - part.Position).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearestEgg = egg
                        end
                    end
                end

                if nearestEgg then
                    local part = nearestEgg.PrimaryPart or nearestEgg:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local prompt = getNearestProximityPromptFromModel(nearestEgg)
                        if prompt and (root.Position - part.Position).Magnitude < 15 then
                            fireProximityPrompt(prompt)
                        elseif (root.Position - part.Position).Magnitude > 15 then
                            root.CFrame = CFrame.new(part.Position + Vector3.new(0, 4, 0))
                        end
                    end
                end

                local basePart = findBase()
                if basePart and (root.Position - basePart.Position).Magnitude > 20 then
                    root.CFrame = CFrame.new(basePart.Position + Vector3.new(0, 3, 0))
                end
            end
        end
        task.wait(values.DelaySteal)
    end
end

local function autoHatchLoop()
    while true do
        if values.AutoHatch and localPlayer.Character then
            local eggSearchNames = {
                currentEggType .. " Egg",
                currentEggType,
                currentEggType:lower() .. "egg"
            }

            local found = false
            for _, searchName in ipairs(eggSearchNames) do
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name:lower():find(currentEggType:lower(), 1, true) then
                        local prompt = getNearestProximityPromptFromModel(obj)
                        if prompt then
                            fireProximityPrompt(prompt)
                            found = true
                            break
                        end
                    end
                end
                if found then break end
            end
        end
        task.wait(values.DelayHatch)
    end
end

local function autoTrainLoop()
    while true do
        if values.AutoTrain and localPlayer.Character then
            local station = findTrainStation()
            if station then
                local root = getRootPart(localPlayer.Character)
                if root then
                    if (root.Position - station.Position).Magnitude > 20 then
                        root.CFrame = CFrame.new(station.Position + Vector3.new(0, 4, 0))
                    else
                        for _, child in ipairs(station.Parent:GetDescendants()) do
                            if child:IsA("ProximityPrompt") then
                                fireProximityPrompt(child)
                                break
                            end
                        end
                    end
                end
            end
        end
        task.wait(values.DelayTrain)
    end
end

local function infiniteJumpLoop()
    while true do
        if values.InfiniteJump and localPlayer.Character then
            local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Jump = true
            end
        end
        task.wait(0.05)
    end
end

-- ==================== GUI TABS ====================

local MainTab = Window:MakeTab({
	Name = "Main",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

MainTab:AddLabel("Auto Farm & Collection")

MainTab:AddToggle({
	Name = "Auto Steal / Auto Farm",
	Default = false,
	Callback = function(Value)
		values.AutoSteal = Value
	end	
})

MainTab:AddSlider({
	Name = "Farm Delay (Segundos)",
	Min = 0.1,
	Max = 2,
	Default = 0.25,
	Color = Color3.fromRGB(255,255,255),
	Increment = 0.05,
	ValueName = "s",
	Callback = function(Value)
		values.DelaySteal = Value
	end	
})

MainTab:AddLabel("")
MainTab:AddLabel("Auto Hatch / Eggs")

MainTab:AddToggle({
	Name = "Auto Hatch / Auto Open Eggs",
	Default = false,
	Callback = function(Value)
		values.AutoHatch = Value
	end	
})

MainTab:AddDropdown({
	Name = "Tipo de Ovo",
	Default = "Common",
	Options = {"Common", "Rare", "Epic", "Legendary", "Mythic"},
	Callback = function(Value)
		currentEggType = Value
	end	
})

MainTab:AddSlider({
	Name = "Hatch Delay (Segundos)",
	Min = 0.1,
	Max = 2,
	Default = 0.35,
	Color = Color3.fromRGB(255,255,255),
	Increment = 0.05,
	ValueName = "s",
	Callback = function(Value)
		values.DelayHatch = Value
	end	
})

MainTab:AddLabel("")
MainTab:AddLabel("Auto Train / Treadmill")

MainTab:AddToggle({
	Name = "Auto Train / Treadmill",
	Default = false,
	Callback = function(Value)
		values.AutoTrain = Value
	end	
})

MainTab:AddSlider({
	Name = "Train Delay (Segundos)",
	Min = 0.1,
	Max = 2,
	Default = 0.2,
	Color = Color3.fromRGB(255,255,255),
	Increment = 0.05,
	ValueName = "s",
	Callback = function(Value)
		values.DelayTrain = Value
	end	
})

-- TAB 2: PLAYER MODS
local PlayerTab = Window:MakeTab({
	Name = "Player",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

PlayerTab:AddLabel("Speed & Jump")

PlayerTab:AddSlider({
	Name = "WalkSpeed",
	Min = 16,
	Max = 250,
	Default = 16,
	Color = Color3.fromRGB(255,255,255),
	Increment = 5,
	ValueName = "",
	Callback = function(Value)
		values.WalkSpeed = Value
	end	
})

PlayerTab:AddSlider({
	Name = "JumpPower",
	Min = 50,
	Max = 250,
	Default = 50,
	Color = Color3.fromRGB(255,255,255),
	Increment = 5,
	ValueName = "",
	Callback = function(Value)
		values.JumpPower = Value
	end	
})

PlayerTab:AddLabel("")
PlayerTab:AddLabel("Modifiers")

PlayerTab:AddToggle({
	Name = "Infinite Jump",
	Default = false,
	Callback = function(Value)
		values.InfiniteJump = Value
	end	
})

PlayerTab:AddToggle({
	Name = "Noclip",
	Default = false,
	Callback = function(Value)
		values.Noclip = Value
	end	
})

-- TAB 3: ESP
local EspTab = Window:MakeTab({
	Name = "ESP",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

EspTab:AddLabel("Visual Helpers")

EspTab:AddToggle({
	Name = "ESP Eggs / Rares",
	Default = false,
	Callback = function(Value)
		values.ESPEggs = Value
		if not Value then
			clearEsp()
		end
	end	
})

EspTab:AddToggle({
	Name = "ESP Enemy Base",
	Default = false,
	Callback = function(Value)
		values.ESPBase = Value
		if not Value then
			clearEsp()
		end
	end	
})

EspTab:AddButton({
	Name = "Clear ESP",
	Callback = function()
      		clearEsp()
  	end    
})

-- TAB 4: INFO
local InfoTab = Window:MakeTab({
	Name = "Info",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

InfoTab:AddLabel("GUI Utility Hub v1.0")
InfoTab:AddLabel("Steal An Egg Script")
InfoTab:AddLabel("")
InfoTab:AddLabel("Funcionalidades:")
InfoTab:AddLabel("✓ Auto Steal / Auto Farm")
InfoTab:AddLabel("✓ Auto Hatch / Open Eggs")
InfoTab:AddLabel("✓ Auto Train / Treadmill")
InfoTab:AddLabel("✓ Player Mods (Speed, Jump)")
InfoTab:AddLabel("✓ Noclip & Infinite Jump")
InfoTab:AddLabel("✓ ESP System")
InfoTab:AddLabel("")
InfoTab:AddLabel("Desenvolvido com Orion Library")

-- ==================== START ====================
task.spawn(autoStealLoop)
task.spawn(autoHatchLoop)
task.spawn(autoTrainLoop)
task.spawn(infiniteJumpLoop)

local lastEsp = 0
RunService.RenderStepped:Connect(function()
    applyPlayerMods()

    if tick() - lastEsp > 0.5 then
        updateEsp()
        lastEsp = tick()
    end
end)

OrionLib:MakeNotification({
	Name = "GUI Utility Hub",
	Content = "Script loaded successfully!",
	Image = "rbxassetid://4483345998",
	Time = 5
})

print("✓ Steal An Egg Utility Hub loaded!")
