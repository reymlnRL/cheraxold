-- CHERAX ROBLOX • V5 (UI + ESP) - SOLARA REALTIME ESP EDITION

--------------------------------------------------
-- SERVICES / BASE
--------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- SAVE CONFIG (solo UI, no toggles ni posición)
--------------------------------------------------
local SAVE_DIR  = "save/cheraxroblox"
local CONFIG_PATH = SAVE_DIR .. "/config.json"

local DEFAULT = {
    width       = 820,
    height      = 500,
    theme       = "Operator",
    lastTab     = "Player",
    menuSound   = false,
    fpsShow     = false,
    firstLaunch = true   -- para el popup de error
}

-- SIN getgenv: solo _G (Solara safe)
local GlobalEnv = _G
GlobalEnv.CheraxConfig = GlobalEnv.CheraxConfig or DEFAULT

local hasWriteFile  = type(writefile)  == "function"
local hasReadFile   = type(readfile)   == "function"
local hasIsFile     = type(isfile)     == "function"
local hasIsFolder   = type(isfolder)   == "function"
local hasMakeFolder = type(makefolder) == "function"

local _writefile, _readfile, _isfile, _isfolder, _makefolder =
    writefile, readfile, isfile, isfolder, makefolder

local function safeCall(fn, ...)
    local ok, res = pcall(fn, ...)
    if not ok then
        warn("[Cherax] Error:", res)
    end
    return ok, res
end

local function ensureFolder(path)
    if hasIsFolder and hasMakeFolder then
        safeCall(function()
            if not _isfolder(path) then _makefolder(path) end
        end)
    end
end

local function saveConfig()
    if not hasWriteFile then return false end
    local cfg = GlobalEnv.CheraxConfig
    local ok, data = pcall(function() return HttpService:JSONEncode(cfg) end)
    if ok and data then
        ensureFolder(SAVE_DIR)
        safeCall(function() _writefile(CONFIG_PATH, data) end)
        return true
    end
    return false
end

local function loadConfig()
    if not (hasReadFile and hasIsFile and _isfile(CONFIG_PATH)) then return false end
    local ok, raw = pcall(function() return _readfile(CONFIG_PATH) end)
    if not ok or not raw then return false end
    local suc, tbl = pcall(function() return HttpService:JSONDecode(raw) end)
    if suc and type(tbl)=="table" then
        for k,v in pairs(tbl) do
            GlobalEnv.CheraxConfig[k] = v
        end
        return true
    end
    return false
end

safeCall(loadConfig)

--------------------------------------------------
-- GUI BASE
--------------------------------------------------
local gui = playerGui:FindFirstChild("CheraxRoblox")
if not gui then
    gui = Instance.new("ScreenGui")
    gui.Name = "CheraxRoblox"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = playerGui
end

gui.DisplayOrder = 50
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Hint Insert
local function ensureHotkeyHint()
    local h = gui:FindFirstChild("HotkeyHint")
    if not h then
        h = Instance.new("TextLabel")
        h.Name = "HotkeyHint"
        h.Size = UDim2.new(0, 420, 0, 36)
        h.Position = UDim2.new(0.5, -210, 0, 18)
        h.BackgroundColor3 = Color3.fromRGB(20,20,28)
        h.Text = "Press [INSERT] to open Cherax Roblox"
        h.TextColor3 = Color3.fromRGB(185,200,255)
        h.Font = Enum.Font.Gotham
        h.TextSize = 15
        h.BackgroundTransparency = 0
        h.ZIndex = 2000
        h.Parent = gui
        pcall(function()
            Instance.new("UICorner", h).CornerRadius = UDim.new(0,6)
        end)
    end
    return h
end
local hotkeyHint = ensureHotkeyHint()

--------------------------------------------------
-- MAIN FRAME
--------------------------------------------------
local main = gui:FindFirstChild("Main")
if not main then
    main = Instance.new("Frame")
    main.Name = "Main"
    main.Active = true
    main.Size = UDim2.new(0, GlobalEnv.CheraxConfig.width, 0, GlobalEnv.CheraxConfig.height)
    main.Position = UDim2.new(0, 20, 0, 60)
    main.BackgroundColor3 = Color3.fromRGB(15,15,20)
    main.BorderSizePixel = 0
    main.ZIndex = 1500
    main.Parent = gui
    pcall(function()
        Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)
    end)
else
    main.Size = UDim2.new(0, GlobalEnv.CheraxConfig.width, 0, GlobalEnv.CheraxConfig.height)
    main.Position = UDim2.new(0, 20, 0, 60)
end
main.Visible = false

--------------------------------------------------
-- HEADER + VERSION (TESTER UI RGB)
--------------------------------------------------
local header = main:FindFirstChild("HeaderContainer")
if not header then
    header = Instance.new("Frame")
    header.Name = "HeaderContainer"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(12,12,16)
    header.BorderSizePixel = 0
    header.ZIndex = 2000
    header.Parent = main
end

local hdrMain = header:FindFirstChild("TextMain")
if not hdrMain then
    hdrMain = Instance.new("TextLabel")
    hdrMain.Name = "TextMain"
    hdrMain.Size = UDim2.new(0, 250, 1, 0)
    hdrMain.Position = UDim2.new(0, 10, 0, 0)
    hdrMain.BackgroundTransparency = 1
    hdrMain.Font = Enum.Font.GothamBold
    hdrMain.TextSize = 20
    hdrMain.TextColor3 = Color3.fromRGB(255,255,255)
    hdrMain.TextXAlignment = Enum.TextXAlignment.Left
    hdrMain.Text = "CHERAX ROBLOX"
    hdrMain.ZIndex = 2001
    hdrMain.Parent = header
end

local hdrRGB = header:FindFirstChild("TextRGB")
if not hdrRGB then
    hdrRGB = Instance.new("TextLabel")
    hdrRGB.Name = "TextRGB"
    hdrRGB.Size = UDim2.new(0, 220, 1, 0)
    hdrRGB.Position = UDim2.new(0, 260, 0, 0)
    hdrRGB.BackgroundTransparency = 1
    hdrRGB.Font = Enum.Font.GothamBold
    hdrRGB.TextSize = 20
    hdrRGB.TextColor3 = Color3.fromRGB(255, 0, 0)
    hdrRGB.TextXAlignment = Enum.TextXAlignment.Left
    hdrRGB.Text = "| TESTER UI"
    hdrRGB.ZIndex = 2001
    hdrRGB.Parent = header
end

task.spawn(function()
    local t = 0
    while true do
        t += 0.04
        if hdrRGB then
            hdrRGB.TextColor3 = Color3.fromRGB(
                math.sin(t) * 127 + 128,
                math.sin(t + 2) * 127 + 128,
                math.sin(t + 4) * 127 + 128
            )
        end
        task.wait(0.03)
    end
end)

local footer = main:FindFirstChild("VersionLabel")
if not footer then
    footer = Instance.new("TextLabel")
    footer.Name = "VersionLabel"
    footer.Size = UDim2.new(1, -20, 0, 20)
    footer.Position = UDim2.new(0, 10, 1, -24)
    footer.BackgroundTransparency = 1
    footer.Text = "Version: Universal"
    footer.TextColor3 = Color3.fromRGB(150,150,170)
    footer.Font = Enum.Font.Gotham
    footer.TextSize = 13
    footer.ZIndex = 2000
    footer.Parent = main
end

--------------------------------------------------
-- SIDEBAR
--------------------------------------------------
local sidebar = main:FindFirstChild("Sidebar")
if not sidebar then
    sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 170, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = Color3.fromRGB(20,20,28)
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 1600
    sidebar.Parent = main
    pcall(function()
        Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,8)
    end)
else
    sidebar.Size = UDim2.new(0, 170, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
end

local tabsFrame = sidebar:FindFirstChild("Tabs")
local tabsLayout
if not tabsFrame then
    tabsFrame = Instance.new("ScrollingFrame")
    tabsFrame.Name = "Tabs"
    tabsFrame.Size = UDim2.new(1, 0, 1, -60)
    tabsFrame.Position = UDim2.new(0, 0, 0, 50)
    tabsFrame.BackgroundTransparency = 1
    tabsFrame.BorderSizePixel = 0
    tabsFrame.ScrollBarThickness = 4
    tabsFrame.CanvasSize = UDim2.new(0,0,0,0)
    tabsFrame.ZIndex = 1650
    tabsFrame.Parent = sidebar

    tabsLayout = Instance.new("UIListLayout")
    tabsLayout.Parent = tabsFrame
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Padding = UDim.new(0,6)
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    tabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabsFrame.CanvasSize = UDim2.new(0,0,0, tabsLayout.AbsoluteContentSize.Y + 10)
    end)
else
    tabsLayout = tabsFrame:FindFirstChildOfClass("UIListLayout")
end

--------------------------------------------------
-- PAGE AREA
--------------------------------------------------
local pageArea = main:FindFirstChild("PageArea")
if not pageArea then
    pageArea = Instance.new("Frame")
    pageArea.Name = "PageArea"
    pageArea.Size = UDim2.new(1, -170, 1, -60)
    pageArea.Position = UDim2.new(0, 170, 0, 40)
    pageArea.BackgroundColor3 = Color3.fromRGB(13,13,18)
    pageArea.BorderSizePixel = 0
    pageArea.ZIndex = 1600
    pageArea.ClipsDescendants = true
    pageArea.Parent = main
    pcall(function()
        Instance.new("UICorner", pageArea).CornerRadius = UDim.new(0,8)
    end)
else
    pageArea.Size = UDim2.new(1, -170, 1, -60)
    pageArea.Position = UDim2.new(0, 170, 0, 40)
end

local title = pageArea:FindFirstChild("Title")
if not title then
    title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -20, 0, 28)
    title.Position = UDim2.new(0, 10, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextColor3 = Color3.fromRGB(185,200,255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 1700
    title.Text = "Player"
    title.Parent = pageArea
end

--------------------------------------------------
-- THEMES (incluye Operator)
--------------------------------------------------
local themes = {
    Dark = {
        main    = Color3.fromRGB(15,15,20),
        sidebar = Color3.fromRGB(20,20,28),
        page    = Color3.fromRGB(13,13,18),
        text    = Color3.fromRGB(210,210,210),
        accent  = Color3.fromRGB(70,90,255)
    },
    Operator = {
        main    = Color3.fromRGB(28,28,30),
        sidebar = Color3.fromRGB(38,40,44),
        page    = Color3.fromRGB(22,22,24),
        text    = Color3.fromRGB(210,210,210),
        accent  = Color3.fromRGB(0,160,200)
    },
    Neon = {
        main    = Color3.fromRGB(8,10,14),
        sidebar = Color3.fromRGB(10,12,18),
        page    = Color3.fromRGB(8,10,12),
        text    = Color3.fromRGB(190,220,255),
        accent  = Color3.fromRGB(0,170,255)
    }
}

local currentThemeName = GlobalEnv.CheraxConfig.theme or "Operator"
local tabButtons = {}
local currentMainTab = "Player"

--------------------------------------------------
-- SUBTABS PLAYER
--------------------------------------------------
local playerSubTabs = {"General","ESP","Skin (Visual)"}
local playerSubTabButtons = {}
local currentPlayerSubTab = "General"

local subTabBar = pageArea:FindFirstChild("PlayerSubTabs")
if not subTabBar then
    subTabBar = Instance.new("Frame")
    subTabBar.Name = "PlayerSubTabs"
    subTabBar.Position = UDim2.new(0, 10, 0, 40)
    subTabBar.Size = UDim2.new(1, -20, 0, 24)
    subTabBar.BackgroundTransparency = 1
    subTabBar.ZIndex = 1750
    subTabBar.Parent = pageArea

    local layout = Instance.new("UIListLayout")
    layout.Parent = subTabBar
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
end
subTabBar.Visible = false

--------------------------------------------------
-- APPLY THEME
--------------------------------------------------
local function applyTheme(name)
    local t = themes[name] or themes.Operator
    currentThemeName = name
    GlobalEnv.CheraxConfig.theme = name

    TweenService:Create(main, TweenInfo.new(0.18), {BackgroundColor3 = t.main}):Play()
    TweenService:Create(sidebar, TweenInfo.new(0.18), {BackgroundColor3 = t.sidebar}):Play()
    TweenService:Create(pageArea, TweenInfo.new(0.18), {BackgroundColor3 = t.page}):Play()
    title.TextColor3  = t.text
    -- botones se recolorean al cambiar de tab
end

--------------------------------------------------
-- THEME FILE SAVE/LOAD
--------------------------------------------------
local THEME_PATH_PREFIX = SAVE_DIR .. "/theme_"

local function colorToTable(c)
    return {math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5)}
end
local function tableToColor(t)
    return Color3.fromRGB(t[1] or 0, t[2] or 0, t[3] or 0)
end

local function saveThemeToFile(name)
    if not hasWriteFile then return false end
    local th = themes[name]
    if not th then return false end

    local serial = {
        main    = colorToTable(th.main),
        sidebar = colorToTable(th.sidebar),
        page    = colorToTable(th.page),
        text    = colorToTable(th.text),
        accent  = colorToTable(th.accent)
    }

    local ok, raw = pcall(function() return HttpService:JSONEncode(serial) end)
    if not ok or not raw then return false end

    ensureFolder(SAVE_DIR)
    safeCall(function()
        _writefile(THEME_PATH_PREFIX .. name .. ".json", raw)
    end)
    return true
end

local function loadThemeFromFile(name)
    local path = THEME_PATH_PREFIX .. name .. ".json"
    if not (hasReadFile and hasIsFile and _isfile(path)) then return false end

    local ok, raw = pcall(function() return _readfile(path) end)
    if not ok or not raw then return false end

    local suc, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not suc or type(data)~="table" then return false end

    themes[name] = {
        main    = tableToColor(data.main    or {28,28,30}),
        sidebar = tableToColor(data.sidebar or {38,40,44}),
        page    = tableToColor(data.page    or {22,22,24}),
        text    = tableToColor(data.text    or {210,210,210}),
        accent  = tableToColor(data.accent  or {0,160,200})
    }
    applyTheme(name)
    return true
end

--------------------------------------------------
-- SCROLL CONTENT
--------------------------------------------------
local function createScrollContent()
    for _,v in ipairs(pageArea:GetChildren()) do
        if v.Name=="ScrollContent" then v:Destroy() end
    end

    local sf = Instance.new("ScrollingFrame")
    sf.Name = "ScrollContent"
    sf.Parent = pageArea

    local topOffset = (subTabBar and subTabBar.Visible) and 70 or 48
    sf.Position = UDim2.new(0, 10, 0, topOffset)
    sf.Size = UDim2.new(1, -20, 1, -(topOffset + 20))
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 6
    sf.ZIndex = 1700

    local layout = Instance.new("UIListLayout")
    layout.Parent = sf
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Top

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 10)
    end)

    return sf
end

--------------------------------------------------
-- NOTIFS + FPS
--------------------------------------------------
local notifFrame = gui:FindFirstChild("NotifFrame")
if not notifFrame then
    notifFrame = Instance.new("Frame")
    notifFrame.Name = "NotifFrame"
    notifFrame.BackgroundTransparency = 1
    notifFrame.Size = UDim2.new(0, 300, 0, 200)
    notifFrame.Position = UDim2.new(1, -320, 0, 18)
    notifFrame.ZIndex = 3000
    notifFrame.Parent = gui
end

local function notify(text, duration)
    duration = duration or 2
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 32)
    f.Position = UDim2.new(1, 20, 0, 0)
    f.BackgroundColor3 = Color3.fromRGB(28,28,30)
    f.ZIndex = 3001
    f.Parent = notifFrame
    pcall(function()
        Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    end)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -12, 1, 0)
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(230,230,230)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = text
    lbl.ZIndex = 3002
    lbl.Parent = f

    TweenService:Create(f, TweenInfo.new(0.18), {Position = UDim2.new(0,0,0,#notifFrame:GetChildren()*34)}):Play()
    task.delay(duration, function()
        pcall(function()
            TweenService:Create(f, TweenInfo.new(0.15), {Position = UDim2.new(1,20,0,0)}):Play()
        end)
        task.delay(0.18, function()
            pcall(function() f:Destroy() end)
        end)
    end)
end

local fpsLabel = gui:FindFirstChild("CheraxFPS")
if not fpsLabel then
    fpsLabel = Instance.new("TextLabel")
    fpsLabel.Name = "CheraxFPS"
    fpsLabel.Size = UDim2.new(0,120,0,26)
    fpsLabel.Position = UDim2.new(0, 8, 1, -40)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 14
    fpsLabel.TextColor3 = Color3.fromRGB(200,200,200)
    fpsLabel.ZIndex = 4000
    fpsLabel.Parent = gui
end
fpsLabel.Visible = GlobalEnv.CheraxConfig.fpsShow or false

do
    local frameTimes = {}
    RunService:BindToRenderStep("CheraxFPSCalc", Enum.RenderPriority.Last.Value, function(dt)
        table.insert(frameTimes, dt)
        if #frameTimes > 60 then table.remove(frameTimes, 1) end
        if GlobalEnv.CheraxConfig.fpsShow then
            local sum = 0
            for _,v in ipairs(frameTimes) do sum = sum + v end
            local avg = sum / math.max(1, #frameTimes)
            local fps = math.floor(1/avg + 0.5)
            fpsLabel.Text = "FPS: "..tostring(fps)
        end
    end)
end

--------------------------------------------------
-- TOGGLES / ESP / SPEED / SKIN
--------------------------------------------------
local Speed_Enabled    = false
local InfJump_Enabled  = false
local NoClip_Enabled   = false
local TP_Enabled       = false

local SuperSpeed_Enabled       = false
local SuperSpeed_MaxSpeed      = 150
local SuperSpeed_Acceleration  = 8
local SuperSpeedVelocity       = nil

local Speed_Value = 120

local ESP_Enabled      = false
local ESP_Box          = false
local ESP_Name         = false
local ESP_Tracers      = false
local ESP_Distance     = false
local ESP_TeamColor    = false

local ESP_Color_R = 0
local ESP_Color_G = 170
local ESP_Color_B = 255
local ESP_Color   = Color3.fromRGB(ESP_Color_R, ESP_Color_G, ESP_Color_B)

local ToggleStates = {}

-- Drawing check
local hasDrawing = false
pcall(function()
    local test = Drawing.new("Line")
    if test then
        hasDrawing = true
        test:Remove()
    end
end)

local camera = workspace.CurrentCamera
local espConnection
local espObjects = {}
local lastValidHRP = {}
local ESPFreeze = false

local function createDrawingSet()
    local set = {}

    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1
    box.Filled = false
    box.Color = Color3.fromRGB(0,170,255)
    set.Box = box

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1
    tracer.Color = Color3.fromRGB(0,170,255)
    set.Tracer = tracer

    local name = Drawing.new("Text")
    name.Visible = false
    name.Size = 13
    name.Center = true
    name.Outline = true
    name.Color = Color3.fromRGB(255,255,255)
    set.Name = name

    local dist = Drawing.new("Text")
    dist.Visible = false
    dist.Size = 12
    dist.Center = true
    dist.Outline = true
    dist.Color = Color3.fromRGB(200,200,200)
    set.Dist = dist

    return set
end

local function removeESPForPlayer(plr)
    local set = espObjects[plr]
    if not set then return end
    for _,obj in pairs(set) do
        pcall(function() obj:Remove() end)
    end
    espObjects[plr] = nil
    lastValidHRP[plr] = nil
end

local function clearAllESP()
    for plr,_ in pairs(espObjects) do
        removeESPForPlayer(plr)
    end
end

-- ESP REALTIME
local function updateESP()
    if ESPFreeze then return end
    if not ESP_Enabled then
        clearAllESP()
        return
    end
    if not hasDrawing then return end

    local localChar = player.Character
    local localHRP  = localChar and localChar:FindFirstChild("HumanoidRootPart")

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")

            if hrp then
                lastValidHRP[plr] = hrp
            else
                hrp = lastValidHRP[plr]
            end

            if hrp and hum and hum.Health > 0 then
                if not espObjects[plr] then
                    espObjects[plr] = createDrawingSet()
                end
                local set = espObjects[plr]
                local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    local baseColor = ESP_Color
                    if ESP_TeamColor and plr.Team ~= nil then
                        baseColor = plr.Team.Color.Color
                    end

                    if ESP_Box then
                        local topPos = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                        local bottomPos = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        local height = math.abs(topPos.Y - bottomPos.Y)
                        local width  = height / 2

                        set.Box.Visible = true
                        set.Box.Color = baseColor
                        set.Box.Size = Vector2.new(width, height)
                        set.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                    else
                        set.Box.Visible = false
                    end

                    if ESP_Tracers then
                        set.Tracer.Visible = true
                        set.Tracer.Color = baseColor
                        set.Tracer.From  = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                        set.Tracer.To    = Vector2.new(pos.X, pos.Y + 10)
                    else
                        set.Tracer.Visible = false
                    end

                    if ESP_Name then
                        set.Name.Visible = true
                        set.Name.Color = baseColor
                        set.Name.Text = plr.Name
                        set.Name.Position = Vector2.new(pos.X, pos.Y - 20)
                    else
                        set.Name.Visible = false
                    end

                    if ESP_Distance and localHRP then
                        local distNum = (hrp.Position - localHRP.Position).Magnitude
                        set.Dist.Visible = true
                        set.Dist.Text = string.format("[%.0f]", distNum)
                        set.Dist.Position = Vector2.new(pos.X, pos.Y + 20)
                    else
                        set.Dist.Visible = false
                    end
                else
                    if espObjects[plr] then
                        local set = espObjects[plr]
                        set.Box.Visible    = false
                        set.Tracer.Visible = false
                        set.Name.Visible   = false
                        set.Dist.Visible   = false
                    end
                end
            else
                if espObjects[plr] then
                    removeESPForPlayer(plr)
                end
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(plr)
    removeESPForPlayer(plr)
end)

--------------------------------------------------
-- CALLBACKS TOGGLES
--------------------------------------------------
local function OnSpeedToggle(state)
    Speed_Enabled = state
end

local function OnInfJumpToggle(state)
    InfJump_Enabled = state
end

local function OnNoClipToggle(state)
    NoClip_Enabled = state
end

local function OnTeleportToggle(state)
    TP_Enabled = state
end

local function OnSuperSpeedToggle(state)
    SuperSpeed_Enabled = state
    if not state then
        if SuperSpeedVelocity then
            SuperSpeedVelocity:Destroy()
            SuperSpeedVelocity = nil
        end
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
        end
    end
end

local function OnESPEnable(state)
    if not hasDrawing then
        notify("Your executor does not support Drawing (advanced ESP).", 2)
        return
    end
    ESP_Enabled = state
    if ESP_Enabled then
        if not espConnection then
            espConnection = RunService.RenderStepped:Connect(updateESP)
        end
    else
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
        clearAllESP()
    end
end

local function OnESPBoxToggle(state)      ESP_Box = state    end
local function OnESPNameToggle(state)     ESP_Name = state   end
local function OnESPTracersToggle(state)  ESP_Tracers = state end
local function OnESPDistanceToggle(state) ESP_Distance = state end
local function OnESPTeamColorToggle(state) ESP_TeamColor = state end

-- Speed normal (Humanoid.WalkSpeed)
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if Speed_Enabled and not SuperSpeed_Enabled then
        hum:ChangeState(Enum.HumanoidStateType.Running)
        hum.WalkSpeed = Speed_Value
    elseif not Speed_Enabled and not SuperSpeed_Enabled then
        hum.WalkSpeed = 16
    end
end)

-- SuperSpeed (BodyVelocity)
RunService.RenderStepped:Connect(function(dt)
    if not SuperSpeed_Enabled then return end
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end

    if not SuperSpeedVelocity then
        SuperSpeedVelocity = Instance.new("BodyVelocity")
        SuperSpeedVelocity.MaxForce = Vector3.new(1e6,0,1e6)
        SuperSpeedVelocity.Velocity = Vector3.new()
        SuperSpeedVelocity.Parent = hrp
        hum.WalkSpeed = 0
    end

    local moveDir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDir = moveDir + hrp.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDir = moveDir - hrp.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDir = moveDir - hrp.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDir = moveDir + hrp.CFrame.RightVector
    end

    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit
        local current = SuperSpeedVelocity.Velocity.Magnitude
        local target = math.clamp(current + SuperSpeed_Acceleration, 0, SuperSpeed_MaxSpeed)
        SuperSpeedVelocity.Velocity = moveDir * target
    else
        SuperSpeedVelocity.Velocity = SuperSpeedVelocity.Velocity * 0.80
    end
end)

--------------------------------------------------
-- CONTROLES GENERALES UI (TOGGLE / SLIDER)
--------------------------------------------------
local function addToggle(scroll, labelText, defaultState, onToggle)
    local theme = themes[currentThemeName] or themes.Operator
    local key = (currentMainTab or "Main") .. "|" .. (currentPlayerSubTab or "Root") .. "|" .. labelText
    if ToggleStates[key] ~= nil then
        defaultState = ToggleStates[key]
    end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 32)
    btn.BackgroundColor3 = defaultState and theme.accent or Color3.fromRGB(32,32,38)
    btn.BorderSizePixel = 0
    btn.Text = labelText
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.TextColor3 = defaultState and Color3.fromRGB(255,255,255) or theme.text
    btn.AutoButtonColor = false
    btn.ZIndex = 1750
    btn.Parent = scroll

    pcall(function()
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 16)
    end)

    local padding = Instance.new("UIPadding")
    padding.Parent = btn
    padding.PaddingLeft = UDim.new(0, 10)

    btn.MouseButton1Click:Connect(function()
        defaultState = not defaultState
        ToggleStates[key] = defaultState

        local t = themes[currentThemeName] or themes.Operator
        local targetColor = defaultState and t.accent or Color3.fromRGB(32,32,38)
        local targetText  = defaultState and Color3.fromRGB(255,255,255) or t.text

        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
        btn.TextColor3 = targetText

        if onToggle then
            onToggle(defaultState)
        end
    end)
end

-- SLIDER GENERICO (0-255 ó lo que quieras)
local function addSlider(parent, labelText, minValue, maxValue, defaultValue, onChanged)
    local theme = themes[currentThemeName] or themes.Operator

    local holder = Instance.new("Frame")
    holder.Name = "Slider_"..labelText
    holder.Size = UDim2.new(1, -12, 0, 40)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 1750
    holder.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.4, 0, 0, 18)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = theme.text
    lbl.Text = labelText
    lbl.ZIndex = 1751
    lbl.Parent = holder

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 0, 18)
    valueLabel.Position = UDim2.new(0.8, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.TextColor3 = theme.text
    valueLabel.Text = tostring(defaultValue)
    valueLabel.ZIndex = 1751
    valueLabel.Parent = holder

    local barBg = Instance.new("Frame")
    barBg.Name = "BarBg"
    barBg.Size = UDim2.new(1, 0, 0, 8)
    barBg.Position = UDim2.new(0, 0, 0, 22)
    barBg.BackgroundColor3 = Color3.fromRGB(32,32,38)
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 1751
    barBg.Parent = holder
    pcall(function()
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(0,4)
    end)

    local rel0 = (defaultValue - minValue) / (maxValue - minValue)
    rel0 = math.clamp(rel0,0,1)

    local barFill = Instance.new("Frame")
    barFill.Name = "BarFill"
    barFill.Size = UDim2.new(rel0, 0, 1, 0)
    barFill.Position = UDim2.new(0,0,0,0)
    barFill.BackgroundColor3 = theme.accent
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 1752
    barFill.Parent = barBg
    pcall(function()
        Instance.new("UICorner", barFill).CornerRadius = UDim.new(0,4)
    end)

    local dragging = false

    local function setValueFromX(x)
        local rel = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(minValue + rel * (maxValue - minValue) + 0.5)
        valueLabel.Text = tostring(val)
        barFill.Size = UDim2.new(rel, 0, 1, 0)
        if onChanged then
            onChanged(val)
        end
    end

    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setValueFromX(input.Position.X)
        end
    end)

    barBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    barBg.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setValueFromX(input.Position.X)
        end
    end)

    return holder
end

--------------------------------------------------
-- CATEGORÍAS PLAYER (GRID 2 COLUMNAS)
--------------------------------------------------
local function getCategoryGrid(scroll)
    local grid = scroll:FindFirstChild("CategoryGrid")
    if not grid then
        grid = Instance.new("Frame")
        grid.Name = "CategoryGrid"
        grid.BackgroundTransparency = 1
        grid.Size = UDim2.new(1, 0, 1, 0)
        grid.Parent = scroll

        local gl = Instance.new("UIGridLayout")
        gl.Parent = grid
        gl.SortOrder = Enum.SortOrder.LayoutOrder
        gl.CellSize = UDim2.new(0.5, -8, 0, 210)
        gl.CellPadding = UDim2.new(0, 8, 0, 8)
        gl.HorizontalAlignment = Enum.HorizontalAlignment.Left
        gl.VerticalAlignment = Enum.VerticalAlignment.Top
    end
    return grid
end

local function addCategoryBox(scroll, titleText)
    local theme = themes[currentThemeName] or themes.Operator
    local grid = getCategoryGrid(scroll)

    local cat = Instance.new("Frame")
    cat.Name = "Cat_" .. titleText
    cat.BackgroundColor3 = Color3.fromRGB(20,20,28)
    cat.BorderSizePixel = 0
    cat.ZIndex = 1725
    cat.Parent = grid

    pcall(function()
        Instance.new("UICorner", cat).CornerRadius = UDim.new(0, 8)
    end)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "CatTitle"
    titleLbl.Size = UDim2.new(1, -12, 0, 20)
    titleLbl.Position = UDim2.new(0, 6, 0, 6)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextColor3 = theme.text
    titleLbl.Text = titleText
    titleLbl.ZIndex = 1730
    titleLbl.Parent = cat

    local inner = Instance.new("Frame")
    inner.Name = "Inner"
    inner.BackgroundTransparency = 1
    inner.Position = UDim2.new(0, 6, 0, 28)
    inner.Size = UDim2.new(1, -12, 1, -34)
    inner.ZIndex = 1730
    inner.Parent = cat

    local il = Instance.new("UIListLayout")
    il.Parent = inner
    il.SortOrder = Enum.SortOrder.LayoutOrder
    il.Padding = UDim.new(0, 6)
    il.HorizontalAlignment = Enum.HorizontalAlignment.Left
    il.VerticalAlignment = Enum.VerticalAlignment.Top

    return inner
end

--------------------------------------------------
-- RENDER PLAYER: GENERAL / ESP / SKIN
--------------------------------------------------
local function renderPlayerGeneral(scroll)
    local box = addCategoryBox(scroll, "Movement & Speed")

    addToggle(box, "Enable Speed", false, OnSpeedToggle)

    addSlider(box, "Speed", 16, 200, Speed_Value, function(v)
        Speed_Value = v
    end)

    addToggle(box, "Super Speed Mode", false, OnSuperSpeedToggle)
    addSlider(box, "SuperSpeed Max", 50, 600, SuperSpeed_MaxSpeed, function(v)
        SuperSpeed_MaxSpeed = v
    end)
    addSlider(box, "Acceleration", 1, 30, SuperSpeed_Acceleration, function(v)
        SuperSpeed_Acceleration = v
    end)

    addToggle(box, "Enable Inf Jump", false, OnInfJumpToggle)
    addToggle(box, "Enable No-Clip", false, OnNoClipToggle)
    addToggle(box, "Enable Teleport (T)", false, OnTeleportToggle)
end

local function renderPlayerESP(scroll)
    local box = addCategoryBox(scroll, "ESP Options")
    addToggle(box, "ESP Enable",      false, OnESPEnable)
    addToggle(box, "ESP Box",         false, OnESPBoxToggle)
    addToggle(box, "ESP Name",        false, OnESPNameToggle)
    addToggle(box, "ESP Tracers",     false, OnESPTracersToggle)
    addToggle(box, "ESP Distance",    false, OnESPDistanceToggle)
    addToggle(box, "ESP Team Color",  false, OnESPTeamColorToggle)

    local colorBox = addCategoryBox(scroll, "ESP Color")

    local preview = Instance.new("Frame")
    preview.Name = "ColorPreview"
    preview.Size = UDim2.new(1, -12, 0, 22)
    preview.Position = UDim2.new(0, 0, 0, 0)
    preview.BackgroundColor3 = ESP_Color
    preview.BorderSizePixel = 0
    preview.ZIndex = 1750
    preview.Parent = colorBox
    pcall(function()
        Instance.new("UICorner", preview).CornerRadius = UDim.new(0,6)
    end)

    local function updateESPColor()
        ESP_Color = Color3.fromRGB(ESP_Color_R, ESP_Color_G, ESP_Color_B)
        preview.BackgroundColor3 = ESP_Color
    end

    addSlider(colorBox, "Red", 0, 255, ESP_Color_R, function(v)
        ESP_Color_R = v
        updateESPColor()
    end)
    addSlider(colorBox, "Green", 0, 255, ESP_Color_G, function(v)
        ESP_Color_G = v
        updateESPColor()
    end)
    addSlider(colorBox, "Blue", 0, 255, ESP_Color_B, function(v)
        ESP_Color_B = v
        updateESPColor()
    end)
end

-- SKIN (VISUAL) – solo UI visual / placeholder
local function renderPlayerSkin(scroll)
    local boxPreview = addCategoryBox(scroll, "Character Preview")

    local previewFrame = Instance.new("Frame")
    previewFrame.Name = "SkinPreview"
    previewFrame.Size = UDim2.new(1, -12, 0, 120)
    previewFrame.BackgroundColor3 = Color3.fromRGB(18,18,24)
    previewFrame.BorderSizePixel = 0
    previewFrame.ZIndex = 1750
    previewFrame.Parent = boxPreview
    pcall(function()
        Instance.new("UICorner", previewFrame).CornerRadius = UDim.new(0,10)
    end)

    local previewText = Instance.new("TextLabel")
    previewText.Size = UDim2.new(1, -10, 1, -10)
    previewText.Position = UDim2.new(0, 5, 0, 5)
    previewText.BackgroundTransparency = 1
    previewText.Font = Enum.Font.Gotham
    previewText.TextSize = 14
    previewText.TextColor3 = Color3.fromRGB(220,220,230)
    previewText.TextWrapped = true
    previewText.Text = "[SYSTEM ERROR] Character preview unavailable: missing renderer asset."
    previewText.ZIndex = 1751
    previewText.Parent = previewFrame

    local boxOptions = addCategoryBox(scroll, "Skin (Visual) Options")

    addToggle(boxOptions, "Show Hair Change Animation", true, function(state)
        -- aquí podrías disparar anims cutscene de tu personaje
        if state then
            notify("Hair animation: ON (visual only)", 1.5)
        else
            notify("Hair animation: OFF", 1.0)
        end
    end)

    addToggle(boxOptions, "Show Outfit Change Animation", true, function(state)
        if state then
            notify("Outfit animation: ON (visual only)", 1.5)
        else
            notify("Outfit animation: OFF", 1.0)
        end
    end)

    addToggle(boxOptions, "Show Side Rotation", true, function(state)
        if state then
            notify("Side rotation enabled (visual).", 1.5)
        else
            notify("Side rotation disabled.", 1.0)
        end
    end)

    local hairSliderBox = addCategoryBox(scroll, "Hair ID (Visual)")
    addSlider(hairSliderBox, "Hair ID", 1, 10, 1, function(v)
        notify("Hair preset changed (visual ID: "..v..")", 1.1)
    end)
end

--------------------------------------------------
-- PLAYER SUBTAB BUTTONS
--------------------------------------------------
for _,name in ipairs(playerSubTabs) do
    if not playerSubTabButtons[name] then
        local btn = Instance.new("TextButton")
        btn.Name = "Sub_"..name
        btn.Size = UDim2.new(0, 100, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(30,30,40)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Text = name
        btn.TextColor3 = (themes[currentThemeName] or themes.Operator).text
        btn.ZIndex = 1755
        btn.Parent = subTabBar
        pcall(function()
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
        end)
        playerSubTabButtons[name] = btn
    end
end

local function selectPlayerSubTab(name)
    currentPlayerSubTab = name
    local t = themes[currentThemeName] or themes.Operator

    for _,btn in pairs(playerSubTabButtons) do
        btn.BackgroundColor3 = Color3.fromRGB(30,30,40)
        btn.TextColor3 = t.text
    end
    if playerSubTabButtons[name] then
        playerSubTabButtons[name].BackgroundColor3 = t.accent
        playerSubTabButtons[name].TextColor3 = Color3.fromRGB(255,255,255)
    end

    local scroll = createScrollContent()
    if name=="General" then
        renderPlayerGeneral(scroll)
    elseif name=="ESP" then
        renderPlayerESP(scroll)
    elseif name=="Skin (Visual)" then
        renderPlayerSkin(scroll)
    end
end

for name,btn in pairs(playerSubTabButtons) do
    btn.MouseButton1Click:Connect(function()
        selectPlayerSubTab(name)
    end)
end

--------------------------------------------------
-- SETTINGS (themes / tamaño / FPS / config)
--------------------------------------------------
local function renderSettings(scroll)
    for _,c in ipairs(scroll:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end

    local function addLabel(txt)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -12, 0, 22)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold
        l.TextSize = 14
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextColor3 = (themes[currentThemeName] or themes.Operator).text
        l.Text = txt
        l.ZIndex = 1750
        l.Parent = scroll
        return l
    end

    local function addButton(text, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 160, 0, 30)
        b.BackgroundColor3 = Color3.fromRGB(36,36,40)
        b.BorderSizePixel = 0
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.Text = text
        b.TextColor3 = Color3.fromRGB(230,230,230)
        b.ZIndex = 1750
        b.Parent = scroll
        pcall(function()
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        end)
        b.MouseButton1Click:Connect(function()
            safeCall(cb, b)
        end)
        return b
    end

    addLabel("Appearance / Themes")

    local themeRow = Instance.new("Frame")
    themeRow.Size = UDim2.new(1, -12, 0, 32)
    themeRow.BackgroundTransparency = 1
    themeRow.ZIndex = 1750
    themeRow.Parent = scroll

    local tLayout = Instance.new("UIListLayout", themeRow)
    tLayout.FillDirection = Enum.FillDirection.Horizontal
    tLayout.Padding = UDim.new(0, 6)

    local order = {"Operator","Dark","Neon"}
    for _,name in ipairs(order) do
        if themes[name] then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0, 90, 1, 0)
            b.BackgroundColor3 = Color3.fromRGB(36,36,40)
            b.BorderSizePixel = 0
            b.Font = Enum.Font.Gotham
            b.TextSize = 13
            b.Text = name
            b.TextColor3 = Color3.fromRGB(230,230,230)
            b.ZIndex = 1750
            b.Parent = themeRow
            pcall(function()
                Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
            end)
            b.MouseButton1Click:Connect(function()
                applyTheme(name)
                saveConfig()
                notify("Theme applied: "..name, 1.2)
                if currentMainTab == "Player" then
                    selectPlayerSubTab(currentPlayerSubTab or "General")
                else
                    local sc = createScrollContent()
                    renderSettings(sc)
                end
            end)
        end
    end

    addLabel("Theme File")

    local nameRow = Instance.new("Frame")
    nameRow.Size = UDim2.new(1, -12, 0, 28)
    nameRow.BackgroundTransparency = 1
    nameRow.ZIndex = 1750
    nameRow.Parent = scroll

    local themeNameBox = Instance.new("TextBox")
    themeNameBox.Size = UDim2.new(0.5, -4, 1, 0)
    themeNameBox.BackgroundColor3 = Color3.fromRGB(24,24,26)
    themeNameBox.BorderSizePixel = 0
    themeNameBox.Font = Enum.Font.Gotham
    themeNameBox.TextSize = 14
    themeNameBox.TextColor3 = (themes[currentThemeName] or themes.Operator).text
    themeNameBox.PlaceholderText = "Theme name"
    themeNameBox.Text = currentThemeName
    themeNameBox.ZIndex = 1750
    themeNameBox.Parent = nameRow
    pcall(function()
        Instance.new("UICorner", themeNameBox).CornerRadius = UDim.new(0,6)
    end)

    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0.25, -2, 1, 0)
    loadBtn.Position = UDim2.new(0.5, 2, 0, 0)
    loadBtn.BackgroundColor3 = Color3.fromRGB(36,36,40)
    loadBtn.BorderSizePixel = 0
    loadBtn.Font = Enum.Font.Gotham
    loadBtn.TextSize = 13
    loadBtn.Text = "Load Theme"
    loadBtn.TextColor3 = Color3.fromRGB(230,230,230)
    loadBtn.ZIndex = 1750
    loadBtn.Parent = nameRow
    pcall(function()
        Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0,6)
    end)

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.25, -2, 1, 0)
    saveBtn.Position = UDim2.new(0.75, 2, 0, 0)
    saveBtn.BackgroundColor3 = Color3.fromRGB(36,36,40)
    saveBtn.BorderSizePixel = 0
    saveBtn.Font = Enum.Font.Gotham
    saveBtn.TextSize = 13
    saveBtn.Text = "Save Theme"
    saveBtn.TextColor3 = Color3.fromRGB(230,230,230)
    saveBtn.ZIndex = 1750
    saveBtn.Parent = nameRow
    pcall(function()
        Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,6)
    end)

    loadBtn.MouseButton1Click:Connect(function()
        local nm = themeNameBox.Text ~= "" and themeNameBox.Text or currentThemeName
        if loadThemeFromFile(nm) then
            notify("Theme loaded: "..nm, 1.5)
        else
            notify("Theme load failed: "..nm, 2)
        end
    end)

    saveBtn.MouseButton1Click:Connect(function()
        if not hasWriteFile then
            notify("Executor does not support writefile/readfile.", 2)
            return
        end
        local nm = themeNameBox.Text ~= "" and themeNameBox.Text or currentThemeName
        if saveThemeToFile(nm) then
            notify("Theme saved: "..nm, 1.8)
        else
            notify("Theme save error: "..nm, 2)
        end
    end)

    addLabel("Menu Size")

    local sizes = {
        Small   = {600,380},
        Default = {820,500},
        Large   = {940,580},
        XL      = {1050,650}
    }

    local sizeRow = Instance.new("Frame")
    sizeRow.Size = UDim2.new(1, -12, 0, 32)
    sizeRow.BackgroundTransparency = 1
    sizeRow.ZIndex = 1750
    sizeRow.Parent = scroll

    local sLayout = Instance.new("UIListLayout", sizeRow)
    sLayout.FillDirection = Enum.FillDirection.Horizontal
    sLayout.Padding = UDim.new(0,6)

    local function resizeMenu(w,h)
        w = math.clamp(w, 600, 1100)
        h = math.clamp(h, 380, 650)
        GlobalEnv.CheraxConfig.width  = w
        GlobalEnv.CheraxConfig.height = h
        TweenService:Create(main, TweenInfo.new(0.18),
            {Size = UDim2.new(0,w,0,h)}):Play()
    end

    for name,sz in pairs(sizes) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 95, 1, 0)
        b.BackgroundColor3 = Color3.fromRGB(36,36,40)
        b.BorderSizePixel = 0
        b.Font = Enum.Font.Gotham
        b.TextSize = 13
        b.Text = name
        b.TextColor3 = Color3.fromRGB(230,230,230)
        b.ZIndex = 1750
        b.Parent = sizeRow
        pcall(function()
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        end)

        b.MouseButton1Click:Connect(function()
            resizeMenu(sz[1], sz[2])
            saveConfig()
            notify("Size set: "..name, 1.2)
        end)
    end

    addLabel("FPS Counter")
    addButton(GlobalEnv.CheraxConfig.fpsShow and "FPS: ON" or "FPS: OFF", function(btn)
        GlobalEnv.CheraxConfig.fpsShow = not GlobalEnv.CheraxConfig.fpsShow
        fpsLabel.Visible = GlobalEnv.CheraxConfig.fpsShow
        btn.Text = GlobalEnv.CheraxConfig.fpsShow and "FPS: ON" or "FPS: OFF"
        saveConfig()
    end)

    addLabel("Config")
    addButton("Save Config", function()
        saveConfig()
        notify("Config saved.",1.2)
    end)
    addButton("Reload Config", function()
        loadConfig()
        notify("Config reloaded (UI).",1.2)
    end)
end

--------------------------------------------------
-- MAIN TABS
--------------------------------------------------
local mainTabs = {
    "Player","Player List","Spawner","Vehicle","Weapon",
    "Recovery","Misc","Protection","SCAPI","Menus","Settings"
}

for _,name in ipairs(mainTabs) do
    local key = name:gsub("%s","_")
    local b = tabsFrame:FindFirstChild(key)
    if not b then
        b = Instance.new("TextButton")
        b.Name = key
        b.Size = UDim2.new(1, -18, 0, 30)
        b.BackgroundColor3 = Color3.fromRGB(30,30,40)
        b.BorderSizePixel = 0
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.Text = name
        b.TextColor3 = Color3.fromRGB(200,200,200)
        b.ZIndex = 1650
        b.Parent = tabsFrame
        pcall(function()
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        end)
    end
    tabButtons[name] = b
end

local function selectTab(tab)
    currentMainTab = tab
    GlobalEnv.CheraxConfig.lastTab = tab
    title.Text = tab

    local theme = themes[currentThemeName] or themes.Operator
    for _,btn in pairs(tabButtons) do
        btn.BackgroundColor3 = theme.sidebar
        btn.TextColor3 = theme.text
    end
    if tabButtons[tab] then
        tabButtons[tab].BackgroundColor3 = theme.accent
        tabButtons[tab].TextColor3 = Color3.fromRGB(255,255,255)
    end

    if tab == "Player" then
        subTabBar.Visible = true
        selectPlayerSubTab(currentPlayerSubTab or "General")
    else
        subTabBar.Visible = false
        local scroll = createScrollContent()
        if tab == "Settings" then
            renderSettings(scroll)
        else
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -12, 0, 80)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 16
            lbl.TextColor3 = theme.text
            lbl.TextWrapped = true
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = "Content of "..tab.." (UI ready, logic WIP)."
            lbl.ZIndex = 1750
            lbl.Parent = scroll
        end
    end
end

for name,btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        selectTab(name)
    end)
end

--------------------------------------------------
-- POPUP WINDOWS STYLE (Cherax Roblox Loader Error)
--------------------------------------------------
local popupOpen = false

local function showWindowsError()
    if gui:FindFirstChild("CheraxErrorPopup") then
        gui.CheraxErrorPopup:Destroy()
    end

    popupOpen = true
    hotkeyHint.Visible = false

    local back = Instance.new("Frame")
    back.Name = "CheraxErrorPopup"
    back.Size = UDim2.new(1,0,1,0)
    back.Position = UDim2.new(0,0,0,0)
    back.BackgroundColor3 = Color3.fromRGB(0,0,0)
    back.BackgroundTransparency = 0.35
    back.ZIndex = 5000
    back.Parent = gui

    local win = Instance.new("Frame")
    win.Name = "ErrorWindow"
    win.Size = UDim2.new(0, 420, 0, 180)
    win.Position = UDim2.new(0.5, -210, 0.5, -90)
    win.BackgroundColor3 = Color3.fromRGB(240,240,240)
    win.BorderSizePixel = 0
    win.ZIndex = 5001
    win.Parent = back
    pcall(function()
        Instance.new("UICorner", win).CornerRadius = UDim.new(0,4)
    end)

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1,0,0,26)
    titleBar.BackgroundColor3 = Color3.fromRGB(0,120,215)
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 5002
    titleBar.Parent = win

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1,-10,1,0)
    tLabel.Position = UDim2.new(0,6,0,0)
    tLabel.BackgroundTransparency = 1
    tLabel.Font = Enum.Font.SourceSansBold
    tLabel.TextSize = 15
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.TextColor3 = Color3.fromRGB(255,255,255)
    tLabel.Text = "Cherax Roblox - Loader Error"
    tLabel.ZIndex = 5003
    tLabel.Parent = titleBar

    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1,-20,0,70)
    msg.Position = UDim2.new(0,10,0,40)
    msg.BackgroundTransparency = 1
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 14
    msg.TextWrapped = true
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextYAlignment = Enum.TextYAlignment.Top
    msg.TextColor3 = Color3.fromRGB(20,20,20)
    msg.Text = "You are running a TEST build of Cherax Roblox.\n\nYou may experience crashes, bugs or unexpected behaviour.\nUse at your own risk."
    msg.ZIndex = 5003
    msg.Parent = win

    local extra = Instance.new("TextLabel")
    extra.Size = UDim2.new(1,-20,0,20)
    extra.Position = UDim2.new(0,10,0,110)
    extra.BackgroundTransparency = 1
    extra.Font = Enum.Font.Gotham
    extra.TextSize = 12
    extra.TextXAlignment = Enum.TextXAlignment.Left
    extra.TextColor3 = Color3.fromRGB(90,90,90)
    extra.Text = "If this window appears often, your loader may be unstable."
    extra.ZIndex = 5003
    extra.Parent = win

    local okBtn = Instance.new("TextButton")
    okBtn.Size = UDim2.new(0,90,0,26)
    okBtn.Position = UDim2.new(1,-100,1,-34)
    okBtn.BackgroundColor3 = Color3.fromRGB(0,120,215)
    okBtn.BorderSizePixel = 0
    okBtn.Font = Enum.Font.Gotham
    okBtn.TextSize = 14
    okBtn.TextColor3 = Color3.fromRGB(255,255,255)
    okBtn.Text = "OK"
    okBtn.ZIndex = 5003
    okBtn.Parent = win
    pcall(function()
        Instance.new("UICorner", okBtn).CornerRadius = UDim.new(0,4)
    end)

    okBtn.MouseButton1Click:Connect(function()
        popupOpen = false
        GlobalEnv.CheraxConfig.firstLaunch = false
        saveConfig()
        notify("Tester build acknowledged.", 2)
        back:Destroy()
        hotkeyHint.Visible = true
    end)
end

--------------------------------------------------
-- DRAG MAIN
--------------------------------------------------
local dragging = false
local dragStart, startPos

main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

main.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

--------------------------------------------------
-- OPEN/CLOSE (INSERT)
--------------------------------------------------
local menuOpen = false

local function openMenu()
    if menuOpen or popupOpen then return end
    menuOpen = true
    hotkeyHint.Visible = false
    main.Visible = true

    ESPFreeze = true
    main.BackgroundTransparency = 1
    TweenService:Create(main, TweenInfo.new(0.2), {
        BackgroundTransparency = 0
    }):Play()
    task.delay(0.25, function()
        ESPFreeze = false
    end)

    notify("Cherax opened", 1.0)
end

local function closeMenu()
    if not menuOpen then return end
    menuOpen = false

    ESPFreeze = true
    TweenService:Create(main, TweenInfo.new(0.18), {
        BackgroundTransparency = 1
    }):Play()

    task.delay(0.25, function()
        ESPFreeze = false
        if not menuOpen then
            main.Visible = false
            hotkeyHint.Visible = true
        end
    end)

    notify("Cherax closed", 0.8)
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or popupOpen then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        if menuOpen then
            closeMenu()
        else
            openMenu()
        end
    end
end)

--------------------------------------------------
-- INIT
--------------------------------------------------
if GlobalEnv.CheraxConfig.firstLaunch == nil then
    GlobalEnv.CheraxConfig.firstLaunch = true
end

applyTheme(currentThemeName or "Operator")
selectTab("Player")

if GlobalEnv.CheraxConfig.firstLaunch then
    task.delay(0.2, function()
        showWindowsError()
    end)
end

print("[Cherax V5 UI+ESP] loaded (Solara Realtime ESP Edition). Press INSERT to open/close. Config:", CONFIG_PATH)
--------------------------------------------------
-- ANTI-KICK PRO (Studio Safe)
--------------------------------------------------

local StarterGui = game:GetService("StarterGui")
local notify = notify or function(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Cherax Protection";
            Text = msg;
            Duration = 3;
        })
    end)
end

-- Log visual de acciones anti-kick
local function kickLog(msg)
    notify("⚠ " .. msg)
end

-- Interceptar Kick() local
local mt = getrawmetatable(game)
if mt then
    setreadonly(mt, false)
    local old = mt.__namecall

    mt.__namecall = function(self, ...)
        local method = getnamecallmethod()

        if tostring(method) == "Kick" or tostring(method) == "kick" then

            kickLog("The game is trying to kick you. Intercepting…")

            -- BLOQUEO
            return nil
        end

        return old(self, ...)
    end
    setreadonly(mt, true)
end

kickLog("Anti-Kick is active (Studio build)")

