-- // SNUS-HUB Gakuran | Full Feature Edition - Optimized Parry
-- // Made by SNUSLOVER
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "SNUS-HUB | Gakuran",
    LoadingTitle = "SNUS-HUB",
    LoadingSubtitle = "by SNUSLOVER - Optimized",
    Theme = "Amethyst",
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Config = {
    AutoParry = {
        Enabled = true,
        Range = 12,
        BaseDelay = 0.038,
        AnimHighlight = 0.12,
        Cooldown = 0.08,
        AttackDelay = 0.11,
        DynamicTiming = true,     -- Neue optimierte Funktion
        PingCompensation = true,
    },
    AutoGreenAssist = true,
    GreenDelay = 0.085,
    GreenHoldTime = 0.04,

    AutoMusic = false,
    Instrument = "Guitar",
    MusicSpeed = 1.0,
}

-- Deine Animation IDs
local AttackAnimations = {
    "120393553812903","1259761673936","134945199381140","117877243065533",
    "106965238908791","131071815103338","1370347470470618","118943955490014",
    "132022052139564","78888626472394","103964436023727","71676634048602",
    "114647502301740","134829666925953","112759168172605","104867156139010",
    "137837926745158","100981571094705","130865087635587","86495068205420",
    "96726284968458","139911027872047","104515319350296","74960202100098",
    "76236532060812","74206130671324","71919935695307","122861547142657",
    "137980914350618","100408082509740","94803478352691","78695517680318",
}

local lastParry = 0
local parryCooldown = {}

-- ==================== OPTIMIZED PARRY TIMING ====================
local function GetPing()
    return (game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000) or 0.05
end

local function IsAttackAnimation(track)
    if not track or not track.Animation then return false end
    local id = track.Animation.AnimationId:match("%d+")
    for _, animId in ipairs(AttackAnimations) do
        if id == animId then return true end
    end
    return false
end

RunService.Heartbeat:Connect(function()
    if not Config.AutoParry.Enabled then return end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local ping = Config.AutoParry.PingCompensation and GetPing() or 0

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer or not plr.Character then continue end
        if parryCooldown[plr] and tick() - parryCooldown[plr] < Config.AutoParry.Cooldown then continue end

        local enemy = plr.Character
        local eRoot = enemy:FindFirstChild("HumanoidRootPart")
        local eHum = enemy:FindFirstChild("Humanoid")
        if not eRoot or not eHum then continue end

        local distance = (eRoot.Position - root.Position).Magnitude
        if distance > Config.AutoParry.Range + 6 then continue end

        local animator = eHum:FindFirstChildOfClass("Animator")
        if not animator then continue end

        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            if track.IsPlaying and IsAttackAnimation(track) then
                local timePos = track.TimePosition
                local speed = track.Speed or 1.0

                -- === OPTIMIZED TIMING LOGIC ===
                local shouldParry = false
                
                if Config.AutoParry.DynamicTiming then
                    -- Smart Timing basierend auf Animation Fortschritt + Speed
                    if timePos >= Config.AutoParry.AnimHighlight and timePos < 0.78 then
                        if speed > 1.2 then
                            shouldParry = timePos < 0.65
                        else
                            shouldParry = timePos < 0.75
                        end
                    end
                else
                    if timePos >= Config.AutoParry.AnimHighlight and timePos < 0.82 then
                        shouldParry = true
                    end
                end

                if shouldParry then
                    local finalDelay = Config.AutoParry.BaseDelay + ping * 0.6
                    
                    -- Dynamische Anpassung bei Nähe
                    if distance < 9 then
                        finalDelay = math.max(0.018, finalDelay - 0.022)
                    end

                    task.delay(finalDelay, function()
                        if tick() - lastParry < 0.1 then return end
                        lastParry = tick()
                        parryCooldown[plr] = tick()

                        -- Perfect Parry
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                        task.wait(Config.AutoParry.AttackDelay)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)

                        -- Auto Punish
                        task.wait(0.08)
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end)
                end
            end
        end
    end
end)

-- ==================== AUTO GREEN + MUSIC (unverändert) ====================
local isShooting = false

local function AutoGreen()
    if not Config.AutoGreenAssist or isShooting then return end
    isShooting = true
    task.delay(Config.GreenDelay, function()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        task.wait(Config.GreenHoldTime)
        isShooting = false
    end)
end

RunService.Heartbeat:Connect(function()
    if not Config.AutoGreenAssist then return end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        if track.IsPlaying and (track.Animation.AnimationId:find("shoot") or track.Animation.AnimationId:find("throw")) then
            if track.TimePosition > 0.12 and track.TimePosition < 0.68 then
                AutoGreen()
                break
            end
        end
    end
end)

-- ==================== UI ====================
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
CombatTab:CreateToggle({Name = "Auto Parry", CurrentValue = true, Callback = function(v) Config.AutoParry.Enabled = v end})
CombatTab:CreateSlider({Name = "Parry Range", Range = {6, 25}, Increment = 1, CurrentValue = 12, Callback = function(v) Config.AutoParry.Range = v end})
CombatTab:CreateSlider({Name = "Base Delay (ms)", Range = {20, 80}, Increment = 1, CurrentValue = 38, Callback = function(v) Config.AutoParry.BaseDelay = v/1000 end})
CombatTab:CreateSlider({Name = "Anim Highlight", Range = {0.05, 0.35}, Increment = 0.01, CurrentValue = 0.12, Callback = function(v) Config.AutoParry.AnimHighlight = v end})
CombatTab:CreateToggle({Name = "Dynamic Timing", CurrentValue = true, Callback = function(v) Config.AutoParry.DynamicTiming = v end})
CombatTab:CreateToggle({Name = "Ping Compensation", CurrentValue = true, Callback = function(v) Config.AutoParry.PingCompensation = v end})

local BasketballTab = Window:CreateTab("🏀 Basketball", 4483362458)
BasketballTab:CreateToggle({Name = "Auto Green Assist", CurrentValue = true, Callback = function(v) Config.AutoGreenAssist = v end})
BasketballTab:CreateSlider({Name = "Green Delay (ms)", Range = {40, 160}, Increment = 1, CurrentValue = 85, Callback = function(v) Config.GreenDelay = v/1000 end})

Rayfield:Notify({
    Title = "SNUS-HUB",
    Content = "Parry Timing stark optimiert ✓",
    Duration = 8
})

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then Rayfield:ToggleUI() end
end)
