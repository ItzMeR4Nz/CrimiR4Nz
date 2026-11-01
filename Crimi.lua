-- ========================================================
-- 🥷 CRIMINAL HUB v37 (by sega1games12-alt)
-- ========================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local LOCALES = {
    RU = {
        Title = "🥷 КРИМИНАЛ",
        Sub = "от sega1games12-alt",
        Move = "🚀 ДВИЖЕНИЕ",
        Fly = "Fly (Полет)",
        NoClip = "NoClip (Сквозь стены)",
        Visual = "👁 ВИЗУАЛЬНЫЕ ФУНКЦИИ",
        Loot = "Loot ESP",
        Police = "Police ESP",
        Guard = "Guard ESP",
        Civilian = "Civilian ESP",
        Settings = "⚙️ НАСТРОЙКИ",
        Clear = "🗑 Очистить все",
        Themes = "🎨 ЦВЕТОВЫЕ ТЕМЫ",
        Lang = "🌐 ЯЗЫК",
        Gold = "🥇 Золотая",
        Red = "🔥 Красная",
        Blue = "💙 Синяя",
        Green = "💚 Зеленая",
        Rainbow = "🌈 Радужная"
    },
    UA = {
        Title = "🥷 КРИМІНАЛ",
        Sub = "від sega1games12-alt",
        Move = "🚀 РУХ",
        Fly = "Fly (Політ)",
        NoClip = "NoClip (Крізь стіни)",
        Visual = "👁 ВІЗУАЛЬНІ ФУНКЦІЇ",
        Loot = "Loot ESP",
        Police = "Police ESP",
        Guard = "Guard ESP",
        Civilian = "Civilian ESP",
        Settings = "⚙️ НАЛАШТУВАННЯ",
        Clear = "🗑 Очистити все",
        Themes = "🎨 КОЛЬОРОВІ ТЕМИ",
        Lang = "🌐 МОВА",
        Gold = "🥇 Золота",
        Red = "🔥 Червона",
        Blue = "💙 Синя",
        Green = "💚 Зелена",
        Rainbow = "🌈 Веселкова"
    },
    EN = {
        Title = "🥷 CRIMINAL",
        Sub = "by sega1games12-alt",
        Move = "🚀 MOVEMENT",
        Fly = "Fly",
        NoClip = "NoClip (Walls)",
        Visual = "👁 VISUALS",
        Loot = "Loot ESP",
        Police = "Police ESP",
        Guard = "Guard ESP",
        Civilian = "Civilian ESP",
        Settings = "⚙️ SETTINGS",
        Clear = "🗑 Clear All",
        Themes = "🎨 THEMES",
        Lang = "🌐 LANGUAGE",
        Gold = "🥇 Gold",
        Red = "🔥 Red",
        Blue = "💙 Blue",
        Green = "💚 Green",
        Rainbow = "🌈 Rainbow"
    }
}
local CurrentLang = "EN"

local COLORS = {
    Loot = Color3.fromRGB(255, 215, 0), Safe = Color3.fromRGB(255, 50, 50),
    Police = Color3.fromRGB(0, 100, 255), Guard = Color3.fromRGB(255, 0, 0),
    Civilian = Color3.fromRGB(0, 255, 0), Bg = Color3.fromRGB(20, 20, 25),
    Panel = Color3.fromRGB(30, 30, 35), Button = Color3.fromRGB(45, 45, 55),
}
local CurrentAccent = Color3.fromRGB(255, 215, 0)
local IsRainbow = false
-- NPC folders may be nested or streamed in later.
local FOLDER_ALIASES = {
    Police = { police = true, cops = true, officers = true },
    Guard = { guards = true, guard = true, security = true, securityguards = true },
    Civilian = { npcs = true, npc = true, civilians = true, civilian = true, citizens = true }
}
local enabled = { Loot = false, Police = false, Guard = false, Civilian = false, Fly = false, NoClip = false }
local active = {}; local lootMarks = {}  

local LOOT_NAMES = {
    ["CashBag"] = true, ["GoldBar"] = true, ["DiamondNecklace"] = true, ["Handbag"] = true,
    ["SeizedCash"] = true, ["TaserItem"] = true, ["CashBox"] = true, ["PoliceRadio"] = true,
    ["PoliceBadge"] = true, ["Ring"] = true, ["RingBox"] = true, ["Wallet"] = true,
    ["Watch"] = true, ["Necklace"] = true, ["Valuables"] = true, ["Item"] = true
}

if getgenv().CrimHubStop then pcall(getgenv().CrimHubStop) end
local running = true
local pg = LP:WaitForChild("PlayerGui")
for _, name in ipairs({"CrimHubV34","CrimHubV35","CrimHubV36","CrimHubV37"}) do
    if pg:FindFirstChild(name) then pg[name]:Destroy() end
end
for _, v in ipairs(Workspace:GetDescendants()) do
    if v.Name == "CrimESP" or v.Name == "CrimMark" then v:Destroy() end
end

local sg = Instance.new("ScreenGui")
sg.Name = "CrimHubV37"
sg.ResetOnSpawn = false
sg.Parent = pg

local function addHL(obj, kind)
    local hl = obj:FindFirstChild("CrimESP")
    if not hl or not hl.Parent then
        hl = Instance.new("Highlight")
        hl.Name = "CrimESP"
        hl.FillTransparency = 0.5
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = obj
    end
    hl.Adornee = obj
    hl.Enabled = true
    hl.FillColor = COLORS[kind]
    hl.OutlineColor = COLORS[kind]
    active[obj] = { hl = hl, kind = kind }
end
local function removeKind(kind)
    for obj, rec in pairs(active) do
        if rec.kind == kind then if rec.hl then rec.hl:Destroy() end; active[obj] = nil end
    end
end
local function inCharacter(obj)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and obj:IsDescendantOf(p.Character) then return true end
    end
    return false
end
local function hasMark(obj)
    if lootMarks[obj] then return true end
    local parent = obj.Parent
    while parent and parent ~= Workspace do
        if lootMarks[parent] then return true end
        if (parent:IsA("Model") or parent:IsA("BasePart")) and LOOT_NAMES[parent.Name] then return true end
        parent = parent.Parent
    end
    return false
end
local function markLoot(obj, isSafe)
    if not obj or not obj.Parent or inCharacter(obj) then return end
    local color = isSafe and COLORS.Safe or COLORS.Loot
    local hl = lootMarks[obj] and lootMarks[obj].hl or obj:FindFirstChild("CrimESP")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "CrimESP"
        hl.Adornee = obj
        hl.FillTransparency = 0.4
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = obj
    end
    hl.Adornee = obj
    hl.OutlineColor = color
    hl.FillColor = color

    local oldBB = lootMarks[obj] and lootMarks[obj].bb
    local part = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    local bb = oldBB
    if part then
        if not bb or not bb.Parent then
            bb = Instance.new("BillboardGui")
            bb.Name = "CrimMark"
            bb.AlwaysOnTop = true
            bb.Size = UDim2.new(0, 120, 0, 22)
            bb.StudsOffset = Vector3.new(0, 2, 0)
            bb.Parent = sg
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamBold
            label.TextSize = 12
            label.TextStrokeTransparency = 0.5
            label.Parent = bb
        end
        bb.Adornee = part
        local label = bb:FindFirstChild("Label")
        if label then
            label.Text = "◆ " .. obj.Name
            label.TextColor3 = color
        end
    end
    lootMarks[obj] = {hl = hl, bb = bb}
end
local function isLoot(d)
    if not (d:IsA("Model") or d:IsA("BasePart")) then return false, false end
    local name = d.Name
    if name == "SafeDialing" or name:find("Safe") then return true, true end
    if LOOT_NAMES[name] then return true, false end
    return false, false
end
local lootConn = nil
local lootRetryRunning = false
local function scanLoot()
    if not enabled.Loot then return end
    local descendants = Workspace:GetDescendants()
    for i, d in ipairs(descendants) do
        if not enabled.Loot then break end
        local isL, isSafe = isLoot(d)
        if isL then
            pcall(markLoot, d, isSafe)
        end
        if i % 150 == 0 then task.wait() end
    end
end

local function setLoot(on)
    if lootConn then lootConn:Disconnect(); lootConn = nil end
    lootRetryRunning = on
    if on then
        task.spawn(scanLoot)
        lootConn = Workspace.DescendantAdded:Connect(function(d)
            if not enabled.Loot then return end
            task.defer(function()
                if d and d.Parent then
                    local isL, isSafe = isLoot(d)
                    if isL then pcall(markLoot, d, isSafe) end
                end
            end)
            task.delay(0.8, function()
                if enabled.Loot and d and d.Parent then
                    local isL, isSafe = isLoot(d)
                    if isL then pcall(markLoot, d, isSafe) end
                end
            end)
        end)
        -- Reconcile NPC ESP continuously: supports nested folders, late spawns,
-- and StreamingEnabled. The parent-folder ancestry selects the ESP type.
local function getNPCModel(inst)
    local node = inst
    while node and node ~= Workspace do
        if node:IsA("Model") then
            local hum = node:FindFirstChildOfClass("Humanoid") or node:FindFirstChildWhichIsA("Humanoid", true)
            if hum then return node end
        end
        node = node.Parent
    end
    return nil
end

local function getNPCType(model)
    local node = model.Parent
    while node and node ~= Workspace do
        local key = string.lower((node.Name:gsub("[%s_%-]", "")))
        for kind, aliases in pairs(FOLDER_ALIASES) do
            if aliases[key] then return kind end
        end
        node = node.Parent
    end
    return nil
end

local function scanNPCs()
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if not running then return end
        local model = getNPCModel(inst)
        if model then
            local kind = getNPCType(model)
            if kind and enabled[kind] then pcall(addHL, model, kind) end
        end
    end
    for model, rec in pairs(active) do
        if not model.Parent or not model:IsDescendantOf(Workspace)
            or not enabled[rec.kind] or getNPCType(model) ~= rec.kind then
            if rec.hl then rec.hl:Destroy() end
            active[model] = nil
        end
    end
end

task.spawn(function()
    while running do
        task.wait(1)
        pcall(scanNPCs)
    end
end)

Workspace.DescendantAdded:Connect(function(inst)
    if not running then return end
    task.delay(0.25, function()
        if not running or not inst.Parent then return end
        local model = getNPCModel(inst)
        if not model then return end
        local kind = getNPCType(model)
        if kind and enabled[kind] then pcall(addHL, model, kind) end
    end)
end)


local flyConnection = nil
local flyBodyVel = nil
local flyBodyGyro = nil
local noclipConnection = nil
local flyUpHeld = false
local flyDownHeld = false
local flyMobileGui = nil

local function makeFlyMobileControls()
    if flyMobileGui and flyMobileGui.Parent then return end
    flyMobileGui = Instance.new("Frame")
    flyMobileGui.Name = "FlyMobileControls"
    flyMobileGui.Size = UDim2.new(0, 58, 0, 124)
    flyMobileGui.Position = UDim2.new(1, -76, 0.55, -62)
    flyMobileGui.BackgroundTransparency = 1
    flyMobileGui.Visible = UIS.TouchEnabled
    flyMobileGui.Parent = sg

    local function makeVerticalButton(text, y, callbackDown, callbackUp)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 54, 0, 54)
        b.Position = UDim2.new(0, 2, 0, y)
        b.BackgroundColor3 = COLORS.Panel
        b.BackgroundTransparency = 0.15
        b.Text = text
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 24
        b.Font = Enum.Font.GothamBold
        b.Parent = flyMobileGui
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 12)
        b.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then callbackDown() end
        end)
        b.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then callbackUp() end
        end)
    end
    makeVerticalButton("▲", 0, function() flyUpHeld = true end, function() flyUpHeld = false end)
    makeVerticalButton("▼", 66, function() flyDownHeld = true end, function() flyDownHeld = false end)
end

local function toggleFly(on)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then
        enabled.Fly = false
        return
    end

    if on then
        makeFlyMobileControls()
        if flyMobileGui then flyMobileGui.Visible = UIS.TouchEnabled end
        hum.PlatformStand = false
        hum.AutoRotate = false
        if not flyBodyVel or not flyBodyVel.Parent then
            flyBodyVel = Instance.new("BodyVelocity")
            flyBodyVel.Name = "CrimFlyVelocity"
            flyBodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            flyBodyVel.P = 1e4
            flyBodyVel.Velocity = Vector3.zero
            flyBodyVel.Parent = hrp
        end
        if not flyBodyGyro or not flyBodyGyro.Parent then
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.Name = "CrimFlyGyro"
            flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
            flyBodyGyro.P = 1e4
            flyBodyGyro.CFrame = hrp.CFrame
            flyBodyGyro.Parent = hrp
        end
        if flyConnection then flyConnection:Disconnect() end
        flyConnection = RunService.RenderStepped:Connect(function()
            if not enabled.Fly or not hrp.Parent then return end
            local camCF = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame or CFrame.new()
            local dir = Vector3.zero
            if UIS.TouchEnabled then
                dir = hum.MoveDirection
            else
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir += camCF.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= camCF.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir += camCF.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= camCF.RightVector end
            end
            if UIS:IsKeyDown(Enum.KeyCode.Space) or flyUpHeld then dir += Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or flyDownHeld then dir -= Vector3.new(0, 1, 0) end
            if dir.Magnitude > 1 then dir = dir.Unit end
            flyBodyVel.Velocity = dir * 50
            flyBodyGyro.CFrame = camCF
        end)
    else
        flyUpHeld = false
        flyDownHeld = false
        if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
        if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        if hum then hum.AutoRotate = true; hum.PlatformStand = false end
        if flyMobileGui then flyMobileGui.Visible = false end
    end
end

local function toggleNoclip(on)
    if on then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if not enabled.NoClip then return end
            local char = LP.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
        local char = LP.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
                    part.CanCollide = true 
                end
            end
        end
    end
end

local ThemeElements = {}
local function RegisterTheme(obj, prop)
    table.insert(ThemeElements, {obj = obj, prop = prop})
    obj[prop] = CurrentAccent
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 0)
MainFrame.AutomaticSize = Enum.AutomaticSize.Y
MainFrame.Position = UDim2.new(0, 30, 0, 100)
MainFrame.BackgroundColor3 = COLORS.Bg
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = sg
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 1.5
RegisterTheme(MainStroke, "Color")

local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local originalSizeY = 0
task.delay(0.1, function()
    originalSizeY = MainFrame.AbsoluteSize.Y
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 220, 0, originalSizeY)
    }):Play()
end)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = COLORS.Panel
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)
local fixCorner = Instance.new("Frame")
fixCorner.Size = UDim2.new(1, 0, 0.5, 0)
fixCorner.Position = UDim2.new(0, 0, 0.5, 0)
fixCorner.BackgroundColor3 = COLORS.Panel
fixCorner.BorderSizePixel = 0
fixCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0.6, 0)
Title.Position = UDim2.new(0, 10, 0, 2)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar
RegisterTheme(Title, "TextColor3")

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -60, 0.4, 0)
SubTitle.Position = UDim2.new(0, 10, 0.6, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 10
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 160)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
MinimizeBtn.Position = UDim2.new(1, -30, 0, 10)
MinimizeBtn.BackgroundColor3 = COLORS.Button
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TopBar
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 5)

local isMinimized = false
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 0, 0)
Content.AutomaticSize = Enum.AutomaticSize.Y
Content.Position = UDim2.new(0, 0, 0, 45)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 10)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = Content

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingBottom = UDim.new(0, 10)
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)
UIPadding.Parent = Content

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 220, 0, 45)}):Play()
        MinimizeBtn.Text = "+"; Content.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 220, 0, originalSizeY)}):Play()
        MinimizeBtn.Text = "—"; Content.Visible = true
    end
end)

local buttons = {}
local labelsList = {}
local themeBtns = {}

local function makeLabel(text, key)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 20)
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextColor3 = Color3.fromRGB(120, 120, 130)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = text
    l.Parent = Content
    local p = Instance.new("UIPadding"); p.PaddingTop = UDim.new(0, 5); p.Parent = l
    if key then table.insert(labelsList, {label = l, key = key}) end
    return l
end

local function makeBtn(text, key, onClick)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 28)
    b.BackgroundColor3 = COLORS.Button
    b.TextColor3 = Color3.fromRGB(200, 200, 200)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12; b.Text = text
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Parent = Content
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local padding = Instance.new("UIPadding"); padding.PaddingLeft = UDim.new(0, 10); padding.Parent = b
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 75)}):Play() end)
    b.MouseLeave:Connect(function()
        if not b:GetAttribute("Active") then TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Button}):Play() end
    end)
    b.MouseButton1Click:Connect(function() onClick(b) end)
    if key then table.insert(labelsList, {label = b, key = key, isBtn = true}) end
    return b
end

local function makeToggle(labelBase, kind, onToggle, isFly)
    local b
    local thisThemeRef = nil 
    b = makeBtn("○ " .. labelBase, nil, function()
        enabled[kind] = not enabled[kind]
        b:SetAttribute("Active", enabled[kind])
        local langData = LOCALES[CurrentLang]
        local translatedText = isFly and langData.Fly or langData.NoClip
        if kind == "Loot" then translatedText = langData.Loot
        elseif kind == "Police" then translatedText = langData.Police
        elseif kind == "Guard" then translatedText = langData.Guard
        elseif kind == "Civilian" then translatedText = langData.Civilian end
        
        if enabled[kind] then
            b.Text = "● " .. translatedText
            table.insert(ThemeElements, {obj = b, prop = "TextColor3"})
            thisThemeRef = ThemeElements[#ThemeElements] 
            b.TextColor3 = CurrentAccent
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Panel}):Play()
        else
            b.Text = "○ " .. translatedText
            b.TextColor3 = Color3.fromRGB(200, 200, 200)
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.Button}):Play()
            if thisThemeRef then
                for i, v in ipairs(ThemeElements) do
                    if v == thisThemeRef then table.remove(ThemeElements, i); break end
                end
                thisThemeRef = nil
            end
        end
        if onToggle then onToggle(enabled[kind]) end
        if kind == "Loot" then setLoot(enabled[kind]) elseif not enabled[kind] then removeKind(kind) end
    end)
    
    b:SetAttribute("LangKey", kind)
    buttons[kind] = { btn = b, label = labelBase }
end


local function UpdateLanguage()
    local L = LOCALES[CurrentLang]
    Title.Text = L.Title
    SubTitle.Text = L.Sub
    
    for _, item in ipairs(labelsList) do
        if item.key then item.label.Text = L[item.key] end
    end
    

    for _, kind in ipairs({"Loot", "Police", "Guard", "Civilian"}) do
        local b = buttons[kind].btn
        local translatedText = L[kind]
        if b:GetAttribute("Active") then b.Text = "● " .. translatedText else b.Text = "○ " .. translatedText end
    end
    
    local bFly = buttons["Fly"].btn
    if bFly:GetAttribute("Active") then bFly.Text = "● " .. L.Fly else bFly.Text = "○ " .. L.Fly end
    local bNoclip = buttons["NoClip"].btn
    if bNoclip:GetAttribute("Active") then bNoclip.Text = "● " .. L.NoClip else bNoclip.Text = "○ " .. L.NoClip end
    
    local themeKeys = {"Gold", "Red", "Blue", "Green", "Rainbow"}
    for i, theme in ipairs(themeBtns) do
        theme.btn.Text = L[themeKeys[i]]
    end
end

makeLabel(LOCALES[CurrentLang].Move, "Move")
makeToggle("Fly", "Fly", toggleFly, true)
makeToggle("NoClip", "NoClip", toggleNoclip, false)

makeLabel(LOCALES[CurrentLang].Visual, "Visual")
makeToggle("Loot ESP", "Loot")
makeToggle("Police ESP", "Police")
makeToggle("Guard ESP", "Guard")
makeToggle("Civilian ESP", "Civilian")

makeLabel(LOCALES[CurrentLang].Settings, "Settings")
makeBtn(LOCALES[CurrentLang].Clear, "Clear", function()
    enabled.Fly = false
    enabled.NoClip = false
    pcall(toggleFly, false)
    pcall(toggleNoclip, false)
    clearAll()
    for kind, info in pairs(buttons) do
        enabled[kind] = false
        info.btn:SetAttribute("Active", false)
        info.btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        info.btn.BackgroundColor3 = COLORS.Button
    end
    for i = #ThemeElements, 1, -1 do
        if ThemeElements[i].obj:IsA("TextButton") then table.remove(ThemeElements, i) end
    end
    UpdateLanguage() 
end)

makeLabel(LOCALES[CurrentLang].Themes, "Themes")
local Themes = {
    {Key = "Gold", Color = Color3.fromRGB(255, 215, 0)},
    {Key = "Red", Color = Color3.fromRGB(255, 50, 50)},
    {Key = "Blue", Color = Color3.fromRGB(0, 150, 255)},
    {Key = "Green", Color = Color3.fromRGB(0, 255, 100)},
    {Key = "Rainbow", Color = "Rainbow"}
}

for i, theme in ipairs(Themes) do
    local b = makeBtn(LOCALES[CurrentLang][theme.Key], nil, function()
        if theme.Color == "Rainbow" then IsRainbow = true
        else
            IsRainbow = false; CurrentAccent = theme.Color
            for _, item in ipairs(ThemeElements) do
                if item.obj and item.obj.Parent then item.obj[item.prop] = CurrentAccent end
            end
        end
    end)
    table.insert(themeBtns, {btn = b, key = theme.Key})
end

makeLabel(LOCALES[CurrentLang].Lang, "Lang")
local LangFrame = Instance.new("Frame")
LangFrame.Size = UDim2.new(1, 0, 0, 28)
LangFrame.BackgroundTransparency = 1
LangFrame.Parent = Content

local function makeLangBtn(text, langCode, xPos)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.3, 0, 1, 0)
    b.Position = UDim2.new(xPos, 0, 0, 0)
    b.BackgroundColor3 = COLORS.Button
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Text = text
    b.Parent = LangFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        CurrentLang = langCode
        UpdateLanguage()
    end)
    return b
end

makeLangBtn("🇷🇺 RU", "RU", 0)
makeLangBtn("🇺🇦 UA", "UA", 0.35)
makeLangBtn("🇬🇧 EN", "EN", 0.70)

UpdateLanguage()

RunService.RenderStepped:Connect(function()
    if IsRainbow then
        CurrentAccent = Color3.fromHSV((tick() * 0.2) % 1, 1, 1)
        for _, item in ipairs(ThemeElements) do
            if item.obj and item.obj.Parent then item.obj[item.prop] = CurrentAccent end
        end
    end
end)

local unlocked = false
RunService:BindToRenderStep("MouseUnlocker", Enum.RenderPriority.Camera.Value + 1, function()
    if unlocked then UIS.MouseBehavior = Enum.MouseBehavior.Default end
end)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.V then unlocked = not unlocked end
end)

print("🚔 Criminal Hub v37 loaded (English default, Mobile Fly, improved Loot ESP)")
