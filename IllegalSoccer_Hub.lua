local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer

local settings = {
    InfiniteStamina = false,
    AutoSprint = false,
    AutoPass = false,
    AutoShoot = false,
    WalkSpeed = 16,
    JumpPower = 50,
    Noclip = false,
    InfiniteJump = false,
    ESPPlayers = false,
    DelayAutoAction = 0.5,
}

getgenv().infstamina = false

-- ==================== RAYFIELD LIBRARY ====================
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua"))()

local Window = Rayfield:CreateWindow({
    Name = "Illegal Soccer Hub",
    LoadingTitle = "Loading Illegal Soccer Hub",
    LoadingSubtitle = "By Copilot",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "IllegalSoccerHub",
        FileName = "Config"
    },
    KeySystem = false,
})

-- ==================== INFINITE STAMINA SETUP ====================
local function hookInfiniteStamina()
    local SprintSuccess, SprintModule = pcall(function()
        return require(ReplicatedStorage.Modules.Actions.Sprint)
    end)

    if SprintSuccess and SprintModule then
        local oldDrain = SprintModule.GetDrainAmount
        SprintModule.GetDrainAmount = function(...)
            if getgenv().infstamina then
                return 0
            end
            return oldDrain(...)
        end

        local oldSpend = SprintModule.GetSpendAmount
        SprintModule.GetSpendAmount = function(...)
            if getgenv().infstamina then
                return 0
            end
            return oldSpend(...)
        end
    end

    local BallHitSuccess, BallHitModule = pcall(function()
        return require(ReplicatedStorage.Modules.Actions.BallHitStamina)
    end)

    if BallHitSuccess and BallHitModule then
        local oldCost = BallHitModule.GetCost
        BallHitModule.GetCost = function(...)
            if getgenv().infstamina then
                return 0
            end
            return oldCost(...)
        end
    end
end

hookInfiniteStamina()

-- ==================== UTILITY FUNCTIONS ====================
local function getRootPart(character)
    if character and character:FindFirstChild("HumanoidRootPart") then
        return character.HumanoidRootPart
    end
end

local function getPlayersList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(list, player)
        end
    end
    return list
end

local espLabels = {}

local function clearESP()
    for _, label in ipairs(espLabels) do
        if label and label.Parent then
            label:Destroy()
        end
    end
    espLabels = {}
end

local function addESPLabel(target, text, color)
    if not target or not target.Parent then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPLabel"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 180, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = target
    billboard.Parent = target

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

    table.insert(espLabels, billboard)
end

local function updateESP()
    clearESP()
    if not settings.ESPPlayers then return end

    for _, player in ipairs(getPlayersList()) do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            addESPLabel(char.HumanoidRootPart, player.Name, Color3.fromRGB(255, 70, 70))
        end
    end
end

local function applyPlayerMods()
    if not localPlayer.Character then return end
    local char = localPlayer.Character
    local hum = char:FindFirstChildOfClass("Humanoid")

    if hum then
        hum.WalkSpeed = settings.WalkSpeed
        hum.JumpPower = settings.JumpPower
    end

    if settings.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

local function infiniteJumpLoop()
    while true do
        if settings.InfiniteJump and localPlayer.Character then
            local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Jump = true
            end
        end
        task.wait(0.05)
    end
end

local function autoActionLoop()
    while true do
        if localPlayer.Character then
            if settings.AutoSprint then
                local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:Move(Vector3.new(1, 0, 0), true)
                end
            end
        end
        task.wait(settings.DelayAutoAction)
    end
end

-- ==================== RAYFIELD TABS ====================

-- ==================== MAIN TAB ====================
local MainTab = Window:CreateTab("Main", 4483345998)
local MainSection = MainTab:CreateSection("Stamina")

MainTab:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Flag = "InfiniteStamina",
    Callback = function(value)
        settings.InfiniteStamina = value
        getgenv().infstamina = value
    end,
})

local AutoActionsSection = MainTab:CreateSection("Auto Actions")

MainTab:CreateToggle({
    Name = "Auto Sprint",
    CurrentValue = false,
    Flag = "AutoSprint",
    Callback = function(value)
        settings.AutoSprint = value
    end,
})

MainTab:CreateToggle({
    Name = "Auto Pass",
    CurrentValue = false,
    Flag = "AutoPass",
    Callback = function(value)
        settings.AutoPass = value
    end,
})

MainTab:CreateToggle({
    Name = "Auto Shoot",
    CurrentValue = false,
    Flag = "AutoShoot",
    Callback = function(value)
        settings.AutoShoot = value
    end,
})

MainTab:CreateSlider({
    Name = "Action Delay",
    Range = {0.1, 2},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 0.5,
    Flag = "ActionDelay",
    Callback = function(value)
        settings.DelayAutoAction = value
    end,
})

-- ==================== PLAYER TAB ====================
local PlayerTab = Window:CreateTab("Player", 4483345998)
local SpeedSection = PlayerTab:CreateSection("Speed & Jump")

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 250},
    Increment = 1,
    Suffix = "",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(value)
        settings.WalkSpeed = value
    end,
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 250},
    Increment = 1,
    Suffix = "",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(value)
        settings.JumpPower = value
    end,
})

local ModifiersSection = PlayerTab:CreateSection("Modifiers")

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(value)
        settings.InfiniteJump = value
    end,
})

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(value)
        settings.Noclip = value
    end,
})

-- ==================== ESP TAB ====================
local ESPTab = Window:CreateTab("ESP", 4483345998)
local ESPSection = ESPTab:CreateSection("Visual")

ESPTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = false,
    Flag = "ESPPlayers",
    Callback = function(value)
        settings.ESPPlayers = value
        if not value then
            clearESP()
        end
    end,
})

ESPTab:CreateButton({
    Name = "Clear ESP",
    Callback = function()
        clearESP()
        Rayfield:Notify({
            Title = "ESP",
            Content = "Cleared all ESP labels",
            Duration = 3,
            Image = 4483345998,
        })
    end,
})

-- ==================== INFO TAB ====================
local InfoTab = Window:CreateTab("Info", 4483345998)
local InfoSection = InfoTab:CreateSection("About")

InfoTab:CreateLabel("Illegal Soccer Hub v1.0")
InfoTab:CreateLabel("Created by Copilot")
InfoTab:CreateLabel("")
InfoTab:CreateLabel("Features:")
InfoTab:CreateLabel("✓ Infinite Stamina")
InfoTab:CreateLabel("✓ Auto Sprint")
InfoTab:CreateLabel("✓ Player Mods")
InfoTab:CreateLabel("✓ Noclip & Infinite Jump")
InfoTab:CreateLabel("✓ ESP System")

InfoTab:CreateLabel("")
InfoTab:CreateLabel("Note: This is for")
InfoTab:CreateLabel("educational purposes only.")

-- ==================== RUNTIME ====================
Rayfield:Notify({
    Title = "Illegal Soccer Hub",
    Content = "Script loaded successfully!",
    Duration = 5,
    Image = 4483345998,
})

task.spawn(infiniteJumpLoop)
task.spawn(autoActionLoop)

local lastESPUpdate = 0
RunService.RenderStepped:Connect(function()
    applyPlayerMods()
    
    if tick() - lastESPUpdate > 0.5 then
        updateESP()
        lastESPUpdate = tick()
    end
end)

print("✓ Illegal Soccer Hub loaded with Rayfield!")
