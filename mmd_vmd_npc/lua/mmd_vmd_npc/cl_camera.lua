-- Imported MMD camera animation playback (client).
--
-- The importer exports camera keys in the dancing CHARACTER's local frame:
-- eye position in source units and view angles in degrees, both relative to an
-- upright character at the origin facing +X. At render time each sample is
-- transformed by the anchor entity's position and yaw, so the path is correct
-- wherever the character stands and whichever way it faces.

MMDVMDNPC = MMDVMDNPC or {}
MMDVMDNPC.CameraTracks = MMDVMDNPC.CameraTracks or {}          -- [anchorEntIndex] = track
MMDVMDNPC.CameraDebugTracks = MMDVMDNPC.CameraDebugTracks or {} -- [motionID] = track
MMDVMDNPC.CameraPendingTransfers = MMDVMDNPC.CameraPendingTransfers or {}
MMDVMDNPC.CameraAnimActive = MMDVMDNPC.CameraAnimActive or false
MMDVMDNPC.CameraAnimEntIndex = MMDVMDNPC.CameraAnimEntIndex or nil
MMDVMDNPC.CameraAnimViewOrigin = MMDVMDNPC.CameraAnimViewOrigin or nil
MMDVMDNPC.CameraDebugPreview = MMDVMDNPC.CameraDebugPreview or nil

CreateClientConVar("mmd_vmd_npc_camera_key", "0", true, false, "Key code that toggles the imported camera animation view")
CreateClientConVar("mmd_vmd_npc_camera_auto", "1", true, false, "Automatically enter the imported camera animation when a dance you start has one")
CreateClientConVar("mmd_vmd_npc_cam_scale", "1", true, false, "Camera animation: global position scale")
CreateClientConVar("mmd_vmd_npc_cam_offset_x", "0", true, false, "Camera animation: global offset forward")
CreateClientConVar("mmd_vmd_npc_cam_offset_y", "0", true, false, "Camera animation: global offset left")
CreateClientConVar("mmd_vmd_npc_cam_offset_z", "0", true, false, "Camera animation: global offset up")
CreateClientConVar("mmd_vmd_npc_cam_yaw", "0", true, false, "Camera animation: global yaw offset (degrees)")
CreateClientConVar("mmd_vmd_npc_cam_pitch", "0", true, false, "Camera animation: global pitch offset (degrees)")
CreateClientConVar("mmd_vmd_npc_cam_fov", "0", true, false, "Camera animation: fov offset (degrees)")
CreateClientConVar("mmd_vmd_npc_cam_collision", "1", true, false, "Camera animation: pull the camera in front of walls it would otherwise clip through")
CreateClientConVar("mmd_vmd_npc_cam_max_distance", "2500", true, false, "Camera animation: cap the camera's distance to the subject (0 = unlimited)")

-- Wall collision defaults on. New clients already get "1"; this one-time
-- migration also turns it on for existing clients that saved it off during
-- earlier testing (before it actually worked), then respects any later choice.
CreateClientConVar("mmd_vmd_npc_cam_collision_migrated", "0", true, false)
hook.Add("InitPostEntity", "MMDVMDNPCCamCollisionDefaultOn", function()
    local marker = GetConVar("mmd_vmd_npc_cam_collision_migrated")
    if marker and marker:GetBool() then return end
    RunConsoleCommand("mmd_vmd_npc_cam_collision_migrated", "1")
    RunConsoleCommand("mmd_vmd_npc_cam_collision", "1")
end)

local function L(key, fallback)
    return MMDVMDNPC.L and MMDVMDNPC.L(key, fallback) or (fallback or key)
end

local function convar_number(name, fallback)
    local cvar = GetConVar(name)
    if not cvar then return fallback end
    local value = cvar:GetFloat()
    if value ~= value then return fallback end
    return value
end

local function camera_auto_enabled()
    local cvar = GetConVar("mmd_vmd_npc_camera_auto")
    if not cvar then return true end
    return cvar:GetBool()
end

-- Track sampling --------------------------------------------------------------

-- A hard camera cut is exported as two keys on adjacent frames with a large
-- delta; hold the earlier key instead of smearing across the cut.
local CUT_POSITION_DELTA = 30
local CUT_ANGLE_DELTA = 25

local function normalize_angle(value)
    return math.NormalizeAngle and math.NormalizeAngle(value) or (((value + 180) % 360) - 180)
end

local function lerp_number(a, b, t)
    return a + (b - a) * t
end

local function lerp_angle(a, b, t)
    return a + normalize_angle(b - a) * t
end

local function camera_key_span(keys, frame)
    local lo, hi = 1, #keys
    while lo < hi do
        local mid = math.floor((lo + hi + 1) / 2)
        if keys[mid].frame <= frame then
            lo = mid
        else
            hi = mid - 1
        end
    end
    return lo
end

function MMDVMDNPC.SampleCameraTrack(track, frame)
    local keys = track and track.keys or nil
    if not istable(keys) or #keys <= 0 then return nil end

    local first, last = keys[1], keys[#keys]
    if frame <= first.frame then
        return first.x, first.y, first.z, first.p, first.yw, first.r, first.fov
    end
    if frame >= last.frame then
        return last.x, last.y, last.z, last.p, last.yw, last.r, last.fov
    end

    local index = camera_key_span(keys, frame)
    local a = keys[index]
    local b = keys[index + 1] or a
    local span = math.max(1e-6, b.frame - a.frame)
    local t = math.Clamp((frame - a.frame) / span, 0, 1)

    if (b.frame - a.frame) <= 1 then
        local posDelta = math.max(math.abs(b.x - a.x), math.abs(b.y - a.y), math.abs(b.z - a.z))
        local angDelta = math.max(
            math.abs(normalize_angle(b.p - a.p)),
            math.abs(normalize_angle(b.yw - a.yw)),
            math.abs(normalize_angle(b.r - a.r))
        )
        if posDelta > CUT_POSITION_DELTA or angDelta > CUT_ANGLE_DELTA then
            return a.x, a.y, a.z, a.p, a.yw, a.r, a.fov
        end
    end

    return lerp_number(a.x, b.x, t),
        lerp_number(a.y, b.y, t),
        lerp_number(a.z, b.z, t),
        lerp_angle(a.p, b.p, t),
        lerp_angle(a.yw, b.yw, t),
        lerp_angle(a.r, b.r, t),
        lerp_number(a.fov, b.fov, t)
end

local function track_frame_now(track, now)
    local fps = math.max(1, track.fps or 30)
    if track.paused then
        return track.heldFrame or track.frameStart or 0
    end
    local elapsedSeconds = math.max(0, now - (track.startAt or 0))
    -- Looping follows the BODY motion's period (loopSeconds from the server),
    -- not the camera's own frame range: the camera may be shorter than the
    -- dance and must hold its last key until the dance wraps.
    if track.loop and (track.loopSeconds or 0) > 0 then
        elapsedSeconds = elapsedSeconds % track.loopSeconds
    end
    local frame = (track.frameStart or 0) + elapsedSeconds * fps
    return math.min(frame, track.frameEnd or frame)
end

-- Global user transform (tuned from the camera debug panel) -------------------

local function apply_global_transform(x, y, z, p, yw, r, fov)
    local scale = math.Clamp(convar_number("mmd_vmd_npc_cam_scale", 1), 0.05, 20)
    local yawOff = convar_number("mmd_vmd_npc_cam_yaw", 0)
    local pitchOff = convar_number("mmd_vmd_npc_cam_pitch", 0)
    local fovOff = convar_number("mmd_vmd_npc_cam_fov", 0)

    x, y, z = x * scale, y * scale, z * scale
    if math.abs(yawOff) > 0.001 then
        local rad = math.rad(yawOff)
        local c, s = math.cos(rad), math.sin(rad)
        x, y = x * c - y * s, x * s + y * c
    end
    x = x + convar_number("mmd_vmd_npc_cam_offset_x", 0)
    y = y + convar_number("mmd_vmd_npc_cam_offset_y", 0)
    z = z + convar_number("mmd_vmd_npc_cam_offset_z", 0)

    p = math.Clamp(p + pitchOff, -89.9, 89.9)
    yw = yw + yawOff
    fov = math.Clamp(fov + fovOff, 1, 170)
    return x, y, z, p, yw, r, fov
end

-- MMD fov is vertical; Source expects the 4:3 horizontal fov and derives the
-- vertical from it independent of the actual window aspect.
local function vertical_to_source_fov(vfov)
    local half = math.rad(math.Clamp(vfov, 1, 170)) * 0.5
    return math.deg(2 * math.atan(math.tan(half) * (4 / 3)))
end

local function anchor_transform(ent)
    local ang = ent:GetAngles()
    return ent:GetPos(), Angle(0, ang.y or 0, 0)
end

-- Wall collision + distance cap. The animated camera can be authored to swing
-- far from the character or, once the character is at an arbitrary world
-- position, end up on the far side of a wall so the player only sees geometry.
-- Both cases are corrected by pulling the camera along the subject->camera line
-- until it is in front of the obstruction (and no farther than a cap), then
-- widening the vertical FOV so the subject keeps its intended apparent size
-- (tan(fov/2) scales with the distance ratio).
local CAMERA_WALL_MARGIN = 8
-- Degenerate floor: never divide by ~zero and never pull nearer than this even
-- if a wall is right against the subject. Applied uniformly at every distance
-- (no separate "close-up" cutoff), so the camera never snaps on/off as an
-- animated close pass crosses a threshold.
local CAMERA_MIN_PULL = 4
local CAMERA_MAX_ADJUSTED_FOV = 130
local CAMERA_HULL_MIN = Vector(-4, -4, -4)
local CAMERA_HULL_MAX = Vector(4, 4, 4)

local function camera_pivot(anchorEnt)
    if anchorEnt.WorldSpaceCenter then
        local center = anchorEnt:WorldSpaceCenter()
        if isvector(center) then return center end
    end
    return anchorEnt:GetPos() + Vector(0, 0, 40)
end

-- Occlusion trace from the subject to the desired camera spot. Uses the DEFAULT
-- solid mask (world brushes AND props/func_detail/displacements — the same mask
-- the working orbit camera uses; MASK_SOLID_BRUSHWORLD missed prop and detail
-- walls). A ±4 hull keeps the lens clear of the surface. If the hull merely
-- grazes nearby geometry at the start it reports StartSolid even though the
-- subject is in the open, so fall back to a line trace to tell a genuine
-- overshoot (subject truly inside a brush) from a false positive.
local function trace_camera_wall(pivot, target, anchorEnt)
    local filter = { anchorEnt }
    local ply = LocalPlayer()
    if IsValid(ply) then filter[#filter + 1] = ply end

    local hull = util.TraceHull({
        start = pivot,
        endpos = target,
        mins = CAMERA_HULL_MIN,
        maxs = CAMERA_HULL_MAX,
        filter = filter,
    })
    if not hull.StartSolid then return hull end

    return util.TraceLine({
        start = pivot,
        endpos = target,
        filter = filter,
    })
end

local function apply_camera_collision(anchorEnt, pivot, camPos, vfov)
    local toCam = camPos - pivot
    local dist = toCam:Length()
    if dist <= CAMERA_MIN_PULL then return camPos, vfov end
    local dir = toCam / dist

    local capped = dist
    local maxDist = convar_number("mmd_vmd_npc_cam_max_distance", 2500)
    if maxDist > 0 then capped = math.min(capped, maxDist) end

    local collide = GetConVar("mmd_vmd_npc_cam_collision")
    if not collide or collide:GetBool() then
        local tr = trace_camera_wall(pivot, pivot + dir * capped, anchorEnt)
        -- StartSolid here means the subject itself is inside a brush (a real
        -- animation overshoot through a wall); leave the camera where the
        -- animation put it rather than yanking it onto a surface behind the
        -- character.
        if tr.Hit and not tr.StartSolid then
            capped = math.min(capped, (tr.HitPos - pivot):Length() - CAMERA_WALL_MARGIN)
        end
    end

    capped = math.max(CAMERA_MIN_PULL, capped)
    if capped >= dist - 0.5 then return camPos, vfov end

    -- Widen to preserve apparent size, but never below the authored FOV (the
    -- ceiling only trims extreme fisheye — a base FOV already wider than the
    -- ceiling must not be narrowed by the collision path).
    local half = math.rad(math.Clamp(vfov, 1, 179)) * 0.5
    local widened = math.deg(2 * math.atan(math.tan(half) * (dist / capped)))
    return pivot + dir * capped, math.Clamp(widened, vfov, math.max(vfov, CAMERA_MAX_ADJUSTED_FOV))
end

local function camera_view_for(track, anchorEnt, frame)
    local x, y, z, p, yw, r, fov = MMDVMDNPC.SampleCameraTrack(track, frame)
    if x == nil then return nil end
    x, y, z, p, yw, r, fov = apply_global_transform(x, y, z, p, yw, r, fov)

    local anchorPos, anchorAng = anchor_transform(anchorEnt)
    local worldPos, worldAng = LocalToWorld(Vector(x, y, z), Angle(p, yw, r), anchorPos, anchorAng)
    worldPos, fov = apply_camera_collision(anchorEnt, camera_pivot(anchorEnt), worldPos, fov)
    return {
        origin = worldPos,
        angles = worldAng,
        fov = vertical_to_source_fov(fov),
        drawviewer = true,
        localValues = { x = x, y = y, z = z, p = p, yw = yw, r = r, fov = fov },
    }
end

-- The camera debug preview orbits the "entity of interest": the first assigned
-- group actor, else the selected debug target, else the local player (so a
-- debug session with nothing selected previews on the player's own model).
function MMDVMDNPC.CameraDebugAnchor()
    local assigned = MMDVMDNPC.AssignedActors
    if istable(assigned) and istable(assigned.order) then
        for _, ent in ipairs(assigned.order) do
            if IsValid(ent) then return ent end
        end
    end
    local target = MMDVMDNPC.TargetStatus and MMDVMDNPC.TargetStatus.ent or nil
    if IsValid(target) then return target end
    local ply = LocalPlayer()
    if IsValid(ply) then return ply end
    return nil
end

-- Public helpers for the debug panel ------------------------------------------

function MMDVMDNPC.CameraDebugTrackFor(motionID)
    return MMDVMDNPC.CameraDebugTracks[tostring(motionID or "")]
end

-- True when the debug camera preview will actually render a view this frame.
-- Pure predicate (no CalcView side effects) so hook order cannot deadlock the
-- orbit camera against the camera hook.
function MMDVMDNPC.CameraDebugPreviewRenderable()
    local debugPreview = MMDVMDNPC.CameraDebugPreview
    if not istable(debugPreview) then return false end
    local track = MMDVMDNPC.CameraDebugTracks[tostring(debugPreview.motionID or "")]
    if not track then return false end
    local anchor = MMDVMDNPC.CameraDebugAnchor()
    if not IsValid(anchor) then return false end
    local frameWindow = MMDVMDNPC.DebugFrame
    local frame = IsValid(frameWindow) and tonumber(frameWindow.ActiveFrame) or nil
    return frame ~= nil and frame >= 0
end

function MMDVMDNPC.CameraDebugSample(motionID, frame)
    local track = MMDVMDNPC.CameraDebugTrackFor(motionID)
    if not track then return nil end
    local x, y, z, p, yw, r, fov = MMDVMDNPC.SampleCameraTrack(track, frame)
    if x == nil then return nil end
    x, y, z, p, yw, r, fov = apply_global_transform(x, y, z, p, yw, r, fov)
    return { x = x, y = y, z = z, p = p, yw = yw, r = r, fov = fov }
end

-- Activation -------------------------------------------------------------------

local function playable_camera_entries()
    local out = {}
    for entIndex, track in pairs(MMDVMDNPC.CameraTracks) do
        local ent = Entity(entIndex)
        if IsValid(ent) and istable(track.keys) and #track.keys > 0 then
            out[#out + 1] = { entIndex = entIndex, track = track }
        end
    end
    return out
end

function MMDVMDNPC.CameraAnimAvailable()
    return #playable_camera_entries() > 0
end

function MMDVMDNPC.ActivateCameraAnim(entIndex)
    local track = MMDVMDNPC.CameraTracks[entIndex]
    if not track or not IsValid(Entity(entIndex)) then return false end
    MMDVMDNPC.CameraAnimActive = true
    MMDVMDNPC.CameraAnimEntIndex = entIndex
    return true
end

function MMDVMDNPC.DeactivateCameraAnim()
    MMDVMDNPC.CameraAnimActive = false
    MMDVMDNPC.CameraAnimEntIndex = nil
    MMDVMDNPC.CameraAnimViewOrigin = nil
end

function MMDVMDNPC.ToggleCameraAnim()
    if MMDVMDNPC.CameraAnimActive then
        MMDVMDNPC.DeactivateCameraAnim()
        return
    end

    -- Of all dances currently playing with a camera path, enter the one that
    -- started most recently.
    local entries = playable_camera_entries()
    if #entries <= 0 then
        if notification and notification.AddLegacy then
            notification.AddLegacy(L("mmd_vmd_npc.camera.none_available", "No camera animation is playing"), NOTIFY_HINT, 3)
        end
        return
    end
    table.sort(entries, function(a, b)
        return (a.track.receivedAt or 0) > (b.track.receivedAt or 0)
    end)
    MMDVMDNPC.ActivateCameraAnim(entries[1].entIndex)
end

concommand.Add("mmdvmd_camera_toggle", function()
    MMDVMDNPC.ToggleCameraAnim()
end)

-- Net receivers ----------------------------------------------------------------

local function prune_stale_transfers()
    local cutoff = SysTime() - 30
    for id, pending in pairs(MMDVMDNPC.CameraPendingTransfers) do
        if (pending.receivedAt or 0) < cutoff then
            MMDVMDNPC.CameraPendingTransfers[id] = nil
        end
    end
end

-- The server's paced key chunks are sent from timers that outlive a stop or a
-- restart of the playback, so an in-flight transfer must be invalidated when
-- its anchor is stopped or superseded — otherwise the late chunks complete it,
-- re-install a dead track and auto-enter the camera of a playback that no
-- longer exists.
local function cancel_pending_transfers_for(entIndex)
    for id, pending in pairs(MMDVMDNPC.CameraPendingTransfers) do
        if pending.debug ~= true and pending.entIndex == entIndex then
            MMDVMDNPC.CameraPendingTransfers[id] = nil
        end
    end
end

local function pending_transfer_for(entIndex)
    for _, pending in pairs(MMDVMDNPC.CameraPendingTransfers) do
        if pending.debug ~= true and pending.entIndex == entIndex then
            return pending
        end
    end
    return nil
end

net.Receive("mmdvmd_camera_begin", function()
    prune_stale_transfers()
    local transferID = net.ReadUInt(32)
    local entIndex = net.ReadUInt(16)
    local motionID = net.ReadString()
    local fps = net.ReadUInt(16)
    local frameStart = net.ReadUInt(32)
    local frameEnd = net.ReadUInt(32)
    local startAt = net.ReadFloat()
    local loop = net.ReadBool()
    local loopSeconds = net.ReadFloat()
    local autoEnter = net.ReadBool()
    local debug = net.ReadBool()
    local keyCount = net.ReadUInt(16)

    local track = {
        entIndex = entIndex,
        motionID = motionID,
        fps = fps,
        frameStart = frameStart,
        frameEnd = frameEnd,
        startAt = startAt,
        loop = loop,
        loopSeconds = loopSeconds,
        autoEnter = autoEnter,
        debug = debug,
        expected = keyCount,
        received = 0,
        keys = {},
        receivedAt = SysTime(),
    }

    if keyCount <= 0 then
        -- Camera-less motion answering a debug request.
        if debug then
            MMDVMDNPC.CameraDebugTracks[motionID] = nil
            hook.Run("MMDVMDNPCCameraDebugTrackUpdated", motionID, nil)
        end
        return
    end

    -- A newer begin for the same anchor supersedes any older in-flight
    -- transfer (the playback was restarted while the previous camera track
    -- was still streaming).
    if not debug then
        cancel_pending_transfers_for(entIndex)
    end
    MMDVMDNPC.CameraPendingTransfers[transferID] = track
end)

net.Receive("mmdvmd_camera_keys", function()
    local transferID = net.ReadUInt(32)
    local startIndex = net.ReadUInt(16)
    local count = net.ReadUInt(16)
    local track = MMDVMDNPC.CameraPendingTransfers[transferID]

    for i = 0, count - 1 do
        local key = {
            frame = net.ReadUInt(32),
            x = net.ReadFloat(),
            y = net.ReadFloat(),
            z = net.ReadFloat(),
            p = net.ReadFloat(),
            yw = net.ReadFloat(),
            r = net.ReadFloat(),
            fov = net.ReadFloat(),
        }
        if track then
            track.keys[startIndex + i] = key
            track.received = track.received + 1
        end
    end

    if not track or track.received < track.expected then return end
    MMDVMDNPC.CameraPendingTransfers[transferID] = nil

    if track.debug then
        MMDVMDNPC.CameraDebugTracks[track.motionID] = track
        hook.Run("MMDVMDNPCCameraDebugTrackUpdated", track.motionID, track)
        return
    end

    MMDVMDNPC.CameraTracks[track.entIndex] = track

    -- Any playback this player started (wheel, self via menu, NPC or group):
    -- enter the imported camera automatically when the camera-auto option is
    -- enabled. The freshly spawned self-proxy entity may not have been
    -- networked yet (net messages outrun entity snapshots), so a failed
    -- activation is retried from the Think hook until the entity appears or
    -- the attempt expires.
    if track.autoEnter and camera_auto_enabled() then
        if not MMDVMDNPC.ActivateCameraAnim(track.entIndex) then
            track.pendingActivate = true
            track.pendingActivateUntil = SysTime() + 5
        end
    end
end)

net.Receive("mmdvmd_camera_stop", function()
    local entIndex = net.ReadUInt(16)
    MMDVMDNPC.CameraTracks[entIndex] = nil
    cancel_pending_transfers_for(entIndex)
    if MMDVMDNPC.CameraAnimActive and MMDVMDNPC.CameraAnimEntIndex == entIndex then
        MMDVMDNPC.DeactivateCameraAnim()
    end
end)

net.Receive("mmdvmd_camera_sync", function()
    local entIndex = net.ReadUInt(16)
    local paused = net.ReadBool()
    local startAt = net.ReadFloat()
    -- The keys may still be streaming; apply the sync to the in-flight
    -- transfer so a pause issued in that window is not lost when the track
    -- installs moments later.
    local track = MMDVMDNPC.CameraTracks[entIndex] or pending_transfer_for(entIndex)
    if not track then return end

    if paused and not track.paused then
        track.heldFrame = track_frame_now(track, CurTime())
    end
    track.paused = paused
    track.startAt = startAt
    if not paused then track.heldFrame = nil end
end)

hook.Add("MMDVMDNPCPlayStatusUpdated", "MMDVMDNPCCameraStatusWatch", function(status)
    -- "stopped_all" only stops NPC dances; the server sends explicit
    -- mmdvmd_camera_stop per playback, so just prune tracks whose anchor is
    -- gone rather than wiping a still-running self-playback camera.
    if istable(status) and status.status == "stopped_all" then
        for entIndex, track in pairs(MMDVMDNPC.CameraTracks) do
            -- A freshly started self playback's proxy can lawfully be invalid
            -- for a few seconds (net beats entity snapshots). The pending
            -- activation window covers the auto-enter case; the receivedAt
            -- grace covers tracks installed with the camera-auto option off.
            local awaitingEntity = (track.pendingActivate
                    and (track.pendingActivateUntil or 0) >= SysTime())
                or (track.receivedAt or 0) >= SysTime() - 5
            if not IsValid(Entity(entIndex)) and not awaitingEntity then
                MMDVMDNPC.CameraTracks[entIndex] = nil
                if MMDVMDNPC.CameraAnimActive and MMDVMDNPC.CameraAnimEntIndex == entIndex then
                    MMDVMDNPC.DeactivateCameraAnim()
                end
            end
        end
    end
end)

-- Rendering --------------------------------------------------------------------

hook.Add("CalcView", "MMDVMDNPCCameraAnim", function(ply, pos, angles, fov)
    -- Camera debug preview from the raw-animation debug window takes priority.
    if MMDVMDNPC.CameraDebugPreviewRenderable() then
        local debugPreview = MMDVMDNPC.CameraDebugPreview
        local track = MMDVMDNPC.CameraDebugTracks[tostring(debugPreview.motionID or "")]
        local anchor = MMDVMDNPC.CameraDebugAnchor()
        local frameWindow = MMDVMDNPC.DebugFrame
        local frame = IsValid(frameWindow) and tonumber(frameWindow.ActiveFrame) or 0
        local view = camera_view_for(track, anchor, math.max(0, frame))
        if view then
            MMDVMDNPC.CameraAnimViewOrigin = view.origin
            MMDVMDNPC.CameraAnimViewAngles = view.angles
            return view
        end
    end

    if not MMDVMDNPC.CameraAnimActive then return end

    local entIndex = MMDVMDNPC.CameraAnimEntIndex
    local track = entIndex and MMDVMDNPC.CameraTracks[entIndex] or nil
    local anchor = entIndex and Entity(entIndex) or nil
    if not track or not IsValid(anchor) then
        MMDVMDNPC.DeactivateCameraAnim()
        return
    end

    local view = camera_view_for(track, anchor, track_frame_now(track, CurTime()))
    if not view then
        MMDVMDNPC.DeactivateCameraAnim()
        return
    end

    MMDVMDNPC.CameraAnimViewOrigin = view.origin
    MMDVMDNPC.CameraAnimViewAngles = view.angles
    return view
end)

hook.Add("PreDrawViewModel", "MMDVMDNPCCameraAnimViewModel", function()
    if MMDVMDNPC.CameraAnimActive or MMDVMDNPC.CameraDebugPreviewRenderable() then return true end
end)

-- Hotkey + deferred activation ---------------------------------------------------

local function retry_pending_activations()
    for entIndex, track in pairs(MMDVMDNPC.CameraTracks) do
        if track.pendingActivate then
            if (track.pendingActivateUntil or 0) < SysTime() then
                track.pendingActivate = nil
            elseif MMDVMDNPC.ActivateCameraAnim(entIndex) then
                track.pendingActivate = nil
            end
        end
    end
end

-- input.WasKeyPressed/WasMousePressed only work inside Move hooks, so from
-- Think the hotkey must edge-detect the held state manually.
local hotkeyWasDown = false

hook.Add("Think", "MMDVMDNPCCameraHotkey", function()
    retry_pending_activations()

    local key = math.floor(convar_number("mmd_vmd_npc_camera_key", 0))
    if key <= 0 then
        hotkeyWasDown = false
        return
    end

    -- DBinder can hand out mouse button codes as well as keyboard KEY_ codes.
    local down
    if MOUSE_FIRST and key >= MOUSE_FIRST then
        down = input.IsMouseDown and input.IsMouseDown(key) or false
    else
        down = input.IsKeyDown and input.IsKeyDown(key) or false
    end

    -- Do not toggle while UI could be consuming the key: main menu, any
    -- cursor-visible panel (spawn menu, addon menu, wheel — this also covers
    -- pressing the key inside the DBinder while binding it), chat, or a
    -- focused text field. The held state still updates below so closing the
    -- UI with the key held does not fire a spurious toggle.
    local suppressed = gui.IsGameUIVisible()
        or (vgui and vgui.CursorVisible and vgui.CursorVisible())
        or (vgui and vgui.GetKeyboardFocus and IsValid(vgui.GetKeyboardFocus()))
    if not suppressed then
        local ply = LocalPlayer()
        suppressed = IsValid(ply) and ply.IsTyping and ply:IsTyping() or false
    end

    if down and not hotkeyWasDown and not suppressed then
        MMDVMDNPC.ToggleCameraAnim()
    end
    hotkeyWasDown = down
end)
