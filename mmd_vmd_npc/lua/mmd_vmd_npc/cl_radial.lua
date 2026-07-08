MMDVMDNPC.RadialFavorites = MMDVMDNPC.RadialFavorites or {}

local DATA_FILE = "mmdvmd_favorites.json"

function MMDVMDNPC.ToggleFavorite(name)
    if not name or name == "" or name == "stop_playback" then return end

    local found = false
    for k, v in ipairs(MMDVMDNPC.RadialFavorites) do
        if v == name then
            table.remove(MMDVMDNPC.RadialFavorites, k)
            found = true
            break
        end
    end

    if not found then
        table.insert(MMDVMDNPC.RadialFavorites, name)
    end

    MMDVMDNPC.SaveRadial()
    return not found
end

-- Whether a motion id is currently on the wheel (used by the Motion Manager to
-- show wheel membership and label the add/remove button).
function MMDVMDNPC.IsFavorite(name)
    name = tostring(name or "")
    if name == "" then return false end
    for _, v in ipairs(MMDVMDNPC.RadialFavorites or {}) do
        if v == name then return true end
    end
    return false
end

-- Load
function MMDVMDNPC.LoadRadial()
    local raw = file.Read(DATA_FILE, "DATA")
    if raw then
        MMDVMDNPC.RadialFavorites = util.JSONToTable(raw) or {}
    else
        MMDVMDNPC.RadialFavorites = {"stop_playback"}
    end
end

-- Save
function MMDVMDNPC.SaveRadial()
    file.Write(DATA_FILE, util.TableToJSON(MMDVMDNPC.RadialFavorites))
end

MMDVMDNPC.LoadRadial()

-- UI

local function GetArcPoly(x, y, ang1, ang2, radius, inner_radius, res)
    local poly = {}
    local steps = math.max(1, res)
    local step_ang = (ang2 - ang1) / steps
    
    for i = 0, steps do
        local a = math.rad(ang1 + i * step_ang)
        table.insert(poly, { x = x + math.cos(a) * radius, y = y + math.sin(a) * radius })
    end
    for i = steps, 0, -1 do
        local a = math.rad(ang1 + i * step_ang)
        table.insert(poly, { x = x + math.cos(a) * inner_radius, y = y + math.sin(a) * inner_radius })
    end
    return poly
end

local PANEL = {}

local function WrapWord(word, maxWidth)
    -- Break a single space-free word (e.g. a CJK motion title) into chunks that
    -- fit maxWidth, iterating by UTF-8 codepoint so multibyte characters are
    -- never split mid-sequence.
    local chunks = {}
    local current = ""
    local iter = (utf8 and utf8.codes) and utf8.codes or nil
    if iter then
        for _, code in iter(word) do
            local char = utf8.char(code)
            local test = current .. char
            local w = surface.GetTextSize(test)
            if w > maxWidth and current ~= "" then
                chunks[#chunks + 1] = current
                current = char
            else
                current = test
            end
        end
    else
        current = word
    end
    if current ~= "" then chunks[#chunks + 1] = current end
    if #chunks == 0 then chunks[1] = word end
    return chunks
end

local function WrapText(text, font, maxWidth)
    surface.SetFont(font)
    local words = string.Explode(" ", text)
    local lines = {}
    local currentLine = ""

    local function flush()
        if currentLine ~= "" then
            lines[#lines + 1] = currentLine
            currentLine = ""
        end
    end

    for _, word in ipairs(words) do
        local wordWidth = surface.GetTextSize(word)
        if wordWidth > maxWidth then
            -- A single word wider than the box: flush what we have and split it.
            flush()
            for _, chunk in ipairs(WrapWord(word, maxWidth)) do
                lines[#lines + 1] = chunk
            end
        else
            local testLine = currentLine == "" and word or currentLine .. " " .. word
            local w = surface.GetTextSize(testLine)
            if w > maxWidth and currentLine ~= "" then
                lines[#lines + 1] = currentLine
                currentLine = word
            else
                currentLine = testLine
            end
        end
    end
    flush()
    if #lines == 0 then lines[1] = text end
    return lines
end

function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:Center()
    self:MakePopup()
    -- MakePopup grabs keyboard focus, which can swallow the wheel bind's key-up
    -- so -mmd_wheel never fires. The wheel is mouse-driven, so release keyboard
    -- capture and keep only mouse input.
    self:SetKeyboardInputEnabled(false)
    self:SetAlpha(0)
    self:AlphaTo(255, 0.1)

    self.Favorites = {}
    for _, v in ipairs(MMDVMDNPC.RadialFavorites) do
        if v ~= "toggle_cam_mode" then
            table.insert(self.Favorites, v)
        end
    end

    self.Count = #self.Favorites
    self.SelectedIndex = 0
    self.Segments = {}
    self.LerpAlpha = {}
    self.PrecachedNames = {}

    -- Derive the geometry from the viewport so the ring and the FOLLOW toggle
    -- below it stay on screen at low resolutions (e.g. 800x600).
    self.OuterRadius = math.min(260, ScrH() * 0.40)
    self.InnerRadius = self.OuterRadius * 0.31
    self.TextRadius = self.OuterRadius * 0.65

    local cx, cy = ScrW()/2, ScrH()/2
    local step = self.Count > 0 and (360 / self.Count) or 0
    local font = "DermaDefaultBold"
    local maxTextWidth = 120

    for i = 1, self.Count do
        local startAng = (i - 1) * step - 90 - (step / 2)
        local endAng = startAng + step
        self.Segments[i] = GetArcPoly(cx, cy, startAng, endAng, self.OuterRadius, self.InnerRadius, 30)
        self.LerpAlpha[i] = 0
        local rawName = MMDVMDNPC.GetNiceName(self.Favorites[i] or "Unknown")
        self.PrecachedNames[i] = WrapText(rawName, font, maxTextWidth)
    end

    self.ToggleBtn = {
        w = 190,
        h = 50,
        hover = 0
    }
    -- Second button beside FOLLOW: whether playing a motion auto-enters its
    -- imported camera animation (global mmd_vmd_npc_camera_auto option).
    self.CameraBtn = {
        w = 190,
        h = 50,
        hover = 0
    }
end

local function camera_auto_on()
    local cvar = GetConVar("mmd_vmd_npc_camera_auto")
    return not cvar or cvar:GetBool()
end

function PANEL:Paint(w, h)
    local cx, cy = w / 2, h / 2
    local mx, my = gui.MousePos()
    local dx, dy = mx - cx, my - cy
    local dist = math.sqrt(dx*dx + dy*dy)
    
    local outerRadius = self.OuterRadius or 260
    local innerRadius = self.InnerRadius or 80
    local btnW, btnH = self.ToggleBtn.w, self.ToggleBtn.h
    local camW, camH = self.CameraBtn.w, self.CameraBtn.h
    local btnX = cx - btnW - 5
    local camX = cx + 5
    local btnY = math.min(cy + outerRadius + 20, h - btnH - 10)
    local isOverToggle = mx > btnX and mx < btnX + btnW and my > btnY and my < btnY + btnH
    local isOverCamera = mx > camX and mx < camX + camW and my > btnY and my < btnY + camH
    self.IsOverToggle = isOverToggle
    self.IsOverCamera = isOverCamera

    -- Choice
    local step = self.Count > 0 and (360 / self.Count) or 0
    self.SelectedIndex = 0
    if dist > innerRadius and dist < outerRadius and not isOverToggle and not isOverCamera then
        local mouseAngle = math.deg(math.atan2(dy, dx)) + 90
        if mouseAngle < 0 then mouseAngle = mouseAngle + 360 end
        local adjustedAngle = (mouseAngle + step/2) % 360
        self.SelectedIndex = math.floor(adjustedAngle / step) + 1
    end

    draw.NoTexture()

    -- 1. Segments of wheel
    for i = 1, self.Count do
        local isSelected = (i == self.SelectedIndex)
        self.LerpAlpha[i] = Lerp(FrameTime() * 12, self.LerpAlpha[i], isSelected and 255 or 0)
        
        surface.SetDrawColor(15, 15, 15, 220)
        surface.DrawPoly(self.Segments[i])

        if self.LerpAlpha[i] > 1 then
            surface.SetDrawColor(50, 150, 255, self.LerpAlpha[i] * 0.6)
            surface.DrawPoly(self.Segments[i])
        end

        local textAng = math.rad((i - 1) * step - 90)
        local textRadius = self.TextRadius or 170
        local tx = cx + math.cos(textAng) * textRadius
        local ty = cy + math.sin(textAng) * textRadius
        
        local lines = self.PrecachedNames[i]
        local font = "DermaDefaultBold"
        local lineHeight = 14
        local totalHeight = #lines * lineHeight
        local col = isSelected and Color(255, 255, 255) or Color(180, 180, 180)
        
        for k, line in ipairs(lines) do
            local ly = ty - (totalHeight / 2) + (k - 1) * lineHeight + (lineHeight / 2)
            draw.SimpleText(line, font, tx, ly, col, 1, 1)
        end
    end

    -- 2. Follow toggle
    self.ToggleBtn.hover = Lerp(FrameTime() * 10, self.ToggleBtn.hover, isOverToggle and 1 or 0)

    draw.RoundedBox(8, btnX, btnY, btnW, btnH, Color(15, 15, 15, 220))
    if self.ToggleBtn.hover > 0.01 then
        draw.RoundedBox(8, btnX, btnY, btnW, btnH, Color(50, 150, 255, 100 * self.ToggleBtn.hover))
    end
    surface.SetDrawColor(255, 255, 255, 20 + (self.ToggleBtn.hover * 50))
    surface.DrawOutlinedRect(btnX, btnY, btnW, btnH, 1)

    local modeName = MMDVMDNPC.CameraTrackMode and "FOLLOW: ON" or "FOLLOW: OFF"
    local modeCol = MMDVMDNPC.CameraTrackMode and Color(100, 255, 100) or Color(255, 100, 100)
    draw.SimpleText(modeName, "DermaDefaultBold", btnX + btnW/2, btnY + btnH/2, modeCol, 1, 1)

    -- 3. Camera-animation auto-enter toggle
    self.CameraBtn.hover = Lerp(FrameTime() * 10, self.CameraBtn.hover, isOverCamera and 1 or 0)

    draw.RoundedBox(8, camX, btnY, camW, camH, Color(15, 15, 15, 220))
    if self.CameraBtn.hover > 0.01 then
        draw.RoundedBox(8, camX, btnY, camW, camH, Color(50, 150, 255, 100 * self.CameraBtn.hover))
    end
    surface.SetDrawColor(255, 255, 255, 20 + (self.CameraBtn.hover * 50))
    surface.DrawOutlinedRect(camX, btnY, camW, camH, 1)

    local camOn = camera_auto_on()
    local camName = camOn and "CAMERA: ON" or "CAMERA: OFF"
    local camCol = camOn and Color(100, 255, 100) or Color(255, 100, 100)
    draw.SimpleText(camName, "DermaDefaultBold", camX + camW/2, btnY + camH/2, camCol, 1, 1)

    surface.SetDrawColor(255, 255, 255, 50)
    surface.DrawRect(cx-1, cy-1, 2, 2)
end

function PANEL:OnMousePressed(mouseCode)
    if mouseCode == MOUSE_LEFT then
        if self.IsOverToggle then
            self:ToggleCameraMode()
        elseif self.IsOverCamera then
            self:ToggleCameraAuto()
        elseif self.SelectedIndex > 0 then
            self:ExecuteSelection(self.SelectedIndex)
        end
    end
end

function PANEL:ToggleCameraAuto()
    local turnOn = not camera_auto_on()
    RunConsoleCommand("mmd_vmd_npc_camera_auto", turnOn and "1" or "0")
    local label = (MMDVMDNPC.L and MMDVMDNPC.L("mmd_vmd_npc.camera.auto_option", "Enter camera animation automatically"))
        or "Enter camera animation automatically"
    notification.AddLegacy(label .. ": " .. (turnOn and "ON" or "OFF"), NOTIFY_HINT, 3)
    surface.PlaySound("buttons/lightswitch2.wav")
end

function PANEL:ToggleCameraMode()
    MMDVMDNPC.CameraTrackMode = not MMDVMDNPC.CameraTrackMode
    local modeName = MMDVMDNPC.CameraTrackMode and "Dynamic" or "Static"
    notification.AddLegacy("Camera: " .. modeName, NOTIFY_HINT, 3)
    surface.PlaySound("buttons/lightswitch2.wav")
    
    if not MMDVMDNPC.CameraTrackMode and IsValid(MMDVMDNPC.SelfPlaybackCameraEnt) then
        local target = MMDVMDNPC.SelfPlaybackCameraEnt
        local pelvisBone = target:LookupBone("ValveBiped.Bip01_Pelvis") or target:LookupBone("Pelvis") or 0
        local bPos, _ = target:GetBonePosition(pelvisBone)
        MMDVMDNPC.StaticCameraCenter = bPos or target:WorldSpaceCenter()
    end
end

function PANEL:ExecuteSelection(index)
    -- Guard against a double fire: a mouse click executes and starts the close
    -- fade, then the key-up (-mmd_wheel) would execute the same selection again.
    -- CloseMenu (called below) sets self.Closed, so this entry guard blocks the
    -- second call. Do NOT set self.Closed here or CloseMenu becomes a no-op and
    -- the wheel never disappears.
    if self.Closed then return end
    local act = self.Favorites[index]
    if not act then return end

    if act == "stop_playback" then
        MMDVMDNPC.RequestStopSelectedMotion()
    elseif MMDVMDNPC.RequestPlaySelfAuto then
        -- Play the chosen motion on the player, auto-building first if the
        -- playermodel has no cache for it yet.
        MMDVMDNPC.RequestPlaySelfAuto(act)
    end

    self:CloseMenu()
end

function PANEL:CloseMenu()
    if self.Closed then return end
    self.Closed = true
    self:AlphaTo(0, 0.1, 0, function()
        self:Remove()
        gui.EnableScreenClicker(false)
    end)
end

vgui.Register("MMD_RadialMenu", PANEL, "EditablePanel")

-- COMMANDS

local radialMenuInstance = nil

local function radial_empty_message()
    return (MMDVMDNPC.L and MMDVMDNPC.L("mmd_vmd_npc.radial.empty", "Favorites wheel is empty!"))
        or "Favorites wheel is empty!"
end

concommand.Add("+mmd_wheel", function()
    -- Count only entries the wheel will actually show (Init drops
    -- "toggle_cam_mode"), so an all-filtered list does not open an empty wheel.
    local playable = 0
    for _, v in ipairs(MMDVMDNPC.RadialFavorites) do
        if v ~= "toggle_cam_mode" then playable = playable + 1 end
    end
    if playable == 0 then
        notification.AddLegacy(radial_empty_message(), NOTIFY_ERROR, 3)
        return
    end

    if IsValid(radialMenuInstance) then radialMenuInstance:Remove() end
    radialMenuInstance = vgui.Create("MMD_RadialMenu")
end)

concommand.Add("-mmd_wheel", function()
    if IsValid(radialMenuInstance) and not radialMenuInstance.Closed then
        if radialMenuInstance.SelectedIndex > 0 then
            radialMenuInstance:ExecuteSelection(radialMenuInstance.SelectedIndex)
        else
            radialMenuInstance:CloseMenu()
        end
    end
end)