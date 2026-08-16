local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/UI-Interface/CustomFIeld/main/RayField.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "Project Slayers Hub",
    LoadingTitle = "Loading Interface...",
    LoadingSubtitle = "by thirty",
    ConfigurationSaving = { Enabled = false },
    
    -- Key System Setup
    KeySystem = true,
    KeySettings = {
        Title = "Project Slayers | Key System",
        Subtitle = "Access Verification",
        Note = "Join our Discord for the key: discord.gg/nigger",
        FileName = "ProjectSlayersKeyConfigg",
        SaveKey = false, -- Set to true if you want to remember the key across sessions
        GrabKeyFromSite = false, -- Keep false for plain text keys
        Key = "PSHKeyCool" -- Single string key to prevent format bugs
    }
})

-- ==================== TELEPORTS TAB ====================
local TPTab = Window:CreateTab("Teleports", 4483362458)

-- --- SERVER INFO SECTION ---
TPTab:CreateSection("Server Info", false)

local function formatServerAge(seconds)
    seconds = math.floor(tonumber(seconds) or 0)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02dh %02dm %02ds", hours, minutes, secs)
end

local function formatDayNight(val)
    local num = tonumber(val) or 0
    local hours = math.floor(num)
    local minutes = math.floor((num - hours) * 60)
    local timeStr = string.format("%02d:%02d", hours, minutes)
    
    local isNight = (num >= 16.5) or (num < 6)
    local status = isNight and "🌙 Night" or "☀️ Day"
    
    return string.format("%s (%s)", status, timeStr)
end

local serverAgeLabel = TPTab:CreateLabel("Server Age: Loading...", nil)
local dayNightLabel = TPTab:CreateLabel("Time Cycle: Loading...", nil)

task.spawn(function()
    while task.wait(1) do
        local serverAgeVal = workspace:FindFirstChild("Server_Age")
        if serverAgeVal and serverAgeVal:IsA("ValueBase") then
            serverAgeLabel:Set("Server Age: " .. formatServerAge(serverAgeVal.Value), nil)
        else
            serverAgeLabel:Set("Server Age: Not Found", nil)
        end

        local dayNightVal = workspace:FindFirstChild("DayNNight")
        if dayNightVal and dayNightVal:IsA("ValueBase") then
            dayNightLabel:Set("Time Cycle: " .. formatDayNight(dayNightVal.Value), nil)
        else
            dayNightLabel:Set("Time Cycle: Not Found", nil)
        end
    end
end)

-- --- TELEPORT SETTINGS ---
TPTab:CreateSection("Teleport Settings", false)

local travelTime = 2

TPTab:CreateSlider({
    Name = "Tween Duration (Sec)",
    Info = "Travel duration in seconds",
    Range = {0.5, 10},
    Increment = 0.5,
    Suffix = "s",
    CurrentValue = 2,
    Flag = "TweenSpeedSlider",
    Callback = function(Value)
        travelTime = Value
    end,
})

-- Safe Tween Function с авто-ноклипом во время полёта
local function tweenToCFrame(targetCFrame, locationName)
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart", 5)
    
    if not rootPart then 
        return Rayfield:Notify({Title = "Error", Content = "Character not found!", Duration = 3})
    end

    -- Включаем Noclip на период полёта
    local noclipConnection
    noclipConnection = RunService.Stepped:Connect(function()
        if character then
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)

    local tweenInfo = TweenInfo.new(
        travelTime,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()

    Rayfield:Notify({Title = "Teleporting", Content = "Moving to " .. locationName .. "...", Duration = 2})

    tween.Completed:Connect(function()
        if noclipConnection then
            noclipConnection:Disconnect()
        end
    end)
end

-- --- LOCATIONS SECTION ---
TPTab:CreateSection("Key NPCs & Bosses", false)

TPTab:CreateButton({
    Name = "TP to Muzan",
    Interact = "Teleport",
    Callback = function()
        local muzan = workspace:FindFirstChild("Muzan")
        if not muzan or not muzan:FindFirstChild("SpawnPos") then
            return Rayfield:Notify({Title = "Error", Content = "Muzan not found!", Duration = 3})
        end
        local spawnPos = muzan.SpawnPos.Value
        local targetCFrame = CFrame.new(spawnPos + Vector3.new(0, 10, 0))
        tweenToCFrame(targetCFrame, "Muzan")
    end,
})

local higoshimaCFrame = CFrame.new(
    525.667603, 321.392609 + 3, -2304.71729,
    -0.655203104, 0, 0.755452693,
    0, 1, 0,
    -0.755452693, 0, -0.655203104
)

TPTab:CreateButton({
    Name = "TP to Doctor Higoshima",
    Interact = "Teleport",
    Callback = function()
        tweenToCFrame(higoshimaCFrame, "Doctor Higoshima")
    end,
})

TPTab:CreateSection("Trainers & Villages", false)

TPTab:CreateButton({
    Name = "TP to Water Trainer (Urokodaki)",
    Interact = "Teleport",
    Callback = function()
        tweenToCFrame(CFrame.new(706, 344, -2410), "Water Trainer")
    end,
})

-- Исправленные координаты для Wind Trainer
TPTab:CreateButton({
    Name = "TP to Thunder Trainer (Jigoro)",
    Interact = "Teleport",
    Callback = function()
        tweenToCFrame(CFrame.new(-319.431122, 428.94455, -2383.9563, 0, 0, 1, 0, 1, 0, -1, 0, 0), "Thunder Trainer")
    end,
})

-- Исправленные координаты для Kiribating Village
TPTab:CreateButton({
    Name = "TP to Kiribating Village",
    Interact = "Teleport",
    Callback = function()
        tweenToCFrame(CFrame.new(125, 282, -1610), "Kiribating Village")
    end,
})

-- ==================== VISUALS TAB ====================
local VisualsTab = Window:CreateTab("Visuals", 4483362458)

-- --- MUZAN ESP ---
VisualsTab:CreateSection("Muzan ESP", false)

local muzanEspEnabled = false
local muzanHighlight = nil
local muzanBillboard = nil

local function removeMuzanESP()
    if muzanHighlight then muzanHighlight:Destroy() muzanHighlight = nil end
    if muzanBillboard then muzanBillboard:Destroy() muzanBillboard = nil end
end

local function applyMuzanESP()
    removeMuzanESP()
    if not muzanEspEnabled then return end

    local muzan = workspace:FindFirstChild("Muzan")
    if not muzan then
        return Rayfield:Notify({Title = "ESP Error", Content = "Muzan not found in Workspace!", Duration = 3})
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "MuzanHighlight"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.Adornee = muzan
    highlight.Parent = muzan
    muzanHighlight = highlight

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MuzanESPText"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)

    local targetPart = muzan:FindFirstChild("Head") or muzan:FindFirstChild("HumanoidRootPart") or muzan:FindFirstChildWhichIsA("BasePart")
    billboard.Adornee = targetPart or muzan

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "MUZAN"
    textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = 20
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard

    billboard.Parent = muzan
    muzanBillboard = billboard
end

VisualsTab:CreateToggle({
    Name = "Muzan ESP",
    CurrentValue = false,
    Flag = "MuzanESPToggle",
    Callback = function(Value)
        muzanEspEnabled = Value
        if muzanEspEnabled then applyMuzanESP() else removeMuzanESP() end
    end,
})

-- --- DOCTOR HIGOSHIMA ESP ---
VisualsTab:CreateSection("Doctor Higoshima ESP", false)

local docEspEnabled = false
local docBillboard = nil
local docHighlight = nil
local docAttachment = nil

local function removeDocESP()
    if docHighlight then docHighlight:Destroy() docHighlight = nil end
    if docBillboard then docBillboard:Destroy() docBillboard = nil end
    if docAttachment then docAttachment:Destroy() docAttachment = nil end
end

local function applyDocESP()
    removeDocESP()
    if not docEspEnabled then return end

    local basePos = Vector3.new(525.667603, 321.392609, -2304.71729)
    local docModel = workspace:FindFirstChild("Doctor Higoshima") or workspace:FindFirstChild("Higoshima")

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DocESPText"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)

    if docModel then
        local targetPart = docModel:FindFirstChild("Head") or docModel:FindFirstChild("HumanoidRootPart") or docModel:FindFirstChildWhichIsA("BasePart")
        billboard.Adornee = targetPart or docModel

        local highlight = Instance.new("Highlight")
        highlight.Name = "DocHighlight"
        highlight.FillColor = Color3.fromRGB(0, 255, 128)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.Adornee = docModel
        highlight.Parent = docModel
        docHighlight = highlight
    else
        local attachment = Instance.new("Attachment")
        attachment.Name = "DocESPAttachment"
        attachment.WorldPosition = basePos
        attachment.Parent = workspace.Terrain
        docAttachment = attachment
        
        billboard.Adornee = attachment
    end

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "Doctor Higoshima"
    textLabel.TextColor3 = Color3.fromRGB(0, 255, 128)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextSize = 20
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard

    billboard.Parent = workspace
    docBillboard = billboard
end

VisualsTab:CreateToggle({
    Name = "Doctor Higoshima ESP",
    CurrentValue = false,
    Flag = "DocESPToggle",
    Callback = function(Value)
        docEspEnabled = Value
        if docEspEnabled then applyDocESP() else removeDocESP() end
    end,
})

-- ==================== PLAYER TAB ====================
local PlayerTab = Window:CreateTab("Player", 4483362458)
PlayerTab:CreateSection("Movement Settings", false)

local infiniteJumpEnabled = false

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Info = "Modify your character's speed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        local char = player.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "JumpPower",
    Info = "Modify your character's jump height",
    Range = {50, 300},
    Increment = 5,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpPowerSlider",
    Callback = function(Value)
        local char = player.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            hum.UseJumpPower = true
            hum.JumpPower = Value
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    Info = "Jump indefinitely in mid-air",
    CurrentValue = false,
    Flag = "InfJumpToggle",
    Callback = function(Value)
        infiniteJumpEnabled = Value
    end,
})

-- Обработчик Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local char = player.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- --- MUZAN SPAWN ANNOUNCER ---
task.spawn(function()
    local muzan = workspace:WaitForChild("Muzan", 10)
    if muzan and muzan:FindFirstChild("SpawnPos") then
        muzan.SpawnPos:GetPropertyChangedSignal("Value"):Connect(function()
            Rayfield:Notify({
                Title = "🚨 MUZAN HAS SPAWNED!",
                Content = "Muzan's location has updated in Workspace!",
                Duration = 6
            })
            if muzanEspEnabled then
                applyMuzanESP()
            end
        end)
    end
end)
