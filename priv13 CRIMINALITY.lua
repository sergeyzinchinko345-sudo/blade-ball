if not game:IsLoaded() then
    game.Loaded:Wait()
end

if getgc then
    local patched = 0
    local required = 1

    local function tryPatch()
        patched = 0
        for _, value in next, getgc(true) do
            if typeof(value) == 'table' then
                if rawget(value, "indexInstance") or rawget(value, "newindexInstance") or rawget(value, "newIndexInstance") then
                    rawset(value, "tvk", { "kick", function() return task.wait(9e9) end })
                    patched += 1
                end
            end
        end
        return patched >= required
    end

    local maxAttempts = 10
    local attempt = 0
    local success = false

    repeat
        attempt += 1
        success = tryPatch()
        if not success then
            task.wait(0.5)
        end
    until success or attempt >= maxAttempts

    if not success then
        -- я пидарас
        task.delay(4, function()
            if UILibNotifications then
                UILibNotifications:Create({ Name = "AC Bypass failed - your executor doesn't support getgc, you may get kicked", LifeTime = 6 })
            end
        end)
    end
end
task.wait(5)
local success, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/eradicator2/priv13-criminality/refs/heads/main/library.txt")
end)

if not success or type(result) ~= "string" or result == "" then
    success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/veracrypter/storage/refs/heads/main/library/v6")
    end)
end

if not success or type(result) ~= "string" or result == "" then
    warn("ui library wont load idk why")
    return
end

local func = loadstring(result)
if not func then
    warn("ui library wont load idk why")
    return
end

local Library, UILibNotifications, UILibThemes = func()


local Notifications; do
    local tweenService, coreGui = game:GetService("TweenService"), game:GetService("CoreGui");

    local insert, find, remove = table.insert, table.find, table.remove
    local format = string.format

    local newInstance = Instance.new
    local fromRGB = Color3.fromRGB

    local notificationPositions = {
        ["Middle"] = UDim2.new(0.445, 0, 0.7, 0),
        ["MiddleRight"] = UDim2.new(0.85, 0, 0.7, 0),
        ["MiddleLeft"] = UDim2.new(0.01, 0, 0.7, 0),

        ["Top"] = UDim2.new(0.445, 0, 0.007, 0),
        ["TopLeft"] = UDim2.new(0.06, 0, 0.001, 0),
        ["TopRight"] = UDim2.new(0.8, 0, 0.001, 0),
    };

    local function protectScreenGui(screenGui)
        if syn and syn.protect_gui then
            syn.protect_gui(screenGui);
            screenGui.Parent = coreGui
        elseif gethui then
            screenGui.Parent = gethui();
        else
            screenGui.Parent = coreGui();
        end
    end

    local function createObject(className, properties)
        local instance = newInstance(className);

        for index, value in next, properties do
            instance[index] = value
        end

        return instance
    end

    local function fadeObject(object, onTweenCompleted)
        local tweenInformation = tweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            TextTransparency = 1,
            TextStrokeTransparency = 1
        });

        tweenInformation.Completed:Connect(onTweenCompleted);
        tweenInformation:Play();
    end

    local notifications = {}; do
        function notifications.new(settings)
            assert(settings, "missing argument #1 in function notifications.new(settings)");
            assert(typeof(settings) == "table", format("expected table for argument #1 in function notifications.new(settings), got %s", typeof(settings)));

            local notificationSettings = {ui = {notificationsFrame = nil, notificationsFrame_UIListLayout = nil}};

            for setting, value in next, settings do
                notificationSettings[setting] = value
            end

            setmetatable(notificationSettings, {__index = notifications});
            return notificationSettings
        end

        function notifications:SetNotificationLifetime(number)
            assert(number, "missing argument #1 in function SetNotificationLifetime(number)");
            assert(typeof(number) == "number",  format("expected number for argument #1 in function SetNotificationLifetime, got %s", typeof(number)));

            self.NotificationLifetime = number
        end

        function notifications:SetTextColor(color3)
            assert(color3, "missing argument #1 in function SetTextColor(Color3)");
            assert(typeof(color3) == "Color3", format("expected Color3 for argument #1 in function SetTextColor3, got %s", typeof(color3)));

            self.TextColor = color3
        end

        function notifications:SetTextSize(number)
            assert(number, "missing argument #1 in function SetTextSize(number)");
            assert(typeof(number) == "number",  format("expected number for argument #1 in function SetTextSize, got %s", typeof(number)));

            self.TextSize = number
        end

        function notifications:SetTextStrokeTransparency(number)
            assert(number, "missing argument #1 in function SetTextStrokeTransparency(number)");
            assert(typeof(number) == "number",  format("expected number for argument #1 in function SetTextStrokeTransparency, got %s", typeof(number)));

            self.TextStrokeTransparency = number
        end

        function notifications:SetTextStrokeColor(color3)
            assert(color3, "missing argument #1 in function SetTextStrokeColor(Color3)");
            assert(typeof(color3) == "Color3", format("expected Color3 for argument #1 in function SetTextStrokeColor, got %s", typeof(color3)));

            self.TextStrokeColor = color3
        end

        function notifications:SetTextFont(font)
            assert(font, "missing argument #1 in function SetTextFont(Font)");
            assert((typeof(font) == "string" or typeof(font) == "EnumItem"))

            self.TextFont = Enum.Font[font];
        end

        function notifications:SetTextFontFace(fontFace)
            self.TextFontFace = fontFace
        end

        function notifications:BuildNotificationUI()
            if notifications_screenGui then
                notifications_screenGui:Destroy();
            end

            getgenv().notifications_screenGui = createObject("ScreenGui", {
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            }); protectScreenGui(notifications_screenGui);

            self.ui.notificationsFrame = createObject("Frame", {
                Name = "notificationsFrame",
                Parent = notifications_screenGui,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1.000,
                Position = notificationPositions[self.NotificationPosition],
                Size = UDim2.new(0, 236, 0, 215)
            });

            self.ui.notificationsFrame_UIListLayout = createObject("UIListLayout", {
                Name = "notificationsFrame_UIListLayout",
                Parent = self.ui.notificationsFrame,
                Padding = UDim.new(0, 1),
                SortOrder = Enum.SortOrder.LayoutOrder
            });
        end

        function notifications:Notify(text)
            local notification = createObject("TextLabel", {
                Name = "notification",
                Parent = self.ui.notificationsFrame,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1.000,
                Size = UDim2.new(1, 0, 0, 14),
                Text = text,

                Font = self.TextFont,
                TextColor3 = self.TextColor,
                TextSize = self.TextSize,
                TextStrokeColor3 = self.TextStrokeColor,
                TextStrokeTransparency = self.TextStrokeTransparency,
                TextXAlignment = Enum.TextXAlignment.Center,
            });

            if self.TextFontFace then
                notification.FontFace = self.TextFontFace
            end

            task.delay(self.NotificationLifetime, function()
                fadeObject(notification, function()
                    notification:Destroy();
                end);
            end);
        end
    end

    Notifications = notifications
end

local HitLog = Notifications.new({ NotificationPosition = "Middle" })
HitLog:SetNotificationLifetime(1.5)
HitLog:SetTextColor(Color3.fromRGB(255, 255, 255))
HitLog:SetTextSize(12)
HitLog:SetTextStrokeColor(Color3.new(0, 0, 0))
HitLog:SetTextStrokeTransparency(0)
HitLog:SetTextFont("SourceSansBold")
HitLog:BuildNotificationUI()

task.wait(0.1)

if HitLog.ui and HitLog.ui.notificationsFrame then
    local frame = HitLog.ui.notificationsFrame
    frame.AnchorPoint = Vector2.new(0.5, 1)
    frame.Position = UDim2.new(0.5, 0, 0.85, 0)
    frame.Size = UDim2.new(0, 600, 0, 200)
    frame.ClipsDescendants = true
end

local HitLogSett = { On = false, LastLogTime = 0, MinInterval = 0.15, Method = "Middle" }

local Plrs  = game:GetService("Players")
local RepSt = game:GetService("ReplicatedStorage")
local RS    = game:GetService("RunService")
local UIS   = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local LP    = Plrs.LocalPlayer
local Cam   = workspace.CurrentCamera

local AllowedPlaceIds = {
    [8343259840]  = true,
    [15169310267] = true,
    [15169303036] = true,
}

if not AllowedPlaceIds[game.PlaceId] then
    LP:Kick("poshel nahui")
    return
end

local Playerlist

local friend_cache = {}
local function is_friend(player)
    if player == LP then return false end
    if friend_cache[player.UserId] ~= nil then
        return friend_cache[player.UserId]
    end
    local ok, res = pcall(function() return LP:IsFriendsWith(player.UserId) end)
    if ok then
        friend_cache[player.UserId] = res
        return res
    end
    return false
end

local function get_player_status(player)
    local entry = Playerlist and Playerlist.Players and Playerlist.Players[player.Name]
    if entry and entry.Priority then
        return entry.Priority.Text
    end
    return "Neutral"
end

local RB = {
    Enabled            = false,
    FovLimit           = true,
    ShowFov            = true,
    TargetLine         = false,
    TargetLineColor    = Color3.fromRGB(255, 0, 0),
    TargetLineObj      = nil,
    TargetLineConn     = nil,
    FovRadius          = 150,
    FovColor           = Color3.new(1, 1, 1),
    FireRate           = 50,
    CheckDowned        = false,
    CheckTeam          = false,
    LockedEnemyTarget  = nil,
    FovCircle          = nil,
    FovUpdateConn      = nil,
    TPHit              = false,
    TPHitPrevFovLimit  = nil,
    TPHitReturnDelay   = 0.15,
    TPHitInterval      = 0.5,
    SkyboxBullet       = false,
    SkyboxBulletMode   = "Left+Right",
    SkyboxBulletHeight = 12,
    SkyboxBulletOffset = 6,
    SkyboxBulletInterval = 0.01,
    SkyboxBulletSide   = 1,
    SkyboxBulletRandomOffset = Vector3.new(0, 0, 0),
    SkyboxBulletLastSwitch = 0,
    SkyboxBulletPrevFovLimit = nil,
    SkyboxBulletCustomRight   = 0,
    SkyboxBulletCustomHeight  = 12,
    SkyboxBulletCustomForward = 0,
    SkyboxBulletSavedCFrame   = nil,
    NoFallDamage       = false,
    NoFallDamageMethod = "Block Remote",
    NoFallDamageFF     = nil,
    NoFallDamageCharConn = nil,
    SphereMode         = "Fibonacci",
    SphereRadius       = 19,
    CheckDead          = true,
}

local BB = {
    On = false,
    Col = Color3.fromRGB(230, 160, 70),
    Thick = 0.1,
    Life = 2,
    Type = "Beam",
    Trans = 0.7,
    Mat = "ForceField",
    SmoothFade = false,
    FadeSpeed = 1,
    Active = {},
    CurTex = "DNA",
    CustomTex = "rbxassetid://7071778278",
    Conns = {},
}

local TTexs = {
    ["Obelus"]       = {Tex = "rbxassetid://2382169232",    Len = 5,  Spd = 0, Mode = "Stretch", Segs = 1,  W0 = 0.3, W1 = 0.3},
    ["Lightning"]    = {Tex = "rbxassetid://7151778302",    Len = 1,  Spd = 1, Mode = "Stretch", Segs = 10, W0 = 1.2, W1 = 1.2},
    ["DNA"]          = {Tex = "rbxassetid://7071778278",    Len = 12, Spd = 1, Mode = "Wrap",    Segs = 1,  W0 = 0.6, W1 = 0.6},
    ["Straight"]     = {Tex = "rbxassetid://4595131819",    Len = 5,  Spd = 0, Mode = "Stretch", Segs = 1,  W0 = 0.3, W1 = 0.3},
    ["Taser"]        = {Tex = "rbxassetid://446111271",     Len = 8,  Spd = 1, Mode = "Stretch", Segs = 6,  W0 = 0.8, W1 = 0.8},
    ["Edge"]         = {Tex = "rbxassetid://9149045341",    Len = 6,  Spd = 1, Mode = "Stretch", Segs = 1,  W0 = 0.6, W1 = 0.6},
    ["Energy"]       = {Tex = "rbxassetid://6091341618",    Len = 10, Spd = 1, Mode = "Wrap",    Segs = 4,  W0 = 0.9, W1 = 0.9},
}

local HitSounds = {
    ["Rust"]        = "rbxassetid://5043539486",
    ["CODE200"]     = "rbxassetid://98545664405431",
    ["Minecraft"]   = "rbxassetid://7151570575",
    ["Neverlose"]   = "rbxassetid://6607204501",
    ["Gamesense"]   = "rbxassetid://5633695679",
    ["Bonk"]        = "rbxassetid://3765689841",
    ["Bat"]         = "rbxassetid://3333907347",
    ["Laser Beam"]  = "rbxassetid://130791043",
    ["Fatality"]    = "rbxassetid://6607142036",
    ["Bow"]         = "rbxassetid://93158957747276",
    ["koch"]        = "rbxassetid://126832876895392",
    ["golda"]      = "rbxassetid://72129857868180",
    ["agpa1"]      = "rbxassetid://136193374775854",
    ["agpa2"]      = "rbxassetid://104673402060812"
}
local HSett = { On = true, SoundId = "rbxassetid://5043539486", Vol = 1, Method = "Hit Check" }
local HSound = Instance.new("Sound")
HSound.Volume  = HSett.Vol
HSound.SoundId = HSett.SoundId
HSound.Parent  = workspace

local id_swap_conn = nil

local function PlayHSound()
    if not HSett.On then return end
    pcall(function() HSound:Play() end)
end

local function apply_hitmarker_hook()
    task.spawn(function()
        local ok, playerGui = pcall(function() return LP:WaitForChild("PlayerGui", 5) end)
        if not (ok and playerGui) then return end
        local ok2, coreGui = pcall(function() return playerGui:WaitForChild("CoreGUI", 5) end)
        if not (ok2 and coreGui) then return end

        local function handle_obj(obj)
            if obj.Name ~= "HitmarkerSound" then return end
            if not obj:IsA("Sound") then return end
            
            if HSett.Method == "ID Swap" then
                if HSett.On then
                    obj.SoundId    = HSett.SoundId
                    obj.Volume     = HSett.Vol
                    obj.SoundGroup = nil 
                end
            elseif HSett.Method == "Hit Check" then
                if HSett.On then
                    obj.Volume = 0
                    PlayHSound()
                end
            end
        end

        for _, obj in ipairs(coreGui:GetDescendants()) do
            handle_obj(obj)
        end

        if not id_swap_conn then
            id_swap_conn = coreGui.DescendantAdded:Connect(handle_obj)
        end
    end)
end

local function UpdHSound()
    HSound.SoundId = HSett.SoundId
    HSound.Volume  = HSett.Vol
    apply_hitmarker_hook()
end

local function findMzl(gun)
    if not gun or gun.Parent == nil then return nil end
    local names = {"Muzzle", "Flash", "FirePoint", "Handle", "WeaponHandle"}
    for _, n in pairs(names) do
        local p = gun:FindFirstChild(n)
        if p and p:IsA("BasePart") then return p end
    end
    return gun:FindFirstChildWhichIsA("BasePart") or gun
end

local function crBeam(sPos, ePos, col)
    if not BB.On or not sPos or not ePos then return nil end
    local bm, a0, a1
    local suc, err = pcall(function()
        bm = Instance.new("Beam")
        a0 = Instance.new("Attachment")
        a1 = Instance.new("Attachment")
        local par = workspace:FindFirstChild("Terrain") or workspace
        a0.Position = sPos; a0.Parent = par
        a1.Position = ePos; a1.Parent = par
        bm.Attachment0 = a0; bm.Attachment1 = a1
        bm.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, col), ColorSequenceKeypoint.new(1, col)})
        local tData = TTexs[BB.CurTex] or TTexs["Classic"]
        bm.Width0 = tData.W0 or BB.Thick
        bm.Width1 = tData.W1 or (BB.Thick * 0.5)
        if BB.CurTex == "Custom" then bm.Texture = BB.CustomTex else bm.Texture = tData.Tex end
        bm.TextureLength = tData.Len; bm.TextureSpeed = tData.Spd
        bm.TextureMode = Enum.TextureMode[tData.Mode] or Enum.TextureMode.Wrap
        if tData.Segs then bm.Segments = tData.Segs end
        bm.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, BB.Trans * 0.5),
            NumberSequenceKeypoint.new(0.5, BB.Trans),
            NumberSequenceKeypoint.new(1, 1)
        })
        bm.FaceCamera = true; bm.LightEmission = 0.5; bm.LightInfluence = 0.1; bm.Parent = par
    end)
    if not suc then
        if bm then bm:Destroy() end
        if a0 then a0:Destroy() end
        if a1 then a1:Destroy() end
        return nil
    end
    local id = #BB.Active + 1
    BB.Active[id] = {Beam = bm, Atts = {a0, a1}, Created = tick(), Type = "Beam"}
    return id
end

local function crLine(sPos, ePos, col)
    if not BB.On or not sPos or not ePos then return nil end
    local line
    local suc, err = pcall(function()
        if not Drawing then return end
        line = Drawing.new("Line")
        line.Visible = true
        line.From = Vector2.new(sPos.X, sPos.Y)
        line.To = Vector2.new(ePos.X, ePos.Y)
        line.Color = col
        line.Thickness = math.floor(BB.Thick * 10)
        line.Transparency = BB.Trans
        line.ZIndex = 999
    end)
    if not suc then return nil end
    local id = #BB.Active + 1
    BB.Active[id] = {Line = line, Created = tick(), Type = "Line"}
    return id
end

local function crAstralix(sPos, ePos, col)
    if not BB.On or not sPos or not ePos then return nil end
    local suc, err = pcall(function()
        local dir    = (ePos - sPos)
        local dist   = dir.Magnitude
        local mid    = sPos + dir * 0.5
        local cf     = CFrame.lookAt(mid, ePos) * CFrame.Angles(0, math.rad(90), 0)

        local par = Instance.new("Part")
        par.Name         = "RapidSting"
        par.Size         = Vector3.new(dist, 0.1, 0.1)
        par.CFrame       = cf
        par.Anchored     = true
        par.CanCollide   = false
        par.CanQuery     = false
        par.CanTouch     = false
        par.CastShadow   = false
        par.Massless     = true
        par.Transparency = 1
        par.Parent       = workspace

        local trFd = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)})
        local szSeq = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1.5),
            NumberSequenceKeypoint.new(0.5, 1),
            NumberSequenceKeypoint.new(1, 0)
        })
        local sqSeq = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(1, 0)
        })

        local function mkSlash(name, tex)
            local pe = Instance.new("ParticleEmitter")
            pe.Name              = name
            pe.Brightness        = 2
            pe.Color             = ColorSequence.new(col)
            pe.LightEmission     = 1; pe.LightInfluence = 0
            pe.Orientation       = Enum.ParticleOrientation.VelocityParallel
            pe.Size              = szSeq
            pe.Squash            = sqSeq
            pe.Texture           = tex
            pe.Transparency      = trFd
            pe.ZOffset           = 0
            pe.EmissionDirection = Enum.NormalId.Back
            pe.Enabled           = true
            pe.Lifetime          = NumberRange.new(0.3, 0.3)
            pe.Rate              = 10
            pe.Rotation          = NumberRange.new(90, 90)
            pe.RotSpeed          = NumberRange.new(0, 0)
            pe.Speed             = NumberRange.new(40, 40)
            pe.SpreadAngle       = Vector2.new(0, 0)
            pe.Shape             = Enum.ParticleEmitterShape.Box
            pe.ShapeInOut        = Enum.ParticleEmitterShapeInOut.Outward
            pe.ShapeStyle        = Enum.ParticleEmitterShapeStyle.Surface
            pe.Drag              = 2
            pe.LockedToPart      = false
            pe:SetAttribute("EmitCount", 1)
            pe.Parent            = par
            pe:Emit(math.ceil(dist / 2))
            pe.Enabled = false
            return pe
        end

        local sl1 = mkSlash("MainSlash1", "http://www.roblox.com/asset/?id=6820821916")
        local sl2 = mkSlash("MainSlash2", "http://www.roblox.com/asset/?id=12684715885")

        local weld = Instance.new("Motor6D")
        weld.Name         = "Weld"
        weld.C0           = CFrame.new(-dist * 0.5 - 0.023, 0, -6.5)
        weld.C1           = CFrame.new(0, 0, 0)
        weld.Part1        = par
        weld.MaxVelocity  = 0
        weld.Parent       = par

        local id = #BB.Active + 1
        BB.Active[id] = {Part = par, Atts = {sl1, sl2, weld}, Created = tick(), Type = "Astralix"}
    end)
end

local function crPart(sPos, ePos, col)
    pcall(function()
        local dist = (sPos - ePos).Magnitude
        local par = Instance.new("Part")
        par.Anchored = true
        par.CanCollide = false
        par.CastShadow = false
        par.Massless = true
        par.Material = Enum.Material[BB.Mat] or Enum.Material.ForceField
        par.Color = col
        par.Transparency = BB.Trans
        local th = BB.Thick or 0.1
        par.Size = Vector3.new(th, th, dist)
        par.CFrame = CFrame.lookAt(sPos, ePos) * CFrame.new(0, 0, -dist / 2)
        par.Parent = workspace
        
        local id = #BB.Active + 1
        BB.Active[id] = {Part = par, Created = tick(), Type = "Part"}
    end)
end

local function crTracer(sPos, ePos, col)
    if not BB.On then return nil end
    if not sPos or not ePos then return nil end
    if BB.CurTex == "Astralix" then
        return crAstralix(sPos, ePos, col)
    elseif BB.Type == "Beam" then
        return crBeam(sPos, ePos, col)
    elseif BB.Type == "Line" and Drawing then
        return crLine(sPos, ePos, col)
    elseif BB.Type == "Part" then
        return crPart(sPos, ePos, col)
    end
    return nil
end

local function clrTracers()
    for id, t in pairs(BB.Active) do
        pcall(function()
            if t.Beam then t.Beam:Destroy()
            elseif t.Line then t.Line:Remove()
            elseif t.Part then t.Part:Destroy() end
            if t.Atts then
                for _, a in ipairs(t.Atts) do
                    if a and a.Parent then a:Destroy() end
                end
            end
        end)
        BB.Active[id] = nil
    end
    BB.Active = {}
end

local function setupBB()
    local ev2 = RepSt:FindFirstChild("Events2")
    if ev2 then
        local viz = ev2:FindFirstChild("Visualize")
        if viz then
            local c = viz.Event:Connect(function(_, sc, _, gun, _, sPos, bps)
                if not BB.On or not bps then return end
                local char = LP.Character; if not char then return end
                local myTool = char:FindFirstChildOfClass("Tool"); if myTool ~= gun then return end
                local mzl = findMzl(gun); local mzlPos = mzl and mzl.Position or sPos
                for _, bDir in pairs(bps) do
                    local ray = Ray.new(mzlPos, bDir * 1000)
                    local hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {Cam, char, gun})
                    local ePos = hit and hitPos or mzlPos + (bDir * 500)
                    crTracer(mzlPos, ePos, BB.Col)
                end
            end)
            table.insert(BB.Conns, c)
        end
    end
    local ev = RepSt:FindFirstChild("Events")
    if ev then
        local fire = ev:FindFirstChild("GNX_S")
        if fire then
            local c = fire.OnClientEvent:Connect(function(st, sc, gun, ft, sPos, dirs, silenced)
                if not BB.On or not dirs then return end
                local char = LP.Character; if not char then return end
                local tool = char:FindFirstChildOfClass("Tool"); if tool ~= gun then return end
                local mzl = findMzl(gun); local mzlPos = mzl and mzl.Position or sPos
                for _, dir in pairs(dirs) do
                    local ray = Ray.new(mzlPos, dir * 1000)
                    local hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {Cam, char, gun})
                    local ePos = hit and hitPos or mzlPos + (dir * 500)
                    crTracer(mzlPos, ePos, BB.Col)
                end
            end)
            table.insert(BB.Conns, c)
        end
    end
end

local function toggleBB(state)
    BB.On = state
    if BB.On then
        clrTracers()
        for _, c in pairs(BB.Conns) do if c then c:Disconnect() end end
        BB.Conns = {}
        local suc, err = pcall(setupBB)
        
        local rsC = game:GetService("RunService").RenderStepped:Connect(function()
            for id, t in pairs(BB.Active) do
                local el = tick() - t.Created
                local maxLife = BB.SmoothFade and (BB.Life + BB.FadeSpeed) or BB.Life
                if el > maxLife then
                    pcall(function()
                        if t.Beam then t.Beam:Destroy() end
                        if t.Line then t.Line:Remove() end
                        if t.Part then t.Part:Destroy() end
                        if t.Atts then for _, a in ipairs(t.Atts) do if a and a.Parent then a:Destroy() end end end
                    end)
                    BB.Active[id] = nil
                    continue
                end
                
                local curTrans = BB.Trans
                if BB.SmoothFade and el > BB.Life then
                    local fadeEl = el - BB.Life
                    local fadeAmount = math.clamp(fadeEl / BB.FadeSpeed, 0, 1)
                    curTrans = BB.Trans + fadeAmount * (1 - BB.Trans)
                end
                
                pcall(function()
                    if t.Type == "Beam" and t.Beam then
                        t.Beam.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, BB.Col), ColorSequenceKeypoint.new(1, BB.Col)})
                        t.Beam.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, curTrans * 0.5),
                            NumberSequenceKeypoint.new(0.5, curTrans),
                            NumberSequenceKeypoint.new(1, 1)
                        })
                    elseif t.Type == "Line" and t.Line then
                        t.Line.Color = BB.Col
                        t.Line.Transparency = 1 - curTrans
                    elseif t.Type == "Part" and t.Part then
                        t.Part.Color = BB.Col
                        t.Part.Transparency = curTrans
                    elseif t.Type == "Astralix" and t.Atts then
                        local sl1, sl2 = t.Atts[1], t.Atts[2]
                        if sl1 then
                            sl1.Color = ColorSequence.new(BB.Col)
                            sl1.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, curTrans), NumberSequenceKeypoint.new(1, 1)})
                        end
                        if sl2 then
                            sl2.Color = ColorSequence.new(BB.Col)
                            sl2.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, curTrans), NumberSequenceKeypoint.new(1, 1)})
                        end
                    end
                end)
            end
        end)
        table.insert(BB.Conns, rsC)
        
        local charC = LP.CharacterAdded:Connect(function()
            if not BB.On then return end
            clrTracers()
            task.wait(1); pcall(setupBB)
        end)
        table.insert(BB.Conns, charC)
        local remC = LP.CharacterRemoving:Connect(function() if BB.On then clrTracers() end end)
        table.insert(BB.Conns, remC)
    else
        clrTracers()
        for _, c in pairs(BB.Conns) do if c then c:Disconnect() end end
        BB.Conns = {}
    end
end

Library.WatermarkText     = "priv13 | shariktools | {build} | FPS: {fps} | Ping: {ping}"
Library.WatermarkIsDev    = false 
Library.WatermarkUpdating = false 

local Window = Library:Window({
    Name = "priv13 | shariktools",
    Size = UDim2.new(0, 455, 0, 730),
})

local PetPanel = Library:PetPanel({
    Enabled      = true,
    AnchorWindow = Window,
    Side         = "Left",
    Gap          = 8,
    AlignY       = "Top",
    Images       = {
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/szyb54glrozg5wmnaf.jpg",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/ia3y9emvvuwwh4lp6n.jpg",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/5no35s1ilaaubf21dy.jpg",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/vt1xbbxr9si29jpx63.jpg",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/hqxdvyc5uyc18s4hji.png",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/6pgg5orls0oupfnfp9.jpg",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/g35fk5qkwyobvhorgm.png",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/fkuyge9y6ijtcniu4m.png",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/kgr7qzz431mmhdn77s.png",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/04z3e32u7r1urxzdab.jpg",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/pe3q961nw9g18fhrhw.png",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/4by7wc36jsv52fjewv.jpg",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/t4gwvheua3osev6z6p.png",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/iuwolustju7cpkv4cr.png",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/tjd9x7bw4y5qatlkrx.jpg",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/u6sd71obrlgghwrqwk.jpg",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/nhux5jodyfuwizg9fr.png",
        "https://r2.e-z.host/679dd696-e8cf-4c6c-a895-1a9cb7560b69/p4ry02r6c4jcjphe41.jpg",
    },
})
local function Notify(title, text, time)
    UILibNotifications:Create({Name = title .. ": " .. text, LifeTime = time})
end

local UpdateLogSettings = {
    Enabled = false,
    Title   = "Update Log",
    Entries = {
        "+ Added New Ragebot Method",
        "+ Added New Silent aim method",
        "~ Fixed Silent aim",
        "~ Optimized wallhacks",
    },
}

if UpdateLogSettings.Enabled then
    Library:UpdateLog({
        Title        = UpdateLogSettings.Title,
        Entries      = UpdateLogSettings.Entries,
        AnchorWindow = Window,
        Side         = "Right",
        Gap          = 8,
        AlignY       = "Top",
    })
end

local CombatPage = Window:Tab({Name = "Rage"})
local LegitPage = Window:Tab({Name = "Legit"})
local VisualsPage = Window:Tab({Name = "Visuals"})
local WorldPage = Window:Tab({Name = "World"})
local MiscPage = Window:Tab({Name = "Misc"})
local PlayersPage = Window:Tab({Name = "Players"})

local esp_workspace     = cloneref and cloneref(game:GetService("Workspace"))     or game:GetService("Workspace")
local esp_run           = cloneref and cloneref(game:GetService("RunService"))     or game:GetService("RunService")
local esp_http_service  = cloneref and cloneref(game:GetService("HttpService"))    or game:GetService("HttpService")
local esp_players       = cloneref and cloneref(game:GetService("Players"))        or game:GetService("Players")

local vec2 = Vector2.new
local vec3 = Vector3.new
local dim2 = UDim2.new
local dim = UDim.new
local rect = Rect.new
local cfr = CFrame.new
local empty_cfr = cfr()
local point_object_space = empty_cfr.PointToObjectSpace
local angle = CFrame.Angles
local dim_offset = UDim2.fromOffset

local espcolor = Color3.new
local rgb = Color3.fromRGB
local hex = Color3.fromHex
local hsv = Color3.fromHSV
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new
local numseq = NumberSequence.new
local numkey = NumberSequenceKeypoint.new

local esp_camera = esp_workspace.CurrentCamera

local flags = { 
    ["Enabled"] = false;
    ["Names"] = false;
    ["Name_Color"] = { Color = rgb(255, 255, 255) };
    ["Skeleton"] = false;
    ["Skeleton_Outline"] = true;
    ["Skeleton_Color"] = { Color = rgb(255, 255, 255) };
    ["Headdot"] = false;
    ["Headdot_Outline"] = true;
    ["Headdot_Color"] = { Color = rgb(255, 255, 255) };
    ["Headdot_Size"] = 1;
    ["Name_Mode"] = "Both";
    ["Boxes"] = false;
    ["Box_Type"] = "Corner";
    ["Box_Color"] = { Color = rgb(255, 255, 255) };
    ["Box_Gradient"] = false;
    ["Box_Gradient_Color"] = { Color = rgb(128, 128, 128) };
    ["Healthbar"] = false;
    ["Healthbar_Mode"] = "Dynamic";
    ["Health_Text"] = false;
    ["Health_Text_Color"] = { Color = rgb(0, 255, 0) };
    ["Health_High"] = { Color = rgb(0, 255, 0) };
    ["Health_Low"]  = { Color = rgb(255, 0, 0) };
    ["Healthbar_Gradient"] = false;
    ["Healthbar_Gradient_Color"] = { Color = rgb(255, 0, 0) };
    ["Distance"] = false;
    ["Weapon"] = false;
    ["Distance_Color"] = { Color = rgb(255, 255, 255) };
    ["Weapon_Color"] = { Color = rgb(100, 149, 237) };
    ["Max_Distance"] = 1000;
    ["Enemy_Color"]   = { Color = rgb(255, 255, 255) };
    ["Friendly_Color"] = { Color = rgb(0, 200, 80) };
    ["Armorbar"]      = false;
    ["Armorbar_Mode"] = "Dynamic";
    ["Armor_Color"]   = { Color = rgb(100, 149, 237) };
    ["Armor_High"]    = { Color = rgb(100, 149, 237) };
    ["Armor_Low"]     = { Color = rgb(200, 80,  80)  };
    ["Armor_Text"]    = false;
    ["Armor_Text_Color"] = { Color = rgb(100, 149, 237) };
    ["Crouching"]     = false;
    ["Crouch_Color"]  = { Color = rgb(255, 255, 255) };
    ["Downed"]        = false;
    ["Downed_Color"]  = { Color = rgb(255, 0, 0) };
    ["ForceField"]        = false;
    ["ForceField_Color"]  = { Color = rgb(64, 224, 208) };
    ["Reloadbar"]     = false;
    ["Reload_Color"]  = { Color = rgb(255, 255, 255) };
    ["Level"]         = false;
    ["Level_Color"]   = { Color = rgb(255, 255, 255) };
    ["CombatZone"]       = false;
    ["CombatZone_Color"] = { Color = rgb(255, 80, 80) };
    ["ESPScaleText"]     = false;
    ["Smooth_Fade_OOR"]  = false;
    ["Smooth_Fade_Dead"] = false;
}

local fonts = {}; do
    function Register_Font(Name, Weight, Style, Asset)
        if not isfile or not writefile or not getcustomasset then return nil end

        if not isfile(Asset.Id) then
            writefile(Asset.Id, Asset.Font)
        end

        if isfile(Name .. ".font") then
            delfile(Name .. ".font")
        end

        local Data = {
            name = Name,
            faces = {
                {
                    name = "Normal",
                    weight = Weight,
                    style = Style,
                    assetId = getcustomasset(Asset.Id),
                },
            },
        }
        writefile(Name .. ".font", esp_http_service:JSONEncode(Data))

        return getcustomasset(Name .. ".font");
    end

    local function b64decode(s)
        if crypt then
            if crypt.base64 and crypt.base64.decode then return crypt.base64.decode(s) end
            if crypt.base64decode then return crypt.base64decode(s) end
        end
        if base64decode then return base64decode(s) end
        if base64_decode then return base64_decode(s) end
        return s
    end

    local MinecraftiaB64 = "AAEAAAANAIAAAwBQRFNJRwAAAAEAAQX0AAAACEdERUYDBAAkAAEF/AAAAChPUy8y1NZFSAAAANwAAABgY21hcNZo3swAAQp8AAAIOGdhc3AAAAADAAEF7AAAAAhnbHlmEGqBuwAAGjgAANTQaGVhZAZHGCYAAPpgAAAANmhoZWERQQ7WAAAZ9AAAACRobXR4Ywj7gAAA+pgAAAtUbG9jYQEl1TwAAO8IAAALWG1heHAC4wA8AAAaGAAAACBuYW1lomnC7QABBiQAAARWcG9zdN5ON9IAAAE8AAAYuAADBGEBkAAFAAQDAAMAAAABgAMAAwAAAAMAAEwBMgAAAAAEAAAAAAAAAKAAAL9AAGB7AAAAAAAAAABGU1RSAEAAIPsCCQADAAAACoD9wAAAAf8AAAAAB4AJAAAAACAAAQACAAAAAAAAAJgATAAAAAAAAAAAAAAAAAAAAAAAAAAAAtUAAAABAAIAAwAEAAUABgAHAAgACQAKAAsADAANAA4ADwAQABEAEgATABQAFQAWABcAGAAZABoAGwAcAB0AHgAfACAAIQAiACMAJAAlACYAJwAoACkAKgArACwALQAuAC8AMAAxADIAMwA0ADUANgA3ADgAOQA6ADsAPAA9AD4APwBAAEEAQgBDAEQARQBGAEcASABJAEoASwBMAE0ATgBPAFAAUQBSAFMAVABVAFYAVwBYAFkAWgBbAFwAXQBeAF8AYABhAKMAhACFAL0AlgDoAIYAjgCLAJ0AqQCkAIoA2gCDAJMA8gDzAI0AlwCIAMMA3gDxAJ4AqgD1APQA9gCiAK0AyQDHAK4AYgBjAJAAZADLAGUAyADKAM8AzADNAM4A6QBmANMA0ADRAK8AZwDwAJEA1gDUANUAaADrAO0AiQBqAGkAawBtAGwAbgCgAG8AcQBwAHIAcwB1AHQAdgB3AOoAeAB6AHkAewB9AHwAuAChAH8AfgCAAIEA7ADuALoBAgEDAQQBBQEGAQcA/QD+AQgBCQEKAQsA/wEAAQwBDQEOAQEBDwEQAREBEgETARQBFQEWARcBGAEZARoA+AD5ARsBHAEdAR4BHwEgASEBIgEjASQBJQEmAScBKAEpASoA+gDXASsBLAEtAS4BLwEwATEBMgEzATQBNQE2ATcBOAE5AOIA4wE6ATsBPAE9AT4BPwFAAUEBQgFDAUQBRQFGAUcBSACwALEBSQFKAUsBTAFNAU4BTwFQAVEBUgD7APwA5ADlAVMBVAFVAVYBVwFYAVkBWgFbAVwBXQFeAV8BYAFhAWIBYwFkAWUBZgFnAWgAuwFpAWoBawFsAOYA5wFtAW4BbwFwAKYBcQFyAXMBdAF1AXYBdwF4AXkBegF7AXwBfQF+AX8BgAGBAYIBgwGEAYUBhgGHAYgBiQGKANgA4QGLAYwBjQDbANwA3QDgANkA3wGOAY8BkAGRAZIBkwGUAZUBlgGXAZgBmQGaAZsBnAGdAZ4BnwGgAaEBogGjAaQBpQGmAacBqAGpAaoBqwGsAa0BrgGvAbABsQGyAJ8BswG0AbUBtgG3AbgBuQG6AbsBvAG9Ab4BvwHAAcEBwgHDAcQBxQHGAccByACbAckBygHLAcwBzQHOAc8B0AHRAdIB0wHUAdUB1gHXAdgB2QHaAdsB3AHdAd4B3wHgAeEB4gHjAeQB5QHmAecB6AHpAeoB6wHsAe0B7gHvAfAB8QHyAfMB9AH1AfYB9wH4AfkB+gH7AfwB/QH+Af8CAAIBAgICAwIEAgUCBgIHAggCCQIKAgsCDAINAg4CDwIQAhECEgITAhQCFQIWAhcCGAIZAhoCGwIcAh0CHgIfAiACIQIiAiMCJAIlAiYCJwIoAikCKgIrAiwCLQIuAi8CMAIxAjICMwI0AjUCNgI3AjgCOQI6AjsCPAI9Aj4CPwJAAkECQgJDAkQCRQJGAkcCSAJJAkoCSwJMAk0CTgJPAlACUQJSAlMCVAJVAlYCVwJYAlkCWgJbAlwCXQJeAl8CYAJhAmICYwJkAmUCZgJnAmgCaQJqAmsCbAJtAm4CbwJwAnECcgJzAnQCdQJ2AncCeAJ5AnoCewJ8An0CfgJ/AoACgQKCAoMChAKFAoYChwKIAokCigC2ALcAxAKLALQAtQDFAowAggDCAIcCjQCrAMYCjgKPApACkQC+AL8AvAKSApMClAKVApYClwKYApkCmgKbApwCnQKeAp8CoAKhAqICowKkAqUCpgKnAqgCqQKqAqsCrAKtAq4CrwKwAIwCsQKyArMCtAK1ArYCtwK4ArkCugK7ArwCvQK+Ar8CwALBAsICwwLEAsUCxgLHAsgCyQLKAssAqAClAJIAnALMAKcAjwCUAJUCzQLOAs8C0ALRAtIC0wLUAtUC1gLXAtgC2QLaAtsC3ALdAt4AwADBB0FtYWNyb24HYW1hY3JvbgZBYnJldmUGYWJyZXZlB0FvZ29uZWsHYW9nb25lawtDY2lyY3VtZmxleAtjY2lyY3VtZmxleARDZG90BGNkb3QGRGNhcm9uBmRjYXJvbgZEY3JvYXQHRW1hY3JvbgdlbWFjcm9uBkVicmV2ZQZlYnJldmUERWRvdARlZG90B0VvZ29uZWsHZW9nb25lawZFY2Fyb24GZWNhcm9uC0djaXJjdW1mbGV4C2djaXJjdW1mbGV4BEdkb3QEZ2RvdAhHY2VkaWxsYQhnY2VkaWxsYQtIY2lyY3VtZmxleAtoY2lyY3VtZmxleARIYmFyBGhiYXIGSXRpbGRlBml0aWxkZQdJbWFjcm9uB2ltYWNyb24GSWJyZXZlBmlicmV2ZQdJb2dvbmVrB2lvZ29uZWsCSUoCaWoLSmNpcmN1bWZsZXgLamNpcmN1bWZsZXgIS2NlZGlsbGEIa2NlZGlsbGEMa2dyZWVubGFuZGljBkxhY3V0ZQZsYWN1dGUITGNlZGlsbGEIbGNlZGlsbGEGTGNhcm9uBmxjYXJvbgRMZG90BGxkb3QGTmFjdXRlBm5hY3V0ZQhOY2VkaWxsYQhuY2VkaWxsYQZOY2Fyb24GbmNhcm9uC25hcG9zdHJvcGhlA0VuZwNlbmcHT21hY3JvbgdvbWFjcm9uBk9icmV2ZQZvYnJldmUJT2RibGFjdXRlCW9kYmxhY3V0ZQZSYWN1dGUGcmFjdXRlCFJjZWRpbGxhCHJjZWRpbGxhBlJjYXJvbgZyY2Fyb24GU2FjdXRlBnNhY3V0ZQtTY2lyY3VtZmxleAtzY2lyY3VtZmxleAhUY2VkaWxsYQh0Y2VkaWxsYQZUY2Fyb24GdGNhcm9uBFRiYXIEdGJhcgZVdGlsZGUGdXRpbGRlB1VtYWNyb24HdW1hY3JvbgZVYnJldmUGdWJyZXZlBVVyaW5nBXVyaW5nCVVkYmxhY3V0ZQl1ZGJsYWN1dGUHVW9nb25lawd1b2dvbmVrC1djaXJjdW1mbGV4C3djaXJjdW1mbGV4C1ljaXJjdW1mbGV4C3ljaXJjdW1mbGV4BlphY3V0ZQZ6YWN1dGUEWmRvdAR6ZG90BWxvbmdzB0J0b3BiYXIHYnRvcGJhcgVTY2h3YQdac3Ryb2tlB3pzdHJva2UDRXpoB0dzdHJva2UHZ3N0cm9rZQZHY2Fyb24GZ2Nhcm9uBktjYXJvbgZrY2Fyb24HT29nb25lawdvb2dvbmVrCEV6aGNhcm9uCGV6aGNhcm9uCkFyaW5nYWN1dGUKYXJpbmdhY3V0ZQdBRWFjdXRlB2FlYWN1dGULT3NsYXNoYWN1dGULb3NsYXNoYWN1dGUMU2NvbW1hYWNjZW50DHNjb21tYWFjY2VudAtUY29tbWFiZWxvdwt0Y29tbWFiZWxvdwhkb3RsZXNzagVzY2h3YQNlemgQZmlyc3R0b25lY2hpbmVzZRFzZWNvbmR0b25lY2hpbmVzZRFmb3VydGh0b25lY2hpbmVzZRBudW1lcmFsc2lnbmdyZWVrFW51bWVyYWxzaWdubG93ZXJncmVlaw1xdWVzdGlvbmdyZWVrBXRvbm9zDmRpYWx5dGlrYXRvbm9zCkFscGhhdG9ub3MJYW5vdGVsZWlhDEVwc2lsb250b25vcwhFdGF0b25vcwlJb3RhdG9ub3MMT21pY3JvbnRvbm9zDFVwc2lsb250b25vcwpPbWVnYXRvbm9zEWlvdGFkaWVyZXNpc3Rvbm9zBUFscGhhBEJldGEFR2FtbWEKRGVsdGFncmVlawdFcHNpbG9uBFpldGEDRXRhBVRoZXRhBElvdGEFS2FwcGEGTGFtYmRhAk11Ak51AlhpB09taWNyb24CUGkDUmhvBVNpZ21hA1RhdQdVcHNpbG9uA1BoaQNDaGkDUHNpDElvdGFkaWVyZXNpcw9VcHNpbG9uZGllcmVzaXMKYWxwaGF0b25vcwxlcHNpbG9udG9ub3MIZXRhdG9ub3MJaW90YXRvbm9zFHVwc2lsb25kaWVyZXNpc3Rvbm9zBWFscGhhBGJldGEFZ2FtbWEFZGVsdGEHZXBzaWxvbgR6ZXRhA2V0YQV0aGV0YQRpb3RhBWthcHBhBmxhbWJkYQdtdWdyZWVrAm51AnhpB29taWNyb24DcmhvBnNpZ21hMQVzaWdtYQN0YXUHdXBzaWxvbgNwaGkDY2hpA3BzaQVvbWVnYQxpb3RhZGllcmVzaXMPdXBzaWxvbmRpZXJlc2lzDG9taWNyb250b25vcwx1cHNpbG9udG9ub3MKb21lZ2F0b25vcwd1bmkwM0Q3B3VuaTA0MDAJYWZpaTEwMDIzCWFmaWkxMDA1MQlhZmlpMTAwNTIJYWZpaTEwMDUzCWFmaWkxMDA1NAlhZmlpMTAwNTUJYWZpaTEwMDU2CWFmaWkxMDA1NwlhZmlpMTAwNTgJYWZpaTEwMDU5CWFmaWkxMDA2MAlhZmlpMTAwNjEHdW5pMDQwRAlhZmlpMTAwNjIJYWZpaTEwMTQ1CUFjeXJpbGxpYwlhZmlpMTAwMTgJYWZpaTEwMDE5CWFmaWkxMDAyMAlhZmlpMTAwMjEJYWZpaTEwMDIyCWFmaWkxMDAyNAlhZmlpMTAwMjUJYWZpaTEwMDI2CWFmaWkxMDAyNwlhZmlpMTAwMjgJYWZpaTEwMDI5CWFmaWkxMDAzMAlhZmlpMTAwMzEJYWZpaTEwMDMyCWFmaWkxMDAzMwlhZmlpMTAwMzQJYWZpaTEwMDM1CWFmaWkxMDAzNglhZmlpMTAwMzcJYWZpaTEwMDM4CWFmaWkxMDAzOQlhZmlpMTAwNDAJYWZpaTEwMDQxCWFmaWkxMDA0MglhZmlpMTAwNDMJYWZpaTEwMDQ0CWFmaWkxMDA0NQlhZmlpMTAwNDYJYWZpaTEwMDQ3CWFmaWkxMDA0OAlhZmlpMTAwNDkJYWN5cmlsbGljCWFmaWkxMDA2NglhZmlpMTAwNjcJYWZpaTEwMDY4CWFmaWkxMDA2OQlhZmlpMTAwNzAJYWZpaTEwMDcyCWFmaWkxMDA3MwlhZmlpMTAwNzQJYWZpaTEwMDc1CWFmaWkxMDA3NglhZmlpMTAwNzcJYWZpaTEwMDc4CWFmaWkxMDA3OQlhZmlpMTAwODAJYWZpaTEwMDgxCWFmaWkxMDA4MglhZmlpMTAwODMJYWZpaTEwMDg0CWFmaWkxMDA4NQlhZmlpMTAwODYJYWZpaTEwMDg3CWFmaWkxMDA4OAlhZmlpMTAwODkJYWZpaTEwMDkwCWFmaWkxMDA5MQlhZmlpMTAwOTIJYWZpaTEwMDkzCWFmaWkxMDA5NAlhZmlpMTAwOTUJYWZpaTEwMDk2CWFmaWkxMDA5Nwd1bmkwNDUwCWFmaWkxMDA3MQlhZmlpMTAwOTkJYWZpaTEwMTAwCWFmaWkxMDEwMQlhZmlpMTAxMDIJYWZpaTEwMTAzCWFmaWkxMDEwNAlhZmlpMTAxMDUJYWZpaTEwMTA2CWFmaWkxMDEwNwlhZmlpMTAxMDgJYWZpaTEwMTA5B3VuaTA0NUQJYWZpaTEwMTEwCWFmaWkxMDE5MwlhZmlpMTAxNDYJYWZpaTEwMTk0CWFmaWkxMDE0NwlhZmlpMTAxOTUJYWZpaTEwMTQ4CWFmaWkxMDE5Ngd1bmkwNDhBB3VuaTA0OEIHdW5pMDQ4Qwd1bmkwNDhEB3VuaTA0OEUHdW5pMDQ4RglhZmlpMTAwNTAJYWZpaTEwMDk4EUdoZXN0cm9rZWN5cmlsbGljEWdoZXN0cm9rZWN5cmlsbGljFFpoZWRlc2NlbmRlcmN5cmlsbGljFHpoZWRlc2NlbmRlcmN5cmlsbGljE1plZGVzY2VuZGVyY3lyaWxsaWMTemVkZXNjZW5kZXJjeXJpbGxpYxNLYWRlc2NlbmRlcmN5cmlsbGljE2thZGVzY2VuZGVyY3lyaWxsaWMYS2F2ZXJ0aWNhbHN0cm9rZWN5cmlsbGljGGthdmVydGljYWxzdHJva2VjeXJpbGxpYxFLYWJhc2hraXJjeXJpbGxpYxFrYWJhc2hraXJjeXJpbGxpYxNFbmRlc2NlbmRlcmN5cmlsbGljE2VuZGVzY2VuZGVyY3lyaWxsaWMTRXNkZXNjZW5kZXJjeXJpbGxpYxNlc2Rlc2NlbmRlcmN5cmlsbGljEVVzdHJhaWdodGN5cmlsbGljEXVzdHJhaWdodGN5cmlsbGljF1VzdHJhaWdodHN0cm9rZWN5cmlsbGljF3VzdHJhaWdodHN0cm9rZWN5cmlsbGljE0hhZGVzY2VuZGVyY3lyaWxsaWMTaGFkZXNjZW5kZXJjeXJpbGxpYxRDaGVkZXNjZW5kZXJjeXJpbGxpYxRjaGVkZXNjZW5kZXJjeXJpbGxpYxlDaGV2ZXJ0aWNhbHN0cm9rZWN5cmlsbGljGWNoZXZlcnRpY2Fsc3Ryb2tlY3lyaWxsaWMMU2hoYWN5cmlsbGljDHNoaGFjeXJpbGxpYxBwYWxvY2hrYWN5cmlsbGljEFpoZWJyZXZlY3lyaWxsaWMQemhlYnJldmVjeXJpbGxpYwd1bmkwNEM1B3VuaTA0QzYORW5ob29rY3lyaWxsaWMOZW5ob29rY3lyaWxsaWMHdW5pMDRDOQd1bmkwNENBB3VuaTA0Q0QHdW5pMDRDRQd1bmkwNENGEUFkaWVyZXNpc2N5cmlsbGljEWFkaWVyZXNpc2N5cmlsbGljC0FpZWN5cmlsbGljC2FpZWN5cmlsbGljDVNjaHdhY3lyaWxsaWMJYWZpaTEwODQ2D0ltYWNyb25jeXJpbGxpYw9pbWFjcm9uY3lyaWxsaWMRSWRpZXJlc2lzY3lyaWxsaWMRaWRpZXJlc2lzY3lyaWxsaWMRT2RpZXJlc2lzY3lyaWxsaWMRb2RpZXJlc2lzY3lyaWxsaWMPT2JhcnJlZGN5cmlsbGljD29iYXJyZWRjeXJpbGxpYwd1bmkwNEVDB3VuaTA0RUQPVW1hY3JvbmN5cmlsbGljD3VtYWNyb25jeXJpbGxpYxFVZGllcmVzaXNjeXJpbGxpYxF1ZGllcmVzaXNjeXJpbGxpYwZXZ3JhdmUGd2dyYXZlBldhY3V0ZQZ3YWN1dGUJV2RpZXJlc2lzCXdkaWVyZXNpcwd1bmkxRTlFBllncmF2ZQZ5Z3JhdmURcXVvdGVsZWZ0cmV2ZXJzZWQHdW5pMjAxRgd1bmkyMDIzBm1pbnV0ZQZzZWNvbmQNcHJpbWVyZXZlcnNlZAd1bmkyMDM2DHplcm9zdXBlcmlvcgd1bmkyMDcxDGZvdXJzdXBlcmlvcgxmaXZlc3VwZXJpb3ILc2l4c3VwZXJpb3INc2V2ZW5zdXBlcmlvcg1laWdodHN1cGVyaW9yDG5pbmVzdXBlcmlvcgx6ZXJvaW5mZXJpb3ILb25laW5mZXJpb3ILdHdvaW5mZXJpb3INdGhyZWVpbmZlcmlvcgxmb3VyaW5mZXJpb3IMZml2ZWluZmVyaW9yC3NpeGluZmVyaW9yDXNldmVuaW5mZXJpb3INZWlnaHRpbmZlcmlvcgxuaW5laW5mZXJpb3IDd29uBEV1cm8HdW5pMjBBRQd1bmkyMEIxB3VuaTIwQjQHdW5pMjBCOAd1bmkyMEI5B3VuaTIwQkEJYWZpaTYxMjQ4CWFmaWk2MTI4OQlhZmlpNjEzNTIHdW5pMjExNwd1bmkyMTIwCWVzdGltYXRlZAd1bmkyMTUwB3VuaTIxNTEHdW5pMjE1MghvbmV0aGlyZAl0d290aGlyZHMHdW5pMjE1NQd1bmkyMTU2B3VuaTIxNTcHdW5pMjE1OAd1bmkyMTU5B3VuaTIxNUEJb25lZWlnaHRoDHRocmVlZWlnaHRocwtmaXZlZWlnaHRocwxzZXZlbmVpZ2h0aHMJYXJyb3dsZWZ0B2Fycm93dXAKYXJyb3dyaWdodAlhcnJv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wMDAwMABgP6AwAGA/oDAwMDAwMDAwAAAAAQAAAPAA8AJwAADAAkADQARAAARETMRFTUhETMRATUzFSU1MxXAAkDA/cDA/oDABIADAP0AwMADAPxABIDAwMDAwAAABAAAA8ADwAnAAAMACQANABEAABERMxEVNSERMxEBNTMVNTUzFcACQMD9wMDABIADAP0AwMADAPxABIDAwMDAwAAAAAAFAAADwAPACcAAAwAJAA0AEQAVAAARETMRFTUhETMRATUzFTM1MxUlNTMVwAJAwP0AwMDA/oDABIADAP0AwMADAPxABIDAwMDAwMDAAAAAAAQAAAPAA8AJAAADAAkADQARAAARETMRFTUhETMRATUzFTM1MxXAAkDA/QDAwMAEgAMA/QDAwAMA/EAEgMDAwMAAAAAABQAAAwADwAnAAAMABwAPABMAFwAAETUhFQERMxEBNSE1IREzEQE1MxU1NTMVAwD9AMACQP3AAkDA/cDAwAMAwMACQAJA/cD+gMDAAkD8QASAwMDAwMAAAAMAAAMAA8AJAAADAAcAEwAAAREzEQE1IRUBETMRMxUjFSEVIREDAMD9wAGA/QDAwMACQP3ABUABgP6AAYDAwPxABgD9wMDAwP6AAAADAAADAAPAB4AAAwAHAA8AABE1IRUBETMRATUhNSERMxEDAP0AwAJA/cACQMADAMDAAkACQP3A/oDAwAJA/EAAAwAAA8ADwAqAAAsADwATAAARETMVITUzESMRIRERNSEVATUhFcACQMDA/cACQP3AAkADwASAwMD7gAMA/QAEgMDAAYDAwAAABAAAA8ADwAkAAAMADQARABUAABE1MxUVNSE1ITUhNTMRATUhFQE1IRXAAkD9wAJAwP0AAkD9wAJABIDAwMDAwMDA/QADAMDAAYDAwAAAAAACAAADwAPACoAACwATAAARETMVITUzESMRIRERETMVMzUzEcACQMDA/cDAwMADwASAwMD7gAMA/QAEgAJAwMD9wAAAAAQAAAPAA8AJwAADAA0AEQAZAAARNTMVFTUhNSE1ITUzEQE1IRUBETMVMzUzEcACQP3AAkDA/QACQP3AwMDABIDAwMDAwMDA/QADAMDAAYABgMDA/oAAAAADAAACQAPACQAABQARABUAAAERMxUzFQERMxUhNTMRIxEhERE1IRUCQMDA/EDAAkDAwP3AAkAC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AAAAAAADAAADAAPAB4AABwALAA8AABERMxEhFSERAREzEQE1IRXAAkD9wAJAwP0AAkADAAPA/oDA/oACQAGA/oABgMDAAAAAAAQAAAMAA8AHgAADAAcACwAPAAABETMRATUhFSURMxERNSEVAwDA/QACQP0AwAMAAwABgP6AAYDAwMABgP6AAYDAwAAAAwAAA8ADwAeAAAMABwAPAAATNSEVJREzESERITUhFSMRwAGA/cDAAYD+gAMAwAPAwMDAAkD9wAJAwMD9wAAAAAEAAAPAA8AHgAAHAAABESE1IRUhEQGA/oADwP6AA8ADAMDA/QAAAAADAAADwAPAB4AAAwAHAAsAABM1IRUlETMRIREzEcACQP0AwAJAwAPAwMDAAwD9AAMA/QAAAwAAAwADwAeAAAMABwAVAAABETMRIREzERMRIzUzESEVIxEzFSMRAwDA/EDAwMDAAYDAwMAFQAGA/oACQP3A/cABgMACQMD+gMD+gAAAAAAJAAADAAPAB4AAAwAHAAsADwATABcAGwAfACMAABERMxEhETMRATUzFTM1MxUlNTMVJTUzFTM1MxUlNTMVITUzFcACQMD9AMDAwP6AwP6AwMDA/QDAAkDAAwABgP6AAYD+gAGAwMDAwMDAwMDAwMDAwMDAwMAAAAADAAADAAPAB4AAAwAPABMAABERMxETESM1MxEzETMVIxETETMRwMDAwMDAwMDABUACQP3A/cABgMACQP3AwP6AAkACQP3AAAAFAAADwAPAB4AAAwAHAAsADwATAAATNTMVMzUzFSURMxEhETMRIREzEcDAwMD+gMD9wMACQMADwMDAwMDAAYD+gAMA/QADAP0AAAAAAwAAA8ACQAkAAAMABwALAAATETMRATUzFTM1MxXAwP6AwMDAA8ADwPxABIDAwMDAAAAAAAUAAAPAA8AJAAADAAcACwAPABMAABM1IRUlETMRIREzEQE1MxUzNTMVwAJA/QDAAkDA/QDAwMADwMDAwAMA/QADAP0AA8DAwMDAAAAEAAADwAPAB4AAAwAHAAsADwAAEzUhFSURMxEhETMRATUhFcACQP0AwAJAwP0AAkADwMDAwAJA/cACQP3AAkDAwAAAAAQAAAPAA8AJwAADAAcACwAPAAATNSEVJREzESERMxEBETMRwAJA/QDAAkDA/cDAA8DAwMADAP0AAwD9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AADDrAAAxEAAAMTIAADFYAAAxggAAMacAADHOAAAx9gAAMhwAADIyAAAySAAAMl4AADJ1AAAyjwAAMqoAADLDAAAy2QAAMvIAADMJAAAzMwAAM0YAADNdAAAzdwAAM4MAADOPAAAzqgAAM7sAADPRAAAz5wAAM+4AADP4AAA0AwAANBUAADQhAAA0NQAANFIAADRhAAA0eQAANI0AADSYAAA0pwAANLoAADTLAAA03AAANPMAADUBAAA1DwAANSEAADU0AABAAAAAgAANpQQ/l8PPPUACwYAAAAAANA0HEwAAAAA0DOsHP6AAkAIQAqAAAAACAACAAEAAAAAAYAAAAAAAAABgAAAAYAAAAGAAAADAAAABIAAAASAAAAEgAAABIAAAAGAAAADwAAAA8AAAAPAAAAEgAAAAYAAAASAAAABgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAABgAAAAYAAAAPAAAAEgAAAA8AAAASAAAAFQAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAADAAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAADAAAABIAAAAMAAAAEgAAABIAAAAJAAAAEgAAABIAAAASAAAAEgAAABIAAAAPAAAAEgAAABIAAAAGAAAAEgAAAA8AAAAJAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAAAwAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAAPAAAABgAAAA8AAAAVAAAABgAAAA8AAAASAAAAEgAAABIAAAAGAAAAEgAAAA8AAwAYAAAADAAAAA8AAAAPAAAAGAAAABIAAAAMAAAAEgAAAAwAAAAMAAAACQAAABIAAAASAAAABgAAAAwAAwAMAAAADAAAAA8AAAAbAAAAGwAAABsAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAHgAAABIAAAASAAAAEgAAABIAAAASAAAADAAAAAwAAAAMAAAADAAAABUAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAAPAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAAeAAAAEgAAABIAAAASAAAAEgAAABIAAAAGA/0ACQAAAAkD/QAJA/0AEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABgAAAAVAAAAFQAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABUAAAAPA/0ADwP9AAwAAAAJA/0ADAAAAAkD/QAMAAAACQAAAAwAAAAGAAAAHgAAABgAAAASAAAAFQAAABIAAAAPAAAADwAAABIAAAAJAAAAEgAAAAkAAAASAAAADAAAABIAAAAMAAAAFQAAAAwAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAAYAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAAeAAAAHgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAAAwAAAASAAAAEgAAABIAAAAMAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAAPAAAAEgAAAA8AAAASAAAAEgAAABIAAAASAAAAEgAAABUAAAAVAAAAEgAAABIAAAASAAAADwAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAAB4AAAAeAAAAEgAAABIAAAASAAAAEgAAABIAAAAMAAAAEgAAABIAAAASAAAADAAAAAwAAAAMAAAACQAAAAkAAAAMAAAACQADAAwAAAAJAAAAEgAAAA8AAAAJAAAACQAAAAYAAAAGAAAAEgAAABgAAAAGAAAAGAAAABgAAAASAAAAGAAAABgAAAAYAAAADwP9ABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAADAAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAAAwAAAASAAAAEgAAABIAAAASAAAABgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAADwAAAAYAAAAPAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAADAAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAAVAAAAEgAAABIAAAASAAAADAAAAAwAAAASAAAAHgAAAB4AAAAVAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAAVAAAAEgAAABIAAAAVAAAAFQAAABgAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAAA8AAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAAYAAAAEgAAABUAAAASAAAAEgAAABUAAAASAAAAFQAAAA8AAAASAAAAEgAAABIAAAASAAAAEgAAABUAAAASAAAAEgAAABIAAAAGAAAADAAAABIAAAAbAAAAGwAAABUAAAAPAAAAEgAAABIAAAASAAAAFQAAABUAAAASAAAAEgAAABIAAAASAAAAFQAAABUAAAAVAAAAEgAAABIAAAASAAAAEgAAABIAAAAVAAAAFQAAABUAAAAVAAAAEgAAABIAAAAVAAAADwAAABIAAAASAAAAFQAAABIAAAAVAAAAFQAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABUAAAAVAAAAFQAAABUAAAASAAAAEgAAABIAAAASAAAABgAAABIAAAASAAAAFQAAABUAAAASAAAAEgAAABUAAAAVAAAAFQAAABIAAAAGAAAAEgAAABIAAAAeAAAAHgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAAJAAAACQAAAAkAAAAJAAAADwAAAA8AAAAPAAAADwAAAAwAAAAMAAAACQAAAAwAAAASAAAAGAAAAAwAAAASAAAADAAAABIAAAAJAAAACQAAAAwD+gAMAAAABgAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAASAAAAEgAAABIAAAASAAAAEgAAABIAAAASAAAAEgAAABgAAAAPAAAAGwAAABgAAAAYAAAAGAAAABUAAAAbAAAAGwAAACQAAAAbAAAAGwAAABsAAAAbAAAAGwAAABsAAAAbAAAAGwAAABsAAAAbAAAAGwAAABsAAAAYAAAAGAAAABgAAAAYAAAAGAAAABUAAwAYAAAAGAAAABgAAAAYAAAAGAAAABIAAAAbAAAAGAAAABIAAAASAAAAFQAAABIAAAAVAAAAFQAAAAwAAAAMAAAAEgAAABIAAAAPAAAADwAAABUAAAAVAAAAEgAAABUAAAAPAAAAFQAAABUAAAAPAAAADwAAABIAAAAJAAAACQAAABUAAAAYAAAAAAQAB//8AAgAAAAEAAAAAAAEAAAAOAAAAGAAgAAAAAgABAAEC1AABAAQAAAACAAAAAQAAAAEAAAAAABoBPgABAAAAAAAAABsAAAABAAAAAAABAAsAGwABAAAAAAACAAcAJgABAAAAAAADAA8ALQABAAAAAAAEAA8APAABAAAAAAAFAAsASwABAAAAAAAGABMAVgABAAAAAAAIABYAaQABAAAAAAAJAAwAfwABAAAAAAALABYAiwABAAAAAAAMABYAoQABAAAAAAANACgAtwABAAAAAAATACkA3wADAAEECQAAADYBCAADAAEECQABABYBPgADAAEECQACAA4BVAADAAEECQADAB4BYgADAAEECQAEAB4BgAADAAEECQAFABYBngADAAEECQAGACYBtAADAAEECQAIACwB2gADAAEECQAJABgCBgADAAEECQALACwCHgADAAEECQAMACwCSgADAAEECQANAFACdgADAAEECQATAFICxkNvcHlyaWdodCBBbmRyZXcgVHlsZXIgMjAxNE1pbmVjcmFmdGlhUmVndWxhck1pbmVjcmFmdGlhIDIuME1pbmVjcmFmdGlhIDIuMFZlcnNpb24gMi4wTWluZWNyYWZ0aWEtUmVndWxhcmh0dHA6Ly9hbmRyZXd0eWxlci5uZXRBbmRyZXcgVHlsZXJodHRwOi8vYW5kcmV3dHlsZXIubmV0aHR0cDovL2FuZHJld3R5bGVyLm5ldENyZWF0aXZlIENvbW1vbnMgQXR0cmlidXRpb24gU2hhcmUgQWxpa2VGaXZlIGJpZyBxdWFja2luZyB6ZXBoeXJzIGpvbHQgbXkgd2F4IGJlZABDAG8AcAB5AHIAaQBnAGgAdAAgAEEAbgBkAHIAZQB3ACAAVAB5AGwAZQByACAAMgAwADEANABNAGkAbgBlAGMAcgBhAGYAdABpAGEAUgBlAGcAdQBsAGEAcgBNAGkAbgBlAGMAcgBhAGYAdABpAGEAIAAyAC4AMABNAGkAbgBlAGMAcgBhAGYAdABpAGEAIAAyAC4AMABWAGUAcgBzAGkAbwBuACAAMgAuADAATQBpAG4AZQBjAHIAYQBmAHQAaQBhAC0AUgBlAGcAdQBsAGEAcgBoAHQAdABwADoALwAvAGEAbgBkAHIAZQB3AHQAeQBsAGUAcgAuAG4AZQB0AEEAbgBkAHIAZQB3ACAAVAB5AGwAZQByAGgAdAB0AHAAOgAvAC8AYQBuAGQAcgBlAHcAdAB5AGwAZQByAC4AbgBlAHQAaAB0AHQAcAA6AC8ALwBhAG4AZAByAGUAdwB0AHkAbABlAHIALgBuAGUAdABDAHIAZQBhAHQAaQB2AGUAIABDAG8AbQBtAG8AbgBzACAAQQB0AHQAcgBpAGIAdQB0AGkAbwBuACAAUwBoAGEAcgBlACAAQQBsAGkAawBlAEYAaQB2AGUAIABiAGkAZwAgAHEAdQBhAGMAawBpAG4AZwAgAHoAZQBwAGgAeQByAHMAIABqAG8AbAB0ACAAbQB5ACAAdwBhAHgAIABiAGUAZAAAAAAAAwAAAAMAAAAeAAEAAAAAAyYAAwABAAAFMAAAAAQDCAAAAK4AgAAGAC4AfgCsAX8BgwGPAZIBtwHrAe8B/wIbAjcCWQKSAscCywLdA3UDfgOKA4wDoQPOA9cEXwRjBHUEkwSdBKMEqwSzBLsEwgTKBM8E1QTZBOkE8R6FHp4e8yAjICYgMCAzIDYgOiBEIHEgeSCJIKkgrCCuILEgtCC6IQUhEyEXISAhIiEuIV4hmSIG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"

    local Minecraftia = Register_Font("AstraMinecraftia!", 400, "Normal", {
        Id = "AstraMinecraftia.ttf",
        Font = b64decode(MinecraftiaB64),
    })

    fonts = {
        main = Font.new(Minecraftia, Enum.FontWeight.Regular, Enum.FontStyle.Normal);
    }
end

HitLog:SetTextFontFace(fonts.main)

local function ensure_gradient(parent, name)
    name = name or "BoxGradient"
    local grad = parent:FindFirstChild(name)
    if not grad then
        grad = Instance.new("UIGradient")
        grad.Name = name
        grad.Parent = parent
    end
    return grad
end

local function get_name_text(player)
    if flags["Name_Mode"] == "DisplayName" then
        return player.DisplayName
    elseif flags["Name_Mode"] == "Username" then
        return "@" .. player.Name
    end
    return string.format("%s (@%s)", player.DisplayName, player.Name)
end

local esp_gui_parent = (gethui and gethui()) or game:GetService("CoreGui")
local esp = { players = {}, screengui = Instance.new("ScreenGui", esp_gui_parent), cache = Instance.new("ScreenGui", esp_gui_parent), connections = {}}; do
    esp.screengui.IgnoreGuiInset = true
    esp.screengui.DisplayOrder   = -1
    esp.screengui.Name = "\0"

    esp.cache.Enabled = false

        function esp:get_screen_pos(world_position)
            local pos, on_screen = esp_camera:WorldToViewportPoint(world_position)
            return pos, on_screen
        end

        function esp:box_solve(torso)
            if not torso then
                return nil, nil, nil
            end

            -- кеш сифермай
            local cam_cf     = esp_camera.CFrame
            local torso_pos  = torso.Position
            local up_vec     = torso.CFrame.UpVector

            local ViewportTop    = torso_pos + (up_vec * 1.8)
            local ViewportBottom = torso_pos - (up_vec * 2.5)
            local Distance       = (torso_pos - cam_cf.p).Magnitude

            -- хз че
            local Top,    TopIsRendered    = esp_camera:WorldToViewportPoint(ViewportTop)
            local Bottom, BottomIsRendered = esp_camera:WorldToViewportPoint(ViewportBottom)

            local Width   = math.max(math.floor(math.abs(Top.X - Bottom.X)), 3)
            local Height  = math.max(math.floor(math.max(math.abs(Bottom.Y - Top.Y), Width / 2)), 3)
            local BoxSize = Vector2.new(math.floor(math.max(Height / 1.5, Width)), Height)
            local BoxPos  = Vector2.new(math.floor(Top.X * 0.5 + Bottom.X * 0.5 - BoxSize.X * 0.5), math.floor(math.min(Top.Y, Bottom.Y)))

            return BoxSize, BoxPos, TopIsRendered, Distance
        end

        function esp:create(instance, options)
            local ins = Instance.new(instance)

            for prop, value in options do
                ins[prop] = value
            end

            return ins
        end

        function esp:get_boxy_skeleton(char)
            local segments = {}
            local is_r15 = char:FindFirstChild("UpperTorso") ~= nil
            
            if is_r15 then
                local head = char:FindFirstChild("Head")
                local upperTorso = char:FindFirstChild("UpperTorso")
                local lowerTorso = char:FindFirstChild("LowerTorso")
                local leftUpperArm = char:FindFirstChild("LeftUpperArm")
                local rightUpperArm = char:FindFirstChild("RightUpperArm")
                local leftHand = char:FindFirstChild("LeftHand")
                local rightHand = char:FindFirstChild("RightHand")
                local leftUpperLeg = char:FindFirstChild("LeftUpperLeg")
                local rightUpperLeg = char:FindFirstChild("RightUpperLeg")
                local leftFoot = char:FindFirstChild("LeftFoot")
                local rightFoot = char:FindFirstChild("RightFoot")
                
                if head and upperTorso and lowerTorso and leftUpperArm and rightUpperArm and leftHand and rightHand and leftUpperLeg and rightUpperLeg and leftFoot and rightFoot then
                    local neck = upperTorso.CFrame * CFrame.new(0, upperTorso.Size.Y/2, 0)
                    local pelvis = lowerTorso.CFrame * CFrame.new(0, -lowerTorso.Size.Y/2, 0)
                    
                    local leftShoulder = leftUpperArm.CFrame * CFrame.new(0, leftUpperArm.Size.Y/2, 0)
                    local rightShoulder = rightUpperArm.CFrame * CFrame.new(0, rightUpperArm.Size.Y/2, 0)
                    
                    local leftHip = leftUpperLeg.CFrame * CFrame.new(0, leftUpperLeg.Size.Y/2, 0)
                    local rightHip = rightUpperLeg.CFrame * CFrame.new(0, rightUpperLeg.Size.Y/2, 0)
                    
                    table.insert(segments, {neck.Position, pelvis.Position}) -- spine
                    table.insert(segments, {neck.Position, leftShoulder.Position}) -- left collar
                    table.insert(segments, {neck.Position, rightShoulder.Position}) -- right collar
                    table.insert(segments, {leftShoulder.Position, leftHand.Position}) -- left arm
                    table.insert(segments, {rightShoulder.Position, rightHand.Position}) -- right arm
                    table.insert(segments, {pelvis.Position, leftHip.Position}) -- left pelvis
                    table.insert(segments, {pelvis.Position, rightHip.Position}) -- right pelvis
                    table.insert(segments, {leftHip.Position, leftFoot.Position}) -- left leg
                    table.insert(segments, {rightHip.Position, rightFoot.Position}) -- right leg
                end
            else
                local head = char:FindFirstChild("Head")
                local torso = char:FindFirstChild("Torso")
                local leftArm = char:FindFirstChild("Left Arm")
                local rightArm = char:FindFirstChild("Right Arm")
                local leftLeg = char:FindFirstChild("Left Leg")
                local rightLeg = char:FindFirstChild("Right Leg")
                
                if head and torso and leftArm and rightArm and leftLeg and rightLeg then
                    local neck = torso.CFrame * CFrame.new(0, torso.Size.Y/2, 0)
                    local pelvis = torso.CFrame * CFrame.new(0, -torso.Size.Y/2, 0)
                    
                    local leftShoulder = torso.CFrame * CFrame.new(-torso.Size.X/2 - leftArm.Size.X/2, torso.Size.Y/2, 0)
                    local rightShoulder = torso.CFrame * CFrame.new(torso.Size.X/2 + rightArm.Size.X/2, torso.Size.Y/2, 0)
                    
                    local leftHip = torso.CFrame * CFrame.new(-torso.Size.X/4, -torso.Size.Y/2, 0)
                    local rightHip = torso.CFrame * CFrame.new(torso.Size.X/4, -torso.Size.Y/2, 0)
                    
                    table.insert(segments, {neck.Position, pelvis.Position}) -- spine
                    table.insert(segments, {neck.Position, leftShoulder.Position}) -- left collar
                    table.insert(segments, {neck.Position, rightShoulder.Position}) -- right collar
                    table.insert(segments, {leftShoulder.Position, leftArm.CFrame * CFrame.new(0, -leftArm.Size.Y/2, 0).Position}) -- left arm
                    table.insert(segments, {rightShoulder.Position, rightArm.CFrame * CFrame.new(0, -rightArm.Size.Y/2, 0).Position}) -- right arm
                    table.insert(segments, {pelvis.Position, leftHip.Position}) -- left pelvis
                    table.insert(segments, {pelvis.Position, rightHip.Position}) -- right pelvis
                    table.insert(segments, {leftHip.Position, leftLeg.CFrame * CFrame.new(0, -leftLeg.Size.Y/2, 0).Position}) -- left leg
                    table.insert(segments, {rightHip.Position, rightLeg.CFrame * CFrame.new(0, -rightLeg.Size.Y/2, 0).Position}) -- right leg
                end
            end
            return segments
        end

        function esp:create_object( player )
            esp[ player.Name ] = { objects = { }, info = {character = character; humanoid = humanoid}; drawings = { }, skeleton = {} }
            local data = esp[ player.Name ]

            if Drawing then
                for i = 1, 14 do
                    local out_line = Drawing.new("Line")
                    out_line.Visible = false
                    out_line.Thickness = 3
                    
                    local in_line = Drawing.new("Line")
                    in_line.Visible = false
                    in_line.Thickness = 1
                    
                    table.insert(data.drawings, out_line)
                    table.insert(data.drawings, in_line)
                    table.insert(data.skeleton, {
                        out = out_line,
                        in_line = in_line
                    })
                end
                
                data.headdot_out = Drawing.new("Circle")
                data.headdot_out.Visible = false
                data.headdot_out.Thickness = 3
                data.headdot_out.Filled = false
                table.insert(data.drawings, data.headdot_out)

                data.headdot = Drawing.new("Circle")
                data.headdot.Visible = false
                data.headdot.Thickness = 1
                data.headdot.Filled = false
                table.insert(data.drawings, data.headdot)
            end

            local objects = data.objects; do
                objects[ "holder" ] = esp:create( "Frame" , {
                    Parent = esp.screengui;
                    Name = "\0";
                    BackgroundTransparency = 1;
                    ClipsDescendants = false;
                    Position = dim2(0, 0, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(0, 0, 0, 0);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });

                objects[ "box_outline" ] = esp:create( "UIStroke" , {
                    Parent = (flags["Boxes"] and flags["Box_Type"] ~= "Corner" and objects["holder"]) or esp.cache;
                    LineJoinMode = Enum.LineJoinMode.Miter
                });

                objects[ "name" ] = esp:create( "TextLabel" , {
                    FontFace = fonts.main;
                    Parent = esp.cache;
                    TextColor3 = flags["Name_Color"].Color;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = get_name_text(player);
                    Name = "\0";
                    TextStrokeTransparency = 0;
                    AnchorPoint = vec2(0, 1);
                    Size = dim2(1, 0, 0, 0);
                    BackgroundTransparency = 1;
                    Position = dim2(0, 0, 0, -5);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.Y;
                    TextSize = 10;
                });

                objects[ "ff_text" ] = esp:create( "TextLabel" , {
                    FontFace = fonts.main;
                    Parent = objects[ "holder" ];
                    TextColor3 = rgb(0, 140, 255);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "FF";
                    Name = "\0";
                    TextStrokeTransparency = 0;
                    AnchorPoint = vec2(0, 0);
                    Size = dim2(0, 0, 0, 0);
                    BackgroundTransparency = 1;
                    Position = dim2(1, 6, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 10;
                    Visible = false;
                });

                objects[ "downed_text" ] = esp:create( "TextLabel" , {
                    FontFace = fonts.main;
                    Parent = objects[ "holder" ];
                    TextColor3 = rgb(255, 0, 0);
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "D";
                    Name = "\0";
                    TextStrokeTransparency = 0;
                    AnchorPoint = vec2(0, 0);
                    Size = dim2(0, 0, 0, 0);
                    BackgroundTransparency = 1;
                    Position = dim2(1, 6, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 10;
                    Visible = false;
                });

                objects[ "combat_zone_text" ] = esp:create( "TextLabel" , {
                    FontFace = fonts.main;
                    Parent = objects[ "holder" ];
                    TextColor3 = flags["CombatZone_Color"].Color;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "⚔CZ";
                    Name = "\0";
                    TextStrokeTransparency = 0;
                    AnchorPoint = vec2(0, 0);
                    Size = dim2(0, 0, 0, 0);
                    BackgroundTransparency = 1;
                    Position = dim2(1, 6, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 10;
                    Visible = false;
                });

                objects[ "level_text" ] = esp:create( "TextLabel" , {
                    FontFace = fonts.main;
                    Parent = objects[ "holder" ];
                    TextColor3 = flags["Level_Color"].Color;
                    BorderColor3 = rgb(0, 0, 0);
                    Text = "L0";
                    Name = "\0";
                    TextStrokeTransparency = 0;
                    AnchorPoint = vec2(0, 0);
                    Size = dim2(0, 0, 0, 0);
                    BackgroundTransparency = 1;
                    Position = dim2(1, 6, 0, 0);
                    BorderSizePixel = 0;
                    AutomaticSize = Enum.AutomaticSize.XY;
                    TextSize = 10;
                    Visible = false;
                });

                objects[ "box_handler" ] = esp:create( "Frame" , {
                    Parent = (flags["Boxes"] and flags["Box_Type"] ~= "Corner" and objects["holder"]) or esp.cache;
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });

                objects[ "box_color" ] = esp:create( "UIStroke" , {
                    Color = rgb(255, 255, 255);
                    LineJoinMode = Enum.LineJoinMode.Miter;
                    Name = "\0";
                    Parent = objects[ "box_handler" ]
                });

                objects[ "outline" ] = esp:create( "Frame" , {
                    Parent = objects[ "box_handler" ];
                    Name = "\0";
                    BackgroundTransparency = 1;
                    Position = dim2(0, 1, 0, 1);
                    BorderColor3 = rgb(0, 0, 0);
                    Size = dim2(1, -2, 1, -2);
                    BorderSizePixel = 0;
                    BackgroundColor3 = rgb(255, 255, 255)
                });

                esp:create( "UIStroke" , {
                    Parent = objects[ "outline" ];
                    LineJoinMode = Enum.LineJoinMode.Miter
                });

                    objects[ "corners" ] = esp:create( "Frame" , {
                        Visible = true;
                        BorderColor3 = rgb(0, 0, 0);
                        Parent = flags["Boxes"] and flags["Box_Type"] == "Corner" and objects["holder"] or esp.cache;
                        BackgroundTransparency = 1;
                        Position = dim2(0, -1, 0, 2);
                        Name = "\0";
                        Size = dim2(1, 0, 1, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });

                    objects[ "1" ] = esp:create( "Frame" , {
                        Parent = objects[ "corners" ];
                        Name = "line";
                        Position = dim2(0, 0, 0, -2);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0.4, 0, 0, 3);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });

                    esp:create( "Frame" , {
                        Parent = objects[ "1" ];
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = flags["Box_Color"].Color
                    });

                    objects[ "2" ] = esp:create( "Frame" , {
                        Parent = objects[ "corners" ];
                        Name = "line";
                        Position = dim2(0, 0, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 3, 0.25, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });

                    esp:create( "Frame" , {
                        Parent = objects[ "2" ];
                        Position = dim2(0, 1, 0, -2);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, 1);
                        BorderSizePixel = 0;
                        BackgroundColor3 = flags["Box_Color"].Color
                    });

                    objects[ "3" ] = esp:create( "Frame" , {
                        AnchorPoint = vec2(1, 0);
                        Parent = objects[ "corners" ];
                        Name = "line";
                        Position = dim2(1, 0, 0, -2);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0.4, 0, 0, 3);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });

                    esp:create( "Frame" , {
                        Parent = objects[ "3" ];
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = flags["Box_Color"].Color
                    });

                    objects[ "4" ] = esp:create( "Frame" , {
                        AnchorPoint = vec2(1, 0);
                        Parent = objects[ "corners" ];
                        Name = "line";
                        Position = dim2(1, 0, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 3, 0.25, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });

                    esp:create( "Frame" , {
                        Parent = objects[ "4" ];
                        Position = dim2(0, 1, 0, -2);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, 1);
                        BorderSizePixel = 0;
                        BackgroundColor3 = flags["Box_Color"].Color
                    });

                    objects[ "5" ] = esp:create( "Frame" , {
                        AnchorPoint = vec2(0, 1);
                        Parent = objects[ "corners" ];
                        Name = "line";
                        Position = dim2(0, 0, 1, -2);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0.4, 0, 0, 3);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });

                    esp:create( "Frame" , {
                        Parent = objects[ "5" ];
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = flags["Box_Color"].Color
                    });

                    objects[ "6" ] = esp:create( "Frame" , {
                        BorderColor3 = rgb(0, 0, 0);
                        Rotation = 180;
                        Parent = objects[ "corners" ];
                        Name = "line";
                        Position = dim2(0, 0, 1, -5);
                        AnchorPoint = vec2(0, 1);
                        Size = dim2(0, 3, 0.25, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });

                    esp:create( "Frame" , {
                        Parent = objects[ "6" ];
                        Position = dim2(0, 1, 0, -2);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, 1);
                        BorderSizePixel = 0;
                        BackgroundColor3 = flags["Box_Color"].Color
                    });

                    objects[ "7" ] = esp:create( "Frame" , {
                        AnchorPoint = vec2(1, 1);
                        Parent = objects[ "corners" ];
                        Name = "line";
                        Position = dim2(1, 0, 1, -2);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0.4, 0, 0, 3);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });

                    esp:create( "Frame" , {
                        Parent = objects[ "7" ];
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = flags["Box_Color"].Color
                    });

                    objects[ "7" ] = esp:create( "Frame" , {
                        BorderColor3 = rgb(0, 0, 0);
                        Rotation = 180;
                        Parent = objects[ "corners" ];
                        Name = "line";
                        Position = dim2(1, 0, 1, -5);
                        AnchorPoint = vec2(1, 1);
                        Size = dim2(0, 3, 0.25, 0);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });

                    esp:create( "Frame" , {
                        Parent = objects[ "7" ];
                        Position = dim2(0, 1, 0, -2);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, 1);
                        BorderSizePixel = 0;
                        BackgroundColor3 = flags["Box_Color"].Color
                    });

                    objects[ "healthbar_holder" ] = esp:create( "Frame" , {
                        AnchorPoint = vec2(1, 0);
                        Parent = flags["Healthbar"] and objects[ "holder" ] or esp.cache;
                        Name = "\0";
                        Position = dim2(0, -1, 0, -1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 4, 1, 2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });

                    objects[ "healthbar" ] = esp:create( "Frame" , {
                        Parent = objects[ "healthbar_holder" ];
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(255, 255, 255)
                    });

                    objects[ "health_text" ] = esp:create( "TextLabel" , {
                        FontFace = fonts.main;
                        Parent = esp.cache;
                        TextColor3 = flags["Health_High"].Color;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "100";
                        Name = "\0";
                        TextStrokeTransparency = 0;
                        AnchorPoint = vec2(1, 0);
                        Size = dim2(0, 0, 0, 0);
                        BackgroundTransparency = 1;
                        Position = flags["Healthbar"] and dim2(0, -7, 0, -1) or dim2(0, 0, 0, -1);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.XY;
                        TextSize = 10;
                    });

                    
                    objects[ "armor_text" ] = esp:create( "TextLabel" , {
                        FontFace = fonts.main;
                        Parent = esp.cache;
                        TextColor3 = flags["Armor_Color"].Color;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "0";
                        Name = "\0";
                        TextStrokeTransparency = 0;
                        AnchorPoint = vec2(0, 0);
                        Size = dim2(0, 0, 0, 0);
                        BackgroundTransparency = 1;
                        Position = dim2(1, 6, 0, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.XY;
                        TextSize = 10;
                        Visible = false;
                    });
                    objects[ "distance" ] = esp:create( "TextLabel" , {
                        FontFace = fonts.main;
                        TextColor3 = flags["Distance_Color"].Color;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "127st";
                        Parent = flags[ "Distance" ] and objects[ "holder" ] or esp.cache;
                        TextStrokeTransparency = 0;
                        Name = "\0";
                        Size = dim2(1, 0, 0, 0);
                        BackgroundTransparency = 1;
                        Position = dim2(0, 0, 1, 5);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        TextSize = 10;
                    });
                    objects[ "weapon" ] = esp:create( "TextLabel" , {
                        FontFace = fonts.main;
                        TextColor3 = flags["Weapon_Color"].Color;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "ak-47";
                        Parent = esp.cache;
                        TextStrokeTransparency = 0;
                        Name = "\0";
                        Size = dim2(1, 0, 0, 0);
                        BackgroundTransparency = 1;
                        Position = dim2(0, 0, 1, 19);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.Y;
                        TextSize = 10;
                    });

                    
                    objects[ "armorbar_holder" ] = esp:create( "Frame" , {
                        AnchorPoint = vec2(0, 0);
                        Parent = esp.cache;
                        Name = "\0";
                        Position = dim2(1, 1, 0, -1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(0, 4, 1, 2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });

                    objects[ "armorbar" ] = esp:create( "Frame" , {
                        Parent = objects[ "armorbar_holder" ];
                        Name = "\0";
                        Position = dim2(0, 1, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, -2, 1, -2);   
                        BorderSizePixel = 0;
                        BackgroundColor3 = flags["Armor_Color"].Color
                    });

                    
                    objects[ "crouch_text" ] = esp:create( "TextLabel" , {
                        FontFace = fonts.main;
                        Parent = esp.cache;
                        TextColor3 = flags["Crouch_Color"].Color;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "C";
                        Name = "\0";
                        TextStrokeTransparency = 0;
                        AnchorPoint = vec2(0, 0);
                        Size = dim2(0, 0, 0, 0);
                        BackgroundTransparency = 1;
                        Position = dim2(1, 6, 0, 0);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.XY;
                        TextSize = 10;
                        Visible = false;
                    });

                    
                    
                    
                    
                    
                    
                    objects[ "reloadbar_holder" ] = esp:create( "Frame" , {
                        Parent = esp.cache;
                        Name = "\0";
                        Position = dim2(0, 0, 1, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, 0, 0, 4);
                        BorderSizePixel = 0;
                        BackgroundColor3 = rgb(0, 0, 0)
                    });

                    objects[ "reloadbar" ] = esp:create( "Frame" , {
                        Parent = objects[ "reloadbar_holder" ];
                        Name = "\0";
                        Position = dim2(0, 0, 0, 1);
                        BorderColor3 = rgb(0, 0, 0);
                        Size = dim2(1, 0, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = flags["Reload_Color"].Color
                    });

                    objects[ "reload_text" ] = esp:create( "TextLabel" , {
                        FontFace = fonts.main;
                        Parent = esp.cache;
                        TextColor3 = flags["Reload_Color"].Color;
                        BorderColor3 = rgb(0, 0, 0);
                        Text = "1.0s";
                        Name = "\0";
                        TextStrokeTransparency = 0;
                        AnchorPoint = vec2(0, 0.5);
                        Size = dim2(0, 0, 0, 0);
                        BackgroundTransparency = 1;
                        Position = dim2(1, 4, 1, 3);
                        BorderSizePixel = 0;
                        AutomaticSize = Enum.AutomaticSize.XY;
                        TextSize = 10;
                    });

            end

            do
                -- смузи
                data._hp_target   = 100
                data._hp_display  = 100
                data._hp_max      = 100
                data._armor_target  = 0
                data._armor_display = 0

                data.health_changed = function( value )
                    local humanoid = data.info.humanoid
                    data._hp_target = value
                    data._hp_max    = humanoid.MaxHealth > 0 and humanoid.MaxHealth or 100

                    -- позиция текста и парента
                    if not flags[ "Healthbar" ] then return end
                    if flags["Health_Text"] then
                        objects[ "health_text" ].Parent      = objects[ "holder" ]
                        objects[ "health_text" ].AnchorPoint = vec2(1, 0)
                    else
                        objects[ "health_text" ].Parent = esp.cache
                    end
                end

                -- ммм пилигрим

                data.tool_added = function( item )
                    if not item:IsA("Tool") then
                        return
                    end
                    
                    objects[ "weapon" ].Text = string.gsub(item.Name, "[%[%]]", "")
                end

                data.refresh_offsets = function()
                    local offset = 5;

                    if objects["distance"].Parent == objects[ "holder" ] then
                        offset += 5
                        objects[ "weapon" ].Position = dim2(0, 0, 1, offset)
                    end

                    if objects[ "weapon" ].Parent == objects[ "holder" ] then
                        offset += 5
                        objects[ "weapon" ].Position = dim2(0, 0, 1, offset)
                    end
                end

                
                
                data.update_health_text_offset = function()
                    if not flags["Healthbar"] then
                        objects[ "health_text" ].Position = dim2(0, 0, 0, -1)
                        return
                    end

                    local offset = -2
                    if flags["Healthbar"] then offset -= (4 + 1) end

                    objects[ "health_text" ].Position = dim2(0, offset, 0, -1)
                end

                
                data.armor_changed = function()
                    local char_stats = RepSt:FindFirstChild("CharStats")
                    local stat_entry = char_stats and char_stats:FindFirstChild(player.Name)
                    if not stat_entry then
                        objects[ "armorbar_holder" ].Parent = esp.cache
                        objects[ "armor_text" ].Visible     = false
                        data.update_health_text_offset()
                        return
                    end

                    local armor_hp = stat_entry:FindFirstChild("ArmorHP")
                    local body_val = armor_hp and armor_hp:FindFirstChild("Body")
                    local head_val = armor_hp and armor_hp:FindFirstChild("Head")

                    local body_hp = body_val and body_val.Value or 0
                    local head_hp = head_val and head_val.Value or 0

                    if body_hp <= 0 and head_hp <= 0 then
                        objects[ "armorbar_holder" ].Parent = esp.cache
                        objects[ "armor_text" ].Visible     = false
                        data.update_health_text_offset()
                        return
                    end

                    if not flags["Armorbar"] then
                        objects[ "armorbar_holder" ].Parent = esp.cache
                        objects[ "armor_text" ].Visible     = false
                        data.update_health_text_offset()
                        return
                    end

                    objects[ "armorbar_holder" ].Parent = objects[ "holder" ]

                    -- армор текст парент
                    if objects[ "armor_text" ].Parent ~= objects[ "holder" ] then
                        objects[ "armor_text" ].Parent = objects[ "holder" ]
                    end

                    data.update_health_text_offset()

                    local avg        = (body_hp + head_hp) / 2
                    local multiplier = math.clamp(avg / 100, 0, 1)
                    data._armor_mult = multiplier  -- сохранение кфг для лупа
                    local mode       = flags["Armorbar_Mode"]
                    local col1       = flags["Armor_High"].Color
                    local col2       = flags["Armor_Low"].Color

                    local barColor
                    if mode == "Static" then
                        barColor = col1
                    elseif mode == "Dynamic" then
                        barColor = col2:Lerp(col1, multiplier)
                    else
                        barColor = rgb(255, 255, 255)
                    end

                    local textColor
                    if mode == "Static" then
                        textColor = flags["Armor_Text_Color"].Color
                    else
                        textColor = col2:Lerp(col1, multiplier)
                    end

                
                    data._armor_target = avg

                    if flags["Armor_Text"] then
                        objects[ "armor_text" ].AnchorPoint = vec2(0, 0)
                        objects[ "armor_text" ].Visible     = true
                    else
                        objects[ "armor_text" ].Visible = false
                    end
                end

                data.refresh_descendants = function()
                    local character = player.Character or player.CharacterAdded:Wait()
                    local humanoid = character:WaitForChild("Humanoid")
                    local rp = character:WaitForChild("HumanoidRootPart")

                    data.info.character = character
                    data.info.humanoid  = humanoid
                    data.info.rootpart  = rp

                    data._leaderstats = nil

                    humanoid.HealthChanged:Connect(data.health_changed)

                    character.ChildAdded:Connect(data.tool_added)
                    character.ChildRemoved:Connect(data.tool_added)

                    data.health_changed(humanoid.Health)

                    local tool = character:FindFirstChildOfClass("Tool")
                    if tool then data.tool_added(tool) end
                end
            end

            do
                task.spawn(function()
                    data.refresh_descendants()
                end)

                player.CharacterAdded:Connect(data.refresh_descendants)
            end
        end

                function esp:remove_object(player)
            local holder = esp[player.Name]

            if not holder then return end

            local objects = holder.objects

            for _, line in ipairs(holder.drawings or {}) do
                if line.Remove then line:Remove() end
            end

            if objects and objects["holder"] then
                objects["holder"]:Destroy()
            end
            esp[player.Name] = nil
        end

        function esp.refresh_elements( )
            for _,v in esp_players:GetPlayers() do
                if v == esp_players.LocalPlayer then
                    continue
                end

                local path = esp[v.Name]
                local objects = path and path.objects

                if not objects then
                    continue
                end
                objects.holder.Parent = flags["Enabled"] and esp.screengui or esp.cache

                objects[ "name" ].Parent = flags["Names"] and objects["holder"] or esp.cache

                local v_status = get_player_status(v)
                local s_col
                if v_status == "Priority" or v_status == "Enemy" then
                    s_col = flags["Enemy_Color"].Color
                elseif v_status == "Friendly" then
                    s_col = flags["Friendly_Color"].Color
                end

                objects[ "name" ].TextColor3     = s_col or flags["Name_Color"].Color
                objects[ "distance" ].TextColor3  = flags["Distance_Color"].Color
                objects[ "box_color" ].Color      = flags["Box_Color"].Color

                objects[ "name" ].Text = get_name_text(v)

                local is_corner = flags[ "Box_Type" ] == "Corner"

                if flags["Boxes"] then
                    objects[ "corners" ].Parent = (is_corner and objects["holder"]) or esp.cache
                    objects[ "box_handler" ].Parent = (is_corner and esp.cache or objects[ "holder" ])
                    objects[ "box_outline" ].Parent = (is_corner and esp.cache or objects[ "holder" ])
                else
                    objects[ "corners" ].Parent = esp.cache
                    objects[ "box_handler" ].Parent = esp.cache
                    objects[ "box_outline" ].Parent = esp.cache
                end
                objects[ "box_color" ].Color = flags["Box_Color"].Color

                local box_gradient_seq = rgbseq({
                    rgbkey(0, flags["Box_Color"].Color),
                    rgbkey(1, flags["Box_Gradient_Color"].Color),
                })

                local box_color_gradient = ensure_gradient(objects[ "box_color" ], "BoxGradient")
                box_color_gradient.Enabled = flags["Box_Gradient"]
                box_color_gradient.Rotation = 90
                box_color_gradient.Color = box_gradient_seq

                for _, corner in objects[ "corners" ]:GetChildren() do
                    corner.Frame.BackgroundColor3 = flags["Box_Color"].Color

                    local corner_gradient = ensure_gradient(corner.Frame, "BoxGradient")
                    corner_gradient.Enabled = flags["Box_Gradient"]
                    corner_gradient.Rotation = 90
                    corner_gradient.Color = box_gradient_seq
                end

                objects[ "healthbar_holder" ].Parent = flags[ "Healthbar" ] and objects[ "holder" ] or esp.cache
                if not flags["Healthbar"] then
                    objects[ "health_text" ].Parent      = flags[ "Health_Text" ] and objects[ "holder" ] or esp.cache
                    objects[ "health_text" ].AnchorPoint = vec2(1, 0)
                    objects[ "health_text" ].Position    = dim2(0, -2, 0, -1)
                end
                if path.health_changed and path.info.humanoid then
                    path.health_changed(path.info.humanoid.Health)
                end

                
                objects[ "armorbar_holder" ].Position = dim2(1, 2, 0, -1)
                
                if path.armor_changed then
                    path.armor_changed()
                elseif path.update_health_text_offset then
                    path.update_health_text_offset()
                end

                
                objects[ "crouch_text" ].TextColor3 = flags["Crouch_Color"].Color
                if not flags["Crouching"] then
                    objects[ "crouch_text" ].Parent = esp.cache
                end

                objects[ "weapon" ].TextColor3 = flags["Weapon_Color"].Color
                objects[ "weapon" ].Position = flags["Distance"] and dim2(0, 0, 1, 19) or dim2(0, 0, 1, 5)

                objects[ "distance" ].TextColor3 = flags["Distance_Color"].Color
                objects[ "distance" ].Parent = flags["Distance"] and objects[ "holder" ] or esp.cache
            end
        end

        
        
        
        local RELOAD_TIMES = {
            ["Beretta"]              = 2.25,
            ["G-17"]                 = 2.25,
            ["TEC-9"]                = 3.0,
            ["M1911"]                = 2.5,
            ["FNP-45"]               = 2.25,
            ["Deagle"]               = 3.0,
            ["Magnum"]               = 3.0,
            ["G-18"]                 = 2.25,
            ["Hawkeye"]              = 3.0,
            ["FM 1911"]              = 2.5,
            ["Uzi"]                  = 3.0,
            ["MAC-10"]               = 3.0,
            ["MP7"]                  = 3.0,
            ["UMP 45"]               = 3.25,
            ["Tommy Gun"]            = 4.0,
            ["MP5"]                  = 3.25,
            ["Sawn-Off"]             = 2.5,
            ["Super-Shorty"]         = 1.0,
            ["Ithaca-37"]            = 1.25,
            ["AKS-74U"]              = 3.5,
            ["M4A1"]                 = 3.0,
            ["SCAR-H"]               = 3.5,
            ["AKM"]                  = 3.85,
            ["SKS"]                  = 4.0,
            ["FN-FAL"]               = 3.5,
            ["M60"]                  = 8.0,
            ["Scout"]                = 4.5,
            ["Mare"]                 = 0.6,
            ["BFG"]                  = 4.5,
            ["Firework Launcher"]    = 4.0,
            ["M320"]                 = 3.5,
            ["RPG"]                  = 6.0,
            ["Ray Gun"]              = 3.0,
            ["Ray Gun V2"]           = 3.0,
            ["Musket"]               = 7.0,
        }

        local _char_stats_cache     = nil  -- CharStats folder, обновляется при nil
        local _chars_folder_cache   = nil  -- workspace.Characters folder
        local _RELOAD_STOP_DUR      = 0.6
        local _FLAG_KEYS            = { "ff_text", "downed_text", "crouch_text", "level_text", "combat_zone_text" }
        local _GAP                  = 2


        local _ESP_REFRESH_RATE     = 1 / 85  -- обновляем по умолчанию 85 раз/сек

        local _cached_players       = {}
        local _players_dirty        = true

        esp_players.PlayerAdded:Connect(function()   _players_dirty = true end)
        esp_players.PlayerRemoving:Connect(function() _players_dirty = true end)

        local _last_esp_tick = 0
        
        esp.render_connection = esp_run.RenderStepped:Connect(function(dt)
            if not flags["Enabled"] then return end
            local speed = 4 * dt
            for i = 1, #_cached_players do
                local player = _cached_players[i]
                local data   = esp[player.Name]
                if not data then continue end
                
                local objects = data.objects
                if not objects or not objects["holder"] then continue end
                
                if data._hp_display ~= nil and data._hp_target ~= nil then
                    if data._hp_display ~= data._hp_target then
                        data._hp_display = data._hp_display + (data._hp_target - data._hp_display) * math.min(speed, 1)
                        if math.abs(data._hp_display - data._hp_target) < 0.05 then
                            data._hp_display = data._hp_target
                        end
                    end

                    local hpMax  = data._hp_max or 100
                    local mult   = math.clamp(hpMax > 0 and data._hp_display / hpMax or 0, 0, 1)
                    local mode   = flags["Healthbar_Mode"]
                    local col1   = flags["Health_High"].Color
                    local col2   = flags["Health_Low"].Color

                    local barColor
                    if mode == "Static" then barColor = col1
                    elseif mode == "Dynamic" then barColor = col2:Lerp(col1, mult)
                    else barColor = rgb(255, 255, 255) end

                    if flags["Healthbar"] then
                        local hb = objects["healthbar"]
                        local sz = UDim2.new(1, -2, mult, -2)
                        local ps = UDim2.new(0, 1, 1 - mult, 1)
                        if hb.Size ~= sz then hb.Size = sz end
                        if hb.Position ~= ps then hb.Position = ps end
                        if hb.BackgroundColor3 ~= barColor then hb.BackgroundColor3 = barColor end

                        local healthbar_gradient = ensure_gradient(hb, "HealthGradient")
                        if mode == "Gradient" then
                            if not healthbar_gradient.Enabled then healthbar_gradient.Enabled = true end
                            if healthbar_gradient.Rotation ~= 270 then healthbar_gradient.Rotation = 270 end
                            healthbar_gradient.Color    = rgbseq({
                                rgbkey(0, col2),
                                rgbkey(mult, col1:Lerp(col2, 1 - mult)),
                                rgbkey(1, col1),
                            })
                            if healthbar_gradient.Parent ~= hb then healthbar_gradient.Parent = hb end
                        else
                            if healthbar_gradient.Enabled then healthbar_gradient.Enabled = false end
                            if healthbar_gradient.Parent ~= nil then healthbar_gradient.Parent = nil end
                        end
                    end

                    local textColor
                    if mode == "Static" then textColor = flags["Health_Text_Color"].Color
                    else textColor = col2:Lerp(col1, mult) end

                    local h_text = objects["health_text"]
                    local new_text = math.floor(data._hp_display) > 9999 and "inf" or tostring(math.floor(data._hp_display))
                    if h_text.Text ~= new_text then h_text.Text = new_text end
                    if h_text.TextColor3 ~= textColor then h_text.TextColor3 = textColor end

                    if flags["Healthbar"] then
                        local ps = UDim2.new(0, -7, 1 - mult, -1)
                        if h_text.Position ~= ps then h_text.Position = ps end
                    else
                        local ps = UDim2.new(0, 0, 0, -1)
                        if h_text.Position ~= ps then h_text.Position = ps end
                    end
                end

                if data._armor_display ~= nil and data._armor_target ~= nil then
                    if data._armor_display ~= data._armor_target then
                        data._armor_display = data._armor_display + (data._armor_target - data._armor_display) * math.min(speed, 1)
                        if math.abs(data._armor_display - data._armor_target) < 0.05 then
                            data._armor_display = data._armor_target
                        end
                    end

                    local avg  = data._armor_display
                    local mult = math.clamp(avg / 100, 0, 1)
                    local mode = flags["Armorbar_Mode"]
                    local col1 = flags["Armor_High"].Color
                    local col2 = flags["Armor_Low"].Color

                    local barColor
                    if mode == "Static" then barColor = col1
                    elseif mode == "Dynamic" then barColor = col2:Lerp(col1, mult)
                    else barColor = rgb(255, 255, 255) end

                    local textColor
                    if mode == "Static" then textColor = flags["Armor_Text_Color"].Color
                    else textColor = col2:Lerp(col1, mult) end

                    local ab = objects["armorbar"]
                    if flags["Armorbar"] and objects[ "armorbar_holder" ].Parent == objects[ "holder" ] then
                        local sz = UDim2.new(1, -2, mult, -2)
                        local ps = UDim2.new(0, 1, 1 - mult, 1)
                        if ab.Size ~= sz then ab.Size = sz end
                        if ab.Position ~= ps then ab.Position = ps end
                        if ab.BackgroundColor3 ~= barColor then ab.BackgroundColor3 = barColor end

                        local armor_gradient = ensure_gradient(ab, "ArmorGradient")
                        if mode == "Gradient" then
                            if not armor_gradient.Enabled then armor_gradient.Enabled = true end
                            if armor_gradient.Rotation ~= 270 then armor_gradient.Rotation = 270 end
                            armor_gradient.Color    = rgbseq({
                                rgbkey(0, col2),
                                rgbkey(mult, col1:Lerp(col2, 1 - mult)),
                                rgbkey(1, col1),
                            })
                            if armor_gradient.Parent ~= ab then armor_gradient.Parent = ab end
                        else
                            if armor_gradient.Enabled then armor_gradient.Enabled = false end
                            if armor_gradient.Parent ~= nil then armor_gradient.Parent = nil end
                        end
                    end

                    local a_text = objects["armor_text"]
                    local new_text = math.floor(avg) > 9999 and "inf" or tostring(math.floor(avg))
                    if a_text.Text ~= new_text then a_text.Text = new_text end
                    if a_text.TextColor3 ~= textColor then a_text.TextColor3 = textColor end

                    if flags["Armorbar"] and objects[ "armorbar_holder" ].Parent == objects[ "holder" ] then
                        local ps = UDim2.new(1, 5, 1 - mult, 0)
                        if a_text.Position ~= ps then a_text.Position = ps end
                    else
                        local ps = UDim2.new(1, 5, 0, 0)
                        if a_text.Position ~= ps then a_text.Position = ps end
                    end
                end
            end
        end)

        esp.connection = esp_run.Stepped:Connect(function()
            if not flags["Enabled"] then
                return
            end

            local now = tick()
            if flags["Limit_ESP_FPS"] then
                local limit = flags["ESP_FPS_Value"] or 80
                if limit < 144 then
                    if now - _last_esp_tick < (1 / limit) then return end
                end
            end
            _last_esp_tick = now

            if _players_dirty then
                _cached_players = esp_players:GetPlayers()
                _players_dirty  = false
            end

            local char_stats    = RepSt:FindFirstChild("CharStats")
            local chars_folder  = workspace:FindFirstChild("Characters")

            for i = 1, #_cached_players do
                local player = _cached_players[i]
                local data   = esp[player.Name]

                if not data then continue end

                local rate = flags["ESP_Refresh_Rate"] and (1 / flags["ESP_Refresh_Rate"]) or _ESP_REFRESH_RATE
                if (now - (data._last_refresh or 0)) < rate then continue end
                data._last_refresh = now
                
                local character = data.info.character
                local humanoid  = data.info.humanoid

                if not (character and humanoid) then continue end

                local objects = data.objects
                if not objects then continue end

                local holder = objects["holder"]

                local rootpart = humanoid.RootPart
                if not rootpart then
                    if holder.Visible then holder.Visible = false end
                    continue
                end

                local box_size, box_pos, on_screen, distance = esp:box_solve(rootpart)
                on_screen = on_screen or false
                local targetFade = 0
                local force_hide = false
                
                if humanoid.Health <= 0 then
                    if flags["Smooth_Fade_Dead"] then
                        targetFade = 1
                    else
                        force_hide = true
                    end
                elseif flags["Max_Distance"] and distance > flags["Max_Distance"] then
                    if flags["Smooth_Fade_OOR"] then
                        targetFade = 1
                    else
                        force_hide = true
                    end
                end
                
                if force_hide then
                    on_screen = false
                    data._fadeAmount = 1 -- instantly hidden
                    if holder.Visible then holder.Visible = false end
                else
                    data._fadeAmount = data._fadeAmount or 0
                    local dt = math.clamp(now - (data._last_tick or now), 0, 0.1)
                    data._last_tick = now
                    data._fadeAmount = math.clamp(data._fadeAmount + (targetFade - data._fadeAmount) * dt * 8, 0, 1)
                    if math.abs(data._fadeAmount - targetFade) < 0.01 then data._fadeAmount = targetFade end

                    if data._fadeAmount >= 0.99 then
                        if holder.Visible then holder.Visible = false end
                        on_screen = false
                    else
                        if holder.Visible ~= on_screen then holder.Visible = on_screen end
                    end
                end
                
                if data._lastAppliedFade ~= data._fadeAmount then
                    data._lastAppliedFade = data._fadeAmount
                    for key, obj in pairs(data.objects) do
                        if obj:IsA("TextLabel") then
                            obj.TextTransparency = data._fadeAmount
                            obj.TextStrokeTransparency = data._fadeAmount
                        elseif obj:IsA("UIStroke") then
                            obj.Transparency = data._fadeAmount
                        elseif obj:IsA("Frame") then
                            if key == "healthbar" or key == "healthbar_holder" 
                            or key == "armorbar" or key == "armorbar_holder" 
                            or key == "reloadbar" or key == "reloadbar_holder"
                            then
                                obj.BackgroundTransparency = data._fadeAmount
                            elseif key == "corners" then
                                for _, c in ipairs(obj:GetChildren()) do
                                    c.BackgroundTransparency = data._fadeAmount
                                end
                            end
                        end
                    end
                end

                local skel_enabled = flags["Skeleton"]
                local skel_outline = flags["Skeleton_Outline"]
                
                if data.skeleton then
                    local segments = (skel_enabled and on_screen) and esp:get_boxy_skeleton(character) or {}
                    for i, sk in ipairs(data.skeleton) do
                        local pair = segments[i]
                        if pair then
                            local pos1, on1 = esp:get_screen_pos(pair[1])
                            local pos2, on2 = esp:get_screen_pos(pair[2])
                            if on1 or on2 then
                                sk.in_line.Visible = true
                                sk.in_line.From = Vector2.new(pos1.X, pos1.Y)
                                sk.in_line.To = Vector2.new(pos2.X, pos2.Y)
                                sk.in_line.Color = flags["Skeleton_Color"].Color
                                sk.in_line.Transparency = 1 - (data._fadeAmount or 0)
                                
                                if skel_outline then
                                    sk.out.Visible = true
                                    sk.out.From = Vector2.new(pos1.X, pos1.Y)
                                    sk.out.To = Vector2.new(pos2.X, pos2.Y)
                                    sk.out.Color = Color3.new(0, 0, 0)
                                    sk.out.Transparency = 1 - (data._fadeAmount or 0)
                                else
                                    sk.out.Visible = false
                                end
                            else
                                sk.in_line.Visible = false
                                sk.out.Visible = false
                            end
                        else
                            sk.in_line.Visible = false
                            sk.out.Visible = false
                        end
                    end
                end
                
                local headdot_enabled = flags["Headdot"]
                if data.headdot and data.headdot_out then
                    if headdot_enabled and on_screen then
                        local head = character:FindFirstChild("Head")
                        if head then
                            local head_pos, head_on = esp:get_screen_pos(head.Position)
                            if head_on then
                                local distance_to_head = (esp_camera.CFrame.Position - head.Position).Magnitude
                                local radius = (800 / distance_to_head) * (flags["Headdot_Size"] or 1) -- скейл
                                
                                data.headdot.Visible = true
                                data.headdot.Position = Vector2.new(head_pos.X, head_pos.Y)
                                data.headdot.Radius = radius
                                data.headdot.Color = flags["Headdot_Color"] and flags["Headdot_Color"].Color or Color3.new(1,1,1)
                                data.headdot.Transparency = 1 - (data._fadeAmount or 0)
                                
                                if flags["Headdot_Outline"] then
                                    data.headdot_out.Visible = true
                                    data.headdot_out.Position = Vector2.new(head_pos.X, head_pos.Y)
                                    data.headdot_out.Radius = radius
                                    data.headdot_out.Color = Color3.new(0,0,0)
                                    data.headdot_out.Transparency = 1 - (data._fadeAmount or 0)
                                else
                                    data.headdot_out.Visible = false
                                end
                            else
                                data.headdot.Visible = false
                                data.headdot_out.Visible = false
                            end
                        else
                            data.headdot.Visible = false
                            data.headdot_out.Visible = false
                        end
                    else
                        data.headdot.Visible = false
                        data.headdot_out.Visible = false
                    end
                end

                if not on_screen then continue end

                --статус
                local v_status     = get_player_status(player)
                local status_color
                if v_status == "Enemy" then
                    status_color = flags["Enemy_Color"].Color
                elseif v_status == "Friendly" then
                    status_color = flags["Friendly_Color"].Color
                end

                -- нейм
                objects["name"].TextColor3 = status_color or flags["Name_Color"].Color
                objects["box_color"].Color      = flags["Box_Color"].Color
                objects["distance"].TextColor3  = flags["Distance_Color"].Color

                local has_ff = flags["ForceField"] and character:FindFirstChildOfClass("ForceField") ~= nil
                if objects["ff_text"].Visible ~= has_ff then
                    objects["ff_text"].Visible = has_ff
                end
                if has_ff then
                    objects["ff_text"].TextColor3 = flags["ForceField_Color"].Color
                end

                -- $$$
                do
                    local stat_entry = char_stats and char_stats:FindFirstChild(player.Name)
                    local downed     = stat_entry and stat_entry:FindFirstChild("Downed")
                    local is_downed  = flags["Downed"] and downed ~= nil and downed.Value == true
                    if objects["downed_text"].Visible ~= is_downed then
                        objects["downed_text"].Visible = is_downed
                    end
                    if is_downed then
                        objects["downed_text"].TextColor3 = flags["Downed_Color"].Color
                    end
                end

                -- 
                do
                    local czt = objects["combat_zone_text"]
                    local in_zone = flags["CombatZone"] and getgenv().CurrentZones ~= nil and next(getgenv().CurrentZones) ~= nil
                    if czt.Visible ~= (flags["CombatZone"] and in_zone) then
                        czt.Visible = flags["CombatZone"] and in_zone
                    end
                    if flags["CombatZone"] and in_zone then
                        czt.TextColor3 = flags["CombatZone_Color"].Color
                    end
                end

                do
                    if not data._leaderstats then
                        data._leaderstats = player:FindFirstChild("leaderstats")
                    end
                    local level_stat = data._leaderstats and data._leaderstats:FindFirstChild("Level")
                    objects["level_text"].TextColor3 = flags["Level_Color"].Color
                    local show_level = flags["Level"] and level_stat ~= nil
                    if objects["level_text"].Visible ~= show_level then
                        objects["level_text"].Visible = show_level
                    end
                    if show_level then
                        local lvl_text = "L" .. tostring(level_stat.Value)
                        if objects["level_text"].Text ~= lvl_text then
                            objects["level_text"].Text = lvl_text
                        end
                    end
                end

                -- армор
                if data.armor_changed then
                    data.armor_changed()
                end

                -- с
                do
                    local stat_entry   = char_stats and char_stats:FindFirstChild(player.Name)
                    local crouching    = stat_entry and stat_entry:FindFirstChild("Crouching")
                    local is_crouching = flags["Crouching"] and crouching ~= nil and crouching.Value == true
                    local ct           = objects["crouch_text"]
                    if is_crouching then
                        if ct.Parent ~= holder then ct.Parent = holder end
                        if not ct.Visible then ct.Visible = true end
                    else
                        if ct.Parent ~= esp.cache then ct.Parent = esp.cache end
                        if ct.Visible then ct.Visible = false end
                    end
                end

                do
                    local wchar = chars_folder and chars_folder:FindFirstChild(player.Name)
                    local tool  = wchar and wchar:FindFirstChildOfClass("Tool")

                    local show_weapon = flags["Weapon"] and tool ~= nil
                    local wp = objects["weapon"]
                    if show_weapon then
                        if wp.Parent ~= holder then wp.Parent = holder end
                        local wname = "[" .. tool.Name:lower() .. "]"
                        if wp.Text ~= wname then wp.Text = wname end
                    else
                        if wp.Parent ~= esp.cache then wp.Parent = esp.cache end
                    end
                    do
                        local dist_label = objects["distance"]
                        local dist_h = (dist_label.Parent == holder and dist_label.TextBounds.Y > 0)
                            and (dist_label.TextBounds.Y + 2) or 0
                        local wp_y = 5 + dist_h
                        local wp_pos = dim2(0, 0, 1, wp_y)
                        if wp.Position ~= wp_pos then wp.Position = wp_pos end
                    end

                    local reloading_val = nil
                    if tool then
                        reloading_val = tool:FindFirstChild("Reloading")
                        if not reloading_val then
                            local tv = tool:FindFirstChild("Values")
                            reloading_val = tv and tv:FindFirstChild("Reloading")
                        end
                    end
                    local is_reloading = reloading_val ~= nil and reloading_val.Value == true

                    if flags["Reloadbar"] and is_reloading then
                        local tnow = tick()
                        if not data.reload_active then
                            data.reload_active    = true
                            data.reload_start     = tnow
                            data.reload_tool_name = tool.Name
                        end
                        local elapsed = tnow - data.reload_start
                        local known   = RELOAD_TIMES[data.reload_tool_name]
                                     or (data.reload_known and data.reload_known[data.reload_tool_name])
                        local rbh = objects["reloadbar_holder"]
                        local rt  = objects["reload_text"]
                        if rbh.Parent ~= holder then rbh.Parent = holder end
                        if rt.Parent  ~= holder then rt.Parent  = holder end
                        local rcol = flags["Reload_Color"].Color
                        objects["reloadbar"].BackgroundColor3 = rcol
                        rt.TextColor3 = rcol
                        if known and known >= 0.3 then
                            local remaining = math.clamp(known - elapsed, 0, known)
                            objects["reloadbar"].Size = UDim2.new(remaining / known, 0, 1, -2)
                            local rt_text = string.format("%.1fs", remaining)
                            if rt.Text ~= rt_text then rt.Text = rt_text end
                        else
                            objects["reloadbar"].Size = UDim2.new(1, 0, 1, -2)
                            local rt_text = string.format("%.1fs", elapsed)
                            if rt.Text ~= rt_text then rt.Text = rt_text end
                        end
                    else
                        if data.reload_active then
                            local measured   = tick() - data.reload_start
                            local known_time = RELOAD_TIMES[data.reload_tool_name]
                                           or (data.reload_known and data.reload_known[data.reload_tool_name])
                            if known_time and measured < (known_time - 0.15) then
                                data.reload_interrupted    = true
                                data.reload_interrupted_at = tick()
                            else
                                if measured >= 0.3 and not RELOAD_TIMES[data.reload_tool_name] then
                                    data.reload_known = data.reload_known or {}
                                    data.reload_known[data.reload_tool_name] = measured
                                end
                            end
                            data.reload_active = false
                        end
                        local rbh = objects["reloadbar_holder"]
                        local rt  = objects["reload_text"]
                        if data.reload_interrupted and (tick() - (data.reload_interrupted_at or 0)) < _RELOAD_STOP_DUR then
                            if rbh.Parent ~= holder then rbh.Parent = holder end
                            if rt.Parent  ~= holder then rt.Parent  = holder end
                            local stopcol = Color3.fromRGB(220, 50, 50)
                            objects["reloadbar"].BackgroundColor3 = stopcol
                            rt.TextColor3 = stopcol
                            objects["reloadbar"].Size = UDim2.new(0, 0, 1, -2)
                            if rt.Text ~= "stopped" then rt.Text = "stopped" end
                        else
                            if data.reload_interrupted then data.reload_interrupted = false end
                            if rbh.Parent ~= esp.cache then rbh.Parent = esp.cache end
                            if rt.Parent  ~= esp.cache then rt.Parent  = esp.cache end
                        end
                    end
                end

                do
                    local flag_y = 0
                    local at   = objects["armor_text"]
                    local mult = data._armor_mult or 0
                    if at and at.Visible and at.Parent == holder and mult > 0.8 then
                        flag_y = at.TextBounds.Y + _GAP
                    end
                    for fi = 1, #_FLAG_KEYS do
                        local label = objects[_FLAG_KEYS[fi]]
                        if label.Visible then
                            local new_pos = dim2(1, 6, 0, flag_y)
                            if label.Position ~= new_pos then
                                label.Position = new_pos
                            end
                            flag_y = flag_y + label.TextBounds.Y + _GAP
                        end
                    end
                end

                local new_pos  = dim_offset(box_pos.X,  box_pos.Y)
                local new_size = dim_offset(box_size.X, box_size.Y)
                if holder.Position ~= new_pos  then holder.Position = new_pos  end
                if holder.Size     ~= new_size then holder.Size     = new_size end

                if flags["ESPScaleText"] then
                    local text_size = math.floor(math.clamp(10 - (distance / 200) * 3, 7, 10))
                    local _TEXT_OBJS = { "name", "distance", "weapon", "health_text", "armor_text",
                                         "ff_text", "downed_text", "crouch_text", "level_text",
                                         "combat_zone_text", "reload_text" }
                    for _, key in ipairs(_TEXT_OBJS) do
                        local lbl = objects[key]
                        if lbl and lbl.TextSize ~= text_size then
                            lbl.TextSize = text_size
                        end
                    end
                end
                if flags["Health_Text"] and flags["Healthbar"]
                    and objects["health_text"].Parent == holder then
                    local bh   = box_size.Y
                    local hum  = data.info.humanoid
                    local mult = hum and math.clamp(
                        hum.MaxHealth > 0 and hum.Health / hum.MaxHealth or 0, 0, 1) or 1
                    local topY = math.max(0, (1 - mult) * bh)
                    objects["health_text"].Position = dim2(0, -7, 0, topY)
                end
                if flags["Armor_Text"] and objects["armor_text"].Visible
                    and objects["armor_text"].Parent == holder then
                    local bh   = box_size.Y
                    local mult = data._armor_mult or 1
                    if mult > 0.8 then
                        -- высокий армор — текст в колонке флагов (Y=0)
                        objects["armor_text"].AnchorPoint = vec2(0, 0)
                        objects["armor_text"].Position    = dim2(1, 6, 0, 0)
                    else
                        -- низкий армор — следует за баром
                        local topY = math.max(0, (1 - mult) * bh)
                        objects["armor_text"].AnchorPoint = vec2(0, 0)
                        objects["armor_text"].Position    = dim2(1, 6, 0, topY)
                    end
                end

                local dist_label = objects["distance"]
                local dist_text  = tostring(math.round(distance)) .. "st"
                if dist_label.Text ~= dist_text then
                    dist_label.Text = dist_text
                end
            end
        end)

        function esp:unload()
            for _, player in esp_players:GetPlayers() do
                esp:remove_object(player)
            end

            esp.connection:Disconnect()
            esp.player_added:Disconnect()
            esp.player_removed:Disconnect()

            esp.cache:Destroy()
            esp.screengui:Destroy()

            esp = nil
        end
end

if flags["Enabled"] then
    for _,v in esp_players:GetPlayers() do
        if v ~= esp_players.LocalPlayer then
            esp:create_object(v)
        end
    end
end

esp.player_added = esp_players.PlayerAdded:Connect(function(v)
    if flags["Enabled"] then
        esp:create_object(v)
        esp.refresh_elements()
    end
end)

esp.player_removed = esp_players.PlayerRemoving:Connect(function(v)
    esp:remove_object(v)
end)

if flags["Enabled"] then
    esp.refresh_elements()
end

local safe_flags = {
    SafeEnabled = false,
    RegEnabled  = false,
    ShowBox     = true,
    ShowName    = true,
    ShowDist    = true,
    ShowBroken  = true,
    NormalColor = { Color = rgb(255, 255, 255) },
    BrokenColor = { Color = rgb(255, 0, 0) },
    NameColor   = { Color = rgb(255, 255, 255) },
    DistColor   = { Color = rgb(255, 255, 255) },
    MaxDist     = 500,
}

;(function() 
local CombatSection = CombatPage:Section({Name = "Combat", Side = "Left"})
local BulletSection  = CombatPage:Section({Name = "Bullet Tracers", Side = "Right"})

local AimbotSection = LegitPage:Section({Name = "Aimbot", Side = "Right"})

    
    

local Settings = {
    Aimbot = {
        Enabled = false,
        Active = false,
        SelectedMethod = "Mouse",
        TargetParts = {"Head"},
        DownedCheck = false,
        DeadCheck   = true,
        FFCheck     = true,
        SwitchDelay = 1.25,
        MaxDistance = 500,
        HitChance   = 45,
        FOVColor    = Color3.fromRGB(255, 0, 0),

        Methods = {
            Mouse = {
                SmoothX = 5, SmoothY = 5, FOV = 40, FOVVis = false,
                PredictX = 0, PredictY = 0, AutoPred = false, VisCheck = true,
                Sort = "distance", Sticky = false, Easing = "linear"
            },
            Camera = {
                SmoothX = 50, SmoothY = 50, FOV = 40, FOVVis = false,
                PredictX = 0, PredictY = 0, AutoPred = false, VisCheck = true,
                Sort = "distance", Sticky = false, Easing = "linear"
            }
        }
    }
}

local function SyncAimbotUI(methodName)
    local data = Settings.Aimbot.Methods[methodName]
    local cf = Library.ConfigFlags
    pcall(function()
        if cf["aim_sx"]    then cf["aim_sx"](data.SmoothX) end
        if cf["aim_sy"]    then cf["aim_sy"](data.SmoothY) end
        if cf["aim_fov"]   then cf["aim_fov"](data.FOV) end
        if cf["aim_fvis"]  then cf["aim_fvis"](data.FOVVis) end
        if cf["aim_predx"] then cf["aim_predx"](data.PredictX) end
        if cf["aim_predy"] then cf["aim_predy"](data.PredictY) end
        if cf["aim_apred"] then cf["aim_apred"](data.AutoPred) end
        if cf["aim_vis"]   then cf["aim_vis"](data.VisCheck) end
        if cf["aim_sort"]  then cf["aim_sort"](data.Sort) end
        if cf["aim_sticky"] then cf["aim_sticky"](data.Sticky) end
        if cf["aim_ease"]  then cf["aim_ease"](data.Easing) end
    end)
end

local function getPing() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000 end

local _physMod = nil
task.spawn(function()
    task.wait(3)
    if not getgc then return end
    for _, v in next, getgc(true) do
        if type(v) == "table" and type(rawget(v, "trajectory")) == "function" and type(rawget(v, "spring")) == "function" then
            _physMod = v
            break
        end
    end
end)

local function getBulletConfig()
    local char = LP.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return nil end
    local cfgMod = tool:FindFirstChild("Config") or tool:FindFirstChild("BulletConfig")
    if not cfgMod then return nil end
    local ok, cfg = pcall(require, cfgMod)
    if ok and type(cfg) == "table" then return cfg end
    return nil
end

local function getBulletSpeed()
    local cfg = getBulletConfig()
    if cfg and cfg.BulletSettings and cfg.BulletSettings.Velocity then
        return cfg.BulletSettings.Velocity * 1.5
    end
    return 400  -- fallback
end

local function getBulletAccelY()
    local cfg = getBulletConfig()
    if cfg and cfg.BulletSettings and cfg.BulletSettings.Acceleration then
        local acc = cfg.BulletSettings.Acceleration
        if typeof(acc) == "Vector3" then return acc.Y end
    end
    return -workspace.Gravity * 0.5  -- fallback
end

local function computePredictedPos(targetPart)
    local myPos   = Cam.CFrame.Position
    local tgtPos  = targetPart.Position
    local tgtVel  = targetPart.Velocity
    local ping    = getPing()
    local bSpeed  = getBulletSpeed()
    local accY    = getBulletAccelY()

    local startPos = tgtPos + tgtVel * ping

    if _physMod and type(_physMod.trajectory) == "function" then
        local ok, aimDir, tof = pcall(
            _physMod.trajectory,
            myPos.X, myPos.Y, myPos.Z,
            startPos.X, startPos.Y, startPos.Z,
            tgtVel.X, tgtVel.Y, tgtVel.Z,
            bSpeed
        )
        if ok and aimDir and typeof(aimDir) == "Vector3" and tof and tof == tof then
            local dropY = 0.5 * math.abs(accY) * (tof * tof)
            return myPos + aimDir.Unit * 1000 + Vector3.new(0, dropY, 0)
        end
    end
    local predicted = startPos
    local t = (startPos - myPos).Magnitude / bSpeed
    for _ = 1, 4 do
        predicted = startPos + tgtVel * t
        t = (predicted - myPos).Magnitude / bSpeed
    end
    local dropY = 0.5 * math.abs(accY) * (t * t)
    return predicted + Vector3.new(0, dropY, 0)
end

local function getTarget(cfg, radius)
    local results = {}
    local mousePos = UIS:GetMouseLocation()
    
    for _, plr in next, Plrs:GetPlayers() do
        if plr == LP or not plr.Character then continue end
        local char = plr.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        if Settings.Aimbot.DeadCheck and hum.Health <= 0 then continue end

        if Settings.Aimbot.FFCheck and char:FindFirstChildOfClass("ForceField") then continue end

                if Settings.Aimbot.DownedCheck then
            local char_stats = RepSt:FindFirstChild("CharStats")
            local p_stats = char_stats and char_stats:FindFirstChild(plr.Name)
            local downed = p_stats and p_stats:FindFirstChild("Downed")
            if downed and downed.Value == true then continue end
        end

        local targetParts = Settings.Aimbot.TargetParts
        local bestPartForPlr = nil
        local bestPartFov = radius

        for _, partName in pairs(targetParts) do
            local p = char:FindFirstChild(partName)
            if p then
                if cfg.VisCheck then
                    local ray = Ray.new(Cam.CFrame.Position, (p.Position - Cam.CFrame.Position).Unit * 1000)
                    if workspace:FindPartOnRayWithIgnoreList(ray, {LP.Character, char}) then continue end
                end

                local screenPos, onScreen = Cam:WorldToViewportPoint(p.Position)
                if onScreen then
                    local fovDist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if fovDist < bestPartFov then
                        bestPartForPlr = p
                        bestPartFov = fovDist
                    end
                end
            end
        end

        if bestPartForPlr then
            local worldDist = (LP.Character.HumanoidRootPart.Position - bestPartForPlr.Position).Magnitude

            if Settings.Aimbot.MaxDistance > 0 and worldDist > Settings.Aimbot.MaxDistance then continue end
            table.insert(results, {
                plr = plr,
                part = bestPartForPlr,
                fovDist = bestPartFov,
                worldDist = worldDist,
                hp = hum.Health
            })
        end
    end

    if #results == 0 then return nil, nil end
    
    table.sort(results, function(a, b)
        if cfg.Sort == "fov" then return a.fovDist < b.fovDist
        elseif cfg.Sort == "health" then return a.hp < b.hp
        else return a.worldDist < b.worldDist end
    end)
    
    return results[1].plr, results[1].part
end

local lockedPlayer, lockedPart = nil, nil
local _aimbot_last_switch = 0
local easingF = {
    linear = function(t) return t end,
    easein = function(t) return t * t end,
    easeout = function(t) return 1 - (1 - t) * (1 - t) end,
    smoothstep = function(t) return t * t * (3 - 2 * t) end
}

local AimCircle = nil  -- 

local function ensureAimCircle()
    if AimCircle then return end
    AimCircle = Drawing.new("Circle")
    AimCircle.Thickness = 1; AimCircle.NumSides = 30; AimCircle.Color = Color3.new(1,0,0)
    AimCircle.Visible = false
end

RS.Heartbeat:Connect(function()
    if not Settings.Aimbot.Enabled then
        if AimCircle then AimCircle.Visible = false end
        return
    end
    ensureAimCircle()
    local mouseLoc = UIS:GetMouseLocation()
    local cfg = Settings.Aimbot.Methods[Settings.Aimbot.SelectedMethod]
    
    AimCircle.Visible = Settings.Aimbot.Enabled and cfg.FOVVis
    AimCircle.Color   = Settings.Aimbot.FOVColor
    AimCircle.Position = mouseLoc; AimCircle.Radius = cfg.FOV

    if not (Settings.Aimbot.Enabled and Settings.Aimbot.Active) then lockedPlayer = nil; return end
    
    if not cfg.Sticky or not lockedPlayer then
        local newPlr, newPart = getTarget(cfg, cfg.FOV)

        if newPlr ~= lockedPlayer then
            local now_t = tick()
            if Settings.Aimbot.SwitchDelay > 0 and lockedPlayer ~= nil
                and (now_t - _aimbot_last_switch) < Settings.Aimbot.SwitchDelay then
                local char = lockedPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if not (char and hum and hum.Health > 0) then
                    lockedPlayer, lockedPart = newPlr, newPart
                    _aimbot_last_switch = now_t
                end
            else
                lockedPlayer, lockedPart = newPlr, newPart
                if newPlr ~= nil then _aimbot_last_switch = tick() end
            end
        else
            lockedPart = newPart
        end
    end
    
    if lockedPlayer and lockedPart then
        local pos = lockedPart.Position
        if cfg.AutoPred then
            pos = computePredictedPos(lockedPart)
        else
            local vel = lockedPart.Velocity

            local px = cfg.PredictX or 0
            local py = cfg.PredictY or 0
            if px ~= 0 or py ~= 0 then
                local flatVel = Vector3.new(vel.X, 0, vel.Z)
                local flatUnit = flatVel.Magnitude > 0.01 and flatVel.Unit or Vector3.new(0, 0, 0)
                pos = pos + flatUnit * px + Vector3.new(0, vel.Y > 0 and py or -py, 0)
            end
        end
        
        if Settings.Aimbot.SelectedMethod == "Mouse" then
            local screenPos, onScreen = Cam:WorldToViewportPoint(pos)
            if onScreen then
                local delta = Vector2.new(screenPos.X, screenPos.Y) - mouseLoc
                local factor = easingF[cfg.Easing](math.clamp(delta.Magnitude / cfg.FOV, 0, 1))
                
                local sx = math.clamp(cfg.SmoothX / 100, 0.01, 1)
                local sy = math.clamp(cfg.SmoothY / 100, 0.01, 1)
                if mousemoverel then mousemoverel(delta.X * sx * factor, delta.Y * sy * factor) end
            end
        else 
            local targetCF = CFrame.new(Cam.CFrame.Position, pos)
            local curP, curY = Cam.CFrame:ToOrientation()
            local tgtP, tgtY = targetCF:ToOrientation()
            Cam.CFrame = CFrame.new(Cam.CFrame.Position) * CFrame.fromOrientation(curP+(tgtP-curP)*math.pow(1-(cfg.SmoothY/105),3), curY+(tgtY-curY)*math.pow(1-(cfg.SmoothX/105),3), 0)
        end
    end
end)

AimbotSection:Toggle({
    Name = "Enabled",
    Flag = "ab_en",
    Callback = function(v) Settings.Aimbot.Enabled = v end
}):Keybind({
    Flag = "ab_kb",
    Default = Enum.UserInputType.MouseButton2,
    Mode = "Hold",
    Callback = function(v) Settings.Aimbot.Active = v end
})

AimbotSection:Dropdown({
    Name = "Target Parts",
    Options = {"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
    Default = {"Head"},
    Multi = true,
    Flag = "ab_parts",
    Callback = function(v) Settings.Aimbot.TargetParts = v end
})

AimbotSection:Dropdown({
    Name = "Method to Edit",
    Options = {"Mouse", "Camera"},
    Default = "Mouse",
    Flag = "method_selector",
    Callback = function(v)
        Settings.Aimbot.SelectedMethod = v
        SyncAimbotUI(v)
    end
})

AimbotSection:Slider({ Name = "Smooth X", Min = 1, Max = 100, Default = 5, Flag = "aim_sx", Callback = function(v) Settings.Aimbot.Methods[Settings.Aimbot.SelectedMethod].SmoothX = v end })
AimbotSection:Slider({ Name = "Smooth Y", Min = 1, Max = 100, Default = 5, Flag = "aim_sy", Callback = function(v) Settings.Aimbot.Methods[Settings.Aimbot.SelectedMethod].SmoothY = v end })
AimbotSection:Toggle({ Name = "Show FOV", Flag = "aim_fvis", Default = false, Callback = function(v) Settings.Aimbot.Methods[Settings.Aimbot.SelectedMethod].FOVVis = v end }):Colorpicker({
    Name     = "FOV Color",
    Flag     = "aim_fov_color",
    Color    = Color3.fromRGB(255, 0, 0),
    Alpha    = 0,
    Callback = function(color)
        Settings.Aimbot.FOVColor = color
        if AimCircle then AimCircle.Color = color end
    end,
})
AimbotSection:Slider({ Name = "FOV", Min = 1, Max = 600, Default = 40, Decimal = 1, Suffix = "°", Flag = "aim_fov", Callback = function(v) Settings.Aimbot.Methods[Settings.Aimbot.SelectedMethod].FOV = v end })

AimbotSection:Slider({
    Name    = "Switch Delay",
    Flag    = "aim_switch_delay",
    Min     = 0,
    Max     = 3000,
    Default = 1250,
    Decimal = 1,
    Suffix  = "ms",
    Callback = function(v) Settings.Aimbot.SwitchDelay = v / 1000 end,
})

AimbotSection:Slider({
    Name    = "Max Distance",
    Flag    = "aim_max_dist",
    Min     = 0,
    Max     = 4000,
    Default = 500,
    Decimal = 1,
    Suffix  = "m",
    Callback = function(v) Settings.Aimbot.MaxDistance = v end,
})

AimbotSection:Slider({
    Name     = "Predict X",
    Flag     = "aim_predx",
    Min      = 0,
    Max      = 50,
    Default  = 0,
    Decimal  = 0.1,
    Suffix   = "st",
    Callback = function(v) Settings.Aimbot.Methods[Settings.Aimbot.SelectedMethod].PredictX = v end,
})

AimbotSection:Slider({
    Name     = "Predict Y",
    Flag     = "aim_predy",
    Min      = 0,
    Max      = 50,
    Default  = 0,
    Decimal  = 0.1,
    Suffix   = "st",
    Callback = function(v) Settings.Aimbot.Methods[Settings.Aimbot.SelectedMethod].PredictY = v end,
})

AimbotSection:Toggle({ Name = "Auto Prediction", Flag = "aim_apred", Callback = function(v) Settings.Aimbot.Methods[Settings.Aimbot.SelectedMethod].AutoPred = v end })
AimbotSection:Toggle({ Name = "Visible Check", Flag = "aim_vis", Callback = function(v) Settings.Aimbot.Methods[Settings.Aimbot.SelectedMethod].VisCheck = v end })
AimbotSection:Toggle({ Name = "Downed Check", Flag = "aim_downed", Callback = function(v) Settings.Aimbot.DownedCheck = v end })
AimbotSection:Toggle({ Name = "Dead Check", Flag = "aim_dead", Default = false, Callback = function(v) Settings.Aimbot.DeadCheck = v end })
AimbotSection:Toggle({ Name = "Force Shield Check", Flag = "aim_ffcheck", Default = false, Callback = function(v) Settings.Aimbot.FFCheck = v end })
AimbotSection:Dropdown({ Name = "Sort Mode", Options = {"distance", "fov", "health"}, Default = "distance", Flag = "aim_sort", Callback = function(v) Settings.Aimbot.Methods[Settings.Aimbot.SelectedMethod].Sort = v end })
AimbotSection:Dropdown({ Name = "Easing", Options = {"linear", "easein", "easeout", "smoothstep"}, Default = "linear", Flag = "aim_ease", Callback = function(v) Settings.Aimbot.Methods[Settings.Aimbot.SelectedMethod].Easing = v end })
AimbotSection:Toggle({ Name = "Sticky Aim", Flag = "aim_sticky", Callback = function(v) Settings.Aimbot.Methods[Settings.Aimbot.SelectedMethod].Sticky = v end })

SyncAimbotUI("Mouse")


local NoScopeGlint = {
    Enabled = false,
    Conn    = nil,
    Hidden  = {},   -- { [SpotLight] = originalBrightness }
}

local function nsg_hide_glints(char)
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    for _, obj in next, tool:GetDescendants() do
        if obj:IsA("SpotLight") or obj:IsA("SurfaceLight") or obj:IsA("PointLight") then
            if NoScopeGlint.Hidden[obj] == nil then
                NoScopeGlint.Hidden[obj] = obj.Enabled
                obj.Enabled = false
            end
        end
    end
end

local function nsg_restore_glints()
    for obj, wasEnabled in next, NoScopeGlint.Hidden do
        pcall(function() obj.Enabled = wasEnabled end)
    end
    NoScopeGlint.Hidden = {}
end

local function nsg_enable()
    if NoScopeGlint.Enabled then return end
    NoScopeGlint.Enabled = true
    NoScopeGlint.Hidden  = {}

    local function applyToChar(char)
        if not char then return end
        nsg_hide_glints(char)

        char.ChildAdded:Connect(function(child)
            if not NoScopeGlint.Enabled then return end
            if child:IsA("Tool") then
                task.wait(0.1)
                nsg_hide_glints(char)
            end
        end)

        char.DescendantAdded:Connect(function(obj)
            if not NoScopeGlint.Enabled then return end
            if obj:IsA("SpotLight") or obj:IsA("SurfaceLight") or obj:IsA("PointLight") then
                task.wait()
                if NoScopeGlint.Hidden[obj] == nil then
                    NoScopeGlint.Hidden[obj] = obj.Enabled
                    obj.Enabled = false
                end
            end
        end)
    end

    applyToChar(LP.Character)

    NoScopeGlint.Conn = LP.CharacterAdded:Connect(function(char)
        if not NoScopeGlint.Enabled then return end
        NoScopeGlint.Hidden = {}
        task.wait(1)
        applyToChar(char)
    end)
end

local function nsg_disable()
    if not NoScopeGlint.Enabled then return end
    NoScopeGlint.Enabled = false
    if NoScopeGlint.Conn then
        NoScopeGlint.Conn:Disconnect()
        NoScopeGlint.Conn = nil
    end
    nsg_restore_glints()
end

--

local chams_flags = {
    MasterEnabled = false,
    Enabled      = false,
    Color        = Color3.fromRGB(255, 255, 255),
    TargetColor  = Color3.fromRGB(255, 255, 255),
    Alpha        = 0.3,
    TargetAlpha  = 0.3,
    LerpSpeed    = 0.01,
    GlowEnabled  = false,
    GlowSize     = 1.75,
    ShadingEnabled  = false,
    InlineShade  = "Default",
    OutlineShade = "Default",
}
local chams_cache = {}

-- второй слой 
local chams2_flags = {
    MasterEnabled = false,
    Enabled      = false,
    Color        = Color3.fromRGB(255, 165, 0),
    TargetColor  = Color3.fromRGB(255, 165, 0),
    Alpha        = 0.3,
    TargetAlpha  = 0.3,
    LerpSpeed    = 0.01,
    GlowEnabled  = false,
    GlowSize     = 1.75,
    ShadingEnabled  = false,
    InlineShade  = "Default",
    OutlineShade = "Default",
}
local chams2_cache = {}

local function chams_get_color()
    return chams_flags.Color
end

local function chams_apply_color(plrName)
    local entry = chams_cache[plrName]
    if not entry or not entry.folder or not entry.folder.Parent then return end
    local col = chams_get_color()
    for _, adornment in ipairs(entry.folder:GetChildren()) do
        if adornment:IsA("BoxHandleAdornment") then
            adornment.Color3       = col
            adornment.Transparency = chams_flags.Alpha
        end
    end
end

local function chams_remove_player(plrName)
    local entry = chams_cache[plrName]
    if not entry then return end
    if entry.folder and entry.folder.Parent then entry.folder:Destroy() end
    for _, c in ipairs(entry.conns or {}) do pcall(function() c:Disconnect() end) end
    chams_cache[plrName] = nil
end

local function chams2_remove_player(plrName)
    local entry = chams2_cache[plrName]
    if not entry then return end
    if entry.folder and entry.folder.Parent then entry.folder:Destroy() end
    for _, c in ipairs(entry.conns or {}) do pcall(function() c:Disconnect() end) end
    chams2_cache[plrName] = nil
end

local chams2_build_player  -- forward declaration

local function chams_build_player(plr)
    if not plr or plr == LP then return end
    local plrName = plr.Name
    chams_remove_player(plrName)


    local char = plr.Character
    if not char then return end


    local ok, hum = pcall(function()
        return char:WaitForChild("HumanoidRootPart", 8) and char:WaitForChild("Humanoid", 8)
    end)
    if not ok or not hum then return end

    task.wait(0.1)

    -- Перепроверяем: персонаж мог умереть или смениться пока мы ждали
    if plr.Character ~= char then return end
    char = plr.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end

    local folder = Instance.new("Folder")
    folder.Name   = plrName .. "_CHAMS"
    folder.Parent = game:GetService("CoreGui")
    local plrEntry = { folder = folder, conns = {}, inners = {}, outers = {} }
    chams_cache[plrName] = plrEntry
    local col = chams_get_color()
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local a_in        = Instance.new("BoxHandleAdornment")
            a_in.Name         = plrName .. "_in"
            a_in.Parent       = folder
            a_in.Adornee      = part
            a_in.AlwaysOnTop  = true
            a_in.ZIndex       = 1
            a_in.Size         = part.Size + Vector3.new(-0.1, -0.1, -0.1)
            a_in.Color3       = col
            a_in.Transparency = chams_flags.Alpha
            table.insert(plrEntry.inners, a_in)

            local a_out       = Instance.new("BoxHandleAdornment")
            a_out.Name        = plrName .. "_out"
            a_out.Parent      = folder
            a_out.Adornee     = part
            a_out.AlwaysOnTop = chams_flags.GlowEnabled
            a_out.ZIndex      = -1
            a_out.Size        = part.Size + Vector3.new(0.1, 0.1, 0.1)
            a_out.Color3      = col
            a_out.Transparency = chams_flags.GlowEnabled
                and (chams_flags.Alpha / chams_flags.GlowSize)
                or chams_flags.Alpha
            table.insert(plrEntry.outers, a_out)
        end
    end
    
end

chams2_build_player = function(plr)
    if not plr or plr == LP then return end
    local plrName = plr.Name
    chams2_remove_player(plrName)

    local char = plr.Character
    if not char then return end

    local ok, hum = pcall(function()
        return char:WaitForChild("HumanoidRootPart", 8) and char:WaitForChild("Humanoid", 8)
    end)
    if not ok or not hum then return end
    task.wait(0.1)

    if plr.Character ~= char then return end
    char = plr.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end

    local folder = Instance.new("Folder")
    folder.Name   = plrName .. "_CHAMS2"
    folder.Parent = game:GetService("CoreGui")
    local plrEntry = { folder = folder, conns = {}, inners = {}, outers = {} }
    chams2_cache[plrName] = plrEntry
    local col = chams2_flags.Color
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local a_in        = Instance.new("BoxHandleAdornment")
            a_in.Name         = plrName .. "_in"
            a_in.Parent       = folder
            a_in.Adornee      = part
            a_in.AlwaysOnTop  = false
            a_in.ZIndex       = 1
            a_in.Size         = part.Size + Vector3.new(0, 0, 0)
            a_in.Color3       = col
            a_in.Transparency = chams2_flags.Alpha
            table.insert(plrEntry.inners, a_in)

            local a_out       = Instance.new("BoxHandleAdornment")
            a_out.Name        = plrName .. "_out"
            a_out.Parent      = folder
            a_out.Adornee     = part
            a_out.AlwaysOnTop = false
            a_out.ZIndex      = 1
            a_out.Size        = part.Size + Vector3.new(0.2, 0.2, 0.2)
            a_out.Color3      = col
            a_out.Transparency = chams2_flags.GlowEnabled
                and (chams2_flags.Alpha / chams2_flags.GlowSize)
                or chams2_flags.Alpha
            table.insert(plrEntry.outers, a_out)
        end
    end
    local conn = plr.CharacterAdded:Connect(function(newChar)
        task.spawn(function()
            local rok = pcall(function()
                newChar:WaitForChild("HumanoidRootPart", 8)
                newChar:WaitForChild("Humanoid", 8)
            end)
            if not rok then return end
            task.wait(0.15)
            if chams2_flags.Enabled then chams2_build_player(plr) end
        end)
    end)
    table.insert(plrEntry.conns, conn)
end

local function chams_start()
    for _, plr in ipairs(esp_players:GetPlayers()) do
        if plr ~= LP then task.spawn(chams_build_player, plr) end
    end
end

local function chams_stop()
    for plrName in pairs(chams_cache) do chams_remove_player(plrName) end
end

local function chams2_start()
    for _, plr in ipairs(esp_players:GetPlayers()) do
        if plr ~= LP then task.spawn(chams2_build_player, plr) end
    end
end

local function chams2_stop()
    for plrName in pairs(chams2_cache) do chams2_remove_player(plrName) end
end


local hchams_flags = {
    Enabled      = false,
    FillColor    = Color3.fromRGB(100, 255, 100),
    FillTarget   = Color3.fromRGB(100, 255, 100),
    OutlineColor = Color3.fromRGB(255, 255, 255),
    OutlineTarget= Color3.fromRGB(255, 255, 255),
    FillAlpha    = 0.5,
    FillTargetAlpha = 0.5,
    OutlineAlpha = 0,
    OutlineTargetAlpha = 0,
    LerpSpeed    = 0.01,
}
local hchams_cache = {}

local hchams2_flags = {
    Enabled      = false,
    FillColor    = Color3.fromRGB(255, 100, 100),
    FillTarget   = Color3.fromRGB(255, 100, 100),
    OutlineColor = Color3.fromRGB(255, 255, 255),
    OutlineTarget= Color3.fromRGB(255, 255, 255),
    FillAlpha    = 0.5,
    FillTargetAlpha = 0.5,
    OutlineAlpha = 0,
    OutlineTargetAlpha = 0,
    LerpSpeed    = 0.01,
}
local hchams2_cache = {}

local function hchams_remove_player(plrName)
    local entry = hchams_cache[plrName]
    if entry then
        if entry.hl then entry.hl:Destroy() end
        if entry.conn then entry.conn:Disconnect() end
        hchams_cache[plrName] = nil
    end
    local entry2 = hchams2_cache[plrName]
    if entry2 then
        if entry2.hl then entry2.hl:Destroy() end
        if entry2.conn then entry2.conn:Disconnect() end
        hchams2_cache[plrName] = nil
    end
end

local function hchams_build_player(plr)
    if not plr or plr == LP then return end
    local plrName = plr.Name
    
    local entry = hchams_cache[plrName]
    if entry then
        if entry.hl then entry.hl:Destroy() end
        if entry.conn then entry.conn:Disconnect() end
        hchams_cache[plrName] = nil
    end

    local char = plr.Character
    if not char then return end

    local hl = Instance.new("Highlight")
    hl.Name = "HChams_" .. plrName
    hl.Adornee = char
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillColor = hchams_flags.FillColor
    hl.FillTransparency = hchams_flags.FillAlpha
    hl.OutlineColor = hchams_flags.OutlineColor
    hl.OutlineTransparency = hchams_flags.OutlineAlpha
    hl.Parent = esp.cache
    
    local new_entry = { hl = hl, conn = nil }
    hchams_cache[plrName] = new_entry
    
    new_entry.conn = plr.CharacterAdded:Connect(function(newChar)
        task.wait(0.2)
        if hchams_flags.Enabled then hchams_build_player(plr) end
    end)
end

local function hchams2_build_player(plr)
    if not plr or plr == LP then return end
    local plrName = plr.Name
    
    local entry = hchams2_cache[plrName]
    if entry then
        if entry.hl then entry.hl:Destroy() end
        if entry.conn then entry.conn:Disconnect() end
        hchams2_cache[plrName] = nil
    end

    local char = plr.Character
    if not char then return end

    local hl = Instance.new("Highlight")
    hl.Name = "HChams2_" .. plrName
    hl.Adornee = char
    hl.DepthMode = Enum.HighlightDepthMode.Occluded
    hl.FillColor = hchams2_flags.FillColor
    hl.FillTransparency = hchams2_flags.FillAlpha
    hl.OutlineColor = hchams2_flags.OutlineColor
    hl.OutlineTransparency = hchams2_flags.OutlineAlpha
    hl.Parent = esp.cache
    
    local new_entry = { hl = hl, conn = nil }
    hchams2_cache[plrName] = new_entry
    
    new_entry.conn = plr.CharacterAdded:Connect(function(newChar)
        task.wait(0.2)
        if hchams2_flags.Enabled then hchams2_build_player(plr) end
    end)
end

local function hchams_start()
    for _, plr in ipairs(esp_players:GetPlayers()) do
        if plr ~= LP then task.spawn(hchams_build_player, plr) end
    end
end
local function hchams_stop()
    for plrName in pairs(hchams_cache) do
        local entry = hchams_cache[plrName]
        if entry.hl then entry.hl:Destroy() end
        if entry.conn then entry.conn:Disconnect() end
        hchams_cache[plrName] = nil
    end
end

local function hchams2_start()
    for _, plr in ipairs(esp_players:GetPlayers()) do
        if plr ~= LP then task.spawn(hchams2_build_player, plr) end
    end
end
local function hchams2_stop()
    for plrName in pairs(hchams2_cache) do
        local entry = hchams2_cache[plrName]
        if entry.hl then entry.hl:Destroy() end
        if entry.conn then entry.conn:Disconnect() end
        hchams2_cache[plrName] = nil
    end
end

local hchams_render_conn = nil
local function calc_chams_fade(plrName, dt, entry)
    local targetFade = 0
    local should_fade_oor = flags["Smooth_Fade_OOR"]
    local should_fade_dead = flags["Smooth_Fade_Dead"]
    
    local lp_hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    
        if should_fade_oor or should_fade_dead then
        local p = esp_players:FindFirstChild(plrName)
        if p and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if should_fade_dead and hum and hum.Health <= 0 then
                targetFade = 1
            elseif should_fade_oor and hrp and lp_hrp and flags["Max_Distance"] then
                local dist = (hrp.Position - lp_hrp.Position).Magnitude
                if dist > flags["Max_Distance"] then
                    targetFade = 1
                end
            end
        else
            targetFade = 1
        end
    end
    
    entry.fadeAmount = entry.fadeAmount or 0
    if should_fade_oor or should_fade_dead then
        entry.fadeAmount = math.clamp(entry.fadeAmount + (targetFade - entry.fadeAmount) * dt * 5, 0, 1)
        if math.abs(entry.fadeAmount - targetFade) < 0.01 then entry.fadeAmount = targetFade end
    else
        entry.fadeAmount = 0
    end
    
    return entry.fadeAmount
end

local function hchams_start_render()
    if hchams_render_conn then return end
    hchams_render_conn = esp_run.RenderStepped:Connect(function(dt)
        if not chams_flags.MasterEnabled then
            for _, entry in pairs(hchams_cache) do if entry.hl then entry.hl.Enabled = false end end
            for _, entry in pairs(hchams2_cache) do if entry.hl then entry.hl.Enabled = false end end
            return
        end
        
        if hchams_flags.Enabled then
            local t = math.clamp(dt / hchams_flags.LerpSpeed, 0, 1)
            hchams_flags.FillColor = hchams_flags.FillColor:Lerp(hchams_flags.FillTarget, t)
            hchams_flags.OutlineColor = hchams_flags.OutlineColor:Lerp(hchams_flags.OutlineTarget, t)
            hchams_flags.FillAlpha = hchams_flags.FillAlpha + (hchams_flags.FillTargetAlpha - hchams_flags.FillAlpha) * t
            hchams_flags.OutlineAlpha = hchams_flags.OutlineAlpha + (hchams_flags.OutlineTargetAlpha - hchams_flags.OutlineAlpha) * t
            
            for plrName, entry in pairs(hchams_cache) do
                if entry.hl then
                    local fade = calc_chams_fade(plrName, dt, entry)
                    if fade >= 0.99 then
                        entry.hl.Enabled = false
                    else
                        entry.hl.Enabled = true
                        entry.hl.FillColor = hchams_flags.FillColor
                        entry.hl.FillTransparency = hchams_flags.FillAlpha + fade * (1 - hchams_flags.FillAlpha)
                        entry.hl.OutlineColor = hchams_flags.OutlineColor
                        entry.hl.OutlineTransparency = hchams_flags.OutlineAlpha + fade * (1 - hchams_flags.OutlineAlpha)
                    end
                end
            end
        else
            for _, entry in pairs(hchams_cache) do if entry.hl then entry.hl.Enabled = false end end
        end

        if hchams2_flags.Enabled then
            local t2 = math.clamp(dt / hchams2_flags.LerpSpeed, 0, 1)
            hchams2_flags.FillColor = hchams2_flags.FillColor:Lerp(hchams2_flags.FillTarget, t2)
            hchams2_flags.OutlineColor = hchams2_flags.OutlineColor:Lerp(hchams2_flags.OutlineTarget, t2)
            hchams2_flags.FillAlpha = hchams2_flags.FillAlpha + (hchams2_flags.FillTargetAlpha - hchams2_flags.FillAlpha) * t2
            hchams2_flags.OutlineAlpha = hchams2_flags.OutlineAlpha + (hchams2_flags.OutlineTargetAlpha - hchams2_flags.OutlineAlpha) * t2
            
            for plrName, entry in pairs(hchams2_cache) do
                if entry.hl then
                    local fade = calc_chams_fade(plrName, dt, entry)
                    if fade >= 0.99 then
                        entry.hl.Enabled = false
                    else
                        entry.hl.Enabled = true
                        entry.hl.FillColor = hchams2_flags.FillColor
                        entry.hl.FillTransparency = hchams2_flags.FillAlpha + fade * (1 - hchams2_flags.FillAlpha)
                        entry.hl.OutlineColor = hchams2_flags.OutlineColor
                        entry.hl.OutlineTransparency = hchams2_flags.OutlineAlpha + fade * (1 - hchams2_flags.OutlineAlpha)
                    end
                end
            end
        else
            for _, entry in pairs(hchams2_cache) do if entry.hl then entry.hl.Enabled = false end end
        end
    end)
end

local function hchams_stop_render()
    if hchams_render_conn then hchams_render_conn:Disconnect(); hchams_render_conn = nil end
end


local chams_render_conn = nil
local function chams_start_render()
    if chams_render_conn then return end
    chams_render_conn = esp_run.RenderStepped:Connect(function(dt)
        if not chams_flags.Enabled and not chams2_flags.Enabled then return end


        local masterOn = chams_flags.MasterEnabled
        if not masterOn then
            for _, entry in pairs(chams_cache) do
                if entry.folder and entry.folder.Parent then
                    for i = 1, #entry.inners do entry.inners[i].Visible = false end
                    for i = 1, #entry.outers do entry.outers[i].Visible = false end
                end
            end
            for _, entry in pairs(chams2_cache) do
                if entry.folder and entry.folder.Parent then
                    for i = 1, #entry.inners do entry.inners[i].Visible = false end
                    for i = 1, #entry.outers do entry.outers[i].Visible = false end
                end
            end
            return
        end

        local t = math.clamp(dt / chams_flags.LerpSpeed, 0, 1)


        chams_flags.Color = chams_flags.Color:Lerp(chams_flags.TargetColor, t)
        chams_flags.Alpha = chams_flags.Alpha + (chams_flags.TargetAlpha - chams_flags.Alpha) * t


        local t2 = math.clamp(dt / chams2_flags.LerpSpeed, 0, 1)
        chams2_flags.Color = chams2_flags.Color:Lerp(chams2_flags.TargetColor, t2)
        chams2_flags.Alpha = chams2_flags.Alpha + (chams2_flags.TargetAlpha - chams2_flags.Alpha) * t2

        if chams_flags.Enabled then
            local col       = chams_flags.Color
            local alpha     = chams_flags.Alpha
            local glowOn    = chams_flags.GlowEnabled
            local glowAlpha = glowOn and (chams_flags.Alpha / chams_flags.GlowSize) or chams_flags.Alpha
            local inShade   = chams_flags.ShadingEnabled and chams_flags.InlineShade  or "Default"
            local outShade  = chams_flags.ShadingEnabled and chams_flags.OutlineShade or "Default"

            for plrName, entry in pairs(chams_cache) do

                if not entry.folder or not entry.folder.Parent then
                    local plr = esp_players:FindFirstChild(plrName)
                    if plr then task.spawn(chams_build_player, plr) end
                    continue
                end

                local firstInner = entry.inners and entry.inners[1]
                if firstInner and (not firstInner.Parent or not firstInner.Adornee or not firstInner.Adornee.Parent) then
                    local plr = esp_players:FindFirstChild(plrName)
                    if plr then task.spawn(chams_build_player, plr) end
                    continue
                end

                local inners = entry.inners
                local fade = calc_chams_fade(plrName, dt, entry)
                local isVisible = fade < 0.99
                for i = 1, #inners do
                    local a = inners[i]
                    a.Visible      = isVisible
                    a.Color3       = col
                    a.Transparency = alpha + fade * (1 - alpha)
                    a.Shading      = inShade
                end
                local outers = entry.outers
                for i = 1, #outers do
                    local a = outers[i]
                    a.Visible      = isVisible and glowOn
                    if a.Visible and a.Adornee then
                        local gs = chams_flags.GlowSize
                        a.Size = a.Adornee.Size + Vector3.new(0.1 * gs, 0.1 * gs, 0.1 * gs)
                    end
                    a.Color3       = col
                    a.AlwaysOnTop  = glowOn
                    a.Transparency = glowAlpha + fade * (1 - glowAlpha)
                    a.Shading      = outShade
                end
            end
        end

        if chams2_flags.Enabled then
            local col2       = chams2_flags.Color
            local alpha2     = chams2_flags.Alpha
            local glowOn2    = chams2_flags.GlowEnabled
            local glowAlpha2 = glowOn2 and math.max(0, chams2_flags.Alpha / chams2_flags.GlowSize) or chams2_flags.Alpha
            local inShade2   = chams2_flags.ShadingEnabled and chams2_flags.InlineShade  or "Default"
            local outShade2  = chams2_flags.ShadingEnabled and chams2_flags.OutlineShade or "Default"

            for plrName, entry in pairs(chams2_cache) do

                if not entry.folder or not entry.folder.Parent then
                    local plr = esp_players:FindFirstChild(plrName)
                    if plr then task.spawn(chams2_build_player, plr) end
                    continue
                end

                local firstInner = entry.inners and entry.inners[1]
                if firstInner and (not firstInner.Parent or not firstInner.Adornee or not firstInner.Adornee.Parent) then
                    local plr = esp_players:FindFirstChild(plrName)
                    if plr then task.spawn(chams2_build_player, plr) end
                    continue
                end

                local inners = entry.inners
                local fade = calc_chams_fade(plrName, dt, entry)
                local isVisible = fade < 0.99
                for i = 1, #inners do
                    local a = inners[i]
                    a.Visible      = isVisible
                    a.Color3       = col2
                    a.Transparency = alpha2 + fade * (1 - alpha2)
                    a.Shading      = inShade2
                end
                local outers = entry.outers
                for i = 1, #outers do
                    local a = outers[i]
                    a.Visible      = isVisible and glowOn2
                    if a.Visible and a.Adornee then
                        local gs = chams2_flags.GlowSize
                        a.Size = a.Adornee.Size + Vector3.new(0.1 * gs, 0.1 * gs, 0.1 * gs)
                    end
                    a.Color3       = col2
                    a.AlwaysOnTop  = false
                    a.Transparency = glowAlpha2 + fade * (1 - glowAlpha2)
                    a.Shading      = outShade2
                end
            end
        end
    end)
end

local function chams_stop_render()
    if chams_render_conn then
        chams_render_conn:Disconnect()
        chams_render_conn = nil
    end
end

esp_players.PlayerRemoving:Connect(function(plr)
    chams_remove_player(plr.Name)
    chams2_remove_player(plr.Name)
    hchams_remove_player(plr.Name)
end)
esp_players.PlayerAdded:Connect(function(plr)
    local function onCharAdded(newChar)
        task.spawn(function()
            local rok = pcall(function()
                newChar:WaitForChild("HumanoidRootPart", 8)
                newChar:WaitForChild("Humanoid", 8)
            end)
            if not rok then return end
            task.wait(0.15)
            if chams_flags.Enabled  then chams_build_player(plr)  end
            if chams2_flags.Enabled then chams2_build_player(plr) end
            if hchams_flags.Enabled then hchams_build_player(plr) end
            if hchams2_flags.Enabled then hchams2_build_player(plr) end
        end)
    end
    plr.CharacterAdded:Connect(onCharAdded)
    if plr.Character then onCharAdded(plr.Character) end
end)

for _, plr in ipairs(esp_players:GetPlayers()) do
    local function onCharAdded(newChar)
        task.spawn(function()
            local rok = pcall(function()
                newChar:WaitForChild("HumanoidRootPart", 8)
                newChar:WaitForChild("Humanoid", 8)
            end)
            if not rok then return end
            task.wait(0.15)
            if chams_flags.Enabled  then chams_build_player(plr)  end
            if chams2_flags.Enabled then chams2_build_player(plr) end
            if hchams_flags.Enabled then hchams_build_player(plr) end
            if hchams2_flags.Enabled then hchams2_build_player(plr) end
        end)
    end
    plr.CharacterAdded:Connect(onCharAdded)
end

local VisualsSection = VisualsPage:Section({Name = "Visuals", Side = "Left"})
local ChamsSection   = VisualsPage:Section({Name = "Chams",   Side = "Right"})

local MiscSection = MiscPage:Section({Name = "Misc", Side = "Left"})

local FarmMeleeAura_Enabled = false
local FarmMeleeAura_Connection

local farmRunAttackLoop do
    local maxdist = 20

    local function Attack(target)
        if not (target and target:FindFirstChild("Head")) then return end
        local ev = RepSt:FindFirstChild("Events")
        local remote1 = ev and ev:FindFirstChild("XMHH.2")
        local remote2 = ev and ev:FindFirstChild("XMHH2.2")
        if not (remote1 and remote2) then return end
        local arg1 = {
            [1] = "??", 
            [2] = tick(),
            [3] = LP.Character and LP.Character:FindFirstChildOfClass("Tool"),
            [4] = "43TRFWX",
            [5] = "Normal",
            [6] = tick(),
            [7] = true
        }
        local result = remote1:InvokeServer(unpack(arg1))
        task.wait(0.3)

        local tool = LP.Character and LP.Character:FindFirstChildOfClass("Tool")
        if tool then
            local Handle = tool:FindFirstChild("WeaponHandle") or tool:FindFirstChild("Handle")
                          or LP.Character:FindFirstChild("Right Arm")
            if Handle and target:FindFirstChild("Head") then
                local arg2 = {
                    [1] = "??", 
                    [2] = tick(),
                    [3] = tool,
                    [4] = "2389ZFX34",
                    [5] = result,
                    [6] = false,
                    [7] = Handle,
                    [8] = target:FindFirstChild("Head"),
                    [9] = target,
                    [10] = LP.Character:FindFirstChild("HumanoidRootPart").Position,
                    [11] = target:FindFirstChild("Head").Position
                }
                remote2:FireServer(unpack(arg2))
            end
        end
    end

    farmRunAttackLoop = function()
        return RS.RenderStepped:Connect(function()
            if not FarmMeleeAura_Enabled then return end
            local char = LP.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, plr in ipairs(Plrs:GetPlayers()) do
                    if plr ~= LP then
                        local c = plr.Character
                        local hrp2 = c and c:FindFirstChild("HumanoidRootPart")
                        local hum = c and c:FindFirstChildOfClass("Humanoid")
                        if hrp2 and hum then
                            local dist = (hrp.Position - hrp2.Position).Magnitude
                            if dist < maxdist and hum.Health > 15 and not c:FindFirstChildOfClass("ForceField") then
                                Attack(c)
                            end
                        end
                    end
                end
            end
        end)
    end
end

local function FarmMeleeAura_Enable()
    if FarmMeleeAura_Enabled then return end
    FarmMeleeAura_Enabled = true
    FarmMeleeAura_Connection = farmRunAttackLoop()
end

local function FarmMeleeAura_Disable()
    if not FarmMeleeAura_Enabled then return end
    FarmMeleeAura_Enabled = false
    if FarmMeleeAura_Connection then
        FarmMeleeAura_Connection:Disconnect()
        FarmMeleeAura_Connection = nil
    end
end

MiscSection:Toggle({
    Name     = "Melee Aura",
    Flag     = "MiscMeleeAura",
    Default  = false,
    Callback = function(state)
        if state then FarmMeleeAura_Enable() else FarmMeleeAura_Disable() end
    end,
})

local FinishAura = {
    Enabled    = false,
    Connection = nil,
    Range      = 7,
}

local function finish_aura_has_marked_enemies()
    if not (Playerlist and Playerlist.Players) then return false end
    for _, entry in pairs(Playerlist.Players) do
        if entry.Priority and entry.Priority.Text == "Enemy" then
            return true
        end
    end
    return false
end

local function finish_aura_is_valid_target(player, has_enemies)
    local status = get_player_status(player)
    if has_enemies then
        return status == "Enemy"
    end
    return status ~= "Friendly"
end

local function FinishAura_Enable()
    if FinishAura.Enabled then return end
    FinishAura.Enabled = true

    FinishAura.Connection = RS.RenderStepped:Connect(function()
        if not FinishAura.Enabled then return end

        local local_char = LP.Character
        local local_hrp   = local_char and local_char:FindFirstChild("HumanoidRootPart")
        local tool        = local_char and local_char:FindFirstChildOfClass("Tool")
        if not (local_hrp and tool) then return end

        local events      = RepSt:FindFirstChild("Events")
        local invoke_event = events and events:FindFirstChild("XMHH.2")
        local fire_event   = events and events:FindFirstChild("XMHH2.2")
        if not (invoke_event and fire_event) then return end

        local has_enemies = finish_aura_has_marked_enemies()

        for _, player in ipairs(Plrs:GetPlayers()) do
            if player ~= LP and finish_aura_is_valid_target(player, has_enemies) then
                local target_char = player.Character
                local target_hrp  = target_char and target_char:FindFirstChild("HumanoidRootPart")
                local target_head = target_char and target_char:FindFirstChild("Head")
                local target_humanoid = target_char and target_char:FindFirstChildOfClass("Humanoid")
                local char_stats  = RepSt:FindFirstChild("CharStats")
                local stat_entry  = char_stats and char_stats:FindFirstChild(player.Name)
                local downed_value = stat_entry and stat_entry:FindFirstChild("Downed")

                if target_hrp and target_head and target_humanoid and downed_value
                    and (local_hrp.Position - target_hrp.Position).Magnitude <= FinishAura.Range
                    and target_humanoid.Health > 0
                    and downed_value.Value == true
                then
                    local invoke_result = invoke_event:InvokeServer("\240\159\141\158", tick(), tool, "EXECQX")
                    task.wait(0.25)
                    fire_event:FireServer("\240\159\141\158", tick(), tool, "2389ZFX34", invoke_result, false, local_char:FindFirstChild("Right Leg"), target_head, target_char, target_head.Position, target_head.Position)
                end
            end
        end
    end)
end

local function FinishAura_Disable()
    if not FinishAura.Enabled then return end
    FinishAura.Enabled = false

    if FinishAura.Connection then
        FinishAura.Connection:Disconnect()
        FinishAura.Connection = nil
    end
end

MiscSection:Toggle({
    Name     = "No Scope Glint",
    Flag     = "aim_noscope_glint",
    Default  = false,
    Callback = function(v)
        if v then nsg_enable() else nsg_disable() end
    end,
})

MiscSection:Toggle({
    Name     = "Finish Aura",
    Flag     = "MiscFinishAura",
    Default  = false,
    Callback = function(state)
        if state then FinishAura_Enable() else FinishAura_Disable() end
    end,
})

local NoCamBob = { Enabled = false, Conn = nil, ConfigTable = nil, Scanned = false }

local function ncb_scan()
    if NoCamBob.Scanned then return end
    NoCamBob.Scanned = true
    if not getgc or not isreadonly then return end
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and not isreadonly(v) then
            if rawget(v, "CameraBobbing") ~= nil or rawget(v, "Bobbing") ~= nil then
                NoCamBob.ConfigTable = v
                break
            end
        end
    end
end

local function apply_nocambob()
    ncb_scan()
    local t = NoCamBob.ConfigTable
    if not t then return end
    
    if rawget(t, "CameraBobbing") ~= nil then t.CameraBobbing = false end
    if rawget(t, "Bobbing") ~= nil then t.Bobbing = false end
    
    if NoCamBob.Conn then NoCamBob.Conn:Disconnect(); NoCamBob.Conn = nil end
    NoCamBob.Conn = RS.Heartbeat:Connect(function()
        if not NoCamBob.Enabled then return end
        if rawget(t, "CameraBobbing") ~= nil then t.CameraBobbing = false end
        if rawget(t, "Bobbing") ~= nil then t.Bobbing = false end
    end)
end

local function disable_nocambob()
    if NoCamBob.Conn then NoCamBob.Conn:Disconnect(); NoCamBob.Conn = nil end
end

local patched_Upvalues = {}
local MiscNoSpread = { Enabled = false }

local function apply_misc_nospread()
    if not getgc or not debug.getupvalues or not debug.setupvalue then return end
    
    if MiscNoSpread.Enabled then
        local guns = {}
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "EquipTime") then
                local s = rawget(v, "Spread")
                local r = rawget(v, "Recoil")
                if type(s) == "number" and s > 0 and type(r) == "number" and r > 0 then
                    table.insert(guns, {Spread = s, Recoil = r})
                end
            end
        end
        
        for _, closure in pairs(getgc(true)) do
            if type(closure) == "function" then
                local suc, upvalues = pcall(debug.getupvalues, closure)
                if suc and type(upvalues) == "table" then
                    local matched_gun = nil
                    for _, gun in ipairs(guns) do
                        local has_s, has_r = false, false
                        for _, upv in pairs(upvalues) do
                            if type(upv) == "number" then
                                if upv == gun.Spread then has_s = true end
                                if upv == gun.Recoil then has_r = true end
                            end
                        end
                        if has_s and has_r then
                            matched_gun = gun
                            break
                        end
                    end
                    
                    if matched_gun then
                        for index, value in pairs(upvalues) do
                            if type(value) == "number" and value == matched_gun.Spread then
                                table.insert(patched_Upvalues, {closure = closure, index = index, original = value})
                                pcall(debug.setupvalue, closure, index, 0)
                            end
                        end
                    end
                end
            end
        end
    else
        for _, patch in pairs(patched_Upvalues) do
            if patch.closure and patch.original then
                pcall(function()
                    debug.setupvalue(patch.closure, patch.index, patch.original)
                end)
            end
        end
        patched_Upvalues = {}
    end
end

local CustomMaxZoom = { Enabled = false, Value = 128, Conn = nil }
local function apply_custom_max_zoom()
    if CustomMaxZoom.Enabled then
        if not CustomMaxZoom.Conn then
            CustomMaxZoom.Conn = RS.Heartbeat:Connect(function()
                if LP.CameraMaxZoomDistance ~= CustomMaxZoom.Value then
                    LP.CameraMaxZoomDistance = CustomMaxZoom.Value
                end
            end)
        end
    else
        if CustomMaxZoom.Conn then
            CustomMaxZoom.Conn:Disconnect()
            CustomMaxZoom.Conn = nil
        end
        -- Do not reset to 128, keep user's unlocked default
    end
end

MiscSection:Toggle({
    Name     = "Custom Max Zoom",
    Flag     = "MiscCustomMaxZoom",
    Default  = false,
    Callback = function(state)
        CustomMaxZoom.Enabled = state
        apply_custom_max_zoom()
    end,
})

MiscSection:Slider({
    Name     = "Max Zoom Distance",
    Flag     = "MiscCustomMaxZoomValue",
    Min      = 10,
    Max      = 10000,
    Default  = 128,
    Callback = function(value)
        CustomMaxZoom.Value = value
    end,
})

MiscSection:Toggle({
    Name     = "No Spread",
    Flag     = "MiscNoSpreadUpv",
    Default  = false,
    Callback = function(state)
        MiscNoSpread.Enabled = state
        apply_misc_nospread()
    end,
})

MiscSection:Toggle({
    Name     = "No Camera Bobbing",
    Flag     = "MiscNoShakeCam",
    Default  = false,
    Callback = function(state)
        NoCamBob.Enabled = state
        if state then apply_nocambob() else disable_nocambob() end
    end,
})

local function remove_no_fall_damage_ff()
    if RB.NoFallDamageFF then
        pcall(function() RB.NoFallDamageFF:Destroy() end)
        RB.NoFallDamageFF = nil
    end
end

local function apply_no_fall_damage_ff(character)
    remove_no_fall_damage_ff()
    if not character then return end

    local ff = Instance.new("ForceField")
    ff.Visible = false
    ff.Parent = character
    RB.NoFallDamageFF = ff
end

RS.Heartbeat:Connect(function()
    if not (RB.NoFallDamage and RB.NoFallDamageMethod == "ForceField") then
        return
    end

    local char = LP.Character
    if not char then return end

    local existing = char:FindFirstChildOfClass("ForceField")
    if not existing or existing ~= RB.NoFallDamageFF then
        apply_no_fall_damage_ff(char)
    end
end)

local NoFallDamageHookOriginal = nil
local function install_no_fall_damage_hook()
    if NoFallDamageHookOriginal then return end
    if not hookmetamethod or not getnamecallmethod then return end

    task.spawn(function()
        local events = RepSt:FindFirstChild("Events")
        local fall_event = events and events:FindFirstChild("__RZDONL")
        if not fall_event then

            if events then
                fall_event = events:WaitForChild("__RZDONL", 10)
            end
        end
        if not fall_event then return end
        if NoFallDamageHookOriginal then return end  -- уже поставили пока ждали

        NoFallDamageHookOriginal = hookmetamethod(game, "__namecall", function(self, ...)
            if getnamecallmethod() == "FireServer" and self == fall_event then
                local args = { ... }
                if RB.NoFallDamage and RB.NoFallDamageMethod == "Block Remote"
                    and (args[1] == "FlllD" or args[1] == "FllH") then
                    return
                end
            end
            return NoFallDamageHookOriginal(self, ...)
        end)
    end)
end

MiscSection:Toggle({
    Name     = "No Fall Damage",
    Flag     = "MiscNoFallDamage",
    Default  = false,
    Callback = function(state)
        RB.NoFallDamage = state
        install_no_fall_damage_hook()

        if state and RB.NoFallDamageMethod == "ForceField" then
            apply_no_fall_damage_ff(LP.Character)

            if RB.NoFallDamageCharConn then RB.NoFallDamageCharConn:Disconnect() end
            RB.NoFallDamageCharConn = LP.CharacterAdded:Connect(function(char)
                if RB.NoFallDamage and RB.NoFallDamageMethod == "ForceField" then
                    apply_no_fall_damage_ff(char)
                end
            end)
        else
            remove_no_fall_damage_ff()
            if RB.NoFallDamageCharConn then
                RB.NoFallDamageCharConn:Disconnect()
                RB.NoFallDamageCharConn = nil
            end
        end
    end,
})

MiscSection:Dropdown({
    Name     = "Method",
    Flag     = "MiscNoFallDamageMethod",
    Options    = {"Block Remote", "ForceField"},
    Default  = "Block Remote",
    Multi    = false,
    Callback = function(v)
        RB.NoFallDamageMethod = v
        -- хук ставим только если тоггл уже включён
        if RB.NoFallDamage then
            install_no_fall_damage_hook()
        end

        if not RB.NoFallDamage then return end

        if v == "ForceField" then
            apply_no_fall_damage_ff(LP.Character)

            if RB.NoFallDamageCharConn then RB.NoFallDamageCharConn:Disconnect() end
            RB.NoFallDamageCharConn = LP.CharacterAdded:Connect(function(char)
                if RB.NoFallDamage and RB.NoFallDamageMethod == "ForceField" then
                    apply_no_fall_damage_ff(char)
                end
            end)
        else
            remove_no_fall_damage_ff()
            if RB.NoFallDamageCharConn then
                RB.NoFallDamageCharConn:Disconnect()
                RB.NoFallDamageCharConn = nil
            end
        end
    end,
})

local SpectateEnemy = {
    Enabled    = false,
    Connection = nil,
}

local function spectate_find_enemy_target()
    local my_char = LP.Character
    local my_hrp  = my_char and my_char:FindFirstChild("HumanoidRootPart")
    if not my_hrp then return nil end

    local best_player, best_dist
    for _, player in ipairs(Plrs:GetPlayers()) do
        if player ~= LP and get_player_status(player) == "Enemy" then
            local char = player.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (my_hrp.Position - hrp.Position).Magnitude
                if not best_dist or dist < best_dist then
                    best_dist   = dist
                    best_player = player
                end
            end
        end
    end

    return best_player
end

local MovementSection = MiscPage:Section({Name = "Movement", Side = "Right"})

local Movement = {
    TPWalkOn    = false,
    TPWalkSpeed = 16,
    TPWalkConn  = nil,

    SpeedOn     = false,
    SpeedMethod = "CFrame",
    SpeedValue  = 16,
    SpeedConn   = nil,
}

local function get_speed_move_vector()
    local camCF = Cam.CFrame
    local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
    if flatLook.Magnitude == 0 then flatLook = Vector3.new(0, 0, -1) end
    flatLook = flatLook.Unit
    local flatRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit

    local moveVec = Vector3.new()
    if UIS:IsKeyDown(Enum.KeyCode.W) then moveVec += flatLook end
    if UIS:IsKeyDown(Enum.KeyCode.S) then moveVec -= flatLook end
    if UIS:IsKeyDown(Enum.KeyCode.D) then moveVec += flatRight end
    if UIS:IsKeyDown(Enum.KeyCode.A) then moveVec -= flatRight end

    return moveVec
end

MovementSection:Toggle({
    Name     = "TPWalk",
    Flag     = "MiscTPWalk",
    Default  = false,
    Callback = function(state)
        Movement.TPWalkOn = state

        if Movement.TPWalkConn then
            Movement.TPWalkConn:Disconnect()
            Movement.TPWalkConn = nil
        end

        if state then
            Movement.TPWalkConn = RS.RenderStepped:Connect(function(dt)
                local char = LP.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                if not (hrp and hum) then return end

                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    hrp.CFrame = hrp.CFrame + (moveDir.Unit * Movement.TPWalkSpeed * dt)
                end
            end)
        end
    end,
})

MovementSection:Slider({
    Name     = "TPWalk Speed",
    Flag     = "MiscTPWalkSpeed",
    Min      = 1,
    Max      = 200,
    Default  = 16,
    Decimal = 1,
    Suffix   = "st/s",
    Callback = function(value) Movement.TPWalkSpeed = value end,
})

MovementSection:Toggle({
    Name     = "Speed",
    Flag     = "MiscSpeed",
    Default  = false,
    Callback = function(state)
        Movement.SpeedOn = state

        if Movement.SpeedConn then
            Movement.SpeedConn:Disconnect()
            Movement.SpeedConn = nil
        end

        if state then
            Movement.SpeedConn = RS.RenderStepped:Connect(function(dt)
                local char = LP.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local moveVec = get_speed_move_vector()
                local hasInput = moveVec.Magnitude > 0
                if hasInput then moveVec = moveVec.Unit end

                if Movement.SpeedMethod == "Velocity" then
                    local horizontal = moveVec * Movement.SpeedValue
                    local vel = hrp.AssemblyLinearVelocity
                    hrp.AssemblyLinearVelocity = Vector3.new(horizontal.X, vel.Y, horizontal.Z)
                elseif hasInput then
                    hrp.CFrame = hrp.CFrame + (moveVec * Movement.SpeedValue * dt)
                end
            end)
        end
    end,
})

MovementSection:Dropdown({
    Name     = "Method",
    Flag     = "MiscSpeedMethod",
    Options    = {"CFrame", "Velocity"},
    Default  = "CFrame",
    Multi    = false,
    Callback = function(v) Movement.SpeedMethod = v end,
})

MovementSection:Slider({
    Name     = "Speed Value",
    Flag     = "MiscSpeedValue",
    Min      = 1,
    Max      = 200,
    Default  = 16,
    Decimal = 1,
    Suffix   = "st/s",
    Callback = function(value) Movement.SpeedValue = value end,
})

local FlyState = { On = false, Conn = nil, Speed = 50, Mode = "Normal" }

local function fly(hrp)
    local events = RepSt:FindFirstChild("Events")
    local event  = events and events:FindFirstChild("__RZDONL")

    if FlyState.On then
        if FlyState.Conn then FlyState.Conn:Disconnect() end

        local function onStep()
            if not FlyState.On or not hrp or not hrp.Parent then
                if FlyState.Conn then FlyState.Conn:Disconnect() end
                return
            end

            local moveVector = Vector3.new(0, 0, 0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then
                moveVector = moveVector + (Cam.CFrame.LookVector * FlyState.Speed)
            end
            if UIS:IsKeyDown(Enum.KeyCode.S) then
                moveVector = moveVector - (Cam.CFrame.LookVector * FlyState.Speed)
            end
            if UIS:IsKeyDown(Enum.KeyCode.A) then
                moveVector = moveVector - (Cam.CFrame.RightVector * FlyState.Speed)
            end
            if UIS:IsKeyDown(Enum.KeyCode.D) then
                moveVector = moveVector + (Cam.CFrame.RightVector * FlyState.Speed)
            end

            hrp.Velocity = moveVector

            if FlyState.Mode == "Bypass" and event then
                event:FireServer("__---r", Vector3.new(0, 0, 0), hrp.CFrame, false)
            end
        end

        FlyState.Conn = RS.RenderStepped:Connect(onStep)
        task.spawn(onStep)
    else
        if hrp then hrp.Velocity = Vector3.new(0, 0, 0) end
    end
end

local function enable_fly()
    FlyState.On = true
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then fly(hrp) end
end

local function disable_fly()
    FlyState.On = false
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    fly(hrp)
end

local FlyToggle = MovementSection:Toggle({
    Name     = "Fly",
    Flag     = "MiscFly",
    Default  = false,
    Callback = function(state)
        if state then
            enable_fly()
        else
            disable_fly()
        end
    end,
})

FlyToggle:Keybind({
    Flag     = "MiscFlyKey",
    Default  = false,
    Mode     = "Toggle",
    Callback = function(Value)
        FlyToggle.Set(Value)
    end,
})

MovementSection:Dropdown({
    Name     = "Fly Mode",
    Flag     = "MiscFlyMode",
    Options    = {"Normal", "Bypass"},
    Default  = "Normal",
    Multi    = false,
    Callback = function(v) FlyState.Mode = v end,
})

MovementSection:Slider({
    Name     = "Fly Speed",
    Flag     = "MiscFlySpeed",
    Min      = 10,
    Max      = 200,
    Default  = 50,
    Decimal = 1,
    Suffix   = "st/s",
    Callback = function(value) FlyState.Speed = value end,
})

;(function()
local JumpCFG = {
    Bhop = false,
    CSBhop = false,
    NoCD = false,
    MaxSpeed = 100,
    Conn = nil
}

local last_vel = Vector3.new()

local function update_jump_logic()
    if JumpCFG.Bhop or JumpCFG.NoCD or JumpCFG.CSBhop then
        if not JumpCFG.Conn then
            JumpCFG.Conn = RS.Heartbeat:Connect(function(dt)
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not (hum and hrp) then return end

                if JumpCFG.NoCD then
                    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                end
                
                local state = hum:GetState()
                local in_air = (state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping)
                
                if (JumpCFG.Bhop or JumpCFG.CSBhop) and UIS:IsKeyDown(Enum.KeyCode.Space) then
                    if not in_air and state ~= Enum.HumanoidStateType.FallingDown then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                        hum.Jump = true
                        if JumpCFG.CSBhop then
                            hrp.AssemblyLinearVelocity = Vector3.new(last_vel.X, hrp.AssemblyLinearVelocity.Y, last_vel.Z)
                        end
                        in_air = true
                    end
                end
                
                if JumpCFG.CSBhop and in_air then
                    local cam = workspace.CurrentCamera
                    local look = cam.CFrame.LookVector
                    local right = cam.CFrame.RightVector
                    local wishDir = Vector3.new()
                    
                    local p_w = UIS:IsKeyDown(Enum.KeyCode.W)
                    local p_s = UIS:IsKeyDown(Enum.KeyCode.S)
                    local p_a = UIS:IsKeyDown(Enum.KeyCode.A)
                    local p_d = UIS:IsKeyDown(Enum.KeyCode.D)
                    
                    if p_w then wishDir += look end
                    if p_s then wishDir -= look end
                    if p_a then wishDir -= right end
                    if p_d then wishDir += right end
                    
                    if not p_w and not p_s and (p_a or p_d) then
                        wishDir += look * 0.15
                    end
                    
                    wishDir = Vector3.new(wishDir.X, 0, wishDir.Z)
                    if wishDir.Magnitude > 0.01 then 
                        wishDir = wishDir.Unit 
                    else
                        wishDir = Vector3.zero
                    end
                    
                    local vel = hrp.AssemblyLinearVelocity
                    if vel.X ~= vel.X or vel.Y ~= vel.Y or vel.Z ~= vel.Z then
                        hrp.AssemblyLinearVelocity = Vector3.zero
                        vel = Vector3.zero
                    end
                    if last_vel.X ~= last_vel.X or last_vel.Y ~= last_vel.Y or last_vel.Z ~= last_vel.Z then
                        last_vel = Vector3.zero
                    end

                    local actualFlat = Vector3.new(vel.X, 0, vel.Z)
                    local lastFlat = Vector3.new(last_vel.X, 0, last_vel.Z)
                    
                    if (actualFlat - lastFlat).Magnitude > 2 then
                        lastFlat = actualFlat
                    end
                    
                    local flatVel = lastFlat
                    
                    if wishDir.Magnitude > 0 then
                        local currentSpeed = flatVel:Dot(wishDir)
                        local maxAirSpeed = 3.5
                        local accel = 200
                        
                        local addSpeed = maxAirSpeed - currentSpeed
                        if addSpeed > 0 then
                            local accelSpeed = accel * maxAirSpeed * dt
                            if accelSpeed > addSpeed then accelSpeed = addSpeed end
                            flatVel = flatVel + wishDir * accelSpeed
                        end
                    end
                    
                    if flatVel.Magnitude > JumpCFG.MaxSpeed then
                        flatVel = flatVel.Unit * JumpCFG.MaxSpeed
                    end
                    
                    hrp.AssemblyLinearVelocity = Vector3.new(flatVel.X, vel.Y, flatVel.Z)
                    last_vel = hrp.AssemblyLinearVelocity
                else
                    last_vel = hrp.AssemblyLinearVelocity
                end
            end)
        end
    else
        if JumpCFG.Conn then
            JumpCFG.Conn:Disconnect()
            JumpCFG.Conn = nil
        end
    end
end

MovementSection:Toggle({
    Name     = "Bunny Hop",
    Flag     = "MiscBhop",
    Default  = false,
    Callback = function(state)
        JumpCFG.Bhop = state
        update_jump_logic()
    end,
})

MovementSection:Toggle({
    Name     = "csgo strafes ( real )",
    Flag     = "MiscCSBhop",
    Default  = false,
    Callback = function(state)
        JumpCFG.CSBhop = state
        update_jump_logic()
    end,
})

MovementSection:Slider({
    Name     = "Bhop Max Speed",
    Flag     = "MiscBhopMaxSpeed",
    Min      = 16,
    Max      = 300,
    Default  = 100,
    Suffix   = "st/s",
    Callback = function(value)
        JumpCFG.MaxSpeed = value
    end,
})

MovementSection:Toggle({
    Name     = "No Jump Cooldown",
    Flag     = "MiscNoJumpCD",
    Default  = false,
    Callback = function(state)
        JumpCFG.NoCD = state
        update_jump_logic()
    end,
})
end)()

local OtherSection = MiscPage:Section({Name = "Other", Side = "Left"})

local HideBody = {
    Enabled        = false,
    Conn           = nil,
    Track          = nil,
    VerticalOffset = -2.6,
}

local function set_local_transparency(char, value)
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            v.LocalTransparencyModifier = value
        end
    end
end

local function enable_hidebody()
    HideBody.Enabled = true

    local char = LP.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid") or char:WaitForChild("Humanoid", 3)
    if not humanoid then return end

    set_local_transparency(char, 1)

    if HideBody.Track then
        pcall(function()
            HideBody.Track:Stop()
            HideBody.Track:Destroy()
        end)
        HideBody.Track = nil
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://282574440"
    HideBody.Track = humanoid:LoadAnimation(anim)
    HideBody.Track.Looped   = true
    HideBody.Track.Priority = Enum.AnimationPriority.Action4
    HideBody.Track:Play(0.1, 1, 0)

    if HideBody.Conn then HideBody.Conn:Disconnect() end
    HideBody.Conn = RS.Heartbeat:Connect(function()
        if not HideBody.Enabled then return end
        local c   = LP.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if not (hrp and HideBody.Track) then return end

        HideBody.Track.TimePosition = 1.755

        local original_cframe   = hrp.CFrame
        local original_velocity = hrp.AssemblyLinearVelocity
        local new_cframe = hrp.CFrame + Vector3.new(0, HideBody.VerticalOffset, 0)
        hrp.CFrame = new_cframe

        RS.RenderStepped:Wait()

        local c2   = LP.Character
        local hrp2 = c2 and c2:FindFirstChild("HumanoidRootPart")
        if hrp2 then
            hrp2.CFrame = original_cframe
            hrp2.AssemblyLinearVelocity = original_velocity
        end

        if HideBody.Enabled then
            set_local_transparency(c, 1)
        end
    end)
end

local function disable_hidebody()
    HideBody.Enabled = false

    if HideBody.Track then
        pcall(function()
            HideBody.Track:Stop()
            HideBody.Track:Destroy()
        end)
        HideBody.Track = nil
    end
    if HideBody.Conn then
        HideBody.Conn:Disconnect()
        HideBody.Conn = nil
    end

    if not SpectateEnemy.Enabled then
        set_local_transparency(LP.Character, 0)
    end
end

local R6Invis = (function()
    local clonerefSafe = cloneref or function(...) return ... end
    local services     = setmetatable({}, { __index = function(_, k) return clonerefSafe(game:GetService(k)) end })
    local localPlayer  = services.Players.LocalPlayer
    local character, humanoid, hrp

    local function updateChar()
        character = localPlayer.Character
        if character then
            hrp      = character:FindFirstChild("HumanoidRootPart")
            humanoid = character:FindFirstChildOfClass("Humanoid")
        else
            hrp = nil
            humanoid = nil
        end
    end
    updateChar()

    local heartbeat     = game:GetService("RunService").Heartbeat
    local renderStepped = game:GetService("RunService").RenderStepped
    local starterGui    = game:GetService("StarterGui")

    local InvisPossible = true
    if character and not character:FindFirstChild("Torso") then
        InvisPossible = false
    end

    local InvisActive    = false
    local InvisAnim      = Instance.new("Animation")
    InvisAnim.AnimationId = "rbxassetid://215384594"
    local InvisAnimTrack = nil

    local function loadInvisAnim()
        if InvisAnimTrack then
            pcall(function() InvisAnimTrack:Stop() end)
            InvisAnimTrack = nil
        end
        if humanoid then
            local success, track = pcall(function() return humanoid:LoadAnimation(InvisAnim) end)
            if success then
                InvisAnimTrack          = track
                InvisAnimTrack.Priority = Enum.AnimationPriority.Action4
            else
                InvisAnimTrack = nil
            end
        else
            InvisAnimTrack = nil
        end
    end

    local function disableInvis()
        if not InvisActive then return end
        InvisActive = false
        if InvisAnimTrack then
            pcall(function() InvisAnimTrack:Stop() end)
        end
        if humanoid then
            workspace.CurrentCamera.CameraSubject = humanoid
        end
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency == 0.5 then
                    part.Transparency = 0
                end
            end
        end
    end

    local function enableInvis()
        if InvisActive or not InvisPossible then return end
        updateChar()
        if not character or not humanoid or not hrp then return end
        if not character:FindFirstChild("Torso") then
            pcall(function()
                starterGui:SetCore("SendNotification", {
                    Title = "Невидимость НЕ РАБОТАЕТ", Text = "Требуется R6 аватар", Duration = 5,
                })
            end)
            return
        end
        InvisActive = true
        workspace.CurrentCamera.CameraSubject = hrp
        loadInvisAnim()
    end

        localPlayer.CharacterAdded:Connect(function(new_char)
        if InvisAnimTrack then
            pcall(function() InvisAnimTrack:Stop() end)
            InvisAnimTrack = nil
        end
        local function onDied()
            if InvisActive then disableInvis() end
        end
        local hum = new_char:WaitForChild("Humanoid", 5)
        if hum then hum.Died:Connect(onDied) end

        task.wait()
        updateChar()
        if not humanoid then
            task.wait(0.5)
            updateChar()
            if not humanoid then
                InvisPossible = false
                if InvisActive then disableInvis() end
                return
            end
        end
        if humanoid.RigType ~= Enum.HumanoidRigType.R6 then
            InvisPossible = false
            if InvisActive then disableInvis() end
        else
            InvisPossible = true
        end
        if InvisActive then
            if hrp then workspace.CurrentCamera.CameraSubject = hrp end
            loadInvisAnim()
        end
    end)
    if character then
        local hum = character:WaitForChild("Humanoid", 5)
        if hum then hum.Died:Connect(function() if InvisActive then disableInvis() end end) end
    end

    localPlayer.CharacterRemoving:Connect(function()
        if InvisAnimTrack then
            pcall(function() InvisAnimTrack:Stop() end)
            InvisAnimTrack = nil
        end
    end)

    heartbeat:Connect(function(dt)
        if not InvisActive or not InvisPossible then
            if not InvisActive and character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Transparency == 0.5 then
                        part.Transparency = 0
                    end
                end
            end
            return
        end
        if not character or not humanoid or not hrp
            or not humanoid:IsDescendantOf(workspace)
            or humanoid.Health <= 0
        then return end

        local speed = 12
        if humanoid.MoveDirection.Magnitude > 0 then
            local move = humanoid.MoveDirection * speed * dt
            hrp.CFrame = hrp.CFrame + move
        end

        local originalCF        = hrp.CFrame
        local originalCamOffset = humanoid.CameraOffset
        local _, cameraYaw      = workspace.CurrentCamera.CFrame:ToOrientation()

        hrp.CFrame            = CFrame.new(hrp.CFrame.Position) * CFrame.fromOrientation(0, cameraYaw, 0)
        hrp.CFrame            = hrp.CFrame * CFrame.Angles(math.rad(90), 0, 0)
        humanoid.CameraOffset = Vector3.new(0, 1.44, 0)

        if InvisAnimTrack then
            local success = pcall(function()
                if not InvisAnimTrack.IsPlaying then
                    InvisAnimTrack:Play()
                    InvisAnimTrack:AdjustSpeed(0)
                end
                InvisAnimTrack.TimePosition = 0.3
            end)
            if not success then loadInvisAnim() end
        elseif humanoid and humanoid.Health > 0 and InvisActive then
            loadInvisAnim()
        end

        renderStepped:Wait()

        if humanoid and humanoid:IsDescendantOf(workspace) then
            humanoid.CameraOffset = originalCamOffset
        end
        if hrp and hrp:IsDescendantOf(workspace) then
            hrp.CFrame = originalCF
        end
        if InvisAnimTrack then
            pcall(function() InvisAnimTrack:Stop() end)
        end
        if hrp and hrp:IsDescendantOf(workspace) then
            local lookVec  = workspace.CurrentCamera.CFrame.LookVector
            local flatLook = Vector3.new(lookVec.X, 0, lookVec.Z).Unit
            if flatLook.Magnitude > 0.1 then
                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + flatLook)
            end
        end
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency ~= 1 then
                    part.Transparency = 0.5
                end
            end
        end
    end)

    return { Enable = enableInvis, Disable = disableInvis, IsActive = function() return InvisActive end }
end)()
local InvisMethod = "HideBody"

local function applyInvis(state)
    if InvisMethod == "Anim" then
        if state then R6Invis.Enable() else R6Invis.Disable() end
    else
        if state then enable_hidebody() else disable_hidebody() end
    end
end

local InvisibleKeybind
local InvisibleToggle = OtherSection:Toggle({
    Name     = "Invisible",
    Flag     = "MiscInvisible",
    Default  = false,
    Callback = function(state)
        applyInvis(state)
    end,
})

InvisibleKeybind = InvisibleToggle:Keybind({
    Flag     = "MiscInvisibleKey",
    Default  = false,
    Mode     = "Toggle",
    Callback = function(Value)
        InvisibleToggle.Set(Value)
    end,
})

OtherSection:Dropdown({
    Name    = "Method",
    Flag    = "MiscInvisMethod",
    Options = { "HideBody", "Anim" },
    Default = "HideBody",
    Callback = function(val)
        local wasOn = Library.Flags["MiscInvisible"]
        if wasOn then applyInvis(false) end
        InvisMethod = val
        if wasOn then applyInvis(true) end
    end,
})

local function setup_hidebody_died(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.Died:Connect(disable_hidebody)
    end
end

if LP.Character then
    setup_hidebody_died(LP.Character)
end

LP.CharacterAdded:Connect(function(new_char)
    setup_hidebody_died(new_char)
    if HideBody.Enabled then
        if not new_char then return end
        task.wait(3)
        enable_hidebody()
    end
end)

LP.CharacterRemoving:Connect(disable_hidebody)

local function spectate_reset_camera()
    local my_humanoid = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if my_humanoid then
        Cam.CameraSubject = my_humanoid
    end
end

local function spectate_apply_local_visibility(hidden)
    if hidden then
        set_local_transparency(LP.Character, 1)
    elseif not HideBody.Enabled then
        set_local_transparency(LP.Character, 0)
    end
end

local function SpectateEnemy_Enable()
    if SpectateEnemy.Enabled then return end
    SpectateEnemy.Enabled = true

    spectate_apply_local_visibility(true)

    local lastSubject = nil
    SpectateEnemy.Connection = RS.RenderStepped:Connect(function()
        if not SpectateEnemy.Enabled then return end

        spectate_apply_local_visibility(true)

        local target_player = spectate_find_enemy_target()
        local target_humanoid = target_player and target_player.Character and target_player.Character:FindFirstChildOfClass("Humanoid")

        if target_humanoid then
            if lastSubject ~= target_humanoid then
                Cam.CameraSubject = target_humanoid
                lastSubject = target_humanoid
            end
        elseif lastSubject ~= nil then
            spectate_reset_camera()
            lastSubject = nil
        end
    end)
end

local function SpectateEnemy_Disable()
    if not SpectateEnemy.Enabled then return end
    SpectateEnemy.Enabled = false

    if SpectateEnemy.Connection then
        SpectateEnemy.Connection:Disconnect()
        SpectateEnemy.Connection = nil
    end

    spectate_reset_camera()
    spectate_apply_local_visibility(false)
end

local SpectateToggle = MiscSection:Toggle({
    Name     = "Spectate Target",
    Flag     = "MiscSpectateTarget",
    Default  = false,
    Callback = function(state)
        if state then SpectateEnemy_Enable() else SpectateEnemy_Disable() end
    end,
})

SpectateToggle:Keybind({
    Flag     = "MiscSpectateTargetKey",
    Default  = false,
    Mode     = "Toggle",
    Callback = function(Value)
        SpectateToggle.Set(Value)
    end,
})

local fastPickupEnabled = false

local function bypassProximityPrompts()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
        end
    end
end

local function enableBypass()
    fastPickupEnabled = true
    bypassProximityPrompts()
    game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(v)
        if fastPickupEnabled then
            v.HoldDuration = 0
        end
    end)
end

local function disableBypass()
    fastPickupEnabled = false
end

OtherSection:Toggle({
    Name     = "Instant Pickup",
    Flag     = "MiscInstantPickup",
    Default  = false,
    Callback = function(state)
        if state then
            enableBypass()
        else
            disableBypass()
        end
    end,
})

local InfStamina = { Enabled = false, Hook = nil, CharConn = nil }

local function apply_inf_stamina()
    if not getrenv or not hookfunction or not debug or not debug.getupvalue then return end
    pcall(function()
        local cloned   = getrenv()._G.S_Get
        local original = debug.getupvalue(cloned, 1)
        InfStamina.Hook = hookfunction(original, function()
            return 100, 100
        end)
    end)
end

OtherSection:Toggle({
    Name     = "Infinity Stamina",
    Flag     = "MiscInfStamina",
    Default  = false,
    Callback = function(state)
        InfStamina.Enabled = state
        if state then
            apply_inf_stamina()
            if InfStamina.CharConn then InfStamina.CharConn:Disconnect() end
            InfStamina.CharConn = LP.CharacterAdded:Connect(function()
                if InfStamina.Enabled then
                    task.wait(1)
                    apply_inf_stamina()
                end
            end)
        else
            if InfStamina.CharConn then
                InfStamina.CharConn:Disconnect()
                InfStamina.CharConn = nil
            end
            if InfStamina.Hook then
                pcall(function()
                    local cloned   = getrenv()._G.S_Get
                    local original = debug.getupvalue(cloned, 1)
                    hookfunction(original, InfStamina.Hook)
                end)
                InfStamina.Hook = nil
            end
        end
    end,
})

local NoclipConn = nil
local NoclippedParts = {}

local NoclipToggle = OtherSection:Toggle({
    Name     = "Noclip",
    Flag     = "MiscNoclip",
    Default  = false,
    Callback = function(state)
        if NoclipConn then
            NoclipConn:Disconnect()
            NoclipConn = nil
        end

        if state then
            NoclipConn = RS.RenderStepped:Connect(function()
                local char = LP.Character
                if not char then return end
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if not (humanoid and humanoid.Health > 15) then return end

                for _, descendant in ipairs(char:GetDescendants()) do
                    if descendant:IsA("BasePart") and descendant.CanCollide == true then
                        descendant.CanCollide = false
                        NoclippedParts[descendant] = true
                    end
                end
            end)
        else
            for part in pairs(NoclippedParts) do
                if part and part.Parent then
                    part.CanCollide = true
                end
            end
            NoclippedParts = {}
        end
    end,
})

NoclipToggle:Keybind({
    Flag     = "MiscNoclipKey",
    Default  = false,
    Mode     = "Toggle",
    Callback = function(Value)
        NoclipToggle.Set(Value)
    end,
})

local NoFailLockPick = { Enabled = false }

local function modify_lockpick_gui(gui)
    for _, element in ipairs(gui:GetDescendants()) do
        if element:IsA("ImageLabel") and element.Name == "Bar" and element.Parent.Name ~= "Attempts" then
            local original_size = element.Size
            RS.RenderStepped:Connect(function()
                if not NoFailLockPick.Enabled then
                    element.Size = original_size
                else
                    element.Size = UDim2.new(0, 280, 0, 280)
                end
            end)
        end
    end
end

OtherSection:Toggle({
    Name     = "No Fail Lockpick",
    Flag     = "MiscNoFailLockpick",
    Default  = false,
    Callback = function(state)
        NoFailLockPick.Enabled = state
        LP.PlayerGui.ChildAdded:Connect(function(child)
            if child:IsA("ScreenGui") and child.Name == "LockpickGUI" then
                modify_lockpick_gui(child)
            end
        end)
    end,
})

local AutoPickupMoney = { Enabled = false, Conn = nil }

OtherSection:Toggle({
    Name     = "Auto Pickup Money",
    Flag     = "MiscAutoPickupMoney",
    Default  = false,
    Callback = function(state)
        AutoPickupMoney.Enabled = state

        if AutoPickupMoney.Conn then
            AutoPickupMoney.Conn:Disconnect()
            AutoPickupMoney.Conn = nil
        end

        if not state then return end

        local pickup_event  = RepSt.Events:FindFirstChild("CZDPZUS")
        local spawned_money = workspace:FindFirstChild("Filter") and workspace.Filter:FindFirstChild("SpawnedBread")
        if not pickup_event or not spawned_money then return end

        local can_pickup      = true
        local last_pickup_time = tick()

        AutoPickupMoney.Conn = RS.RenderStepped:Connect(function()
            if not AutoPickupMoney.Enabled then return end

                        local char = LP.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            if not can_pickup then
                if tick() - last_pickup_time >= 1 then
                    can_pickup = true
                    last_pickup_time = tick()
                else
                    return
                end
            end

            local nearest  = nil
            local min_dist = 5

            for _, money in pairs(spawned_money:GetChildren()) do
                local dist = (hrp.Position - money.Position).Magnitude
                if dist < min_dist then
                    min_dist = dist
                    nearest  = money
                end
            end

            if nearest and can_pickup then
                pickup_event:FireServer(nearest)
                can_pickup = false
                last_pickup_time = tick()
            end
        end)
    end,
})

OtherSection:Toggle({
    Name     = "No Barriers",
    Flag     = "MiscNoBarriers",
    Default  = false,
    Callback = function(state)
        local barriers_folder = workspace:FindFirstChild("Filter")
            and workspace.Filter:FindFirstChild("Parts")
            and workspace.Filter.Parts:FindFirstChild("F_Parts")
        
        if not barriers_folder then return end

        for _, part in ipairs(barriers_folder:GetDescendants()) do
            if part:IsA("Part") or part:IsA("MeshPart") then
                part.CanTouch = not state
            end
        end
    end,
})

local AutoRefillAmmo = { Enabled = false, Conn = nil, LastRefill = 0, MaxStored = {}, MaxCurrent = {} }

OtherSection:Toggle({
    Name     = "Auto Refill Ammo",
    Flag     = "MiscAutoRefillAmmo",
    Default  = false,
    ToolTip  = {
        Name        = "Auto refill ammo",
        Description = "Simply but helpful",
    },
    Callback = function(state)
        AutoRefillAmmo.Enabled = state

        if AutoRefillAmmo.Conn then
            AutoRefillAmmo.Conn:Disconnect()
            AutoRefillAmmo.Conn = nil
        end

        if not state then return end

        AutoRefillAmmo.Conn = RS.Heartbeat:Connect(function()
            if not AutoRefillAmmo.Enabled then return end
            
            if tick() - AutoRefillAmmo.LastRefill < 0.5 then return end

            local char = LP.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return end

            local weapon_name = tool.Name

            
            
            
            do
                local ok, current_ammo, stored_ammo = pcall(function()
                    local main = LP.PlayerGui:FindFirstChild("GunGUI")
                    main = main and main:FindFirstChild("Frame")
                    main = main and main:FindFirstChild("Main")
                    if not main then return nil, nil end

                    local cur_lbl = main:FindFirstChild("Current")
                    local st_lbl  = main:FindFirstChild("Stored")

                    local cur_num = cur_lbl and tonumber(tostring(cur_lbl.Text):match("%-?%d+"))
                    local st_num  = st_lbl  and tonumber(tostring(st_lbl.Text):match("%-?%d+"))

                    return cur_num, st_num
                end)

                if ok and (current_ammo or stored_ammo) then
                    local needs_refill = false

                    if current_ammo then
                        local max_cur = AutoRefillAmmo.MaxCurrent[weapon_name]
                        if not max_cur or current_ammo > max_cur then
                            AutoRefillAmmo.MaxCurrent[weapon_name] = current_ammo
                        elseif (max_cur - current_ammo) >= 1 then
                            needs_refill = true
                        end
                    end

                    if stored_ammo then
                        local max_st = AutoRefillAmmo.MaxStored[weapon_name]
                        if not max_st or stored_ammo > max_st then
                            AutoRefillAmmo.MaxStored[weapon_name] = stored_ammo
                        elseif (max_st - stored_ammo) >= 1 then
                            needs_refill = true
                        end
                    end

                    if not needs_refill then
                        return 
                    end
                end
            end

            local open_event  = RepSt.Events:FindFirstChild("BYZERSPROTEC")
            local buy_event   = RepSt.Events:FindFirstChild("SSHPRMTE1")
            
            if not open_event or not buy_event then return end

            local shopz = workspace:FindFirstChild("Map") 
                and workspace.Map:FindFirstChild("Shopz")
            
            if not shopz then return end

            local closest_store = nil
            local closest_dist  = 15

            for _, store_folder in ipairs(shopz:GetChildren()) do
                local main_part = store_folder:FindFirstChild("MainPart")
                if main_part then
                    local dist = (hrp.Position - main_part.Position).Magnitude
                    if dist < closest_dist then
                        closest_dist = dist
                        local store_type = "IllegalStore"
                        if store_folder.Name:lower():find("armor") or store_folder.Name:lower():find("legal") then
                            store_type = "LegalStore"
                        end
                        closest_store = {
                            name = store_type,
                            main_part = main_part,
                            dist = dist,
                            folder = store_folder.Name
                        }
                    end
                end
            end

            if closest_store then
                local success, err = pcall(function()
                    open_event:FireServer()
                    buy_event:InvokeServer(closest_store.name, "Guns", weapon_name, closest_store.main_part, "ResupplyAmmo", true)
                    AutoRefillAmmo.LastRefill = tick()
                    
                    task.wait(0.1)
                    local backpack_weapon = LP.Backpack:FindFirstChild(weapon_name)
                    if backpack_weapon and char:FindFirstChild("Humanoid") then
                        char.Humanoid:EquipTool(backpack_weapon)
                    end
                end)
            end
        end)
    end,
})

local AutoBuy = { Enabled = false, Conn = nil, Item = "Beretta", LastBuy = 0 }

local AutoBuyDropdown = OtherSection:Dropdown({
    Name     = "Auto Buy Item",
    Flag     = "MiscAutoBuyItem",
    Options    = {"Beretta", "TEC-9"},
    Default  = "Beretta",
    Multi    = false,
    ToolTip  = {
        Name        = "Auto buy",
        Description = "Simple good for HvH",
    },
    Callback = function(selected)
        AutoBuy.Item = selected
    end
})

OtherSection:Toggle({
    Name     = "Auto Buy",
    Flag     = "MiscAutoBuy",
    Default  = false,
    Callback = function(state)
        AutoBuy.Enabled = state

        if AutoBuy.Conn then
            AutoBuy.Conn:Disconnect()
            AutoBuy.Conn = nil
        end

        if not state then return end

        AutoBuy.Conn = RS.Heartbeat:Connect(function()
            if not AutoBuy.Enabled then return end
            
            if tick() - AutoBuy.LastBuy < 1 then return end

            local char = LP.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local buy_event = RepSt.Events:FindFirstChild("SSHPRMTE1")
            if not buy_event then return end

            local shopz = workspace:FindFirstChild("Map") 
                and workspace.Map:FindFirstChild("Shopz")
            
            if not shopz then return end

            local closest_dealer = nil
            local closest_dist = 15

            for _, store_folder in ipairs(shopz:GetChildren()) do
                local main_part = store_folder:FindFirstChild("MainPart")
                if main_part then
                    local dist = (hrp.Position - main_part.Position).Magnitude
                    if dist < closest_dist then
                        closest_dist = dist
                        closest_dealer = main_part
                    end
                end
            end

            if closest_dealer then
                local item = AutoBuy.Item
                local categories = {"Melees", "Guns", "Throwables", "Misc"}
                local stores = {"IllegalStore", "LegalStore"}
                
                local success = false
                for _, store_type in ipairs(stores) do
                    for _, category in ipairs(categories) do
                        local ok, result = pcall(function()
                            return buy_event:InvokeServer(store_type, category, item, closest_dealer)
                        end)
                        if ok and result then
                            success = true
                            break
                        end
                    end
                    if success then break end
                end
                
                AutoBuy.LastBuy = tick()
            end
        end)
    end,
})

local AutoClaimAllowance = { Enabled = false, Conn = nil }

local function find_nearest_atm(max_distance)
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local map = workspace:FindFirstChild("Map")
    local atm_folder = map and map:FindFirstChild("ATMz")
    if not atm_folder then return nil end

    local closest_part, closest_dist = nil, max_distance
    for _, atm in ipairs(atm_folder:GetChildren()) do
        local main_part = atm:FindFirstChild("MainPart")
        if main_part then
            local distance = (hrp.Position - main_part.Position).Magnitude
            if distance < closest_dist then
                closest_dist  = distance
                closest_part  = main_part
            end
        end
    end

    return closest_part
end

OtherSection:Toggle({
    Name     = "Auto Claim Allowance",
    Flag     = "MiscAutoClaimAllowance",
    Default  = false,
    Callback = function(state)
        AutoClaimAllowance.Enabled = state

        if AutoClaimAllowance.Conn then
            AutoClaimAllowance.Conn:Disconnect()
            AutoClaimAllowance.Conn = nil
        end

        if not state then return end

        AutoClaimAllowance.Conn = RS.Heartbeat:Connect(function()
            if not AutoClaimAllowance.Enabled then return end

            local data = RepSt:FindFirstChild("PlayerbaseData2")
            local player_data = data and data:FindFirstChild(LP.Name)
            local next_allowance = player_data and player_data:FindFirstChild("NextAllowance")
            if not next_allowance or next_allowance.Value ~= 0 then return end

            local atm_part = find_nearest_atm(math.huge)
            if atm_part then
                RepSt.Events.CLMZALOW:InvokeServer(atm_part)
            end
        end)
    end,
})

local AB = {
    Enabled     = false,
    Blocking    = false,
    LastTrigger = 0,
    BlockCache  = {},
    Conn        = nil,
}

local function ab_get_remote()
    local ev = RepSt:FindFirstChild("Events")
    return ev and ev:FindFirstChild("XMHH.2")
end

local function ab_get_tick()
    local vals = RepSt:FindFirstChild("Values")
    return vals and vals:FindFirstChild("ServerTick")
end

local function ab_stop_block(tool)
    local remote = ab_get_remote()
    local st     = ab_get_tick()
    if remote and st then
        pcall(function()
            remote:InvokeServer("🍞", math.floor(st.Value - 81919), tool, "BZLZSTI2")
        end)
    end
    AB.Blocking = false
end

local function ab_start()
    if AB.Conn then AB.Conn:Disconnect() end

    AB.Conn = RS.Heartbeat:Connect(function()
        if not AB.Enabled then return end

        local char = LP.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local tool = char and char:FindFirstChildOfClass("Tool")

        if not tool or not hrp then
            if AB.Blocking then ab_stop_block(nil) end
            return
        end

        if AB.BlockCache[tool] == nil then
            local can = false
            pcall(function()
                local cfg = require(tool:FindFirstChild("Config"))
                if cfg and cfg.BlockSettings and cfg.BlockSettings.Enabled then can = true end
            end)
            if not can and tool:FindFirstChild("AnimsFolder") and tool.AnimsFolder:FindFirstChild("BlockStart") then
                can = true
            end
            if tool:GetAttribute("CanBlock") == false then can = false end
            AB.BlockCache[tool] = can
        end

        if not AB.BlockCache[tool] then
            if AB.Blocking then ab_stop_block(tool) end
            return
        end

        local shouldBlock = false
        for _, p in ipairs(Plrs:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local eHrp = p.Character.HumanoidRootPart
                if (eHrp.Position - hrp.Position).Magnitude <= 15 then
                    local eTool = p.Character:FindFirstChildOfClass("Tool")
                    if eTool and not (eTool:GetAttribute("Unblockable") or eTool:GetAttribute("IgnoreBlock")) then
                        local attacking = false
                        local v = eTool:FindFirstChild("Values")
                        if v then
                            if (v:FindFirstChild("Slashing1") and v.Slashing1.Value) or
                               (v:FindFirstChild("Attacking") and v.Attacking.Value) then
                                attacking = true
                            else
                                for _, val in ipairs(v:GetChildren()) do
                                    if val.Name:find("Slashing") and val.Value == true then
                                        attacking = true; break
                                    end
                                end
                            end
                        end
                        if not attacking then
                            local h = p.Character:FindFirstChildOfClass("Humanoid")
                            if h then
                                for _, t in ipairs(h:GetPlayingAnimationTracks()) do
                                    local n = t.Name:lower()
                                    if n:find("slash") or n:find("swing") or n:find("attack") or
                                       n:find("lunge") or n:find("heavy") then
                                        attacking = true; break
                                    end
                                end
                            end
                        end
                        if attacking then shouldBlock = true; break end
                    end
                end
            end
        end

        if shouldBlock then
            AB.LastTrigger = tick()
            if not AB.Blocking then
                AB.Blocking = true
                task.spawn(function()
                    local remote = ab_get_remote()
                    local st     = ab_get_tick()
                    local t      = tool
                    while AB.Blocking and AB.Enabled and char and t.Parent == char do
                        if remote and st then
                            pcall(function()
                                remote:InvokeServer("🍞", math.floor(st.Value - 81919), t, "BLSTAX1")
                            end)
                        end
                        task.wait(0.1)
                        if tick() - AB.LastTrigger > 0.2 then break end
                    end
                    if AB.Blocking then ab_stop_block(t) end
                end)
            end
        elseif AB.Blocking and tick() - AB.LastTrigger > 0.2 then
            ab_stop_block(tool)
        end
    end)
end

local function ab_stop()
    AB.Enabled = false
    if AB.Conn then AB.Conn:Disconnect(); AB.Conn = nil end
    local char = LP.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if AB.Blocking then ab_stop_block(tool) end
    AB.BlockCache = {}
end

OtherSection:Toggle({
    Name     = "Auto Block",
    Flag     = "MiscAutoBlock",
    Default  = false,
    Callback = function(state)
        if state then
            AB.Enabled = true
            ab_start()
        else
            ab_stop()
        end
    end,
})

local SecuritySection = MiscPage:Section({Name = "Security", Side = "Right"})

local PublicNameSpoof = {
    Enabled     = false,
    FakeName    = LP.Name,
    FakeDisplay = LP.DisplayName,
    Conns       = {},
}

local function PNS_GetDisplay()
    return PublicNameSpoof.FakeDisplay
end

local function PNS_GetName()
    return PublicNameSpoof.FakeName
end

local function PNS_SpoofTextObj(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
    local function apply()
        local text = obj.Text
        if text == "" then return end
        local targetDisplay = PNS_GetDisplay()
        local targetName    = PNS_GetName()
        local realDisplay   = LP.DisplayName
        local realName      = LP.Name
        if text:find(targetDisplay, 1, true) then return end
        local newText = text
        if newText:find(realDisplay, 1, true) then
            newText = newText:gsub(realDisplay, targetDisplay)
        end
        if newText:find(realName, 1, true) then
            newText = newText:gsub(realName, targetName)
        end
        if newText ~= obj.Text then
            obj.Text = newText
        end
    end
    apply()
    local c = obj:GetPropertyChangedSignal("Text"):Connect(apply)
    table.insert(PublicNameSpoof.Conns, c)
end

local function PNS_MonitorBillboard(billboard)
    for _, obj in ipairs(billboard:GetDescendants()) do
        if obj:IsA("TextLabel") then
            local targetDisplay = PNS_GetDisplay()
            local function apply()
                if obj.Text ~= targetDisplay then obj.Text = targetDisplay end
            end
            apply()
            local c = obj:GetPropertyChangedSignal("Text"):Connect(apply)
            table.insert(PublicNameSpoof.Conns, c)
        end
    end
    local c2 = billboard.DescendantAdded:Connect(function(obj)
        if obj:IsA("TextLabel") then
            local targetDisplay = PNS_GetDisplay()
            obj.Text = targetDisplay
            local c = obj:GetPropertyChangedSignal("Text"):Connect(function()
                if obj.Text ~= PNS_GetDisplay() then obj.Text = PNS_GetDisplay() end
            end)
            table.insert(PublicNameSpoof.Conns, c)
        end
    end)
    table.insert(PublicNameSpoof.Conns, c2)
end

local function PNS_MonitorChar(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
        or char:WaitForChild("Humanoid", 5)
    if humanoid then
        local function applyHum()
            local d = PNS_GetDisplay()
            if humanoid.DisplayName ~= d then humanoid.DisplayName = d end
        end
        applyHum()
        local c = humanoid:GetPropertyChangedSignal("DisplayName"):Connect(applyHum)
        table.insert(PublicNameSpoof.Conns, c)
    end
    task.wait(0.3)
    for _, bb in ipairs(char:GetDescendants()) do
        if bb:IsA("BillboardGui") then
            PNS_MonitorBillboard(bb)
        end
    end
end

local function PNS_Enable()
    PublicNameSpoof.Enabled = true

    
    for _, obj in ipairs(LP.PlayerGui:GetDescendants()) do
        PNS_SpoofTextObj(obj)
    end
    local c1 = LP.PlayerGui.DescendantAdded:Connect(PNS_SpoofTextObj)
    table.insert(PublicNameSpoof.Conns, c1)

    
    pcall(function()
        local cg = game:GetService("CoreGui")
        for _, obj in ipairs(cg:GetDescendants()) do
            PNS_SpoofTextObj(obj)
        end
        local c = cg.DescendantAdded:Connect(PNS_SpoofTextObj)
        table.insert(PublicNameSpoof.Conns, c)
    end)

    
    if LP.Character then PNS_MonitorChar(LP.Character) end
    local c2 = LP.CharacterAdded:Connect(function(char)
        if not PublicNameSpoof.Enabled then return end
        task.wait(0.5)
        PNS_MonitorChar(char)
    end)
    table.insert(PublicNameSpoof.Conns, c2)

    
    pcall(function()
        local realName    = LP.Name
        local realDisplay = LP.DisplayName
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BillboardGui") then
                for _, t in ipairs(obj:GetDescendants()) do
                    if t:IsA("TextLabel") then
                        local txt = t.Text
                        if txt:find(realName, 1, true) or txt:find(realDisplay, 1, true) then
                            PNS_MonitorBillboard(obj)
                            break
                        end
                    end
                end
            end
        end
        local c = workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("BillboardGui") then
                task.wait(0.3)
                for _, t in ipairs(obj:GetDescendants()) do
                    if t:IsA("TextLabel") then
                        local txt = t.Text
                        if txt:find(LP.Name, 1, true) or txt:find(LP.DisplayName, 1, true) then
                            PNS_MonitorBillboard(obj)
                            break
                        end
                    end
                end
            end
        end)
        table.insert(PublicNameSpoof.Conns, c)
    end)

    
    pcall(function()
        local TCS = game:GetService("TextChatService")
        if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
            TCS.OnIncomingMessage = function(msg)
                local props = Instance.new("TextChatMessageProperties")
                if msg.TextSource and msg.TextSource.UserId == LP.UserId then
                    props.PrefixText = PNS_GetDisplay()
                end
                return props
            end
        end
    end)
end

local function PNS_Disable()
    PublicNameSpoof.Enabled = false
    for _, c in ipairs(PublicNameSpoof.Conns) do
        pcall(function() c:Disconnect() end)
    end
    PublicNameSpoof.Conns = {}

    
    pcall(function()
        local char = LP.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.DisplayName = LP.DisplayName end
    end)

    
    pcall(function()
        local TCS = game:GetService("TextChatService")
        if TCS.ChatVersion == Enum.ChatVersion.TextChatService then
            TCS.OnIncomingMessage = nil
        end
    end)
end

SecuritySection:Toggle({
    Name     = "Public Name Spoof",
    Flag     = "SecPublicNameSpoof",
    Default  = false,
    Callback = function(state)
        if state then PNS_Enable() else PNS_Disable() end
    end,
})

SecuritySection:Textbox({
    Name        = "Fake Name",
    Flag        = "SecPublicFakeName",
    PlaceHolder = LP.Name,
    Default     = LP.Name,
    Callback    = function(text)
        PublicNameSpoof.FakeName = text ~= "" and text or LP.Name
    end,
})

SecuritySection:Textbox({
    Name        = "Fake Display Name",
    Flag        = "SecPublicFakeDisplay",
    PlaceHolder = LP.DisplayName,
    Default     = LP.DisplayName,
    Callback    = function(text)
        PublicNameSpoof.FakeDisplay = text ~= "" and text or LP.DisplayName
    end,
})

local function spoof_lock(key, get_obj, prop, get_val, connections_tbl)
    if connections_tbl[key] then
        connections_tbl[key]:Disconnect()
        connections_tbl[key] = nil
    end
    connections_tbl[key .. "_active"] = true
    connections_tbl[key .. "_get"]    = get_obj
    connections_tbl[key .. "_prop"]   = prop

    local function try_save_orig()
        if connections_tbl[key .. "_orig"] ~= nil then return end
        pcall(function()
            local obj = get_obj()
            if obj then
                connections_tbl[key .. "_orig"] = obj[prop]
            end
        end)
    end

    local function apply()
        pcall(function()
            local obj = get_obj()
            if not obj then return end
            
            if connections_tbl[key .. "_orig"] == nil then
                connections_tbl[key .. "_orig"] = obj[prop]
            end
            local val = get_val()
            if obj[prop] ~= val then obj[prop] = val end
        end)
    end

    try_save_orig()
    apply()

    pcall(function()
        local obj = get_obj()
        if obj then
            connections_tbl[key] = obj:GetPropertyChangedSignal(prop):Connect(apply)
        end
    end)

    task.spawn(function()
        while connections_tbl[key .. "_active"] do
            task.wait(0.5)
            
            
            
            if not connections_tbl[key .. "_active"] then break end
            apply()
            if not connections_tbl[key] then
                pcall(function()
                    local obj = get_obj()
                    if obj then
                        connections_tbl[key] = obj:GetPropertyChangedSignal(prop):Connect(apply)
                    end
                end)
            end
        end
    end)
end

local function spoof_stop(key, connections_tbl)
    connections_tbl[key .. "_active"] = nil
    if connections_tbl[key] then
        connections_tbl[key]:Disconnect()
        connections_tbl[key] = nil
    end
    
    local get_obj = connections_tbl[key .. "_get"]
    local prop    = connections_tbl[key .. "_prop"]
    local orig    = connections_tbl[key .. "_orig"]
    if get_obj and prop and orig ~= nil then
        pcall(function()
            local obj = get_obj()
            if obj then obj[prop] = orig end
        end)
    end
    connections_tbl[key .. "_orig"] = nil
    connections_tbl[key .. "_get"]  = nil
    connections_tbl[key .. "_prop"] = nil
end

local sec_conns = {}  

local XPSpoof = { Enabled = false, Text = "99999 / 99999 XP" }
SecuritySection:Toggle({
    Name     = "Spoof XP Bar",
    Flag     = "SecSpoofXP",
    Default  = false,
    Callback = function(state)
        XPSpoof.Enabled = state
        if state then
            spoof_lock("xp", function()
                    return LP.PlayerGui:FindFirstChild("CoreGUI")
                        and LP.PlayerGui.CoreGUI:FindFirstChild("LevelFrame")
                        and LP.PlayerGui.CoreGUI.LevelFrame:FindFirstChild("Bar")
                        and LP.PlayerGui.CoreGUI.LevelFrame.Bar:FindFirstChild("Stat")
                end, "Text", function() return XPSpoof.Text end, sec_conns)
        else
            spoof_stop("xp", sec_conns)
        end
    end,
})
SecuritySection:Textbox({
    Name        = "XP Text",
    Flag        = "SecSpoofXPText",
    PlaceHolder = "99999 / 99999 XP",
    Default     = "99999 / 99999 XP",
    Callback    = function(text)
        XPSpoof.Text = text
    end,
})

local LevelSpoof = { Enabled = false, Text = "999" }
SecuritySection:Toggle({
    Name     = "Spoof Level HUD",
    Flag     = "SecSpoofLevelHUD",
    Default  = false,
    Callback = function(state)
        LevelSpoof.Enabled = state
        if state then
            spoof_lock("lvl_hud", function()
                    return LP.PlayerGui:FindFirstChild("CoreGUI")
                        and LP.PlayerGui.CoreGUI:FindFirstChild("LevelFrame")
                        and LP.PlayerGui.CoreGUI.LevelFrame:FindFirstChild("LevelBox")
                        and LP.PlayerGui.CoreGUI.LevelFrame.LevelBox:FindFirstChild("LevelNumber")
                end, "Text", function() return LevelSpoof.Text end, sec_conns)
        else
            spoof_stop("lvl_hud", sec_conns)
        end
    end,
})
SecuritySection:Textbox({
    Name        = "Level Text",
    Flag        = "SecSpoofLevelHUDText",
    PlaceHolder = "999",
    Default     = "999",
    Callback    = function(text)
        LevelSpoof.Text = text
    end,
})

local LBSpoof = { Enabled = false, Value = 999, conn = nil }

local function lb_get_stat()
    local ls = LP:FindFirstChild("leaderstats")
    return ls and ls:FindFirstChild("Level")
end

local function lb_apply()
    local stat = lb_get_stat()
    if not stat then return end
    pcall(function() stat.Value = LBSpoof.Value end)
end

local function lb_start()
    lb_apply()
    local stat = lb_get_stat()
    if stat then
        LBSpoof.conn = stat:GetPropertyChangedSignal("Value"):Connect(function()
            if LBSpoof.Enabled then
                task.defer(lb_apply)  
            end
        end)
    end
end

local function lb_stop()
    if LBSpoof.conn then LBSpoof.conn:Disconnect(); LBSpoof.conn = nil end
    
    
end

SecuritySection:Toggle({
    Name     = "Leaderboard Level",
    Flag     = "SecLBLevel",
    Default  = false,
    Callback = function(state)
        LBSpoof.Enabled = state
        if state then lb_start() else lb_stop() end
    end,
})
SecuritySection:Textbox({
    Name        = "Level Value",
    Flag        = "SecLBLevelValue",
    PlaceHolder = "999",
    Default     = "999",
    Callback    = function(text)
        local n = tonumber(text)
        if n then
            LBSpoof.Value = math.floor(n)
            if LBSpoof.Enabled then lb_apply() end
        end
    end,
})

Playerlist = PlayersPage:PlayerList({})

local function SyncPlayerlist()
    local present = {}
    for _, plr in Plrs:GetPlayers() do
        present[plr.Name] = true
        if not Playerlist.Players[plr.Name] then
            Playerlist.AddPlayer(plr)
        end
    end

    for name, entry in pairs(Playerlist.Players) do
        if not present[name] then
            if entry.Background then entry.Background:Destroy() end
            Playerlist.Players[name] = nil
        end
    end
end

Plrs.PlayerAdded:Connect(function(plr)
    if not Playerlist.Players[plr.Name] then
        Playerlist.AddPlayer(plr)
    end
end)

Plrs.PlayerRemoving:Connect(function(plr)
    local entry = Playerlist.Players[plr.Name]
    if entry then
        if entry.Background then entry.Background:Destroy() end
        Playerlist.Players[plr.Name] = nil
    end
end)

if Playerlist.Items and Playerlist.Items.Refresh then
    Playerlist.Items.Refresh.MouseButton1Click:Connect(SyncPlayerlist)
end

local FovLimitToggle

local RageBotToggle = CombatSection:Toggle({
    Name     = "Enable Rage Bot",
    Flag     = "RageBotToggle",
    Default  = false,
    ToolTip  = {
        Name        = "Rage Bot",
        Description = "Automatically shoots at enemies in FOV",
    },
    Callback = function(state)
        RB.Enabled = state

        local events              = RepSt:FindFirstChild("Events")
        local start_shoot_event   = events and events:FindFirstChild("GNX_S")
        local finish_shoot_event  = events and events:FindFirstChild("ZFKLF__H")

        if RB.Enabled and not (start_shoot_event and finish_shoot_event) then
            RB.Enabled = false
            Notify("Rage Bot", "Required remotes not found, cannot enable", 3)
            return
        end

        if not RB.Enabled then
            if RB.FovUpdateConn then
                RB.FovUpdateConn:Disconnect()
                RB.FovUpdateConn = nil
            end
            if RB.FovCircle then
                RB.FovCircle:Remove()
                RB.FovCircle = nil
            end
            if RB.TargetLineConn then
                RB.TargetLineConn:Disconnect()
                RB.TargetLineConn = nil
            end
            if RB.TargetLineObj then
                RB.TargetLineObj:Remove()
                RB.TargetLineObj = nil
            end

            local my_humanoid = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if my_humanoid then
                Cam.CameraSubject = my_humanoid
            end

            Notify("Rage Bot", "Rage Bot disabled", 2)
        else
            if RB.FovCircle then RB.FovCircle:Remove() end
            if RB.TargetLineObj then RB.TargetLineObj:Remove() end
            RB.TargetLineObj = Drawing.new("Line")
            RB.TargetLineObj.Thickness = 1
            RB.TargetLineObj.Color = RB.TargetLineColor or Color3.new(1,0,0)
            RB.FovCircle           = Drawing.new("Circle")
            RB.FovCircle.Thickness = 1
            RB.FovCircle.Filled    = false
            RB.FovCircle.Visible   = (RB.ShowFov and RB.FovLimit) or false
            RB.FovCircle.NumSides  = 64
            RB.FovCircle.Radius    = RB.FovRadius or 150
            RB.FovCircle.Color     = RB.FovColor or Color3.new(1, 1, 1)
            local mp = UIS:GetMouseLocation()
            RB.FovCircle.Position  = Vector2.new(mp.X, mp.Y)

            if RB.FovUpdateConn then RB.FovUpdateConn:Disconnect() end
            RB.FovUpdateConn = RS.RenderStepped:Connect(function()
                if RB.FovCircle then
                    local mp = UIS:GetMouseLocation()
                    RB.FovCircle.Position = Vector2.new(mp.X, mp.Y)
                    RB.FovCircle.Radius   = RB.FovRadius or 150
                    RB.FovCircle.Color    = RB.FovColor or Color3.new(1, 1, 1)
                    RB.FovCircle.Visible  = (RB.ShowFov and RB.FovLimit) or false
                end
            end)

            local function generate_random_string(length)
                local result = ""
                for i = 1, length do
                    result = result .. string.char(math.random(97, 122))
                end
                return result
            end

            local function has_marked_enemies()
                if not (Playerlist and Playerlist.Players) then return false end
                for _, entry in pairs(Playerlist.Players) do
                    if entry.Priority and entry.Priority.Text == "Enemy" then
                        return true
                    end
                end
                return false
            end

            local function find_closest_target()
                local my_hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if not my_hrp then return nil end

                local has_enemies = has_marked_enemies()
                local mouse_pos   = UIS:GetMouseLocation()

                
                local function is_hittable(player)
                    local char = player.Character
                    if not char then return false end
                    local hum  = char:FindFirstChildOfClass("Humanoid")
                    if not hum then return false end
                    
                    if RB.CheckDead and hum.Health <= 0 then return false end
                    
                    if char:FindFirstChildOfClass("ForceField") then return false end
                    
                                        if RB.CheckDowned then
                        local char_stats = RepSt:FindFirstChild("CharStats")
                        local p_stats = char_stats and char_stats:FindFirstChild(player.Name)
                        local downed = p_stats and p_stats:FindFirstChild("Downed")
                        if downed and downed.Value == true then return false end
                    end
                    return true
                end

                local function screen_dist(head)
                    local sp, on = Cam:WorldToViewportPoint(head.Position)
                    if not on then return math.huge end
                    return (Vector2.new(sp.X, sp.Y) - mouse_pos).Magnitude
                end

                if has_enemies then
                    
                    local locked = RB.LockedEnemyTarget
                    if locked and locked.Parent and Plrs:FindFirstChild(locked.Name) == locked
                        and get_player_status(locked) == "Enemy"
                        and is_hittable(locked) then
                        return locked
                    end

                    
                    RB.LockedEnemyTarget = nil

                    
                    local my_pos    = my_hrp.Position
                    local candidates = {}
                    for _, player in ipairs(Plrs:GetPlayers()) do
                        if player ~= LP and get_player_status(player) == "Enemy" then
                            local char = player.Character
                            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                            local head = char and char:FindFirstChild("Head")
                            if hrp and head then
                                local hittable  = is_hittable(player)
                                local sp, on    = Cam:WorldToViewportPoint(head.Position)
                                local worldDist = (my_pos - hrp.Position).Magnitude
                                local scrDist   = on and (Vector2.new(sp.X, sp.Y) - mouse_pos).Magnitude or math.huge
                                table.insert(candidates, {
                                    player    = player,
                                    hittable  = hittable,
                                    worldDist = worldDist,
                                    scrDist   = scrDist,
                                    on        = on,
                                })
                            end
                        end
                    end

                    
                    
                    
                    table.sort(candidates, function(a, b)
                        local function score(c)
                            if not c.hittable then return 2 end
                            return c.on and 0 or 1
                        end
                        local sa, sb = score(a), score(b)
                        if sa ~= sb then return sa < sb end
                        return a.worldDist < b.worldDist
                    end)

                    
                    for _, c in ipairs(candidates) do
                        if c.hittable then
                            RB.LockedEnemyTarget = c.player
                            return c.player
                        end
                    end

                    return nil
                end

                
                RB.LockedEnemyTarget = nil

                local fov_target, fov_dist = nil, math.huge

                for _, player in ipairs(Plrs:GetPlayers()) do
                    if player ~= LP then
                        local character = player.Character
                        local humanoid  = character and character:FindFirstChildOfClass("Humanoid")
                        local root_part = character and character:FindFirstChild("HumanoidRootPart")
                        local head      = character and character:FindFirstChild("Head")
                        local status    = get_player_status(player)
                                                local char_stats = RepSt:FindFirstChild("CharStats")
                        local p_stats = char_stats and char_stats:FindFirstChild(player.Name)
                        local downed = p_stats and p_stats:FindFirstChild("Downed")
                        local isDown = downed and downed.Value == true
                        local valid = root_part and humanoid and head
                            and (not RB.CheckDead or humanoid.Health > 0)
                            and (not RB.CheckDowned or not isDown)
                            and not character:FindFirstChildOfClass("ForceField")
                            and (not RB.CheckTeam or LP.Team ~= player.Team)
                            and status ~= "Friendly"

                        if valid then
                            local sp, on_screen = Cam:WorldToViewportPoint(head.Position)
                            if on_screen then
                                local dist = (Vector2.new(sp.X, sp.Y) - mouse_pos).Magnitude
                                if (not RB.FovLimit or dist <= (RB.FovRadius or 150)) and dist < fov_dist then
                                    fov_dist = dist
                                    fov_target = player
                                end
                            end
                        end
                    end
                end

                return fov_target
            end

            local function get_random_sphere_offsets(point_amount, radius)
                local positions = {}
                local two_pi = math.pi * 2

                for i = 1, point_amount do
                    local distance        = radius * (math.random() ^ (1 / 3))
                    local cosine          = math.random() * 2 - 1
                    local sine_component  = distance * ((1 - cosine * cosine) ^ 0.5)
                    local theta           = math.random() * two_pi

                    positions[i] = Vector3.new(
                        sine_component * math.cos(theta),
                        sine_component * math.sin(theta),
                        distance * cosine
                    )
                end

                return positions
            end

            local CARDINAL_DIRECTIONS = {
                Vector3.new(0, 1, 0),
                Vector3.new(0, -1, 0),
                Vector3.new(0, 0, 1),
                Vector3.new(0, 0, -1),
                Vector3.new(1, 0, 0),
                Vector3.new(-1, 0, 0),
            }

            local function get_cardinal_offsets(point_amount, radius)
                local positions      = {}
                local cardinal_index = 1

                for i = 1, point_amount do
                    positions[i]  = CARDINAL_DIRECTIONS[cardinal_index] * radius
                    cardinal_index = cardinal_index % 6 + 1
                end

                return positions
            end

            
            
            
            
            local function get_hammersley_offsets(point_amount, radius)
                local pts    = { Vector3.new(0, 0, 0) } 
                local twoPi  = math.pi * 2

                for i = 1, point_amount do
                    
                    local b = 0.5
                    local v = 0
                    local k = i
                    while k > 0 do
                        if k % 2 == 1 then v = v + b end
                        k = math.floor(k / 2)
                        b = b * 0.5
                    end

                    local u     = i / point_amount          
                    local theta = twoPi * v                  
                    local phi   = math.acos(1 - 2 * u)      

                    local sin_phi = math.sin(phi)
                    pts[#pts + 1] = Vector3.new(
                        radius * sin_phi * math.cos(theta),
                        radius * math.cos(phi),
                        radius * sin_phi * math.sin(theta)
                    )
                end

                return pts
            end

            local function generate_femboy_fibonacci_offsets(radius, num_points)
                local offsets = {}
                local phi = (1 + math.sqrt(5)) / 2
                local angle_increment = math.pi * 2 * phi
                for i = 0, num_points - 1 do
                    local t = i / num_points
                    local inclination = math.acos(1 - 2 * t)
                    local azimuth = angle_increment * i
                    local x = math.sin(inclination) * math.cos(azimuth)
                    local y = math.sin(inclination) * math.sin(azimuth)
                    local z = math.cos(inclination)
                    offsets[#offsets + 1] = Vector3.new(x * radius, y * radius, z * radius)
                end
                return offsets
            end


            local function is_femboy_path_clear(from_pos, to_pos, ignore_list)
                local direction = (to_pos - from_pos)
                local rp = RaycastParams.new()
                rp.FilterType = Enum.RaycastFilterType.Exclude
                rp.FilterDescendantsInstances = ignore_list
                rp.IgnoreWater = true
                return workspace:Raycast(from_pos, direction.Unit * direction.Magnitude, rp) == nil
            end

            local function raycast_function(origin, direction)
                local rp = RaycastParams.new()
                rp.FilterType = Enum.RaycastFilterType.Exclude
                rp.FilterDescendantsInstances = { Cam, LP.Character }
                rp.IgnoreWater = true
                return workspace:Raycast(origin, direction, rp)
            end

            
            local find_tphit_target = find_closest_target

            task.spawn(function()
                while RB.Enabled do
                    if not RB.TPHit then
                        RS.RenderStepped:Wait()
                        continue
                    end

                    local target_player = find_tphit_target()
                    local my_char = LP.Character
                    local my_hrp  = my_char and my_char:FindFirstChild("HumanoidRootPart")

                    if target_player and target_player.Character and my_hrp then
                        local target_char = target_player.Character
                        local target_hrp  = target_char:FindFirstChild("HumanoidRootPart")
                        
                        if target_hrp and not target_char:FindFirstChildOfClass("ForceField") then
                            local tp_cf = CFrame.new(
                                target_hrp.Position - (target_hrp.CFrame.LookVector * 3),
                                target_hrp.Position
                            )
                            my_hrp.CFrame = tp_cf
                        end
                    end

                    RS.RenderStepped:Wait()
                end
            end)

            task.spawn(function()
                while RB.Enabled do
                    if not RB.SkyboxBullet then
                        RS.RenderStepped:Wait()
                        continue
                    end

                    local target_player = find_tphit_target()
                    local my_char = LP.Character
                    local my_hrp  = my_char and my_char:FindFirstChild("HumanoidRootPart")

                    if target_player and target_player.Character and my_hrp then
                        local target_hrp = target_player.Character:FindFirstChild("HumanoidRootPart")
                        
                        if target_hrp and not target_player.Character:FindFirstChildOfClass("ForceField") then
                            local look  = target_hrp.CFrame.LookVector
                            local right = target_hrp.CFrame.RightVector

                            local offset
                            if RB.SkyboxBulletMode == "Custom" then
                                offset = right * RB.SkyboxBulletCustomRight
                                    + Vector3.new(0, RB.SkyboxBulletCustomHeight, 0)
                                    + look * RB.SkyboxBulletCustomForward
                            elseif RB.SkyboxBulletMode == "Random" then
                                local now = tick()
                                if now - RB.SkyboxBulletLastSwitch >= RB.SkyboxBulletInterval then
                                    RB.SkyboxBulletLastSwitch = now
                                    RB.SkyboxBulletRandomOffset = Vector3.new(
                                        math.random(-100, 100) / 100,
                                        math.random(-100, 100) / 100,
                                        math.random(-100, 100) / 100
                                    )
                                end

                                local H = RB.SkyboxBulletHeight
                                local D = RB.SkyboxBulletOffset
                                local r = RB.SkyboxBulletRandomOffset
                                offset = (right * D * r.X) + (look * D * r.Z) + Vector3.new(0, H * (0.5 + r.Y * 0.5), 0)
                            else
                                local now = tick()
                                if now - RB.SkyboxBulletLastSwitch >= RB.SkyboxBulletInterval then
                                    RB.SkyboxBulletLastSwitch = now
                                    RB.SkyboxBulletSide = (math.random(0, 1) == 0) and -1 or 1
                                end

                                local H = RB.SkyboxBulletHeight
                                local D = RB.SkyboxBulletOffset
                                offset = (right * D * RB.SkyboxBulletSide) + Vector3.new(0, H * 0.5, 0)
                            end

                            my_hrp.CFrame = CFrame.new(target_hrp.Position + offset, target_hrp.Position)
                        end
                    end

                    RS.RenderStepped:Wait()
                end
            end)

            task.spawn(function()
                while RB.Enabled do
                    local target_player = find_closest_target()
                    if target_player then
                        local target_char = target_player.Character
                        if target_char then
                            local target_head     = target_char:FindFirstChild("Head")
                            local target_humanoid = target_char:FindFirstChildOfClass("Humanoid")
                            if target_head and target_humanoid and (not RB.CheckDead or target_humanoid.Health > 0) then
                                local local_char = LP.Character
                                if local_char then
                                    local local_hrp  = local_char:FindFirstChild("HumanoidRootPart")
                                    local local_tool = local_char:FindFirstChildOfClass("Tool")
                                    if local_hrp and local_tool then
                                        local tool_values = local_tool:FindFirstChild("Values")
                                        local hitmarker   = local_tool:FindFirstChild("Hitmarker")
                                        if tool_values and hitmarker then
                                            local server_ammo  = tool_values:FindFirstChild("SERVER_Ammo")
                                            local stored_ammo  = tool_values:FindFirstChild("SERVER_StoredAmmo")
                                            if server_ammo and stored_ammo and server_ammo.Value > 0 then

                                                local priority_parts = {}
                                                for _, name in ipairs({"Head", "UpperTorso", "HumanoidRootPart", "Torso"}) do
                                                    local p = target_char:FindFirstChild(name)
                                                    if p then table.insert(priority_parts, p) end
                                                end

                                                local hit_found = false
                                                local direction_vector
                                                local random_origin = local_hrp.Position
                                                local hit_part_name = "Body"
                                                local head_position = target_head.Position
                                                local final_hit_pos = nil

                                                if RB.SphereMode == "Femboy Fibonacci" then
                                                    local R = math.clamp(RB.SphereRadius or 19, 1, 19)
                                                    local femboy_offsets = generate_femboy_fibonacci_offsets(R, 40)
                                                    table.insert(femboy_offsets, 1, Vector3.new(0, 0, 0))
                                                    local femboy_ignore = { Cam, LP.Character, target_char }

                                                    for _, shoot_offset in ipairs(femboy_offsets) do
                                                        if hit_found then break end
                                                        local shoot_pos = local_hrp.Position + shoot_offset
                                                        for _, part in ipairs(priority_parts) do
                                                            if hit_found then break end
                                                            for _, hit_offset in ipairs(femboy_offsets) do
                                                                local hit_pos = part.Position + hit_offset
                                                                if is_femboy_path_clear(shoot_pos, hit_pos, femboy_ignore) then
                                                                    random_origin    = shoot_pos
                                                                    final_hit_pos    = hit_pos
                                                                    direction_vector = (hit_pos - shoot_pos).Unit * 1000
                                                                    hit_found        = true
                                                                    hit_part_name    = part.Name
                                                                    break
                                                                end
                                                            end
                                                        end
                                                    end
                                                else
                                                local offsets = (function()
                                                    local R = math.clamp(RB.SphereRadius or 19, 1, 19)
                                                    local N = 19

                                                    if RB.SphereMode == "Vector" then
                                                        local pts = {}
                                                        for _ = 1, N do
                                                            pts[#pts + 1] = Vector3.new(
                                                                math.random(-18, 18),
                                                                math.random(-18, 18),
                                                                math.random(-18, 18)
                                                            )
                                                        end
                                                        return pts
                                                    end

                                                    if RB.SphereMode == "Random" then
                                                        local pts = { Vector3.new(0, 0, 0), Vector3.new(0, R, 0) }
                                                        for _, point in ipairs(get_random_sphere_offsets(N, R)) do
                                                            pts[#pts + 1] = point
                                                        end
                                                        return pts
                                                    end

                                                    if RB.SphereMode == "Cardinals" then
                                                        local pts = { Vector3.new(0, 0, 0), Vector3.new(0, R, 0) }
                                                        for _, point in ipairs(get_cardinal_offsets(N, R)) do
                                                            pts[#pts + 1] = point
                                                        end
                                                        return pts
                                                    end

                                                    if RB.SphereMode == "Hammersley" then
                                                        return get_hammersley_offsets(N, R)
                                                    end

                                                    local phi   = (1 + math.sqrt(5)) * 0.5
                                                    local twoPi = math.pi * 2

                                                    local rim = {}
                                                    for i = 0, N - 1 do
                                                        local t     = (i + 0.5) / N
                                                        local y     = 1 - t
                                                        local r     = math.sqrt(1 - y * y)
                                                        local theta = twoPi * i / phi
                                                        local x     = r * math.cos(theta)
                                                        local z     = r * math.sin(theta)
                                                        rim[#rim + 1] = { pos = Vector3.new(x * R, y * R, z * R), r = r }
                                                    end

                                                    table.sort(rim, function(a, b) return a.r > b.r end)

                                                    local pts = { Vector3.new(0, 0, 0), Vector3.new(0, R, 0) }
                                                    for _, point in ipairs(rim) do
                                                        pts[#pts + 1] = point.pos
                                                    end

                                                    local M = 19
                                                    local lower_rim = {}
                                                    for i = 0, M - 1 do
                                                        local t     = (i + 0.5) / M
                                                        local y     = -(1 - t)
                                                        local r     = math.sqrt(1 - y * y)
                                                        local theta = twoPi * i / phi
                                                        local x     = r * math.cos(theta)
                                                        local z     = r * math.sin(theta)
                                                        lower_rim[#lower_rim + 1] = { pos = Vector3.new(x * R, y * R, z * R), r = r }
                                                    end
                                                    table.sort(lower_rim, function(a, b) return a.r > b.r end)

                                                    pts[#pts + 1] = Vector3.new(0, -R, 0)
                                                    for _, point in ipairs(lower_rim) do
                                                        pts[#pts + 1] = point.pos
                                                    end

                                                    return pts
                                                end)()

                                                for _, offset in ipairs(offsets) do
                                                    if hit_found then break end
                                                    local candidate_origin = local_hrp.Position + offset
                                                    for _, part in ipairs(priority_parts) do
                                                        local hit_pos     = part.Position
                                                        local to_hit      = hit_pos - candidate_origin
                                                        local unit_dir    = to_hit.Unit
                                                        local ray_result  = raycast_function(candidate_origin, to_hit)
                                                        local path_clear
                                                        if not ray_result then
                                                            path_clear = true
                                                        else
                                                            path_clear = ray_result.Instance:IsDescendantOf(target_char)
                                                        end

                                                        if path_clear then
                                                            random_origin    = candidate_origin
                                                            direction_vector = unit_dir * 1000
                                                            hit_found        = true
                                                            hit_part_name    = part.Name
                                                            break
                                                        end
                                                    end
                                                end
                                                end -- close Femboy vs others if/else

                                                if hit_found then
                                                    local random_id = generate_random_string(30) .. 0
                                                    start_shoot_event:FireServer(tick(), random_id, local_tool, "FDS9I83", random_origin, { direction_vector }, false)

                                                 
                                                    local hit_pos_to_send = (RB.SphereMode == "Femboy Fibonacci" and final_hit_pos) or target_head.Position

                                                    if BB.On then
                                                        crTracer(random_origin, hit_pos_to_send, BB.Col)
                                                    end

                                                    local delay_time = (1 - (RB.FireRate or 50) / 100) * 0.2
                                                    task.wait(delay_time)

                                                    finish_shoot_event:FireServer("\240\159\167\136", local_tool, random_id, 1, target_head, hit_pos_to_send, direction_vector)
                                                   
                                                    RepSt.Events.GNX_R:FireServer(tick(), "KLWE89U0", local_tool)

                                                    if HitLogSett.On and (tick() - HitLogSett.LastLogTime) >= HitLogSett.MinInterval then
                                                        HitLogSett.LastLogTime = tick()
                                                        local hit_dist = (local_hrp.Position - target_head.Position).Magnitude
                                                        local msg = string.format(
                                                            "[%s] hit %s | HP: %d | Dist: %dst",
                                                            hit_part_name,
                                                            target_player.Name,
                                                            math.max(target_humanoid.Health, 0),
                                                            math.round(hit_dist)
                                                        )
                                                        if HitLogSett.Method == "Library" then
                                                            Notify("Hit Log", msg, 2)
                                                        else
                                                            HitLog:Notify(msg)
                                                        end
                                                    end
                                                else
                                                    RS.RenderStepped:Wait()
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    RS.RenderStepped:Wait()
                end
            end)
            if RB.TargetLineConn then RB.TargetLineConn:Disconnect() end
            RB.TargetLineConn = RS.RenderStepped:Connect(function()
                if RB.TargetLine and RB.TargetLineObj then
                    local target = find_closest_target()
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = target.Character.HumanoidRootPart
                        local pos, vis = Cam:WorldToViewportPoint(hrp.Position)
                        if vis then
                            local mp = UIS:GetMouseLocation()
                            RB.TargetLineObj.From = Vector2.new(mp.X, mp.Y)
                            RB.TargetLineObj.To = Vector2.new(pos.X, pos.Y)
                            RB.TargetLineObj.Color = RB.TargetLineColor or Color3.new(1,0,0)
                            RB.TargetLineObj.Visible = true
                        else
                            RB.TargetLineObj.Visible = false
                        end
                    else
                        RB.TargetLineObj.Visible = false
                    end
                elseif RB.TargetLineObj then
                    RB.TargetLineObj.Visible = false
                end
            end)
            Notify("Rage Bot", "Rage Bot enabled", 2)
        end
    end,
})

RageBotToggle:Keybind({
    Flag     = "RageBotKey",
    Default  = false,
    Mode     = "Toggle",
    Callback = function(Value)
        RageBotToggle.Set(Value)
    end,
})

CombatSection:Dropdown({
    Name     = "Sphere Algorithm",
    Flag     = "RageSphereMode",
    Options    = {"Fibonacci", "Random", "Cardinals", "Vector", "Hammersley", "Femboy Fibonacci"},
    Default  = "Fibonacci",
    Multi    = false,
    Callback = function(v) RB.SphereMode = v end,
})

CombatSection:Slider({
    Name     = "Sphere Radius",
    Flag     = "RageSphereRadius",
    Min      = 1,
    Max      = 19,
    Default  = 19,
    Decimal = 1,
    Suffix   = "st",
    Callback = function(value) RB.SphereRadius = value end,
})

CombatSection:Slider({
    Name     = "Fire Rate",
    Flag     = "RageFireRate",
    Min      = 0,
    Max      = 100,
    Default  = 50,
    Decimal = 1,
    Suffix   = "%",
    Callback = function(value) RB.FireRate = value end,
})

FovLimitToggle = CombatSection:Toggle({
    Name     = "FOV Limit",
    Flag     = "RageFovLimit",
    Default = false,
    Callback = function(state)
        RB.FovLimit = state
    end,
})

CombatSection:Slider({
    Name     = "FOV Radius",
    Flag     = "RageFovRadius",
    Min      = 10,
    Max      = 600,
    Default  = 150,
    Decimal = 1,
    Suffix   = "px",
    Callback = function(value)
        RB.FovRadius = value
        if RB.FovCircle then RB.FovCircle.Radius = value end
    end,
})

CombatSection:Toggle({
    Name     = "Show FOV circle",
    Flag     = "RageShowFov",
    Default = false,
    Callback = function(state)
        RB.ShowFov = state
    end,
}):Colorpicker({
    Name     = "FOV Color",
    Flag     = "RageFovColor",
    Color  = Color3.new(1, 1, 1),
    Alpha    = 0,
    Callback = function(color)
        RB.FovColor = color
        if RB.FovCircle then RB.FovCircle.Color = color end
    end,
})

CombatSection:Toggle({
    Name     = "Target Line",
    Flag     = "RageTargetLine",
    Default  = false,
    Callback = function(state)
        RB.TargetLine = state
    end,
}):Colorpicker({
    Name     = "Target Line Color",
    Flag     = "RageTargetLineColor",
    Color    = Color3.new(1, 0, 0),
    Alpha    = 0,
    Callback = function(color)
        RB.TargetLineColor = color
        if RB.TargetLineObj then RB.TargetLineObj.Color = color end
    end,
})

CombatSection:Toggle({
    Name     = "Check downed",
    Flag     = "RageCheckDowned",
    Default  = false,
    Callback = function(state) RB.CheckDowned = state end,
})

CombatSection:Toggle({
    Name     = "Check dead",
    Flag     = "RageCheckDead",
    Default = false,
    Callback = function(state) RB.CheckDead = state end,
})

CombatSection:Toggle({
    Name     = "Check team",
    Flag     = "RageCheckTeam",
    Default  = false,
    Callback = function(state) RB.CheckTeam = state end,
})

CombatSection:Toggle({
    Name     = "TP Hit",
    Flag     = "RageTPHit",
    Default  = false,
    Callback = function(state)
        RB.TPHit = state

        if state then
            RB.TPHitPrevFovLimit = RB.FovLimit
            RB.FovLimit = false
            if FovLimitToggle then FovLimitToggle.Set(false) end
        else
            if RB.TPHitPrevFovLimit ~= nil then
                RB.FovLimit = RB.TPHitPrevFovLimit
                if FovLimitToggle then FovLimitToggle.Set(RB.TPHitPrevFovLimit) end
                RB.TPHitPrevFovLimit = nil
            end
        end
    end,
})

CombatSection:Toggle({
    Name     = "Skybox Bullet",
    Flag     = "RageSkyboxBullet",
    Default  = false,
    Callback = function(state)
        RB.SkyboxBullet = state

        if state then

            local char = LP.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                RB.SkyboxBulletSavedCFrame = hrp.CFrame
            end

            RB.SkyboxBulletPrevFovLimit = RB.FovLimit
            RB.FovLimit = false
            if FovLimitToggle then FovLimitToggle.Set(false) end
        else

            local char = LP.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and RB.SkyboxBulletSavedCFrame then
                hrp.CFrame = RB.SkyboxBulletSavedCFrame
            end
            RB.SkyboxBulletSavedCFrame = nil

            if RB.SkyboxBulletPrevFovLimit ~= nil then
                RB.FovLimit = RB.SkyboxBulletPrevFovLimit
                if FovLimitToggle then FovLimitToggle.Set(RB.SkyboxBulletPrevFovLimit) end
                RB.SkyboxBulletPrevFovLimit = nil
            end
        end
    end,
})

local SkyboxHeightSlider, SkyboxOffsetSlider, SkyboxIntervalSlider
local SkyboxCustomRightSlider, SkyboxCustomHeightSlider, SkyboxCustomForwardSlider

local function set_slider_visible(slider, visible)
    if slider and slider.Items and slider.Items.Slider then
        slider.Items.Slider.Visible = visible
    end
end

local function refresh_skybox_location_visibility()
    local isCustom = RB.SkyboxBulletMode == "Custom"

    set_slider_visible(SkyboxHeightSlider, not isCustom)
    set_slider_visible(SkyboxOffsetSlider, not isCustom)
    set_slider_visible(SkyboxIntervalSlider, not isCustom)

    set_slider_visible(SkyboxCustomRightSlider, isCustom)
    set_slider_visible(SkyboxCustomHeightSlider, isCustom)
    set_slider_visible(SkyboxCustomForwardSlider, isCustom)
end

CombatSection:Dropdown({
    Name     = "Skybox Location",
    Flag     = "RageSkyboxLocation",
    Options  = {"Left+Right", "Random", "Custom"},
    Default  = "Left+Right",
    Multi    = false,
    Callback = function(v)
        RB.SkyboxBulletMode = v
        refresh_skybox_location_visibility()
    end,
})

SkyboxHeightSlider = CombatSection:Slider({
    Name     = "Skybox Height",
    Flag     = "RageSkyboxHeight",
    Min      = 4,
    Max      = 30,
    Default  = 12,
    Decimal = 1,
    Suffix   = "st",
    Callback = function(value) RB.SkyboxBulletHeight = value end,
})

SkyboxOffsetSlider = CombatSection:Slider({
    Name     = "Skybox Offset",
    Flag     = "RageSkyboxOffset",
    Min      = 2,
    Max      = 15,
    Default  = 6,
    Decimal = 1,
    Suffix   = "st",
    Callback = function(value) RB.SkyboxBulletOffset = value end,
})

SkyboxIntervalSlider = CombatSection:Slider({
    Name     = "Skybox Switch Speed",
    Flag     = "RageSkyboxInterval",
    Min      = 0.01,
    Max      = 0.3,
    Default  = 0.01,
    Decimal = 0.01,
    Suffix   = "s",
    Callback = function(value) RB.SkyboxBulletInterval = value end,
})

SkyboxCustomRightSlider = CombatSection:Slider({
    Name     = "Skybox Custom Right",
    Flag     = "RageSkyboxCustomRight",
    Min      = -30,
    Max      = 30,
    Default  = 0,
    Decimal = 1,
    Suffix   = "st",
    Callback = function(value) RB.SkyboxBulletCustomRight = value end,
})

SkyboxCustomHeightSlider = CombatSection:Slider({
    Name     = "Skybox Custom Height",
    Flag     = "RageSkyboxCustomHeight",
    Min      = -30,
    Max      = 30,
    Default  = 12,
    Decimal = 1,
    Suffix   = "st",
    Callback = function(value) RB.SkyboxBulletCustomHeight = value end,
})

SkyboxCustomForwardSlider = CombatSection:Slider({
    Name     = "Skybox Custom Forward",
    Flag     = "RageSkyboxCustomForward",
    Min      = -30,
    Max      = 30,
    Default  = 0,
    Decimal = 1,
    Suffix   = "st",
    Callback = function(value) RB.SkyboxBulletCustomForward = value end,
})

refresh_skybox_location_visibility()

local HitSoundSection = CombatPage:Section({Name = "Hit Sounds & Logs", Side = "Right"})

HitSoundSection:Toggle({
    Name     = "Enable hitsounds",
    Flag     = "RageSoundsToggle",
    Default = false,
    Callback = function(v)
        HSett.On = v
        if v then UpdHSound() end  -- хук ставится только при первом включении
    end,
})

HitSoundSection:Dropdown({
    Name     = "Hitsound Method",
    Flag     = "RageSoundMethod",
    Options    = {"Hit Check", "ID Swap"},
    Default  = "Hit Check",
    Multi    = false,
    Callback = function(v)
        HSett.Method = v
        UpdHSound()
    end,
})

HitSoundSection:Toggle({
    Name     = "Hit Log",
    Flag     = "RageHitLogToggle",
    Default  = false,
    Callback = function(v)
        HitLogSett.On = v
    end,
})

HitSoundSection:Dropdown({
    Name     = "Hit Log Method",
    Flag     = "RageHitLogMethod",
    Options  = {"Middle", "Library"},
    Default  = "Middle",
    Multi    = false,
    Callback = function(v)
        HitLogSett.Method = v
    end,
})

HitSoundSection:Dropdown({
    Name     = "Sound type",
    Flag     = "RageSoundType",
    Options    = {"Rust","CODE200","Minecraft","Neverlose","Gamesense","Bonk","Bat","Laser Beam","Fatality","Bow","koch","golda","agpa1","agpa2"},
    Default  = "Rust",
    Multi    = false,
    Callback = function(v)
        HSett.SoundId = HitSounds[v] or HitSounds["Rust"]
        UpdHSound()
    end,
})

HitSoundSection:Slider({
    Name     = "Volume",
    Flag     = "RageSoundVolume",
    Min      = 0,
    Max      = 10,
    Default  = 1,
    Decimal = 1,
    Suffix   = "",
    Callback = function(v) HSett.Vol = v; UpdHSound() end,
})

local HitsoundPreviewToggle
HitsoundPreviewToggle = HitSoundSection:Toggle({
    Name     = "Preview Hitsound",
    Flag     = "RagePreviewHitsound",
    Default  = false,
    Callback = function(state)
        if state then
            PlayHSound()
            task.delay(0.1, function()
                if HitsoundPreviewToggle then
                    HitsoundPreviewToggle.Set(false)
                end
            end)
        end
    end,
})

local SA_R6_BONES = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }

local silentAim = {
    Enabled      = false,
    Method       = "Raycast",  -- "Raycast" | "Remote"
    HitPart      = "Head",
    HitChance    = 100,
    WallCheck    = true,
    CheckDown    = false,
    DeadCheck    = true,
    CheckForceShield = true,
    CheckFriendly = false,
    FOVRadius    = 150,
    DrawFOV      = true,
    FOVCenterOnly = false,
    FOVFilled    = false,
    FOVColor     = Color3.fromRGB(255, 255, 255),
    FOVFillColor = Color3.fromRGB(175, 86, 86),
    target       = nil,
    RandomPart   = false,
    SwitchDelay  = 0,
    _lastSwitchTime = 0,
    _lastTargetPlayer = nil,
    MaxDistance  = 4000,
}

local sa_ring = Drawing.new("Circle")
sa_ring.Visible   = false
sa_ring.Filled    = false
sa_ring.Thickness = 1
sa_ring.NumSides  = 64
sa_ring.Radius    = silentAim.FOVRadius
sa_ring.Color     = silentAim.FOVColor
sa_ring.ZIndex    = 10

local sa_fill = Drawing.new("Circle")
sa_fill.Visible   = false
sa_fill.Filled    = true
sa_fill.Thickness = 1
sa_fill.NumSides  = 64
sa_fill.Radius    = silentAim.FOVRadius
sa_fill.Color     = silentAim.FOVFillColor
sa_fill.Transparency = 0.85
sa_fill.ZIndex    = 9

RS.RenderStepped:Connect(function()
    local center
    if silentAim.FOVCenterOnly then
        center = Vector2.new(Cam.ViewportSize.X * 0.5, Cam.ViewportSize.Y * 0.5)
    else
        center = UIS:GetMouseLocation()
    end
    sa_ring.Position = center
    sa_ring.Radius   = silentAim.FOVRadius
    sa_ring.Color    = silentAim.FOVColor
    sa_ring.Visible  = silentAim.Enabled and silentAim.DrawFOV

    sa_fill.Position = center
    sa_fill.Radius   = silentAim.FOVRadius
    sa_fill.Color    = silentAim.FOVFillColor
    sa_fill.Visible  = silentAim.Enabled and silentAim.FOVFilled
end)

local function sa_should_ignore(player)
    if not player or player == LP then return true end
    local char = player.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum or hum.Health <= 0 then return true end
    if silentAim.DeadCheck and hum.Health <= 0 then return true end
    if silentAim.CheckForceShield and char:FindFirstChildOfClass("ForceField") then return true end
    if silentAim.CheckDown then
        local char_stats = RepSt:FindFirstChild("CharStats")
        local p_stats = char_stats and char_stats:FindFirstChild(player.Name)
        local downed = p_stats and p_stats:FindFirstChild("Downed")
        if downed and downed.Value == true then return true end
    end
    if silentAim.CheckFriendly then
        if is_friend(player) then return true end
    end
    return false
end

local function sa_has_los(part)
    if not silentAim.WallCheck then return true end
    local char = LP.Character
    if not char or not part then return false end
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = { char, Cam, part.Parent }
    rp.IgnoreWater = true
    return workspace:Raycast(Cam.CFrame.Position, part.Position - Cam.CFrame.Position, rp) == nil
end

RS.Heartbeat:Connect(function()
    if not silentAim.Enabled then
        silentAim.target = nil
        return
    end

    local center
    if silentAim.FOVCenterOnly then
        center = Vector2.new(Cam.ViewportSize.X * 0.5, Cam.ViewportSize.Y * 0.5)
    else
        center = UIS:GetMouseLocation()
    end

    local best_part, best_dist = nil, math.huge
    local best_player = nil

    local local_hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

    for _, player in ipairs(Plrs:GetPlayers()) do
        if sa_should_ignore(player) then continue end
        local char = player.Character

      
        if silentAim.MaxDistance > 0 and local_hrp then
            local eHrp = char:FindFirstChild("HumanoidRootPart")
            if not eHrp then continue end
            local dist3d = (local_hrp.Position - eHrp.Position).Magnitude
            if dist3d > silentAim.MaxDistance then continue end
        end

        local part
        if silentAim.RandomPart then
      
            local available = {}
            for _, bone in ipairs(SA_R6_BONES) do
                local p = char:FindFirstChild(bone)
                if p then available[#available + 1] = p end
            end
            if #available > 0 then
                part = available[math.random(1, #available)]
            end
        else
            part = char:FindFirstChild(silentAim.HitPart)
            if not part then
                for _, bone in ipairs(SA_R6_BONES) do
                    local p = char:FindFirstChild(bone)
                    if p then part = p; break end
                end
            end
        end
                if not part then continue end

        local sp, on_screen = Cam:WorldToViewportPoint(part.Position)
        if not on_screen then continue end

        local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
        if dist <= silentAim.FOVRadius and dist < best_dist then
          
            if not sa_has_los(part) then continue end
            best_dist = dist
            best_part = part
            best_player = player
        end
    end


    if best_player ~= silentAim._lastTargetPlayer then
        local now = tick()
        if silentAim.SwitchDelay > 0
            and silentAim._lastTargetPlayer ~= nil
            and (now - silentAim._lastSwitchTime) < silentAim.SwitchDelay
        then
    
            local old_char = silentAim._lastTargetPlayer.Character
            local old_part = old_char and old_char:FindFirstChild(silentAim.HitPart)
            if old_part and old_part.Parent then
                silentAim.target = old_part
            else
                silentAim.target = best_part
                silentAim._lastTargetPlayer = best_player
                silentAim._lastSwitchTime = now
            end
        else
            silentAim.target = best_part
            if best_player ~= silentAim._lastTargetPlayer then
                silentAim._lastSwitchTime = tick()
                silentAim._lastTargetPlayer = best_player
            end
        end
    else
        silentAim.target = best_part
    end
end)

local sa_oldNamecall
local sa_hook_installed = false

local function sa_install_hook()
    if sa_hook_installed then return end
    if not (hookmetamethod and newcclosure and getnamecallmethod) then return end
    sa_hook_installed = true
    sa_oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local args   = { ... }
        local method = getnamecallmethod()

        if method == "Raycast" and silentAim.Enabled and silentAim.Method == "Raycast"
            and silentAim.target
            and math.random(1, 100) <= silentAim.HitChance
        then
            local external = true
            pcall(function() external = not checkcaller() end)

            if external and self == workspace and args[1] and typeof(args[1]) == "Vector3" then
                args[2] = (silentAim.target.Position - args[1]).Unit * 9999
                return sa_oldNamecall(self, table.unpack(args))
            end
        end

        return sa_oldNamecall(self, ...)
    end))
end

do
    local ev2       = RepSt:FindFirstChild("Events2")
    local visualize = ev2 and ev2:FindFirstChild("Visualize")
    local ev        = RepSt:FindFirstChild("Events")
    local hitRemote = ev and ev:FindFirstChild("ZFKLF__H")

    if visualize and visualize.Event and hitRemote then
        visualize.Event:Connect(function(_, shotId, _, tool, _, origin, pelletDirs)
            if not silentAim.Enabled or not tool then return end
            local char = LP.Character
            if not char or char:FindFirstChildOfClass("ForceField") then return end
            if char:FindFirstChildOfClass("Tool") ~= tool then return end

            local targetPart = silentAim.target
            if not targetPart or not targetPart.Parent then return end

            if typeof(origin) ~= "Vector3" then
                local handle = tool:FindFirstChild("WeaponHandle", true) or tool:FindFirstChild("Handle", true)
                local fp = handle and (handle:FindFirstChild("FirePoint", true) or handle:FindFirstChild("Muzzle", true))
                origin = fp and (fp:IsA("Attachment") and fp.WorldPosition or fp.Position) or Cam.CFrame.Position
            end

            if silentAim.Method == "Raycast" then
               
                if math.random(1, 100) > silentAim.HitChance then return end

                local count = type(pelletDirs) == "table" and math.max(1, #pelletDirs) or 1
                local dir   = CFrame.new(origin, targetPart.Position).LookVector

                task.wait()
                for i = 1, count do
                    pcall(function()
                        hitRemote:FireServer(utf8.char(129480), tool, shotId, i, targetPart, targetPart.Position, dir)
                    end)
                end

                                local hitmarker = tool:FindFirstChild("Hitmarker")
                if hitmarker and hitmarker:IsA("BindableEvent") then hitmarker:Fire(targetPart) end

            elseif silentAim.Method == "Remote" then
          
                if math.random(1, 100) > silentAim.HitChance then return end

                local pelletCount = type(pelletDirs) == "table" and math.clamp(#pelletDirs, 1, 100) or 1
                local dir         = CFrame.new(origin, targetPart.Position).LookVector
                local partPos     = targetPart.Position

                local partPos = targetPart.Position
                local bullets = {}
                for i = 1, pelletCount do
                    table.insert(bullets, { index = i, dir = dir, pos = partPos })
                end

                task.wait(0.005)

                for _, bullet in ipairs(bullets) do
                    pcall(function()
                        hitRemote:FireServer("🧈", tool, shotId, bullet.index, targetPart, bullet.pos, bullet.dir)
                    end)
                end

                                local hitmarker = tool:FindFirstChild("Hitmarker")
                if hitmarker and hitmarker:IsA("BindableEvent") then hitmarker:Fire(targetPart) end
            end
        end)
    end
end

local SilentAimSection = LegitPage:Section({Name = "Silent Aim", Side = "Left"})

local _SilentAimToggle
_SilentAimToggle = SilentAimSection:Toggle({
    Name     = "Enable Silent Aim",
    Flag     = "SAEnabled",
    Default  = false,
    Callback = function(state)
      
        if state and silentAim.Method == "Raycast" and not hookmetamethod then
            UILibNotifications:Create({
                Name     = "Silent Aim: Raycast method requires hookmetamethod which your executor doesn't support. Switch to Remote.",
                LifeTime = 5,
            })
        end
        silentAim.Enabled = state
        if state then
            sa_install_hook()  -- хук вешается только при первом включении
        end
        if not state then silentAim.target = nil end
        Notify("Silent Aim", state and "enabled" or "disabled", 2)
    end,
})

SilentAimSection:Dropdown({
    Name     = "Method",
    Flag     = "SAMethod",
    Options  = {"Raycast", "Remote"},
    Default  = hookmetamethod and "Raycast" or "Remote",
    Multi    = false,
    Callback = function(v)
        silentAim.Method = v
        if v == "Raycast" and not hookmetamethod then
            UILibNotifications:Create({
                Name     = "Silent Aim: Raycast won't work on your executor, use Remote instead",
                LifeTime = 5,
            })
        end
        Notify("Silent Aim", "Method: " .. v, 2)
    end,
})

SilentAimSection:Dropdown({
    Name     = "Target Bone",
    Flag     = "SATargetBone",
    Options  = {"Random", "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
    Default  = "Head",
    Multi    = false,
    Callback = function(v)
        if v == "Random" then
            silentAim.RandomPart = true
        else
            silentAim.RandomPart = false
            silentAim.HitPart = v
        end
    end,
})

SilentAimSection:Slider({
    Name     = "Switch Delay",
    Flag     = "SASwitchDelay",
    Min      = 0,
    Max      = 3000,
    Default  = 0,
    Decimal  = 1,
    Suffix   = "ms",
    Callback = function(v) silentAim.SwitchDelay = v / 1000 end,
})

SilentAimSection:Slider({
    Name     = "FOV",
    Flag     = "SAFovRadius",
    Min      = 1,
    Max      = 600,
    Default  = 40,
    Decimal  = 1,
    Suffix   = "°",
    Callback = function(v) silentAim.FOVRadius = v end,
})

SilentAimSection:Slider({
    Name     = "Max Distance",
    Flag     = "SAMaxDistance",
    Min      = 0,
    Max      = 4000,
    Default  = 500,
    Decimal  = 1,
    Suffix   = "m",
    Callback = function(v) silentAim.MaxDistance = v end,
})

SilentAimSection:Slider({
    Name     = "Hit Chance",
    Flag     = "SAHitChance",
    Min      = 1,
    Max      = 100,
    Default  = 45,
    Suffix   = "%",
    Callback = function(v) silentAim.HitChance = math.floor(v) end,
})

SilentAimSection:Toggle({
    Name     = "Show FOV Circle",
    Flag     = "SAShowFov",
    Default = false,
    Callback = function(state) silentAim.DrawFOV = state end,
}):Colorpicker({
    Name     = "FOV Color",
    Flag     = "SAFovColor",
    Color    = Color3.new(1, 1, 1),
    Alpha    = 0,
    Callback = function(color) silentAim.FOVColor = color end,
})



SilentAimSection:Toggle({
    Name     = "Wall Check",
    Flag     = "SAWallCheck",
    Default = false,
    Callback = function(state) silentAim.WallCheck = state end,
})

SilentAimSection:Toggle({
    Name     = "Check Downed",
    Flag     = "SACheckDowned",
    Default  = false,
    Callback = function(state) silentAim.CheckDown = state end,
})

SilentAimSection:Toggle({
    Name     = "Dead Check",
    Flag     = "SADeadCheck",
    Default = false,
    Callback = function(state) silentAim.DeadCheck = state end,
})

SilentAimSection:Toggle({
    Name     = "Force Shield Check",
    Flag     = "SAFFCheck",
    Default = false,
    Callback = function(state) silentAim.CheckForceShield = state end,
})

SilentAimSection:Toggle({
    Name     = "Check Friendly",
    Flag     = "SACheckFriendly",
    Default  = false,
    Callback = function(state) silentAim.CheckFriendly = state end,
})

local GunAdjustSection = LegitPage:Section({Name = "Gun Adjustment", Side = "Left"})

local NR = {
    Enabled      = false,
    Mode         = "No Recoil",   
    ReducePct    = 100,
    
    weapons      = {},
    originals    = {},
    connections  = {},
    CFHook       = nil,
}

local function NR_Scan()
    NR.weapons = {}
    if not getgc then return end
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "EquipTime") then
            table.insert(NR.weapons, v)
            if not NR.originals[v] then
                NR.originals[v] = {
                    Recoil               = v.Recoil,
                    CameraRecoilingEnabled = v.CameraRecoilingEnabled,
                    AngleX_Min           = v.AngleX_Min,
                    AngleX_Max           = v.AngleX_Max,
                    AngleY_Min           = v.AngleY_Min,
                    AngleY_Max           = v.AngleY_Max,
                    AngleZ_Min           = v.AngleZ_Min,
                    AngleZ_Max           = v.AngleZ_Max,
                    Spread               = v.Spread,
                }
            end
        end
    end
end

local function NR_Apply()
    NR_Scan()
    for _, w in ipairs(NR.weapons) do
        pcall(function()
            if NR.Mode == "No Recoil" then
                w.Recoil               = 0
                w.CameraRecoilingEnabled = false
                w.AngleX_Min           = 0
                w.AngleX_Max           = 0
                w.AngleY_Min           = 0
                w.AngleY_Max           = 0
                w.AngleZ_Min           = 0
                w.AngleZ_Max           = 0
                w.Spread               = 0

            elseif NR.Mode == "Reduce Recoil" then
                local orig = NR.originals[w]
                if orig then
                    local mult = (100 - NR.ReducePct) / 100
                    w.Recoil               = (orig.Recoil or 0)     * mult
                    w.AngleX_Min           = (orig.AngleX_Min or 0) * mult
                    w.AngleX_Max           = (orig.AngleX_Max or 0) * mult
                    w.AngleY_Min           = (orig.AngleY_Min or 0) * mult
                    w.AngleY_Max           = (orig.AngleY_Max or 0) * mult
                    w.AngleZ_Min           = (orig.AngleZ_Min or 0) * mult
                    w.AngleZ_Max           = (orig.AngleZ_Max or 0) * mult
                    w.Spread               = (orig.Spread or 0)     * mult
                    w.CameraRecoilingEnabled = mult > 0.01
                end
            end
        end)
    end
end

local function NR_Restore()
    for w, orig in pairs(NR.originals) do
        pcall(function()
            w.Recoil               = orig.Recoil
            w.CameraRecoilingEnabled = orig.CameraRecoilingEnabled
            w.AngleX_Min           = orig.AngleX_Min
            w.AngleX_Max           = orig.AngleX_Max
            w.AngleY_Min           = orig.AngleY_Min
            w.AngleY_Max           = orig.AngleY_Max
            w.AngleZ_Min           = orig.AngleZ_Min
            w.AngleZ_Max           = orig.AngleZ_Max
            w.Spread               = orig.Spread
        end)
    end
end

local function NR_HookChar(ch)
    for _, c in ipairs(ch:GetChildren()) do
        if c:IsA("Tool") and NR.Enabled then
            task.wait(0.15)
            NR_Apply()
        end
    end
    table.insert(NR.connections, ch.ChildAdded:Connect(function(c)
        if c:IsA("Tool") and NR.Enabled then
            task.wait(0.15)
            NR_Apply()
        end
    end))
    local hum = ch:WaitForChild("Humanoid", 3)
    if hum then
        table.insert(NR.connections, hum.Died:Connect(function()
            if NR.Enabled then
                task.wait(2)
                NR_Apply()
            end
        end))
    end
end

table.insert(NR.connections, LP.CharacterAdded:Connect(function(ch)
    task.wait(0.5)
    NR_HookChar(ch)
end))
if LP.Character then NR_HookChar(LP.Character) end

local function NR_ApplyCF()
    if NR.CFHook then return end
    if not hookmetamethod or not checkcaller then return end
    NR.CFHook = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value, ...)
        if checkcaller() then
            return NR.CFHook(self, key, value)
        end
        if NR.Enabled and NR.Mode == "No Recoil"
            and self == Cam and (key == "CoordinateFrame" or key == "coordinateFrame") then
            return NR.CFHook(self, key, Cam.CFrame)
        end
        return NR.CFHook(self, key, value)
    end))
end

local NR_ReduceSection = LegitPage:Section({Name = "Reduce Settings", Side = "Left"})
NR_ReduceSection.Items.Section.Visible = false

GunAdjustSection:Toggle({
    Name     = "No Recoil",
    Flag     = "GunNoRecoil",
    Default  = false,
    Callback = function(state)
        NR.Enabled = state
        if state then
            NR_Apply()
            if NR.Mode == "No Recoil" then NR_ApplyCF() end
        else
            NR_Restore()
        end
    end,
})

GunAdjustSection:Dropdown({
    Name     = "Mode",
    Flag     = "GunNoRecoilMode",
    Options  = {"No Recoil", "Reduce Recoil"},
    Default  = "No Recoil",
    Multi    = false,
    Callback = function(v)
        NR.Mode = v
        NR_ReduceSection.Items.Section.Visible = (v == "Reduce Recoil")
        if NR.Enabled then NR_Apply() end
        if v == "No Recoil" then NR_ApplyCF() end
    end,
})

NR_ReduceSection:Slider({
    Name     = "Reduce %",
    Flag     = "GunReducePct",
    Min      = 0,
    Max      = 100,
    Default  = 100,
    Decimal  = 1,
    Suffix   = "%",
    Callback = function(v)
        NR.ReducePct = v
        if NR.Enabled and NR.Mode == "Reduce Recoil" then NR_Apply() end
    end,
})

BulletSection:Toggle({
    Name     = "Enable Bullet Beam",
    Flag     = "BulletBeamToggle",
    Default  = false,
    Callback = function(state) toggleBB(state) end,
}):Colorpicker({
    Name     = "Beam Color",
    Flag     = "BBColor",
    Color  = Color3.fromRGB(230, 160, 70),
    Alpha    = 0.7,
    Callback = function(color, alpha) BB.Col = color; if alpha then BB.Trans = alpha end end,
})

BulletSection:Dropdown({
    Name     = "Texture",
    Flag     = "BBTexture",
    Options    = {"Obelus", "Lightning", "DNA", "Straight", "Taser", "Edge", "Energy"},
    Default  = "DNA",
    Multi    = false,
    Callback = function(v)
        BB.CurTex = v
    end,
})

BulletSection:Dropdown({
    Name     = "Type",
    Flag     = "BBType",
    Options    = {"Beam", "Line", "Part"},
    Default  = "Beam",
    Multi    = false,
    Callback = function(v)
        BB.Type = v
    end,
})

BulletSection:Slider({
    Name     = "Thickness",
    Flag     = "BBThickness",
    Min      = 0.01,
    Max      = 5,
    Default  = 0.1,
    Decimal = 0.01,
    Suffix   = "",
    Callback = function(value) BB.Thick = value end,
})

BulletSection:Slider({
    Name     = "Lifetime",
    Flag     = "BBLife",
    Min      = 0.1,
    Max      = 10,
    Default  = 2,
    Decimal = 0.1,
    Suffix   = "s",
    Callback = function(value) BB.Life = value end,
})

BulletSection:Slider({
    Name     = "Transparency",
    Flag     = "BBTransparency",
    Min      = 0,
    Max      = 1,
    Default  = 0.7,
    Decimal = 0.01,
    Suffix   = "",
    Callback = function(value) BB.Trans = value end,
})

BulletSection:Dropdown({
    Name     = "Material (Part)",
    Flag     = "BBPartMaterial",
    Options  = {"ForceField", "Neon", "SmoothPlastic", "Glass"},
    Default  = "ForceField",
    Multi    = false,
    Callback = function(v) BB.Mat = v end,
})

BulletSection:Toggle({
    Name     = "Smooth Fade",
    Flag     = "BBSmoothFade",
    Default  = false,
    Callback = function(state) BB.SmoothFade = state end,
})

BulletSection:Slider({
    Name     = "Fade Speed",
    Flag     = "BBFadeSpeed",
    Min      = 0.1,
    Max      = 5,
    Default  = 1,
    Decimal  = 1,
    Suffix   = "s",
    Callback = function(value) BB.FadeSpeed = tonumber(value) or 1 end,
})


local LocalSection = WorldPage:Section({Name = "Local", Side = "Right"})

local LocalCFG = {
    CustomFovEnabled   = false,
    CustomFovValue     = 90,
    DisableOnAim       = true,
    SmoothTransition   = true,
    Smoothness         = 10,
    ZoomEnabled        = false,
    ZoomMultiplier     = 1,
    _zoomActive        = false,
    _aimDownConn       = nil,
    _currentInternalFov = 70,
    _isForcing         = false,
    _savedGameFov      = 70,
}

local function LocalFOV_Update()
    if not LocalCFG._aimDownConn then
        LocalCFG._currentInternalFov = Cam.FieldOfView
        LocalCFG._aimDownConn = RS.RenderStepped:Connect(function(dt)
            local targetFov = nil
            local shouldForce = false

            if LocalCFG._zoomActive then
                targetFov = 20 / LocalCFG.ZoomMultiplier
                shouldForce = true
            elseif LocalCFG.CustomFovEnabled then
                local isAiming = false
                if LocalCFG.DisableOnAim then
                    local char = LP.Character
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool then
                        local vals = tool:FindFirstChild("Values")
                        local aimDown = vals and vals:FindFirstChild("AimDown")
                        if aimDown and aimDown.Value == true then
                            isAiming = true
                        end
                    end
                end
                
                if not isAiming then
                    targetFov = LocalCFG.CustomFovValue
                    shouldForce = true
                end
            end
            
            if not shouldForce then
                local char = LP.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                local isAiming = false
                if tool then
                    local vals = tool:FindFirstChild("Values")
                    local aimDown = vals and vals:FindFirstChild("AimDown")
                    if aimDown and aimDown.Value == true then
                        isAiming = true
                    end
                end

                if isAiming then
                    LocalCFG._isForcing = false
                    LocalCFG._currentInternalFov = Cam.FieldOfView
                    return 
                end
                
                if LocalCFG._isForcing then
                    if math.abs(LocalCFG._currentInternalFov - LocalCFG._savedGameFov) > 0.5 then
                        targetFov = LocalCFG._savedGameFov
                    else
                        LocalCFG._isForcing = false
                        LocalCFG._currentInternalFov = Cam.FieldOfView
                        return
                    end
                else
                    LocalCFG._currentInternalFov = Cam.FieldOfView
                    return
                end
            else
                if not LocalCFG._isForcing then
                    LocalCFG._savedGameFov = Cam.FieldOfView
                    LocalCFG._isForcing = true
                end
            end
            
            if targetFov then
                if LocalCFG.SmoothTransition then
                    local speed = math.clamp(21 - LocalCFG.Smoothness, 1, 20) * 1.5 
                    local diff = targetFov - LocalCFG._currentInternalFov
                    if math.abs(diff) > 0.05 then
                        LocalCFG._currentInternalFov = LocalCFG._currentInternalFov + diff * math.min(dt * speed, 1)
                    else
                        LocalCFG._currentInternalFov = targetFov
                    end
                else
                    LocalCFG._currentInternalFov = targetFov
                end
                
                Cam.FieldOfView = LocalCFG._currentInternalFov
            end
        end)
    end
end

local function LocalFOV_Toggle(state)
    LocalCFG.CustomFovEnabled = state
    LocalFOV_Update()
end

local function LocalZoom_Apply(active)
    LocalCFG._zoomActive = active
    LocalFOV_Update()
end

local CustomFovToggle = LocalSection:Toggle({
    Name     = "Custom Camera FOV",
    Flag     = "LocalCustomFov",
    Default  = false,
    Callback = function(state)
        LocalFOV_Toggle(state)
    end,
})

LocalSection:Toggle({
    Name     = "Disable On Aim",
    Flag     = "LocalFovDisableOnAim",
    Default = false,
    Callback = function(state)
        LocalCFG.DisableOnAim = state
    end,
})

LocalSection:Toggle({
    Name     = "Smooth FOV Transition",
    Flag     = "LocalFovSmooth",
    Default = false,
    Callback = function(state)
        LocalCFG.SmoothTransition = state
    end,
})

LocalSection:Slider({
    Name     = "Transition Speed",
    Flag     = "LocalFovSmoothnessValue",
    Min      = 1,
    Max      = 20,
    Default  = 10,
    Decimal  = 1,
    Callback = function(v)
        LocalCFG.Smoothness = v
    end,
})

LocalSection:Slider({
    Name     = "FOV",
    Flag     = "LocalFovValue",
    Min      = 50,
    Max      = 120,
    Default  = 90,
    Decimal  = 1,
    Suffix   = "°",
    Callback = function(v)
        LocalCFG.CustomFovValue = v
    end,
})

local ZoomToggle = LocalSection:Toggle({
    Name     = "Zoom",
    Flag     = "LocalZoom",
    Default  = false,
    Callback = function(state)
        LocalZoom_Apply(state)
    end,
})

ZoomToggle:Keybind({
    Flag     = "LocalZoomKey",
    Default  = false,
    Mode     = "Hold",
    Callback = function(active)
        ZoomToggle.Set(active)
    end,
})

LocalSection:Slider({
    Name     = "Zoom Multiplier",
    Flag     = "LocalZoomMultiplier",
    Min      = 1,
    Max      = 20,
    Default  = 1,
    Decimal  = 0.1,
    Suffix   = "x",
    Callback = function(v)
        LocalCFG.ZoomMultiplier = v
    end,
})

LP.CharacterAdded:Connect(function()
    task.wait(1)
    LocalFOV_Update()
end)


;(function()
local ViewModelSection = WorldPage:Section({Name = "Custom ViewModel", Side = "Right"})

local VMCFG = {
    Enabled = false,
    SelectedState = "Default",
    Speed = 0.3,
    States = {
        Default = { X = 0, Y = 0, Z = 0, Pitch = 0, Yaw = 0, Roll = 0 },
        Aiming  = { X = 0, Y = 0, Z = 0, Pitch = 0, Yaw = 0, Roll = 0 }
    },
    Current = { X = 0, Y = 0, Z = 0, Pitch = 0, Yaw = 0, Roll = 0 }
}

ViewModelSection:Toggle({
    Name = "Enable Custom ViewModel",
    Flag = "VM_Enabled",
    Default = false,
    Callback = function(v) VMCFG.Enabled = v end
})

local vmSliders = {}

ViewModelSection:Dropdown({
    Name = "State",
    Flag = "VM_State",
    Options = {"Default", "Aiming"},
    Default = "Default",
    Multi = false,
    Callback = function(v)
        VMCFG.SelectedState = v
        local s = VMCFG.States[v]
        if vmSliders.X then
            vmSliders.X.Set(s.X)
            vmSliders.Y.Set(s.Y)
            vmSliders.Z.Set(s.Z)
            vmSliders.Pitch.Set(s.Pitch)
            vmSliders.Yaw.Set(s.Yaw)
            vmSliders.Roll.Set(s.Roll)
        end
    end
})

vmSliders.X = ViewModelSection:Slider({ Name = "Offset X", Flag = "VM_X", Min = -5, Max = 5, Default = 0, Decimal = 0.1, Callback = function(v) VMCFG.States[VMCFG.SelectedState].X = v end })
vmSliders.Y = ViewModelSection:Slider({ Name = "Offset Y", Flag = "VM_Y", Min = -5, Max = 5, Default = 0, Decimal = 0.1, Callback = function(v) VMCFG.States[VMCFG.SelectedState].Y = v end })
vmSliders.Z = ViewModelSection:Slider({ Name = "Offset Z", Flag = "VM_Z", Min = -5, Max = 5, Default = 0, Decimal = 0.1, Callback = function(v) VMCFG.States[VMCFG.SelectedState].Z = v end })
vmSliders.Pitch = ViewModelSection:Slider({ Name = "Pitch", Flag = "VM_Pitch", Min = -180, Max = 180, Default = 0, Decimal = 1, Callback = function(v) VMCFG.States[VMCFG.SelectedState].Pitch = v end })
vmSliders.Yaw = ViewModelSection:Slider({ Name = "Yaw", Flag = "VM_Yaw", Min = -180, Max = 180, Default = 0, Decimal = 1, Callback = function(v) VMCFG.States[VMCFG.SelectedState].Yaw = v end })
vmSliders.Roll = ViewModelSection:Slider({ Name = "Roll", Flag = "VM_Roll", Min = -180, Max = 180, Default = 0, Decimal = 1, Callback = function(v) VMCFG.States[VMCFG.SelectedState].Roll = v end })

local saved_pure_cframe = nil

RS:BindToRenderStep("Antigravity_ViewModel_Restore", 100, function()
    if saved_pure_cframe then
        local vm = workspace.CurrentCamera:FindFirstChild("ViewModel")
        if vm then
            vm:PivotTo(saved_pure_cframe)
        end
        saved_pure_cframe = nil
    end
end)

RS:BindToRenderStep("Antigravity_ViewModel_Custom", 3000, function(dt)
    if VMCFG.Enabled then
        local char = LP.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
                local isAiming = false
        if tool then
            local vals = tool:FindFirstChild("Values")
            local aimDown = vals and vals:FindFirstChild("AimDown")
            if aimDown and aimDown.Value == true then
                isAiming = true
            end
        end
        
        local targetState = isAiming and VMCFG.States.Aiming or VMCFG.States.Default
        
        local factor = 1
        if VMCFG.Speed > 0 then
            factor = 1 - math.pow(0.001, dt / VMCFG.Speed)
        end
        
        VMCFG.Current.X = VMCFG.Current.X + (targetState.X - VMCFG.Current.X) * factor
        VMCFG.Current.Y = VMCFG.Current.Y + (targetState.Y - VMCFG.Current.Y) * factor
        VMCFG.Current.Z = VMCFG.Current.Z + (targetState.Z - VMCFG.Current.Z) * factor
        VMCFG.Current.Pitch = VMCFG.Current.Pitch + (targetState.Pitch - VMCFG.Current.Pitch) * factor
        VMCFG.Current.Yaw = VMCFG.Current.Yaw + (targetState.Yaw - VMCFG.Current.Yaw) * factor
        VMCFG.Current.Roll = VMCFG.Current.Roll + (targetState.Roll - VMCFG.Current.Roll) * factor

        local vm = workspace.CurrentCamera:FindFirstChild("ViewModel")
        if vm then
            saved_pure_cframe = vm:GetPivot()
            local camCF = workspace.CurrentCamera.CFrame
            local offset = CFrame.new(VMCFG.Current.X, VMCFG.Current.Y, VMCFG.Current.Z) * CFrame.Angles(math.rad(VMCFG.Current.Pitch), math.rad(VMCFG.Current.Yaw), math.rad(VMCFG.Current.Roll))
            local new_pivot = camCF * offset * camCF:ToObjectSpace(saved_pure_cframe)
            vm:PivotTo(new_pivot)
        end
    else
        saved_pure_cframe = nil
    end
end)


end)()

;(function()

VisualsSection:Toggle({
    Name     = "Enable",
    Flag     = "ESPEnabled",
    Default  = false,
    Callback = function(state)
        flags["Enabled"] = state

        if state then
            for _, v in esp_players:GetPlayers() do
                if v ~= esp_players.LocalPlayer and not esp[v.Name] then
                    esp:create_object(v)
                end
            end
        end
        esp.refresh_elements()
    end,
})

VisualsSection:Toggle({
    Name     = "Names",
    Flag     = "ESPNames",
    Default  = false,
    Callback = function(state)
        flags["Names"] = state
        esp.refresh_elements()
    end,
}):Colorpicker({
    Name     = "Name Color",
    Flag     = "ESPNameColor",
    Color  = Color3.fromRGB(255, 255, 255),
    Alpha    = 0,
    Callback = function(color)
        flags["Name_Color"].Color = color
        esp.refresh_elements()
    end,
})


VisualsSection:Dropdown({
    Name     = "Name Display",
    Flag     = "ESPNameMode",
    Options    = {"Both", "DisplayName", "Username"},
    Default  = "DisplayName",
    Multi    = false,
    Callback = function(v)
        flags["Name_Mode"] = v
        esp.refresh_elements()
    end,
})

VisualsSection:Toggle({
    Name     = "Boxes",
    Flag     = "ESPNames",
    Default  = false,
    Callback = function(state)
        flags["Boxes"] = state
        esp.refresh_elements()
    end,
}):Colorpicker({
    Name     = "Box Color",
    Flag     = "ESPBoxColor",
    Color  = Color3.fromRGB(255, 255, 255),
    Alpha    = 0,
    Callback = function(color)
        flags["Box_Color"].Color = color
        esp.refresh_elements()
    end,
})

VisualsSection:Toggle({
    Name     = "Box Gradient",
    Flag     = "ESPBoxGradient",
    Default  = false,
    Callback = function(state)
        flags["Box_Gradient"] = state
        esp.refresh_elements()
    end,
}):Colorpicker({
    Name     = "Box Gradient Color",
    Flag     = "ESPBoxGradientColor",
    Color  = Color3.fromRGB(128, 128, 128),
    Alpha    = 0,
    Callback = function(color)
        flags["Box_Gradient_Color"].Color = color
        esp.refresh_elements()
    end,
})

VisualsSection:Dropdown({
    Name     = "Box Type",
    Flag     = "ESPBoxType",
    Options    = {"Corner", "Normal"},
    Default  = "Normal",
    Multi    = false,
    Callback = function(v)
        flags["Box_Type"] = v
        esp.refresh_elements()
    end,
})

ChamsSection:Toggle({
    Name     = "Enabled",
    Flag     = "ChamsAllEnabled",
    Default  = false,
    Callback = function(state)
        chams_flags.MasterEnabled  = state
        chams2_flags.MasterEnabled = state
        if state and (chams_flags.Enabled or chams2_flags.Enabled) then
            chams_start_render()
        end
        if state and (hchams_flags.Enabled or hchams2_flags.Enabled) then
            hchams_start_render()
        end
    end,
})

ChamsSection:Toggle({
    Name     = "Chams",
    Flag     = "ChamsEnabled",
    Default  = false,
    Callback = function(state)
        chams_flags.Enabled = state
        if state then
            chams_start()
            chams_start_render()
        else
            chams_stop()
            if not chams2_flags.Enabled then chams_stop_render() end
        end
    end,
}):Colorpicker({
    Name     = "Chams Color",
    Flag     = "ChamsColor",
    Color    = Color3.fromRGB(255, 255, 255),
    Alpha    = 0.3,
    Callback = function(color, alpha)
        chams_flags.TargetColor = color
        chams_flags.TargetAlpha = alpha
        if not chams_flags.Enabled then
            chams_flags.Color = color
            chams_flags.Alpha = alpha
        end
    end,
})

ChamsSection:Toggle({
    Name     = "Chams Glow",
    Flag     = "ChamsGlowEnabled",
    Default  = false,
    Callback = function(state)
        chams_flags.GlowEnabled = state
        if state then chams_start() end
    end,
})

ChamsSection:Slider({
    Name     = "Chams Glow Size",
    Flag     = "ChamsGlowSize",
    Min      = 1,
    Max      = 2.5,
    Default  = 1.75,
    Decimal  = 0.01,
    Callback = function(v)
        chams_flags.GlowSize = v
    end,
})

ChamsSection:Toggle({
    Name     = "Chams Shading",
    Flag     = "ChamsShadingEnabled",
    Default  = false,
    Callback = function(state)
        chams_flags.ShadingEnabled = state
        pcall(function()
            if setfflag then setfflag("AdornShadingAPI", state and "True" or "False") end
        end)
    end,
})

ChamsSection:Dropdown({
    Name     = "Chams Inline Shade",
    Flag     = "ChamsInlineShade",
    Options  = { "Default", "XRay", "XRayShaded" },
    Default  = "Default",
    Callback = function(v)
        chams_flags.InlineShade = v
    end,
})

ChamsSection:Dropdown({
    Name     = "Chams Outline Shade",
    Flag     = "ChamsOutlineShade",
    Options  = { "Default", "Shaded", "XRay", "XRayShaded" },
    Default  = "Default",
    Callback = function(v)
        chams_flags.OutlineShade = v
    end,
})

ChamsSection:Toggle({
    Name     = "Visible Chams",
    Flag     = "Chams2Enabled",
    Default  = false,
    Callback = function(state)
        chams2_flags.Enabled = state
        if state then
            chams2_start()
            chams_start_render()
        else
            chams2_stop()
            if not chams_flags.Enabled then chams_stop_render() end
        end
    end,
}):Colorpicker({
    Name     = "Visible Chams Color",
    Flag     = "Chams2Color",
    Color    = Color3.fromRGB(255, 165, 0),
    Alpha    = 0.3,
    Callback = function(color, alpha)
        chams2_flags.TargetColor = color
        chams2_flags.TargetAlpha = alpha
        if not chams2_flags.Enabled then
            chams2_flags.Color = color
            chams2_flags.Alpha = alpha
        end
    end,
})

ChamsSection:Toggle({
    Name     = "Visible Chams Glow",
    Flag     = "Chams2GlowEnabled",
    Default  = false,
    Callback = function(state)
        chams2_flags.GlowEnabled = state
        if state then chams2_start() end
    end,
})

ChamsSection:Slider({
    Name     = "Visible Chams Glow Size",
    Flag     = "Chams2GlowSize",
    Min      = 1,
    Max      = 2.5,
    Default  = 1.75,
    Decimal  = 0.01,
    Callback = function(v)
        chams2_flags.GlowSize = v
    end,
})

ChamsSection:Toggle({
    Name     = "Visible Chams Shading",
    Flag     = "Chams2ShadingEnabled",
    Default  = false,
    Callback = function(state)
        chams2_flags.ShadingEnabled = state
        pcall(function()
            if setfflag then setfflag("AdornShadingAPI", state and "True" or "False") end
        end)
    end,
})

ChamsSection:Dropdown({
    Name     = "Visible Chams Inline Shade",
    Flag     = "Chams2InlineShade",
    Options  = { "Default", "Shaded" },
    Default  = "Default",
    Callback = function(v)
        chams2_flags.InlineShade = v
    end,
})

ChamsSection:Dropdown({
    Name     = "Visible Chams Outline Shade",
    Flag     = "Chams2OutlineShade",
    Options  = { "Default", "Shaded" },
    Default  = "Default",
    Callback = function(v)
        chams2_flags.OutlineShade = v
    end,
})

ChamsSection:Toggle({
    Name     = "Highlight Chams",
    Flag     = "HChamsEnabled",
    Default  = false,
    Callback = function(state)
        hchams_flags.Enabled = state
        if state then
            if hchams2_flags.Enabled then
                local cf = Library.ConfigFlags
                if cf and cf["HChams2Enabled"] then
                    cf["HChams2Enabled"](false)
                end
            end
            hchams_start()
            hchams_start_render()
        else
            hchams_stop()
        end
    end,
}):Colorpicker({
    Name     = "Fill Color",
    Flag     = "HChamsFillColor",
    Color    = Color3.fromRGB(100, 255, 100),
    Alpha    = 0.5,
    Callback = function(c, a)
        hchams_flags.FillTarget = c
        hchams_flags.FillColor  = c
        if a then
            hchams_flags.FillTargetAlpha = a
            hchams_flags.FillAlpha       = a
        end
    end,
})

ChamsSection:Toggle({
    Name     = "Outline",
    Flag     = "HChamsOutlineToggle",
    Default = false,
    Callback = function(state)
        if not state then
            hchams_flags.OutlineTargetAlpha = 1
            hchams_flags.OutlineAlpha       = 1
        else
            hchams_flags.OutlineTargetAlpha = hchams_flags._savedOutlineAlpha or 0
            hchams_flags.OutlineAlpha       = hchams_flags._savedOutlineAlpha or 0
        end
    end,
}):Colorpicker({
    Name     = "Outline Color",
    Flag     = "HChamsOutlineColor",
    Color    = Color3.fromRGB(255, 255, 255),
    Alpha    = 0,
    Callback = function(c, a)
        hchams_flags.OutlineTarget = c
        hchams_flags.OutlineColor  = c
        if a then
            hchams_flags._savedOutlineAlpha = a
            if Library.Flags["HChamsOutlineToggle"] then
                hchams_flags.OutlineTargetAlpha = a
                hchams_flags.OutlineAlpha       = a
            end
        end
    end,
})

ChamsSection:Toggle({
    Name     = "Visible Highlight Chams",
    Flag     = "HChams2Enabled",
    Default  = false,
    Callback = function(state)
        hchams2_flags.Enabled = state
        if state then

            if hchams_flags.Enabled then
                local cf = Library.ConfigFlags
                if cf and cf["HChamsEnabled"] then
                    cf["HChamsEnabled"](false)
                end
            end
            hchams2_start()
            hchams_start_render()
        else
            hchams2_stop()
        end
    end,
}):Colorpicker({
    Name     = "Fill Color",
    Flag     = "HChams2FillColor",
    Color    = Color3.fromRGB(255, 100, 100),
    Alpha    = 0.5,
    Callback = function(c, a)
        hchams2_flags.FillTarget = c
        hchams2_flags.FillColor  = c
        if a then
            hchams2_flags.FillTargetAlpha = a
            hchams2_flags.FillAlpha       = a
        end
    end,
})

ChamsSection:Toggle({
    Name     = "Visible Outline",
    Flag     = "HChams2OutlineToggle",
    Default = false,
    Callback = function(state)
        if not state then
            hchams2_flags.OutlineTargetAlpha = 1
            hchams2_flags.OutlineAlpha       = 1
        else
            hchams2_flags.OutlineTargetAlpha = hchams2_flags._savedOutlineAlpha or 0
            hchams2_flags.OutlineAlpha       = hchams2_flags._savedOutlineAlpha or 0
        end
    end,
}):Colorpicker({
    Name     = "Outline Color",
    Flag     = "HChams2OutlineColor",
    Color    = Color3.fromRGB(255, 255, 255),
    Alpha    = 0,
    Callback = function(c, a)
        hchams2_flags.OutlineTarget = c
        hchams2_flags.OutlineColor  = c
        if a then
            hchams2_flags._savedOutlineAlpha = a
            if Library.Flags["HChams2OutlineToggle"] then
                hchams2_flags.OutlineTargetAlpha = a
                hchams2_flags.OutlineAlpha       = a
            end
        end
    end,
})

local _healthbar_t = VisualsSection:Toggle({
    Name     = "Healthbar",
    Flag     = "ESPHealthbar",
    Default  = false,
    Callback = function(state)
        flags["Healthbar"] = state
        esp.refresh_elements()
    end,
})
_healthbar_t:Colorpicker({
    Name     = "Health High Color",
    Flag     = "ESPHealthHigh",
    Color    = Color3.fromRGB(0, 255, 0),
    Alpha    = 0,
    LayoutOrder = 1,
    Callback = function(color)
        flags["Health_High"].Color = color
        esp.refresh_elements()
    end,
})
_healthbar_t:Colorpicker({
    Name     = "Health Low Color",
    Flag     = "ESPHealthLow",
    Color    = Color3.fromRGB(255, 0, 0),
    Alpha    = 0,
    LayoutOrder = 2,
    Callback = function(color)
        flags["Health_Low"].Color = color
        esp.refresh_elements()
    end,
})

VisualsSection:Dropdown({
    Name     = "Healthbar Mode",
    Flag     = "ESPHealthbarMode",
    Options  = { "Static", "Dynamic", "Gradient" },
    Default  = "Dynamic",
    Multi    = false,
    Callback = function(v)
        flags["Healthbar_Mode"] = v
        esp.refresh_elements()
    end,
})

VisualsSection:Toggle({
    Name     = "Health Text",
    Flag     = "ESPHealthText",
    Default  = false,
    Callback = function(state)
        flags["Health_Text"] = state
        esp.refresh_elements()
    end,
}):Colorpicker({
    Name     = "Health Text Color",
    Flag     = "ESPHealthTextColor",
    Color    = Color3.fromRGB(0, 255, 0),
    Alpha    = 0,
    Callback = function(color)
        flags["Health_Text_Color"].Color = color
        esp.refresh_elements()
    end,
})

local ArmorBarToggle = VisualsSection:Toggle({
    Name     = "Armor Bar",
    Flag     = "ESPArmorbar",
    Default  = false,
    Callback = function(state)
        flags["Armorbar"] = state
        esp.refresh_elements()
    end,
})

ArmorBarToggle:Colorpicker({
    Name     = "Armor High Color",
    Flag     = "ESPArmorHighColor",
    Color    = Color3.fromRGB(100, 149, 237),
    Alpha    = 0,
    Callback = function(color)
        flags["Armor_High"].Color = color
        esp.refresh_elements()
    end,
})

ArmorBarToggle:Colorpicker({
    Name     = "Armor Low Color",
    Flag     = "ESPArmorLowColor",
    Color    = Color3.fromRGB(200, 80, 80),
    Alpha    = 0,
    Callback = function(color)
        flags["Armor_Low"].Color = color
        esp.refresh_elements()
    end,
})

VisualsSection:Dropdown({
    Name     = "Armorbar Mode",
    Flag     = "ESPArmorbarMode",
    Options  = {"Static", "Dynamic", "Gradient"},
    Default  = "Dynamic",
    Multi    = false,
    Callback = function(v)
        flags["Armorbar_Mode"] = v
        esp.refresh_elements()
    end,
})

VisualsSection:Toggle({
    Name     = "Armor Text",
    Flag     = "ESPArmorText",
    Default  = false,
    Callback = function(state)
        flags["Armor_Text"] = state
        esp.refresh_elements()
    end,
}):Colorpicker({
    Name     = "Armor Text Color",
    Flag     = "ESPArmorTextColor",
    Color    = Color3.fromRGB(100, 149, 237),
    Alpha    = 0,
    Callback = function(color)
        flags["Armor_Text_Color"].Color = color
        esp.refresh_elements()
    end,
})

VisualsSection:Toggle({
    Name     = "Reload Bar",
    Flag     = "ESPReloadbar",
    Default  = false,
    Callback = function(state)
        flags["Reloadbar"] = state
    end,
}):Colorpicker({
    Name     = "Reload Color",
    Flag     = "ESPReloadColor",
    Color    = Color3.fromRGB(255, 255, 255),
    Alpha    = 0,
    Callback = function(color)
        flags["Reload_Color"].Color = color
    end,
})

VisualsSection:Toggle({
    Name     = "Distance",
    Flag     = "ESPDistance",
    Default  = false,
    Callback = function(state)
        flags["Distance"] = state
        esp.refresh_elements()
    end,
}):Colorpicker({
    Name     = "Distance Color",
    Flag     = "ESPDistanceColor",
    Color  = Color3.fromRGB(255, 255, 255),
    Alpha    = 0,
    Callback = function(color)
        flags["Distance_Color"].Color = color
        esp.refresh_elements()
    end,
})

VisualsSection:Slider({
    Name     = "Distance",
    Flag     = "ESPMaxDistance",
    Min      = 50,
    Max      = 5000,
    Default  = 1000,
    Decimal = 1,
    Suffix   = "st",
    Callback = function(value)
        flags["Max_Distance"] = value
    end,
})

VisualsSection:Toggle({
    Name     = "Limit ESP FPS",
    Flag     = "ESPLimitFPS",
    Default  = false,
    Callback = function(state)
        flags["Limit_ESP_FPS"] = state
    end,
})

VisualsSection:Slider({
    Name     = "ESP FPS Value",
    Flag     = "ESPFPSValue",
    Min      = 10,
    Max      = 144,
    Default  = 80,
    Callback = function(value)
        flags["ESP_FPS_Value"] = value
    end,
})

VisualsSection:Toggle({
    Name     = "Smooth Fade OOR",
    Flag     = "ESPSmoothFadeOOR",
    Default  = false,
    Callback = function(state)
        flags["Smooth_Fade_OOR"] = state
    end,
})

VisualsSection:Toggle({
    Name     = "Smooth Fade Dead",
    Flag     = "ESPSmoothFadeDead",
    Default  = false,
    Callback = function(state)
        flags["Smooth_Fade_Dead"] = state
    end,
})

VisualsSection:Toggle({
    Name     = "Skeleton",
    Flag     = "ESPSkeleton",
    Default  = false,
    Callback = function(state)
        flags["Skeleton"] = state
    end,
}):Colorpicker({
    Name     = "Skeleton Color",
    Flag     = "ESPSkeletonColor",
    Color    = Color3.fromRGB(255, 255, 255),
    Alpha    = 0,
    Callback = function(color)
        flags["Skeleton_Color"].Color = color
    end,
})

VisualsSection:Toggle({
    Name     = "Skeleton Outline",
    Flag     = "ESPSkeletonOutline",
    Default = false,
    Callback = function(state)
        flags["Skeleton_Outline"] = state
    end,
})

VisualsSection:Toggle({
    Name     = "Headdot",
    Flag     = "ESPHeaddot",
    Default  = false,
    Callback = function(state)
        flags["Headdot"] = state
    end,
}):Colorpicker({
    Name     = "Headdot Color",
    Flag     = "ESPHeaddotColor",
    Color    = Color3.fromRGB(255, 255, 255),
    Alpha    = 0,
    Callback = function(color)
        flags["Headdot_Color"] = { Color = color }
    end,
})

VisualsSection:Toggle({
    Name     = "Headdot Outline",
    Flag     = "ESPHeaddotOutline",
    Default = false,
    Callback = function(state)
        flags["Headdot_Outline"] = state
    end,
})

VisualsSection:Slider({
    Name = "Headdot Size",
    Flag = "ESPHeaddotSize",
    Min = 0.1, Max = 5, Default = 1, Decimal = 1,
    Callback = function(v) flags["Headdot_Size"] = v end,
})

VisualsSection:Toggle({
    Name     = "Weapon",
    Flag     = "ESPWeapon",
    Default  = false,
    Callback = function(state)
        flags["Weapon"] = state
        esp.refresh_elements()
    end,
}):Colorpicker({
    Name     = "Weapon Color",
    Flag     = "ESPWeaponColor",
    Color  = Color3.fromRGB(100, 149, 237),
    Alpha    = 0,
    Callback = function(color)
        flags["Weapon_Color"].Color = color
        esp.refresh_elements()
    end,
})

VisualsSection:Label({Name = "Enemy Color"}):Colorpicker({
    Name = "Enemy Color", Flag = "ESPEnemyColor2",
    Color = rgb(255, 255, 255), Alpha = 0,
    Callback = function(color) flags["Enemy_Color"].Color = color; esp.refresh_elements() end,
})
VisualsSection:Label({Name = "Friendly Color"}):Colorpicker({
    Name = "Friendly Color", Flag = "ESPFriendlyColor2",
    Color = rgb(0, 200, 80), Alpha = 0,
    Callback = function(color) flags["Friendly_Color"].Color = color; esp.refresh_elements() end,
})

VisualsSection:Toggle({
    Name     = "Crouch",
    Flag     = "ESPCrouching",
    Default  = false,
    Callback = function(state)
        flags["Crouching"] = state
        esp.refresh_elements()
    end,
}):Colorpicker({
    Name = "Crouch Color", Flag = "ESPCrouchColor",
    Color = Color3.fromRGB(255, 255, 255), Alpha = 0,
    Callback = function(color) flags["Crouch_Color"].Color = color; esp.refresh_elements() end,
})

VisualsSection:Toggle({
    Name     = "Downed",
    Flag     = "ESPDowned",
    Default  = false,
    Callback = function(state)
        flags["Downed"] = state
        esp.refresh_elements()
    end,
}):Colorpicker({
    Name = "Downed Color", Flag = "ESPDownedColor",
    Color = Color3.fromRGB(255, 0, 0), Alpha = 0,
    Callback = function(color) flags["Downed_Color"].Color = color; esp.refresh_elements() end,
})

VisualsSection:Toggle({
    Name     = "ForceField",
    Flag     = "ESPForceField",
    Default  = false,
    Callback = function(state)
        flags["ForceField"] = state
        esp.refresh_elements()
    end,
}):Colorpicker({
    Name = "ForceField Color", Flag = "ESPForceFieldColor",
    Color = Color3.fromRGB(100, 149, 237), Alpha = 0,
    Callback = function(color) flags["ForceField_Color"].Color = color; esp.refresh_elements() end,
})

VisualsSection:Toggle({
    Name     = "Level",
    Flag     = "ESPLevel",
    Default  = false,
    Callback = function(state)
        flags["Level"] = state
        esp.refresh_elements()
    end,
}):Colorpicker({
    Name = "Level Color", Flag = "ESPLevelColor",
    Color = Color3.fromRGB(255, 255, 255), Alpha = 0,
    Callback = function(color) flags["Level_Color"].Color = color; esp.refresh_elements() end,
})

VisualsSection:Toggle({
    Name     = "Combat Zone",
    Flag     = "ESPCombatZone",
    Default  = false,
    Callback = function(state)
        flags["CombatZone"] = state

        if state and not getgenv().CurrentZones then
            getgenv().CurrentZones = {}
        end
        if state then

            if not getgenv()._cz_esp_conn then
                local ev = RepSt:FindFirstChild("Events")
                local czev = ev and ev:FindFirstChild("CombatZone")
                if czev then
                    getgenv()._cz_esp_conn = czev.OnClientEvent:Connect(function(eventType, _, displayName)
                        local zoneName = displayName or "Unknown"
                        if eventType ~= "Leaving" then
                            getgenv().CurrentZones = getgenv().CurrentZones or {}
                            getgenv().CurrentZones[zoneName] = tick()
                        else
                            if getgenv().CurrentZones then
                                getgenv().CurrentZones[zoneName] = nil
                            end
                        end
                    end)
                end
            end
        else
            if getgenv()._cz_esp_conn then
                getgenv()._cz_esp_conn:Disconnect()
                getgenv()._cz_esp_conn = nil
            end
            getgenv().CurrentZones = {}
        end
        esp.refresh_elements()
    end,
}):Colorpicker({
    Name = "Combat Zone Color", Flag = "ESPCombatZoneColor",
    Color = Color3.fromRGB(255, 80, 80), Alpha = 0,
    Callback = function(color) flags["CombatZone_Color"].Color = color; esp.refresh_elements() end,
})

VisualsSection:Toggle({
    Name     = "Scale Text by Distance",
    Flag     = "ESPScaleText",
    Default  = false,
    Callback = function(state)
        flags["ESPScaleText"] = state

        if not state then
            for _, plr in ipairs(esp_players:GetPlayers()) do
                local data = esp[plr.Name]
                if data and data.objects then
                    for _, key in ipairs({"name","distance","weapon","health_text","armor_text",
                        "ff_text","downed_text","crouch_text","level_text","combat_zone_text","reload_text"}) do
                        local lbl = data.objects[key]
                        if lbl then lbl.TextSize = 10 end
                    end
                end
            end
        end
    end,
})


end)() -- split main IIFE to avoid register overflow

;(function() --
local VisualsOtherSection = VisualsPage:Section({Name = "Safe", Side = "Right"})

local SAFE_TYPES   = { "SmallSafe", "MediumSafe", "Register" }
local safe_cache   = {}  
local safe_conn    = nil
local safe_add_conn= nil
local safe_rem_conn= nil

local function safe_is_type(name)
    for _, t in ipairs(SAFE_TYPES) do if name:find(t) then return true end end
    return false
end

local function safe_category_enabled(name)
    if name:find("Register") then return safe_flags.RegEnabled end
    return safe_flags.SafeEnabled
end

local function safe_any_enabled()
    return safe_flags.SafeEnabled or safe_flags.RegEnabled
end
local function safe_get_part(model)
    local parts = model:FindFirstChild("Parts")
    if parts then local p = parts:FindFirstChildWhichIsA("BasePart"); if p then return p end end
    return model:FindFirstChildWhichIsA("BasePart")
end
local function safe_is_broken(model)
    local vals = model:FindFirstChild("Values"); if not vals then return false end
    local b = vals:FindFirstChild("Broken"); return b ~= nil and b.Value == true
end
local function safe_label(model)
    local n = model.Name
    if n:find("MediumSafe") then return "MedSafe" elseif n:find("SmallSafe") then return "SmSafe" elseif n:find("Register") then return "Reg" end
    return n:sub(1,8)
end

function esp:box_solve_part(part)
    if not part then return nil, nil, nil, nil end
    local sz  = part.Size
    local cf  = part.CFrame
    
    local pts = {
        cf * Vector3.new( sz.X/2,  sz.Y/2,  sz.Z/2),
        cf * Vector3.new(-sz.X/2,  sz.Y/2,  sz.Z/2),
        cf * Vector3.new( sz.X/2,  sz.Y/2, -sz.Z/2),
        cf * Vector3.new(-sz.X/2,  sz.Y/2, -sz.Z/2),
        cf * Vector3.new( sz.X/2, -sz.Y/2,  sz.Z/2),
        cf * Vector3.new(-sz.X/2, -sz.Y/2,  sz.Z/2),
        cf * Vector3.new( sz.X/2, -sz.Y/2, -sz.Z/2),
        cf * Vector3.new(-sz.X/2, -sz.Y/2, -sz.Z/2),
    }
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local any_on = false
    for _, p in ipairs(pts) do
        local s, on = esp:get_screen_pos(p)
        if on then
            any_on = true
            if s.X < minX then minX = s.X end
            if s.Y < minY then minY = s.Y end
            if s.X > maxX then maxX = s.X end
            if s.Y > maxY then maxY = s.Y end
        end
    end
    if not any_on then return nil, nil, nil, nil end
    local W = math.max(math.floor(maxX - minX), 6)
    local H = math.max(math.floor(maxY - minY), 6)
    local dist = (part.Position - esp_camera.CFrame.p).Magnitude
    return Vector2.new(W, H), Vector2.new(math.floor(minX), math.floor(minY)), true, dist
end

local function safe_create(model)
    if safe_cache[model] then return end
    local col = safe_flags.NormalColor.Color
    local objects = {}

    objects["holder"] = esp:create("Frame", {
        Parent = esp.cache; Name = "\0"; BackgroundTransparency = 1;
        Position = dim2(0,0,0,0); BorderColor3 = rgb(0,0,0);
        Size = dim2(0,0,0,0); BorderSizePixel = 0; BackgroundColor3 = rgb(255,255,255);
    })
    objects["box_handler"] = esp:create("Frame", {
        Parent = safe_flags.ShowBox and objects["holder"] or esp.cache; Name = "\0";
        BackgroundTransparency = 1; Position = dim2(0,1,0,1); BorderColor3 = rgb(0,0,0);
        Size = dim2(1,-2,1,-2); BorderSizePixel = 0; BackgroundColor3 = rgb(255,255,255);
    })
    objects["box_outline"] = esp:create("UIStroke", {
        Parent = safe_flags.ShowBox and objects["holder"] or esp.cache;
        LineJoinMode = Enum.LineJoinMode.Miter;
    })
    objects["box_color"] = esp:create("UIStroke", {
        Color = col; LineJoinMode = Enum.LineJoinMode.Miter; Name = "\0";
        Parent = objects["box_handler"];
    })
    objects["box_inner"] = esp:create("Frame", {
        Parent = objects["box_handler"]; Name = "\0"; BackgroundTransparency = 1;
        Position = dim2(0,1,0,1); BorderColor3 = rgb(0,0,0);
        Size = dim2(1,-2,1,-2); BorderSizePixel = 0; BackgroundColor3 = rgb(255,255,255);
    })
    esp:create("UIStroke", { Parent = objects["box_inner"]; LineJoinMode = Enum.LineJoinMode.Miter; })
    objects["name"] = esp:create("TextLabel", {
        FontFace = fonts.main; Parent = safe_flags.ShowName and objects["holder"] or esp.cache;
        TextColor3 = safe_flags.NameColor.Color; BorderColor3 = rgb(0,0,0); Text = safe_label(model); Name = "\0";
        TextStrokeTransparency = 0; AnchorPoint = vec2(0,1); Size = dim2(1,0,0,0);
        BackgroundTransparency = 1; Position = dim2(0,0,0,-5); BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.Y; TextSize = 10;
    })
    objects["distance"] = esp:create("TextLabel", {
        FontFace = fonts.main; TextColor3 = safe_flags.DistColor.Color; BorderColor3 = rgb(0,0,0);
        Text = ""; Parent = safe_flags.ShowDist and objects["holder"] or esp.cache;
        TextStrokeTransparency = 0; Name = "\0"; Size = dim2(1,0,0,0);
        BackgroundTransparency = 1; Position = dim2(0,0,1,5); BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.Y; TextSize = 10;
    })
    objects["broken"] = esp:create("TextLabel", {
        FontFace = fonts.main; Parent = objects["holder"]; TextColor3 = rgb(255,80,80);
        BorderColor3 = rgb(0,0,0); Text = "[BROKEN]"; Name = "\0";
        TextStrokeTransparency = 0; AnchorPoint = vec2(0,0); Size = dim2(1,0,0,0);
        BackgroundTransparency = 1; Position = dim2(0,0,1,15); BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.Y; TextSize = 10; Visible = false;
    })
    safe_cache[model] = { objects = objects, part = safe_get_part(model) }
end

local function safe_remove(model)
    local data = safe_cache[model]
    if not data then return end
    local holder = data.objects and data.objects["holder"]
    if holder then
        pcall(function()
            do
                holder:Destroy()
            end
        end)
    end
    safe_cache[model] = nil
end

local function safe_scan()
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("Model") and safe_is_type(d.Name) and not safe_cache[d] then
            safe_create(d)
        end
    end
end

local function safe_refresh_all()
    for _, data in pairs(safe_cache) do
        local o = data.objects
        local col = safe_flags.NormalColor.Color
        o["name"].TextColor3    = safe_flags.NameColor.Color
        o["distance"].TextColor3 = safe_flags.DistColor.Color
        o["box_color"].Color    = col
        o["name"].Parent        = safe_flags.ShowName and o["holder"] or esp.cache
        o["distance"].Parent    = safe_flags.ShowDist and o["holder"] or esp.cache
        o["box_handler"].Parent = safe_flags.ShowBox  and o["holder"] or esp.cache
        o["box_outline"].Parent = safe_flags.ShowBox  and o["holder"] or esp.cache
    end
end

local function safe_esp_start()
    safe_scan()
    safe_add_conn = workspace.DescendantAdded:Connect(function(d)
        if d:IsA("Model") and safe_is_type(d.Name) and not safe_cache[d] then
            task.spawn(safe_create, d)
        end
    end)
    safe_rem_conn = workspace.DescendantRemoving:Connect(function(d)
        if safe_cache[d] then safe_remove(d) end
    end)
    safe_conn = esp_run.RenderStepped:Connect(function()
        if not safe_any_enabled() then return end
        local lp_char = LP.Character
        local lp_hrp  = lp_char and lp_char:FindFirstChild("HumanoidRootPart")
        for model, data in pairs(safe_cache) do
            if not model.Parent then safe_remove(model); continue end
            local objects = data.objects
            local holder  = objects["holder"]
            if not safe_category_enabled(model.Name) then holder.Visible = false; continue end
            local part    = data.part or safe_get_part(model)
            data.part = part
            if not part then holder.Visible = false; continue end
            local dist = lp_hrp and (lp_hrp.Position - part.Position).Magnitude or 0
            if dist > safe_flags.MaxDist then holder.Visible = false; continue end
            local box_size, box_pos, on_screen = esp:box_solve_part(part)
            on_screen = on_screen or false
            if holder.Visible ~= on_screen then holder.Visible = on_screen end
            if not on_screen then continue end
            if holder.Parent ~= esp.screengui then holder.Parent = esp.screengui end
            holder.Position = dim_offset(box_pos.X, box_pos.Y)
            holder.Size     = dim_offset(box_size.X, box_size.Y)
            local is_broken = safe_is_broken(model)
            local col = is_broken and safe_flags.BrokenColor.Color or safe_flags.NormalColor.Color
            objects["name"].TextColor3 = col
            objects["box_color"].Color = col
            objects["broken"].Visible  = is_broken and safe_flags.ShowBroken
            objects["distance"].Text   = math.round(dist) .. "st"
        end
    end)
end

local function safe_esp_stop()
    if safe_conn     then safe_conn:Disconnect();     safe_conn     = nil end
    if safe_add_conn then safe_add_conn:Disconnect(); safe_add_conn = nil end
    if safe_rem_conn then safe_rem_conn:Disconnect(); safe_rem_conn = nil end
    --
    local models_to_remove = {}
    for model in pairs(safe_cache) do table.insert(models_to_remove, model) end
    for _, model in ipairs(models_to_remove) do safe_remove(model) end
end

local function safe_esp_sync()
    if safe_any_enabled() then
        if not safe_conn then safe_esp_start() end
    else
        if safe_conn then safe_esp_stop() end
    end
end

VisualsOtherSection:Toggle({
    Name = "Safe", Flag = "SafeESPEnabled", Default = false,
    Callback = function(state)
        safe_flags.SafeEnabled = state
        safe_esp_sync()
    end,
})
VisualsOtherSection:Toggle({
    Name = "Reg", Flag = "RegESPEnabled", Default = false,
    Callback = function(state)
        safe_flags.RegEnabled = state
        safe_esp_sync()
    end,
})
VisualsOtherSection:Toggle({
    Name = "Box", Flag = "SafeRegESPBox", Default = false,
    Callback = function(state)
        safe_flags.ShowBox = state
        for _, data in pairs(safe_cache) do
            local o = data.objects
            o["box_handler"].Parent = state and o["holder"] or esp.cache
            o["box_outline"].Parent = state and o["holder"] or esp.cache
        end
    end,
}):Colorpicker({
    Name = "Box Color", Flag = "SafeRegESPColor", Color = rgb(255, 255, 255), Alpha = 0,
    Callback = function(color) safe_flags.NormalColor.Color = color; safe_refresh_all() end,
})
VisualsOtherSection:Toggle({
    Name = "Name", Flag = "SafeRegESPName", Default = false,
    Callback = function(state)
        safe_flags.ShowName = state
        for _, data in pairs(safe_cache) do
            data.objects["name"].Parent = state and data.objects["holder"] or esp.cache
        end
    end,
}):Colorpicker({
    Name = "Name Color", Flag = "SafeRegESPNameColor", Color = rgb(255, 255, 255), Alpha = 0,
    Callback = function(color)
        safe_flags.NameColor.Color = color
        for _, data in pairs(safe_cache) do data.objects["name"].TextColor3 = color end
    end,
})
VisualsOtherSection:Toggle({
    Name = "Distance", Flag = "SafeRegESPDistToggle", Default = false,
    Callback = function(state)
        safe_flags.ShowDist = state
        for _, data in pairs(safe_cache) do
            data.objects["distance"].Parent = state and data.objects["holder"] or esp.cache
        end
    end,
}):Colorpicker({
    Name = "Distance Color", Flag = "SafeRegESPDistColor", Color = rgb(255, 255, 255), Alpha = 0,
    Callback = function(color)
        safe_flags.DistColor.Color = color
        for _, data in pairs(safe_cache) do data.objects["distance"].TextColor3 = color end
    end,
})
VisualsOtherSection:Toggle({
    Name = "Broken Tag", Flag = "SafeRegESPBrokenToggle", Default = false,
    Callback = function(state) safe_flags.ShowBroken = state end,
}):Colorpicker({
    Name = "Broken Color", Flag = "SafeRegESPBroken", Color = rgb(255, 0, 0), Alpha = 0,
    Callback = function(color)
        safe_flags.BrokenColor.Color = color
        for _, data in pairs(safe_cache) do data.objects["broken"].TextColor3 = color end
    end,
})
VisualsOtherSection:Slider({
    Name = "Max Distance", Flag = "SafeRegESPMaxDist",
    Min = 50, Max = 2000, Default = 500, Decimal = 1, Suffix = "st",
    Callback = function(v) safe_flags.MaxDist = v end,
})
end)() -- 

;(function()
local WorldSection  = WorldPage:Section({Name = "World",     Side = "Left"})
local WorldSection2 = WorldPage:Section({Name = "Visual FX", Side = "Left"})

;(function()
local GrenadeTrajectorySection = MiscPage:Section({Name = "Grenade Trajectory", Side = "Left"})

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Players       = Plrs
local RunService    = RS
local Workspace     = workspace
local HttpService   = game:GetService("HttpService")
local PhysicsService = game:GetService("PhysicsService")
local LocalPlayer   = LP
local Mouse         = LocalPlayer:GetMouse()

local CONFIG = {
	DEFAULT_THROW_SPEED = 150,
	EFFECTIVE_GRAVITY_SCALE = 0.55,
	DEFAULT_FUSE_TIME = 2.5,
	MAX_PREDICT_TIME = 6,
	UNTIL_SLOW_MAX_TIME = 8,
	SIMULATION_DT = 1 / 90,
	MAX_BOUNCES = 6,
	MAX_POINTS = 220,
	MIN_SPEED = 1.25,
	BASE_MIN_RESTITUTION = 0.012,
	BASE_MAX_RESTITUTION = 0.24,
	BASE_MIN_TANGENT_DAMPING = 0.45,
	BASE_MAX_TANGENT_DAMPING = 0.92,
	LOW_SPEED_RESTITUTION_CUTOFF = 22,
	LOW_SPEED_RESTITUTION_MULT = 0.35,
	THROW_DELAY_SAFETY = 0.55,
	PREVIEW_UPDATE_INTERVAL = 1 / 30,
	PREVIEW_COLOR = Color3.fromRGB(255, 60, 60),
	PREVIEW_TRANSPARENCY = 0.15,
	PREVIEW_THICKNESS = 0.11,
	FIRST_PERSON_START_OFFSET = 0.35,
	CAMERA_NEAR_CLIP_DISTANCE = 1.4,
	LIVE_COLOR = Color3.fromRGB(255, 170, 120),
	LIVE_TRANSPARENCY = 0.2,
	LIVE_THICKNESS = 0.1,
	LIVE_SAMPLE_DT = 1 / 60,
	LIVE_TTL = 0.55,
	MAX_LIVE_TIME = 6,
	FLIGHT_MIN_START_SPEED = 8,
}

local function randomName(prefix)
	local ok, guid = pcall(function()
		return HttpService:GenerateGUID(false)
	end)
	if ok and type(guid) == "string" then
		local cleaned = string.gsub(guid, "%-", "")
		return string.format("%s%s", prefix, string.sub(cleaned, 1, 12))
	end
	return string.format("%s%d", prefix, math.random(100000, 999999))
end

local rootParent = Workspace:FindFirstChild("Debris") or Workspace

local runTag = randomName("r_")
for _, child in ipairs(rootParent:GetChildren()) do
	if child:IsA("BasePart") and child:GetAttribute("gt_line") == true then
		child:Destroy()
	end
end

local previewParent = rootParent
local liveParent = rootParent

local function getCharacter()
	return LocalPlayer.Character
end

local function getHead(character)
	if not character then
		return nil
	end
	return character:FindFirstChild("Head")
end

local function getAimPoint()
	local global = rawget(_G, "GetMousePoint")
	if type(global) == "function" then
		local ok, point = pcall(global)
		if ok and typeof(point) == "Vector3" then
			return point
		end
	end

	if Mouse and Mouse.Hit then
		return Mouse.Hit.Position
	end

	local camera = Workspace.CurrentCamera
	if camera then
		return camera.CFrame.Position + (camera.CFrame.LookVector * 500)
	end

	return Vector3.zero
end

local function isThrowableTool(tool)
	if not tool or not tool:IsA("Tool") then
		return false
	end

	local handle = tool:FindFirstChild("Handle")
	local rightGrip = tool:FindFirstChild("RightGrip")
	local gripPart = (handle and handle:IsA("BasePart") and handle) or (rightGrip and rightGrip:IsA("BasePart") and rightGrip) or nil
	if not gripPart then
		return false
	end

	local event = tool:FindFirstChild("Event")
	if not (event and event:IsA("RemoteEvent")) then
		return false
	end

	local pin = tool:FindFirstChild("PinPulled")
	if not (pin and pin:IsA("BoolValue")) then
		return false
	end

	return tool:FindFirstChild("AnimsFolder") ~= nil
end

local function getGripPart(tool)
	local handle = tool:FindFirstChild("Handle")
	if handle and handle:IsA("BasePart") then
		return handle
	end

	local rightGrip = tool:FindFirstChild("RightGrip")
	if rightGrip and rightGrip:IsA("BasePart") then
		return rightGrip
	end

	return nil
end

local function findServerScript(tool)
	for _, child in ipairs(tool:GetChildren()) do
		if child:IsA("Script") then
			local low = string.lower(child.Name)
			if string.find(low, "server", 1, true) then
				return child
			end
		end
	end
	return nil
end

local function getScriptSource(scriptObject)
	if not scriptObject then
		return nil
	end
	local ok, source = pcall(function()
		return scriptObject.Source
	end)
	if ok and type(source) == "string" and #source > 0 then
		return source
	end
	return nil
end

local parseSettings, evalSimpleExpression, analyzeToolProfile
do
local function _parseSettings(source)
	local settings = {}
	local startPos = string.find(source, "local Settings%s*=%s*{")
	if not startPos then
		return settings
	end

	local braceStart = string.find(source, "{", startPos, true)
	if not braceStart then
		return settings
	end

	local depth = 0
	local braceEnd = nil
	for i = braceStart, #source do
		local ch = string.sub(source, i, i)
		if ch == "{" then
			depth += 1
		elseif ch == "}" then
			depth -= 1
			if depth == 0 then
				braceEnd = i
				break
			end
		end
	end

	if not braceEnd then
		return settings
	end

	local block = string.sub(source, braceStart + 1, braceEnd - 1)
	for key, raw in string.gmatch(block, "([%a_][%w_]*)%s*=%s*([^;\n,]+)") do
		local clean = string.gsub(raw, "%-%-.*", "")
		clean = string.gsub(clean, "%s+", "")
		local number = tonumber(clean)
		if number then
			settings[key] = number
		end
	end

	return settings
end
parseSettings = _parseSettings

local function _evalSimpleExpression(expr, settings)
	if not expr then return nil end
	local rewritten = string.gsub(expr, "Settings%.([%a_][%w_]*)", function(key)
		local v = settings[key]
		return v and tostring(v) or "0"
	end)
	rewritten = string.gsub(rewritten, "%s+", "")
	if rewritten == "" then return nil end
	local direct = tonumber(rewritten)
	if direct then return direct end
	local a, op, b = string.match(rewritten, "^(%-?[%d%.]+)([%+%-%*/])(%-?[%d%.]+)$")
	a = tonumber(a); b = tonumber(b)
	if not (a and b and op) then return nil end
	if op == "+" then return a + b
	elseif op == "-" then return a - b
	elseif op == "*" then return a * b
	elseif op == "/" then return b ~= 0 and a / b or nil end
	return nil
end
evalSimpleExpression = _evalSimpleExpression

local function _analyzeToolProfile(tool)
	local profile = {
		mode = "fallback",
		throwSpeed = CONFIG.DEFAULT_THROW_SPEED,
		maxPredictTime = CONFIG.MAX_PREDICT_TIME,
		throwFuse = CONFIG.DEFAULT_FUSE_TIME,
		pullFuse = nil,
		minFlight = 0,
		stopSpeed = nil,
		touchFuseDelay = nil,
		explodeOnTouch = false,
	}
	local handle = getGripPart(tool)
	local throwSoundId = nil
	local hasAttachmentX, hasClickDetector, hasBouncePack, hasSingleBounce = false, false, false, false
	if tool:FindFirstChild("Lighter") then profile.explodeOnTouch = true end
	if handle then
		hasAttachmentX   = handle:FindFirstChild("X") ~= nil
		hasClickDetector = handle:FindFirstChild("ClickDetector") ~= nil
		hasBouncePack    = handle:FindFirstChild("Bounce1") ~= nil
		hasSingleBounce  = handle:FindFirstChild("Bounce") ~= nil
		if handle:FindFirstChild("ExtinguishS") or handle:FindFirstChild("FireIdle")
			or handle:FindFirstChild("Spark") or handle:FindFirstChild("CanForce") then
			profile.explodeOnTouch = true
		end
		local throwSound = handle:FindFirstChild("Throw")
		if throwSound and throwSound:IsA("Sound") then
			throwSoundId = tostring(throwSound.SoundId)
			if string.find(throwSoundId, "1657151608", 1, true) then
				profile.explodeOnTouch = true
			end
		end
	end
	local function applyStructuralFallback()
		if profile.explodeOnTouch then
			profile.mode = "fixed_after_pull"
			profile.pullFuse = tool:FindFirstChild("Lighter") and 5 or 7
			profile.maxPredictTime = tool:FindFirstChild("Lighter") and 3.5 or 6.25
			return
		end
		if hasBouncePack then
			profile.mode = "fixed_after_throw"
			if hasAttachmentX or hasClickDetector then
				profile.throwFuse = 2.5; profile.maxPredictTime = 2.5
			else
				profile.throwFuse = 1.8 + CONFIG.THROW_DELAY_SAFETY
				profile.maxPredictTime = 1.8 + CONFIG.THROW_DELAY_SAFETY
			end
			return
		end
		if hasSingleBounce then
			if throwSoundId and string.find(throwSoundId, "360521794", 1, true) then
				profile.mode = "until_slow"; profile.minFlight = 0.75
				profile.stopSpeed = 4; profile.maxPredictTime = 4.8
			else
				profile.mode = "fixed_after_throw"
				profile.throwFuse = 1.8 + CONFIG.THROW_DELAY_SAFETY
				profile.maxPredictTime = 1.8 + CONFIG.THROW_DELAY_SAFETY
			end
		end
	end
	local serverScript = findServerScript(tool)
	local source = getScriptSource(serverScript)
	if not source then applyStructuralFallback(); return profile end
	local settings = _parseSettings(source)
	if settings.VELOCITY then profile.throwSpeed = settings.VELOCITY end
	if string.find(source, "Explode(Handle.CFrame,true)", 1, true)
		or string.find(source, "Explode(Handle.CFrame,\"Water\")", 1, true)
		or string.find(source, "Explode(\"Water\")", 1, true) then
		profile.explodeOnTouch = true
	end
	if string.find(source, "delay(Settings.ExplodeTime - Settings.PullTime", 1, true) and settings.ExplodeTime then
		profile.mode = "fixed_after_pull"
		profile.pullFuse = settings.ExplodeTime
		profile.maxPredictTime = math.max(0.2, settings.ExplodeTime)
		return profile
	end
	if string.find(source, "function DoTimer()", 1, true) and settings.ExplodeTime then
		profile.mode = "fixed_after_throw"
		profile.throwFuse = settings.ExplodeTime
		profile.maxPredictTime = math.max(0.2, settings.ExplodeTime)
		return profile
	end
	local minFlightExpr = string.match(source, "fastWait%(([^%)]+)%)%s*[\r\n]+%s*repeat%s+fastWait")
	local stopSpeedValue = tonumber(string.match(source, "until%s+Handle%.Velocity%.Magnitude%s*<=%s*([%d%.]+)"))
	local minFlightValue = _evalSimpleExpression(minFlightExpr, settings)
	if stopSpeedValue and minFlightValue then
		profile.mode = "until_slow"
		profile.minFlight = math.max(0, minFlightValue)
		profile.stopSpeed = stopSpeedValue
		profile.maxPredictTime = stopSpeedValue <= 3 and 5.1 or 4.6
		return profile
	end
	local maxDelay, minDelay = nil, nil
	for expr in string.gmatch(source, "delay%(([^,]+),%s*function%s*%(") do
		local value = _evalSimpleExpression(expr, settings)
		if value and value > 0 then
			if (not maxDelay) or value > maxDelay then maxDelay = value end
			if (not minDelay) or value < minDelay then minDelay = value end
		end
	end
	if maxDelay then
		profile.mode = "fixed_after_throw"
		profile.throwFuse = maxDelay + CONFIG.THROW_DELAY_SAFETY
		profile.maxPredictTime = math.max(0.2, maxDelay + CONFIG.THROW_DELAY_SAFETY)
		if minDelay and minDelay < maxDelay then profile.touchFuseDelay = minDelay end
	else
		applyStructuralFallback()
	end
	return profile
end
analyzeToolProfile = _analyzeToolProfile
end -- /do analyzeToolProfile

-- экспортируем в getgenv для второй половины
getgenv()._GT_CONFIG           = CONFIG
getgenv()._GT_getCharacter     = getCharacter
getgenv()._GT_getHead          = getHead
getgenv()._GT_getAimPoint      = getAimPoint
getgenv()._GT_isThrowableTool  = isThrowableTool
getgenv()._GT_getGripPart      = getGripPart
getgenv()._GT_analyzeToolProfile = analyzeToolProfile
getgenv()._GT_randomName       = randomName
getgenv()._GT_runTag           = runTag
getgenv()._GT_rootParent       = rootParent
getgenv()._GT_previewParent    = previewParent
getgenv()._GT_liveParent       = liveParent
getgenv()._GT_Section          = GrenadeTrajectorySection

end)() -- конец первой половины гранатного блока

-- вторая половина
;(function()
local Players       = Plrs
local RunService    = RS
local Workspace     = workspace
local PhysicsService = game:GetService("PhysicsService")
local LocalPlayer   = LP
local Mouse         = LocalPlayer:GetMouse()

local GrenadeTrajectoryEnabled = true
local GrenadeTrajectoryConn

local CONFIG = getgenv()._GT_CONFIG
local getCharacter       = getgenv()._GT_getCharacter
local getHead            = getgenv()._GT_getHead
local getAimPoint        = getgenv()._GT_getAimPoint
local isThrowableTool    = getgenv()._GT_isThrowableTool
local getGripPart        = getgenv()._GT_getGripPart
local analyzeToolProfile = getgenv()._GT_analyzeToolProfile
local randomName         = getgenv()._GT_randomName
local runTag             = getgenv()._GT_runTag
local rootParent         = getgenv()._GT_rootParent
local previewParent      = getgenv()._GT_previewParent
local liveParent         = getgenv()._GT_liveParent
local GrenadeTrajectorySection = getgenv()._GT_Section

local function isFirstPerson(head)
	local camera = Workspace.CurrentCamera
	if not (camera and head) then return false end
	return (camera.CFrame.Position - head.Position).Magnitude <= 1.1
end

local function getSimulationWindow(state, nowTick)
	local profile = state.profile or {}
	local maxTime = profile.maxPredictTime or CONFIG.MAX_PREDICT_TIME
	local minFlight, stopSpeed = 0, nil
	local touchFuseDelay = profile.touchFuseDelay
	local explodeOnTouch = profile.explodeOnTouch == true
	if profile.mode == "fixed_after_throw" then
		maxTime = math.max(0.05, profile.throwFuse or CONFIG.DEFAULT_FUSE_TIME)
	elseif profile.mode == "fixed_after_pull" then
		local held = state.pinPulledAt and (nowTick - state.pinPulledAt) or 0
		maxTime = math.max(0.05, (profile.pullFuse or CONFIG.DEFAULT_FUSE_TIME) - held)
	elseif profile.mode == "until_slow" then
		minFlight = profile.minFlight or 0
		stopSpeed = profile.stopSpeed
		maxTime = profile.maxPredictTime or CONFIG.UNTIL_SLOW_MAX_TIME
	end
	local timerValue = state.timerValue
	if timerValue and timerValue > 0 then
		if state.timerIsCountdown then maxTime = math.min(maxTime, math.max(0.05, timerValue))
		elseif profile.mode == "fallback" then maxTime = math.min(maxTime, timerValue) end
	end
	return maxTime, minFlight, stopSpeed, touchFuseDelay, explodeOnTouch
end

local makeLineSegment, clearPool, placeSegment, renderPath
do
	local function _makeLineSegment(parent, color, transparency)
		local p = Instance.new("Part")
		p.Name = randomName("s_")
		p.Anchored = true; p.CanCollide = false; p.CanQuery = false
		p.CanTouch = false; p.CastShadow = false
		p.Material = Enum.Material.Neon
		p.Color = color; p.Transparency = transparency
		p.Size = Vector3.new(0.08, 0.08, 0.08)
		p:SetAttribute("gt_line", true); p:SetAttribute("gt_run", runTag)
		p.Parent = parent
		return p
	end
	makeLineSegment = _makeLineSegment

	local function _clearPool(pool)
		for i = 1, #pool do if pool[i] then pool[i]:Destroy() end end
		table.clear(pool)
	end
	clearPool = _clearPool

	local function _placeSegment(part, p0, p1, thickness, color, transparency)
		local delta = p1 - p0
		local len = delta.Magnitude
		if len < 0.001 then part.Transparency = 1; return end
		part.Color = color; part.Transparency = transparency
		part.Size = Vector3.new(thickness, thickness, len)
		part.CFrame = CFrame.lookAt((p0 + p1) * 0.5, p1)
	end
	placeSegment = _placeSegment

	local function _renderPath(points, pool, parent, color, transparency, thickness, clipNearCamera)
		local needed = math.max(0, #points - 1)
		local camera = clipNearCamera and Workspace.CurrentCamera or nil
		local skipUntil = 1
		if camera then
			local camPos = camera.CFrame.Position
			local near = CONFIG.CAMERA_NEAR_CLIP_DISTANCE
			while skipUntil < #points and (points[skipUntil] - camPos).Magnitude <= near do
				skipUntil += 1
			end
		end
		for i = 1, needed do
			local seg = pool[i]
			if not seg then seg = _makeLineSegment(parent, color, transparency); pool[i] = seg
			elseif seg.Parent ~= parent then seg.Parent = parent end
			if i < skipUntil then seg.Parent = nil; continue end
			_placeSegment(seg, points[i], points[i+1], thickness, color, transparency)
		end
		for i = needed + 1, #pool do if pool[i] then pool[i].Parent = nil end end
	end
	renderPath = _renderPath
end

local buildCastParams, castWithRadius, pushPoint, simulateTrajectory
do
	local function _buildCastParams(ignoreTool)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.IgnoreWater = false
		pcall(function() params.RespectCanCollide = true end)
		local cgName = rawget(_G, "CG_NCC")
		if type(cgName) == "string" and cgName ~= "" then
			local ok = pcall(function() params.CollisionGroup = cgName end)
			if not ok then
				local gok, groups = pcall(function() return PhysicsService:GetRegisteredCollisionGroups() end)
				if gok and type(groups) == "table" then
					for _, g in ipairs(groups) do
						if g and g.name == cgName then pcall(function() params.CollisionGroup = cgName end); break end
					end
				end
			end
		end
		local filter = {}
		local character = getCharacter()
		if character then table.insert(filter, character) end
		local chars = Workspace:FindFirstChild("Characters")
		if chars then table.insert(filter, chars) end
		if ignoreTool then table.insert(filter, ignoreTool) end
		params.FilterDescendantsInstances = filter
		return params
	end
	buildCastParams = _buildCastParams

	local function _castWithRadius(origin, radius, direction, params)
		if typeof(Workspace.Spherecast) == "function" then return Workspace:Spherecast(origin, radius, direction, params) end
		return Workspace:Raycast(origin, direction, params)
	end
	castWithRadius = _castWithRadius

	local function _pushPoint(points, point)
		local last = points[#points]
		if not last then points[1] = point; return end
		if (last - point).Magnitude <= 0.01 then points[#points] = point; return end
		table.insert(points, point)
	end
	pushPoint = _pushPoint

	local function _simulateTrajectory(tool, state, nowTick)
		local character = getCharacter()
		local head = getHead(character)
		if not head then return {} end
		local startPos = head.Position
		local aimPoint = getAimPoint()
		local toAim = aimPoint - startPos
		if toAim.Magnitude < 0.001 then return {} end
		local direction = toAim.Unit
		local renderStartPos = startPos
		if isFirstPerson(head) then renderStartPos = startPos + (direction * CONFIG.FIRST_PERSON_START_OFFSET) end
		local handle = state.handle
		if not handle or not handle.Parent then return {} end
		local hb = handle:FindFirstChild("HB")
		local collisionPart = (hb and hb:IsA("BasePart")) and hb or handle
		local radius = math.max(collisionPart.Size.X, collisionPart.Size.Y, collisionPart.Size.Z) * 0.5
		local params = _buildCastParams(tool)
		local profile = state.profile or {}
		local speed = state.learnedSpeed or profile.throwSpeed or CONFIG.DEFAULT_THROW_SPEED
		local gravity = Vector3.new(0, -Workspace.Gravity * CONFIG.EFFECTIVE_GRAVITY_SCALE, 0)
		local maxTime, minFlight, stopSpeed, touchFuseDelay, explodeOnTouch = getSimulationWindow(state, nowTick)
		maxTime = math.min(maxTime, CONFIG.UNTIL_SLOW_MAX_TIME)
		local points = {renderStartPos}
		local position = startPos
		local velocity = direction * speed
		local elapsed, bounces = 0, 0
		local dynamicMaxTime = maxTime
		while elapsed < dynamicMaxTime and #points < CONFIG.MAX_POINTS do
			local step = math.min(CONFIG.SIMULATION_DT, dynamicMaxTime - elapsed)
			local displacement = (velocity * step) + (0.5 * gravity * step * step)
			local hit = _castWithRadius(position, radius, displacement, params)
			if hit and hit.Instance and hit.Instance ~= Workspace.Terrain and (not hit.Instance.CanCollide) then hit = nil end
			if hit then
				local travel = displacement.Magnitude
				local alpha = travel > 1e-5 and math.clamp((hit.Position - position).Magnitude / travel, 0, 1) or 1
				local hitTime = step * alpha
				local centerAtHit = hit.Position + (hit.Normal * radius)
				_pushPoint(points, centerAtHit)
				local impactVel = velocity + (gravity * hitTime)
				local normalSpeed = impactVel:Dot(hit.Normal)
				local normalVel = hit.Normal * normalSpeed
				local tangentVel = impactVel - normalVel
				if normalSpeed < 0 then
					local friction = state.surfaceFriction or 2
					local elasticity = state.surfaceElasticity or 0
					local upDot = math.abs(hit.Normal:Dot(Vector3.yAxis))
					local td = math.clamp(1-(friction*0.15), CONFIG.BASE_MIN_TANGENT_DAMPING, CONFIG.BASE_MAX_TANGENT_DAMPING)
					local rest = math.clamp(CONFIG.BASE_MIN_RESTITUTION+(elasticity*0.85), CONFIG.BASE_MIN_RESTITUTION, CONFIG.BASE_MAX_RESTITUTION)
					if upDot > 0.75 then td *= 0.9; rest *= 0.62
					elseif upDot < 0.35 then td *= 0.78; rest *= 0.5
					else td *= 0.84; rest *= 0.75 end
					if impactVel.Magnitude <= CONFIG.LOW_SPEED_RESTITUTION_CUTOFF then rest *= CONFIG.LOW_SPEED_RESTITUTION_MULT end
					velocity = (tangentVel * td) - (normalVel * rest)
				else
					local td = math.clamp(1-((state.surfaceFriction or 2)*0.15), CONFIG.BASE_MIN_TANGENT_DAMPING, CONFIG.BASE_MAX_TANGENT_DAMPING)
					velocity = impactVel * td
				end
				position = centerAtHit + (hit.Normal * 0.02)
				if explodeOnTouch then dynamicMaxTime = math.min(dynamicMaxTime, elapsed+hitTime+0.02); break end
				if touchFuseDelay then
					local tfa = elapsed+hitTime+touchFuseDelay
					if tfa < dynamicMaxTime then dynamicMaxTime = tfa end
				end
				bounces += 1
				if bounces >= CONFIG.MAX_BOUNCES then break end
			else
				position += displacement
				velocity += gravity * step
				_pushPoint(points, position)
			end
			if velocity.Magnitude <= CONFIG.MIN_SPEED then break end
			if stopSpeed and elapsed >= minFlight and velocity.Magnitude <= stopSpeed then break end
			elapsed += step
		end
		return points
	end
	simulateTrajectory = _simulateTrajectory
end

do -- runtime state + render loop
local toolStates = {}
local previewSegments = {}
local activeFlights = {}
local activeByPart = {}
local previewTool = nil
local lastPreviewTick = 0

local function addTool(tool)
	if toolStates[tool] or not isThrowableTool(tool) then
		return
	end

	local pin = tool:FindFirstChild("PinPulled")
	local timerObj = pin and pin:FindFirstChild("Timer")
	local handle = getGripPart(tool)
	local hb = handle and handle:FindFirstChild("HB")
	local collisionPart = (hb and hb:IsA("BasePart")) and hb or handle
	local friction = 2
	local elasticity = 0
	if collisionPart and collisionPart:IsA("BasePart") then
		local cpp = collisionPart.CustomPhysicalProperties
		if cpp then
			friction = cpp.Friction
			elasticity = cpp.Elasticity
		end
	end
	local state = {
		tool = tool,
		handle = handle,
		pin = pin,
		timerObj = timerObj,
		timerValue = (timerObj and timerObj:IsA("NumberValue")) and timerObj.Value or nil,
		lastTimerValue = (timerObj and timerObj:IsA("NumberValue")) and timerObj.Value or nil,
		timerIsCountdown = false,
		lastPin = pin and pin.Value or false,
		pinPulledAt = (pin and pin.Value) and os.clock() or nil,
		flightStarted = false,
		profile = analyzeToolProfile(tool),
		surfaceFriction = friction,
		surfaceElasticity = elasticity,
		learnedSpeed = nil,
	}
	if state.profile and state.profile.throwSpeed then
		state.learnedSpeed = state.profile.throwSpeed
	end
	toolStates[tool] = state
end

local function startFlight(state)
	local handle = state.handle
	if not handle or not handle:IsA("BasePart") or activeByPart[handle] then
		return
	end

	local flight = {
		part = handle,
		points = {},
		segments = {},
		lastSample = 0,
		startedAt = os.clock(),
	}
	activeByPart[handle] = flight
	table.insert(activeFlights, flight)

	local speedNow = handle.AssemblyLinearVelocity.Magnitude
	if speedNow > 40 then
		local base = (state.profile and state.profile.throwSpeed) or CONFIG.DEFAULT_THROW_SPEED
		state.learnedSpeed = math.clamp(speedNow, base * 0.85, base * 1.2)
	end
end

local function cleanupFlight(index)
	local flight = activeFlights[index]
	if not flight then
		return
	end
	activeByPart[flight.part] = nil
	clearPool(flight.segments)
	table.remove(activeFlights, index)
end

local function extractPositions(trailPoints)
	local out = table.create(#trailPoints)
	for i = 1, #trailPoints do
		out[i] = trailPoints[i].pos
	end
	return out
end

local function getEquippedThrowableTool()
	local character = getCharacter()
	if not character then
		return nil
	end

	for _, obj in ipairs(character:GetChildren()) do
		if obj:IsA("Tool") and toolStates[obj] then
			return obj
		end
	end
	return nil
end

local function scanForTools()
	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
	if backpack then
		for _, obj in ipairs(backpack:GetChildren()) do
			addTool(obj)
		end
	end

	local character = getCharacter()
	if character then
		for _, obj in ipairs(character:GetChildren()) do
			addTool(obj)
		end
	end
end

GrenadeTrajectorySection:Toggle({
	Name     = "Enabled",
	Flag     = "GrenadeTrajectoryEnabled",
	Default = false,
	Callback = function(state)
		GrenadeTrajectoryEnabled = state
		if state then
			startGrenadeTrajectory()  -- запускаем петлю только при первом включении
		end
		if not state then
			renderPath({}, previewSegments, previewParent, CONFIG.PREVIEW_COLOR, CONFIG.PREVIEW_TRANSPARENCY, CONFIG.PREVIEW_THICKNESS, true)
			for i = #activeFlights, 1, -1 do
				cleanupFlight(i)
			end
		end
	end,
}):Colorpicker({
	Name     = "Preview Color",
	Flag     = "GrenadeTrajectoryPreviewColor",
	Color    = CONFIG.PREVIEW_COLOR,
	Alpha    = CONFIG.PREVIEW_TRANSPARENCY,
	Callback = function(color, alpha)
		CONFIG.PREVIEW_COLOR = color
		if alpha then CONFIG.PREVIEW_TRANSPARENCY = alpha end
	end,
})

GrenadeTrajectorySection:Colorpicker({
	Name     = "Live Color",
	Flag     = "GrenadeTrajectoryLiveColor",
	Color    = CONFIG.LIVE_COLOR,
	Alpha    = CONFIG.LIVE_TRANSPARENCY,
	Callback = function(color, alpha)
		CONFIG.LIVE_COLOR = color
		if alpha then CONFIG.LIVE_TRANSPARENCY = alpha end
	end,
})

GrenadeTrajectorySection:Slider({
	Name     = "Line Thickness",
	Flag     = "GrenadeTrajectoryThickness",
	Min      = 0.02,
	Max      = 0.4,
	Default  = CONFIG.PREVIEW_THICKNESS,
	Decimal  = 0.02,
	Callback = function(value)
		CONFIG.PREVIEW_THICKNESS = value
		CONFIG.LIVE_THICKNESS = value
	end,
})

GrenadeTrajectorySection:Slider({
	Name     = "Prediction Time",
	Flag     = "GrenadeTrajectoryPredictTime",
	Min      = 1,
	Max      = 8,
	Default  = CONFIG.MAX_PREDICT_TIME,
	Decimal  = 1,
	Callback = function(value)
		CONFIG.MAX_PREDICT_TIME = value
		CONFIG.UNTIL_SLOW_MAX_TIME = math.max(value, CONFIG.UNTIL_SLOW_MAX_TIME)
	end,
})

GrenadeTrajectoryEnabled = false
-- коннект создаётся лениво при первом включении тоггла
local function startGrenadeTrajectory()
	if GrenadeTrajectoryConn then return end
	GrenadeTrajectoryConn = RunService.RenderStepped:Connect(function()
	if not GrenadeTrajectoryEnabled then return end

	local nowTick = os.clock()
	scanForTools()

	local character = getCharacter()
	for tool, state in pairs(toolStates) do
		if not tool:IsDescendantOf(game) then
			if previewTool == tool then
				previewTool = nil
			end
			toolStates[tool] = nil
		else
			local pin = state.pin
			if pin and pin.Parent then
				if pin.Value ~= state.lastPin then
					state.lastPin = pin.Value
					if pin.Value then
						state.pinPulledAt = nowTick
					else
						state.pinPulledAt = nil
						state.flightStarted = false
						state.timerIsCountdown = false
						if state.timerObj and state.timerObj:IsA("NumberValue") then
							state.lastTimerValue = state.timerObj.Value
							state.timerValue = state.timerObj.Value
						end
					end
				end
			end

			if (not state.timerObj) or (not state.timerObj.Parent) then
				if pin and pin.Parent then
					local maybeTimer = pin:FindFirstChild("Timer")
					if maybeTimer and maybeTimer:IsA("NumberValue") then
						state.timerObj = maybeTimer
					end
				end
			end

			local timerObj = state.timerObj
			if timerObj and timerObj.Parent and timerObj:IsA("NumberValue") then
				local currentTimer = timerObj.Value
				local lastTimer = state.lastTimerValue
				state.timerValue = currentTimer
				if lastTimer and (currentTimer < (lastTimer - 0.01)) then
					state.timerIsCountdown = true
				end
				state.lastTimerValue = currentTimer
			else
				state.timerValue = nil
			end

			local handle = state.handle
			if handle and handle.Parent then
				if handle:IsDescendantOf(tool) then
					state.flightStarted = false
				elseif not state.flightStarted and handle:IsDescendantOf(Workspace) and (not character or not handle:IsDescendantOf(character)) then
					if handle.AssemblyLinearVelocity.Magnitude > CONFIG.FLIGHT_MIN_START_SPEED then
						state.flightStarted = true
						startFlight(state)
						if previewTool == tool then
							previewTool = nil
							renderPath({}, previewSegments, previewParent, CONFIG.PREVIEW_COLOR, CONFIG.PREVIEW_TRANSPARENCY, CONFIG.PREVIEW_THICKNESS, true)
						end
					end
				end
			end
		end
	end

	local equipped = getEquippedThrowableTool()
	if equipped ~= previewTool then
		previewTool = equipped
		lastPreviewTick = 0
	end

	if previewTool and (nowTick - lastPreviewTick >= CONFIG.PREVIEW_UPDATE_INTERVAL) then
		local state = toolStates[previewTool]
		if state then
			local points = simulateTrajectory(previewTool, state, nowTick)
			renderPath(points, previewSegments, previewParent, CONFIG.PREVIEW_COLOR, CONFIG.PREVIEW_TRANSPARENCY, CONFIG.PREVIEW_THICKNESS, true)
		end
		lastPreviewTick = nowTick
	elseif not previewTool then
		renderPath({}, previewSegments, previewParent, CONFIG.PREVIEW_COLOR, CONFIG.PREVIEW_TRANSPARENCY, CONFIG.PREVIEW_THICKNESS, true)
	end

	for i = #activeFlights, 1, -1 do
		local flight = activeFlights[i]
		local part = flight.part
		if (not part) or (not part.Parent) or (not part:IsDescendantOf(Workspace)) or (nowTick - flight.startedAt > CONFIG.MAX_LIVE_TIME) then
			cleanupFlight(i)
		else
			if nowTick - flight.lastSample >= CONFIG.LIVE_SAMPLE_DT then
				flight.lastSample = nowTick
				table.insert(flight.points, {pos = part.Position, t = nowTick})
			end

			while #flight.points > 0 and (nowTick - flight.points[1].t > CONFIG.LIVE_TTL) do
				table.remove(flight.points, 1)
			end

			if #flight.points <= 1 and part.AssemblyLinearVelocity.Magnitude < 1.2 and (nowTick - flight.startedAt > 0.25) then
				cleanupFlight(i)
			else
				renderPath(extractPositions(flight.points), flight.segments, liveParent, CONFIG.LIVE_COLOR, CONFIG.LIVE_TRANSPARENCY, CONFIG.LIVE_THICKNESS)
			end
		end
	end
end)
end -- startGrenadeTrajectory

end -- runtime state 
end)() -- grenade trajectory 

-- чистим временные getgenv ключи
getgenv()._GT_CONFIG = nil; getgenv()._GT_getCharacter = nil
getgenv()._GT_getHead = nil; getgenv()._GT_getAimPoint = nil
getgenv()._GT_isThrowableTool = nil; getgenv()._GT_getGripPart = nil
getgenv()._GT_analyzeToolProfile = nil; getgenv()._GT_randomName = nil
getgenv()._GT_runTag = nil; getgenv()._GT_rootParent = nil
getgenv()._GT_previewParent = nil; getgenv()._GT_liveParent = nil
getgenv()._GT_Section = nil

;(function() -- 
local Lighting = game:GetService("Lighting")

local World_Orig  = {}
local World_Conns = {}

local function world_save_orig()
    if World_Orig.saved then return end
    World_Orig.saved              = true
    World_Orig.ClockTime          = Lighting.ClockTime
    World_Orig.Brightness         = Lighting.Brightness
    World_Orig.GlobalShadows      = Lighting.GlobalShadows
    World_Orig.Ambient            = Lighting.Ambient
    World_Orig.OutdoorAmbient     = Lighting.OutdoorAmbient
    World_Orig.ColorShift_Top     = Lighting.ColorShift_Top
    World_Orig.ColorShift_Bottom  = Lighting.ColorShift_Bottom
    World_Orig.ExposureCompensation = Lighting.ExposureCompensation
end

local function world_conn(key, fn)
    if World_Conns[key] then World_Conns[key]:Disconnect(); World_Conns[key] = nil end
    local prop = key:match("^([^_]+)")
    local ok, sig = pcall(Lighting.GetPropertyChangedSignal, Lighting, prop)
    if ok and sig then
        World_Conns[key] = sig:Connect(fn)
    end
end
local function world_disconn(key)
    if World_Conns[key] then World_Conns[key]:Disconnect(); World_Conns[key] = nil end
end

local FB = { Enabled = false }

local function fb_clocktime_cb()     if FB.Enabled then Lighting.ClockTime     = 14    end end
local function fb_brightness_cb()    if FB.Enabled then Lighting.Brightness    = 5     end end
local function fb_globalshadows_cb() if FB.Enabled then Lighting.GlobalShadows = false end end
local function fb_ambient_cb()       if FB.Enabled then Lighting.Ambient = Color3.fromRGB(178,178,178) end end

local function fb_enable()
    world_save_orig()
    Lighting.ClockTime     = 14
    Lighting.Brightness    = 5
    Lighting.GlobalShadows = false
    Lighting.Ambient       = Color3.fromRGB(178, 178, 178)
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("PostEffect") then pcall(function() e.Enabled = false end) end
    end
    world_conn("ClockTime_fb",     fb_clocktime_cb)
    world_conn("Brightness_fb",    fb_brightness_cb)
    world_conn("GlobalShadows_fb", fb_globalshadows_cb)
    world_conn("Ambient_fb",       fb_ambient_cb)
end

local function fb_disable()
    world_disconn("ClockTime_fb"); world_disconn("Brightness_fb")
    world_disconn("GlobalShadows_fb"); world_disconn("Ambient_fb")
    if World_Orig.ClockTime     ~= nil then Lighting.ClockTime     = World_Orig.ClockTime     end
    if World_Orig.Brightness    ~= nil then Lighting.Brightness    = World_Orig.Brightness    end
    if World_Orig.GlobalShadows ~= nil then Lighting.GlobalShadows = World_Orig.GlobalShadows end
    if World_Orig.Ambient       ~= nil then Lighting.Ambient       = World_Orig.Ambient       end
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("PostEffect") then pcall(function() e.Enabled = true end) end
    end
end

WorldSection:Toggle({
    Name = "Fullbright", Flag = "WorldFullbright", Default = false,
    Callback = function(state)
        FB.Enabled = state
        if state then fb_enable() else fb_disable() end
    end,
})

local CA = { Enabled = false, Top = Color3.fromRGB(128, 128, 128), Bot = Color3.fromRGB(80, 80, 80) }

local function ca_ambient_cb()         if CA.Enabled then Lighting.Ambient        = CA.Top end end
local function ca_outdoor_ambient_cb() if CA.Enabled then Lighting.OutdoorAmbient = CA.Bot end end

local CA_Toggle = WorldSection:Toggle({
    Name = "Custom Ambience", Flag = "WorldCustomAmbience", Default = false,
    Callback = function(state)
        CA.Enabled = state
        if state then
            world_save_orig()
            Lighting.Ambient        = CA.Top
            Lighting.OutdoorAmbient = CA.Bot
            world_conn("Ambient_ca",        ca_ambient_cb)
            world_conn("OutdoorAmbient_ca", ca_outdoor_ambient_cb)
        else
            world_disconn("Ambient_ca"); world_disconn("OutdoorAmbient_ca")
            if World_Orig.Ambient        then Lighting.Ambient        = World_Orig.Ambient        end
            if World_Orig.OutdoorAmbient then Lighting.OutdoorAmbient = World_Orig.OutdoorAmbient end
        end
    end,
})
CA_Toggle:Colorpicker({
    Name = "Ambient Color", Flag = "WorldAmbienceTop", Color = Color3.fromRGB(128, 128, 128), Alpha = 0,
    LayoutOrder = 1,
    Callback = function(c) CA.Top = c; if CA.Enabled then Lighting.Ambient = c end end,
})
CA_Toggle:Colorpicker({
    Name = "Outdoor Ambient", Flag = "WorldAmbienceBot", Color = Color3.fromRGB(80, 80, 80), Alpha = 0,
    LayoutOrder = 2,
    Callback = function(c) CA.Bot = c; if CA.Enabled then Lighting.OutdoorAmbient = c end end,
})

local CS = { Enabled = false, Top = Color3.fromRGB(255, 255, 255), Bot = Color3.fromRGB(128, 128, 128) }
local CS_Toggle = WorldSection:Toggle({
    Name = "Custom Colorshift", Flag = "WorldColorshift", Default = false,
    Callback = function(state)
        CS.Enabled = state
        if state then
            Lighting.ColorShift_Top    = CS.Top
            Lighting.ColorShift_Bottom = CS.Bot
        else
            if World_Orig.ColorShift_Top    then Lighting.ColorShift_Top    = World_Orig.ColorShift_Top    end
            if World_Orig.ColorShift_Bottom then Lighting.ColorShift_Bottom = World_Orig.ColorShift_Bottom end
        end
    end,
})
CS_Toggle:Colorpicker({
    Name = "Shift Top", Flag = "WorldShiftTop", Color = Color3.fromRGB(255, 255, 255), Alpha = 0,
    LayoutOrder = 1,
    Callback = function(c) CS.Top = c; if CS.Enabled then Lighting.ColorShift_Top = c end end,
})
CS_Toggle:Colorpicker({
    Name = "Shift Bottom", Flag = "WorldShiftBot", Color = Color3.fromRGB(128, 128, 128), Alpha = 0,
    LayoutOrder = 2,
    Callback = function(c) CS.Bot = c; if CS.Enabled then Lighting.ColorShift_Bottom = c end end,
})

local CE = { Enabled = false, Amount = -0.08 }
WorldSection:Toggle({
    Name = "Custom Exposure", Flag = "WorldExposure", Default = false,
    Callback = function(state)
        CE.Enabled = state
        if state then
            Lighting.ExposureCompensation = CE.Amount
        else
            if World_Orig.ExposureCompensation ~= nil then
                Lighting.ExposureCompensation = World_Orig.ExposureCompensation
            end
        end
    end,
})
WorldSection:Slider({
    Name = "Exposure Amount", Flag = "WorldExposureAmt",
    Min = -5, Max = 5, Default = -0.08, Decimal = 0.01, Suffix = "%",
    Callback = function(v) CE.Amount = v; if CE.Enabled then Lighting.ExposureCompensation = v end end,
})

local CT = { Enabled = false, Time = 13 }

RS.RenderStepped:Connect(function()
    if CT.Enabled then
        Lighting.ClockTime = CT.Time
    end
end)

WorldSection:Toggle({
    Name = "Custom Time", Flag = "WorldCustomTime", Default = false,
    Callback = function(state)
        CT.Enabled = state
        if state then
            world_save_orig()
            Lighting.ClockTime = CT.Time
        else
            if World_Orig.ClockTime ~= nil then Lighting.ClockTime = World_Orig.ClockTime end
        end
    end,
})
WorldSection:Slider({
    Name = "Time", Flag = "WorldTime",
    Min = 0, Max = 24, Default = 13, Decimal = 0.1, Suffix = "hr",
    Callback = function(v)
        CT.Time = v
        if CT.Enabled then
            Lighting.ClockTime = v
        end
    end,
})

local Shadows_Enabled = false
WorldSection:Toggle({
    Name = "No Shadows", Flag = "WorldShadows", Default = false,
    Callback = function(state)
        Shadows_Enabled = state
        Lighting.GlobalShadows = not state
    end,
})

local Bloom_Enabled = false
local Bloom_I = 56
local Bloom_S = 4.1
local Bloom_T = 90.2
local _bloom_obj = nil  

local function get_bloom()
    if _bloom_obj and _bloom_obj.Parent then return _bloom_obj end
    _bloom_obj = Lighting:FindFirstChildWhichIsA("BloomEffect")
    if not _bloom_obj then
        _bloom_obj = Instance.new("BloomEffect")
        _bloom_obj.Name    = "CustomBloom"
        _bloom_obj.Enabled = false
        _bloom_obj.Parent  = Lighting
    end
    return _bloom_obj
end

WorldSection2:Toggle({
    Name = "Bloom", Flag = "WorldBloom", Default = false,
    Callback = function(state)
        Bloom_Enabled = state
        local b = get_bloom()
        b.Enabled = state
        if state then
            b.Intensity = Bloom_I
            b.Size      = Bloom_S
            b.Threshold = Bloom_T
        end
    end,
})
WorldSection2:Slider({
    Name = "Bloom Intensity", Flag = "WorldBloomIntensity",
    Min = 0, Max = 100, Default = 56, Decimal = 1,
    Callback = function(v) Bloom_I = v; if Bloom_Enabled then get_bloom().Intensity = v end end,
})
WorldSection2:Slider({
    Name = "Bloom Size", Flag = "WorldBloomSize",
    Min = 0, Max = 56, Default = 4.1, Decimal = 0.1,
    Callback = function(v) Bloom_S = v; if Bloom_Enabled then get_bloom().Size = v end end,
})
WorldSection2:Slider({
    Name = "Bloom Threshold", Flag = "WorldBloomThreshold",
    Min = 0, Max = 100, Default = 90.2, Decimal = 0.1,
    Callback = function(v) Bloom_T = v; if Bloom_Enabled then get_bloom().Threshold = v end end,
})

local LightTech_Enabled = false
WorldSection2:Toggle({
    Name = "Custom Light Tech", Flag = "WorldLightTechEnabled", Default = false,
    Callback = function(state) LightTech_Enabled = state end,
})
WorldSection2:Dropdown({
    Name = "Lighting Technology", Flag = "WorldLightTech",
    Options = {"Compatibility", "ShadowMap", "Future", "Voxel"},
    Default = "Future", Multi = false,
    Callback = function(v)
        if LightTech_Enabled then
            pcall(function() Lighting.Technology = Enum.Technology[v] end)
        end
    end,
})

local SkyBoxes = {
    ["Default"] = {
        SkyboxLf = "rbxassetid://148943339", SkyboxBk = "rbxassetid://148943390",
        SkyboxDn = "rbxassetid://148943362", SkyboxFt = "rbxassetid://148943404",
        SkyboxRt = "rbxassetid://148943379", SkyboxUp = "rbxassetid://148943410",
    },
    ["Nebula"] = {
        SkyboxLf = "rbxassetid://159454286", SkyboxBk = "rbxassetid://159454299",
        SkyboxDn = "rbxassetid://159454296", SkyboxFt = "rbxassetid://159454293",
        SkyboxRt = "rbxassetid://159454300", SkyboxUp = "rbxassetid://159454288",
    },
    ["Blue Nebula"] = {
        SkyboxBk = "rbxassetid://79187608916257",  SkyboxDn = "rbxassetid://79187608916257",
        SkyboxFt = "rbxassetid://135345543970829", SkyboxLf = "rbxassetid://130684897818024",
        SkyboxRt = "rbxassetid://134117814265945", SkyboxUp = "rbxassetid://128019898265074",
    },
    ["Setting Hills"] = {
        SkyboxLf = "rbxassetid://264909758", SkyboxBk = "rbxassetid://264908339",
        SkyboxDn = "rbxassetid://264907909", SkyboxFt = "rbxassetid://264909420",
        SkyboxRt = "rbxassetid://264908886", SkyboxUp = "rbxassetid://264907379",
    },
    ["Blue Aurora"] = {
        SkyboxBk = "rbxassetid://12064107", SkyboxDn = "rbxassetid://12064152",
        SkyboxFt = "rbxassetid://12064121", SkyboxLf = "rbxassetid://12063984",
        SkyboxRt = "rbxassetid://12064115", SkyboxUp = "rbxassetid://12064131",
    },
    ["Red Aurora"] = {
        SkyboxBk = "rbxassetid://401664839", SkyboxDn = "rbxassetid://401664862",
        SkyboxFt = "rbxassetid://401664960", SkyboxLf = "rbxassetid://401664881",
        SkyboxRt = "rbxassetid://401664901", SkyboxUp = "rbxassetid://401664936",
    },
    ["Pink Vision"] = {
        SkyboxBk = "rbxassetid://6593929026", SkyboxDn = "rbxassetid://6593930140",
        SkyboxFt = "rbxassetid://6593931249", SkyboxLf = "rbxassetid://6593932587",
        SkyboxRt = "rbxassetid://6593933789", SkyboxUp = "rbxassetid://6593935319",
    },
    ["Twilight"] = {
        SkyboxBk = "rbxassetid://570557514", SkyboxDn = "rbxassetid://570557775",
        SkyboxFt = "rbxassetid://570557559", SkyboxLf = "rbxassetid://570557620",
        SkyboxRt = "rbxassetid://570557672", SkyboxUp = "rbxassetid://570557727",
    },
    ["Distopia"] = {
        SkyboxBk = "rbxassetid://2240134413", SkyboxDn = "rbxassetid://2240136039",
        SkyboxFt = "rbxassetid://2240130790", SkyboxLf = "rbxassetid://2240133550",
        SkyboxRt = "rbxassetid://2240132643", SkyboxUp = "rbxassetid://2240135222",
    },
    ["Peaceful"] = {
        SkyboxBk = "rbxassetid://73252679982122",  SkyboxDn = "rbxassetid://101074061181553",
        SkyboxFt = "rbxassetid://112572775732134", SkyboxLf = "rbxassetid://126931573973019",
        SkyboxRt = "rbxassetid://135908172504233", SkyboxUp = "rbxassetid://124514468649717",
    },
}

local current_sky = nil
local Skybox_Enabled = false
local Skybox_Current = "Peaceful"

local function apply_skybox(name)
    local data = SkyBoxes[name]
    if not data then return end
    if not current_sky or not current_sky.Parent then
        current_sky = Instance.new("Sky")
        current_sky.Parent = Lighting
    end
    for prop, id in pairs(data) do
        pcall(function() current_sky[prop] = id end)
    end
end

local function remove_skybox()
    if current_sky then current_sky:Destroy(); current_sky = nil end
end

WorldSection2:Toggle({
    Name = "Custom Skybox", Flag = "WorldSkyboxEnabled", Default = false,
    Callback = function(state)
        Skybox_Enabled = state
        if state then
            apply_skybox(Skybox_Current)
        else
            remove_skybox()
        end
    end,
})
WorldSection2:Dropdown({
    Name = "Skybox", Flag = "WorldSkyboxSelect",
    Options = {"Default","Nebula","Blue Nebula","Setting Hills","Blue Aurora","Red Aurora","Pink Vision","Twilight","Distopia","Peaceful"},
    Default = "Peaceful", Multi = false,
    Callback = function(v)
        Skybox_Current = v
        if Skybox_Enabled then apply_skybox(v) end
    end,
})

local Fog_Enabled = false
local Fog_Density = 0.3
local Fog_Offset  = 0
local Fog_Color   = Color3.fromRGB(192, 192, 192)
local Fog_Decay   = Color3.fromRGB(106, 127, 153)
local Fog_Glare   = 0
local Fog_Haze    = 10

local _fog_atmo   = nil  -- 
local _fog_orig_atmo = Lighting:FindFirstChildOfClass("Atmosphere")  -- оригинальный

local function fog_get_or_create()
    if _fog_atmo and _fog_atmo.Parent then return _fog_atmo end
    _fog_atmo = Instance.new("Atmosphere")
    _fog_atmo.Name   = "CustomFog"
    _fog_atmo.Parent = Lighting
    return _fog_atmo
end

local function fog_apply()
    local atmo = fog_get_or_create()
    atmo.Density = Fog_Density
    atmo.Offset  = Fog_Offset
    atmo.Color   = Fog_Color
    atmo.Decay   = Fog_Decay
    atmo.Glare   = Fog_Glare
    atmo.Haze    = Fog_Haze
end

local function fog_remove()
    if _fog_atmo and _fog_atmo.Parent then
        _fog_atmo:Destroy()
        _fog_atmo = nil
    end
end

local WorldFogSection = WorldPage:Section({Name = "Fog", Side = "Right"})

WorldFogSection:Toggle({
    Name = "Custom Fog", Flag = "WorldFogEnabled", Default = false,
    Callback = function(state)
        Fog_Enabled = state
        if state then
           
            if _fog_orig_atmo and _fog_orig_atmo.Parent then pcall(function() _fog_orig_atmo.Parent = nil end) end
            fog_apply()
        else
            fog_remove()
           
            if _fog_orig_atmo then pcall(function() _fog_orig_atmo.Parent = Lighting end) end
        end
    end,
}):Colorpicker({
    Name = "Fog Color", Flag = "WorldFogColor",
    Color = Color3.fromRGB(192, 192, 192), Alpha = 0,
    Callback = function(c)
        Fog_Color = c
        if Fog_Enabled then fog_apply() end
    end,
})

WorldFogSection:Colorpicker({
    Name = "Fog Decay", Flag = "WorldFogDecay",
    Color = Color3.fromRGB(106, 127, 153), Alpha = 0,
    Callback = function(c)
        Fog_Decay = c
        if Fog_Enabled then fog_apply() end
    end,
})

WorldFogSection:Slider({
    Name = "Density", Flag = "WorldFogDensity",
    Min = 0, Max = 1, Default = 0.3, Decimal = 0.01,
    Callback = function(v)
        Fog_Density = v
        if Fog_Enabled then fog_apply() end
    end,
})

WorldFogSection:Slider({
    Name = "Offset", Flag = "WorldFogOffset",
    Min = 0, Max = 1, Default = 0, Decimal = 0.01,
    Callback = function(v)
        Fog_Offset = v
        if Fog_Enabled then fog_apply() end
    end,
})

WorldFogSection:Slider({
    Name = "Haze", Flag = "WorldFogHaze",
    Min = 0, Max = 10, Default = 10, Decimal = 0.1,
    Callback = function(v)
        Fog_Haze = v
        if Fog_Enabled then fog_apply() end
    end,
})

WorldFogSection:Slider({
    Name = "Glare", Flag = "WorldFogGlare",
    Min = 0, Max = 10, Default = 0, Decimal = 0.1,
    Callback = function(v)
        Fog_Glare = v
        if Fog_Enabled then fog_apply() end
    end,
})

end)() -- 

end)() -- 

;(function() 
local GunChamsSection  = WorldPage:Section({Name = "Gun Chams", Side = "Left"})

local GC = {
    Enabled      = false,
    Color        = Color3.fromRGB(100, 149, 237),
    TargetColor  = Color3.fromRGB(100, 149, 237),
    Alpha        = 0,
    TargetAlpha  = 0,
    Material     = "Neon",
    NoTexture    = true,
    Mode         = "Material",
    HighlightOutlineColor = Color3.fromRGB(255, 255, 255),
    HighlightOutlineAlpha = 0,
    HighlightInstance = nil,

    originals    = {},
    conn         = nil,
    charConn     = nil,
    toolConn     = nil,
    tweenConn    = nil,

    SkipTransparencyThreshold = 0.99,

    -- плавность смены цвета
    ColorLerpSpeed = 0.12,
}

local MATERIALS = {
    "Neon", "ForceField", "Glass", "SmoothPlastic", "Plastic",
    "Metal", "DiamondPlate", "Foil", "Ice",
}

local function gc_get_parts(root)
    local parts = {}
    
    
    if root:IsA("BasePart") or root:IsA("MeshPart") or root:IsA("SpecialMesh") then
        table.insert(parts, root)
    end
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("BasePart") or d:IsA("MeshPart") or d:IsA("SpecialMesh") then
            table.insert(parts, d)
        end
    end
    return parts
end

local function gc_save(part)
    if GC.originals[part] then return end

    local origTransparency = nil
    local skipTransparency = false
    if part:IsA("BasePart") or part:IsA("MeshPart") then
        origTransparency = part.Transparency
        
        if origTransparency >= GC.SkipTransparencyThreshold then
            skipTransparency = true
        end
    end

    GC.originals[part] = {
        Color         = part:IsA("BasePart") and part.Color       or nil,
        BrickColor    = part:IsA("BasePart") and part.BrickColor  or nil,
        Material      = part:IsA("BasePart") and part.Material    or nil,
        TextureID     = (part:IsA("MeshPart") and part.TextureID) or
                        (part:IsA("SpecialMesh") and part.TextureId) or nil,
        Transparency  = origTransparency,
        SkipTransparency = skipTransparency,
    }
end

local function gc_apply_part(part, forceInvisible)
    gc_save(part)
    local orig = GC.originals[part]

    pcall(function()
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            -- используем GC.Color 
            part.Color    = GC.Color
            part.Material = Enum.Material[GC.Material] or Enum.Material.Neon

            if not (orig and orig.SkipTransparency) then
                if forceInvisible then
                    part.Transparency = 1
                else
                    part.Transparency = GC.Alpha
                end
            end
        end
        if GC.NoTexture then
            if part:IsA("MeshPart") then
                part.TextureID = ""
            elseif part:IsA("SpecialMesh") then
                part.TextureId = ""
            end
        end
    end)
end


local function gc_start_color_tween()

end

local function gc_stop_color_tween()
    if GC.tweenConn then GC.tweenConn:Disconnect(); GC.tweenConn = nil end
end

local function gc_restore_part(part)
    local orig = GC.originals[part]
    if not orig then return end
    pcall(function()
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            if orig.Color    then part.Color    = orig.Color    end
            if orig.Material then part.Material = orig.Material end
            if orig.Transparency ~= nil and not orig.SkipTransparency then
                part.Transparency = orig.Transparency
            end
        end
        if orig.TextureID then
            if part:IsA("MeshPart")    then part.TextureID = orig.TextureID end
            if part:IsA("SpecialMesh") then part.TextureId = orig.TextureID end
        end
    end)
    GC.originals[part] = nil
end

local function gc_get_roots()
    local roots = {}
    local char = LP.Character
    if not char then return roots end

    
    
    local equippedNames = {}
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            table.insert(roots, { root = child, forceInvisible = false })
            equippedNames[child.Name] = true
        end
    end

    
    local di = char:FindFirstChild("DisplayItems")
    if di then
        for _, weapon_folder in ipairs(di:GetChildren()) do
            local parts_folder = weapon_folder:FindFirstChild("Parts")
            if parts_folder then
                for _, part_group in ipairs(parts_folder:GetChildren()) do
                    local model = part_group:FindFirstChild("Model")
                    if model then
                        local handle = model:FindFirstChild("Handle")
                            or model:FindFirstChildWhichIsA("BasePart")
                        if handle then
                            local root = handle.Parent or handle
                            local isEquipped = equippedNames[weapon_folder.Name] == true
                            table.insert(roots, { root = root, forceInvisible = isEquipped })
                        end
                    end
                end
            end
        end
    end

    return roots
end

local function gc_restore_all()
    for part in pairs(GC.originals) do
        gc_restore_part(part)
    end
    GC.originals = {}
end

local function gc_apply_all()
    local roots = gc_get_roots()
    
    if GC.Mode == "Material" and GC.Enabled then
        for _, entry in ipairs(roots) do
            for _, part in ipairs(gc_get_parts(entry.root)) do
                gc_apply_part(part, entry.forceInvisible)
            end
        end
    else
        gc_restore_all()
    end

    if GC.Mode == "Highlight" and GC.Enabled then
  
        if GC.HighlightInstance and not GC.HighlightInstance.Parent then
            pcall(function() GC.HighlightInstance:Destroy() end)
            GC.HighlightInstance = nil
        end
        if not GC.HighlightInstance then
            GC.HighlightInstance = Instance.new("Highlight")
            GC.HighlightInstance.Name = "GunHighlight"
        end
        local h = GC.HighlightInstance
        h.FillColor = GC.Color
        h.FillTransparency = GC.Alpha
        h.OutlineColor = GC.HighlightOutlineColor
        h.OutlineTransparency = GC.HighlightOutlineAlpha
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
  
        local vm = workspace.CurrentCamera:FindFirstChild("ViewModel")
        local vmTool = vm and vm:FindFirstChild("Tool")
        local target = vmTool or (roots[1] and roots[1].root) or nil
        if target then
            pcall(function()
                h.Adornee = target
                h.Parent = target
            end)
        end
    else
        if GC.HighlightInstance then
            pcall(function() GC.HighlightInstance:Destroy() end)
            GC.HighlightInstance = nil
        end
    end
end

local function gc_start()
    gc_apply_all()
    gc_start_color_tween()

    GC.conn = RS.RenderStepped:Connect(function()
        if not GC.Enabled then return end
        gc_apply_all()
    end)

    GC.charConn = LP.CharacterAdded:Connect(function()
        task.wait(1)
        if GC.Enabled then gc_apply_all() end
    end)
end

local function gc_stop()
    if GC.conn     then GC.conn:Disconnect();     GC.conn     = nil end
    if GC.charConn then GC.charConn:Disconnect(); GC.charConn = nil end
    gc_stop_color_tween()
    
    if GC.HighlightInstance then
        GC.HighlightInstance:Destroy()
        GC.HighlightInstance = nil
    end
    gc_restore_all()
end
local GunChamsHighlightSection = nil

GunChamsSection:Toggle({
    Name     = "Enabled",
    Flag     = "GunChamsEnabled",
    Default  = false,
    Callback = function(state)
        GC.Enabled = state
        if state then gc_start() else gc_stop() end
    end,
}):Colorpicker({
    Name     = "Color",
    Flag     = "GunChamsColor",
    Color    = Color3.fromRGB(100, 149, 237),
    Alpha    = 0,
    Callback = function(c, a)
        GC.TargetColor = c
        GC.Color       = c
        if a then GC.TargetAlpha = a; GC.Alpha = a end
        if GC.Enabled then gc_apply_all() end
    end,
})

GunChamsSection:Dropdown({
    Name     = "Mode",
    Flag     = "GunChamsMode",
    Options  = {"Material", "Highlight"},
    Default  = "Material",
    Multi    = false,
    Callback = function(v)
        GC.Mode = v
        if GunChamsHighlightSection then
            GunChamsHighlightSection.Items.Section.Visible = (v == "Highlight")
        end
        if GC.Enabled then gc_apply_all() end
    end,
})

GunChamsSection:Dropdown({
    Name     = "Material",
    Flag     = "GunChamsMaterial",
    Options  = MATERIALS,
    Default  = "Neon",
    Multi    = false,
    Callback = function(v)
        GC.Material = v
        if GC.Enabled then gc_apply_all() end
    end,
})

GunChamsHighlightSection = WorldPage:Section({Name = "Gun Highlight Settings", Side = "Left"})
GunChamsHighlightSection.Items.Section.Visible = false

GunChamsHighlightSection:Toggle({
    Name     = "Outline",
    Flag     = "GunChamsHLOutline",
    Default = false,
    Callback = function(state)
        if state then
            GC.HighlightOutlineAlpha = GC._savedOutlineAlpha or 0
        else
            GC.HighlightOutlineAlpha = 1
        end
        if GC.Enabled then gc_apply_all() end
    end,
}):Colorpicker({
    Name     = "Outline Color",
    Flag     = "GunChamsHighlightOutline",
    Color    = Color3.fromRGB(255, 255, 255),
    Alpha    = 0,
    Callback = function(c, a)
        GC.HighlightOutlineColor = c
        if a then
            GC._savedOutlineAlpha = a
            if Library.Flags["GunChamsHLOutline"] then
                GC.HighlightOutlineAlpha = a
            end
        end
        if GC.Enabled then gc_apply_all() end
    end,
})

end)()


;(function()
local ArmsSection = WorldPage:Section({Name = "Arms", Side = "Left"})

local ARMS_MATERIALS = {
    "Neon", "ForceField", "Glass", "SmoothPlastic", "Plastic",
    "Metal", "DiamondPlate", "Foil", "Ice",
}

local AC = {
    Left  = {
        Enabled     = false,
        Color       = Color3.fromRGB(255, 200, 150),
        TargetColor = Color3.fromRGB(255, 200, 150),
        Alpha       = 0,
        TargetAlpha = 0,
        Material    = "SmoothPlastic",
        origColor   = nil,
        origMat     = nil,
        origAlpha   = nil,
        partName    = "Left Arm",
    },
    Right = {
        Enabled     = false,
        Color       = Color3.fromRGB(255, 200, 150),
        TargetColor = Color3.fromRGB(255, 200, 150),
        Alpha       = 0,
        TargetAlpha = 0,
        Material    = "SmoothPlastic",
        origColor   = nil,
        origMat     = nil,
        origAlpha   = nil,
        partName    = "Right Arm",
    },
}

local ac_conn     = nil
local ac_lerpConn = nil

local function ac_get_part(cfg)
    local vm = workspace.CurrentCamera:FindFirstChild("ViewModel")
    if vm then
        local p = vm:FindFirstChild(cfg.partName)
        if p then return p, false end -- false 
    end
    -- fallback
    local char = LP.Character
    if char then
        local p = char:FindFirstChild(cfg.partName)
        if p then return p, true end -- true = Character
    end
    return nil, false
end

local function ac_is_third_person()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local camPos  = workspace.CurrentCamera.CFrame.Position
    local hrpPos  = hrp.Position
    local dist    = (camPos - hrpPos).Magnitude
    return dist > 3 -- 
end

local function ac_apply(cfg)
    local part, isChar = ac_get_part(cfg)
    if not part then return end
    pcall(function()
        if cfg.origColor == nil then
            cfg.origColor = part.Color
            cfg.origMat   = part.Material
            cfg.origAlpha = part.Transparency
        end
        part.Color        = cfg.Color
        part.Material     = Enum.Material[cfg.Material] or Enum.Material.SmoothPlastic
        part.Transparency = cfg.Alpha
    end)
end

local function ac_restore(cfg)
    local vm = workspace.CurrentCamera:FindFirstChild("ViewModel")
    if vm then
        local vp = vm:FindFirstChild(cfg.partName)
        if vp then pcall(function()
            vp.Color                     = cfg.origVMColor    or vp.Color
            vp.Material                  = cfg.origVMMat      or vp.Material
            vp.Transparency              = cfg.origVMAlpha    ~= nil and cfg.origVMAlpha or vp.Transparency
            vp.LocalTransparencyModifier = 0
        end) end
    end
    local char = LP.Character
    if char then
        local cp = char:FindFirstChild(cfg.partName)
        if cp then pcall(function()
            cp.Color                     = cfg.origCharColor  or cp.Color
            cp.Material                  = cfg.origCharMat    or cp.Material
            cp.Transparency              = cfg.origCharAlpha  ~= nil and cfg.origCharAlpha or cp.Transparency
            cp.LocalTransparencyModifier = 0
        end) end
    end
    cfg.origVMColor   = nil; cfg.origVMMat   = nil; cfg.origVMAlpha   = nil
    cfg.origCharColor = nil; cfg.origCharMat = nil; cfg.origCharAlpha = nil
end

local function ac_apply_all()
    local thirdPerson = ac_is_third_person()

    for _, cfg in pairs(AC) do
        if cfg.Enabled then
            -- 
            local vm = workspace.CurrentCamera:FindFirstChild("ViewModel")
            if vm then
                local vp = vm:FindFirstChild(cfg.partName)
                if vp then
                    pcall(function()
                        --
                        if cfg.origVMColor == nil then
                            cfg.origVMColor = vp.Color
                            cfg.origVMMat   = vp.Material
                            cfg.origVMAlpha = vp.Transparency
                        end
                        vp.LocalTransparencyModifier = thirdPerson and 1 or 0
                        if not thirdPerson then
                            vp.Color        = cfg.Color
                            vp.Material     = Enum.Material[cfg.Material] or Enum.Material.SmoothPlastic
                            vp.Transparency = cfg.Alpha
                        else
                            -- 
                            vp.Color        = cfg.origVMColor
                            vp.Material     = cfg.origVMMat
                            vp.Transparency = cfg.origVMAlpha
                        end
                    end)
                end
            end
            -- 
            local char = LP.Character
            if char then
                local cp = char:FindFirstChild(cfg.partName)
                if cp then
                    pcall(function()
                        -- сохраняем оригинал 
                        if cfg.origCharColor == nil then
                            cfg.origCharColor = cp.Color
                            cfg.origCharMat   = cp.Material
                            cfg.origCharAlpha = cp.Transparency
                        end
                        cp.LocalTransparencyModifier = thirdPerson and 0 or 1
                        if thirdPerson then
                            cp.Color        = cfg.Color
                            cp.Material     = Enum.Material[cfg.Material] or Enum.Material.SmoothPlastic
                            cp.Transparency = cfg.Alpha
                        else
                            -- восстанавливаем
                            cp.Color        = cfg.origCharColor
                            cp.Material     = cfg.origCharMat
                            cp.Transparency = cfg.origCharAlpha
                        end
                    end)
                end
            end
        end
    end
end

local function ac_start()
    if not ac_conn then
        ac_conn = RS.RenderStepped:Connect(function()
            ac_apply_all()
        end)
    end
end

local function ac_stop_if_none()
    if not AC.Left.Enabled and not AC.Right.Enabled then
        if ac_conn then ac_conn:Disconnect(); ac_conn = nil end
    end
end

-- retarded

ArmsSection:Toggle({
    Name     = "Left Arm",
    Flag     = "ArmsLeftEnabled",
    Default  = false,
    Callback = function(state)
        AC.Left.Enabled = state
        if state then
            ac_start()
        else
            ac_restore(AC.Left)
            ac_stop_if_none()
        end
    end,
}):Colorpicker({
    Name     = "Left Arm Color",
    Flag     = "ArmsLeftColor",
    Color    = Color3.fromRGB(255, 200, 150),
    Alpha    = 0,
    Callback = function(c, a)
        AC.Left.TargetColor = c
        AC.Left.Color       = c
        AC.Left.TargetAlpha = a or AC.Left.TargetAlpha
        AC.Left.Alpha       = a or AC.Left.Alpha
        if AC.Left.Enabled then ac_apply(AC.Left) end
    end,
})

ArmsSection:Dropdown({
    Name     = "Left Arm Material",
    Flag     = "ArmsLeftMaterial",
    Options  = ARMS_MATERIALS,
    Default  = "SmoothPlastic",
    Multi    = false,
    Callback = function(v)
        AC.Left.Material = v
        if AC.Left.Enabled then ac_apply(AC.Left) end
    end,
})

ArmsSection:Toggle({
    Name     = "Right Arm",
    Flag     = "ArmsRightEnabled",
    Default  = false,
    Callback = function(state)
        AC.Right.Enabled = state
        if state then
            ac_start()
        else
            ac_restore(AC.Right)
            ac_stop_if_none()
        end
    end,
}):Colorpicker({
    Name     = "Right Arm Color",
    Flag     = "ArmsRightColor",
    Color    = Color3.fromRGB(255, 200, 150),
    Alpha    = 0,
    Callback = function(c, a)
        AC.Right.TargetColor = c
        AC.Right.Color       = c
        AC.Right.TargetAlpha = a or AC.Right.TargetAlpha
        AC.Right.Alpha       = a or AC.Right.Alpha
        if AC.Right.Enabled then ac_apply(AC.Right) end
    end,
})

ArmsSection:Dropdown({
    Name     = "Right Arm Material",
    Flag     = "ArmsRightMaterial",
    Options  = ARMS_MATERIALS,
    Default  = "SmoothPlastic",
    Multi    = false,
    Callback = function(v)
        AC.Right.Material = v
        if AC.Right.Enabled then ac_apply(AC.Right) end
    end,
})

end)()

Library:Configs(Window)

UILibNotifications:Create({Name = "Loaded! priv13 loaded successfully", LifeTime = 5})



end)()