local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

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

-- ==================== RAYFIELD LOAD ====================
local Rayfield = nil
local Window = nil

local raySuccess = pcall(function()
    Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua"))()
    
    Window = Rayfield:CreateWindow({
        Name = "Illegal Soccer Hub",
        LoadingTitle = "Loading Illegal Soccer Hub",
        LoadingSubtitle = "by Copilot",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "IllegalSoccerHub",
            FileName = "Config"
        },
        KeySystem = false,
    })
end)

if not raySuccess or not Window then
    print("Rayfield failed to load, using fallback GUI")
    Rayfield = nil
    Window = nil
end

-- ==================== FALLBACK GUI ====================
local fallbackScreen = nil

local function createFallbackGui()
    if fallbackScreen then return end
    
    fallbackScreen = Instance.new("ScreenGui")
    fallbackScreen.Name = "FallbackSoccerHub"
    fallbackScreen.ResetOnSpawn = false
    fallbackScreen.Parent = CoreGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = fallbackScreen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Illegal Soccer Hub - Fallback"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.Parent = mainFrame

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 8)
    uiListLayout.Parent = scrollFrame

    local function createLabel(text)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(100, 200, 150)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = scrollFrame
        return label
    end

    local function createToggle(labelText, default, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 35)
        container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        container.BorderSizePixel = 0
        container.Parent = scrollFrame

        local containerCorner = Instance.new("UICorner")
        containerCorner.CornerRadius = UDim.new(0, 6)
        containerCorner.Parent = container

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 250, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.Font = Enum.Font.Gotham
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 45, 0, 22)
        toggle.Position = UDim2.new(1, -55, 0.5, -11)
        toggle.BackgroundColor3 = default and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(50, 50, 50)
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.Text = default and "ON" or "OFF"
        toggle.Font = Enum.Font.GothamBold
        toggle.TextSize = 10
        toggle.BorderSizePixel = 0
        toggle.Parent = container

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 4)
        toggleCorner.Parent = toggle

        local isEnabled = default

        toggle.MouseButton1Click:Connect(function()
            isEnabled = not isEnabled
            toggle.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(50, 50, 50)
            toggle.Text = isEnabled and "ON" or "OFF"
            callback(isEnabled)
        end)

        return toggle
    end

    local function createSlider(labelText, min, max, default, callback)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 50)
        container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        container.BorderSizePixel = 0
        container.Parent = scrollFrame

        local containerCorner = Instance.new("UICorner")
        containerCorner.CornerRadius = UDim.new(0, 6)
        containerCorner.Parent = container

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 250, 0, 15)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = labelText .. ": " .. tostring(default)
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.Font = Enum.Font.Gotham
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container

        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -20, 0, 4)
        sliderBg.Position = UDim2.new(0, 10, 0, 25)
        sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        sliderBg.BorderSizePixel = 0
        sliderBg.Parent = container

        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 2)
        sliderCorner.Parent = sliderBg

        local slider = Instance.new("TextButton")
        slider.Size = UDim2.new(0, 12, 0, 12)
        slider.Position = UDim2.new(0, 10, 0.5, -6)
        slider.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        slider.Text = ""
        slider.BorderSizePixel = 0
        slider.Parent = sliderBg

        local sliderCorner2 = Instance.new("UICorner")
        sliderCorner2.CornerRadius = UDim.new(0, 6)
        sliderCorner2.Parent = slider

        local currentValue = default
        local dragging = false

        local function updateSlider(mouseX)
            local minX = sliderBg.AbsolutePosition.X
            local maxX = minX + sliderBg.AbsoluteSize.X
            local percent = math.clamp((mouseX - minX) / (maxX - minX), 0, 1)
            currentValue = math.floor(min + (max - min) * percent)
            currentValue = math.clamp(currentValue, min, max)

            local p = (currentValue - min) / (max - min)
            slider.Position = UDim2.new(p, -6, 0.5, -6)
            label.Text = labelText .. ": " .. tostring(currentValue)
            callback(currentValue)
        end

        slider.MouseButton1Down:Connect(function()
            dragging = true
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input.Position.X)
            end
        end)

        return slider
    end

    -- BUILD FALLBACK GUI
    createLabel("STAMINA")
    createToggle("Infinite Stamina", false, function(v)
        settings.InfiniteStamina = v
        getgenv().infstamina = v
    end)

    createLabel("AUTO ACTIONS")
    createToggle("Auto Sprint", false, function(v) settings.AutoSprint = v end)
    createToggle("Auto Pass", false, function(v) settings.AutoPass = v end)
    createToggle("Auto Shoot", false, function(v) settings.AutoShoot = v end)
    createSlider("Action Delay", 0.1, 2, 0.5, function(v) settings.DelayAutoAction = v end)

    createLabel("PLAYER MODS")
    createSlider("WalkSpeed", 16, 250, 16, function(v) settings.WalkSpeed = v end)
    createSlider("JumpPower", 50, 250, 50, function(v) settings.JumpPower = v end)
    createToggle("Infinite Jump", false, function(v) settings.InfiniteJump = v end)
    createToggle("Noclip", false, function(v) settings.Noclip = v end)

    createLabel("ESP")
    createToggle("ESP Players", false, function(v) settings.ESPPlayers = v end)

    return fallbackScreen
end

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
if Window then
    local MainTab = Window:CreateTab("Main", 4483345998)
    local PlayerTab = Window:CreateTab("Player", 4483345998)
    local ESPTab = Window:CreateTab("ESP", 4483345998)

    MainTab:CreateToggle({
        Name = "Infinite Stamina",
        CurrentValue = false,
        Flag = "InfiniteStamina",
        Callback = function(value)
            settings.InfiniteStamina = value
            getgenv().infstamina = value
        end,
    })

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

    Rayfield:Notify({
        Title = "Illegal Soccer Hub",
        Content = "Rayfield loaded successfully!",
        Duration = 5,
        Image = 4483345998,
    })
else
    createFallbackGui()
    print("Using fallback GUI - Rayfield not available")
end

-- ==================== RUNTIME ====================
task.spawn(infiniteJumpLoop)
task.spawn(autoActionLoop)

RunService.RenderStepped:Connect(function()
    applyPlayerMods()
    updateESP()
end)

print("Illegal Soccer Hub loaded!")
