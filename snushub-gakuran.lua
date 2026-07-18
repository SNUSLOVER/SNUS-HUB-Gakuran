-- // SNUS-HUB Gakuran | Precision Parry + Advanced Auto Music Player
-- // Made by SNUSLOVER - Best Version

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "SNUS-HUB | Gakuran",
    LoadingTitle = "SNUS-HUB",
    LoadingSubtitle = "by SNUSLOVER",
    Theme = "Amethyst",
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Config = {
    AutoParry = true,
    BaseRange = 16,
    ForwardRange = 23,
    Delay = 0.037,
    PredictVelocity = true,
    ShowHitbox = true,
    
    -- Music
    AutoMusic = false,
    Instrument = "Guitar", -- Guitar, Bass, Piano, Drums
    MusicSpeed = 1.0,
    Randomization = true,   -- Humanizer
}

local lastParry = 0
local hitboxVisual = nil
local parryCooldown = {}
local musicConnection = nil

-- Hitbox Visual (unverändert)
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

-- ==================== AUTO PARRY (gleich wie vorher) ====================
RunService.Heartbeat:Connect(function()
    if not Config.AutoParry then return end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local lookVec = root.CFrame.LookVector
    UpdateHitboxVisual(root)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character then continue end
        local enemy = plr.Character
        local eRoot = enemy:FindFirstChild("HumanoidRootPart")
        local hum = enemy:FindFirstChild("Humanoid")
        if not eRoot or not hum then continue end

        if parryCooldown[plr] and tick() - parryCooldown[plr] < 0.6 then continue end

        local distance = (eRoot.Position - root.Position).Magnitude
        local isInFront = (eRoot.Position - root.Position).Unit:Dot(lookVec) > 0.5
        local currentRange = isInFront and Config.ForwardRange or Config.BaseRange
        if distance > currentRange + 6 then continue end

        local shouldParry = false
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if track.IsPlaying then
                    local pos = track.TimePosition
                    local speed = track.Speed or 1
                    if (pos > 0.085 and pos < 0.82) or (speed > 1.15 and pos < 0.68) then
                        shouldParry = true
                        break
                    end
                end
            end
        end

        if not shouldParry and Config.PredictVelocity then
            local vel = eRoot.Velocity
            local predictedDist = (eRoot.Position + vel * 0.075 - root.Position).Magnitude
            if predictedDist < currentRange - 2.5 then shouldParry = true end
        end

        if shouldParry then
            local dynamicDelay = Config.Delay
            if distance < 11 then dynamicDelay = math.clamp(Config.Delay - 0.017, 0.018, 0.045) end
            task.delay(dynamicDelay, function()
                Parry()
                parryCooldown[plr] = tick()
            end)
        end
    end
end)

-- ==================== ADVANCED AUTO MUSIC ====================
local keys = {
    Guitar = {Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.T},
    Bass   = {Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.R},
    Piano  = {Enum.KeyCode.Q, Enum.KeyCode.W, Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.T, Enum.KeyCode.Y},
    Drums  = {Enum.KeyCode.Q, Enum.KeyCode.W, Enum.KeyCode.E, Enum.KeyCode.R}
}

local function PlayNote(key)
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(0.04)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

local function StartAutoMusic()
    if musicConnection then musicConnection:Disconnect() end

    musicConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoMusic then return end
        
        local selectedKeys = keys[Config.Instrument] or keys.Guitar
        local speed = Config.MusicSpeed

        -- Rhythm Pattern
        for i = 1, #selectedKeys do
            if not Config.AutoMusic then break end
            
            local key = selectedKeys[i]
            PlayNote(key)
            
            -- Randomization für Human-Look
            local waitTime = (0.08 + math.random(1,4)*0.015) * speed
            if Config.Randomization and math.random(1,3) == 1 then
                waitTime = waitTime + 0.025
            end
            task.wait(waitTime)
        end
        
        task.wait(0.1 * speed) -- kurze Pause zwischen Patterns
    end)
end

local function StopAutoMusic()
    if musicConnection then
        musicConnection:Disconnect()
        musicConnection = nil
    end
end

-- ==================== UI ====================
local MainTab = Window:CreateTab("⚔️ Combat", 4483362458)
MainTab:CreateSection("Precision Parry v8.1")
MainTab:CreateToggle({Name = "Auto Parry", CurrentValue = true, Callback = function(v) Config.AutoParry = v end})
MainTab:CreateToggle({Name = "Show Hitbox", CurrentValue = true, Callback = function(v) Config.ShowHitbox = v end})
MainTab:CreateSlider({Name = "Base Range", Range = {8, 28}, Increment = 1, CurrentValue = 16, Callback = function(v) Config.BaseRange = v end})
MainTab:CreateSlider({Name = "Forward Range", Range = {15, 38}, Increment = 1, CurrentValue = 23, Callback = function(v) Config.ForwardRange = v end})
MainTab:CreateSlider({Name = "Base Delay (ms)", Range = {20, 65}, Increment = 2, CurrentValue = 37, Callback = function(v) Config.Delay = v / 1000 end})
MainTab:CreateToggle({Name = "Velocity Prediction", CurrentValue = true, Callback = function(v) Config.PredictVelocity = v end})

local MusicTab = Window:CreateTab("🎸 Auto Music", 4483362458)
MusicTab:CreateSection("Advanced Auto Rhythm Player")

MusicTab:CreateToggle({
    Name = "Auto Music Player",
    CurrentValue = false,
    Callback = function(v)
        Config.AutoMusic = v
        if v then
            StartAutoMusic()
        else
            StopAutoMusic()
        end
    end
})

MusicTab:CreateDropdown({
    Name = "Instrument",
    Options = {"Guitar", "Bass", "Piano", "Drums"},
    CurrentOption = {"Guitar"},
    MultipleOptions = false,
    Callback = function(selected)
        Config.Instrument = selected[1]
    end
})

MusicTab:CreateSlider({
    Name = "Speed",
    Range = {0.4, 2.2},
    Increment = 0.05,
    CurrentValue = 1.0,
    Callback = function(v) Config.MusicSpeed = v end
})

MusicTab:CreateToggle({
    Name = "Humanizer (Random)",
    CurrentValue = true,
    Callback = function(v) Config.Randomization = v end
})

MusicTab:CreateSection("Hinweise")
MusicTab:CreateParagraph({Title = "Benutzung", Content = "1. Gehe in den Music Room\n2. Nimm das gewünschte Instrument (Gitarre, Bass, Klavier, Drums)\n3. Aktiviere Auto Music\n4. Passe Speed + Instrument an"})

game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        Rayfield:ToggleUI()
    end
end)

Rayfield:Notify({
    Title = "SNUS-HUB | Gakuran",
    Content = "v8.1 + Advanced Auto Music geladen",
    Duration = 10
})
