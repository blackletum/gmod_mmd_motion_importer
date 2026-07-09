MMDVMDNPC = MMDVMDNPC or {}
if not MMDVMDNPC.L then include("mmd_vmd_npc/sh_core.lua") end

local function L(key, fallback)
    return MMDVMDNPC.L and MMDVMDNPC.L(key, fallback) or (fallback or key)
end

local function LF(key, ...)
    return MMDVMDNPC.LFormat and MMDVMDNPC.LFormat(key, ...) or string.format(L(key, key), ...)
end

local function motion_display_name(metaOrID)
    if istable(metaOrID) then
        local display = tostring(metaOrID.displayName or "")
        if display ~= "" then return display end
        return tostring(metaOrID.id or "")
    end

    local id = tostring(metaOrID or "")
    local meta = MMDVMDNPC.MotionDetails and MMDVMDNPC.MotionDetails[id] or nil
    local display = meta and tostring(meta.displayName or "") or ""
    return display ~= "" and display or id
end

TOOL.Category = L("mmd_vmd_npc.category", "Animation")
TOOL.Name = "#tool.mmd_vmd_npc.name"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.Information = {
    { name = "left" },
    { name = "left_use", icon2 = "gui/e.png" },
    { name = "left_speed", icon2 = "mmd_vmd_npc/shift.png" },
    { name = "left_alt", icon2 = "mmd_vmd_npc/alt.png" },
    { name = "reload_alt", icon2 = "mmd_vmd_npc/alt.png" },
    { name = "right" },
    { name = "right_speed", icon2 = "mmd_vmd_npc/shift.png" },
    { name = "reload" },
    { name = "reload_speed", icon2 = "mmd_vmd_npc/shift.png" },
    { name = "reload_use", icon2 = "gui/e.png" },
}

local function client_alt_down()
    if not CLIENT or not input or not input.IsKeyDown then return false end
    return (KEY_LALT ~= nil and input.IsKeyDown(KEY_LALT))
        or (KEY_RALT ~= nil and input.IsKeyDown(KEY_RALT))
end

local function bind_is_primary_attack(bind)
    bind = string.lower(tostring(bind or ""))
    return bind == "+attack" or bind == "attack"
end

local function request_stop_npc_playbacks()
    if not CLIENT then return end
    net.Start("mmdvmd_stop_npc_playbacks_request")
    net.SendToServer()
end

local function request_align_assigned_actors()
    if not CLIENT then return end
    net.Start("mmdvmd_assignment_align_request")
    net.SendToServer()
end

local function local_player_has_mmd_vmd_tool()
    if not CLIENT then return false end
    local ply = LocalPlayer()
    if not IsValid(ply) then return false end

    local weapon = ply:GetActiveWeapon()
    if not IsValid(weapon) or weapon:GetClass() ~= "gmod_tool" then return false end

    if weapon.GetMode then
        return weapon:GetMode() == "mmd_vmd_npc"
    end
    return tostring(weapon.Mode or "") == "mmd_vmd_npc"
end

if CLIENT then
    hook.Add("PlayerBindPress", "MMDVMDNPCToolModifierBinds", function(ply, bind, pressed)
        if ply ~= LocalPlayer() or not pressed then return end
        bind = string.lower(tostring(bind or ""))
        if bind_is_primary_attack(bind) and client_alt_down() and local_player_has_mmd_vmd_tool() then
            request_align_assigned_actors()
            return true
        end

        if not string.find(bind, "reload", 1, true) then return end
        if not client_alt_down() or not local_player_has_mmd_vmd_tool() then return end

        request_stop_npc_playbacks()
        return true
    end)
end

TOOL.ClientConVar = {
    motion = "",
    show_halos = "1",
    disable_armtwist = "0",
    disable_handtwist = "0",
    disable_eyes = "0",
    disable_spine_pelvis_correction = "0",
    start_delay = "2",
    pelvis_z_offset = "-2.5",
    thirdperson_distance = "120",
    thirdperson_height = "24",
    eye_track = "1",
    eye_track_smooth = "20",
    eye_track_moveback = "0.10",
    eye_track_pos_ud = "0.5",
    eye_track_pos_lr = "0.5",
    music_enabled = "1",
    music_volume = "1",
    music_omni = "1",
    music_range = "1500",
    music_fade = "300",
    loop_playback = "0",
    camera_auto = "1",
    fast_build = "1",
    build_frames_per_batch = "32",
    playback_hz = "120",
}

if CLIENT then
    MMDVMDNPC.RegisterI18N()
end

local function selected_motion(tool)
    return tool:GetClientInfo("motion")
end

local function selected_tool_options(tool)
    return MMDVMDNPC.ToolOptions and MMDVMDNPC.ToolOptions(tool) or nil
end

local function selected_playback_settings(tool)
    return MMDVMDNPC.ToolPlaybackSettings and MMDVMDNPC.ToolPlaybackSettings(tool) or nil
end

local function notify_blocked(ply, message, ent)
    if MMDVMDNPC.NotifyBlocked then
        MMDVMDNPC.NotifyBlocked(ply, message, ent)
    else
        MMDVMDNPC.Chat(ply, message)
    end
end

local function assign_target(tool, trace)
    local owner = tool:GetOwner()
    local ent = trace and trace.Entity or nil
    if not IsValid(ent) or not (ent.IsNPC and ent:IsNPC()) then
        notify_blocked(owner, L("mmd_vmd_npc.error.left_click_valid_npc"))
        return false
    end

    local motionID = selected_motion(tool)
    if motionID == "" then
        notify_blocked(owner, L("mmd_vmd_npc.error.select_motion"), ent)
        return false
    end
    local options = selected_tool_options(tool)
    local playbackSettings = selected_playback_settings(tool)
    local ok, err = MMDVMDNPC.AssignActorForPlayer(owner, ent, motionID, options, playbackSettings)
    if not ok and err then
        notify_blocked(owner, err, ent)
    end
    return ok
end

local function open_selected_motion(tool, trace)
    local owner = tool:GetOwner()
    local ent = trace and trace.Entity or nil
    if not IsValid(ent) or not ((ent.IsNPC and ent:IsNPC()) or (ent.IsPlayer and ent:IsPlayer())) then
        ent = MMDVMDNPC.DebugTargets and MMDVMDNPC.DebugTargets[owner] or nil
    end

    if not IsValid(ent) or not ((ent.IsNPC and ent:IsNPC()) or (ent.IsPlayer and ent:IsPlayer())) then
        notify_blocked(owner, L("mmd_vmd_npc.error.shift_right_click_valid_actor"))
        return false
    end

    local motionID = selected_motion(tool)
    local ok, err = MMDVMDNPC.OpenDebugForPlayer(owner, ent, motionID, -1)
    if not ok and err then
        notify_blocked(owner, err, ent)
    end
    return ok
end

local function align_selected_actors(owner, ent)
    if MMDVMDNPC.AlignAssignedActorsToFirstForPlayer then
        local ok, err = MMDVMDNPC.AlignAssignedActorsToFirstForPlayer(owner)
        if not ok and err then notify_blocked(owner, err, ent) end
        return ok == true
    end
    return false
end

function TOOL:LeftClick(trace)
    if CLIENT then return true end
    local owner = self:GetOwner()
    if IsValid(owner) and owner:KeyDown(IN_SPEED) then
        if MMDVMDNPC.BeginBuildForAssignedActorsForPlayer then
            local ok, err = MMDVMDNPC.BeginBuildForAssignedActorsForPlayer(owner, selected_playback_settings(self))
            if not ok and err then notify_blocked(owner, err, trace and trace.Entity or nil) end
            return ok == true
        end
        return false
    end
    if IsValid(owner) and owner:KeyDown(IN_USE) then
        if MMDVMDNPC.StartAssignedGroupPlaybackForPlayer then
            local ok, err = MMDVMDNPC.StartAssignedGroupPlaybackForPlayer(owner, selected_playback_settings(self))
            if not ok and err then notify_blocked(owner, err, trace and trace.Entity or nil) end
            return ok == true
        end
        return false
    end
    return assign_target(self, trace)
end

function TOOL:RightClick(trace)
    if CLIENT then return true end
    local owner = self:GetOwner()
    if not IsValid(owner) then return false end
    if owner:KeyDown(IN_SPEED) then
        return open_selected_motion(self, trace)
    end
    if MMDVMDNPC.HasAssignedActorsForPlayer and MMDVMDNPC.HasAssignedActorsForPlayer(owner) and MMDVMDNPC.ToggleAssignedPlaybackPauseForPlayer then
        local ok, err = MMDVMDNPC.ToggleAssignedPlaybackPauseForPlayer(owner)
        if ok then return true end
        if err and err ~= "no active selected playback to pause" then
            notify_blocked(owner, err, trace and trace.Entity or nil)
            return false
        end
    end
    if MMDVMDNPC.TogglePlaybackPauseForPlayer then
        local ok, err = MMDVMDNPC.TogglePlaybackPauseForPlayer(owner, trace and trace.Entity or nil)
        if not ok and err then notify_blocked(owner, err, trace and trace.Entity or nil) end
        return ok == true
    end
    return false
end

function TOOL:Reload()
    if CLIENT then
        if client_alt_down() then
            request_stop_npc_playbacks()
        end
        return true
    end
    local owner = self:GetOwner()
    if not IsValid(owner) then return false end

    local ok, err = MMDVMDNPC.SelectTargetForPlayer(owner, owner)
    if not ok and err then
        notify_blocked(owner, err, owner)
        return false
    end

    local motionID = selected_motion(self)
    if motionID == "" then
        notify_blocked(owner, L("mmd_vmd_npc.error.select_motion"), owner)
        return true
    end

    local options = selected_tool_options(self)
    local playbackSettings = selected_playback_settings(self)

    if owner:KeyDown(IN_SPEED) then
        if MMDVMDNPC.BeginBuildForPlayer then
            local ok, err = MMDVMDNPC.BeginBuildForPlayer(owner, motionID, options, playbackSettings)
            if not ok and err then notify_blocked(owner, err, owner) end
            return ok == true
        end
        return false
    end

    if owner:KeyDown(IN_USE) then
        local hasBuilt = MMDVMDNPC.HasBuiltAnimationForPlayer and MMDVMDNPC.HasBuiltAnimationForPlayer(owner, motionID, options)
        if not hasBuilt then
            if MMDVMDNPC.ReportBuiltStatusForPlayer then
                MMDVMDNPC.ReportBuiltStatusForPlayer(owner, motionID, options)
            else
                notify_blocked(owner, L("mmd_vmd_npc.error.build_self_first"), owner)
            end
            return true
        end

        if MMDVMDNPC.IsSelfPlaybackRunningForPlayer and MMDVMDNPC.IsSelfPlaybackRunningForPlayer(owner) then
            MMDVMDNPC.StopSelfPlaybackForPlayer(owner, true)
        elseif MMDVMDNPC.StartPlaybackForPlayer then
            MMDVMDNPC.StartPlaybackForPlayer(owner, motionID, options, playbackSettings)
        end
        return true
    end

    if MMDVMDNPC.ReportBuiltStatusForPlayer then
        MMDVMDNPC.ReportBuiltStatusForPlayer(owner, motionID, options)
    end
    return true
end

function TOOL.BuildCPanel(panel)
    panel:ClearControls()
    panel:Help(L("mmd_vmd_npc.ui.tool_help"))

    -- Camera and RTX-Remix lighting settings live in their own sub-tabs below.

    local screenW = ScrW and ScrW() or 1280
    local screenH = ScrH and ScrH() or 720
    local compactPanel = screenW <= 1366 or screenH <= 760
    local textLimit = compactPanel and 38 or 64
    local pathLimit = compactPanel and 42 or 78

    local function shorten_text(value, limit)
        local text = tostring(value or "")
        limit = math.max(12, tonumber(limit) or textLimit)
        if #text <= limit then return text end

        local head = math.max(4, math.floor((limit - 3) * 0.58))
        local tail = math.max(4, limit - 3 - head)
        return string.sub(text, 1, head) .. "..." .. string.sub(text, -tail)
    end

    local function bounded_label(label, font, color, height)
        label:SetFont(font or "DermaDefault")
        if color then label:SetTextColor(color) end
        label:SetWrap(true)
        label:SetAutoStretchVertical(false)
        label:SetTall(height or (compactPanel and 42 or 52))
        return label
    end

    local container = vgui.Create("DPanel", panel)
    container:SetTall(compactPanel and math.max(screenH * 1.05, 700) or math.max(screenH * 1.15, 820))
    container.Paint = nil
    panel:AddItem(container)

    local sheet = vgui.Create("DPropertySheet", container)
    sheet:Dock(FILL)

    local function create_subtab(title, icon)
        local tab = vgui.Create("ControlPanel", sheet)
        tab:Dock(FILL)
        sheet:AddSheet(title, tab, icon or "icon16/wrench.png")
        return tab
    end

    local function add_slider(parent, label, cvar, minv, maxv, decimals)
        return parent:NumSlider(label, cvar, minv, maxv, decimals or 2)
    end

    local function add_checkbox_with_help(parent, label, cvar, helpText)
        local checkbox = parent:CheckBox(label, cvar)
        if helpText and helpText ~= "" then parent:Help(helpText) end
        return checkbox
    end

    local function section(parent, title, color)
        local header = vgui.Create("DLabel")
        header:SetText(title)
        header:SetFont("DermaDefaultBold")
        header:SetTextColor(color or Color(80, 170, 255))
        header:DockMargin(0, 8, 0, 2)
        parent:AddItem(header)
        return header
    end

    local function colored_button(parent, text, color, callback)
        local button = vgui.Create("DButton")
        button:SetText(text)
        button:SetTall(30)
        button.DoClick = callback
        button.Paint = function(self, w, h)
            local c = color or Color(70, 120, 190)
            if self:IsHovered() then
                c = Color(math.min(c.r + 25, 255), math.min(c.g + 25, 255), math.min(c.b + 25, 255), 255)
            end
            draw.RoundedBox(5, 0, 0, w, h, c)
            draw.SimpleText(self:GetText(), "DermaDefaultBold", w * 0.5, h * 0.5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            return true
        end
        parent:AddItem(button)
        return button
    end

    local function key_binder(parent, labelText, cvarName, color)
        local row = vgui.Create("DPanel")
        row:SetTall(30)
        row.Paint = nil
        local label = vgui.Create("DLabel", row)
        label:Dock(FILL)
        label:SetText(labelText)
        label:SetTextColor(color or Color(255, 200, 90))
        label:SetFont("DermaDefaultBold")
        local binder = vgui.Create("DBinder", row)
        binder:Dock(RIGHT)
        binder:SetWide(130)
        local cvar = GetConVar(cvarName)
        binder:SetValue(cvar and cvar:GetInt() or 0)
        binder.OnChange = function(_, num)
            RunConsoleCommand(cvarName, tostring(math.max(0, math.floor(tonumber(num) or 0))))
        end
        parent:AddItem(row)
        return binder
    end

    local motionTab = create_subtab(L("mmd_vmd_npc.ui.tab.motion"), "icon16/film.png")
    local playbackTab = create_subtab(L("mmd_vmd_npc.ui.tab.build_playback"), "icon16/control_play_blue.png")
    local cameraTab = create_subtab(L("mmd_vmd_npc.ui.tab.camera"), "icon16/camera.png")
    local lightingTab = create_subtab(L("mmd_vmd_npc.ui.tab.lighting"), "icon16/lightbulb.png")
    local performanceTab = create_subtab(L("mmd_vmd_npc.ui.tab.performance"), "icon16/lightning.png")
    local advancedTab = create_subtab(L("mmd_vmd_npc.ui.tab.advanced"), "icon16/wrench.png")

    section(motionTab, L("mmd_vmd_npc.ui.tab.motion"), Color(80, 170, 255))
    colored_button(motionTab, L("mmd_vmd_npc.ui.force_reset_self_view"), Color(220, 95, 55), function()
        if MMDVMDNPC and MMDVMDNPC.RequestForceSelfPlaybackReset then
            MMDVMDNPC.RequestForceSelfPlaybackReset()
        end
    end)

    local hookID = "MMDVMDNPCToolPanel_" .. tostring(panel)
    local audioOffsetSuppress = false
    local selectedMotionLabel = vgui.Create("DLabel")
    selectedMotionLabel:SetText(L("mmd_vmd_npc.ui.selected_motion_none"))
    bounded_label(
        selectedMotionLabel,
        compactPanel and "DermaDefaultBold" or "DermaLarge",
        Color(105, 205, 255),
        compactPanel and 34 or 54
    )
    motionTab:AddItem(selectedMotionLabel)

    local pauseWarningLabel = vgui.Create("DLabel")
    pauseWarningLabel:SetText("")
    pauseWarningLabel:SetFont("DermaDefaultBold")
    pauseWarningLabel:SetTextColor(Color(255, 80, 80))
    pauseWarningLabel:SetWrap(true)
    pauseWarningLabel:SetAutoStretchVertical(true)
    pauseWarningLabel:SetVisible(false)
    motionTab:AddItem(pauseWarningLabel)

    local function convar_number(name)
        local cvar = GetConVar(name)
        if not cvar then return 0 end
        return tonumber(cvar:GetString()) or 0
    end

    local function update_pause_warning()
        if not IsValid(pauseWarningLabel) then return end
        local pauseStatus = MMDVMDNPC.PauseStatus or {}
        local svPause = tonumber(pauseStatus.svPause) or convar_number("sv_pause")
        local svPauseSP = tonumber(pauseStatus.svPauseSP) or convar_number("sv_pause_sp")
        local paused = svPause ~= 0 or svPauseSP ~= 0
        pauseWarningLabel:SetVisible(paused)
        pauseWarningLabel:SetText(paused and LF("mmd_vmd_npc.ui.pause_warning_fmt", tostring(svPause), tostring(svPauseSP)) or "")
    end

    local function request_pause_status()
        if MMDVMDNPC and MMDVMDNPC.RequestPauseStatus then
            MMDVMDNPC.RequestPauseStatus()
        end
        update_pause_warning()
    end

    timer.Create(hookID .. "_PauseWarning", 0.5, 0, request_pause_status)

    local audioOffsetSlider = vgui.Create("DNumSlider")
    audioOffsetSlider:SetText(L("mmd_vmd_npc.ui.music_offset"))
    audioOffsetSlider:SetMin(-5)
    audioOffsetSlider:SetMax(5)
    audioOffsetSlider:SetDecimals(2)
    audioOffsetSlider:SetValue(0)
    audioOffsetSlider:SetTall(42)
    motionTab:AddItem(audioOffsetSlider)

    add_checkbox_with_help(motionTab, L("mmd_vmd_npc.ui.play_imported_music"), "mmd_vmd_npc_music_enabled", L("mmd_vmd_npc.ui.play_imported_music_help"))
    add_slider(motionTab, L("mmd_vmd_npc.ui.music_volume"), "mmd_vmd_npc_music_volume", 0, 2, 2)
    add_checkbox_with_help(motionTab, L("mmd_vmd_npc.ui.music_omni"), "mmd_vmd_npc_music_omni", L("mmd_vmd_npc.ui.music_omni_help"))
    add_slider(motionTab, L("mmd_vmd_npc.ui.music_range"), "mmd_vmd_npc_music_range", 100, 5000, 0)
    add_slider(motionTab, L("mmd_vmd_npc.ui.music_fade"), "mmd_vmd_npc_music_fade", 10, 2000, 0)
    motionTab:Help(L("mmd_vmd_npc.ui.music_range_help"))
    add_checkbox_with_help(motionTab, L("mmd_vmd_npc.ui.loop_playback"), "mmd_vmd_npc_loop_playback", L("mmd_vmd_npc.ui.loop_playback_help"))

    local motionList = vgui.Create("DListView")
    motionList:SetTall(145)
    motionList:SetMultiSelect(false)
    motionList:AddColumn(L("mmd_vmd_npc.ui.column.motion"))
    motionList:AddColumn(L("mmd_vmd_npc.ui.column.duration"))
    motionList:AddColumn(L("mmd_vmd_npc.ui.column.addon"))
    motionTab:AddItem(motionList)
    local targetLabel = vgui.Create("DLabel")
    local assignmentLabel = vgui.Create("DLabel")
    local buildLabel = vgui.Create("DLabel")
    local buildProgress = vgui.Create("DProgress")
    local playLabel = vgui.Create("DLabel")
    local motionInfo = vgui.Create("DLabel")
    local eyeStatusLabel = vgui.Create("DLabel")
    local update_motion_details
    local update_eye_status

    local function duration_text(meta)
        if not meta then return L("mmd_vmd_npc.ui.loading") end
        return string.format("%.2fs", tonumber(meta.duration) or 0)
    end

    local function refresh_motion_list(motions)
        if not IsValid(motionList) then return end
        motionList:Clear()
        local current = GetConVar("mmd_vmd_npc_motion")
        local selected = current and current:GetString() or ""
        local selectedLine = nil
        local seen = {}
        local detailsOrdered = MMDVMDNPC.MotionDetailsOrdered or {}
        local detailsByID = MMDVMDNPC.MotionDetails or {}

        if #detailsOrdered > 0 then
            for _, meta in ipairs(detailsOrdered) do
                local id = tostring(meta.id or "")
                if id ~= "" then
                    seen[id] = true
                    local line = motionList:AddLine(motion_display_name(meta), duration_text(meta), meta.isAddon and L("mmd_vmd_npc.ui.yes") or L("mmd_vmd_npc.ui.no"))
                    line.MotionID = id
                    line.Meta = meta
                    if id == selected then
                        selectedLine = line
                    end
                end
            end
        else
            for _, id in ipairs(motions or MMDVMDNPC.ClientMotions or {}) do
                id = tostring(id or "")
                if id ~= "" then
                    seen[id] = true
                    local meta = detailsByID[id]
                    local line = motionList:AddLine(motion_display_name(meta or id), duration_text(meta), meta and meta.isAddon and L("mmd_vmd_npc.ui.yes") or L("mmd_vmd_npc.ui.no"))
                    line.MotionID = id
                    line.Meta = meta
                    if id == selected then
                        selectedLine = line
                    end
                end
            end
        end

        if selected ~= "" and not seen[selected] then
            selectedLine = motionList:AddLine(selected, L("mmd_vmd_npc.ui.missing"), L("mmd_vmd_npc.ui.no"))
            selectedLine.MotionID = selected
        end

        if selectedLine then
            if motionList.SelectItem then
                motionList:SelectItem(selectedLine)
            elseif selectedLine.SetSelected then
                selectedLine:SetSelected(true)
            end
        end
    end

    motionList.OnRowSelected = function(_, _, line)
        if not line or not line.MotionID then return end
        RunConsoleCommand("mmd_vmd_npc_motion", line.MotionID)
        if MMDVMDNPC and MMDVMDNPC.RequestAudioSettings then
            MMDVMDNPC.RequestAudioSettings(line.MotionID)
        end
        if update_motion_details then
            timer.Simple(0, function()
                if IsValid(motionInfo) then
                    update_motion_details()
                end
            end)
        end
    end

    audioOffsetSlider.OnValueChanged = function(_, value)
        if audioOffsetSuppress then return end
        local current = GetConVar("mmd_vmd_npc_motion")
        local motionID = current and current:GetString() or ""
        if motionID == "" then return end
        local timerName = hookID .. "_AudioOffsetSave"
        timer.Create(timerName, 0.25, 1, function()
            if MMDVMDNPC and MMDVMDNPC.SaveAudioOffset then
                MMDVMDNPC.SaveAudioOffset(motionID, math.Clamp(tonumber(value) or 0, -5, 5))
            end
        end)
    end

    refresh_motion_list()
    hook.Add("MMDVMDNPCMotionListUpdated", hookID, refresh_motion_list)

    colored_button(motionTab, L("mmd_vmd_npc.ui.open_motion_manager"), Color(60, 130, 210), function()
        RunConsoleCommand("mmdvmd_menu")
    end)
    colored_button(motionTab, L("mmd_vmd_npc.ui.refresh_motion_list"), Color(80, 110, 150), function()
        RunConsoleCommand("mmdvmd_list")
        if MMDVMDNPC and MMDVMDNPC.RequestMotionDetails then
            MMDVMDNPC.RequestMotionDetails()
        end
    end)
    colored_button(motionTab, L("mmd_vmd_npc.ui.stop_stuck_build_tasks"), Color(185, 90, 45), function()
        if MMDVMDNPC and MMDVMDNPC.RequestCancelBuildTasks then
            MMDVMDNPC.RequestCancelBuildTasks()
        end
    end)

    section(motionTab, L("mmd_vmd_npc.ui.radial_wheel"), Color(255, 200, 90))
    motionTab:Help(L("mmd_vmd_npc.ui.radial_wheel_help"))

    motionInfo:SetText(L("mmd_vmd_npc.ui.motion_no_metadata"))
    bounded_label(motionInfo, "DermaDefault", Color(210, 220, 230), compactPanel and 40 or 52)
    motionTab:AddItem(motionInfo)

    section(motionTab, L("mmd_vmd_npc.ui.target"), Color(80, 220, 140))
    targetLabel:SetText(L("mmd_vmd_npc.ui.selected_actor_none"))
    bounded_label(
        targetLabel,
        compactPanel and "DermaDefaultBold" or "DermaLarge",
        Color(100, 235, 150),
        compactPanel and 48 or 64
    )
    motionTab:AddItem(targetLabel)

    assignmentLabel:SetText(L("mmd_vmd_npc.ui.coordinated_npcs_zero"))
    bounded_label(assignmentLabel, "DermaDefaultBold", Color(120, 205, 255), compactPanel and 34 or 44)
    motionTab:AddItem(assignmentLabel)

    colored_button(motionTab, L("mmd_vmd_npc.ui.play_selected_group"), Color(80, 155, 230), function()
        if MMDVMDNPC and MMDVMDNPC.RequestPlayAssignedGroup then
            MMDVMDNPC.RequestPlayAssignedGroup()
        end
    end)

    colored_button(motionTab, L("mmd_vmd_npc.ui.stop_animation"), Color(190, 70, 70), function()
        if MMDVMDNPC and MMDVMDNPC.RequestStopSelectedMotion then
            MMDVMDNPC.RequestStopSelectedMotion()
        end
    end)

    colored_button(motionTab, L("mmd_vmd_npc.ui.clear_selection"), Color(150, 95, 95), function()
        if MMDVMDNPC and MMDVMDNPC.RequestClearAssignedActors then
            MMDVMDNPC.RequestClearAssignedActors("all")
        end
    end)

    colored_button(motionTab, L("mmd_vmd_npc.ui.clear_missing_invalid"), Color(165, 125, 70), function()
        if MMDVMDNPC and MMDVMDNPC.RequestClearAssignedActors then
            MMDVMDNPC.RequestClearAssignedActors("missing")
        end
    end)

    colored_button(motionTab, L("mmd_vmd_npc.ui.select_yourself"), Color(70, 150, 90), function()
        if MMDVMDNPC and MMDVMDNPC.RequestSelectSelf then
            MMDVMDNPC.RequestSelectSelf()
        else
            print("[MMD VMD] " .. L("mmd_vmd_npc.hint.self_keys"))
        end
    end)
    motionTab:Help(L("mmd_vmd_npc.ui.self_help"))

    section(playbackTab, L("mmd_vmd_npc.ui.build"), Color(255, 190, 80))
    buildLabel:SetText(L("mmd_vmd_npc.ui.build_idle"))
    buildLabel:SetWrap(true)
    buildLabel:SetAutoStretchVertical(true)
    playbackTab:AddItem(buildLabel)

    buildProgress:SetFraction(0)
    playbackTab:AddItem(buildProgress)

    colored_button(playbackTab, L("mmd_vmd_npc.ui.build_selected_motion"), Color(210, 145, 45), function()
        if MMDVMDNPC and MMDVMDNPC.RequestBuildSelectedMotion then
            MMDVMDNPC.RequestBuildSelectedMotion()
        end
    end)

    colored_button(playbackTab, L("mmd_vmd_npc.ui.stop_build_tasks"), Color(185, 90, 45), function()
        if MMDVMDNPC and MMDVMDNPC.RequestCancelBuildTasks then
            MMDVMDNPC.RequestCancelBuildTasks()
        end
    end)

    section(playbackTab, L("mmd_vmd_npc.ui.playback"), Color(100, 190, 255))
    playLabel:SetText(L("mmd_vmd_npc.ui.playback_idle"))
    playLabel:SetWrap(true)
    playLabel:SetAutoStretchVertical(true)
    playbackTab:AddItem(playLabel)

    colored_button(playbackTab, L("mmd_vmd_npc.ui.play_built_animation"), Color(70, 165, 220), function()
        if MMDVMDNPC and MMDVMDNPC.RequestPlaySelectedMotion then
            MMDVMDNPC.RequestPlaySelectedMotion()
        end
    end)

    colored_button(playbackTab, L("mmd_vmd_npc.ui.stop_animation"), Color(190, 70, 70), function()
        if MMDVMDNPC and MMDVMDNPC.RequestStopSelectedMotion then
            MMDVMDNPC.RequestStopSelectedMotion()
        end
    end)

    add_slider(playbackTab, L("mmd_vmd_npc.ui.start_delay"), "mmd_vmd_npc_start_delay", 2, 20, 1)
    add_slider(playbackTab, L("mmd_vmd_npc.ui.pelvis_z_offset"), "mmd_vmd_npc_pelvis_z_offset", -16, 16, 1)
    add_slider(playbackTab, L("mmd_vmd_npc.ui.thirdperson_distance"), "mmd_vmd_npc_thirdperson_distance", 40, 260, 0)
    add_slider(playbackTab, L("mmd_vmd_npc.ui.thirdperson_height"), "mmd_vmd_npc_thirdperson_height", -20, 90, 0)

    section(motionTab, L("mmd_vmd_npc.ui.eye_tracking"), Color(120, 210, 255))
    add_checkbox_with_help(motionTab, L("mmd_vmd_npc.ui.enable_eye_tracking"), "mmd_vmd_npc_eye_track", L("mmd_vmd_npc.ui.enable_eye_tracking_help"))
    add_slider(motionTab, L("mmd_vmd_npc.ui.eye_smoothing"), "mmd_vmd_npc_eye_track_smooth", 0.1, 30, 2)
    add_slider(motionTab, L("mmd_vmd_npc.ui.eye_moveback"), "mmd_vmd_npc_eye_track_moveback", -0.25, 1, 2)
    add_slider(motionTab, L("mmd_vmd_npc.ui.eye_pos_ud"), "mmd_vmd_npc_eye_track_pos_ud", 0, 2, 2)
    add_slider(motionTab, L("mmd_vmd_npc.ui.eye_pos_lr"), "mmd_vmd_npc_eye_track_pos_lr", 0, 2, 2)
    eyeStatusLabel:SetText(L("mmd_vmd_npc.ui.eye_no_target"))
    eyeStatusLabel:SetWrap(true)
    eyeStatusLabel:SetAutoStretchVertical(true)
    motionTab:AddItem(eyeStatusLabel)

    section(playbackTab, L("mmd_vmd_npc.ui.audio_sync"), Color(180, 130, 255))
    playbackTab:Help(L("mmd_vmd_npc.ui.audio_sync_help"))

    section(playbackTab, L("mmd_vmd_npc.ui.manage_built_cache"), Color(255, 110, 110))
    colored_button(playbackTab, L("mmd_vmd_npc.ui.clear_built_model"), Color(170, 80, 80), function()
        if MMDVMDNPC and MMDVMDNPC.RequestClearBuiltSelectedMotion then
            MMDVMDNPC.RequestClearBuiltSelectedMotion("model")
        end
    end)

    colored_button(playbackTab, L("mmd_vmd_npc.ui.clear_built_all"), Color(145, 65, 65), function()
        if MMDVMDNPC and MMDVMDNPC.RequestClearBuiltSelectedMotion then
            MMDVMDNPC.RequestClearBuiltSelectedMotion("all")
        end
    end)

    section(performanceTab, L("mmd_vmd_npc.ui.build_performance"), Color(255, 190, 80))
    performanceTab:Help(L("mmd_vmd_npc.ui.build_performance_help"))
    add_checkbox_with_help(performanceTab, L("mmd_vmd_npc.ui.fast_build"), "mmd_vmd_npc_fast_build", L("mmd_vmd_npc.ui.fast_build_help"))
    add_slider(performanceTab, L("mmd_vmd_npc.ui.build_frames_per_batch"), "mmd_vmd_npc_build_frames_per_batch", 1, 128, 0)

    section(performanceTab, L("mmd_vmd_npc.ui.playback_performance"), Color(100, 190, 255))
    performanceTab:Help(L("mmd_vmd_npc.ui.playback_performance_help"))
    -- Cap the slider at the value every consumer actually clamps to, so the UI
    -- cannot display a rate (up to 480) that is silently reduced to 240.
    add_slider(performanceTab, L("mmd_vmd_npc.ui.playback_updates_per_second"), "mmd_vmd_npc_playback_hz", MMDVMDNPC.MinPlaybackHz or 10, MMDVMDNPC.MaxPlaybackHz or 240, 0)

    section(advancedTab, L("mmd_vmd_npc.ui.tab.advanced"), Color(180, 180, 180))

    advancedTab:CheckBox("Q: Show halos", "mmd_vmd_npc_show_halos") -- ADDED

    advancedTab:CheckBox(L("mmd_vmd_npc.ui.disable_armtwist"), "mmd_vmd_npc_disable_armtwist")
    advancedTab:CheckBox(L("mmd_vmd_npc.ui.disable_handtwist"), "mmd_vmd_npc_disable_handtwist")
    advancedTab:CheckBox(L("mmd_vmd_npc.ui.disable_eyes"), "mmd_vmd_npc_disable_eyes")
    advancedTab:CheckBox(L("mmd_vmd_npc.ui.disable_spine_pelvis"), "mmd_vmd_npc_disable_spine_pelvis_correction")

    colored_button(advancedTab, L("mmd_vmd_npc.ui.debug_selected_motion"), Color(95, 95, 110), function()
        local current = GetConVar("mmd_vmd_npc_motion")
        local motionID = current and current:GetString() or ""
        if motionID ~= "" and MMDVMDNPC and MMDVMDNPC.OpenDebugMenu then
            MMDVMDNPC.OpenDebugMenu(motionID, -1)
        else
            print("[MMD VMD] " .. L("mmd_vmd_npc.error.select_motion"))
        end
    end)

    -- Camera tab -----------------------------------------------------------------
    section(cameraTab, L("mmd_vmd_npc.ui.tab.camera"), Color(120, 200, 255))
    cameraTab:Help(L("mmd_vmd_npc.camera.tab_help"))
    key_binder(cameraTab, L("mmd_vmd_npc.camera.hotkey_label"), "mmd_vmd_npc_camera_key", Color(120, 200, 255))
    cameraTab:Help(L("mmd_vmd_npc.camera.hotkey_help"))
    add_checkbox_with_help(cameraTab, L("mmd_vmd_npc.camera.auto_option"), "mmd_vmd_npc_camera_auto", L("mmd_vmd_npc.camera.auto_option_help"))
    add_checkbox_with_help(cameraTab, L("mmd_vmd_npc.camera.collision"), "mmd_vmd_npc_cam_collision", L("mmd_vmd_npc.camera.collision_help"))
    add_slider(cameraTab, L("mmd_vmd_npc.camera.max_distance"), "mmd_vmd_npc_cam_max_distance", 0, 6000, 0)

    section(cameraTab, L("mmd_vmd_npc.camera.transform"), Color(120, 200, 255))
    cameraTab:Help(L("mmd_vmd_npc.camera.transform_help"))
    add_slider(cameraTab, L("mmd_vmd_npc.camera.scale"), "mmd_vmd_npc_cam_scale", 0.1, 3, 2)
    add_slider(cameraTab, L("mmd_vmd_npc.camera.offset_x"), "mmd_vmd_npc_cam_offset_x", -128, 128, 0)
    add_slider(cameraTab, L("mmd_vmd_npc.camera.offset_y"), "mmd_vmd_npc_cam_offset_y", -128, 128, 0)
    add_slider(cameraTab, L("mmd_vmd_npc.camera.offset_z"), "mmd_vmd_npc_cam_offset_z", -128, 128, 0)
    add_slider(cameraTab, L("mmd_vmd_npc.camera.yaw"), "mmd_vmd_npc_cam_yaw", -180, 180, 0)
    add_slider(cameraTab, L("mmd_vmd_npc.camera.pitch"), "mmd_vmd_npc_cam_pitch", -90, 90, 0)
    add_slider(cameraTab, L("mmd_vmd_npc.camera.fov_offset"), "mmd_vmd_npc_cam_fov", -80, 80, 0)

    -- RTX-Remix lighting tab -----------------------------------------------------
    section(lightingTab, L("mmd_vmd_npc.ui.tab.lighting"), Color(255, 220, 120))
    lightingTab:Help(L("mmd_vmd_npc.lighting.tab_help"))
    add_checkbox_with_help(lightingTab, L("mmd_vmd_npc.lighting.enable"), "mmd_vmd_npc_flashlight_enabled", L("mmd_vmd_npc.lighting.enable_help"))
    key_binder(lightingTab, L("mmd_vmd_npc.lighting.hotkey_label"), "mmd_vmd_npc_flashlight_key", Color(255, 220, 120))
    lightingTab:Help(L("mmd_vmd_npc.lighting.hotkey_help"))
    add_checkbox_with_help(lightingTab, L("mmd_vmd_npc.lighting.follow_eye"), "mmd_vmd_npc_flashlight_follow_eye", L("mmd_vmd_npc.lighting.follow_eye_help"))
    add_checkbox_with_help(lightingTab, L("mmd_vmd_npc.lighting.shadows"), "mmd_vmd_npc_flashlight_shadows", L("mmd_vmd_npc.lighting.shadows_help"))

    section(lightingTab, L("mmd_vmd_npc.lighting.beam"), Color(255, 220, 120))
    add_slider(lightingTab, L("mmd_vmd_npc.lighting.brightness"), "mmd_vmd_npc_flashlight_brightness", 0, 100, 2)
    add_slider(lightingTab, L("mmd_vmd_npc.lighting.fov"), "mmd_vmd_npc_flashlight_fov", 5, 170, 0)
    add_slider(lightingTab, L("mmd_vmd_npc.lighting.distance"), "mmd_vmd_npc_flashlight_distance", 128, 8192, 0)
    add_slider(lightingTab, L("mmd_vmd_npc.lighting.nearz"), "mmd_vmd_npc_flashlight_nearz", 1, 64, 0)

    section(lightingTab, L("mmd_vmd_npc.lighting.rtx_shaping"), Color(255, 220, 120))
    lightingTab:Help(L("mmd_vmd_npc.lighting.rtx_shaping_help"))
    add_slider(lightingTab, L("mmd_vmd_npc.lighting.rtx_radius"), "mmd_vmd_npc_flashlight_rtx_radius", 1, 200, 0)
    add_slider(lightingTab, L("mmd_vmd_npc.lighting.rtx_softness"), "mmd_vmd_npc_flashlight_rtx_softness", 0, 1, 2)
    add_slider(lightingTab, L("mmd_vmd_npc.lighting.rtx_volumetric"), "mmd_vmd_npc_flashlight_rtx_volumetric", 0, 5, 1)

    section(lightingTab, L("mmd_vmd_npc.lighting.color"), Color(255, 220, 120))
    add_slider(lightingTab, L("mmd_vmd_npc.lighting.color_r"), "mmd_vmd_npc_flashlight_color_r", 0, 255, 0)
    add_slider(lightingTab, L("mmd_vmd_npc.lighting.color_g"), "mmd_vmd_npc_flashlight_color_g", 0, 255, 0)
    add_slider(lightingTab, L("mmd_vmd_npc.lighting.color_b"), "mmd_vmd_npc_flashlight_color_b", 0, 255, 0)

    section(lightingTab, L("mmd_vmd_npc.lighting.offset"), Color(255, 220, 120))
    add_slider(lightingTab, L("mmd_vmd_npc.lighting.offset_forward"), "mmd_vmd_npc_flashlight_offset_forward", -64, 64, 0)
    add_slider(lightingTab, L("mmd_vmd_npc.lighting.offset_right"), "mmd_vmd_npc_flashlight_offset_right", -64, 64, 0)
    add_slider(lightingTab, L("mmd_vmd_npc.lighting.offset_up"), "mmd_vmd_npc_flashlight_offset_up", -64, 64, 0)

    update_eye_status = function()
        if not IsValid(eyeStatusLabel) then return end
        local playStatus = MMDVMDNPC.PlayStatus or {}
        local targetStatus = MMDVMDNPC.TargetStatus or {}
        local ent = IsValid(playStatus.ent) and playStatus.ent or (IsValid(targetStatus.ent) and targetStatus.ent or nil)
        if MMDVMDNPC and MMDVMDNPC.ClientEyeBoneSummary then
            eyeStatusLabel:SetText(MMDVMDNPC.ClientEyeBoneSummary(ent))
        else
            eyeStatusLabel:SetText(L("mmd_vmd_npc.ui.eye_status_unavailable"))
        end
    end

    local function update_target(status)
        if not IsValid(targetLabel) then return end
        status = status or MMDVMDNPC.TargetStatus or {}
        if status.valid and IsValid(status.ent) then
            targetLabel:SetText(LF(
                "mmd_vmd_npc.ui.selected_actor_fmt",
                shorten_text(status.targetType or "actor", 18),
                shorten_text(status.ent, compactPanel and 22 or 34),
                shorten_text(status.model or "", pathLimit)
            ))
        else
            targetLabel:SetText(L("mmd_vmd_npc.ui.selected_actor_none"))
        end
        if update_eye_status then update_eye_status() end
    end

    local function update_build(status)
        if not IsValid(buildLabel) then return end
        status = status or MMDVMDNPC.BuildStatus or {}
        buildLabel:SetText(LF("mmd_vmd_npc.ui.build_status_fmt", tostring(status.message or status.status or "idle")))
        if IsValid(buildProgress) then
            buildProgress:SetFraction(math.Clamp(tonumber(status.progress) or 0, 0, 1))
        end
    end

    local function update_play(status)
        if not IsValid(playLabel) then return end
        status = status or MMDVMDNPC.PlayStatus or {}
        playLabel:SetText(LF("mmd_vmd_npc.ui.playback_status_fmt", tostring(status.message or status.status or "idle")))
        if update_eye_status then update_eye_status() end
    end

    local function update_assignments(assignments)
        if not IsValid(assignmentLabel) then return end
        assignments = assignments or MMDVMDNPC.AssignedActors or {}
        local order = assignments.order or {}
        local count = #order
        if count <= 0 then
            assignmentLabel:SetText(L("mmd_vmd_npc.ui.coordinated_npcs_zero"))
            return
        end

        local firstEnt = order[1]
        local first = assignments.byEnt and assignments.byEnt[firstEnt] or nil
        assignmentLabel:SetText(LF(
            "mmd_vmd_npc.ui.coordinated_npcs_fmt",
            count,
            IsValid(firstEnt) and shorten_text(firstEnt, compactPanel and 18 or 28) or "none",
            shorten_text(first and first.motionID or "", compactPanel and 20 or 34),
            shorten_text(first and first.status or "", compactPanel and 18 or 28)
        ))
    end

    update_motion_details = function()
        if not IsValid(motionInfo) then return end
        local current = GetConVar("mmd_vmd_npc_motion")
        local motionID = current and current:GetString() or ""
        local meta = MMDVMDNPC.MotionDetails and MMDVMDNPC.MotionDetails[motionID] or nil
        if IsValid(selectedMotionLabel) then
            selectedMotionLabel:SetText(motionID ~= "" and LF("mmd_vmd_npc.ui.selected_motion_fmt", shorten_text(motion_display_name(meta or motionID), textLimit)) or L("mmd_vmd_npc.ui.selected_motion_none"))
        end
        if IsValid(audioOffsetSlider) then
            audioOffsetSuppress = true
            audioOffsetSlider:SetValue(math.Clamp(tonumber(MMDVMDNPC.AudioOffsets and MMDVMDNPC.AudioOffsets[motionID] or 0) or 0, -5, 5))
            audioOffsetSuppress = false
        end
        if meta then
            motionInfo:SetText(LF(
                "mmd_vmd_npc.ui.motion_info_fmt",
                shorten_text(motion_display_name(meta), textLimit),
                tonumber(meta.duration) or 0,
                tonumber(meta.frameCount) or 0,
                tonumber(meta.boneCount) or 0,
                tonumber(meta.flexCount) or 0,
                tostring(meta.musicSound or "") ~= "" and L("mmd_vmd_npc.ui.yes") or L("mmd_vmd_npc.ui.no"),
                meta.built and L("mmd_vmd_npc.ui.yes") or L("mmd_vmd_npc.ui.no")
            ))
        else
            motionInfo:SetText(motionID ~= "" and LF("mmd_vmd_npc.ui.motion_metadata_missing_fmt", shorten_text(motionID, textLimit)) or L("mmd_vmd_npc.ui.motion_none"))
        end
    end

    hook.Add("MMDVMDNPCTargetStatusUpdated", hookID .. "_Target", update_target)
    hook.Add("MMDVMDNPCAssignmentStatusUpdated", hookID .. "_Assignments", update_assignments)
    hook.Add("MMDVMDNPCBuildStatusUpdated", hookID .. "_Build", update_build)
    hook.Add("MMDVMDNPCPlayStatusUpdated", hookID .. "_Play", update_play)
    hook.Add("MMDVMDNPCMotionDetailsUpdated", hookID .. "_Details", function()
        refresh_motion_list()
        update_motion_details()
    end)
    hook.Add("MMDVMDNPCAudioSettingsUpdated", hookID .. "_Audio", function(motionID, offset)
        local current = GetConVar("mmd_vmd_npc_motion")
        local selected = current and current:GetString() or ""
        if motionID ~= selected or not IsValid(audioOffsetSlider) then return end
        audioOffsetSuppress = true
        audioOffsetSlider:SetValue(math.Clamp(tonumber(offset) or 0, -5, 5))
        audioOffsetSuppress = false
    end)
    hook.Add("MMDVMDNPCPauseStatusUpdated", hookID .. "_Pause", update_pause_warning)
    local oldOnRemove = panel.OnRemove
    panel.OnRemove = function()
        if oldOnRemove then oldOnRemove(panel) end
        timer.Remove(hookID .. "_AudioOffsetSave")
        timer.Remove(hookID .. "_PauseWarning")
        hook.Remove("MMDVMDNPCMotionListUpdated", hookID)
        hook.Remove("MMDVMDNPCTargetStatusUpdated", hookID .. "_Target")
        hook.Remove("MMDVMDNPCAssignmentStatusUpdated", hookID .. "_Assignments")
        hook.Remove("MMDVMDNPCBuildStatusUpdated", hookID .. "_Build")
        hook.Remove("MMDVMDNPCPlayStatusUpdated", hookID .. "_Play")
        hook.Remove("MMDVMDNPCMotionDetailsUpdated", hookID .. "_Details")
        hook.Remove("MMDVMDNPCAudioSettingsUpdated", hookID .. "_Audio")
        hook.Remove("MMDVMDNPCPauseStatusUpdated", hookID .. "_Pause")
    end
    update_target()
    update_assignments()
    update_build()
    update_play()
    update_motion_details()
    update_eye_status()
    request_pause_status()

    if MMDVMDNPC and MMDVMDNPC.RequestMotionList then
        MMDVMDNPC.RequestMotionList()
    end
    if MMDVMDNPC and MMDVMDNPC.RequestMotionDetails then
        MMDVMDNPC.RequestMotionDetails()
    end
    do
        local current = GetConVar("mmd_vmd_npc_motion")
        local motionID = current and current:GetString() or ""
        if motionID ~= "" and MMDVMDNPC and MMDVMDNPC.RequestAudioSettings then
            MMDVMDNPC.RequestAudioSettings(motionID)
        end
    end
end
