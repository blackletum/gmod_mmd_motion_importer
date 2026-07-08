MMDVMDNPC = MMDVMDNPC or {}
MMDVMDNPC.Cache = MMDVMDNPC.Cache or {}
MMDVMDNPC.FlexAliases = MMDVMDNPC.FlexAliases or nil
MMDVMDNPC.FlexOverrides = MMDVMDNPC.FlexOverrides or nil
MMDVMDNPC.FlexOverrideUnassigned = MMDVMDNPC.FlexOverrideUnassigned or "__mmd_vmd_npc_unassigned__"

local EXPECTED_FORMAT = "mmd_vmd_npc_parent_corrected_axis_v1"
local FLEX_MAPPING_DATA_PATH = "mmd_vmd_npc/flex_mapping_table.json"
local FLEX_MAPPING_STATIC_PATH = "data_static/mmd_vmd_npc/flex_mapping_table.json"
local STATIC_MOTION_ROOT = "data_static/" .. MMDVMDNPC.MotionRoot
local FLEX_OVERRIDE_UNASSIGNED = MMDVMDNPC.FlexOverrideUnassigned

local function number_or(value, fallback)
    local out = tonumber(value)
    if out == nil then return fallback end
    return out
end

local function validate_key(raw, trackName)
    if not istable(raw) then
        return nil, "bad keyframe in " .. trackName
    end

    return {
        frame = number_or(raw[1], 0),
        x = number_or(raw[2], 0),
        y = number_or(raw[3], 0),
        z = number_or(raw[4], 0),
        px = number_or(raw[5], 0),
        py = number_or(raw[6], 0),
        pz = number_or(raw[7], 0),
    }
end

local function normalize_track(raw, index)
    if not istable(raw) then return nil, "bad bone track" end

    local source = tostring(raw.g or raw.target or raw.source or "")
    local mmd = tostring(raw.m or raw.mmd or "")
    if source == "" then
        return nil, "bone track has no target GMod bone: " .. mmd
    end

    local keys = {}
    for _, rawKey in ipairs(raw.k or raw.keys or {}) do
        local key, err = validate_key(rawKey, mmd ~= "" and mmd or source)
        if not key then return nil, err end
        keys[#keys + 1] = key
    end

    table.sort(keys, function(a, b) return a.frame < b.frame end)
    if #keys <= 0 then
        return nil, "bone track has no keyframes: " .. source
    end

    return {
        index = index,
        source = source,
        mmd = mmd,
        role = tostring(raw.role or ""),
        keys = keys,
    }
end

local function validate_flex_key(raw, trackName)
    if not istable(raw) then
        return nil, "bad flex keyframe in " .. trackName
    end

    return {
        frame = number_or(raw[1], 0),
        weight = math.Clamp(number_or(raw[2], 0), 0, 1),
    }
end

local function normalize_flex_track(raw, index)
    if not istable(raw) then return nil, "bad flex track" end

    local source = tostring(raw.g or raw.target or raw.source or raw.flex or "")
    local mmd = tostring(raw.m or raw.mmd or "")
    if source == "" then
        return nil, "flex track has no target Source flex: " .. mmd
    end

    local keys = {}
    for _, rawKey in ipairs(raw.k or raw.keys or {}) do
        local key, err = validate_flex_key(rawKey, mmd ~= "" and mmd or source)
        if not key then return nil, err end
        keys[#keys + 1] = key
    end

    table.sort(keys, function(a, b) return a.frame < b.frame end)
    if #keys <= 0 then
        return nil, "flex track has no keyframes: " .. source
    end

    return {
        index = index,
        source = source,
        mmd = mmd,
        keys = keys,
    }
end

local function normalize_flex_name(name)
    name = string.lower(tostring(name or ""))
    name = string.gsub(name, "[%s_%-]+", "")
    return name
end

local function exact_flex_on_entity(ent, flexName)
    if not IsValid(ent) or not ent.GetFlexNum or not ent.GetFlexName then return nil, nil end

    flexName = tostring(flexName or "")
    if flexName == "" then return nil, nil end

    local maxFlex = ent:GetFlexNum() or 0
    for flexID = 0, maxFlex - 1 do
        local current = tostring(ent:GetFlexName(flexID) or "")
        if current == flexName then
            return flexID, current
        end
    end

    local wantedLower = string.lower(flexName)
    for flexID = 0, maxFlex - 1 do
        local current = tostring(ent:GetFlexName(flexID) or "")
        if string.lower(current) == wantedLower then
            return flexID, current
        end
    end

    return nil, nil
end

function MMDVMDNPC.FindExactFlexOnEntity(ent, flexName)
    return exact_flex_on_entity(ent, flexName)
end

local function flex_override_model_key(modelPath)
    modelPath = string.lower(tostring(modelPath or ""))
    modelPath = string.gsub(modelPath, "\\", "/")
    return modelPath
end

function MMDVMDNPC.FlexOverrideModelKey(modelPath)
    return flex_override_model_key(modelPath)
end

function MMDVMDNPC.LoadFlexOverrides()
    if MMDVMDNPC.FlexOverrides then return MMDVMDNPC.FlexOverrides end

    local raw = file.Read(MMDVMDNPC.FlexOverridePath or (MMDVMDNPC.SettingsRoot .. "/flex_overrides.json"), "DATA")
    local parsed = raw and util.JSONToTable(raw) or nil
    MMDVMDNPC.FlexOverrides = istable(parsed) and parsed or {}
    return MMDVMDNPC.FlexOverrides
end

function MMDVMDNPC.SaveFlexOverrides()
    file.CreateDir(MMDVMDNPC.DataRoot)
    file.CreateDir(MMDVMDNPC.SettingsRoot)
    file.Write(
        MMDVMDNPC.FlexOverridePath or (MMDVMDNPC.SettingsRoot .. "/flex_overrides.json"),
        util.TableToJSON(MMDVMDNPC.LoadFlexOverrides(), false)
    )
end

function MMDVMDNPC.FlexOverrideForModel(modelPath, sourceName, mmdName)
    local modelKey = flex_override_model_key(modelPath)
    if modelKey == "" then return nil end

    local modelOverrides = MMDVMDNPC.LoadFlexOverrides()[modelKey]
    if not istable(modelOverrides) then return nil end

    sourceName = tostring(sourceName or "")
    mmdName = tostring(mmdName or "")

    local function lookup(map, key)
        if not istable(map) or key == "" then return nil end
        local value = map[key]
        if value ~= nil and tostring(value) ~= "" then return tostring(value) end
        return nil
    end

    return lookup(modelOverrides.by_mmd, mmdName)
        or lookup(modelOverrides.by_source, sourceName)
        or lookup(modelOverrides.by_mmd_norm, normalize_flex_name(mmdName))
        or lookup(modelOverrides.by_source_norm, normalize_flex_name(sourceName))
end

function MMDVMDNPC.SetFlexOverrideForModel(modelPath, mmdName, sourceName, flexName)
    local modelKey = flex_override_model_key(modelPath)
    flexName = tostring(flexName or "")
    mmdName = tostring(mmdName or "")
    sourceName = tostring(sourceName or "")

    if modelKey == "" or flexName == "" then return false end

    local overrides = MMDVMDNPC.LoadFlexOverrides()
    local modelOverrides = overrides[modelKey] or {}
    modelOverrides.by_mmd = istable(modelOverrides.by_mmd) and modelOverrides.by_mmd or {}
    modelOverrides.by_source = istable(modelOverrides.by_source) and modelOverrides.by_source or {}
    modelOverrides.by_mmd_norm = istable(modelOverrides.by_mmd_norm) and modelOverrides.by_mmd_norm or {}
    modelOverrides.by_source_norm = istable(modelOverrides.by_source_norm) and modelOverrides.by_source_norm or {}

    if mmdName ~= "" then
        modelOverrides.by_mmd[mmdName] = flexName
        modelOverrides.by_mmd_norm[normalize_flex_name(mmdName)] = flexName
    end
    if sourceName ~= "" then
        modelOverrides.by_source[sourceName] = flexName
        modelOverrides.by_source_norm[normalize_flex_name(sourceName)] = flexName
    end

    overrides[modelKey] = modelOverrides
    MMDVMDNPC.SaveFlexOverrides()
    return true
end

function MMDVMDNPC.SetFlexUnassignedForModel(modelPath, mmdName, sourceName)
    return MMDVMDNPC.SetFlexOverrideForModel(modelPath, mmdName, sourceName, FLEX_OVERRIDE_UNASSIGNED)
end

function MMDVMDNPC.ClearFlexOverrideForModel(modelPath, mmdName, sourceName)
    local modelKey = flex_override_model_key(modelPath)
    if modelKey == "" then return false end

    local overrides = MMDVMDNPC.LoadFlexOverrides()
    local modelOverrides = overrides[modelKey]
    if not istable(modelOverrides) then return false end

    mmdName = tostring(mmdName or "")
    sourceName = tostring(sourceName or "")

    if istable(modelOverrides.by_mmd) and mmdName ~= "" then
        modelOverrides.by_mmd[mmdName] = nil
    end
    if istable(modelOverrides.by_source) and sourceName ~= "" then
        modelOverrides.by_source[sourceName] = nil
    end
    if istable(modelOverrides.by_mmd_norm) and mmdName ~= "" then
        modelOverrides.by_mmd_norm[normalize_flex_name(mmdName)] = nil
    end
    if istable(modelOverrides.by_source_norm) and sourceName ~= "" then
        modelOverrides.by_source_norm[normalize_flex_name(sourceName)] = nil
    end

    MMDVMDNPC.SaveFlexOverrides()
    return true
end

function MMDVMDNPC.LoadFlexAliases()
    if MMDVMDNPC.FlexAliases then return MMDVMDNPC.FlexAliases end

    local aliases = {}
    local raw = file.Read(FLEX_MAPPING_DATA_PATH, "DATA")
    if not raw then
        raw = file.Read(FLEX_MAPPING_STATIC_PATH, "GAME")
    end

    local parsed = raw and util.JSONToTable(raw) or nil
    local rows = istable(parsed) and (istable(parsed.aliases) and parsed.aliases or parsed) or {}

    local function ingest_alias_row(values)
        if not istable(values) then return end
        if #values > 0 then
            local canonical = values[1]
            local row = aliases[canonical] or {}
            local seen = {}
            for _, value in ipairs(row) do
                seen[normalize_flex_name(value)] = true
            end
            for _, value in ipairs(values) do
                local key = normalize_flex_name(value)
                if key ~= "" and not seen[key] then
                    row[#row + 1] = value
                    seen[key] = true
                end
            end
            for _, value in ipairs(row) do
                aliases[value] = row
            end
            aliases[canonical] = row
        end
    end

    for _, values in ipairs(rows) do
        ingest_alias_row(values)
    end

    MMDVMDNPC.FlexAliases = aliases
    return aliases
end

function MMDVMDNPC.ResolveFlexID(ent, sourceName, mmdName)
    if not IsValid(ent) then return -1, "" end

    local candidates = {}
    local seen = {}
    local function add_candidate(name)
        name = tostring(name or "")
        local key = normalize_flex_name(name)
        if key ~= "" and not seen[key] then
            candidates[#candidates + 1] = name
            seen[key] = true
        end
    end

    if ent.GetModel and MMDVMDNPC.FlexOverrideForModel then
        local override = MMDVMDNPC.FlexOverrideForModel(ent:GetModel() or "", sourceName, mmdName)
        if override == FLEX_OVERRIDE_UNASSIGNED then return -1, "" end
        add_candidate(override)
    end
    add_candidate(sourceName)
    add_candidate(mmdName)
    local aliases = MMDVMDNPC.LoadFlexAliases()[tostring(sourceName or "")] or {}
    for _, alias in ipairs(aliases) do
        add_candidate(alias)
    end
    aliases = MMDVMDNPC.LoadFlexAliases()[tostring(mmdName or "")] or {}
    for _, alias in ipairs(aliases) do
        add_candidate(alias)
    end

    for _, name in ipairs(candidates) do
        local exactID, exactName = exact_flex_on_entity(ent, name)
        if exactID and exactID >= 0 then
            return exactID, exactName or name
        end
    end

    if ent.GetFlexIDByName then
        for _, name in ipairs(candidates) do
            local flexID = ent:GetFlexIDByName(name)
            if flexID and flexID >= 0 then
                local actualName = ent.GetFlexName and ent:GetFlexName(flexID) or nil
                return flexID, actualName or name
            end
        end
    end

    local normalizedCandidates = {}
    for _, name in ipairs(candidates) do
        normalizedCandidates[normalize_flex_name(name)] = true
    end

    if ent.GetFlexNum and ent.GetFlexName then
        for flexID = 0, (ent:GetFlexNum() or 0) - 1 do
            local flexName = ent:GetFlexName(flexID)
            if normalizedCandidates[normalize_flex_name(flexName)] then
                return flexID, flexName or ""
            end
        end
    end

    return -1, ""
end

-- Optional MMD camera track exported by the importer: entity-local eye
-- position (source units), local view angles (degrees) and vertical fov per
-- sampled key. Invalid tracks are dropped silently so old motions keep loading.
local MAX_CAMERA_KEYS = 20000

local function normalize_camera_track(raw)
    if not istable(raw) or not istable(raw.keys) then return nil end

    local keys = {}
    for _, rawKey in ipairs(raw.keys) do
        if istable(rawKey) then
            keys[#keys + 1] = {
                frame = math.max(0, math.floor(number_or(rawKey[1], 0))),
                x = number_or(rawKey[2], 0),
                y = number_or(rawKey[3], 0),
                z = number_or(rawKey[4], 0),
                p = number_or(rawKey[5], 0),
                yw = number_or(rawKey[6], 0),
                r = number_or(rawKey[7], 0),
                fov = math.Clamp(number_or(rawKey[8], 30), 1, 179),
            }
            if #keys >= MAX_CAMERA_KEYS then break end
        end
    end
    if #keys <= 0 then return nil end

    table.sort(keys, function(a, b) return a.frame < b.frame end)
    return {
        fps = math.max(1, math.floor(number_or(raw.fps, MMDVMDNPC.VMDFPS or 30))),
        frameStart = math.floor(number_or(raw.frame_start, keys[1].frame)),
        frameEnd = math.floor(number_or(raw.frame_end, keys[#keys].frame)),
        keyCount = #keys,
        keys = keys,
    }
end

local function motion_file_info(motionID)
    local path, id = MMDVMDNPC.MotionPath(motionID)
    if not path or not id then return nil end

    if file.Exists(path, "DATA") then
        return {
            id = id,
            path = path,
            realm = "DATA",
            isAddon = false,
            modified = file.Time(path, "DATA") or 0,
        }
    end

    local staticPath = STATIC_MOTION_ROOT .. "/" .. id .. MMDVMDNPC.CacheExtension
    if file.Exists(staticPath, "GAME") then
        return {
            id = id,
            path = staticPath,
            realm = "GAME",
            isAddon = true,
            modified = file.Time(staticPath, "GAME") or 0,
        }
    end

    return {
        id = id,
        path = path,
        realm = "DATA",
        isAddon = false,
        modified = 0,
    }
end

function MMDVMDNPC.MotionFileInfo(motionID)
    return motion_file_info(motionID)
end

local function read_motion_file(info)
    local path = info and info.path or ""
    local realm = info and info.realm or "DATA"
    local raw = file.Read(path, realm)
    if not raw then
        return nil, "motion json not found: " .. path
    end

    local parsed = util.JSONToTable(raw)
    if not istable(parsed) then
        return nil, "motion file is not valid JSON: " .. path
    end
    if parsed.format ~= EXPECTED_FORMAT then
        return nil, "unsupported motion JSON format: " .. tostring(parsed.format or "missing")
    end

    local motion = {
        format = parsed.format,
        fps = math.max(1, math.floor(number_or(parsed.fps, MMDVMDNPC.VMDFPS or 30))),
        frameStart = number_or(parsed.frame_start, 0),
        frameEnd = number_or(parsed.frame_end, 0),
        frameCount = math.max(1, math.floor(number_or(parsed.frame_count, 1))),
        displayName = tostring(parsed.display_name or parsed.motion_name or parsed.name or ""),
        sourceName = tostring(parsed.input_vmd or ""),
        sourcePath = tostring(parsed.baked_vmd or parsed.input_vmd or ""),
        modelPath = tostring(parsed.mmd_model or ""),
        isAddon = parsed.is_addon == true or (info and info.isAddon == true),
        filePath = path,
        fileRealm = realm,
        axis = parsed.axis or {},
        order = tostring(parsed.order or ""),
        columns = parsed.columns or {},
        music = istable(parsed.music) and {
            sound = tostring(parsed.music.sound or ""),
            sampleRate = number_or(parsed.music.sample_rate, 0),
            source = tostring(parsed.music.source or ""),
            offset = number_or(parsed.music.offset or parsed.music.default_offset, number_or(parsed.audio_offset, 0)),
        } or nil,
        defaultAudioOffset = number_or(parsed.audio_offset, istable(parsed.music) and number_or(parsed.music.offset or parsed.music.default_offset, 0) or 0),
        boneTracks = {},
        flexTracks = {},
        camera = normalize_camera_track(parsed.camera),
    }
    motion.duration = math.max(0, (motion.frameEnd - motion.frameStart) / motion.fps)

    local seenTargets = {}
    for index, rawTrack in ipairs(parsed.bones or {}) do
        local track, err = normalize_track(rawTrack, index)
        if not track then return nil, err end
        if seenTargets[track.source] then
            return nil, "motion JSON has duplicate target GMod bone: " .. track.source
        end
        seenTargets[track.source] = true
        motion.boneTracks[#motion.boneTracks + 1] = track
    end

    table.sort(motion.boneTracks, function(a, b)
        return (a.index or 0) < (b.index or 0)
    end)

    for index, rawTrack in ipairs(parsed.flexes or parsed.morphs or {}) do
        local track, err = normalize_flex_track(rawTrack, index)
        if not track then return nil, err end
        motion.flexTracks[#motion.flexTracks + 1] = track
    end

    table.sort(motion.flexTracks, function(a, b)
        return (a.index or 0) < (b.index or 0)
    end)

    return motion
end

function MMDVMDNPC.MotionMetadata(motionID)
    local info = motion_file_info(motionID)
    if not info then return nil, "invalid motion id" end

    local motion, err = MMDVMDNPC.LoadMotion(info.id)
    if not motion then return nil, err end

    return {
        id = info.id,
        fps = motion.fps or MMDVMDNPC.VMDFPS or 30,
        frameStart = motion.frameStart or 0,
        frameEnd = motion.frameEnd or 0,
        frameCount = motion.frameCount or 0,
        duration = motion.duration or 0,
        boneCount = #(motion.boneTracks or {}),
        flexCount = #(motion.flexTracks or {}),
        displayName = motion.displayName ~= "" and motion.displayName or id,
        sourceName = motion.sourceName or "",
        sourcePath = motion.sourcePath or "",
        modelPath = motion.modelPath or "",
        modified = file.Time(motion.filePath or info.path, motion.fileRealm or info.realm) or motion.modified or 0,
        isAddon = motion.isAddon == true,
        musicSound = motion.music and motion.music.sound or "",
        musicSource = motion.music and motion.music.source or "",
        musicSampleRate = motion.music and motion.music.sampleRate or 0,
        musicOffset = motion.defaultAudioOffset or (motion.music and motion.music.offset) or 0,
        hasCamera = motion.camera ~= nil,
    }
end

function MMDVMDNPC.ListMotions()
    local files = file.Find(MMDVMDNPC.MotionRoot .. "/*" .. MMDVMDNPC.CacheExtension, "DATA", "nameasc")
    local addonFiles = file.Find(STATIC_MOTION_ROOT .. "/*" .. MMDVMDNPC.CacheExtension, "GAME", "nameasc")
    local list = {}
    local seen = {}

    for _, name in ipairs(files or {}) do
        local id = MMDVMDNPC.NormalizeMotionID(name)
        if id and not seen[id] then
            seen[id] = true
            list[#list + 1] = id
        end
    end

    for _, name in ipairs(addonFiles or {}) do
        local id = MMDVMDNPC.NormalizeMotionID(name)
        if id and not seen[id] then
            seen[id] = true
            list[#list + 1] = id
        end
    end

    table.sort(list)
    return list
end

function MMDVMDNPC.LoadMotion(motionID)
    local info = motion_file_info(motionID)
    if not info then
        return nil, "invalid motion id"
    end

    local id = info.id
    local modified = info.modified or file.Time(info.path, info.realm) or 0
    local cached = MMDVMDNPC.Cache[id]
    if cached and cached.modified == modified and cached.path == info.path and cached.realm == info.realm then
        return cached.motion
    end

    local motion, err = read_motion_file(info)
    if not motion then return nil, err end

    motion.id = id
    motion.modified = modified
    MMDVMDNPC.Cache[id] = {
        modified = modified,
        path = info.path,
        realm = info.realm,
        motion = motion,
    }

    return motion
end

function MMDVMDNPC.ClearMotionCache()
    MMDVMDNPC.Cache = {}
end
