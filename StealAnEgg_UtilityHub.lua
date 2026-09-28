--[[
    GUI Utility Hub - Steal An Egg
    Roblox Lua Script
    Compatível com Rayfield e Orion (estrutura genérica)
    Desenvolvido para automação em "Steal An Egg"
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = localPlayer:GetMouse()

local gui = {}
local toggles = {}
local values = {}
local currentEggType = "Common"

-- Configuração básica
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
    toggles[k] = false
end

-- =========================
-- Helpers
-- =========================
local function getRootPart(char)
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char.HumanoidRootPart
    end
end

local function isAlive(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getDistance(a, b)
    if not a or not b then return math.huge end
    return (a.Position - b.Position).Magnitude
end

local function getNearestModelFromName(namePart, maxDist)
    maxDist = maxDist or math.huge
    local nearest = nil
    local nearestDist = maxDist

    for _, obj in ipairs(Workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if n:find(namePart:lower(), 1, true) then
            if obj:IsA("BasePart") then
                local dist = (obj.Position - localPlayer.Character.PrimaryPart.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = obj
                end
            end
        end
    end

    return nearest, nearestDist
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
                    table.insert(found, parent)
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
                table.insert(found, parent)
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

local function findPlayerBase(player)
    local char = player and player.Character
    if not char then return nil end
    local root = getRootPart(char)
    return root
end

local function getNearestProximityPromptFromModel(model)
    if not model then return nil end
    local nearestPrompt = nil
    local nearestDist = math.huge
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            local pos = child.Parent and child.Parent.Position or child.Parent and child.Parent.PrimaryPart and child.Parent.PrimaryPart.Position
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

local function openEggByName(name)
    -- Aqui você pode adaptar os nomes reais dos ovos do jogo
    -- Exemplos comuns: "Common Egg", "Rare Egg", "Epic Egg", "Legendary Egg"
    local eggFolder = Workspace:FindFirstChild("Eggs") or Workspace:FindFirstChild("EggShop") or Workspace:FindFirstChild("EggsShop")
    if not eggFolder then
        return false
    end

    local target = nil
    for _, obj in ipairs(eggFolder:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find(name:lower(), 1, true) then
            target = obj
            break
        end
    end

    if not target then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find(name:lower(), 1, true) then
                target = obj
                break
            end
        end
    end

    if not target then
        return false
    end

    local prompt = getNearestProximityPromptFromModel(target)
    if prompt then
        fireProximityPrompt(prompt)
        return true
    end

    local root = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
    if root then
        local charRoot = getRootPart(localPlayer.Character)
        if charRoot then
            local dist = (charRoot.Position - root.Position).Magnitude
            if dist > 20 then
                charRoot.CFrame = CFrame.new(root.Position + Vector3.new(0, 5, 0))
            end
        end
    end

    return false
end

-- =========================
-- GUI Builder
-- =========================
local function createInstance(className, props)
    local inst = Instance.new(className)
    for prop, val in pairs(props or {}) do
        inst[prop] = val
    end
    return inst
end

local function createNotification(title, text)
    local notify = Instance.new("ScreenGui")
    notify.Name = "Notify_" .. tostring(math.random(1, 100000))
    notify.ResetOnSpawn = false
    notify.IgnoreGuiInset = true
    notify.Parent = game:GetService("CoreGui")

    local frame = createInstance("Frame", {
        Parent = notify,
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(0.5, -150, 0.08, 0),
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
        BorderSizePixel = 0,
        BackgroundTransparency = 0.08
    })

    local corner = createInstance("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 12) })
    local titleLabel = createInstance("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 10, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255,255,255),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local textLabel = createInstance("TextLabel", {
        Parent = frame,
        Size = UDim2.new(1, -20, 0, 26),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(220,220,220),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })

    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.2), { Position = UDim2.new(0.5, -150, 0.08, 0) })
    local tweenOut = TweenService:Create(frame, TweenInfo.new(0.25), { Position = UDim2.new(0.5, -150, -0.15, 0) })
    tweenIn:Play()
    task.delay(2.2, function()
        tweenOut:Play()
        task.delay(0.3, function()
            notify:Destroy()
        end)
    end)
end

-- =========================
-- GUI Library detection
-- =========================
local function loadRayfield()
    local success, rayfield = pcall(function()
        return require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Rayfield"))
    end)
    if success then
        return rayfield
    end
    return nil
end

local function loadOrion()
    local success, orionLib = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
    end)
    if success then
        return orionLib
    end
    return nil
end

local function buildGui()
    local lib = loadRayfield() or loadOrion()
    if not lib then
        local screen = Instance.new("ScreenGui")
        screen.Name = "UtilityHubFallback"
        screen.ResetOnSpawn = false
        screen.Parent = game:GetService("CoreGui")

        local frame = createInstance("Frame", {
            Parent = screen,
            Size = UDim2.new(0, 420, 0, 320),
            Position = UDim2.new(0.5, -210, 0.5, -160),
            BackgroundColor3 = Color3.fromRGB(20,20,20),
            BorderSizePixel = 0
        })
        createInstance("UICorner", { Parent = frame, CornerRadius = UDim.new(0, 12) })
        local title = createInstance("TextLabel", {
            Parent = frame,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            Text = "GUI Utility Hub",
            TextColor3 = Color3.fromRGB(255,255,255),
            Font = Enum.Font.GothamBold,
            TextSize = 18
        })

        local list = createInstance("TextLabel", {
            Parent = frame,
            Position = UDim2.new(0, 20, 0, 50),
            Size = UDim2.new(1, -40, 1, -60),
            BackgroundTransparency = 1,
            Text = "Rayfield/Orion não encontrado.\nInstale uma biblioteca de UI ou adapte a seção de GUI.",
            TextColor3 = Color3.fromRGB(220,220,220),
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextWrapped = true
        })
        return { type = "fallback", screen = screen }
    end

    if lib.Name == "Rayfield" then
        local Window = lib:CreateWindow({
            Name = "GUI Utility Hub",
            LoadingTitle = "Loading...",
            LoadingSubtitle = "Steal An Egg Utility",
            ConfigurationSaving = false,
            KeySystem = false
        })

        local main = Window:CreateTab("Main")
        local playerTab = Window:CreateTab("Player")
        local espTab = Window:CreateTab("ESP")

        return { lib = lib, window = Window, tabs = { main = main, player = playerTab, esp = espTab }, type = "rayfield" }
    end

    if lib.Name == "Orion" then
        local Orion = lib
        local Window = Orion:MakeWindow({ Name = "GUI Utility Hub", HidePremium = true, SaveConfig = false, IntroEnabled = false })

        local main = Window:MakeTab({
            Name = "Main",
            Icon = "rbxassetid://4483345998"
        })

        local player = Window:MakeTab({
            Name = "Player",
            Icon = "rbxassetid://4483345998"
        })

        local esp = Window:MakeTab({
            Name = "ESP",
            Icon = "rbxassetid://4483345998"
        })

        return { lib = lib, window = Window, tabs = { main = main, player = player, esp = esp }, type = "orion" }
    end

    return { type = "fallback" }
end

local GuiInstance = buildGui()

-- =========================
-- UI Builder abstraction
-- =========================
local function addToggle(tab, name, default, callback)
    if GuiInstance.type == "rayfield" then
        local toggle = tab:CreateToggle({
            Name = name,
            CurrentValue = default,
            Flag = name:gsub("%s+", ""),
            Callback = callback
        })
        return toggle
    elseif GuiInstance.type == "orion" then
        local toggle = tab:CreateToggle({
            Name = name,
            Default = default,
            Callback = callback
        })
        return toggle
    else
        return nil
    end
end

local function addSlider(tab, name, min, max, default, callback)
    if GuiInstance.type == "rayfield" then
        local slider = tab:CreateSlider({
            Name = name,
            Range = {min, max},
            Increment = 1,
            Suffix = "",
            CurrentValue = default,
            Flag = name:gsub("%s+", ""),
            Callback = callback
        })
        return slider
    elseif GuiInstance.type == "orion" then
        local slider = tab:CreateSlider({
            Name = name,
            Min = min,
            Max = max,
            Default = default,
            ValueName = "",
            Callback = callback
        })
        return slider
    else
        return nil
    end
end

local function addDropdown(tab, name, options, default, callback)
    if GuiInstance.type == "rayfield" then
        local dropdown = tab:CreateDropdown({
            Name = name,
            Options = options,
            CurrentOption = default,
            Flag = name:gsub("%s+", ""),
            Callback = callback
        })
        return dropdown
    elseif GuiInstance.type == "orion" then
        local dropdown = tab:CreateDropdown({
            Name = name,
            Default = default,
            Options = options,
            Callback = callback
        })
        return dropdown
    else
        return nil
    end
end

-- =========================
-- GUI Setup
-- =========================
if GuiInstance.type == "rayfield" then
    local mainTab = GuiInstance.tabs.main
    local playerTab = GuiInstance.tabs.player
    local espTab = GuiInstance.tabs.esp

    addToggle(mainTab, "Auto Steal / Auto Farm", false, function(v)
        values.AutoSteal = v
    end)

    addToggle(mainTab, "Auto Hatch / Auto Open Eggs", false, function(v)
        values.AutoHatch = v
    end)

    addToggle(mainTab, "Auto Train / Treadmill", false, function(v)
        values.AutoTrain = v
    end)

    addDropdown(mainTab, "Egg Type", {"Common", "Rare", "Epic", "Legendary", "Mythic"}, "Rare", function(v)
        currentEggType = v
    end)

    addSlider(mainTab, "Farm Delay", 0.1, 1, 0.25, function(v)
        values.DelaySteal = v
    end)

    addSlider(mainTab, "Hatch Delay", 0.1, 1.5, 0.35, function(v)
        values.DelayHatch = v
    end)

    addSlider(mainTab, "Train Delay", 0.1, 1, 0.2, function(v)
        values.DelayTrain = v
    end)

    addToggle(playerTab, "Noclip", false, function(v)
        values.Noclip = v
    end)

    addToggle(playerTab, "Infinite Jump", false, function(v)
        values.InfiniteJump = v
    end)

    addSlider(playerTab, "WalkSpeed", 16, 250, 16, function(v)
        values.WalkSpeed = v
    end)

    addSlider(playerTab, "JumpPower", 50, 250, 50, function(v)
        values.JumpPower = v
    end)

    addToggle(espTab, "ESP Eggs / Rares", false, function(v)
        values.ESPEggs = v
    end)

    addToggle(espTab, "ESP Enemy Base", false, function(v)
        values.ESPBase = v
    end)
elseif GuiInstance.type == "orion" then
    local mainTab = GuiInstance.tabs.main
    local playerTab = GuiInstance.tabs.player
    local espTab = GuiInstance.tabs.esp

    mainTab:AddToggle({
        Name = "Auto Steal / Auto Farm",
        Default = false,
        Callback = function(v)
            values.AutoSteal = v
        end
    })

    mainTab:AddToggle({
        Name = "Auto Hatch / Auto Open Eggs",
        Default = false,
        Callback = function(v)
            values.AutoHatch = v
        end
    })

    mainTab:AddToggle({
        Name = "Auto Train / Treadmill",
        Default = false,
        Callback = function(v)
            values.AutoTrain = v
        end
    })

    mainTab:AddDropdown({
        Name = "Egg Type",
        Default = "Rare",
        Options = {"Common", "Rare", "Epic", "Legendary", "Mythic"},
        Callback = function(v)
            currentEggType = v
        end
    })

    mainTab:AddSlider({
        Name = "Farm Delay",
        Min = 0.1,
        Max = 1,
        Default = 0.25,
        Callback = function(v)
            values.DelaySteal = v
        end
    })

    mainTab:AddSlider({
        Name = "Hatch Delay",
        Min = 0.1,
        Max = 1.5,
        Default = 0.35,
        Callback = function(v)
            values.DelayHatch = v
        end
    })

    mainTab:AddSlider({
        Name = "Train Delay",
        Min = 0.1,
        Max = 1,
        Default = 0.2,
        Callback = function(v)
            values.DelayTrain = v
        end
    })

    playerTab:AddToggle({
        Name = "Noclip",
        Default = false,
        Callback = function(v)
            values.Noclip = v
        end
    })

    playerTab:AddToggle({
        Name = "Infinite Jump",
        Default = false,
        Callback = function(v)
            values.InfiniteJump = v
        end
    })

    playerTab:AddSlider({
        Name = "WalkSpeed",
        Min = 16,
        Max = 250,
        Default = 16,
        Callback = function(v)
            values.WalkSpeed = v
        end
    })

    playerTab:AddSlider({
        Name = "JumpPower",
        Min = 50,
        Max = 250,
        Default = 50,
        Callback = function(v)
            values.JumpPower = v
        end
    })

    espTab:AddToggle({
        Name = "ESP Eggs / Rares",
        Default = false,
        Callback = function(v)
            values.ESPEggs = v
        end
    })

    espTab:AddToggle({
        Name = "ESP Enemy Base",
        Default = false,
        Callback = function(v)
            values.ESPBase = v
        end
    })
else
    print("Fallback GUI initialized")
end

-- =========================
-- ESP System
-- =========================
local espObjects = {}

local function clearEsp()
    for _, v in ipairs(espObjects) do
        if v and v.Destroy then
            v:Destroy()
        end
    end
    espObjects = {}
end

local function addEspLabel(obj, color, text, size)
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
                addEspLabel(primary, Color3.fromRGB(0, 255, 150), "Egg", 12)
            end
        end

        for _, egg in ipairs(rareEggs) do
            local primary = egg.PrimaryPart or egg:FindFirstChildWhichIsA("BasePart")
            if primary then
                addEspLabel(primary, Color3.fromRGB(255, 200, 0), "Rare Egg", 12)
            end
        end
    end

    if values.ESPBase then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                addEspLabel(root, Color3.fromRGB(255, 85, 85), player.Name .. " Base", 12)
            end
        end
    end
end

-- =========================
-- Player Mods
-- =========================
local function applyPlayerMods()
    local char = localPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = values.WalkSpeed
        hum.JumpPower = values.JumpPower
    end

    if values.Noclip then
        local root = getRootPart(char)
        if root then
            root.CanCollide = false
        end
    else
        local root = getRootPart(char)
        if root then
            root.CanCollide = true
        end
    end
end

-- =========================
-- Main Automation Loops
-- =========================
local function autoStealLoop()
    while true do
        if values.AutoSteal then
            local root = getRootPart(localPlayer.Character)
            if root then
                -- detect nearest egg
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
                        if prompt then
                            if (root.Position - part.Position).Magnitude < 15 then
                                fireProximityPrompt(prompt)
                                task.wait(values.DelaySteal)
                            else
                                root.CFrame = CFrame.new(part.Position + Vector3.new(0, 4, 0))
                            end
                        end
                    end
                end

                local basePart = findBase()
                if basePart then
                    if (root.Position - basePart.Position).Magnitude > 20 then
                        root.CFrame = CFrame.new(basePart.Position + Vector3.new(0, 3, 0))
                    end
                end
            end
        end
        task.wait(0.2)
    end
end

local function autoHatchLoop()
    while true do
        if values.AutoHatch then
            local success = openEggByName(currentEggType .. " Egg")
            if not success then
                local eggName = currentEggType:lower()
                local found = false
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name:lower():find(eggName, 1, true) then
                        found = true
                        local prompt = getNearestProximityPromptFromModel(obj)
                        if prompt then
                            fireProximityPrompt(prompt)
                            break
                        end
                    end
                end

                if not found then
                    local hint = "No " .. currentEggType .. " egg found. Try a different egg type or update names."
                    -- print/hint optional
                end
            end
            task.wait(values.DelayHatch)
        end
        task.wait(0.15)
    end
end

local function autoTrainLoop()
    while true do
        if values.AutoTrain then
            local station = findTrainStation()
            if station then
                local root = getRootPart(localPlayer.Character)
                if root then
                    if (root.Position - station.Position).Magnitude > 20 then
                        root.CFrame = CFrame.new(station.Position + Vector3.new(0, 4, 0))
                    else
                        local prompt = nil
                        for _, child in ipairs(station.Parent:GetDescendants()) do
                            if child:IsA("ProximityPrompt") then
                                prompt = child
                                break
                            end
                        end
                        if prompt then
                            fireProximityPrompt(prompt)
                        end
                    end
                end
            end
            task.wait(values.DelayTrain)
        end
        task.wait(0.15)
    end
end

local function infiniteJumpLoop()
    while true do
        if values.InfiniteJump then
            local hum = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Jump = true
            end
        end
        task.wait(0.05)
    end
end

local function noclipLoop()
    while true do
        if values.Noclip then
            for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        else
            for _, part in ipairs(localPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
        task.wait(0.1)
    end
end

-- =========================
-- Runtime
-- =========================
local function startRuntime()
    task.spawn(autoStealLoop)
    task.spawn(autoHatchLoop)
    task.spawn(autoTrainLoop)
    task.spawn(infiniteJumpLoop)
    task.spawn(noclipLoop)

    local lastEsp = 0
    RunService.RenderStepped:Connect(function()
        applyPlayerMods()

        if tick() - lastEsp > 0.5 then
            updateEsp()
            lastEsp = tick()
        end
    end)
end

startRuntime()

createNotification("GUI Utility Hub", "Script loaded successfully!")

print("Steal An Egg Utility Hub loaded.")
