local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local values = {}

local defaultSettings = {
    InfiniteStamina = false,
    AutoSprint = false,
    AutoPass = false,
    AutoShoot = false,
    WalkSpeed = 16,
    JumpPower = 50,
    Noclip = false,
    InfiniteJump = false,
    ESPPlayers = false,
    DelayAutoAction = 0.5
}

for k, v in pairs(defaultSettings) do
    values[k] = v
end

-- ==================== INFINITE STAMINA SETUP ====================
getgenv().infstamina = false

local function setupInfiniteStamina()
    local success = false
    
    pcall(function()
        local Sprint = require(ReplicatedStorage.Modules.Actions.Sprint)
        
        if Sprint then
            local OldDrain = Sprint.GetDrainAmount
            Sprint.GetDrainAmount = function(...)
                if getgenv().infstamina then
                    return 0
                end
                return OldDrain(...)
            end
            
            local OldSpend = Sprint.GetSpendAmount
            Sprint.GetSpendAmount = function(...)
                if getgenv().infstamina then
                    return 0
                end
                return OldSpend(...)
            end
            
            success = true
        end
    end)
    
    pcall(function()
        local BallHit = require(ReplicatedStorage.Modules.Actions.BallHitStamina)
        
        if BallHit then
            local OldCost = BallHit.GetCost
            BallHit.GetCost = function(...)
                if getgenv().infstamina then
                    return 0
                end
                return OldCost(...)
            end
            
            success = true
        end
    end)
    
    return success
end

setupInfiniteStamina()

-- ==================== GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IllegalSoccerHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 650)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -325)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "GUI Hub - Illegal Soccer"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollFrame

-- ==================== HELPER GUI FUNCTIONS ====================
local function createLabel(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(100, 200, 150)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
    return Label
end

local function createToggleButton(parent, text, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 35)
    Container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Container.BorderSizePixel = 0
    Container.Parent = parent

    local Corner2 = Instance.new("UICorner")
    Corner2.CornerRadius = UDim.new(0, 6)
    Corner2.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 250, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 45, 0, 22)
    Toggle.Position = UDim2.new(1, -55, 0.5, -11)
    Toggle.BackgroundColor3 = default and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(50, 50, 50)
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.Text = default and "ON" or "OFF"
    Toggle.Font = Enum.Font.GothamBold
    Toggle.TextSize = 11
    Toggle.BorderSizePixel = 0
    Toggle.Parent = Container

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 4)
    ToggleCorner.Parent = Toggle

    local isEnabled = default

    Toggle.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        Toggle.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(50, 50, 50)
        Toggle.Text = isEnabled and "ON" or "OFF"
        callback(isEnabled)
    end)

    return Toggle
end

local function createSlider(parent, text, min, max, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 50)
    Container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Container.BorderSizePixel = 0
    Container.Parent = parent

    local Corner2 = Instance.new("UICorner")
    Corner2.CornerRadius = UDim.new(0, 6)
    Corner2.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 250, 0, 15)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text .. ": " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local SliderBg = Instance.new("Frame")
    SliderBg.Size = UDim2.new(1, -20, 0, 4)
    SliderBg.Position = UDim2.new(0, 10, 0, 25)
    SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderBg.BorderSizePixel = 0
    SliderBg.Parent = Container

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 2)
    SliderCorner.Parent = SliderBg

    local Slider = Instance.new("TextButton")
    Slider.Size = UDim2.new(0, 12, 0, 12)
    Slider.Position = UDim2.new(0, 10, 0.5, -6)
    Slider.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    Slider.Text = ""
    Slider.BorderSizePixel = 0
    Slider.Parent = SliderBg

    local SliderCorner2 = Instance.new("UICorner")
    SliderCorner2.CornerRadius = UDim.new(0, 6)
    SliderCorner2.Parent = Slider

    local currentValue = default
    local dragging = false

    local function updateSliderFromMouse(mouseX)
        local minX = SliderBg.AbsolutePosition.X
        local maxX = minX + SliderBg.AbsoluteSize.X
        local percent = math.clamp((mouseX - minX) / (maxX - minX), 0, 1)
        currentValue = math.floor(min + (max - min) * percent)
        currentValue = math.clamp(currentValue, min, max)

        local p = (currentValue - min) / (max - min)
        Slider.Position = UDim2.new(p, -6, 0.5, -6)
        Label.Text = text .. ": " .. tostring(currentValue)
        callback(currentValue)
    end

    Slider.MouseButton1Down:Connect(function()
        dragging = true
    end)

    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSliderFromMouse(input.Position.X)
        end
    end)

    return Slider
end

-- ==================== BUILD GUI ====================
createLabel(ScrollFrame, "STAMINA")
createToggleButton(ScrollFrame, "Infinite Stamina", false, function(v) 
    values.InfiniteStamina = v
    getgenv().infstamina = v
end)

createLabel(ScrollFrame, "AUTO ACTIONS")
createToggleButton(ScrollFrame, "Auto Sprint", false, function(v) values.AutoSprint = v end)
createToggleButton(ScrollFrame, "Auto Pass", false, function(v) values.AutoPass = v end)
createToggleButton(ScrollFrame, "Auto Shoot", false, function(v) values.AutoShoot = v end)
createSlider(ScrollFrame, "Action Delay", 0.1, 2, 0.5, function(v) values.DelayAutoAction = v end)

createLabel(ScrollFrame, "PLAYER MODS")
createSlider(ScrollFrame, "WalkSpeed", 16, 250, 16, function(v) values.WalkSpeed = v end)
createSlider(ScrollFrame, "JumpPower", 50, 250, 50, function(v) values.JumpPower = v end)
createToggleButton(ScrollFrame, "Infinite Jump", false, function(v) values.InfiniteJump = v end)
createToggleButton(ScrollFrame, "Noclip", false, function(v) values.Noclip = v end)

createLabel(ScrollFrame, "ESP")
createToggleButton(ScrollFrame, "ESP Players", false, function(v) values.ESPPlayers = v end)

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

task.spawn(infiniteJumpLoop)

RunService.RenderStepped:Connect(function()
    applyPlayerMods()
end)

print("✓ Illegal Soccer Hub loaded!")
print("✓ Infinite Stamina: " .. tostring(values.InfiniteStamina))
