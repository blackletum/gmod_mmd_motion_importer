-- Camera-following flashlight for the MMD VMD NPC addon.
--
-- A single native ProjectedTexture is driven along the addon's current view:
--   1. the imported camera-path animation (or its debug preview),
--   2. the third-person self-playback camera (when not in first-person/free view),
--   3. otherwise the player's own eyes (optional).
--
-- ProjectedTexture is portable: vanilla Garry's Mod renders it as a real dynamic
-- spotlight, and the RTX-Remix binary's ProjectedTexture() wrapper mirrors it into
-- a path-traced light automatically, so the same code works in both builds.

if not CLIENT then return end

MMDVMDNPC = MMDVMDNPC or {}

-- Persistent settings (mirrors the remix flashlight's tunables) -------------------
CreateClientConVar("mmd_vmd_npc_flashlight_enabled", "0", true, false, "Enable the MMD camera-following flashlight")
CreateClientConVar("mmd_vmd_npc_flashlight_key", "0", true, false, "Key code that toggles the MMD flashlight")
CreateClientConVar("mmd_vmd_npc_flashlight_follow_eye", "1", true, false, "When no cinematic camera is active, keep the flashlight on the player's eyes")
CreateClientConVar("mmd_vmd_npc_flashlight_shadows", "1", true, false, "Cast dynamic shadows from the MMD flashlight (non-RTX)")
CreateClientConVar("mmd_vmd_npc_flashlight_brightness", "4", true, false, "MMD flashlight brightness")
CreateClientConVar("mmd_vmd_npc_flashlight_fov", "60", true, false, "MMD flashlight cone angle (degrees)")
CreateClientConVar("mmd_vmd_npc_flashlight_distance", "1200", true, false, "MMD flashlight throw distance (far Z)")
CreateClientConVar("mmd_vmd_npc_flashlight_nearz", "12", true, false, "MMD flashlight near Z")
CreateClientConVar("mmd_vmd_npc_flashlight_color_r", "255", true, false, "MMD flashlight red (0-255)")
CreateClientConVar("mmd_vmd_npc_flashlight_color_g", "255", true, false, "MMD flashlight green (0-255)")
CreateClientConVar("mmd_vmd_npc_flashlight_color_b", "255", true, false, "MMD flashlight blue (0-255)")
CreateClientConVar("mmd_vmd_npc_flashlight_offset_forward", "0", true, false, "MMD flashlight forward offset from the view")
CreateClientConVar("mmd_vmd_npc_flashlight_offset_right", "0", true, false, "MMD flashlight right offset from the view")
CreateClientConVar("mmd_vmd_npc_flashlight_offset_up", "0", true, false, "MMD flashlight up offset from the view")

local FLASHLIGHT_TEXTURE = "effects/flashlight001"

local function convar_number(name, fallback)
    local cvar = GetConVar(name)
    if not cvar then return fallback or 0 end
    return tonumber(cvar:GetString()) or fallback or 0
end

local function convar_bool(name, fallback)
    local cvar = GetConVar(name)
    if not cvar then return fallback and true or false end
    return cvar:GetBool()
end

local function flashlight_enabled()
    return convar_bool("mmd_vmd_npc_flashlight_enabled", false)
end

-- ProjectedTexture handle + last-applied state for a cheap per-frame dirty check.
local projected = nil
local lastPos = nil
local lastAng = nil
local lastSig = nil

local function destroy_projected()
    if IsValid(projected) then projected:Remove() end
    projected = nil
    lastPos = nil
    lastAng = nil
    lastSig = nil
end

MMDVMDNPC.DestroyFlashlight = destroy_projected

-- Resolve the origin + angles the flashlight should follow this frame, or nil when
-- it should be hidden (disabled, or free view with eye-follow turned off).
local function resolve_view()
    -- 1. Imported camera-path animation, including the debug-window preview.
    if MMDVMDNPC.CameraAnimActive
        or (MMDVMDNPC.CameraDebugPreviewRenderable and MMDVMDNPC.CameraDebugPreviewRenderable()) then
        if isvector(MMDVMDNPC.CameraAnimViewOrigin) and isangle(MMDVMDNPC.CameraAnimViewAngles) then
            return MMDVMDNPC.CameraAnimViewOrigin, MMDVMDNPC.CameraAnimViewAngles
        end
    end

    -- 2. Third-person self-playback camera (not first-person / free view).
    if MMDVMDNPC.SelfThirdPersonActive
        and isvector(MMDVMDNPC.SelfThirdPersonViewOrigin)
        and isangle(MMDVMDNPC.SelfThirdPersonViewAngles) then
        return MMDVMDNPC.SelfThirdPersonViewOrigin, MMDVMDNPC.SelfThirdPersonViewAngles
    end

    -- 3. Free / first-person view: follow the player's eyes when allowed.
    if convar_bool("mmd_vmd_npc_flashlight_follow_eye", true) then
        local ply = LocalPlayer()
        if IsValid(ply) then
            return ply:EyePos(), ply:EyeAngles()
        end
    end

    return nil
end

local function apply_flashlight()
    local origin, ang = resolve_view()
    if not origin or not ang then
        destroy_projected()
        return
    end

    local offForward = convar_number("mmd_vmd_npc_flashlight_offset_forward", 0)
    local offRight = convar_number("mmd_vmd_npc_flashlight_offset_right", 0)
    local offUp = convar_number("mmd_vmd_npc_flashlight_offset_up", 0)
    if offForward ~= 0 or offRight ~= 0 or offUp ~= 0 then
        origin = origin + ang:Forward() * offForward + ang:Right() * offRight + ang:Up() * offUp
    end

    local fov = math.Clamp(convar_number("mmd_vmd_npc_flashlight_fov", 60), 1, 179)
    local farz = math.max(1, convar_number("mmd_vmd_npc_flashlight_distance", 1200))
    local nearz = math.Clamp(convar_number("mmd_vmd_npc_flashlight_nearz", 12), 1, farz - 1)
    local r = math.Clamp(math.floor(convar_number("mmd_vmd_npc_flashlight_color_r", 255)), 0, 255)
    local g = math.Clamp(math.floor(convar_number("mmd_vmd_npc_flashlight_color_g", 255)), 0, 255)
    local b = math.Clamp(math.floor(convar_number("mmd_vmd_npc_flashlight_color_b", 255)), 0, 255)
    local brightness = math.max(0, convar_number("mmd_vmd_npc_flashlight_brightness", 4))
    local shadows = convar_bool("mmd_vmd_npc_flashlight_shadows", true)

    -- Signature of everything except pos/ang; combined with a position/angle delta
    -- it lets us skip ProjectedTexture:Update() (a shadow-map rebuild) when nothing
    -- actually changed, e.g. a paused dance or a stationary first-person view.
    local sig = table.concat({ fov, farz, nearz, r, g, b, brightness, shadows and 1 or 0 }, ":")

    if not IsValid(projected) then
        projected = ProjectedTexture()
        if not IsValid(projected) then
            projected = nil
            return
        end
        projected:SetTexture(FLASHLIGHT_TEXTURE)
        lastPos = nil
        lastAng = nil
        lastSig = nil
    end

    local moved = (not lastPos) or (not lastAng)
        or lastPos:DistToSqr(origin) > 0.01
        or math.abs(lastAng.p - ang.p) > 0.01
        or math.abs(lastAng.y - ang.y) > 0.01
        or math.abs(lastAng.r - ang.r) > 0.01
    if not moved and sig == lastSig then
        return
    end

    projected:SetPos(origin)
    projected:SetAngles(ang)
    projected:SetFOV(fov)
    projected:SetFarZ(farz)
    projected:SetNearZ(nearz)
    projected:SetColor(Color(r, g, b))
    projected:SetBrightness(brightness)
    projected:SetEnableShadows(shadows)
    projected:Update()

    lastPos = origin
    lastAng = Angle(ang.p, ang.y, ang.r)
    lastSig = sig
end

-- Hotkey toggle. input.WasKeyPressed only fires inside Move hooks, so from Think we
-- edge-detect the held state ourselves (same convention as the camera hotkey).
local hotkeyWasDown = false

hook.Add("Think", "MMDVMDNPCFlashlight", function()
    local key = math.floor(convar_number("mmd_vmd_npc_flashlight_key", 0))
    if key > 0 then
        local down
        if MOUSE_FIRST and key >= MOUSE_FIRST then
            down = input.IsMouseDown and input.IsMouseDown(key) or false
        else
            down = input.IsKeyDown and input.IsKeyDown(key) or false
        end

        local suppressed = gui.IsGameUIVisible()
            or (vgui and vgui.CursorVisible and vgui.CursorVisible())
            or (vgui and vgui.GetKeyboardFocus and IsValid(vgui.GetKeyboardFocus()))
        if not suppressed then
            local ply = LocalPlayer()
            suppressed = IsValid(ply) and ply.IsTyping and ply:IsTyping() or false
        end

        if down and not hotkeyWasDown and not suppressed then
            RunConsoleCommand("mmd_vmd_npc_flashlight_enabled", flashlight_enabled() and "0" or "1")
        end
        hotkeyWasDown = down
    else
        hotkeyWasDown = false
    end

    if not flashlight_enabled() then
        if IsValid(projected) then destroy_projected() end
        return
    end

    apply_flashlight()
end)

concommand.Add("mmd_vmd_npc_flashlight_toggle", function()
    RunConsoleCommand("mmd_vmd_npc_flashlight_enabled", flashlight_enabled() and "0" or "1")
end)

-- Free the ProjectedTexture on map change / lua refresh so it never leaks.
hook.Add("ShutDown", "MMDVMDNPCFlashlightCleanup", destroy_projected)
hook.Add("OnReloaded", "MMDVMDNPCFlashlightCleanup", destroy_projected)
