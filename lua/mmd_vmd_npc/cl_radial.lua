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

local function WrapText(text, font, maxWidth)
    surface.SetFont(font)
    local words = string.Explode(" ", text)
    local lines = {}
    local currentLine = ""

    for _, word in ipairs(words) do
        local testLine = currentLine == "" and word or currentLine .. " " .. word
        local w, h = surface.GetTextSize(testLine)
        if w > maxWidth and currentLine ~= "" then
            table.insert(lines, currentLine)
            currentLine = word
        else
            currentLine = testLine
        end
    end
    table.insert(lines, currentLine)
    return lines
end

function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:Center()
    self:MakePopup()
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
    
    local cx, cy = ScrW()/2, ScrH()/2
    local step = self.Count > 0 and (360 / self.Count) or 0
    local font = "DermaDefaultBold"
    local maxTextWidth = 120
    
    for i = 1, self.Count do
        local startAng = (i - 1) * step - 90 - (step / 2)
        local endAng = startAng + step
        self.Segments[i] = GetArcPoly(cx, cy, startAng, endAng, 260, 80, 30)
        self.LerpAlpha[i] = 0
        local rawName = MMDVMDNPC.GetNiceName(self.Favorites[i] or "Unknown")
        self.PrecachedNames[i] = WrapText(rawName, font, maxTextWidth)
    end

    self.ToggleBtn = {
        w = 240,
        h = 50,
        hover = 0
    }
end

function PANEL:Paint(w, h)
    local cx, cy = w / 2, h / 2
    local mx, my = gui.MousePos()
    local dx, dy = mx - cx, my - cy
    local dist = math.sqrt(dx*dx + dy*dy)
    
    local btnW, btnH = self.ToggleBtn.w, self.ToggleBtn.h
    local btnX, btnY = cx - btnW/2, cy + 280 
    local isOverToggle = mx > btnX and mx < btnX + btnW and my > btnY and my < btnY + btnH
    self.IsOverToggle = isOverToggle  

    -- Choice
    local step = self.Count > 0 and (360 / self.Count) or 0
    self.SelectedIndex = 0
    if dist > 80 and dist < 280 and not isOverToggle then
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
        local tx = cx + math.cos(textAng) * 170
        local ty = cy + math.sin(textAng) * 170
        
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

    -- 2. Follow ToggleR
    self.ToggleBtn.hover = Lerp(FrameTime() * 10, self.ToggleBtn.hover, isOverToggle and 1 or 0)
    
    -- BG
    draw.RoundedBox(8, btnX, btnY, btnW, btnH, Color(15, 15, 15, 220))

    if self.ToggleBtn.hover > 0.01 then
        draw.RoundedBox(8, btnX, btnY, btnW, btnH, Color(50, 150, 255, 100 * self.ToggleBtn.hover))
    end
     
    surface.SetDrawColor(255, 255, 255, 20 + (self.ToggleBtn.hover * 50))
    surface.DrawOutlinedRect(btnX, btnY, btnW, btnH, 1)

    local modeName = MMDVMDNPC.CameraTrackMode and "FOLLOW: ON" or "FOLLOW: OFF"
    local modeCol = MMDVMDNPC.CameraTrackMode and Color(100, 255, 100) or Color(255, 100, 100)
    
    draw.SimpleText(modeName, "DermaDefaultBold", cx, btnY + btnH/2, modeCol, 1, 1)

    surface.SetDrawColor(255, 255, 255, 50)
    surface.DrawRect(cx-1, cy-1, 2, 2)
end

function PANEL:OnMousePressed(mouseCode)
    if mouseCode == MOUSE_LEFT then
        if self.IsOverToggle then
            self:ToggleCameraMode()
        elseif self.SelectedIndex > 0 then
            self:ExecuteSelection(self.SelectedIndex)
        end
    end
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
    local act = self.Favorites[index]
    if not act then return end

    if act == "stop_playback" then
        MMDVMDNPC.RequestStopSelectedMotion()
    else
        net.Start("mmdvmd_select_target")
            net.WriteEntity(LocalPlayer())
        net.SendToServer()

        RunConsoleCommand("mmd_vmd_npc_motion", act)

        timer.Simple(0.1, function()
            MMDVMDNPC.RequestPlaySelectedMotion()
        end)
    end
    
    self:CloseMenu()
end

function PANEL:CloseMenu()
    self:AlphaTo(0, 0.1, 0, function()
        self:Remove()
        gui.EnableScreenClicker(false)
    end)
end

vgui.Register("MMD_RadialMenu", PANEL, "EditablePanel")

-- COMMANDS

local radialMenuInstance = nil

concommand.Add("+mmd_wheel", function()
    if #MMDVMDNPC.RadialFavorites == 0 then 
        notification.AddLegacy("Колесо пусто!", NOTIFY_ERROR, 3)
        return 
    end
    
    if IsValid(radialMenuInstance) then radialMenuInstance:Remove() end
    radialMenuInstance = vgui.Create("MMD_RadialMenu")
end)

concommand.Add("-mmd_wheel", function()
    if IsValid(radialMenuInstance) then
        if radialMenuInstance.SelectedIndex > 0 then
            radialMenuInstance:ExecuteSelection(radialMenuInstance.SelectedIndex)
        else
            radialMenuInstance:CloseMenu()
        end
    end
end)