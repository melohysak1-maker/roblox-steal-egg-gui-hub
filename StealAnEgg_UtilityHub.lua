local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

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

for k, v in pairs(defaultSettings) do
    values[k] = v
end

-- ==================== CUSTOM GUI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UtilityHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 600)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Corner
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "GUI Utility Hub - Steal An Egg"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Scroll View
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -20, 1, -60)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollFrame

-- ==================== HELPER FUNCTIONS ====================
local function createToggleButton(parent, text, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 35)
    Container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Container.BorderSizePixel = 0
    Container.Parent = parent

    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 6)
    ContainerCorner.Parent = Container

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
    Toggle.Name = text
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

    return Toggle, function() return isEnabled end
end

local function createSlider(parent, text, min, max, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 50)
    Container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Container.BorderSizePixel = 0
    Container.Parent = parent

    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 6)
    ContainerCorner.Parent = Container

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
    Slider.Name = "Slider"
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
    local isDragging = false

    local function updateSlider(input)
        local mousePos = input.Position.X
        local sliderPos = SliderBg.AbsolutePosition.X
        local sliderSize = SliderBg.AbsoluteSize.X

        local relativePos = math.clamp(mousePos - sliderPos, 0, sliderSize)
        local percentage = relativePos / sliderSize

        currentValue = math.floor(min + (max - min) * percentage)
        currentValue = math.clamp(currentValue, min, max)

        local newPosition = (currentValue - min) / (max - min)
        Slider.Position = UDim2.new(newPosition, -6, 0.5, -6)

        Label.Text = text .. ": " .. tostring(currentValue)
        callback(currentValue)
    end

    Slider.MouseButton1Down:Connect(function()
        isDragging = true
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    return Slider
end

local function createDropdown(parent, text, options, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 35)
    Container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Container.BorderSizePixel = 0
    Container.Parent = parent

    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 6)
    ContainerCorner.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 150, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local DropButton = Instance.new("TextButton")
    DropButton.Size = UDim2.new(0, 100, 0, 25)
    DropButton.Position = UDim2.new(1, -110, 0.5, -12)
    DropButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    DropButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropButton.Text = default
    DropButton.Font = Enum.Font.Gotham
    DropButton.TextSize = 12
    DropButton.BorderSizePixel = 0
    DropButton.Parent = Container

    local DropCorner = Instance.new("UICorner")
    DropCorner.CornerRadius = UDim.new(0, 4)
    DropCorner.Parent = DropButton

    local DropMenu = Instance.new("Frame")
    DropMenu.Name = "DropMenu"
    DropMenu.Size = UDim2.new(0, 100, 0, #options * 25)
    DropMenu.Position = UDim2.new(1, -110, 1, 5)
    DropMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    DropMenu.BorderSizePixel = 0
    DropMenu.Visible = false
    DropMenu.Parent = Container

    local MenuCorner = Instance.new("UICorner")
    MenuCorner.CornerRadius = UDim.new(0, 4)
    MenuCorner.Parent = DropMenu

    for _, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 25)
        OptionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        OptionButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        OptionButton.Text = option
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextSize = 12
        OptionButton.BorderSizePixel = 0
        OptionButton.Parent = DropMenu

        OptionButton.MouseButton1Click:Connect(function()
            DropButton.Text = option
            DropMenu.Visible = false
            callback(option)
        end)

        OptionButton.MouseEnter:Connect(function()
            OptionButton.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end)

        OptionButton.MouseLeave:Connect(function()
            OptionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end)
    end

    DropButton.MouseButton1Click:Connect(function()
        DropMenu.Visible = not DropMenu.Visible
    end)

    return DropButton
end

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

-- ==================== BUILD GUI ====================
createLabel(ScrollFrame, "AUTO FARM")
local toggleAutoSteal = createToggleButton(ScrollFrame, "Auto Steal / Auto Farm", false, function(v) values.AutoSteal = v end)
createSlider(ScrollFrame, "Farm Delay", 0.1, 2, 0.25, function(v) values.DelaySteal = v end)

createLabel(ScrollFrame, "AUTO HATCH")
local toggleAutoHatch = createToggleButton(ScrollFrame, "Auto Hatch / Open Eggs", false, function(v) values.AutoHatch = v end)
createDropdown(ScrollFrame, "Egg Type", {"Common", "Rare", "Epic", "Legendary", "Mythic"}, "Common", function(v) currentEggType = v end)
createSlider(ScrollFrame, "Hatch Delay", 0.1, 2, 0.35, function(v) values.DelayHatch = v end)

createLabel(ScrollFrame, "AUTO TRAIN")
local toggleAutoTrain = createToggleButton(ScrollFrame, "Auto Train / Treadmill", false, function(v) values.AutoTrain = v end)
createSlider(ScrollFrame, "Train Delay", 0.1, 2, 0.2, function(v) values.DelayTrain = v end)

createLabel(ScrollFrame, "PLAYER MODS")
createSlider(ScrollFrame, "WalkSpeed", 16, 250, 16, function(v) values.WalkSpeed = v end)
createSlider(ScrollFrame, "JumpPower", 50, 250, 50, function(v) values.JumpPower = v end)
local toggleInfJump = createToggleButton(ScrollFrame, "Infinite Jump", false, function(v) values.InfiniteJump = v end)
local toggleNoclip = createToggleButton(ScrollFrame, "Noclip", false, function(v) values.Noclip = v end)

createLabel(ScrollFrame, "ESP")
local toggleESPEggs = createToggleButton(ScrollFrame, "ESP Eggs / Rares", false, function(v) values.ESPEggs = v end)
local toggleESPBase = createToggleButton(ScrollFrame, "ESP Enemy Base", false, function(v) values.ESPBase = v end)

-- ==================== HELPER FUNCTIONS ====================
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
            local found = false

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

print("✓ GUI Utility Hub loaded!")
