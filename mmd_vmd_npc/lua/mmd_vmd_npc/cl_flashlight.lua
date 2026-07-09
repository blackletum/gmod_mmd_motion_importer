-- Camera-following flashlight for the MMD VMD NPC addon.
--
-- The light is driven along the addon's current view:
--   1. the imported camera-path animation (or its debug preview),
--   2. the third-person self-playback camera (when not in free view),
--   3. otherwise the player's own eyes (optional).
--
-- Two render paths share that view:
--   * RTX-Remix build (the RTXFixesBinary module exposes the global `RemixLight`
--     table): a path-traced sphere spotlight is created/updated directly through
--     RemixLight.CreateSphere/UpdateSphere — the same proven pattern as the remix
--     binary's own rtx_flashlight. We do NOT rely on the binary's
--     ProjectedTexture() wrapper: it is silently disabled by archived convars
--     (rtx_lightupdater, rtx_projectedtexture_wrapper_enabled), and Remix discards
--     the raster lighting a ProjectedTexture produces, so nothing would render.
--   * Vanilla Garry's Mod (no RemixLight): a native ProjectedTexture spotlight.

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
-- RTX-Remix specific light shaping (ignored by the vanilla ProjectedTexture path).
CreateClientConVar("mmd_vmd_npc_flashlight_rtx_radius", "20", true, false, "RTX flashlight light sphere radius")
CreateClientConVar("mmd_vmd_npc_flashlight_rtx_softness", "0.45", true, false, "RTX flashlight cone edge softness (0-1)")
CreateClientConVar("mmd_vmd_npc_flashlight_rtx_volumetric", "0", true, false, "RTX flashlight volumetric intensity multiplier")

local FLASHLIGHT_TEXTURE = "effects/flashlight001"
-- The remix flashlight's neutral brightness is radiance == color (scale 1.0 at its
-- brightness 1000). Our slider's default is 4, so divide by 4 to land in the same
-- place: brightness 4 -> radiance 255 per channel.
local RTX_BRIGHTNESS_DIVISOR = 4

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

-- RTXFixesBinary (RTX-Remix builds) exposes RemixLight; absent in vanilla GMod.
local function remix_available()
    return istable(RemixLight)
        and RemixLight.CreateSphere ~= nil
        and RemixLight.UpdateSphere ~= nil
end

-- Light handles live on the persistent MMDVMDNPC table, NOT as file-locals: a
-- Lua auto-refresh re-executes this file with fresh (nil) locals BEFORE the
-- OnReloaded cleanup hook fires, which would orphan a live RemixLight sphere as
-- a frozen duplicate until map change. Table fields survive re-execution, so a
-- refreshed file can reclaim the previous execution's light here.
if MMDVMDNPC.FlashlightRemixLightId and istable(RemixLight) and RemixLight.DestroyLight then
    RemixLight.DestroyLight(MMDVMDNPC.FlashlightRemixLightId)
end
MMDVMDNPC.FlashlightRemixLightId = nil
if IsValid(MMDVMDNPC.FlashlightProjected) then
    MMDVMDNPC.FlashlightProjected:Remove()
end
MMDVMDNPC.FlashlightProjected = nil

-- Vanilla-path dirty-check caches (pure perf state; losing them on refresh is
-- harmless — the next frame just re-applies).
local lastPos = nil
local lastAng = nil
local lastSig = nil

-- RTX path: reusable tables so the per-frame update allocates nothing (same
-- trick as the remix binary's flashlight).
local _vec_pos = { x = 0, y = 0, z = 0 }
local _vec_dir = { x = 0, y = 0, z = 0 }
local _vec_rad = { x = 0, y = 0, z = 0 }
local _shaping = { direction = _vec_dir, coneAngleDegrees = 0, coneSoftness = 0.2, focusExponent = 1.0 }
local _sphere = { position = _vec_pos, radius = 20, shaping = _shaping, volumetricRadianceScale = 0 }
local _base = { hash = 0, radiance = _vec_rad, isDynamic = true, ignoreViewModel = true }

local function remix_hash()
    local ply = LocalPlayer()
    local entIndex = IsValid(ply) and ply:EntIndex() or 0
    return tonumber(util.CRC("mmd_vmd_npc_flashlight_" .. entIndex)) or 987654
end

local function destroy_projected()
    if IsValid(MMDVMDNPC.FlashlightProjected) then MMDVMDNPC.FlashlightProjected:Remove() end
    MMDVMDNPC.FlashlightProjected = nil
    lastPos = nil
    lastAng = nil
    lastSig = nil
end

local function destroy_remix_light()
    if MMDVMDNPC.FlashlightRemixLightId and istable(RemixLight) and RemixLight.DestroyLight then
        RemixLight.DestroyLight(MMDVMDNPC.FlashlightRemixLightId)
    end
    MMDVMDNPC.FlashlightRemixLightId = nil
end

local function destroy_flashlight()
    destroy_projected()
    destroy_remix_light()
end

MMDVMDNPC.DestroyFlashlight = destroy_flashlight

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

-- RTX-Remix path: drive a RemixLight sphere spotlight directly. Updated every
-- frame unconditionally — the light is isDynamic and that is the proven pattern
-- (both the remix flashlight and its ProjectedTexture wrapper update per frame).
local function apply_remix_flashlight(origin, ang, fov, brightness, r, g, b)
    local forward = ang:Forward()
    local scale = brightness / RTX_BRIGHTNESS_DIVISOR
    _vec_rad.x = r * scale
    _vec_rad.y = g * scale
    _vec_rad.z = b * scale

    _vec_pos.x = origin.x
    _vec_pos.y = origin.y
    _vec_pos.z = origin.z

    _vec_dir.x = forward.x
    _vec_dir.y = forward.y
    _vec_dir.z = forward.z

    -- Remix shaping uses the HALF angle (center to edge); ProjectedTexture FOV is
    -- the full cone, so halve it (the remix PT wrapper does the same).
    _shaping.coneAngleDegrees = math.Clamp(fov * 0.5, 1, 89)
    _shaping.coneSoftness = math.Clamp(convar_number("mmd_vmd_npc_flashlight_rtx_softness", 0.45), 0, 1)

    _sphere.radius = math.Clamp(convar_number("mmd_vmd_npc_flashlight_rtx_radius", 20), 1, 200)
    _sphere.volumetricRadianceScale = math.max(0, convar_number("mmd_vmd_npc_flashlight_rtx_volumetric", 0))

    _base.hash = remix_hash()

    if not MMDVMDNPC.FlashlightRemixLightId then
        local ply = LocalPlayer()
        local id = RemixLight.CreateSphere(_base, _sphere, IsValid(ply) and ply:EntIndex() or 0)
        if id and id ~= 0 then
            MMDVMDNPC.FlashlightRemixLightId = id
        end
        return
    end

    RemixLight.UpdateSphere(_base, _sphere, MMDVMDNPC.FlashlightRemixLightId)
end

-- Vanilla path: native ProjectedTexture spotlight.
local function apply_projected_flashlight(origin, ang, fov, brightness, r, g, b)
    local farz = math.max(1, convar_number("mmd_vmd_npc_flashlight_distance", 1200))
    local nearz = math.Clamp(convar_number("mmd_vmd_npc_flashlight_nearz", 12), 1, farz - 1)
    local shadows = convar_bool("mmd_vmd_npc_flashlight_shadows", true)

    -- Signature of everything except pos/ang; combined with a position/angle delta
    -- it lets us skip ProjectedTexture:Update() (a shadow-map rebuild) when nothing
    -- actually changed, e.g. a paused dance or a stationary first-person view.
    local sig = table.concat({ fov, farz, nearz, r, g, b, brightness, shadows and 1 or 0 }, ":")

    local projected = MMDVMDNPC.FlashlightProjected
    if not IsValid(projected) then
        projected = ProjectedTexture()
        if not IsValid(projected) then
            MMDVMDNPC.FlashlightProjected = nil
            return
        end
        projected:SetTexture(FLASHLIGHT_TEXTURE)
        MMDVMDNPC.FlashlightProjected = projected
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

local function apply_flashlight()
    local origin, ang = resolve_view()
    if not origin or not ang then
        destroy_flashlight()
        return
    end

    local offForward = convar_number("mmd_vmd_npc_flashlight_offset_forward", 0)
    local offRight = convar_number("mmd_vmd_npc_flashlight_offset_right", 0)
    local offUp = convar_number("mmd_vmd_npc_flashlight_offset_up", 0)
    if offForward ~= 0 or offRight ~= 0 or offUp ~= 0 then
        origin = origin + ang:Forward() * offForward + ang:Right() * offRight + ang:Up() * offUp
    end

    local fov = math.Clamp(convar_number("mmd_vmd_npc_flashlight_fov", 60), 1, 179)
    local brightness = math.max(0, convar_number("mmd_vmd_npc_flashlight_brightness", 4))
    local r = math.Clamp(math.floor(convar_number("mmd_vmd_npc_flashlight_color_r", 255)), 0, 255)
    local g = math.Clamp(math.floor(convar_number("mmd_vmd_npc_flashlight_color_g", 255)), 0, 255)
    local b = math.Clamp(math.floor(convar_number("mmd_vmd_npc_flashlight_color_b", 255)), 0, 255)

    if remix_available() then
        -- Never keep a ProjectedTexture alive in the RTX build: Remix discards its
        -- raster lighting, and the binary's PT wrapper could bridge it into a
        -- SECOND remix light on setups where that wrapper is enabled.
        if MMDVMDNPC.FlashlightProjected then destroy_projected() end
        apply_remix_flashlight(origin, ang, fov, brightness, r, g, b)
    else
        apply_projected_flashlight(origin, ang, fov, brightness, r, g, b)
    end
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
        if MMDVMDNPC.FlashlightProjected or MMDVMDNPC.FlashlightRemixLightId then destroy_flashlight() end
        return
    end

    apply_flashlight()
end)

concommand.Add("mmd_vmd_npc_flashlight_toggle", function()
    RunConsoleCommand("mmd_vmd_npc_flashlight_enabled", flashlight_enabled() and "0" or "1")
end)

-- Free the light on map change / lua refresh so it never leaks.
hook.Add("ShutDown", "MMDVMDNPCFlashlightCleanup", destroy_flashlight)
hook.Add("OnReloaded", "MMDVMDNPCFlashlightCleanup", destroy_flashlight)
