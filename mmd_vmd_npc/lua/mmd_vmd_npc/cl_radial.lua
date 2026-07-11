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
    -- Every UI showing wheel membership (manager list/button, tool-panel quick
    -- button) refreshes off this, so they can never disagree about the state.
    hook.Run("MMDVMDNPCWheelFavoritesChanged")
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

local SLOTS_PER_PAGE = 9
local MOTIONS_PER_PAGE = SLOTS_PER_PAGE - 1 -- slot 1 is always the Stop button

-- Dropdown value for the curated favorites view; every other value is a
-- category filter over ALL known dances ("" = all categories).
local FAVORITES_FILTER = "__favorites"

local function camera_auto_on()
    local cvar = GetConVar("mmd_vmd_npc_camera_auto")
    return not cvar or cvar:GetBool()
end

local function camera_follow_on()
    local cvar = GetConVar("mmd_vmd_npc_cam_follow")
    return cvar ~= nil and cvar:GetBool()
end

local function WL(key, fallback)
    return (MMDVMDNPC.L and MMDVMDNPC.L(key, fallback)) or fallback
end

function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:Center()
    self:MakePopup()
    -- MakePopup grabs keyboard focus, which can swallow the wheel bind's key-up
    -- so -mmd_wheel never fires. The wheel is mouse-driven, so release keyboard
    -- capture and keep only mouse input.
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(true)
    self:SetAlpha(0)
    self:AlphaTo(255, 0.1)

    self.Page = 0
    self.SelectedSlot = 0
    self.Segments = {}
    self.LerpAlpha = {}

    -- Larger ring; still derived from the viewport so it and the bottom toggles
    -- stay on screen at low resolutions. The ScrH()/2 - 86 term reserves room
    -- above the ring for the category dropdown (10px margin + 30px combo +
    -- 46px gap) so it can never sit on the STOP slot's outer rim.
    self.OuterRadius = math.min(360, ScrH() * 0.46, ScrH() / 2 - 86)
    self.InnerRadius = self.OuterRadius * 0.34
    self.TextRadius = (self.OuterRadius + self.InnerRadius) * 0.5

    local cx, cy = ScrW() / 2, ScrH() / 2
    local step = 360 / SLOTS_PER_PAGE
    for i = 1, SLOTS_PER_PAGE do
        local startAng = (i - 1) * step - 90 - (step / 2)
        self.Segments[i] = GetArcPoly(cx, cy, startAng, startAng + step, self.OuterRadius, self.InnerRadius, 24)
        self.LerpAlpha[i] = 0
    end

    -- Three buttons in a row under the ring: FOLLOW (self third-person camera
    -- mode), CAMERA (auto-enter imported camera animation) and CENTER (force
    -- the imported camera to keep the character in frame).
    self.ToggleBtn = { w = 150, h = 50, hover = 0 }
    self.CameraBtn = { w = 150, h = 50, hover = 0 }
    self.CenterBtn = { w = 150, h = 50, hover = 0 }

    -- Category filter above the ring: same categories as the Motion Manager
    -- (addon categories + User Import), remembered across opens.
    self.CategoryFilter = cookie and cookie.GetString and cookie.GetString("mmdvmd_wheel_category", "") or ""
    local combo = vgui.Create("DComboBox", self)
    self.CategoryCombo = combo
    combo:SetSize(250, 30)
    combo:SetPos(cx - 125, math.max(10, cy - self.OuterRadius - 46))
    combo:SetSortItems(false)
    combo:SetFont("DermaDefaultBold")
    combo.OnSelect = function(_, _, _, value)
        self.CategoryFilter = tostring(value or "")
        if cookie and cookie.Set then cookie.Set("mmdvmd_wheel_category", self.CategoryFilter) end
        self.Page = 0
        self:RebuildMotions()
    end
    self:RebuildCategoryCombo()

    self:RebuildMotions()

    -- Categories need the streamed details; ask for them if this client has
    -- not opened any motion UI yet, and refresh live when they arrive.
    if MMDVMDNPC.RequestMotionDetails and #(MMDVMDNPC.MotionDetailsOrdered or {}) == 0 then
        MMDVMDNPC.RequestMotionDetails()
    end
    local hookID = "MMDVMDNPCRadialDetails_" .. tostring(self)
    self.DetailsHookID = hookID
    hook.Add("MMDVMDNPCMotionDetailsUpdated", hookID, function()
        if IsValid(self) then
            self:RebuildCategoryCombo()
            self:RebuildMotions()
        end
    end)
end

function PANEL:OnRemove()
    if self.DetailsHookID then
        hook.Remove("MMDVMDNPCMotionDetailsUpdated", self.DetailsHookID)
    end
end

function PANEL:RebuildCategoryCombo()
    local combo = self.CategoryCombo
    if not IsValid(combo) then return end
    -- Never rebuild under an open dropdown (Clear() rips the menu away
    -- mid-pick); the next details update rebuilds it anyway.
    if combo.IsMenuOpen and combo:IsMenuOpen() then return end
    combo:Clear()
    -- No select flags: AddChoice(select=true) fires OnSelect synchronously,
    -- which would reset the page and rewrite the cookie on every details
    -- refresh while the wheel is open. Display the selection via SetValue.
    combo:AddChoice(WL("mmd_vmd_npc.category.all", "All Categories"), "")
    combo:AddChoice(WL("mmd_vmd_npc.radial.favorites", "★ Favorites"), FAVORITES_FILTER)
    local found = (self.CategoryFilter or "") == "" or self.CategoryFilter == FAVORITES_FILTER
    if MMDVMDNPC.MotionCategories then
        for _, category in ipairs(MMDVMDNPC.MotionCategories()) do
            found = found or category == self.CategoryFilter
            local label = MMDVMDNPC.CategoryDisplayName and MMDVMDNPC.CategoryDisplayName(category) or category
            combo:AddChoice(label, category)
        end
    end
    local function display_name(category)
        if (category or "") == "" then return WL("mmd_vmd_npc.category.all", "All Categories") end
        if category == FAVORITES_FILTER then return WL("mmd_vmd_npc.radial.favorites", "★ Favorites") end
        return MMDVMDNPC.CategoryDisplayName and MMDVMDNPC.CategoryDisplayName(category) or category
    end
    if found then
        combo:SetValue(display_name(self.CategoryFilter))
    elseif #(MMDVMDNPC.MotionDetailsOrdered or {}) == 0 then
        -- Details not streamed yet: keep the remembered filter (and cookie);
        -- this runs again when the details arrive and can truly validate it.
        combo:SetValue(display_name(self.CategoryFilter))
    else
        self.CategoryFilter = ""
        if cookie and cookie.Set then cookie.Set("mmdvmd_wheel_category", "") end
        combo:SetValue(display_name(""))
    end
end

-- The wheel's motion list. The category views auto-populate with EVERY known
-- dance of that scope (no manual adding needed); the ★ Favorites view is the
-- user-curated list. The Stop button and empty slots come from the fixed
-- 9-slot layout, not from this list.
function PANEL:RebuildMotions()
    self.Motions = {}
    local filter = self.CategoryFilter or ""

    if filter == FAVORITES_FILTER then
        -- Curated list, in the user's own order.
        for _, v in ipairs(MMDVMDNPC.RadialFavorites) do
            if v ~= "toggle_cam_mode" and v ~= "stop_playback" then
                self.Motions[#self.Motions + 1] = v
            end
        end
    else
        local ordered = MMDVMDNPC.MotionDetailsOrdered or {}
        if #ordered > 0 then
            for _, meta in ipairs(ordered) do
                local ok = true
                if MMDVMDNPC.MotionMatchesCategory then
                    ok = MMDVMDNPC.MotionMatchesCategory(meta, filter)
                end
                if ok then
                    self.Motions[#self.Motions + 1] = tostring(meta.id or "")
                end
            end
        elseif filter == "" then
            -- Details not streamed yet: bare id list keeps the wheel usable
            -- right after joining; the details hook rebuilds when they land.
            for _, id in ipairs(MMDVMDNPC.ClientMotions or {}) do
                self.Motions[#self.Motions + 1] = tostring(id or "")
            end
        end
        -- Stable, scannable page order for the auto views.
        table.sort(self.Motions, function(a, b)
            local na = MMDVMDNPC.GetNiceName and MMDVMDNPC.GetNiceName(a) or a
            local nb = MMDVMDNPC.GetNiceName and MMDVMDNPC.GetNiceName(b) or b
            if na == nb then return a < b end
            return string.lower(na) < string.lower(nb)
        end)
    end

    self.PageCount = math.max(1, math.ceil(#self.Motions / MOTIONS_PER_PAGE))
    self.Page = math.Clamp(self.Page or 0, 0, self.PageCount - 1)
    self:RebuildPageNames()
end

-- What a given ring slot does on the current page. Slot 1 is always Stop.
function PANEL:SlotAction(i)
    if i == 1 then return "stop", nil end
    local motionIdx = self.Page * MOTIONS_PER_PAGE + (i - 1)
    local id = self.Motions[motionIdx]
    if id then return "motion", id end
    return "empty", nil
end

function PANEL:RebuildPageNames()
    self.SlotNames = {}
    self.SlotSubNames = {}
    self.SlotMissing = {}
    -- Only trust "missing" once the server's details have streamed; an empty
    -- cache just means this client has not requested them yet.
    local details = MMDVMDNPC.MotionDetails or {}
    local haveDetails = next(details) ~= nil
    for i = 1, SLOTS_PER_PAGE do
        local kind, id = self:SlotAction(i)
        if kind == "stop" then
            self.SlotNames[i] = { WL("mmd_vmd_npc.radial.stop", "STOP") }
        elseif kind == "motion" then
            local nice = MMDVMDNPC.GetNiceName(id or "Unknown")
            self.SlotNames[i] = WrapText(nice, "DermaDefaultBold", 150)
            -- English name (from the imported metadata) as a dimmer sub line,
            -- when it exists and adds information beyond the display name.
            local meta = details[id]
            local english = meta and tostring(meta.englishName or "") or ""
            if english ~= "" and string.lower(english) ~= string.lower(nice) then
                local wrapped = WrapText(english, "DermaDefault", 150)
                if #wrapped > 2 then
                    wrapped = { wrapped[1], wrapped[2] .. "…" }
                end
                self.SlotSubNames[i] = wrapped
            end
            -- A favorite whose motion JSON no longer exists (deleted by hand):
            -- unplayable, drawn red, removable with right-click.
            self.SlotMissing[i] = haveDetails and details[id] == nil or false
        else
            self.SlotNames[i] = {}
        end
    end
end

function PANEL:Paint(w, h)
    local cx, cy = w / 2, h / 2
    local mx, my = gui.MousePos()
    local dx, dy = mx - cx, my - cy
    local dist = math.sqrt(dx * dx + dy * dy)

    local outerRadius = self.OuterRadius or 320
    local innerRadius = self.InnerRadius or 100
    local btnW, btnH = self.ToggleBtn.w, self.ToggleBtn.h
    local camW, camH = self.CameraBtn.w, self.CameraBtn.h
    local cenW, cenH = self.CenterBtn.w, self.CenterBtn.h
    local gap = 8
    local btnX = cx - (btnW + camW + cenW + gap * 2) / 2
    local camX = btnX + btnW + gap
    local cenX = camX + camW + gap
    local btnY = math.min(cy + outerRadius + 20, h - btnH - 10)
    local isOverToggle = mx > btnX and mx < btnX + btnW and my > btnY and my < btnY + btnH
    local isOverCamera = mx > camX and mx < camX + camW and my > btnY and my < btnY + camH
    local isOverCenter = mx > cenX and mx < cenX + cenW and my > btnY and my < btnY + cenH
    self.IsOverToggle = isOverToggle
    self.IsOverCamera = isOverCamera
    self.IsOverCenter = isOverCenter

    -- No ring selection while the category dropdown (or its open menu, which
    -- overlaps the ring) has the mouse: releasing the wheel key mid-pick must
    -- not fire a slot.
    local combo = self.CategoryCombo
    local comboBusy = IsValid(combo)
        and ((combo.IsMenuOpen and combo:IsMenuOpen()) or combo:IsHovered())

    local step = 360 / SLOTS_PER_PAGE
    self.SelectedSlot = 0
    if dist > innerRadius and dist < outerRadius and not isOverToggle and not isOverCamera and not isOverCenter and not comboBusy then
        local mouseAngle = math.deg(math.atan2(dy, dx)) + 90
        if mouseAngle < 0 then mouseAngle = mouseAngle + 360 end
        local adjustedAngle = (mouseAngle + step / 2) % 360
        self.SelectedSlot = math.floor(adjustedAngle / step) + 1
    end

    draw.NoTexture()

    for i = 1, SLOTS_PER_PAGE do
        local kind = self:SlotAction(i)
        local isEmpty = kind == "empty"
        local isStop = kind == "stop"
        local isSelected = (i == self.SelectedSlot) and not isEmpty
        self.LerpAlpha[i] = Lerp(FrameTime() * 12, self.LerpAlpha[i], isSelected and 255 or 0)

        surface.SetDrawColor(15, 15, 15, isEmpty and 110 or 220)
        surface.DrawPoly(self.Segments[i])

        if self.LerpAlpha[i] > 1 then
            if isStop then
                surface.SetDrawColor(220, 70, 70, self.LerpAlpha[i] * 0.6)
            else
                surface.SetDrawColor(50, 150, 255, self.LerpAlpha[i] * 0.6)
            end
            surface.DrawPoly(self.Segments[i])
        end

        local textAng = math.rad((i - 1) * step - 90)
        local tx = cx + math.cos(textAng) * self.TextRadius
        local ty = cy + math.sin(textAng) * self.TextRadius

        if isEmpty then
            draw.SimpleText("—", "DermaDefaultBold", tx, ty, Color(95, 95, 95), 1, 1)
        else
            local lines = self.SlotNames[i] or {}
            local subLines = self.SlotSubNames and self.SlotSubNames[i] or nil
            local lineHeight = 15
            local subLineHeight = 13
            local totalHeight = #lines * lineHeight + (subLines and #subLines * subLineHeight or 0)
            local col, subCol
            if isStop then
                col = isSelected and Color(255, 160, 160) or Color(232, 96, 96)
            elseif self.SlotMissing and self.SlotMissing[i] then
                col = isSelected and Color(255, 140, 140) or Color(210, 100, 100)
                subCol = isSelected and Color(225, 120, 120) or Color(175, 90, 90)
            else
                col = isSelected and Color(255, 255, 255) or Color(188, 188, 188)
                subCol = isSelected and Color(215, 215, 215) or Color(150, 150, 150)
            end
            local textY = ty - totalHeight / 2
            for _, line in ipairs(lines) do
                draw.SimpleText(line, "DermaDefaultBold", tx, textY + lineHeight / 2, col, 1, 1)
                textY = textY + lineHeight
            end
            for _, line in ipairs(subLines or {}) do
                draw.SimpleText(line, "DermaDefault", tx, textY + subLineHeight / 2, subCol, 1, 1)
                textY = textY + subLineHeight
            end
        end
    end

    -- Center: page indicator + scroll hint (only when there is more than 1 page),
    -- or a hint when the current category filter matches nothing on the wheel.
    if self.PageCount > 1 then
        draw.SimpleText(
            string.format(WL("mmd_vmd_npc.radial.page_fmt", "Page %d / %d"), self.Page + 1, self.PageCount),
            "DermaDefaultBold", cx, cy - 9, Color(255, 255, 255), 1, 1)
        draw.SimpleText(WL("mmd_vmd_npc.radial.scroll_hint", "Scroll to switch pages"),
            "DermaDefault", cx, cy + 11, Color(180, 180, 180), 1, 1)
    elseif #(self.Motions or {}) == 0 and (self.CategoryFilter or "") ~= "" then
        local emptyText = self.CategoryFilter == FAVORITES_FILTER
            and WL("mmd_vmd_npc.radial.favorites_empty", "No favorites yet — add dances via the Motion Manager or menu")
            or WL("mmd_vmd_npc.radial.category_empty", "No wheel dances in this category")
        draw.SimpleText(emptyText, "DermaDefault", cx, cy, Color(180, 180, 180), 1, 1)
    end

    -- Hovering a favorite whose motion file is gone: say so and how to fix it.
    if self.SelectedSlot > 1 and self.SlotMissing and self.SlotMissing[self.SelectedSlot] then
        draw.SimpleText(WL("mmd_vmd_npc.radial.missing_hint", "Motion file is missing — right-click to remove it from the wheel"),
            "DermaDefaultBold", cx, cy + (self.PageCount > 1 and 32 or 0), Color(255, 150, 150), 1, 1)
    end

    -- Follow toggle
    self.ToggleBtn.hover = Lerp(FrameTime() * 10, self.ToggleBtn.hover, isOverToggle and 1 or 0)
    draw.RoundedBox(8, btnX, btnY, btnW, btnH, Color(15, 15, 15, 220))
    if self.ToggleBtn.hover > 0.01 then
        draw.RoundedBox(8, btnX, btnY, btnW, btnH, Color(50, 150, 255, 100 * self.ToggleBtn.hover))
    end
    surface.SetDrawColor(255, 255, 255, 20 + (self.ToggleBtn.hover * 50))
    surface.DrawOutlinedRect(btnX, btnY, btnW, btnH, 1)
    local modeName = MMDVMDNPC.CameraTrackMode and "FOLLOW: ON" or "FOLLOW: OFF"
    local modeCol = MMDVMDNPC.CameraTrackMode and Color(100, 255, 100) or Color(255, 100, 100)
    draw.SimpleText(modeName, "DermaDefaultBold", btnX + btnW / 2, btnY + btnH / 2, modeCol, 1, 1)

    -- Camera-animation auto-enter toggle
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
    draw.SimpleText(camName, "DermaDefaultBold", camX + camW / 2, btnY + camH / 2, camCol, 1, 1)

    -- Force-follow-character toggle (experimental; details in the spawn menu)
    self.CenterBtn.hover = Lerp(FrameTime() * 10, self.CenterBtn.hover, isOverCenter and 1 or 0)
    draw.RoundedBox(8, cenX, btnY, cenW, cenH, Color(15, 15, 15, 220))
    if self.CenterBtn.hover > 0.01 then
        draw.RoundedBox(8, cenX, btnY, cenW, cenH, Color(50, 150, 255, 100 * self.CenterBtn.hover))
    end
    surface.SetDrawColor(255, 255, 255, 20 + (self.CenterBtn.hover * 50))
    surface.DrawOutlinedRect(cenX, btnY, cenW, cenH, 1)
    local cenOn = camera_follow_on()
    local cenName = cenOn and "CENTER: ON" or "CENTER: OFF"
    local cenCol = cenOn and Color(100, 255, 100) or Color(255, 100, 100)
    draw.SimpleText(cenName, "DermaDefaultBold", cenX + cenW / 2, btnY + cenH / 2, cenCol, 1, 1)
end

function PANEL:OnMouseWheeled(delta)
    if self.PageCount <= 1 then return true end
    -- Scroll up = previous page, down = next; wraps around.
    self.Page = (self.Page - (delta > 0 and 1 or -1)) % self.PageCount
    self:RebuildPageNames()
    surface.PlaySound("common/wpn_moveselect.wav")
    return true
end

function PANEL:OnMousePressed(mouseCode)
    if mouseCode == MOUSE_LEFT then
        if self.IsOverToggle then
            self:ToggleCameraMode()
        elseif self.IsOverCamera then
            self:ToggleCameraAuto()
        elseif self.IsOverCenter then
            self:ToggleCameraFollow()
        elseif self.SelectedSlot > 0 then
            self:ExecuteSelection(self.SelectedSlot)
        end
    elseif mouseCode == MOUSE_RIGHT and self.SelectedSlot > 1 then
        -- Right-click removes the hovered dance from the FAVORITES view (the
        -- only in-game way to drop a favorite whose motion JSON was deleted by
        -- hand). Category views auto-populate, so there is nothing to remove.
        if (self.CategoryFilter or "") ~= FAVORITES_FILTER then return end
        local kind, id = self:SlotAction(self.SelectedSlot)
        if kind == "motion" and id and MMDVMDNPC.ToggleFavorite then
            MMDVMDNPC.ToggleFavorite(id)
            surface.PlaySound("buttons/button15.wav")
            notification.AddLegacy(
                string.format(WL("mmd_vmd_npc.radial.removed_fmt", "Removed from wheel: %s"),
                    MMDVMDNPC.GetNiceName and MMDVMDNPC.GetNiceName(id) or id),
                NOTIFY_CLEANUP or 1, 3)
            -- Slots reflow after the removal, so a key-release right after
            -- would execute whatever dance slid under the cursor; the release
            -- handler treats a very recent removal as "just close".
            self.LastRemovalTime = RealTime()
            self:RebuildMotions()
        end
    end
end

function PANEL:ToggleCameraAuto()
    local turnOn = not camera_auto_on()
    RunConsoleCommand("mmd_vmd_npc_camera_auto", turnOn and "1" or "0")
    notification.AddLegacy(WL("mmd_vmd_npc.camera.auto_option", "Enter camera animation automatically")
        .. ": " .. (turnOn and "ON" or "OFF"), NOTIFY_HINT, 3)
    surface.PlaySound("buttons/lightswitch2.wav")
end

function PANEL:ToggleCameraFollow()
    local turnOn = not camera_follow_on()
    RunConsoleCommand("mmd_vmd_npc_cam_follow", turnOn and "1" or "0")
    notification.AddLegacy(WL("mmd_vmd_npc.camera.follow", "Force camera to follow character (experimental)")
        .. ": " .. (turnOn and "ON" or "OFF"), NOTIFY_HINT, 3)
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

function PANEL:ExecuteSelection(slot)
    -- Guard against a double fire: a mouse click executes and starts the close
    -- fade, then the key-up (-mmd_wheel) would execute the same slot again.
    -- CloseMenu (called below) sets self.Closed, so this entry guard blocks the
    -- second call. Do NOT set self.Closed here or CloseMenu becomes a no-op and
    -- the wheel never disappears.
    if self.Closed then return end
    local kind, id = self:SlotAction(slot)

    if kind == "stop" then
        MMDVMDNPC.RequestStopSelectedMotion()
    elseif kind == "motion" and MMDVMDNPC.RequestPlaySelfAuto then
        -- Play the chosen motion on the player, auto-building first if the
        -- playermodel has no cache for it yet.
        MMDVMDNPC.RequestPlaySelfAuto(id)
    end
    -- Empty slot: just close.

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

concommand.Add("+mmd_wheel", function()
    -- Always openable: the Stop button and the 9 fixed slots are useful even
    -- with no motions on the wheel yet.
    if IsValid(radialMenuInstance) then radialMenuInstance:Remove() end
    radialMenuInstance = vgui.Create("MMD_RadialMenu")
end)

concommand.Add("-mmd_wheel", function()
    if IsValid(radialMenuInstance) and not radialMenuInstance.Closed then
        local recentRemoval = radialMenuInstance.LastRemovalTime
            and (RealTime() - radialMenuInstance.LastRemovalTime) < 0.6
        if radialMenuInstance.SelectedSlot and radialMenuInstance.SelectedSlot > 0 and not recentRemoval then
            radialMenuInstance:ExecuteSelection(radialMenuInstance.SelectedSlot)
        else
            radialMenuInstance:CloseMenu()
        end
    end
end)

-- Keep the wheel on its default key K: whenever the wheel is UNBOUND at
-- session start and K is free, (re)claim it — the wheel should always have a
-- working default. An existing +mmd_wheel bind (any key) is always respected,
-- and an occupied K is never clobbered. The once-marker only limits the
-- "please bind manually" hint, not the binding itself.
CreateClientConVar("mmd_vmd_npc_wheel_bound_once", "0", true, false)

hook.Add("InitPostEntity", "MMDVMDNPCWheelDefaultBind", function()
    -- Already bound somewhere: respect it.
    if input.LookupBinding and input.LookupBinding("+mmd_wheel") then return end

    -- Only claim K if it is actually free; never clobber an existing key bind
    -- (e.g. the default flashlight on K).
    local kBind = input.LookupKeyBinding and input.LookupKeyBinding(KEY_K)
    if kBind and kBind ~= "" then
        local marker = GetConVar("mmd_vmd_npc_wheel_bound_once")
        if marker and marker:GetBool() then return end
        RunConsoleCommand("mmd_vmd_npc_wheel_bound_once", "1")
        timer.Simple(2, function()
            notification.AddLegacy(WL("mmd_vmd_npc.radial.bind_hint", "Bind the MMD motion wheel with: bind <key> +mmd_wheel"), NOTIFY_GENERIC, 8)
        end)
        return
    end

    RunConsoleCommand("bind", "k", "+mmd_wheel")
    RunConsoleCommand("mmd_vmd_npc_wheel_bound_once", "1")
    timer.Simple(2, function()
        notification.AddLegacy(WL("mmd_vmd_npc.radial.default_bind", "MMD motion wheel bound to K. Rebind with: bind <key> +mmd_wheel"), NOTIFY_GENERIC, 8)
    end)
end)