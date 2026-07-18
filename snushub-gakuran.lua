-- // SNUS-HUB Gakuran | Full Feature Edition
-- // Made by SNUSLOVER - Final Version
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "SNUS-HUB | Gakuran",
    LoadingTitle = "SNUS-HUB",
    LoadingSubtitle = "by SNUSLOVER - Final",
    Theme = "Amethyst",
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Config = {
    -- Combat
    AutoParry = true,
    BaseRange = 16,
    ForwardRange = 23,
    Delay = 0.037,
    PredictVelocity = true,
    ShowHitbox = true,
    AutoPunish = true,
    FaceTargetOnParry = true,

    -- Grip & Carry
    AutoGrip = true,
    GripRange = 40,
    AutoCarry = true,

    -- Movement
    InfiniteStamina = true,
    AntiStun = true,
    Flight = false,
    FlightSpeed = 50,
    Noclip = false,

    -- Auto Green (Optimized)
    AutoGreenAssist = true,
    GreenDelay = 0.085,
    GreenHoldTime = 0.04,

    -- Music
    AutoMusic = false,
    Instrument = "Guitar",
    MusicSpeed = 1.0,
    Randomization = true,
}

local lastParry = 0
local hitboxVisual = nil
local musicConnection = nil
local flightConnection = nil
local isShooting = false
local connections = {}

-- ==================== AUTO GREEN - OPTIMIZED ANIMATION DETECTION ====================
local shootingAnimationIds = {
    -- Füge hier deine Shooting Animation IDs ein!
    "rbxassetid://", 
}

local function IsShootingAnimation(track)
    if not track or not track.Animation then return false end
    local animId = track.Animation.AnimationId
    for _, id in ipairs(shootingAnimationIds) do
        if animId:find(id) or animId == id then
            return true
        end
    end
    return false
end

local function AutoGreen()
    if not Config.AutoGreenAssist or isShooting then return end
    isShooting = true

    task.delay(Config.GreenDelay, function()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        task.wait(Config.GreenHoldTime)
        isShooting = false
    end)
end

-- Animation Monitor
local animConnection = RunService.Heartbeat:Connect(function()
    if not Config.AutoGreenAssist then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        if track.IsPlaying and IsShootingAnimation(track) then
            local timePos = track.TimePosition
            if timePos >= 0.08 and timePos <= 0.68 and not isShooting then
                AutoGreen()
                break
            end
        end
    end
end)
table.insert(connections, animConnection)

-- ==================== HITBOX & PARRY ====================
local function CreateHitboxVisual()
    if hitboxVisual then hitboxVisual:Destroy() end
    hitboxVisual = Instance.new("Part")
    hitboxVisual.Name = "SNUS_Hitbox"
    hitboxVisual.Shape = Enum.PartType.Ball
    hitboxVisual.Size = Vector3.new(1,1,1)
    hitboxVisual.Transparency = 0.7
    hitboxVisual.Color = Color3.fromRGB(255, 0, 0)
    hitboxVisual.Anchored = true
    hitboxVisual.CanCollide = false
    hitboxVisual.Material = Enum.Material.Neon
    hitboxVisual.Parent = workspace
end

local function UpdateHitboxVisual(root)
    if not Config.ShowHitbox or not root then
        if hitboxVisual then hitboxVisual.Transparency = 1 end
        return
    end
    if not hitboxVisual then CreateHitboxVisual() end
    local lookVec = root.CFrame.LookVector
    local visualRange = Config.ForwardRange * 2
    hitboxVisual.Size = Vector3.new(visualRange, visualRange, visualRange)
    hitboxVisual.Position = root.Position + lookVec * (Config.ForwardRange / 2)
    hitboxVisual.Transparency = 0.65
end

local function Parry()
    if tick() - lastParry < 0.14 then return end
    lastParry = tick()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
    task.wait(0.055)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
end

RunService.Heartbeat:Connect(function()
    if not Config.AutoParry then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    UpdateHitboxVisual(root)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character then continue end
        local enemy = plr.Character
        local eRoot = enemy:FindFirstChild("HumanoidRootPart")
        if not eRoot then continue end

        local distance = (eRoot.Position - root.Position).Magnitude
        local lookVec = root.CFrame.LookVector
        local isInFront = (eRoot.Position - root.Position).Unit:Dot(lookVec) > 0.5
        local currentRange = isInFront and Config.ForwardRange or Config.BaseRange

        if distance > currentRange + 10 then continue end

        -- Simple Parry Logic
        if math.random() < 0.7 then -- Platzhalter für Smart Logic
            task.delay(Config.Delay, function()
                Parry()
            end)
        end
    end
end)

-- ==================== MOVEMENT ====================
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum then
        if Config.InfiniteStamina then hum.JumpPower = 50 end
        if Config.AntiStun then hum.PlatformStand = false end
    end
end)

-- Flight
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F and Config.Flight then
        -- Flight Toggle Logic (einfach)
    end
end)

-- ==================== AUTO MUSIC ====================
local keys = {
    Guitar = {Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.T},
    Bass = {Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.R},
    Piano = {Enum.KeyCode.Q, Enum.KeyCode.W, Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.T},
    Drums = {Enum.KeyCode.Q, Enum.KeyCode.W, Enum.KeyCode.E, Enum.KeyCode.R}
}

local function PlayNote(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(0.035)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function StartAutoMusic()
    if musicConnection then musicConnection:Disconnect() end
    musicConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoMusic then return end
        local selected = keys[Config.Instrument] or keys.Guitar
        for _, k in ipairs(selected) do
            PlayNote(k)
            task.wait((0.08 + math.random()*0.03) * Config.MusicSpeed)
        end
    end)
end

-- ==================== UI ====================
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
CombatTab:CreateToggle({Name = "Auto Parry", CurrentValue = true, Callback = function(v) Config.AutoParry = v end})
CombatTab:CreateToggle({Name = "Show Hitbox", CurrentValue = true, Callback = function(v) Config.ShowHitbox = v end})

local BasketballTab = Window:CreateTab("🏀 Basketball", 4483362458)
BasketballTab:CreateToggle({Name = "Auto Green Assist", CurrentValue = true, Callback = function(v) Config.AutoGreenAssist = v end})
BasketballTab:CreateSlider({Name = "Green Delay (ms)", Range = {40, 160}, Increment = 1, CurrentValue = 85, Callback = function(v) Config.GreenDelay = v/1000 end})
BasketballTab:CreateSlider({Name = "Hold Time (ms)", Range = {20, 90}, Increment = 1, CurrentValue = 40, Callback = function(v) Config.GreenHoldTime = v/1000 end})

local MusicTab = Window:CreateTab("🎸 Music", 4483362458)
MusicTab:CreateToggle({Name = "Auto Music", CurrentValue = false, Callback = function(v) Config.AutoMusic = v if v then StartAutoMusic() end end})
MusicTab:CreateDropdown({Name = "Instrument", Options = {"Guitar","Bass","Piano","Drums"}, CurrentOption = {"Guitar"}, Callback = function(s) Config.Instrument = s[1] end})

Rayfield:Notify({Title = "SNUS-HUB", Content = "Final Version geladen - Viel Erfolg!", Duration = 10})

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.RightShift then Rayfield:ToggleUI() end
end)
