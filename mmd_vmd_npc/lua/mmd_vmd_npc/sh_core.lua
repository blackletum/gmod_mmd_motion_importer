MMDVMDNPC = MMDVMDNPC or {}

MMDVMDNPC.Version = 5
MMDVMDNPC.SupportedVersions = {
    [5] = true,
}

MMDVMDNPC.DataRoot = "mmd_vmd_npc"
MMDVMDNPC.MotionRoot = MMDVMDNPC.DataRoot .. "/motions"
MMDVMDNPC.BuiltRoot = MMDVMDNPC.DataRoot .. "/built"
MMDVMDNPC.SettingsRoot = MMDVMDNPC.DataRoot .. "/settings"
MMDVMDNPC.AudioOffsetPath = MMDVMDNPC.SettingsRoot .. "/audio_offsets.json"
MMDVMDNPC.FlexOverridePath = MMDVMDNPC.SettingsRoot .. "/flex_overrides.json"
MMDVMDNPC.CacheExtension = ".json"
MMDVMDNPC.BuiltFormat = "mmd_vmd_npc_built_v1"
MMDVMDNPC.VMDFPS = 30
MMDVMDNPC.DefaultFPS = 30
MMDVMDNPC.MinStartDelay = 2
MMDVMDNPC.DefaultStartDelay = 2
MMDVMDNPC.DefaultPelvisZOffset = -2.5
MMDVMDNPC.DefaultThirdPersonDistance = 120
MMDVMDNPC.DefaultThirdPersonHeight = 24
MMDVMDNPC.DefaultEyeTrackMode = "camera"
MMDVMDNPC.DefaultEyeTrackSmooth = 20
MMDVMDNPC.DefaultEyeTrackBoneMoveBack = 0.10
MMDVMDNPC.DefaultEyeTrackBonePosUD = 0.5
MMDVMDNPC.DefaultEyeTrackBonePosLR = 0.5
MMDVMDNPC.DefaultMusicEnabled = true
MMDVMDNPC.DefaultMusicVolume = 1
MMDVMDNPC.DefaultLoopPlayback = false
MMDVMDNPC.DefaultBuildFramesPerBatch = 16
MMDVMDNPC.MinBuildFramesPerBatch = 1
MMDVMDNPC.MaxBuildFramesPerBatch = 128
MMDVMDNPC.DefaultPlaybackHz = 120
MMDVMDNPC.MinPlaybackHz = 10
MMDVMDNPC.MaxPlaybackHz = 240
MMDVMDNPC.ReferenceFArmAngleThreshold = 20
MMDVMDNPC.ReferenceProbeRightUpperArm = "ValveBiped.Bip01_R_UpperArm"
MMDVMDNPC.ReferenceProbeRightForearm = "ValveBiped.Bip01_R_Forearm"

MMDVMDNPC.ForwardReferenceSequenceNames = {
    "Referencef",
    "referencef",
    "ReferenceF",
    "referenceF",
}

MMDVMDNPC.ReferenceSequenceCandidates = {
    {
        basis = "reference",
        names = { "Reference", "reference", "Ref", "ref" },
    },
    {
        basis = "idlenoise",
        names = { "Idlenoise", "idlenoise", "IdleNoise", "idle_noise" },
    },
    {
        basis = "reference",
        names = { "idle_all_01", "Idle_All_01", "idle", "Idle01" },
    },
}

MMDVMDNPC.RequiredReferenceSequenceNames = {
    "Reference",
    "reference",
}

local function setup_reference_bones_now(ent)
    if not IsValid(ent) then return end
    if ent.InvalidateBoneCache then ent:InvalidateBoneCache() end
    if ent.SetupBones then ent:SetupBones() end
end

local function exact_sequence_lookup(ent, requestedName)
    if not IsValid(ent) or not requestedName then return nil end

    local requested = tostring(requestedName)
    local requestedLower = string.lower(requested)
    local caseInsensitiveMatch

    if ent.GetSequenceCount and ent.GetSequenceName then
        local okCount, count = pcall(ent.GetSequenceCount, ent)
        count = okCount and tonumber(count) or nil
        if count and count > 0 then
            for seq = 0, count - 1 do
                local okName, sequenceName = pcall(ent.GetSequenceName, ent, seq)
                sequenceName = okName and tostring(sequenceName or "") or ""
                if sequenceName == requested then
                    return seq, sequenceName, true
                elseif sequenceName ~= "" and not caseInsensitiveMatch and string.lower(sequenceName) == requestedLower then
                    caseInsensitiveMatch = { seq = seq, name = sequenceName }
                end
            end
        end

        if caseInsensitiveMatch then
            return caseInsensitiveMatch.seq, caseInsensitiveMatch.name, true
        end

        if count then
            return nil, nil, true
        end
    end

    return nil, nil, false
end

local function lookup_sequence_info_from_names(ent, names, basis, extra)
    if not IsValid(ent) or not ent.LookupSequence then return nil end

    for _, name in ipairs(names or {}) do
        local seq, exactName, exactEnumerationAvailable = exact_sequence_lookup(ent, name)
        if not seq and not (istable(extra) and extra.exactOnly == true and exactEnumerationAvailable) then
            seq = ent:LookupSequence(name)
        end
        if seq and seq >= 0 then
            local actualName = exactName or name
            if not exactName and ent.GetSequenceName then
                local ok, sequenceName = pcall(ent.GetSequenceName, ent, seq)
                if ok and sequenceName and sequenceName ~= "" then actualName = sequenceName end
            end
            local info = {
                seq = seq,
                name = actualName,
                displayName = name,
                lookupName = name,
                actualName = actualName,
                basis = basis or "reference",
            }
            if istable(extra) then
                for key, value in pairs(extra) do
                    if key ~= "exactOnly" then
                        info[key] = value
                    end
                end
            end
            return info
        end
    end

    return nil
end

local function set_sequence_for_reference_probe(ent, seq)
    if not IsValid(ent) or not seq or seq < 0 then return false end

    if ent.SetSequence then ent:SetSequence(seq) end
    if ent.ResetSequence then
        ent:ResetSequence(seq)
    end
    if ent.ResetSequenceInfo then ent:ResetSequenceInfo() end
    if ent.SetCycle then ent:SetCycle(0) end
    if ent.SetPlaybackRate then ent:SetPlaybackRate(0) end
    if ent.SetIK then ent:SetIK(false) end
    if ent.FrameAdvance then ent:FrameAdvance(0) end
    setup_reference_bones_now(ent)
    return true
end

local function bone_world_position_for_reference_probe(ent, bone)
    local matrix = ent.GetBoneMatrix and ent:GetBoneMatrix(bone) or nil
    if matrix then return matrix:GetTranslation() end

    if ent.GetBonePosition then
        local pos = ent:GetBonePosition(bone)
        if pos then return pos end
    end

    return nil
end

local function reference_probe_angle_for_sequence(ent, seq)
    if not IsValid(ent) or not ent.LookupBone or not seq or seq < 0 then return nil end

    local previousSeq = ent.GetSequence and ent:GetSequence() or nil
    local previousCycle = ent.GetCycle and ent:GetCycle() or nil
    set_sequence_for_reference_probe(ent, seq)

    local upperArm = ent:LookupBone(MMDVMDNPC.ReferenceProbeRightUpperArm)
    local forearm = ent:LookupBone(MMDVMDNPC.ReferenceProbeRightForearm)
    local angle = nil

    if upperArm and upperArm >= 0 and forearm and forearm >= 0 then
        local upperPos = bone_world_position_for_reference_probe(ent, upperArm)
        local forearmPos = bone_world_position_for_reference_probe(ent, forearm)
        if upperPos and forearmPos then
            local armVector = forearmPos - upperPos
            if armVector:LengthSqr() > 0.000001 then
                armVector:Normalize()
                local modelNegZ = (ent.GetUp and ent:GetUp() or Vector(0, 0, 1)) * -1
                if modelNegZ:LengthSqr() <= 0.000001 then modelNegZ = Vector(0, 0, -1) end
                modelNegZ:Normalize()

                angle = math.deg(math.acos(math.Clamp(armVector:Dot(modelNegZ), -1, 1)))
            end
        end
    end

    if previousSeq and previousSeq >= 0 then
        set_sequence_for_reference_probe(ent, previousSeq)
        if previousCycle and ent.SetCycle then ent:SetCycle(previousCycle) end
        setup_reference_bones_now(ent)
    end

    return angle
end

function MMDVMDNPC.ReferenceSequenceNeedsReferenceF(ent, referenceInfo)
    if not istable(referenceInfo) or tostring(referenceInfo.basis or "") ~= "reference" then return false, nil end
    local angle = reference_probe_angle_for_sequence(ent, referenceInfo.seq)
    if not angle then return false, nil end
    return angle < (MMDVMDNPC.ReferenceFArmAngleThreshold or 20), angle
end

function MMDVMDNPC.ResolveAdaptiveReferenceSequenceInfo(ent, referenceInfo, required)
    if not istable(referenceInfo) then return nil end

    local needsReferenceF, angle = MMDVMDNPC.ReferenceSequenceNeedsReferenceF(ent, referenceInfo)
    referenceInfo.armAxisAngle = angle
    referenceInfo.referenceProbeArmAxisAngle = angle
    if not needsReferenceF then return referenceInfo end

    local forwardInfo = lookup_sequence_info_from_names(ent, MMDVMDNPC.ForwardReferenceSequenceNames, "reference", {
        required = required == true,
        exactOnly = true,
        adaptiveReference = true,
        fallbackFrom = referenceInfo.name or referenceInfo.lookupName or "Reference",
        fallbackFromDisplayName = referenceInfo.displayName or referenceInfo.lookupName or referenceInfo.name or "Reference",
        fallbackFromSeq = referenceInfo.seq or -1,
        armAxisAngle = angle,
        referenceProbeArmAxisAngle = angle,
    })
    if forwardInfo then return forwardInfo end

    local message = string.format(
        "Selected NPC/player uses a Reference pose with right-arm angle %.3f degrees, so Referencef is required but was not found.",
        tonumber(angle) or 0
    )
    return nil, message
end

function MMDVMDNPC.LookupRequiredReferenceSequenceInfo(ent)
    local info = lookup_sequence_info_from_names(ent, MMDVMDNPC.RequiredReferenceSequenceNames, "reference", { required = true, exactOnly = true })
    if not info then return nil end
    return MMDVMDNPC.ResolveAdaptiveReferenceSequenceInfo(ent, info, true)
end

function MMDVMDNPC.LookupReferenceSequenceInfo(ent)
    if not IsValid(ent) or not ent.LookupSequence then return nil end

    for _, candidate in ipairs(MMDVMDNPC.ReferenceSequenceCandidates or {}) do
        local info = lookup_sequence_info_from_names(ent, candidate.names, candidate.basis or "reference")
        if info then
            local resolved, err = MMDVMDNPC.ResolveAdaptiveReferenceSequenceInfo(ent, info, false)
            if resolved or err then return resolved, err end
        end
    end

    local idleSeq = ent.SelectWeightedSequence and ent:SelectWeightedSequence(ACT_IDLE) or -1
    if idleSeq and idleSeq >= 0 then
        local actualName = "ACT_IDLE"
        if ent.GetSequenceName then
            local ok, sequenceName = pcall(ent.GetSequenceName, ent, idleSeq)
            if ok and sequenceName and sequenceName ~= "" then actualName = sequenceName end
        end
        return {
            seq = idleSeq,
            name = actualName,
            displayName = actualName,
            lookupName = "ACT_IDLE",
            actualName = actualName,
            basis = "reference",
        }
    end

    local currentSeq = ent.GetSequence and (ent:GetSequence() or 0) or 0
    local currentName = "current"
    if ent.GetSequenceName then
        local ok, sequenceName = pcall(ent.GetSequenceName, ent, currentSeq)
        if ok and sequenceName and sequenceName ~= "" then currentName = sequenceName end
    end
    return {
        seq = currentSeq,
        name = currentName,
        displayName = currentName,
        lookupName = "current",
        actualName = currentName,
        basis = "reference",
    }
end

function MMDVMDNPC.LookupReferenceSequence(ent)
    local info = MMDVMDNPC.LookupReferenceSequenceInfo(ent)
    return info and info.seq or -1
end

function MMDVMDNPC.ReferenceSequenceDisplayName(info)
    if not istable(info) then return "" end
    return tostring(info.displayName or info.lookupName or info.name or "")
end

function MMDVMDNPC.ReferenceSequenceAxisText(info)
    local basis = istable(info) and tostring(info.basis or "") or tostring(info or "")
    if basis == "idlenoise" then
        return "Idlenoise axes: +Y front, +X left, +Z up"
    end
    return "Reference axes: +X front, -Y left, +Z up"
end

MMDVMDNPC.I18N = MMDVMDNPC.I18N or {}
MMDVMDNPC.I18N.en = {
    ["mmd_vmd_npc.category"] = "Animation",
    ["tool.mmd_vmd_npc.name"] = "Advanced MMD Animation Player",
    ["tool.mmd_vmd_npc.desc"] = "Play MMD animation on NPCs or yourself",
    ["tool.mmd_vmd_npc.0"] = "Use the key rows below for MMD VMD animation actions.",
    ["tool.mmd_vmd_npc.left"] = "Assign selected animation to clicked NPC",
    ["tool.mmd_vmd_npc.left_use"] = "Start animation for all selected NPCs together",
    ["tool.mmd_vmd_npc.left_speed"] = "Build assigned animations for selected NPCs",
    ["tool.mmd_vmd_npc.left_alt"] = "Align selected NPCs to the first NPC",
    ["tool.mmd_vmd_npc.reload_alt"] = "Stop all active NPC playback",
    ["tool.mmd_vmd_npc.right"] = "Pause/resume playback",
    ["tool.mmd_vmd_npc.right_speed"] = "Open motion and flex assignment menu on clicked or last selected actor",
    ["tool.mmd_vmd_npc.middle_speed"] = "Align selected NPCs to the first NPC",
    ["tool.mmd_vmd_npc.right_speed_use"] = "+ E: align selected NPCs to the first NPC",
    ["tool.mmd_vmd_npc.reload"] = "Select yourself and assign animation",
    ["tool.mmd_vmd_npc.reload_use"] = "Play selected motion on yourself",
    ["tool.mmd_vmd_npc.reload_speed"] = "Build selected motion for yourself",

    ["mmd_vmd_npc.error.left_click_valid_npc"] = "left-click a valid NPC for a coordinated dance selection",
    ["mmd_vmd_npc.error.select_motion"] = "Please select a motion JSON first",
    ["mmd_vmd_npc.error.shift_right_click_valid_actor"] = "shift-right-click a valid NPC/player",
    ["mmd_vmd_npc.error.build_self_first"] = "build this motion for your playermodel first",
    ["mmd_vmd_npc.error.no_imported_music"] = "Note: Selected motion has no imported music.",
    ["mmd_vmd_npc.error.missing_reference_sequence"] = "Selected NPC/player has no Reference sequence. This model is not supported yet.",
    ["mmd_vmd_npc.status.actor_playermodel"] = "playermodel",
    ["mmd_vmd_npc.status.actor_npc"] = "NPC",
    ["mmd_vmd_npc.status.actor_generic"] = "actor",
    ["mmd_vmd_npc.status.actor_select_prompt"] = "left-click a valid NPC/player, press R to select yourself, Shift+R to build yourself, or E+R to play yourself",
    ["mmd_vmd_npc.status.invalid_player"] = "invalid player",
    ["mmd_vmd_npc.status.selected_actor_fmt"] = "selected %s %s",
    ["mmd_vmd_npc.status.ai_disabled_required"] = "AI thinking must be disabled: run ai_disabled 1 before building or playing MMD VMD animations",
    ["mmd_vmd_npc.status.build_missing_instruction"] = " Use Shift + left click to build the selected NPC animation(s).",
    ["mmd_vmd_npc.status.built_cache_missing_options"] = "built cache missing for selected model/options.",
    ["mmd_vmd_npc.status.build_missing_group_fmt"] = "build missing before coordinated playback: %s.",
    ["mmd_vmd_npc.status.no_valid_selected_npcs"] = "no valid selected NPCs to play",
    ["mmd_vmd_npc.status.group_countdown_fmt"] = "coordinated playback starts on %d NPC(s) in %.1f seconds",
    ["mmd_vmd_npc.status.started_group_fmt"] = "started %d coordinated playback(s)",
    ["mmd_vmd_npc.status.select_npcs_before_group_play"] = "select one or more NPCs before starting a coordinated dance",
    ["mmd_vmd_npc.status.select_first_npc_align"] = "select a first NPC before aligning coordinated dance NPCs",
    ["mmd_vmd_npc.status.aligned_selected_npcs_fmt"] = "aligned %d selected NPC(s) to first NPC",
    ["mmd_vmd_npc.status.select_npcs_before_build"] = "select one or more NPCs before building selected NPC animations",
    ["mmd_vmd_npc.status.started_queued_builds_fmt"] = "started or queued %d build(s); %d already built",
    ["mmd_vmd_npc.status.failed_suffix"] = "; failed: ",
    ["mmd_vmd_npc.status.all_builds_exist_fmt"] = "all selected NPC animation builds already exist (%d)",
    ["mmd_vmd_npc.status.no_selected_build_needed"] = "no selected NPCs needed a build",
    ["mmd_vmd_npc.status.removed_npc_selection"] = "removed NPC from coordinated dance selection",
    ["mmd_vmd_npc.status.invalid_motion_id"] = "invalid motion id",
    ["mmd_vmd_npc.status.assigned_motion_to_npc_fmt"] = "assigned %s to NPC %s",
    ["mmd_vmd_npc.status.built_cache_exists"] = "built cache already exists",
    ["mmd_vmd_npc.status.built_cache_exists_skip_fmt"] = "Built animation already exists for this model/options; skipping build: %s",
    ["mmd_vmd_npc.status.build_already_fmt"] = "build already %s",
    ["mmd_vmd_npc.status.assigned_motion_missing_build"] = "assigned motion; built cache is missing.",
    ["mmd_vmd_npc.status.referencef_build_warning_fmt"] = "Warning: model %s uses %s instead of the standard A-pose Reference sequence. This addon might not fully support building animation for this model.",
    ["mmd_vmd_npc.status.no_active_selected_playback_pause"] = "no active selected playback to pause",
    ["mmd_vmd_npc.status.no_active_playback_pause"] = "no active playback to pause",
    ["mmd_vmd_npc.status.coordinated_playback_paused"] = "coordinated playback paused",
    ["mmd_vmd_npc.status.coordinated_playback_resumed"] = "coordinated playback resumed",
    ["mmd_vmd_npc.status.self_playback_force_reset"] = "Self playback reset; normal view restored",
    ["mmd_vmd_npc.hint.self_keys"] = "Press R with the tool equipped to assign animation to yourself, Shift+R to build it, and E+R to play yourself.",
    ["mmd_vmd_npc.console.no_motions"] = "No motion files found.",
    ["mmd_vmd_npc.console.motion_files"] = "Imported Motion files:",
    ["mmd_vmd_npc.console.failed_preview_music_fmt"] = "Failed to preview music: %s",
    ["mmd_vmd_npc.console.failed_play_music_fmt"] = "Failed to play music %s: %s",
    ["mmd_vmd_npc.console.debug_failed_fmt"] = "Debug failed for %s: %s",
    ["mmd_vmd_npc.console.build_success_fmt"] = "Built animation: %s",
    ["mmd_vmd_npc.console.build_failed_fmt"] = "Build animation failed: %s",
    ["mmd_vmd_npc.console.build_cancelled_fmt"] = "Build task(s) cancelled: active %d, queued %d",
    ["mmd_vmd_npc.console.built_removed_fmt"] = "built caches removed: %s",
    ["mmd_vmd_npc.console.music_removed_fmt"] = "music removed: %s",
    ["mmd_vmd_npc.console.music_checked_fmt"] = "music checked: %s",
    ["mmd_vmd_npc.console.debug_usage"] = "Usage: mmdvmd_debug <motion_id> [frame]",
    ["mmd_vmd_npc.warning.build_lag_fmt"] = "Building '%s' will process %d frame(s). Your gamemay briefly lag or freeze until the progress bar finishes.",
    ["mmd_vmd_npc.hud.build_queued"] = "Animation build queued",
    ["mmd_vmd_npc.hud.countdown"] = "Estimated time remaining",
    ["mmd_vmd_npc.hud.build"] = "Building Animation: Computing Bone Rotation Quaternion Tensors",

    ["mmd_vmd_npc.ui.tool_help"] = "The motion files are generated by the motion importer in garrysmod/data/mmd_vmd_npc/motions. Left-click an NPC to assign. Shift+left-click builds selected NPCs. E+left-click starts all selected NPCs together. Alt+R stops all NPC playback. Right-click pauses/resumes playback. Shift+middle-click aligns selected NPCs to the first NPC. R selects yourself and assigns the current animation. Shift+R builds yourself. E+R plays yourself.",
    ["mmd_vmd_npc.ui.tab.motion"] = "Motion",
    ["mmd_vmd_npc.ui.tab.build_playback"] = "Build & Playback",
    ["mmd_vmd_npc.ui.tab.performance"] = "Performance",
    ["mmd_vmd_npc.ui.tab.advanced"] = "Advanced",
    ["mmd_vmd_npc.ui.selected_motion_none"] = "Selected motion: none",
    ["mmd_vmd_npc.ui.selected_motion_fmt"] = "Selected motion: %s",
    ["mmd_vmd_npc.ui.pause_warning_fmt"] = "Warning: sv_pause=%s and sv_pause_sp=%s. Set both to 0 before building or playing animations.",
    ["mmd_vmd_npc.ui.music_offset"] = "Music offset (seconds)",
    ["mmd_vmd_npc.ui.play_imported_music"] = "Play imported music",
    ["mmd_vmd_npc.ui.play_imported_music_help"] = "Controls whether the selected motion's imported music plays the next time playback starts.",
    ["mmd_vmd_npc.ui.music_volume"] = "Music volume",
    ["mmd_vmd_npc.ui.loop_playback"] = "Loop animation and music",
    ["mmd_vmd_npc.ui.loop_playback_help"] = "When enabled, the animation restarts from the first frame and imported music restarts when the motion ends.",
    ["mmd_vmd_npc.ui.column.motion"] = "Motion",
    ["mmd_vmd_npc.ui.column.duration"] = "Duration",
    ["mmd_vmd_npc.ui.column.addon"] = "From Addon",
    ["mmd_vmd_npc.ui.loading"] = "loading",
    ["mmd_vmd_npc.ui.missing"] = "missing",
    ["mmd_vmd_npc.ui.open_motion_manager"] = "Open Motion Manager",
    ["mmd_vmd_npc.ui.refresh_motion_list"] = "Refresh Motion List",
    ["mmd_vmd_npc.ui.motion_no_metadata"] = "Motion: no metadata loaded",
    ["mmd_vmd_npc.ui.target"] = "Target",
    ["mmd_vmd_npc.ui.selected_actor_none"] = "Selected actor: none",
    ["mmd_vmd_npc.ui.selected_actor_fmt"] = "Selected %s: %s | %s",
    ["mmd_vmd_npc.ui.coordinated_npcs_zero"] = "Coordinated NPCs: 0",
    ["mmd_vmd_npc.ui.coordinated_npcs_fmt"] = "Coordinated NPCs: %d | first: %s | motion: %s | status: %s",
    ["mmd_vmd_npc.ui.play_selected_group"] = "Play Selected Group",
    ["mmd_vmd_npc.ui.clear_selection"] = "Clear Selection",
    ["mmd_vmd_npc.ui.clear_missing_invalid"] = "Clear Missing/Invalid",
    ["mmd_vmd_npc.ui.select_yourself"] = "Select Yourself",
    ["mmd_vmd_npc.ui.self_help"] = "Left-click an NPC/player to select it. R selects yourself and assigns the current animation; Shift+R builds it for yourself; E+R plays yourself through a temporary proxy model.",
    ["mmd_vmd_npc.ui.build"] = "Build",
    ["mmd_vmd_npc.ui.build_idle"] = "Build: idle",
    ["mmd_vmd_npc.ui.build_status_fmt"] = "Build: %s",
    ["mmd_vmd_npc.ui.build_selected_motion"] = "Build Selected Motion",
    ["mmd_vmd_npc.ui.stop_build_tasks"] = "Stop All Build Tasks",
    ["mmd_vmd_npc.ui.stop_stuck_build_tasks"] = "Stop Build Tasks (Use If Stuck)",
    ["mmd_vmd_npc.ui.playback"] = "Playback",
    ["mmd_vmd_npc.ui.playback_idle"] = "Playback: idle",
    ["mmd_vmd_npc.ui.playback_status_fmt"] = "Playback: %s",
    ["mmd_vmd_npc.ui.play_built_animation"] = "Play Built Animation",
    ["mmd_vmd_npc.ui.stop_animation"] = "Stop Animation",
    ["mmd_vmd_npc.ui.force_reset_self_view"] = "Force Reset Self Playback / View",
    ["mmd_vmd_npc.ui.start_delay"] = "Start delay (seconds, min 2)",
    ["mmd_vmd_npc.ui.pelvis_z_offset"] = "Pelvis Z playback offset",
    ["mmd_vmd_npc.ui.thirdperson_distance"] = "Self thirdperson distance",
    ["mmd_vmd_npc.ui.thirdperson_height"] = "Self thirdperson height",
    ["mmd_vmd_npc.ui.eye_tracking"] = "Eye Tracking",
    ["mmd_vmd_npc.ui.enable_eye_tracking"] = "Enable eye tracking",
    ["mmd_vmd_npc.ui.enable_eye_tracking_help"] = "When enabled, the animated character's eye bones track the current player's view during playback.",
    ["mmd_vmd_npc.ui.eye_smoothing"] = "Smoothing speed",
    ["mmd_vmd_npc.ui.eye_moveback"] = "Eye bone moveback factor",
    ["mmd_vmd_npc.ui.eye_pos_ud"] = "Eye bone pos scale (Up/Down)",
    ["mmd_vmd_npc.ui.eye_pos_lr"] = "Eye bone pos scale (Left/Right)",
    ["mmd_vmd_npc.ui.eye_no_target"] = "Eye bones: no playback target",
    ["mmd_vmd_npc.ui.eye_status_unavailable"] = "Eye bones: status unavailable",
    ["mmd_vmd_npc.ui.audio_sync"] = "Audio Sync",
    ["mmd_vmd_npc.ui.audio_sync_help"] = "Open Motion Manager to preview music, save per-motion audio offsets, and manage built caches.",
    ["mmd_vmd_npc.ui.manage_built_cache"] = "Manage Built Cache",
    ["mmd_vmd_npc.ui.clear_built_model"] = "Clear Built For Selected Model",
    ["mmd_vmd_npc.ui.clear_built_all"] = "Clear Built For All Models",
    ["mmd_vmd_npc.ui.build_performance"] = "Build Performance",
    ["mmd_vmd_npc.ui.build_performance_help"] = "Higher build batch values finish builds faster, but can briefly stall the client while the hidden model computes more frames at once.",
    ["mmd_vmd_npc.ui.build_frames_per_batch"] = "Build frames per batch",
    ["mmd_vmd_npc.ui.playback_performance"] = "Playback Performance",
    ["mmd_vmd_npc.ui.playback_performance_help"] = "Higher playback update rates make motion interpolation smoother. Lower values reduce server/client work.",
    ["mmd_vmd_npc.ui.playback_updates_per_second"] = "Playback updates per second",
    ["mmd_vmd_npc.ui.disable_armtwist"] = "Disable ZArmTwist transforms",
    ["mmd_vmd_npc.ui.disable_handtwist"] = "Disable hand twist transforms",
    ["mmd_vmd_npc.ui.disable_eyes"] = "Disable eye transforms",
    ["mmd_vmd_npc.ui.disable_spine_pelvis"] = "Disable pelvis/spine correction",
    ["mmd_vmd_npc.ui.debug_selected_motion"] = "Debug Selected Motion",
    ["mmd_vmd_npc.ui.motion_info_fmt"] = "Motion: %s | %.2fs | %d frame(s) | %d bone(s) | %d flex(es) | music: %s | built: %s",
    ["mmd_vmd_npc.ui.motion_metadata_missing_fmt"] = "Motion: %s | metadata not loaded",
    ["mmd_vmd_npc.ui.motion_none"] = "Motion: none",
    ["mmd_vmd_npc.ui.yes"] = "yes",
    ["mmd_vmd_npc.ui.no"] = "no",
    ["mmd_vmd_npc.ui.none"] = "none",
    ["mmd_vmd_npc.ui.not_found"] = "not found",
    ["mmd_vmd_npc.ui.unknown"] = "unknown",
    ["mmd_vmd_npc.ui.actor"] = "actor",
    ["mmd_vmd_npc.ui.idle"] = "idle",
    ["mmd_vmd_npc.ui.motion"] = "motion",
    ["mmd_vmd_npc.ui.built"] = "built",
    ["mmd_vmd_npc.ui.eye_status_none"] = "Eye bones: no playback target",
    ["mmd_vmd_npc.ui.eye_status_fmt"] = "Eye bones: L=%s | R=%s",
    ["mmd_vmd_npc.ui.eye_bone_fmt"] = "%s (#%d)",

    ["mmd_vmd_npc.debug.title_fmt"] = "Raw Animation Debug - %s",
    ["mmd_vmd_npc.debug.summary_fmt"] = "%s | frame %d / %d | %.3fs / %.3fs | %d animation bone(s) | %d flex(es)%s",
    ["mmd_vmd_npc.debug.selected_model_fmt"] = "Selected model: %s",
    ["mmd_vmd_npc.debug.selected_model_none"] = "Selected model: none",
    ["mmd_vmd_npc.debug.preview_entity_fmt"] = " | preview ent %s",
    ["mmd_vmd_npc.debug.reference_fmt"] = " | reference: %s",
    ["mmd_vmd_npc.debug.column_mmd_bone"] = "MMD Bone Name",
    ["mmd_vmd_npc.debug.column_source_bone"] = "Assigned Bone",
    ["mmd_vmd_npc.debug.column_role"] = "Role",
    ["mmd_vmd_npc.debug.column_raw_x"] = "Raw +X Left",
    ["mmd_vmd_npc.debug.column_raw_y"] = "Raw +Y Front",
    ["mmd_vmd_npc.debug.column_raw_z"] = "Raw +Z Top",
    ["mmd_vmd_npc.debug.column_bone_position"] = "Bone Position (X, Y, Z)",
    ["mmd_vmd_npc.debug.column_manip_angles"] = "Local ManipulateBoneAngles (P, Y, R)",
    ["mmd_vmd_npc.debug.column_mmd_morph"] = "MMD Morph Name",
    ["mmd_vmd_npc.debug.column_source_flex"] = "Assigned Flex",
    ["mmd_vmd_npc.debug.column_weight"] = "Weight",
    ["mmd_vmd_npc.debug.column_scaled_weight"] = "Scaled Weight",
    ["mmd_vmd_npc.debug.column_target"] = "Target",
    ["mmd_vmd_npc.debug.previous"] = "Previous",
    ["mmd_vmd_npc.debug.jump"] = "Jump",
    ["mmd_vmd_npc.debug.vmd_frame"] = "VMD frame",
    ["mmd_vmd_npc.debug.next"] = "Next",
    ["mmd_vmd_npc.debug.refresh"] = "Refresh",
    ["mmd_vmd_npc.debug.play_preview"] = "Play",
    ["mmd_vmd_npc.debug.pause_preview"] = "Pause",
    ["mmd_vmd_npc.debug.flex_mapping"] = "Manual flex mapping",
    ["mmd_vmd_npc.debug.unresolved_morph"] = "Unresolved morph",
    ["mmd_vmd_npc.debug.motion_flex"] = "Motion morph/flex track",
    ["mmd_vmd_npc.debug.model_flex"] = "Model flex",
    ["mmd_vmd_npc.debug.assign_flex"] = "Assign Flex",
    ["mmd_vmd_npc.debug.unassign_flex"] = "Unassign Flex",
    ["mmd_vmd_npc.debug.clear_flex_mapping"] = "Clear Mapping",
    ["mmd_vmd_npc.debug.no_unresolved_flex"] = "No unresolved flexes",
    ["mmd_vmd_npc.debug.no_motion_flex"] = "No motion flexes",
    ["mmd_vmd_npc.debug.no_model_flex"] = "No model flexes",
    ["mmd_vmd_npc.debug.flex_scale_all"] = "All flex scale",
    ["mmd_vmd_npc.debug.flex_scale_eye"] = "Eye flex scale",
    ["mmd_vmd_npc.debug.flex_scale_brow"] = "Brow flex scale",
    ["mmd_vmd_npc.debug.flex_scale_mouth"] = "Mouth flex scale",

    ["mmd_vmd_npc.manager.title"] = "Motion Manager",
    ["mmd_vmd_npc.manager.search_placeholder"] = "Search motion id, source, or music",
    ["mmd_vmd_npc.manager.refresh"] = "Refresh",
    ["mmd_vmd_npc.manager.column_motion_id"] = "Motion ID",
    ["mmd_vmd_npc.manager.column_duration"] = "Duration",
    ["mmd_vmd_npc.manager.column_frames"] = "Frames",
    ["mmd_vmd_npc.manager.column_bones"] = "Bones",
    ["mmd_vmd_npc.manager.column_flexes"] = "Flexes",
    ["mmd_vmd_npc.manager.column_music"] = "Music",
    ["mmd_vmd_npc.manager.column_addon"] = "From Addon",
    ["mmd_vmd_npc.manager.column_built"] = "Built",
    ["mmd_vmd_npc.manager.select_motion_details"] = "Select a motion to view details.",
    ["mmd_vmd_npc.manager.details_fmt"] = "%s\nFPS %s | frames %s-%s | duration %.2fs | bones %s | flexes %s | music %s | source %s",
    ["mmd_vmd_npc.manager.play_music"] = "Play music",
    ["mmd_vmd_npc.manager.volume"] = "Volume",
    ["mmd_vmd_npc.manager.audio_offset_help"] = "Audio offset seconds. Positive starts music later; negative starts music advanced.",
    ["mmd_vmd_npc.manager.preview_music_only"] = "Preview Music Only",
    ["mmd_vmd_npc.manager.preview_motion"] = "Preview Motion",
    ["mmd_vmd_npc.manager.stop_music"] = "Stop Music",
    ["mmd_vmd_npc.manager.save_offset"] = "Save Offset",
    ["mmd_vmd_npc.manager.debug"] = "Debug",
    ["mmd_vmd_npc.manager.build_selected"] = "Build Selected",
    ["mmd_vmd_npc.manager.play_built"] = "Play Built",
    ["mmd_vmd_npc.manager.stop"] = "Stop",
    ["mmd_vmd_npc.manager.clear_this_model"] = "Clear This Model",
    ["mmd_vmd_npc.manager.clear_all_models"] = "Clear All Models For Motion",
    ["mmd_vmd_npc.manager.delete_motion_music"] = "Delete Motion + Music",
    ["mmd_vmd_npc.manager.delete_prompt_fmt"] = "Delete '%s' from data/mmd_vmd_npc/motions and remove its imported music when possible?",
    ["mmd_vmd_npc.manager.delete_title"] = "Delete MMD VMD Motion",
    ["mmd_vmd_npc.manager.delete_confirm"] = "Delete",
    ["mmd_vmd_npc.manager.cancel"] = "Cancel",
}

local function merge_i18n(overrides)
    local merged = {}
    for key, text in pairs(MMDVMDNPC.I18N.en or {}) do
        merged[key] = text
    end
    for key, text in pairs(overrides or {}) do
        merged[key] = text
    end
    return merged
end

MMDVMDNPC.I18N.zh = merge_i18n({
    ["mmd_vmd_npc.category"] = "动画",
    ["tool.mmd_vmd_npc.name"] = "高级 MMD 动画播放器",
    ["tool.mmd_vmd_npc.desc"] = "在 NPC 或自己身上播放 MMD 动画",
    ["tool.mmd_vmd_npc.0"] = "请参考下方按键说明使用 MMD VMD 动画工具。",
    ["tool.mmd_vmd_npc.left"] = "为点击的 NPC 分配所选动画",
    ["tool.mmd_vmd_npc.left_use"] = "同时开始所有已选 NPC 的动画",
    ["tool.mmd_vmd_npc.left_speed"] = "为已选 NPC 构建已分配动画",
    ["tool.mmd_vmd_npc.left_alt"] = "将已选 NPC 对齐到第一个 NPC",
    ["tool.mmd_vmd_npc.reload_alt"] = "停止所有正在播放的 NPC 动画",
    ["tool.mmd_vmd_npc.right"] = "暂停/继续播放",
    ["tool.mmd_vmd_npc.right_speed"] = "在点击或上次选择的对象上打开动作和表情分配菜单",
    ["tool.mmd_vmd_npc.middle_speed"] = "将已选 NPC 对齐到第一个 NPC",
    ["tool.mmd_vmd_npc.right_speed_use"] = "+ E：将已选 NPC 对齐到第一个 NPC",
    ["tool.mmd_vmd_npc.reload"] = "选择自己并分配动画",
    ["tool.mmd_vmd_npc.reload_use"] = "在自己身上播放所选动作",
    ["tool.mmd_vmd_npc.reload_speed"] = "为自己构建所选动作",
    ["mmd_vmd_npc.error.left_click_valid_npc"] = "请左键点击有效 NPC 以加入协同舞蹈选择",
    ["mmd_vmd_npc.error.select_motion"] = "请先选择一个动作 JSON",
    ["mmd_vmd_npc.error.shift_right_click_valid_actor"] = "请 Shift+右键点击有效 NPC/玩家",
    ["mmd_vmd_npc.error.build_self_first"] = "请先为你的玩家模型构建此动作",
    ["mmd_vmd_npc.error.no_imported_music"] = "注意：所选动作没有导入音乐。",
    ["mmd_vmd_npc.error.missing_reference_sequence"] = "所选 NPC/玩家没有 Reference 序列。此模型暂不支持。",
    ["mmd_vmd_npc.status.actor_playermodel"] = "玩家模型",
    ["mmd_vmd_npc.status.actor_npc"] = "NPC",
    ["mmd_vmd_npc.status.actor_generic"] = "目标",
    ["mmd_vmd_npc.status.actor_select_prompt"] = "左键点击有效 NPC/玩家，按 R 选择自己，按 Shift+R 为自己构建，或按 E+R 播放自己",
    ["mmd_vmd_npc.status.invalid_player"] = "无效玩家",
    ["mmd_vmd_npc.status.selected_actor_fmt"] = "已选择 %s %s",
    ["mmd_vmd_npc.status.ai_disabled_required"] = "必须先禁用 AI 思考：构建或播放 MMD VMD 动画前运行 ai_disabled 1",
    ["mmd_vmd_npc.status.build_missing_instruction"] = " 使用 Shift + 左键构建所选 NPC 动画。",
    ["mmd_vmd_npc.status.built_cache_missing_options"] = "所选模型/选项缺少构建缓存。",
    ["mmd_vmd_npc.status.build_missing_group_fmt"] = "协同播放前缺少构建：%s。",
    ["mmd_vmd_npc.status.no_valid_selected_npcs"] = "没有可播放的有效已选 NPC",
    ["mmd_vmd_npc.status.group_countdown_fmt"] = "%d 个 NPC 的协同播放将在 %.1f 秒后开始",
    ["mmd_vmd_npc.status.started_group_fmt"] = "已开始 %d 个协同播放",
    ["mmd_vmd_npc.status.select_npcs_before_group_play"] = "开始协同舞蹈前请选择一个或多个 NPC",
    ["mmd_vmd_npc.status.select_first_npc_align"] = "对齐协同舞蹈 NPC 前请选择第一个 NPC",
    ["mmd_vmd_npc.status.aligned_selected_npcs_fmt"] = "已将 %d 个已选 NPC 对齐到第一个 NPC",
    ["mmd_vmd_npc.status.select_npcs_before_build"] = "构建已选 NPC 动画前请选择一个或多个 NPC",
    ["mmd_vmd_npc.status.started_queued_builds_fmt"] = "已开始或排队 %d 个构建；%d 个已构建",
    ["mmd_vmd_npc.status.failed_suffix"] = "；失败：",
    ["mmd_vmd_npc.status.all_builds_exist_fmt"] = "所有已选 NPC 动画构建已存在（%d）",
    ["mmd_vmd_npc.status.no_selected_build_needed"] = "没有已选 NPC 需要构建",
    ["mmd_vmd_npc.status.removed_npc_selection"] = "已从协同舞蹈选择中移除 NPC",
    ["mmd_vmd_npc.status.invalid_motion_id"] = "无效动作 ID",
    ["mmd_vmd_npc.status.assigned_motion_to_npc_fmt"] = "已将 %s 分配给 NPC %s",
    ["mmd_vmd_npc.status.built_cache_exists"] = "构建缓存已存在",
    ["mmd_vmd_npc.status.built_cache_exists_skip_fmt"] = "此模型/选项的已构建动画已经存在；跳过构建：%s",
    ["mmd_vmd_npc.status.build_already_fmt"] = "构建已处于 %s 状态",
    ["mmd_vmd_npc.status.assigned_motion_missing_build"] = "动作已分配；缺少构建缓存。",
    ["mmd_vmd_npc.status.referencef_build_warning_fmt"] = "警告：模型 %s 使用 %s，而不是标准 A pose Reference 序列。本插件可能无法完全支持为该模型构建动画。",
    ["mmd_vmd_npc.status.no_active_selected_playback_pause"] = "没有可暂停的已选播放",
    ["mmd_vmd_npc.status.no_active_playback_pause"] = "没有可暂停的播放",
    ["mmd_vmd_npc.status.coordinated_playback_paused"] = "协同播放已暂停",
    ["mmd_vmd_npc.status.coordinated_playback_resumed"] = "协同播放已继续",
    ["mmd_vmd_npc.hint.self_keys"] = "装备工具后按 R 将动画分配给自己，按 Shift+R 构建，按 E+R 播放自己的动画。",
    ["mmd_vmd_npc.console.no_motions"] = "没有找到动作文件。",
    ["mmd_vmd_npc.console.motion_files"] = "已导入的动作文件：",
    ["mmd_vmd_npc.console.failed_preview_music_fmt"] = "预览音乐失败：%s",
    ["mmd_vmd_npc.console.failed_play_music_fmt"] = "播放音乐 %s 失败：%s",
    ["mmd_vmd_npc.console.debug_failed_fmt"] = "%s 调试失败：%s",
    ["mmd_vmd_npc.console.build_success_fmt"] = "动画构建完成：%s",
    ["mmd_vmd_npc.console.build_failed_fmt"] = "动画构建失败：%s",
    ["mmd_vmd_npc.console.build_cancelled_fmt"] = "已取消构建任务：进行中 %d，队列 %d",
    ["mmd_vmd_npc.console.built_removed_fmt"] = "已删除构建缓存：%s",
    ["mmd_vmd_npc.console.music_removed_fmt"] = "已删除音乐：%s",
    ["mmd_vmd_npc.console.music_checked_fmt"] = "已检查音乐：%s",
    ["mmd_vmd_npc.console.debug_usage"] = "用法：mmdvmd_debug <motion_id> [frame]",
    ["mmd_vmd_npc.warning.build_lag_fmt"] = "构建 '%s' 将处理 %d 帧。进度条完成前游戏可能会短暂卡顿或冻结。",
    ["mmd_vmd_npc.hud.build_queued"] = "动画构建已排队",
    ["mmd_vmd_npc.hud.countdown"] = "预计剩余时间",
    ["mmd_vmd_npc.hud.build"] = "正在构建动画：计算骨骼旋转四元数张量",
    ["mmd_vmd_npc.ui.tool_help"] = "动作文件由导入器生成，位于 garrysmod/data/mmd_vmd_npc/motions。左键 NPC 分配动画。Shift+左键为已选 NPC 构建动画。Alt+R 停止所有 NPC 播放。E+左键同时开始所有已选 NPC。右键暂停/继续。Shift+中键将已选 NPC 对齐到第一个。R 选择自己并分配当前动画。Shift+R 为自己构建。E+R 播放自己。",
    ["mmd_vmd_npc.ui.tab.motion"] = "动作",
    ["mmd_vmd_npc.ui.tab.build_playback"] = "构建与播放",
    ["mmd_vmd_npc.ui.tab.performance"] = "性能",
    ["mmd_vmd_npc.ui.tab.advanced"] = "高级",
    ["mmd_vmd_npc.ui.selected_motion_none"] = "已选动作：无",
    ["mmd_vmd_npc.ui.selected_motion_fmt"] = "已选动作：%s",
    ["mmd_vmd_npc.ui.pause_warning_fmt"] = "警告：sv_pause=%s，sv_pause_sp=%s。构建或播放动画前请将两者设为 0。",
    ["mmd_vmd_npc.ui.music_offset"] = "音乐偏移（秒）",
    ["mmd_vmd_npc.ui.play_imported_music"] = "播放导入音乐",
    ["mmd_vmd_npc.ui.play_imported_music_help"] = "控制下次播放时是否播放所选动作的导入音乐。",
    ["mmd_vmd_npc.ui.music_volume"] = "音乐音量",
    ["mmd_vmd_npc.ui.loop_playback"] = "循环动画和音乐",
    ["mmd_vmd_npc.ui.loop_playback_help"] = "启用后，动作结束时会从第一帧重新播放，并重新开始导入的音乐。",
    ["mmd_vmd_npc.ui.column.motion"] = "动作",
    ["mmd_vmd_npc.ui.column.duration"] = "时长",
    ["mmd_vmd_npc.ui.column.addon"] = "来自插件",
    ["mmd_vmd_npc.ui.loading"] = "加载中",
    ["mmd_vmd_npc.ui.missing"] = "缺失",
    ["mmd_vmd_npc.ui.open_motion_manager"] = "打开动作管理器",
    ["mmd_vmd_npc.ui.refresh_motion_list"] = "刷新动作列表",
    ["mmd_vmd_npc.ui.motion_no_metadata"] = "动作：未加载元数据",
    ["mmd_vmd_npc.ui.target"] = "目标",
    ["mmd_vmd_npc.ui.selected_actor_none"] = "已选目标：无",
    ["mmd_vmd_npc.ui.selected_actor_fmt"] = "已选 %s：%s | %s",
    ["mmd_vmd_npc.ui.coordinated_npcs_zero"] = "协同 NPC：0",
    ["mmd_vmd_npc.ui.coordinated_npcs_fmt"] = "协同 NPC：%d | 第一个：%s | 动作：%s | 状态：%s",
    ["mmd_vmd_npc.ui.play_selected_group"] = "播放已选组",
    ["mmd_vmd_npc.ui.clear_selection"] = "清除选择",
    ["mmd_vmd_npc.ui.clear_missing_invalid"] = "清除缺失/无效项",
    ["mmd_vmd_npc.ui.select_yourself"] = "选择自己",
    ["mmd_vmd_npc.ui.self_help"] = "左键 NPC/玩家选择目标。R 选择自己并分配当前动画；Shift+R 为自己构建；E+R 通过临时代理模型播放自己。",
    ["mmd_vmd_npc.ui.build"] = "构建",
    ["mmd_vmd_npc.ui.build_idle"] = "构建：空闲",
    ["mmd_vmd_npc.ui.build_status_fmt"] = "构建：%s",
    ["mmd_vmd_npc.ui.build_selected_motion"] = "构建所选动作",
    ["mmd_vmd_npc.ui.stop_build_tasks"] = "停止所有构建任务",
    ["mmd_vmd_npc.ui.stop_stuck_build_tasks"] = "停止卡住的构建任务",
    ["mmd_vmd_npc.ui.playback"] = "播放",
    ["mmd_vmd_npc.ui.playback_idle"] = "播放：空闲",
    ["mmd_vmd_npc.ui.playback_status_fmt"] = "播放：%s",
    ["mmd_vmd_npc.ui.play_built_animation"] = "播放已构建动画",
    ["mmd_vmd_npc.ui.stop_animation"] = "停止动画",
    ["mmd_vmd_npc.ui.start_delay"] = "开始延迟（秒，最小 2）",
    ["mmd_vmd_npc.ui.pelvis_z_offset"] = "骨盆 Z 播放偏移",
    ["mmd_vmd_npc.ui.thirdperson_distance"] = "自身第三人称距离",
    ["mmd_vmd_npc.ui.thirdperson_height"] = "自身第三人称高度",
    ["mmd_vmd_npc.ui.eye_tracking"] = "眼睛跟踪",
    ["mmd_vmd_npc.ui.enable_eye_tracking"] = "启用眼睛跟踪",
    ["mmd_vmd_npc.ui.enable_eye_tracking_help"] = "启用后，动画角色的眼骨会在播放时跟踪当前玩家视角。",
    ["mmd_vmd_npc.ui.eye_smoothing"] = "平滑速度",
    ["mmd_vmd_npc.ui.eye_moveback"] = "眼骨后移系数",
    ["mmd_vmd_npc.ui.eye_pos_ud"] = "眼骨位置缩放（上/下）",
    ["mmd_vmd_npc.ui.eye_pos_lr"] = "眼骨位置缩放（左/右）",
    ["mmd_vmd_npc.ui.eye_no_target"] = "眼骨：无播放目标",
    ["mmd_vmd_npc.ui.eye_status_unavailable"] = "眼骨：状态不可用",
    ["mmd_vmd_npc.ui.audio_sync"] = "音频同步",
    ["mmd_vmd_npc.ui.audio_sync_help"] = "打开动作管理器以预览音乐、保存每个动作的音频偏移并管理构建缓存。",
    ["mmd_vmd_npc.ui.manage_built_cache"] = "管理构建缓存",
    ["mmd_vmd_npc.ui.clear_built_model"] = "清除此模型的构建",
    ["mmd_vmd_npc.ui.clear_built_all"] = "清除此动作的所有模型构建",
    ["mmd_vmd_npc.ui.build_performance"] = "构建性能",
    ["mmd_vmd_npc.ui.build_performance_help"] = "较高的构建批量会更快完成，但隐藏模型一次计算更多帧时客户端可能短暂停顿。",
    ["mmd_vmd_npc.ui.build_frames_per_batch"] = "每批构建帧数",
    ["mmd_vmd_npc.ui.playback_performance"] = "播放性能",
    ["mmd_vmd_npc.ui.playback_performance_help"] = "较高的播放更新率可让插值更平滑。较低值可减少服务器/客户端负载。",
    ["mmd_vmd_npc.ui.playback_updates_per_second"] = "每秒播放更新次数",
    ["mmd_vmd_npc.ui.disable_armtwist"] = "禁用 ZArmTwist 变换",
    ["mmd_vmd_npc.ui.disable_handtwist"] = "禁用手部扭转变换",
    ["mmd_vmd_npc.ui.disable_eyes"] = "禁用眼睛变换",
    ["mmd_vmd_npc.ui.disable_spine_pelvis"] = "禁用骨盆/脊柱校正",
    ["mmd_vmd_npc.ui.debug_selected_motion"] = "调试所选动作",
    ["mmd_vmd_npc.ui.motion_info_fmt"] = "动作：%s | %.2fs | %d 帧 | %d 骨骼 | %d 表情 | 音乐：%s | 已构建：%s",
    ["mmd_vmd_npc.ui.motion_metadata_missing_fmt"] = "动作：%s | 元数据未加载",
    ["mmd_vmd_npc.ui.motion_none"] = "动作：无",
    ["mmd_vmd_npc.ui.yes"] = "是",
    ["mmd_vmd_npc.ui.no"] = "否",
    ["mmd_vmd_npc.ui.none"] = "无",
    ["mmd_vmd_npc.ui.not_found"] = "未找到",
    ["mmd_vmd_npc.ui.unknown"] = "未知",
    ["mmd_vmd_npc.ui.actor"] = "角色",
    ["mmd_vmd_npc.ui.idle"] = "空闲",
    ["mmd_vmd_npc.ui.motion"] = "动作",
    ["mmd_vmd_npc.ui.built"] = "已构建",
    ["mmd_vmd_npc.ui.eye_status_none"] = "眼骨：无播放目标",
    ["mmd_vmd_npc.ui.eye_status_fmt"] = "眼骨：左=%s | 右=%s",
    ["mmd_vmd_npc.ui.eye_bone_fmt"] = "%s（#%d）",
    ["mmd_vmd_npc.debug.title_fmt"] = "原始动画调试 - %s",
    ["mmd_vmd_npc.debug.summary_fmt"] = "%s | 帧 %d / %d | %.3fs / %.3fs | %d 个动画骨骼 | %d 个表情%s",
    ["mmd_vmd_npc.debug.preview_entity_fmt"] = " | 预览实体 %s",
    ["mmd_vmd_npc.debug.reference_fmt"] = " | 参考序列：%s",
    ["mmd_vmd_npc.debug.column_mmd_bone"] = "MMD 骨骼名",
    ["mmd_vmd_npc.debug.column_source_bone"] = "分配骨骼",
    ["mmd_vmd_npc.debug.column_role"] = "角色",
    ["mmd_vmd_npc.debug.column_raw_x"] = "Raw +X 左",
    ["mmd_vmd_npc.debug.column_raw_y"] = "Raw +Y 前",
    ["mmd_vmd_npc.debug.column_raw_z"] = "Raw +Z 上",
    ["mmd_vmd_npc.debug.column_bone_position"] = "骨骼位置 (X, Y, Z)",
    ["mmd_vmd_npc.debug.column_manip_angles"] = "本地 ManipulateBoneAngles (P, Y, R)",
    ["mmd_vmd_npc.debug.column_mmd_morph"] = "MMD 表情名",
    ["mmd_vmd_npc.debug.column_source_flex"] = "分配 Flex",
    ["mmd_vmd_npc.debug.column_weight"] = "权重",
    ["mmd_vmd_npc.debug.column_target"] = "目标",
    ["mmd_vmd_npc.debug.previous"] = "上一帧",
    ["mmd_vmd_npc.debug.jump"] = "跳转",
    ["mmd_vmd_npc.debug.vmd_frame"] = "VMD 帧",
    ["mmd_vmd_npc.debug.next"] = "下一帧",
    ["mmd_vmd_npc.debug.refresh"] = "刷新",
    ["mmd_vmd_npc.debug.play_preview"] = "播放",
    ["mmd_vmd_npc.debug.pause_preview"] = "暂停",
    ["mmd_vmd_npc.manager.title"] = "动作管理器",
    ["mmd_vmd_npc.manager.search_placeholder"] = "搜索动作 ID、来源或音乐",
    ["mmd_vmd_npc.manager.refresh"] = "刷新",
    ["mmd_vmd_npc.manager.column_motion_id"] = "动作 ID",
    ["mmd_vmd_npc.manager.column_duration"] = "时长",
    ["mmd_vmd_npc.manager.column_frames"] = "帧数",
    ["mmd_vmd_npc.manager.column_bones"] = "骨骼",
    ["mmd_vmd_npc.manager.column_flexes"] = "表情",
    ["mmd_vmd_npc.manager.column_music"] = "音乐",
    ["mmd_vmd_npc.manager.column_addon"] = "来自插件",
    ["mmd_vmd_npc.manager.column_built"] = "已构建",
    ["mmd_vmd_npc.manager.select_motion_details"] = "选择一个动作以查看详情。",
    ["mmd_vmd_npc.manager.details_fmt"] = "%s\nFPS %s | 帧 %s-%s | 时长 %.2fs | 骨骼 %s | 表情 %s | 音乐 %s | 来源 %s",
    ["mmd_vmd_npc.manager.play_music"] = "播放音乐",
    ["mmd_vmd_npc.manager.volume"] = "音量",
    ["mmd_vmd_npc.manager.audio_offset_help"] = "音频偏移秒数。正值让音乐更晚开始；负值让音乐提前。",
    ["mmd_vmd_npc.manager.preview_music_only"] = "仅预览音乐",
    ["mmd_vmd_npc.manager.preview_motion"] = "预览动作",
    ["mmd_vmd_npc.manager.stop_music"] = "停止音乐",
    ["mmd_vmd_npc.manager.save_offset"] = "保存偏移",
    ["mmd_vmd_npc.manager.debug"] = "调试",
    ["mmd_vmd_npc.manager.build_selected"] = "构建所选",
    ["mmd_vmd_npc.manager.play_built"] = "播放已构建",
    ["mmd_vmd_npc.manager.stop"] = "停止",
    ["mmd_vmd_npc.manager.clear_this_model"] = "清除此模型",
    ["mmd_vmd_npc.manager.clear_all_models"] = "清除此动作的所有模型",
    ["mmd_vmd_npc.manager.delete_motion_music"] = "删除动作和音乐",
    ["mmd_vmd_npc.manager.delete_prompt_fmt"] = "从 data/mmd_vmd_npc/motions 删除 '%s'，并在可能时删除其导入音乐？",
    ["mmd_vmd_npc.manager.delete_title"] = "删除 MMD VMD 动作",
    ["mmd_vmd_npc.manager.delete_confirm"] = "删除",
    ["mmd_vmd_npc.manager.cancel"] = "取消",
})

MMDVMDNPC.I18N.ja = merge_i18n({
    ["mmd_vmd_npc.category"] = "アニメーション",
    ["tool.mmd_vmd_npc.name"] = "高度な MMD アニメーションプレイヤー",
    ["tool.mmd_vmd_npc.desc"] = "NPC または自分に MMD アニメーションを再生します",
    ["tool.mmd_vmd_npc.0"] = "下のキー操作を使って MMD VMD アニメーションを操作します。",
    ["tool.mmd_vmd_npc.left"] = "クリックした NPC に選択中のアニメーションを割り当て",
    ["tool.mmd_vmd_npc.left_use"] = "選択中の NPC を同時に再生",
    ["tool.mmd_vmd_npc.left_speed"] = "選択 NPC の割り当て済みアニメーションをビルド",
    ["tool.mmd_vmd_npc.left_alt"] = "選択中の NPC を最初の NPC に整列",
    ["tool.mmd_vmd_npc.reload_alt"] = "NPC の再生をすべて停止",
    ["tool.mmd_vmd_npc.right"] = "一時停止/再開",
    ["tool.mmd_vmd_npc.right_speed"] = "クリック先または最後に選択した対象のモーション/表情割り当てメニューを開く",
    ["tool.mmd_vmd_npc.middle_speed"] = "選択中の NPC を最初の NPC に整列",
    ["tool.mmd_vmd_npc.right_speed_use"] = "+ E：選択中の NPC を最初の NPC に整列",
    ["tool.mmd_vmd_npc.reload"] = "自分を選択してアニメーションを割り当て",
    ["tool.mmd_vmd_npc.reload_use"] = "選択モーションを自分に再生",
    ["tool.mmd_vmd_npc.reload_speed"] = "選択モーションを自分用にビルド",
    ["mmd_vmd_npc.error.left_click_valid_npc"] = "協調ダンス選択には有効な NPC を左クリックしてください",
    ["mmd_vmd_npc.error.select_motion"] = "先にモーション JSON を選択してください",
    ["mmd_vmd_npc.error.shift_right_click_valid_actor"] = "有効な NPC/プレイヤーを Shift+右クリックしてください",
    ["mmd_vmd_npc.error.build_self_first"] = "先に自分のプレイヤーモデル用にこのモーションをビルドしてください",
    ["mmd_vmd_npc.error.no_imported_music"] = "注意：選択したモーションにはインポート済み音楽がありません。",
    ["mmd_vmd_npc.error.missing_reference_sequence"] = "選択した NPC/プレイヤーには Reference シーケンスがありません。このモデルはまだ対応していません。",
    ["mmd_vmd_npc.status.actor_playermodel"] = "プレイヤーモデル",
    ["mmd_vmd_npc.status.actor_npc"] = "NPC",
    ["mmd_vmd_npc.status.actor_generic"] = "対象",
    ["mmd_vmd_npc.status.actor_select_prompt"] = "有効な NPC/プレイヤーを左クリック、R で自分を選択、Shift+R で自分をビルド、E+R で自分を再生します",
    ["mmd_vmd_npc.status.invalid_player"] = "無効なプレイヤー",
    ["mmd_vmd_npc.status.selected_actor_fmt"] = "%s %s を選択しました",
    ["mmd_vmd_npc.status.ai_disabled_required"] = "AI 思考を無効にしてください：MMD VMD アニメーションのビルド/再生前に ai_disabled 1 を実行してください",
    ["mmd_vmd_npc.status.build_missing_instruction"] = " Shift + 左クリックで選択 NPC のアニメーションをビルドしてください。",
    ["mmd_vmd_npc.status.built_cache_missing_options"] = "選択モデル/オプションのビルドキャッシュがありません。",
    ["mmd_vmd_npc.status.build_missing_group_fmt"] = "協調再生前にビルドが不足しています：%s。",
    ["mmd_vmd_npc.status.no_valid_selected_npcs"] = "再生できる有効な選択 NPC がありません",
    ["mmd_vmd_npc.status.group_countdown_fmt"] = "%d 体の NPC の協調再生が %.1f 秒後に開始します",
    ["mmd_vmd_npc.status.started_group_fmt"] = "%d 件の協調再生を開始しました",
    ["mmd_vmd_npc.status.select_npcs_before_group_play"] = "協調ダンスを開始する前に NPC を 1 体以上選択してください",
    ["mmd_vmd_npc.status.select_first_npc_align"] = "協調ダンス NPC を整列する前に先頭 NPC を選択してください",
    ["mmd_vmd_npc.status.aligned_selected_npcs_fmt"] = "%d 体の選択 NPC を先頭 NPC に整列しました",
    ["mmd_vmd_npc.status.select_npcs_before_build"] = "選択 NPC アニメーションをビルドする前に NPC を 1 体以上選択してください",
    ["mmd_vmd_npc.status.started_queued_builds_fmt"] = "%d 件のビルドを開始またはキューに追加しました；%d 件はビルド済み",
    ["mmd_vmd_npc.status.failed_suffix"] = "；失敗：",
    ["mmd_vmd_npc.status.all_builds_exist_fmt"] = "選択 NPC のアニメーションビルドはすべて存在します（%d）",
    ["mmd_vmd_npc.status.no_selected_build_needed"] = "ビルドが必要な選択 NPC はありません",
    ["mmd_vmd_npc.status.removed_npc_selection"] = "協調ダンス選択から NPC を削除しました",
    ["mmd_vmd_npc.status.invalid_motion_id"] = "無効なモーション ID",
    ["mmd_vmd_npc.status.assigned_motion_to_npc_fmt"] = "%s を NPC %s に割り当てました",
    ["mmd_vmd_npc.status.built_cache_exists"] = "ビルドキャッシュは既に存在します",
    ["mmd_vmd_npc.status.built_cache_exists_skip_fmt"] = "このモデル/オプション用のビルド済みアニメーションは既に存在します。ビルドをスキップします：%s",
    ["mmd_vmd_npc.status.build_already_fmt"] = "ビルドは既に %s 状態です",
    ["mmd_vmd_npc.status.assigned_motion_missing_build"] = "モーションを割り当てました；ビルドキャッシュがありません。",
    ["mmd_vmd_npc.status.referencef_build_warning_fmt"] = "警告：モデル %s は標準の A ポーズ Reference シーケンスではなく %s を使用しています。このアドオンでは、このモデルのアニメーションビルドを完全にはサポートできない可能性があります。",
    ["mmd_vmd_npc.status.no_active_selected_playback_pause"] = "一時停止できる選択中の再生はありません",
    ["mmd_vmd_npc.status.no_active_playback_pause"] = "一時停止できる再生はありません",
    ["mmd_vmd_npc.status.coordinated_playback_paused"] = "協調再生を一時停止しました",
    ["mmd_vmd_npc.status.coordinated_playback_resumed"] = "協調再生を再開しました",
    ["mmd_vmd_npc.hint.self_keys"] = "ツール装備中に R で自分に割り当て、Shift+R でビルド、E+R で自分を再生します。",
    ["mmd_vmd_npc.console.no_motions"] = "モーションファイルが見つかりません。",
    ["mmd_vmd_npc.console.motion_files"] = "インポート済みモーションファイル：",
    ["mmd_vmd_npc.console.failed_preview_music_fmt"] = "音楽プレビューに失敗：%s",
    ["mmd_vmd_npc.console.failed_play_music_fmt"] = "音楽 %s の再生に失敗：%s",
    ["mmd_vmd_npc.console.debug_failed_fmt"] = "%s のデバッグに失敗：%s",
    ["mmd_vmd_npc.console.build_success_fmt"] = "アニメーションをビルドしました：%s",
    ["mmd_vmd_npc.console.build_failed_fmt"] = "アニメーションのビルドに失敗：%s",
    ["mmd_vmd_npc.console.build_cancelled_fmt"] = "ビルドタスクをキャンセルしました：実行中 %d、キュー %d",
    ["mmd_vmd_npc.console.built_removed_fmt"] = "ビルドキャッシュを削除：%s",
    ["mmd_vmd_npc.console.music_removed_fmt"] = "音楽を削除：%s",
    ["mmd_vmd_npc.console.music_checked_fmt"] = "音楽を確認：%s",
    ["mmd_vmd_npc.console.debug_usage"] = "使い方：mmdvmd_debug <motion_id> [frame]",
    ["mmd_vmd_npc.warning.build_lag_fmt"] = "'%s' のビルドでは %d フレームを処理します。進行バーが完了するまでゲームが一時的に重くなる場合があります。",
    ["mmd_vmd_npc.hud.build_queued"] = "アニメーションビルドをキューに追加しました",
    ["mmd_vmd_npc.hud.countdown"] = "推定残り時間",
    ["mmd_vmd_npc.hud.build"] = "アニメーションをビルド中：ボーン回転クォータニオンを計算",
    ["mmd_vmd_npc.ui.tool_help"] = "モーションファイルはインポーターにより garrysmod/data/mmd_vmd_npc/motions に生成されます。NPC を左クリックで割り当て。Shift+左クリックで選択 NPC をビルド。E+左クリックで選択 NPC を同時開始。Alt+R で NPC の再生をすべて停止。右クリックで一時停止/再開。Shift+中クリックで選択 NPC を最初の NPC に整列。R で自分を選択して現在のアニメーションを割り当て。Shift+R で自分用にビルド。E+R で自分を再生。",
    ["mmd_vmd_npc.ui.tab.motion"] = "モーション",
    ["mmd_vmd_npc.ui.tab.build_playback"] = "ビルドと再生",
    ["mmd_vmd_npc.ui.tab.performance"] = "パフォーマンス",
    ["mmd_vmd_npc.ui.tab.advanced"] = "詳細",
    ["mmd_vmd_npc.ui.selected_motion_none"] = "選択モーション：なし",
    ["mmd_vmd_npc.ui.selected_motion_fmt"] = "選択モーション：%s",
    ["mmd_vmd_npc.ui.pause_warning_fmt"] = "警告：sv_pause=%s、sv_pause_sp=%s。ビルドまたは再生前に両方を 0 にしてください。",
    ["mmd_vmd_npc.ui.music_offset"] = "音楽オフセット（秒）",
    ["mmd_vmd_npc.ui.play_imported_music"] = "インポート音楽を再生",
    ["mmd_vmd_npc.ui.play_imported_music_help"] = "次回再生時に選択モーションのインポート音楽を再生するかを制御します。",
    ["mmd_vmd_npc.ui.music_volume"] = "音楽音量",
    ["mmd_vmd_npc.ui.loop_playback"] = "アニメーションと音楽をループ",
    ["mmd_vmd_npc.ui.loop_playback_help"] = "有効にすると、モーション終了時に最初のフレームから再開し、インポート音楽も再スタートします。",
    ["mmd_vmd_npc.ui.column.motion"] = "モーション",
    ["mmd_vmd_npc.ui.column.duration"] = "長さ",
    ["mmd_vmd_npc.ui.column.addon"] = "アドオン由来",
    ["mmd_vmd_npc.ui.loading"] = "読み込み中",
    ["mmd_vmd_npc.ui.missing"] = "不足",
    ["mmd_vmd_npc.ui.open_motion_manager"] = "モーション管理を開く",
    ["mmd_vmd_npc.ui.refresh_motion_list"] = "モーション一覧を更新",
    ["mmd_vmd_npc.ui.motion_no_metadata"] = "モーション：メタデータ未読み込み",
    ["mmd_vmd_npc.ui.target"] = "ターゲット",
    ["mmd_vmd_npc.ui.selected_actor_none"] = "選択対象：なし",
    ["mmd_vmd_npc.ui.selected_actor_fmt"] = "選択 %s：%s | %s",
    ["mmd_vmd_npc.ui.coordinated_npcs_zero"] = "協調 NPC：0",
    ["mmd_vmd_npc.ui.coordinated_npcs_fmt"] = "協調 NPC：%d | 最初：%s | モーション：%s | 状態：%s",
    ["mmd_vmd_npc.ui.play_selected_group"] = "選択グループを再生",
    ["mmd_vmd_npc.ui.clear_selection"] = "選択をクリア",
    ["mmd_vmd_npc.ui.clear_missing_invalid"] = "不足/無効をクリア",
    ["mmd_vmd_npc.ui.select_yourself"] = "自分を選択",
    ["mmd_vmd_npc.ui.self_help"] = "NPC/プレイヤーを左クリックして選択します。R で自分を選択して現在のアニメーションを割り当て、Shift+R で自分用にビルド、E+R で一時プロキシモデルとして再生します。",
    ["mmd_vmd_npc.ui.build"] = "ビルド",
    ["mmd_vmd_npc.ui.build_idle"] = "ビルド：待機中",
    ["mmd_vmd_npc.ui.build_status_fmt"] = "ビルド：%s",
    ["mmd_vmd_npc.ui.build_selected_motion"] = "選択モーションをビルド",
    ["mmd_vmd_npc.ui.stop_build_tasks"] = "すべてのビルドタスクを停止",
    ["mmd_vmd_npc.ui.stop_stuck_build_tasks"] = "停止ビルド（固まった時）",
    ["mmd_vmd_npc.ui.playback"] = "再生",
    ["mmd_vmd_npc.ui.playback_idle"] = "再生：待機中",
    ["mmd_vmd_npc.ui.playback_status_fmt"] = "再生：%s",
    ["mmd_vmd_npc.ui.play_built_animation"] = "ビルド済みアニメーションを再生",
    ["mmd_vmd_npc.ui.stop_animation"] = "アニメーションを停止",
    ["mmd_vmd_npc.ui.start_delay"] = "開始遅延（秒、最小 2）",
    ["mmd_vmd_npc.ui.pelvis_z_offset"] = "骨盤 Z 再生オフセット",
    ["mmd_vmd_npc.ui.thirdperson_distance"] = "自分用三人称距離",
    ["mmd_vmd_npc.ui.thirdperson_height"] = "自分用三人称高さ",
    ["mmd_vmd_npc.ui.eye_tracking"] = "視線追跡",
    ["mmd_vmd_npc.ui.enable_eye_tracking"] = "視線追跡を有効化",
    ["mmd_vmd_npc.ui.enable_eye_tracking_help"] = "有効にすると、再生中のキャラクターの目ボーンが現在のプレイヤー視点を追跡します。",
    ["mmd_vmd_npc.ui.eye_smoothing"] = "スムージング速度",
    ["mmd_vmd_npc.ui.eye_moveback"] = "目ボーン後退係数",
    ["mmd_vmd_npc.ui.eye_pos_ud"] = "目ボーン位置倍率（上下）",
    ["mmd_vmd_npc.ui.eye_pos_lr"] = "目ボーン位置倍率（左右）",
    ["mmd_vmd_npc.ui.eye_no_target"] = "目ボーン：再生対象なし",
    ["mmd_vmd_npc.ui.eye_status_unavailable"] = "目ボーン：状態不明",
    ["mmd_vmd_npc.ui.audio_sync"] = "音声同期",
    ["mmd_vmd_npc.ui.audio_sync_help"] = "モーション管理で音楽をプレビューし、モーションごとの音声オフセットやビルドキャッシュを管理します。",
    ["mmd_vmd_npc.ui.manage_built_cache"] = "ビルドキャッシュ管理",
    ["mmd_vmd_npc.ui.clear_built_model"] = "選択モデルのビルドを削除",
    ["mmd_vmd_npc.ui.clear_built_all"] = "このモーションの全モデルビルドを削除",
    ["mmd_vmd_npc.ui.build_performance"] = "ビルド性能",
    ["mmd_vmd_npc.ui.build_performance_help"] = "ビルドバッチ値を上げると速く完了しますが、隠しモデルが一度に多くのフレームを計算するとクライアントが一時停止することがあります。",
    ["mmd_vmd_npc.ui.build_frames_per_batch"] = "ビルドするフレーム数/バッチ",
    ["mmd_vmd_npc.ui.playback_performance"] = "再生性能",
    ["mmd_vmd_npc.ui.playback_performance_help"] = "再生更新率を上げると補間が滑らかになります。下げるとサーバー/クライアント負荷が減ります。",
    ["mmd_vmd_npc.ui.playback_updates_per_second"] = "再生更新回数/秒",
    ["mmd_vmd_npc.ui.disable_armtwist"] = "ZArmTwist 変換を無効化",
    ["mmd_vmd_npc.ui.disable_handtwist"] = "手捩り変換を無効化",
    ["mmd_vmd_npc.ui.disable_eyes"] = "目の変換を無効化",
    ["mmd_vmd_npc.ui.disable_spine_pelvis"] = "骨盤/脊椎補正を無効化",
    ["mmd_vmd_npc.ui.debug_selected_motion"] = "選択モーションをデバッグ",
    ["mmd_vmd_npc.ui.motion_info_fmt"] = "モーション：%s | %.2fs | %d フレーム | %d ボーン | %d 表情 | 音楽：%s | ビルド済み：%s",
    ["mmd_vmd_npc.ui.motion_metadata_missing_fmt"] = "モーション：%s | メタデータ未読み込み",
    ["mmd_vmd_npc.ui.motion_none"] = "モーション：なし",
    ["mmd_vmd_npc.ui.yes"] = "はい",
    ["mmd_vmd_npc.ui.no"] = "いいえ",
    ["mmd_vmd_npc.ui.none"] = "なし",
    ["mmd_vmd_npc.ui.not_found"] = "見つかりません",
    ["mmd_vmd_npc.ui.unknown"] = "不明",
    ["mmd_vmd_npc.ui.actor"] = "アクター",
    ["mmd_vmd_npc.ui.idle"] = "待機中",
    ["mmd_vmd_npc.ui.motion"] = "モーション",
    ["mmd_vmd_npc.ui.built"] = "ビルド済み",
    ["mmd_vmd_npc.ui.eye_status_none"] = "目ボーン：再生対象なし",
    ["mmd_vmd_npc.ui.eye_status_fmt"] = "目ボーン：L=%s | R=%s",
    ["mmd_vmd_npc.ui.eye_bone_fmt"] = "%s（#%d）",
    ["mmd_vmd_npc.manager.title"] = "モーション管理",
    ["mmd_vmd_npc.manager.search_placeholder"] = "モーション ID、ソース、音楽を検索",
    ["mmd_vmd_npc.manager.refresh"] = "更新",
    ["mmd_vmd_npc.manager.column_motion_id"] = "モーション ID",
    ["mmd_vmd_npc.manager.column_duration"] = "長さ",
    ["mmd_vmd_npc.manager.column_frames"] = "フレーム",
    ["mmd_vmd_npc.manager.column_bones"] = "ボーン",
    ["mmd_vmd_npc.manager.column_flexes"] = "表情",
    ["mmd_vmd_npc.manager.column_music"] = "音楽",
    ["mmd_vmd_npc.manager.column_addon"] = "アドオン由来",
    ["mmd_vmd_npc.manager.column_built"] = "ビルド済み",
    ["mmd_vmd_npc.manager.select_motion_details"] = "詳細を見るモーションを選択してください。",
    ["mmd_vmd_npc.manager.play_music"] = "音楽を再生",
    ["mmd_vmd_npc.manager.volume"] = "音量",
    ["mmd_vmd_npc.manager.audio_offset_help"] = "音声オフセット秒数。正の値は音楽を遅く開始、負の値は先行させます。",
    ["mmd_vmd_npc.manager.preview_music_only"] = "音楽のみプレビュー",
    ["mmd_vmd_npc.manager.preview_motion"] = "モーションをプレビュー",
    ["mmd_vmd_npc.manager.stop_music"] = "音楽を停止",
    ["mmd_vmd_npc.manager.save_offset"] = "オフセット保存",
    ["mmd_vmd_npc.manager.debug"] = "デバッグ",
    ["mmd_vmd_npc.manager.build_selected"] = "選択をビルド",
    ["mmd_vmd_npc.manager.play_built"] = "ビルド済みを再生",
    ["mmd_vmd_npc.manager.stop"] = "停止",
    ["mmd_vmd_npc.manager.clear_this_model"] = "このモデルを削除",
    ["mmd_vmd_npc.manager.clear_all_models"] = "このモーションの全モデルを削除",
    ["mmd_vmd_npc.manager.delete_motion_music"] = "モーションと音楽を削除",
    ["mmd_vmd_npc.manager.delete_prompt_fmt"] = "'%s' を data/mmd_vmd_npc/motions から削除し、可能ならインポート音楽も削除しますか？",
    ["mmd_vmd_npc.manager.delete_title"] = "MMD VMD モーションを削除",
    ["mmd_vmd_npc.manager.delete_confirm"] = "削除",
    ["mmd_vmd_npc.manager.cancel"] = "キャンセル",
})

MMDVMDNPC.I18N.ko = merge_i18n({
    ["mmd_vmd_npc.category"] = "애니메이션",
    ["tool.mmd_vmd_npc.name"] = "고급 MMD 애니메이션 플레이어",
    ["tool.mmd_vmd_npc.desc"] = "NPC 또는 자신에게 MMD 애니메이션을 재생합니다",
    ["tool.mmd_vmd_npc.0"] = "아래 키 안내로 MMD VMD 애니메이션을 조작합니다.",
    ["tool.mmd_vmd_npc.left"] = "클릭한 NPC에 선택한 애니메이션 할당",
    ["tool.mmd_vmd_npc.left_use"] = "선택한 NPC를 동시에 재생",
    ["tool.mmd_vmd_npc.left_speed"] = "선택 NPC의 할당된 애니메이션 빌드",
    ["tool.mmd_vmd_npc.left_alt"] = "선택한 NPC를 첫 번째 NPC에 맞춤",
    ["tool.mmd_vmd_npc.reload_alt"] = "모든 NPC 재생 중지",
    ["tool.mmd_vmd_npc.right"] = "일시정지/재개",
    ["tool.mmd_vmd_npc.right_speed"] = "클릭했거나 마지막으로 선택한 대상의 모션/표정 할당 메뉴 열기",
    ["tool.mmd_vmd_npc.middle_speed"] = "선택한 NPC를 첫 번째 NPC에 맞춤",
    ["tool.mmd_vmd_npc.right_speed_use"] = "+ E: 선택한 NPC를 첫 번째 NPC에 맞춤",
    ["tool.mmd_vmd_npc.reload"] = "자신을 선택하고 애니메이션 할당",
    ["tool.mmd_vmd_npc.reload_use"] = "선택한 모션을 자신에게 재생",
    ["tool.mmd_vmd_npc.reload_speed"] = "선택한 모션을 자신용으로 빌드",
    ["mmd_vmd_npc.error.left_click_valid_npc"] = "협동 댄스 선택에는 유효한 NPC를 왼쪽 클릭하세요",
    ["mmd_vmd_npc.error.select_motion"] = "먼저 모션 JSON을 선택하세요",
    ["mmd_vmd_npc.error.shift_right_click_valid_actor"] = "유효한 NPC/플레이어를 Shift+오른쪽 클릭하세요",
    ["mmd_vmd_npc.error.build_self_first"] = "먼저 자신의 플레이어 모델용으로 이 모션을 빌드하세요",
    ["mmd_vmd_npc.error.no_imported_music"] = "참고: 선택한 모션에 가져온 음악이 없습니다.",
    ["mmd_vmd_npc.error.missing_reference_sequence"] = "선택한 NPC/플레이어에 Reference 시퀀스가 없습니다. 이 모델은 아직 지원되지 않습니다.",
    ["mmd_vmd_npc.status.actor_playermodel"] = "플레이어 모델",
    ["mmd_vmd_npc.status.actor_npc"] = "NPC",
    ["mmd_vmd_npc.status.actor_generic"] = "대상",
    ["mmd_vmd_npc.status.actor_select_prompt"] = "유효한 NPC/플레이어를 왼쪽 클릭하고, R로 자신 선택, Shift+R로 자신 빌드, E+R로 자신 재생",
    ["mmd_vmd_npc.status.invalid_player"] = "유효하지 않은 플레이어",
    ["mmd_vmd_npc.status.selected_actor_fmt"] = "%s %s 선택됨",
    ["mmd_vmd_npc.status.ai_disabled_required"] = "AI 사고를 비활성화해야 합니다: MMD VMD 애니메이션 빌드/재생 전에 ai_disabled 1을 실행하세요",
    ["mmd_vmd_npc.status.build_missing_instruction"] = " Shift + 왼쪽 클릭으로 선택한 NPC 애니메이션을 빌드하세요.",
    ["mmd_vmd_npc.status.built_cache_missing_options"] = "선택한 모델/옵션의 빌드 캐시가 없습니다.",
    ["mmd_vmd_npc.status.build_missing_group_fmt"] = "협동 재생 전에 빌드가 없습니다: %s.",
    ["mmd_vmd_npc.status.no_valid_selected_npcs"] = "재생할 유효한 선택 NPC가 없습니다",
    ["mmd_vmd_npc.status.group_countdown_fmt"] = "%d개 NPC의 협동 재생이 %.1f초 후 시작됩니다",
    ["mmd_vmd_npc.status.started_group_fmt"] = "%d개 협동 재생 시작됨",
    ["mmd_vmd_npc.status.select_npcs_before_group_play"] = "협동 댄스를 시작하기 전에 NPC를 하나 이상 선택하세요",
    ["mmd_vmd_npc.status.select_first_npc_align"] = "협동 댄스 NPC를 정렬하기 전에 첫 번째 NPC를 선택하세요",
    ["mmd_vmd_npc.status.aligned_selected_npcs_fmt"] = "선택한 NPC %d개를 첫 번째 NPC에 정렬했습니다",
    ["mmd_vmd_npc.status.select_npcs_before_build"] = "선택 NPC 애니메이션을 빌드하기 전에 NPC를 하나 이상 선택하세요",
    ["mmd_vmd_npc.status.started_queued_builds_fmt"] = "%d개 빌드를 시작하거나 대기열에 추가; %d개는 이미 빌드됨",
    ["mmd_vmd_npc.status.failed_suffix"] = "; 실패: ",
    ["mmd_vmd_npc.status.all_builds_exist_fmt"] = "선택한 NPC 애니메이션 빌드가 모두 이미 존재함(%d)",
    ["mmd_vmd_npc.status.no_selected_build_needed"] = "빌드가 필요한 선택 NPC가 없습니다",
    ["mmd_vmd_npc.status.removed_npc_selection"] = "협동 댄스 선택에서 NPC 제거됨",
    ["mmd_vmd_npc.status.invalid_motion_id"] = "유효하지 않은 모션 ID",
    ["mmd_vmd_npc.status.assigned_motion_to_npc_fmt"] = "%s를 NPC %s에 할당함",
    ["mmd_vmd_npc.status.built_cache_exists"] = "빌드 캐시가 이미 존재합니다",
    ["mmd_vmd_npc.status.built_cache_exists_skip_fmt"] = "이 모델/옵션의 빌드된 애니메이션이 이미 있습니다. 빌드를 건너뜁니다: %s",
    ["mmd_vmd_npc.status.build_already_fmt"] = "빌드가 이미 %s 상태입니다",
    ["mmd_vmd_npc.status.assigned_motion_missing_build"] = "모션이 할당됨; 빌드 캐시가 없습니다.",
    ["mmd_vmd_npc.status.referencef_build_warning_fmt"] = "경고: 모델 %s는 표준 A 포즈 Reference 시퀀스 대신 %s를 사용합니다. 이 애드온이 이 모델의 애니메이션 빌드를 완전히 지원하지 못할 수 있습니다.",
    ["mmd_vmd_npc.status.no_active_selected_playback_pause"] = "일시정지할 선택된 재생이 없습니다",
    ["mmd_vmd_npc.status.no_active_playback_pause"] = "일시정지할 활성 재생이 없습니다",
    ["mmd_vmd_npc.status.coordinated_playback_paused"] = "협동 재생 일시정지됨",
    ["mmd_vmd_npc.status.coordinated_playback_resumed"] = "협동 재생 재개됨",
    ["mmd_vmd_npc.hint.self_keys"] = "도구를 든 상태에서 R은 자신에게 할당, Shift+R은 빌드, E+R은 자신 재생입니다.",
    ["mmd_vmd_npc.console.no_motions"] = "모션 파일을 찾을 수 없습니다.",
    ["mmd_vmd_npc.console.motion_files"] = "가져온 모션 파일:",
    ["mmd_vmd_npc.console.build_cancelled_fmt"] = "빌드 작업 취소됨: 진행 중 %d, 대기열 %d",
    ["mmd_vmd_npc.warning.build_lag_fmt"] = "'%s' 빌드는 %d 프레임을 처리합니다. 진행 막대가 끝날 때까지 게임이 잠시 느려지거나 멈출 수 있습니다.",
    ["mmd_vmd_npc.hud.build_queued"] = "애니메이션 빌드 대기열에 추가됨",
    ["mmd_vmd_npc.hud.countdown"] = "예상 남은 시간",
    ["mmd_vmd_npc.hud.build"] = "애니메이션 빌드 중: 본 회전 쿼터니언 계산",
    ["mmd_vmd_npc.ui.tool_help"] = "모션 파일은 가져오기 도구가 garrysmod/data/mmd_vmd_npc/motions 에 생성합니다. NPC 왼쪽 클릭으로 애니메이션 할당. Shift+왼쪽 클릭으로 선택 NPC 빌드. E+왼쪽 클릭으로 선택 NPC 동시 시작. Alt+R로 모든 NPC 재생 중지. 오른쪽 클릭으로 일시정지/재개. Shift+가운데 클릭으로 선택 NPC를 첫 번째 NPC에 맞춤. R은 자신 선택 및 현재 애니메이션 할당. Shift+R은 자신용 빌드. E+R은 자신 재생.",
    ["mmd_vmd_npc.ui.tab.motion"] = "모션",
    ["mmd_vmd_npc.ui.tab.build_playback"] = "빌드 및 재생",
    ["mmd_vmd_npc.ui.tab.performance"] = "성능",
    ["mmd_vmd_npc.ui.tab.advanced"] = "고급",
    ["mmd_vmd_npc.ui.selected_motion_none"] = "선택한 모션: 없음",
    ["mmd_vmd_npc.ui.selected_motion_fmt"] = "선택한 모션: %s",
    ["mmd_vmd_npc.ui.pause_warning_fmt"] = "경고: sv_pause=%s, sv_pause_sp=%s. 빌드 또는 재생 전에 둘 다 0으로 설정하세요.",
    ["mmd_vmd_npc.ui.music_offset"] = "음악 오프셋(초)",
    ["mmd_vmd_npc.ui.play_imported_music"] = "가져온 음악 재생",
    ["mmd_vmd_npc.ui.play_imported_music_help"] = "다음 재생 시 선택한 모션의 가져온 음악을 재생할지 설정합니다.",
    ["mmd_vmd_npc.ui.music_volume"] = "음악 음량",
    ["mmd_vmd_npc.ui.loop_playback"] = "애니메이션과 음악 반복",
    ["mmd_vmd_npc.ui.loop_playback_help"] = "켜면 모션이 끝날 때 첫 프레임부터 다시 재생되고 가져온 음악도 다시 시작됩니다.",
    ["mmd_vmd_npc.ui.column.motion"] = "모션",
    ["mmd_vmd_npc.ui.column.duration"] = "길이",
    ["mmd_vmd_npc.ui.column.addon"] = "애드온 제공",
    ["mmd_vmd_npc.ui.loading"] = "불러오는 중",
    ["mmd_vmd_npc.ui.missing"] = "없음",
    ["mmd_vmd_npc.ui.open_motion_manager"] = "모션 관리자 열기",
    ["mmd_vmd_npc.ui.refresh_motion_list"] = "모션 목록 새로고침",
    ["mmd_vmd_npc.ui.motion_no_metadata"] = "모션: 메타데이터 없음",
    ["mmd_vmd_npc.ui.target"] = "대상",
    ["mmd_vmd_npc.ui.selected_actor_none"] = "선택 대상: 없음",
    ["mmd_vmd_npc.ui.selected_actor_fmt"] = "선택한 %s: %s | %s",
    ["mmd_vmd_npc.ui.coordinated_npcs_zero"] = "협동 NPC: 0",
    ["mmd_vmd_npc.ui.coordinated_npcs_fmt"] = "협동 NPC: %d | 첫 번째: %s | 모션: %s | 상태: %s",
    ["mmd_vmd_npc.ui.play_selected_group"] = "선택 그룹 재생",
    ["mmd_vmd_npc.ui.clear_selection"] = "선택 지우기",
    ["mmd_vmd_npc.ui.clear_missing_invalid"] = "누락/무효 항목 지우기",
    ["mmd_vmd_npc.ui.select_yourself"] = "자신 선택",
    ["mmd_vmd_npc.ui.self_help"] = "NPC/플레이어를 왼쪽 클릭해 선택합니다. R은 자신 선택 및 현재 애니메이션 할당, Shift+R은 자신용 빌드, E+R은 임시 프록시 모델로 자신 재생입니다.",
    ["mmd_vmd_npc.ui.build"] = "빌드",
    ["mmd_vmd_npc.ui.build_idle"] = "빌드: 대기",
    ["mmd_vmd_npc.ui.build_status_fmt"] = "빌드: %s",
    ["mmd_vmd_npc.ui.build_selected_motion"] = "선택 모션 빌드",
    ["mmd_vmd_npc.ui.stop_build_tasks"] = "모든 빌드 작업 중지",
    ["mmd_vmd_npc.ui.stop_stuck_build_tasks"] = "멈춘 빌드 작업 중지",
    ["mmd_vmd_npc.ui.playback"] = "재생",
    ["mmd_vmd_npc.ui.playback_idle"] = "재생: 대기",
    ["mmd_vmd_npc.ui.playback_status_fmt"] = "재생: %s",
    ["mmd_vmd_npc.ui.play_built_animation"] = "빌드된 애니메이션 재생",
    ["mmd_vmd_npc.ui.stop_animation"] = "애니메이션 중지",
    ["mmd_vmd_npc.ui.start_delay"] = "시작 지연(초, 최소 2)",
    ["mmd_vmd_npc.ui.pelvis_z_offset"] = "골반 Z 재생 오프셋",
    ["mmd_vmd_npc.ui.eye_tracking"] = "눈 추적",
    ["mmd_vmd_npc.ui.enable_eye_tracking"] = "눈 추적 사용",
    ["mmd_vmd_npc.ui.enable_eye_tracking_help"] = "사용하면 재생 중 캐릭터의 눈 본이 현재 플레이어 시점을 추적합니다.",
    ["mmd_vmd_npc.ui.eye_smoothing"] = "부드럽게 속도",
    ["mmd_vmd_npc.ui.audio_sync"] = "오디오 동기화",
    ["mmd_vmd_npc.ui.manage_built_cache"] = "빌드 캐시 관리",
    ["mmd_vmd_npc.ui.build_performance"] = "빌드 성능",
    ["mmd_vmd_npc.ui.playback_performance"] = "재생 성능",
    ["mmd_vmd_npc.ui.disable_armtwist"] = "ZArmTwist 변환 비활성화",
    ["mmd_vmd_npc.ui.disable_handtwist"] = "손 트위스트 변환 비활성화",
    ["mmd_vmd_npc.ui.disable_eyes"] = "눈 변환 비활성화",
    ["mmd_vmd_npc.ui.disable_spine_pelvis"] = "골반/척추 보정 비활성화",
    ["mmd_vmd_npc.ui.debug_selected_motion"] = "선택 모션 디버그",
    ["mmd_vmd_npc.ui.motion_info_fmt"] = "모션: %s | %.2fs | %d 프레임 | %d 본 | %d 표정 | 음악: %s | 빌드됨: %s",
    ["mmd_vmd_npc.ui.yes"] = "예",
    ["mmd_vmd_npc.ui.no"] = "아니요",
    ["mmd_vmd_npc.ui.none"] = "없음",
    ["mmd_vmd_npc.ui.unknown"] = "알 수 없음",
    ["mmd_vmd_npc.manager.title"] = "모션 관리자",
    ["mmd_vmd_npc.manager.search_placeholder"] = "모션 ID, 원본 또는 음악 검색",
    ["mmd_vmd_npc.manager.refresh"] = "새로고침",
    ["mmd_vmd_npc.manager.column_addon"] = "애드온 제공",
    ["mmd_vmd_npc.manager.play_music"] = "음악 재생",
    ["mmd_vmd_npc.manager.volume"] = "음량",
    ["mmd_vmd_npc.manager.save_offset"] = "오프셋 저장",
    ["mmd_vmd_npc.manager.delete_motion_music"] = "모션 + 음악 삭제",
    ["mmd_vmd_npc.manager.delete_confirm"] = "삭제",
    ["mmd_vmd_npc.manager.cancel"] = "취소",
})

MMDVMDNPC.I18N.fr = merge_i18n({
    ["mmd_vmd_npc.category"] = "Animation",
    ["tool.mmd_vmd_npc.name"] = "Lecteur d'animation MMD avancé",
    ["tool.mmd_vmd_npc.desc"] = "Joue une animation MMD sur des PNJ ou sur vous-même",
    ["tool.mmd_vmd_npc.0"] = "Utilisez les lignes de touches ci-dessous pour les animations MMD VMD.",
    ["tool.mmd_vmd_npc.left"] = "Assigner l'animation sélectionnée au PNJ cliqué",
    ["tool.mmd_vmd_npc.left_use"] = "Démarrer tous les PNJ sélectionnés ensemble",
    ["tool.mmd_vmd_npc.left_speed"] = "Construire les animations assignées aux PNJ sélectionnés",
    ["tool.mmd_vmd_npc.left_alt"] = "Aligner les PNJ sélectionnés sur le premier",
    ["tool.mmd_vmd_npc.reload_alt"] = "Arrêter toutes les animations de PNJ",
    ["tool.mmd_vmd_npc.right"] = "Mettre en pause/reprendre",
    ["tool.mmd_vmd_npc.right_speed"] = "Ouvrir le menu d'affectation motion/flex sur la cible cliquée ou le dernier acteur sélectionné",
    ["tool.mmd_vmd_npc.middle_speed"] = "Aligner les PNJ sélectionnés sur le premier",
    ["tool.mmd_vmd_npc.right_speed_use"] = "+ E : aligner les PNJ sélectionnés sur le premier",
    ["tool.mmd_vmd_npc.reload"] = "Vous sélectionner et assigner l'animation",
    ["tool.mmd_vmd_npc.reload_use"] = "Jouer le mouvement sélectionné sur vous-même",
    ["tool.mmd_vmd_npc.reload_speed"] = "Construire le mouvement sélectionné pour vous-même",
    ["mmd_vmd_npc.error.left_click_valid_npc"] = "faites un clic gauche sur un PNJ valide pour une sélection de danse coordonnée",
    ["mmd_vmd_npc.error.select_motion"] = "Veuillez d'abord sélectionner un JSON de mouvement",
    ["mmd_vmd_npc.error.shift_right_click_valid_actor"] = "faites Maj+clic droit sur un PNJ/joueur valide",
    ["mmd_vmd_npc.error.build_self_first"] = "construisez d'abord ce mouvement pour votre modèle joueur",
    ["mmd_vmd_npc.error.no_imported_music"] = "Remarque : le mouvement sélectionné n'a pas de musique importée.",
    ["mmd_vmd_npc.error.missing_reference_sequence"] = "Le PNJ/joueur sélectionné n'a pas de séquence Reference. Ce modèle n'est pas encore pris en charge.",
    ["mmd_vmd_npc.status.actor_playermodel"] = "modèle joueur",
    ["mmd_vmd_npc.status.actor_npc"] = "PNJ",
    ["mmd_vmd_npc.status.actor_generic"] = "acteur",
    ["mmd_vmd_npc.status.actor_select_prompt"] = "clic gauche sur un PNJ/joueur valide, R pour vous sélectionner, Maj+R pour construire, ou E+R pour jouer sur vous-même",
    ["mmd_vmd_npc.status.invalid_player"] = "joueur invalide",
    ["mmd_vmd_npc.status.selected_actor_fmt"] = "%s %s sélectionné",
    ["mmd_vmd_npc.status.ai_disabled_required"] = "L'IA doit être désactivée : exécutez ai_disabled 1 avant de construire ou jouer des animations MMD VMD",
    ["mmd_vmd_npc.status.build_missing_instruction"] = " Utilisez Maj + clic gauche pour construire les animations des PNJ sélectionnés.",
    ["mmd_vmd_npc.status.built_cache_missing_options"] = "cache construit manquant pour le modèle/options sélectionnés.",
    ["mmd_vmd_npc.status.build_missing_group_fmt"] = "construction manquante avant lecture coordonnée : %s.",
    ["mmd_vmd_npc.status.no_valid_selected_npcs"] = "aucun PNJ sélectionné valide à jouer",
    ["mmd_vmd_npc.status.group_countdown_fmt"] = "la lecture coordonnée démarre sur %d PNJ dans %.1f secondes",
    ["mmd_vmd_npc.status.started_group_fmt"] = "%d lecture(s) coordonnée(s) démarrée(s)",
    ["mmd_vmd_npc.status.select_npcs_before_group_play"] = "sélectionnez un ou plusieurs PNJ avant de démarrer une danse coordonnée",
    ["mmd_vmd_npc.status.select_first_npc_align"] = "sélectionnez un premier PNJ avant d'aligner les PNJ de danse coordonnée",
    ["mmd_vmd_npc.status.aligned_selected_npcs_fmt"] = "%d PNJ sélectionné(s) aligné(s) sur le premier PNJ",
    ["mmd_vmd_npc.status.select_npcs_before_build"] = "sélectionnez un ou plusieurs PNJ avant de construire leurs animations",
    ["mmd_vmd_npc.status.started_queued_builds_fmt"] = "%d construction(s) démarrée(s) ou en file ; %d déjà construite(s)",
    ["mmd_vmd_npc.status.failed_suffix"] = " ; échec : ",
    ["mmd_vmd_npc.status.all_builds_exist_fmt"] = "toutes les constructions d'animations de PNJ sélectionnés existent déjà (%d)",
    ["mmd_vmd_npc.status.no_selected_build_needed"] = "aucun PNJ sélectionné n'a besoin d'une construction",
    ["mmd_vmd_npc.status.removed_npc_selection"] = "PNJ retiré de la sélection de danse coordonnée",
    ["mmd_vmd_npc.status.invalid_motion_id"] = "ID de mouvement invalide",
    ["mmd_vmd_npc.status.assigned_motion_to_npc_fmt"] = "%s assigné au PNJ %s",
    ["mmd_vmd_npc.status.built_cache_exists"] = "le cache construit existe déjà",
    ["mmd_vmd_npc.status.built_cache_exists_skip_fmt"] = "L'animation construite existe déjà pour ce modèle/options ; construction ignorée : %s",
    ["mmd_vmd_npc.status.build_already_fmt"] = "construction déjà %s",
    ["mmd_vmd_npc.status.assigned_motion_missing_build"] = "mouvement assigné ; cache construit manquant.",
    ["mmd_vmd_npc.status.referencef_build_warning_fmt"] = "Avertissement : le modèle %s utilise %s au lieu de la séquence Reference standard en pose A. Cet addon peut ne pas prendre entièrement en charge la construction d'animation pour ce modèle.",
    ["mmd_vmd_npc.status.no_active_selected_playback_pause"] = "aucune lecture sélectionnée active à mettre en pause",
    ["mmd_vmd_npc.status.no_active_playback_pause"] = "aucune lecture active à mettre en pause",
    ["mmd_vmd_npc.status.coordinated_playback_paused"] = "lecture coordonnée en pause",
    ["mmd_vmd_npc.status.coordinated_playback_resumed"] = "lecture coordonnée reprise",
    ["mmd_vmd_npc.hint.self_keys"] = "Avec l'outil équipé, appuyez sur R pour vous assigner l'animation, Maj+R pour la construire, et E+R pour la jouer.",
    ["mmd_vmd_npc.console.no_motions"] = "Aucun fichier de mouvement trouvé.",
    ["mmd_vmd_npc.console.motion_files"] = "Fichiers de mouvement importés :",
    ["mmd_vmd_npc.console.failed_preview_music_fmt"] = "Échec de l'aperçu musical : %s",
    ["mmd_vmd_npc.console.failed_play_music_fmt"] = "Impossible de jouer la musique %s : %s",
    ["mmd_vmd_npc.console.debug_failed_fmt"] = "Échec du débogage pour %s : %s",
    ["mmd_vmd_npc.console.build_success_fmt"] = "Animation construite : %s",
    ["mmd_vmd_npc.console.build_failed_fmt"] = "Échec de construction de l'animation : %s",
    ["mmd_vmd_npc.console.build_cancelled_fmt"] = "Tâche(s) de construction annulée(s) : active(s) %d, en file %d",
    ["mmd_vmd_npc.console.built_removed_fmt"] = "caches construits supprimés : %s",
    ["mmd_vmd_npc.console.music_removed_fmt"] = "musique supprimée : %s",
    ["mmd_vmd_npc.console.music_checked_fmt"] = "musique vérifiée : %s",
    ["mmd_vmd_npc.console.debug_usage"] = "Utilisation : mmdvmd_debug <motion_id> [frame]",
    ["mmd_vmd_npc.warning.build_lag_fmt"] = "La construction de '%s' traitera %d image(s). Le jeu peut brièvement ralentir ou se figer jusqu'à la fin de la barre de progression.",
    ["mmd_vmd_npc.hud.build_queued"] = "Construction d'animation en file",
    ["mmd_vmd_npc.hud.countdown"] = "Temps restant estimé",
    ["mmd_vmd_npc.hud.build"] = "Construction de l'animation : calcul des quaternions de rotation des os",
    ["mmd_vmd_npc.ui.tool_help"] = "Les fichiers de mouvement sont générés dans garrysmod/data/mmd_vmd_npc/motions. Clic gauche sur un PNJ pour assigner. Maj+clic gauche construit les PNJ sélectionnés. E+clic gauche démarre tous les PNJ sélectionnés. Alt+R arrête toutes les animations de PNJ. Clic droit pause/reprise. Maj+clic du milieu aligne les PNJ sélectionnés sur le premier. R vous sélectionne et assigne l'animation actuelle. Maj+R construit pour vous-même. E+R joue sur vous-même.",
    ["mmd_vmd_npc.ui.tab.motion"] = "Mouvement",
    ["mmd_vmd_npc.ui.tab.build_playback"] = "Construction et lecture",
    ["mmd_vmd_npc.ui.tab.performance"] = "Performance",
    ["mmd_vmd_npc.ui.tab.advanced"] = "Avancé",
    ["mmd_vmd_npc.ui.selected_motion_none"] = "Mouvement sélectionné : aucun",
    ["mmd_vmd_npc.ui.selected_motion_fmt"] = "Mouvement sélectionné : %s",
    ["mmd_vmd_npc.ui.pause_warning_fmt"] = "Avertissement : sv_pause=%s et sv_pause_sp=%s. Mettez les deux à 0 avant de construire ou jouer des animations.",
    ["mmd_vmd_npc.ui.music_offset"] = "Décalage musique (secondes)",
    ["mmd_vmd_npc.ui.play_imported_music"] = "Jouer la musique importée",
    ["mmd_vmd_npc.ui.play_imported_music_help"] = "Contrôle si la musique importée du mouvement sélectionné sera jouée au prochain démarrage.",
    ["mmd_vmd_npc.ui.music_volume"] = "Volume musique",
    ["mmd_vmd_npc.ui.loop_playback"] = "Boucler animation et musique",
    ["mmd_vmd_npc.ui.loop_playback_help"] = "Si activé, l'animation repart de la première image et la musique importée redémarre à la fin du mouvement.",
    ["mmd_vmd_npc.ui.column.motion"] = "Mouvement",
    ["mmd_vmd_npc.ui.column.duration"] = "Durée",
    ["mmd_vmd_npc.ui.column.addon"] = "Depuis l'addon",
    ["mmd_vmd_npc.ui.loading"] = "chargement",
    ["mmd_vmd_npc.ui.missing"] = "manquant",
    ["mmd_vmd_npc.ui.open_motion_manager"] = "Ouvrir le gestionnaire de mouvements",
    ["mmd_vmd_npc.ui.refresh_motion_list"] = "Actualiser la liste",
    ["mmd_vmd_npc.ui.motion_no_metadata"] = "Mouvement : aucune métadonnée chargée",
    ["mmd_vmd_npc.ui.target"] = "Cible",
    ["mmd_vmd_npc.ui.selected_actor_none"] = "Acteur sélectionné : aucun",
    ["mmd_vmd_npc.ui.selected_actor_fmt"] = "%s sélectionné : %s | %s",
    ["mmd_vmd_npc.ui.coordinated_npcs_zero"] = "PNJ coordonnés : 0",
    ["mmd_vmd_npc.ui.coordinated_npcs_fmt"] = "PNJ coordonnés : %d | premier : %s | mouvement : %s | état : %s",
    ["mmd_vmd_npc.ui.play_selected_group"] = "Jouer le groupe sélectionné",
    ["mmd_vmd_npc.ui.clear_selection"] = "Effacer la sélection",
    ["mmd_vmd_npc.ui.clear_missing_invalid"] = "Effacer manquants/invalides",
    ["mmd_vmd_npc.ui.select_yourself"] = "Vous sélectionner",
    ["mmd_vmd_npc.ui.self_help"] = "Clic gauche sur un PNJ/joueur pour le sélectionner. R vous sélectionne et assigne l'animation actuelle ; Maj+R la construit pour vous-même ; E+R joue via un modèle proxy temporaire.",
    ["mmd_vmd_npc.ui.build"] = "Construire",
    ["mmd_vmd_npc.ui.build_idle"] = "Construction : inactive",
    ["mmd_vmd_npc.ui.build_status_fmt"] = "Construction : %s",
    ["mmd_vmd_npc.ui.build_selected_motion"] = "Construire le mouvement sélectionné",
    ["mmd_vmd_npc.ui.stop_build_tasks"] = "Arrêter toutes les constructions",
    ["mmd_vmd_npc.ui.stop_stuck_build_tasks"] = "Arrêter les builds bloqués",
    ["mmd_vmd_npc.ui.playback"] = "Lecture",
    ["mmd_vmd_npc.ui.playback_idle"] = "Lecture : inactive",
    ["mmd_vmd_npc.ui.playback_status_fmt"] = "Lecture : %s",
    ["mmd_vmd_npc.ui.play_built_animation"] = "Jouer l'animation construite",
    ["mmd_vmd_npc.ui.stop_animation"] = "Arrêter l'animation",
    ["mmd_vmd_npc.ui.start_delay"] = "Délai de départ (secondes, min 2)",
    ["mmd_vmd_npc.ui.pelvis_z_offset"] = "Décalage Z du bassin en lecture",
    ["mmd_vmd_npc.ui.thirdperson_distance"] = "Distance troisième personne",
    ["mmd_vmd_npc.ui.thirdperson_height"] = "Hauteur troisième personne",
    ["mmd_vmd_npc.ui.eye_tracking"] = "Suivi des yeux",
    ["mmd_vmd_npc.ui.enable_eye_tracking"] = "Activer le suivi des yeux",
    ["mmd_vmd_npc.ui.enable_eye_tracking_help"] = "Si activé, les os des yeux du personnage suivent la vue du joueur pendant la lecture.",
    ["mmd_vmd_npc.ui.eye_smoothing"] = "Vitesse de lissage",
    ["mmd_vmd_npc.ui.eye_moveback"] = "Facteur de recul des yeux",
    ["mmd_vmd_npc.ui.eye_pos_ud"] = "Échelle position yeux (haut/bas)",
    ["mmd_vmd_npc.ui.eye_pos_lr"] = "Échelle position yeux (gauche/droite)",
    ["mmd_vmd_npc.ui.eye_no_target"] = "Yeux : aucune cible de lecture",
    ["mmd_vmd_npc.ui.eye_status_unavailable"] = "Yeux : état indisponible",
    ["mmd_vmd_npc.ui.audio_sync"] = "Synchronisation audio",
    ["mmd_vmd_npc.ui.audio_sync_help"] = "Ouvrez le gestionnaire pour prévisualiser la musique, sauvegarder les décalages audio et gérer les caches.",
    ["mmd_vmd_npc.ui.manage_built_cache"] = "Gérer le cache construit",
    ["mmd_vmd_npc.ui.clear_built_model"] = "Effacer pour le modèle sélectionné",
    ["mmd_vmd_npc.ui.clear_built_all"] = "Effacer pour tous les modèles",
    ["mmd_vmd_npc.ui.build_performance"] = "Performance de construction",
    ["mmd_vmd_npc.ui.playback_performance"] = "Performance de lecture",
    ["mmd_vmd_npc.ui.disable_armtwist"] = "Désactiver les transformations ZArmTwist",
    ["mmd_vmd_npc.ui.disable_handtwist"] = "Désactiver les torsions des mains",
    ["mmd_vmd_npc.ui.disable_eyes"] = "Désactiver les transformations des yeux",
    ["mmd_vmd_npc.ui.disable_spine_pelvis"] = "Désactiver la correction bassin/colonne",
    ["mmd_vmd_npc.ui.debug_selected_motion"] = "Déboguer le mouvement sélectionné",
    ["mmd_vmd_npc.ui.motion_info_fmt"] = "Mouvement : %s | %.2fs | %d image(s) | %d os | %d flex | musique : %s | construit : %s",
    ["mmd_vmd_npc.ui.yes"] = "oui",
    ["mmd_vmd_npc.ui.no"] = "non",
    ["mmd_vmd_npc.ui.none"] = "aucun",
    ["mmd_vmd_npc.ui.not_found"] = "introuvable",
    ["mmd_vmd_npc.ui.unknown"] = "inconnu",
    ["mmd_vmd_npc.ui.actor"] = "acteur",
    ["mmd_vmd_npc.ui.idle"] = "inactif",
    ["mmd_vmd_npc.ui.motion"] = "mouvement",
    ["mmd_vmd_npc.ui.built"] = "construit",
    ["mmd_vmd_npc.manager.title"] = "Gestionnaire de mouvements",
    ["mmd_vmd_npc.manager.search_placeholder"] = "Chercher ID, source ou musique",
    ["mmd_vmd_npc.manager.refresh"] = "Actualiser",
    ["mmd_vmd_npc.manager.column_motion_id"] = "ID mouvement",
    ["mmd_vmd_npc.manager.column_duration"] = "Durée",
    ["mmd_vmd_npc.manager.column_frames"] = "Images",
    ["mmd_vmd_npc.manager.column_bones"] = "Os",
    ["mmd_vmd_npc.manager.column_flexes"] = "Flex",
    ["mmd_vmd_npc.manager.column_music"] = "Musique",
    ["mmd_vmd_npc.manager.column_addon"] = "Depuis l'addon",
    ["mmd_vmd_npc.manager.column_built"] = "Construit",
    ["mmd_vmd_npc.manager.select_motion_details"] = "Sélectionnez un mouvement pour voir les détails.",
    ["mmd_vmd_npc.manager.play_music"] = "Jouer la musique",
    ["mmd_vmd_npc.manager.volume"] = "Volume",
    ["mmd_vmd_npc.manager.audio_offset_help"] = "Décalage audio en secondes. Positif démarre la musique plus tard ; négatif l'avance.",
    ["mmd_vmd_npc.manager.preview_music_only"] = "Prévisualiser seulement la musique",
    ["mmd_vmd_npc.manager.preview_motion"] = "Prévisualiser le mouvement",
    ["mmd_vmd_npc.manager.stop_music"] = "Arrêter la musique",
    ["mmd_vmd_npc.manager.save_offset"] = "Sauver le décalage",
    ["mmd_vmd_npc.manager.debug"] = "Déboguer",
    ["mmd_vmd_npc.manager.build_selected"] = "Construire sélection",
    ["mmd_vmd_npc.manager.play_built"] = "Jouer construit",
    ["mmd_vmd_npc.manager.stop"] = "Arrêter",
    ["mmd_vmd_npc.manager.clear_this_model"] = "Effacer ce modèle",
    ["mmd_vmd_npc.manager.clear_all_models"] = "Effacer tous les modèles",
    ["mmd_vmd_npc.manager.delete_motion_music"] = "Supprimer mouvement + musique",
    ["mmd_vmd_npc.manager.delete_confirm"] = "Supprimer",
    ["mmd_vmd_npc.manager.cancel"] = "Annuler",
})

MMDVMDNPC.I18N.ru = merge_i18n({
    ["mmd_vmd_npc.category"] = "Анимация",
    ["tool.mmd_vmd_npc.name"] = "Расширенный проигрыватель MMD-анимаций",
    ["tool.mmd_vmd_npc.desc"] = "Воспроизводит MMD-анимации на NPC или на вас",
    ["tool.mmd_vmd_npc.0"] = "Используйте строки клавиш ниже для действий с MMD VMD-анимацией.",
    ["tool.mmd_vmd_npc.left"] = "Назначить выбранную анимацию NPC",
    ["tool.mmd_vmd_npc.left_use"] = "Запустить всех выбранных NPC одновременно",
    ["tool.mmd_vmd_npc.left_speed"] = "Построить назначенные анимации для выбранных NPC",
    ["tool.mmd_vmd_npc.left_alt"] = "Выровнять выбранных NPC по первому",
    ["tool.mmd_vmd_npc.reload_alt"] = "Остановить все воспроизведения NPC",
    ["tool.mmd_vmd_npc.right"] = "Пауза/продолжить",
    ["tool.mmd_vmd_npc.right_speed"] = "открыть меню назначения движения/flex для цели клика или последнего выбранного актера",
    ["tool.mmd_vmd_npc.middle_speed"] = "Выровнять выбранных NPC по первому",
    ["tool.mmd_vmd_npc.right_speed_use"] = "+ E: выровнять выбранных NPC по первому",
    ["tool.mmd_vmd_npc.reload"] = "Выбрать себя и назначить анимацию",
    ["tool.mmd_vmd_npc.reload_use"] = "Воспроизвести выбранное движение на себе",
    ["tool.mmd_vmd_npc.reload_speed"] = "Построить выбранное движение для себя",
    ["mmd_vmd_npc.error.left_click_valid_npc"] = "щелкните левой кнопкой по допустимому NPC для выбора синхронного танца",
    ["mmd_vmd_npc.error.select_motion"] = "Сначала выберите JSON движения",
    ["mmd_vmd_npc.error.shift_right_click_valid_actor"] = "Shift+ПКМ по допустимому NPC/игроку",
    ["mmd_vmd_npc.error.build_self_first"] = "сначала постройте это движение для вашей модели игрока",
    ["mmd_vmd_npc.error.no_imported_music"] = "Примечание: у выбранного движения нет импортированной музыки.",
    ["mmd_vmd_npc.error.missing_reference_sequence"] = "У выбранного NPC/игрока нет последовательности Reference. Эта модель пока не поддерживается.",
    ["mmd_vmd_npc.status.actor_playermodel"] = "модель игрока",
    ["mmd_vmd_npc.status.actor_npc"] = "NPC",
    ["mmd_vmd_npc.status.actor_generic"] = "актер",
    ["mmd_vmd_npc.status.actor_select_prompt"] = "щелкните левой кнопкой по NPC/игроку, R чтобы выбрать себя, Shift+R чтобы построить для себя, или E+R чтобы играть на себе",
    ["mmd_vmd_npc.status.invalid_player"] = "недопустимый игрок",
    ["mmd_vmd_npc.status.selected_actor_fmt"] = "выбран %s %s",
    ["mmd_vmd_npc.status.ai_disabled_required"] = "Мышление AI должно быть отключено: выполните ai_disabled 1 перед построением или воспроизведением MMD VMD-анимаций",
    ["mmd_vmd_npc.status.build_missing_instruction"] = " Используйте Shift + левый клик, чтобы построить анимации выбранных NPC.",
    ["mmd_vmd_npc.status.built_cache_missing_options"] = "нет построенного кэша для выбранной модели/параметров.",
    ["mmd_vmd_npc.status.build_missing_group_fmt"] = "нет построения перед синхронным воспроизведением: %s.",
    ["mmd_vmd_npc.status.no_valid_selected_npcs"] = "нет допустимых выбранных NPC для воспроизведения",
    ["mmd_vmd_npc.status.group_countdown_fmt"] = "синхронное воспроизведение на %d NPC начнется через %.1f сек.",
    ["mmd_vmd_npc.status.started_group_fmt"] = "запущено %d синхронных воспроизведений",
    ["mmd_vmd_npc.status.select_npcs_before_group_play"] = "выберите одного или нескольких NPC перед запуском синхронного танца",
    ["mmd_vmd_npc.status.select_first_npc_align"] = "выберите первого NPC перед выравниванием NPC синхронного танца",
    ["mmd_vmd_npc.status.aligned_selected_npcs_fmt"] = "%d выбранных NPC выровнены по первому NPC",
    ["mmd_vmd_npc.status.select_npcs_before_build"] = "выберите одного или нескольких NPC перед построением выбранных анимаций NPC",
    ["mmd_vmd_npc.status.started_queued_builds_fmt"] = "запущено или поставлено в очередь %d построений; %d уже построено",
    ["mmd_vmd_npc.status.failed_suffix"] = "; ошибки: ",
    ["mmd_vmd_npc.status.all_builds_exist_fmt"] = "все построения анимаций выбранных NPC уже существуют (%d)",
    ["mmd_vmd_npc.status.no_selected_build_needed"] = "выбранным NPC не требуется построение",
    ["mmd_vmd_npc.status.removed_npc_selection"] = "NPC удален из выбора синхронного танца",
    ["mmd_vmd_npc.status.invalid_motion_id"] = "недопустимый ID движения",
    ["mmd_vmd_npc.status.assigned_motion_to_npc_fmt"] = "%s назначено NPC %s",
    ["mmd_vmd_npc.status.built_cache_exists"] = "построенный кэш уже существует",
    ["mmd_vmd_npc.status.built_cache_exists_skip_fmt"] = "Построенная анимация уже существует для этой модели/параметров; построение пропущено: %s",
    ["mmd_vmd_npc.status.build_already_fmt"] = "построение уже %s",
    ["mmd_vmd_npc.status.assigned_motion_missing_build"] = "движение назначено; построенный кэш отсутствует.",
    ["mmd_vmd_npc.status.referencef_build_warning_fmt"] = "Предупреждение: модель %s использует %s вместо стандартной последовательности Reference в A-позе. Этот аддон может не полностью поддерживать построение анимации для этой модели.",
    ["mmd_vmd_npc.status.no_active_selected_playback_pause"] = "нет активного выбранного воспроизведения для паузы",
    ["mmd_vmd_npc.status.no_active_playback_pause"] = "нет активного воспроизведения для паузы",
    ["mmd_vmd_npc.status.coordinated_playback_paused"] = "синхронное воспроизведение на паузе",
    ["mmd_vmd_npc.status.coordinated_playback_resumed"] = "синхронное воспроизведение продолжено",
    ["mmd_vmd_npc.hint.self_keys"] = "С инструментом нажмите R, чтобы назначить анимацию себе, Shift+R, чтобы построить ее, и E+R, чтобы воспроизвести ее.",
    ["mmd_vmd_npc.console.no_motions"] = "Файлы движений не найдены.",
    ["mmd_vmd_npc.console.motion_files"] = "Импортированные файлы движений:",
    ["mmd_vmd_npc.console.build_cancelled_fmt"] = "Задачи построения отменены: активных %d, в очереди %d",
    ["mmd_vmd_npc.warning.build_lag_fmt"] = "Построение '%s' обработает %d кадр(ов). Игра может кратко зависнуть или притормозить до завершения прогресса.",
    ["mmd_vmd_npc.hud.build_queued"] = "Построение анимации добавлено в очередь",
    ["mmd_vmd_npc.hud.countdown"] = "Оставшееся время",
    ["mmd_vmd_npc.hud.build"] = "Построение анимации: вычисление кватернионов вращения костей",
    ["mmd_vmd_npc.ui.tool_help"] = "Файлы движений создаются импортером в garrysmod/data/mmd_vmd_npc/motions. ЛКМ по NPC назначает анимацию. Shift+ЛКМ строит выбранных NPC. E+ЛКМ запускает выбранных NPC вместе. Alt+R останавливает все воспроизведения NPC. ПКМ пауза/продолжить. Shift+средняя кнопка выравнивает выбранных NPC по первому. R выбирает вас и назначает текущую анимацию. Shift+R строит для вас. E+R воспроизводит на вас.",
    ["mmd_vmd_npc.ui.tab.motion"] = "Движение",
    ["mmd_vmd_npc.ui.tab.build_playback"] = "Построение и воспроизведение",
    ["mmd_vmd_npc.ui.tab.performance"] = "Производительность",
    ["mmd_vmd_npc.ui.tab.advanced"] = "Дополнительно",
    ["mmd_vmd_npc.ui.selected_motion_none"] = "Выбранное движение: нет",
    ["mmd_vmd_npc.ui.selected_motion_fmt"] = "Выбранное движение: %s",
    ["mmd_vmd_npc.ui.pause_warning_fmt"] = "Предупреждение: sv_pause=%s и sv_pause_sp=%s. Перед построением или воспроизведением установите оба в 0.",
    ["mmd_vmd_npc.ui.music_offset"] = "Смещение музыки (сек.)",
    ["mmd_vmd_npc.ui.play_imported_music"] = "Играть импортированную музыку",
    ["mmd_vmd_npc.ui.play_imported_music_help"] = "Определяет, будет ли музыка выбранного движения играть при следующем запуске.",
    ["mmd_vmd_npc.ui.music_volume"] = "Громкость музыки",
    ["mmd_vmd_npc.ui.loop_playback"] = "Повторять анимацию и музыку",
    ["mmd_vmd_npc.ui.loop_playback_help"] = "Если включено, анимация начнется с первого кадра, а импортированная музыка перезапустится в конце движения.",
    ["mmd_vmd_npc.ui.column.motion"] = "Движение",
    ["mmd_vmd_npc.ui.column.duration"] = "Длительность",
    ["mmd_vmd_npc.ui.column.addon"] = "Из аддона",
    ["mmd_vmd_npc.ui.loading"] = "загрузка",
    ["mmd_vmd_npc.ui.missing"] = "отсутствует",
    ["mmd_vmd_npc.ui.open_motion_manager"] = "Открыть менеджер движений",
    ["mmd_vmd_npc.ui.refresh_motion_list"] = "Обновить список движений",
    ["mmd_vmd_npc.ui.motion_no_metadata"] = "Движение: метаданные не загружены",
    ["mmd_vmd_npc.ui.target"] = "Цель",
    ["mmd_vmd_npc.ui.selected_actor_none"] = "Выбранный актер: нет",
    ["mmd_vmd_npc.ui.selected_actor_fmt"] = "Выбран %s: %s | %s",
    ["mmd_vmd_npc.ui.coordinated_npcs_zero"] = "Синхронные NPC: 0",
    ["mmd_vmd_npc.ui.coordinated_npcs_fmt"] = "Синхронные NPC: %d | первый: %s | движение: %s | статус: %s",
    ["mmd_vmd_npc.ui.play_selected_group"] = "Играть выбранную группу",
    ["mmd_vmd_npc.ui.clear_selection"] = "Очистить выбор",
    ["mmd_vmd_npc.ui.clear_missing_invalid"] = "Очистить отсутствующие/недопустимые",
    ["mmd_vmd_npc.ui.select_yourself"] = "Выбрать себя",
    ["mmd_vmd_npc.ui.build"] = "Построить",
    ["mmd_vmd_npc.ui.build_idle"] = "Построение: ожидание",
    ["mmd_vmd_npc.ui.build_status_fmt"] = "Построение: %s",
    ["mmd_vmd_npc.ui.build_selected_motion"] = "Построить выбранное движение",
    ["mmd_vmd_npc.ui.stop_build_tasks"] = "Остановить все задачи построения",
    ["mmd_vmd_npc.ui.stop_stuck_build_tasks"] = "Остановить зависшие задачи построения",
    ["mmd_vmd_npc.ui.playback"] = "Воспроизведение",
    ["mmd_vmd_npc.ui.playback_idle"] = "Воспроизведение: ожидание",
    ["mmd_vmd_npc.ui.playback_status_fmt"] = "Воспроизведение: %s",
    ["mmd_vmd_npc.ui.play_built_animation"] = "Играть построенную анимацию",
    ["mmd_vmd_npc.ui.stop_animation"] = "Остановить анимацию",
    ["mmd_vmd_npc.ui.start_delay"] = "Задержка старта (сек., мин. 2)",
    ["mmd_vmd_npc.ui.pelvis_z_offset"] = "Смещение таза Z при воспроизведении",
    ["mmd_vmd_npc.ui.eye_tracking"] = "Отслеживание глаз",
    ["mmd_vmd_npc.ui.enable_eye_tracking"] = "Включить отслеживание глаз",
    ["mmd_vmd_npc.ui.enable_eye_tracking_help"] = "Если включено, кости глаз персонажа во время воспроизведения следят за видом текущего игрока.",
    ["mmd_vmd_npc.ui.audio_sync"] = "Синхронизация аудио",
    ["mmd_vmd_npc.ui.manage_built_cache"] = "Управление кэшем построения",
    ["mmd_vmd_npc.ui.build_performance"] = "Производительность построения",
    ["mmd_vmd_npc.ui.playback_performance"] = "Производительность воспроизведения",
    ["mmd_vmd_npc.ui.disable_armtwist"] = "Отключить трансформации ZArmTwist",
    ["mmd_vmd_npc.ui.disable_handtwist"] = "Отключить трансформации поворота кистей",
    ["mmd_vmd_npc.ui.disable_eyes"] = "Отключить трансформации глаз",
    ["mmd_vmd_npc.ui.disable_spine_pelvis"] = "Отключить коррекцию таза/позвоночника",
    ["mmd_vmd_npc.ui.debug_selected_motion"] = "Отладить выбранное движение",
    ["mmd_vmd_npc.ui.motion_info_fmt"] = "Движение: %s | %.2fs | %d кадр. | %d кост. | %d flex | музыка: %s | построено: %s",
    ["mmd_vmd_npc.ui.yes"] = "да",
    ["mmd_vmd_npc.ui.no"] = "нет",
    ["mmd_vmd_npc.ui.none"] = "нет",
    ["mmd_vmd_npc.ui.unknown"] = "неизвестно",
    ["mmd_vmd_npc.manager.title"] = "Менеджер движений",
    ["mmd_vmd_npc.manager.search_placeholder"] = "Поиск ID движения, источника или музыки",
    ["mmd_vmd_npc.manager.refresh"] = "Обновить",
    ["mmd_vmd_npc.manager.column_addon"] = "Из аддона",
    ["mmd_vmd_npc.manager.play_music"] = "Играть музыку",
    ["mmd_vmd_npc.manager.volume"] = "Громкость",
    ["mmd_vmd_npc.manager.save_offset"] = "Сохранить смещение",
    ["mmd_vmd_npc.manager.delete_motion_music"] = "Удалить движение и музыку",
    ["mmd_vmd_npc.manager.delete_confirm"] = "Удалить",
    ["mmd_vmd_npc.manager.cancel"] = "Отмена",
})

MMDVMDNPC.I18N.ar = merge_i18n({
    ["mmd_vmd_npc.category"] = "التحريك",
    ["tool.mmd_vmd_npc.name"] = "مشغل تحريك MMD متقدم",
    ["tool.mmd_vmd_npc.desc"] = "تشغيل تحريك MMD على الشخصيات أو على نفسك",
    ["tool.mmd_vmd_npc.0"] = "استخدم صفوف المفاتيح أدناه لإجراءات تحريك MMD VMD.",
    ["tool.mmd_vmd_npc.left"] = "تعيين التحريك المحدد للشخصية التي تم النقر عليها",
    ["tool.mmd_vmd_npc.left_use"] = "تشغيل كل الشخصيات المحددة معاً",
    ["tool.mmd_vmd_npc.left_speed"] = "بناء التحريكات المعينة للشخصيات المحددة",
    ["tool.mmd_vmd_npc.left_alt"] = "محاذاة الشخصيات المحددة مع الأولى",
    ["tool.mmd_vmd_npc.reload_alt"] = "إيقاف كل تشغيلات NPC النشطة",
    ["tool.mmd_vmd_npc.right"] = "إيقاف مؤقت/استئناف التشغيل",
    ["tool.mmd_vmd_npc.right_speed"] = "فتح قائمة تعيين الحركة/التعابير للهدف المحدد أو آخر كيان محدد",
    ["tool.mmd_vmd_npc.middle_speed"] = "محاذاة الشخصيات المحددة مع الأولى",
    ["tool.mmd_vmd_npc.right_speed_use"] = "+ E: محاذاة الشخصيات المحددة مع الأولى",
    ["tool.mmd_vmd_npc.reload"] = "اختيار نفسك وتعيين التحريك",
    ["tool.mmd_vmd_npc.reload_use"] = "تشغيل الحركة المحددة على نفسك",
    ["tool.mmd_vmd_npc.reload_speed"] = "بناء الحركة المحددة لنفسك",
    ["mmd_vmd_npc.error.left_click_valid_npc"] = "انقر بالزر الأيسر على شخصية NPC صالحة لاختيار رقصة منسقة",
    ["mmd_vmd_npc.error.select_motion"] = "يرجى اختيار ملف حركة JSON أولاً",
    ["mmd_vmd_npc.error.shift_right_click_valid_actor"] = "استخدم Shift+النقر الأيمن على NPC/لاعب صالح",
    ["mmd_vmd_npc.error.build_self_first"] = "ابن هذه الحركة لنموذج اللاعب الخاص بك أولاً",
    ["mmd_vmd_npc.error.no_imported_music"] = "ملاحظة: لا توجد موسيقى مستوردة للحركة المحددة.",
    ["mmd_vmd_npc.error.missing_reference_sequence"] = "لا يملك الـ NPC/اللاعب المحدد تسلسل Reference. هذا النموذج غير مدعوم حالياً.",
    ["mmd_vmd_npc.status.actor_playermodel"] = "نموذج اللاعب",
    ["mmd_vmd_npc.status.actor_npc"] = "NPC",
    ["mmd_vmd_npc.status.actor_generic"] = "هدف",
    ["mmd_vmd_npc.status.actor_select_prompt"] = "انقر يساراً على NPC/لاعب صالح، R لاختيار نفسك، Shift+R للبناء لنفسك، أو E+R للتشغيل على نفسك",
    ["mmd_vmd_npc.status.invalid_player"] = "لاعب غير صالح",
    ["mmd_vmd_npc.status.selected_actor_fmt"] = "تم اختيار %s %s",
    ["mmd_vmd_npc.status.ai_disabled_required"] = "يجب تعطيل تفكير AI: نفذ ai_disabled 1 قبل بناء أو تشغيل تحريكات MMD VMD",
    ["mmd_vmd_npc.status.build_missing_instruction"] = " استخدم Shift + النقر الأيسر لبناء تحريك الشخصيات المحددة.",
    ["mmd_vmd_npc.status.built_cache_missing_options"] = "ذاكرة البناء المؤقتة مفقودة للنموذج/الخيارات المحددة.",
    ["mmd_vmd_npc.status.build_missing_group_fmt"] = "البناء مفقود قبل التشغيل المنسق: %s.",
    ["mmd_vmd_npc.status.no_valid_selected_npcs"] = "لا توجد شخصيات محددة صالحة للتشغيل",
    ["mmd_vmd_npc.status.group_countdown_fmt"] = "سيبدأ التشغيل المنسق على %d شخصية خلال %.1f ثانية",
    ["mmd_vmd_npc.status.started_group_fmt"] = "بدأ %d تشغيل منسق",
    ["mmd_vmd_npc.status.select_npcs_before_group_play"] = "اختر شخصية واحدة أو أكثر قبل بدء رقصة منسقة",
    ["mmd_vmd_npc.status.select_first_npc_align"] = "اختر الشخصية الأولى قبل محاذاة شخصيات الرقصة المنسقة",
    ["mmd_vmd_npc.status.aligned_selected_npcs_fmt"] = "تمت محاذاة %d شخصية محددة مع الشخصية الأولى",
    ["mmd_vmd_npc.status.select_npcs_before_build"] = "اختر شخصية واحدة أو أكثر قبل بناء تحريكات الشخصيات المحددة",
    ["mmd_vmd_npc.status.started_queued_builds_fmt"] = "بدأ أو تم وضع %d بناء في الانتظار؛ %d مبنية مسبقاً",
    ["mmd_vmd_npc.status.failed_suffix"] = "؛ فشل: ",
    ["mmd_vmd_npc.status.all_builds_exist_fmt"] = "كل بناءات تحريك الشخصيات المحددة موجودة مسبقاً (%d)",
    ["mmd_vmd_npc.status.no_selected_build_needed"] = "لا توجد شخصيات محددة تحتاج إلى بناء",
    ["mmd_vmd_npc.status.removed_npc_selection"] = "تمت إزالة الشخصية من اختيار الرقصة المنسقة",
    ["mmd_vmd_npc.status.invalid_motion_id"] = "معرف حركة غير صالح",
    ["mmd_vmd_npc.status.assigned_motion_to_npc_fmt"] = "تم تعيين %s إلى NPC %s",
    ["mmd_vmd_npc.status.built_cache_exists"] = "ذاكرة البناء المؤقتة موجودة مسبقاً",
    ["mmd_vmd_npc.status.built_cache_exists_skip_fmt"] = "التحريك المبني موجود مسبقاً لهذا النموذج/الخيارات؛ تم تخطي البناء: %s",
    ["mmd_vmd_npc.status.build_already_fmt"] = "البناء في حالة %s مسبقاً",
    ["mmd_vmd_npc.status.assigned_motion_missing_build"] = "تم تعيين الحركة؛ ذاكرة البناء المؤقتة مفقودة.",
    ["mmd_vmd_npc.status.referencef_build_warning_fmt"] = "تحذير: النموذج %s يستخدم %s بدلاً من تسلسل Reference القياسي بوضعية A. قد لا تدعم هذه الإضافة بناء التحريك لهذا النموذج بشكل كامل.",
    ["mmd_vmd_npc.status.no_active_selected_playback_pause"] = "لا يوجد تشغيل محدد نشط لإيقافه مؤقتاً",
    ["mmd_vmd_npc.status.no_active_playback_pause"] = "لا يوجد تشغيل نشط لإيقافه مؤقتاً",
    ["mmd_vmd_npc.status.coordinated_playback_paused"] = "تم إيقاف التشغيل المنسق مؤقتاً",
    ["mmd_vmd_npc.status.coordinated_playback_resumed"] = "تم استئناف التشغيل المنسق",
    ["mmd_vmd_npc.hint.self_keys"] = "اضغط R أثناء حمل الأداة لتعيين التحريك لنفسك، و Shift+R لبنائه، و E+R لتشغيله على نفسك.",
    ["mmd_vmd_npc.console.no_motions"] = "لم يتم العثور على ملفات حركة.",
    ["mmd_vmd_npc.console.motion_files"] = "ملفات الحركة المستوردة:",
    ["mmd_vmd_npc.console.build_cancelled_fmt"] = "تم إلغاء مهام البناء: نشطة %d، في الانتظار %d",
    ["mmd_vmd_npc.warning.build_lag_fmt"] = "بناء '%s' سيعالج %d إطاراً. قد يتباطأ اللعب أو يتجمد مؤقتاً حتى ينتهي شريط التقدم.",
    ["mmd_vmd_npc.hud.build_queued"] = "تم وضع بناء التحريك في قائمة الانتظار",
    ["mmd_vmd_npc.hud.countdown"] = "الوقت المتبقي المقدر",
    ["mmd_vmd_npc.hud.build"] = "جاري بناء التحريك: حساب دوران العظام",
    ["mmd_vmd_npc.ui.tool_help"] = "يتم إنشاء ملفات الحركة بواسطة المستورد في garrysmod/data/mmd_vmd_npc/motions. النقر الأيسر على NPC لتعيين التحريك. Shift+النقر الأيسر يبني الشخصيات المحددة. E+النقر الأيسر يبدأ كل الشخصيات المحددة معاً. Alt+R يوقف كل تشغيل NPC. النقر الأيمن يوقف/يستأنف. Shift+النقر الأوسط يحاذي الشخصيات المحددة مع الأولى. R يختارك ويعين التحريك الحالي. Shift+R يبني لنفسك. E+R يشغل على نفسك.",
    ["mmd_vmd_npc.ui.tab.motion"] = "الحركة",
    ["mmd_vmd_npc.ui.tab.build_playback"] = "البناء والتشغيل",
    ["mmd_vmd_npc.ui.tab.performance"] = "الأداء",
    ["mmd_vmd_npc.ui.tab.advanced"] = "متقدم",
    ["mmd_vmd_npc.ui.selected_motion_none"] = "الحركة المحددة: لا شيء",
    ["mmd_vmd_npc.ui.selected_motion_fmt"] = "الحركة المحددة: %s",
    ["mmd_vmd_npc.ui.pause_warning_fmt"] = "تحذير: sv_pause=%s و sv_pause_sp=%s. اضبطهما على 0 قبل بناء أو تشغيل التحريك.",
    ["mmd_vmd_npc.ui.music_offset"] = "إزاحة الموسيقى (ثوان)",
    ["mmd_vmd_npc.ui.play_imported_music"] = "تشغيل الموسيقى المستوردة",
    ["mmd_vmd_npc.ui.play_imported_music_help"] = "يتحكم في تشغيل موسيقى الحركة المحددة عند التشغيل التالي.",
    ["mmd_vmd_npc.ui.music_volume"] = "مستوى الموسيقى",
    ["mmd_vmd_npc.ui.loop_playback"] = "تكرار الحركة والموسيقى",
    ["mmd_vmd_npc.ui.loop_playback_help"] = "عند التفعيل، تبدأ الحركة من الإطار الأول من جديد وتُعاد الموسيقى المستوردة عند انتهاء الحركة.",
    ["mmd_vmd_npc.ui.column.motion"] = "الحركة",
    ["mmd_vmd_npc.ui.column.duration"] = "المدة",
    ["mmd_vmd_npc.ui.column.addon"] = "من الإضافة",
    ["mmd_vmd_npc.ui.loading"] = "جار التحميل",
    ["mmd_vmd_npc.ui.missing"] = "مفقود",
    ["mmd_vmd_npc.ui.open_motion_manager"] = "فتح مدير الحركات",
    ["mmd_vmd_npc.ui.refresh_motion_list"] = "تحديث قائمة الحركات",
    ["mmd_vmd_npc.ui.motion_no_metadata"] = "الحركة: لا توجد بيانات وصفية",
    ["mmd_vmd_npc.ui.target"] = "الهدف",
    ["mmd_vmd_npc.ui.selected_actor_none"] = "الهدف المحدد: لا شيء",
    ["mmd_vmd_npc.ui.selected_actor_fmt"] = "تم تحديد %s: %s | %s",
    ["mmd_vmd_npc.ui.coordinated_npcs_zero"] = "شخصيات منسقة: 0",
    ["mmd_vmd_npc.ui.coordinated_npcs_fmt"] = "شخصيات منسقة: %d | الأولى: %s | الحركة: %s | الحالة: %s",
    ["mmd_vmd_npc.ui.play_selected_group"] = "تشغيل المجموعة المحددة",
    ["mmd_vmd_npc.ui.clear_selection"] = "مسح التحديد",
    ["mmd_vmd_npc.ui.clear_missing_invalid"] = "مسح المفقود/غير الصالح",
    ["mmd_vmd_npc.ui.select_yourself"] = "اختيار نفسك",
    ["mmd_vmd_npc.ui.build"] = "بناء",
    ["mmd_vmd_npc.ui.build_idle"] = "البناء: خامل",
    ["mmd_vmd_npc.ui.build_status_fmt"] = "البناء: %s",
    ["mmd_vmd_npc.ui.build_selected_motion"] = "بناء الحركة المحددة",
    ["mmd_vmd_npc.ui.stop_build_tasks"] = "إيقاف كل مهام البناء",
    ["mmd_vmd_npc.ui.stop_stuck_build_tasks"] = "إيقاف مهام البناء العالقة",
    ["mmd_vmd_npc.ui.playback"] = "التشغيل",
    ["mmd_vmd_npc.ui.playback_idle"] = "التشغيل: خامل",
    ["mmd_vmd_npc.ui.playback_status_fmt"] = "التشغيل: %s",
    ["mmd_vmd_npc.ui.play_built_animation"] = "تشغيل التحريك المبني",
    ["mmd_vmd_npc.ui.stop_animation"] = "إيقاف التحريك",
    ["mmd_vmd_npc.ui.start_delay"] = "تأخير البدء (ثوان، الحد الأدنى 2)",
    ["mmd_vmd_npc.ui.pelvis_z_offset"] = "إزاحة Z للحوض أثناء التشغيل",
    ["mmd_vmd_npc.ui.eye_tracking"] = "تتبع العين",
    ["mmd_vmd_npc.ui.enable_eye_tracking"] = "تفعيل تتبع العين",
    ["mmd_vmd_npc.ui.enable_eye_tracking_help"] = "عند التفعيل، تتبع عظام العين منظور اللاعب الحالي أثناء التشغيل.",
    ["mmd_vmd_npc.ui.audio_sync"] = "مزامنة الصوت",
    ["mmd_vmd_npc.ui.manage_built_cache"] = "إدارة ذاكرة البناء",
    ["mmd_vmd_npc.ui.build_performance"] = "أداء البناء",
    ["mmd_vmd_npc.ui.playback_performance"] = "أداء التشغيل",
    ["mmd_vmd_npc.ui.disable_armtwist"] = "تعطيل تحويلات ZArmTwist",
    ["mmd_vmd_npc.ui.disable_handtwist"] = "تعطيل تحويلات التواء اليد",
    ["mmd_vmd_npc.ui.disable_eyes"] = "تعطيل تحويلات العين",
    ["mmd_vmd_npc.ui.disable_spine_pelvis"] = "تعطيل تصحيح الحوض/العمود",
    ["mmd_vmd_npc.ui.debug_selected_motion"] = "تصحيح الحركة المحددة",
    ["mmd_vmd_npc.ui.motion_info_fmt"] = "الحركة: %s | %.2fs | %d إطار | %d عظمة | %d تعبير | موسيقى: %s | مبني: %s",
    ["mmd_vmd_npc.ui.yes"] = "نعم",
    ["mmd_vmd_npc.ui.no"] = "لا",
    ["mmd_vmd_npc.ui.none"] = "لا شيء",
    ["mmd_vmd_npc.ui.unknown"] = "غير معروف",
    ["mmd_vmd_npc.manager.title"] = "مدير الحركات",
    ["mmd_vmd_npc.manager.search_placeholder"] = "بحث عن معرف الحركة أو المصدر أو الموسيقى",
    ["mmd_vmd_npc.manager.refresh"] = "تحديث",
    ["mmd_vmd_npc.manager.column_addon"] = "من الإضافة",
    ["mmd_vmd_npc.manager.play_music"] = "تشغيل الموسيقى",
    ["mmd_vmd_npc.manager.volume"] = "المستوى",
    ["mmd_vmd_npc.manager.save_offset"] = "حفظ الإزاحة",
    ["mmd_vmd_npc.manager.delete_motion_music"] = "حذف الحركة + الموسيقى",
    ["mmd_vmd_npc.manager.delete_confirm"] = "حذف",
    ["mmd_vmd_npc.manager.cancel"] = "إلغاء",
})

MMDVMDNPC.I18N.es = merge_i18n({
    ["mmd_vmd_npc.category"] = "Animación",
    ["tool.mmd_vmd_npc.name"] = "Reproductor avanzado de animaciones MMD",
    ["tool.mmd_vmd_npc.desc"] = "Reproduce animaciones MMD en NPCs o en ti",
    ["tool.mmd_vmd_npc.0"] = "Usa las filas de teclas de abajo para las acciones de animación MMD VMD.",
    ["tool.mmd_vmd_npc.left"] = "Asignar la animación seleccionada al NPC clicado",
    ["tool.mmd_vmd_npc.left_use"] = "Iniciar juntos todos los NPCs seleccionados",
    ["tool.mmd_vmd_npc.left_speed"] = "Construir animaciones asignadas para NPCs seleccionados",
    ["tool.mmd_vmd_npc.left_alt"] = "Alinear NPCs seleccionados con el primero",
    ["tool.mmd_vmd_npc.reload_alt"] = "Detener toda reproducción activa de NPCs",
    ["tool.mmd_vmd_npc.right"] = "Pausar/reanudar reproducción",
    ["tool.mmd_vmd_npc.right_speed"] = "Abrir el menú de asignación de movimiento/flex del objetivo clicado o último actor seleccionado",
    ["tool.mmd_vmd_npc.middle_speed"] = "Alinear NPCs seleccionados con el primero",
    ["tool.mmd_vmd_npc.right_speed_use"] = "+ E: alinear NPCs seleccionados con el primero",
    ["tool.mmd_vmd_npc.reload"] = "Seleccionarte y asignar animación",
    ["tool.mmd_vmd_npc.reload_use"] = "Reproducir el movimiento seleccionado en ti",
    ["tool.mmd_vmd_npc.reload_speed"] = "Construir el movimiento seleccionado para ti",
    ["mmd_vmd_npc.error.left_click_valid_npc"] = "haz clic izquierdo en un NPC válido para una selección de baile coordinado",
    ["mmd_vmd_npc.error.select_motion"] = "Selecciona primero un JSON de movimiento",
    ["mmd_vmd_npc.error.shift_right_click_valid_actor"] = "Shift+clic derecho en un NPC/jugador válido",
    ["mmd_vmd_npc.error.build_self_first"] = "construye primero este movimiento para tu modelo de jugador",
    ["mmd_vmd_npc.error.no_imported_music"] = "Nota: el movimiento seleccionado no tiene música importada.",
    ["mmd_vmd_npc.error.missing_reference_sequence"] = "El NPC/jugador seleccionado no tiene secuencia Reference. Este modelo aún no está soportado.",
    ["mmd_vmd_npc.status.actor_playermodel"] = "modelo de jugador",
    ["mmd_vmd_npc.status.actor_npc"] = "NPC",
    ["mmd_vmd_npc.status.actor_generic"] = "actor",
    ["mmd_vmd_npc.status.actor_select_prompt"] = "clic izquierdo en un NPC/jugador válido, R para seleccionarte, Shift+R para construirte, o E+R para reproducirte",
    ["mmd_vmd_npc.status.invalid_player"] = "jugador no válido",
    ["mmd_vmd_npc.status.selected_actor_fmt"] = "%s %s seleccionado",
    ["mmd_vmd_npc.status.ai_disabled_required"] = "La IA debe estar desactivada: ejecuta ai_disabled 1 antes de construir o reproducir animaciones MMD VMD",
    ["mmd_vmd_npc.status.build_missing_instruction"] = " Usa Shift + clic izquierdo para construir las animaciones de los NPCs seleccionados.",
    ["mmd_vmd_npc.status.built_cache_missing_options"] = "falta la caché construida para el modelo/opciones seleccionados.",
    ["mmd_vmd_npc.status.build_missing_group_fmt"] = "falta construcción antes de la reproducción coordinada: %s.",
    ["mmd_vmd_npc.status.no_valid_selected_npcs"] = "no hay NPCs seleccionados válidos para reproducir",
    ["mmd_vmd_npc.status.group_countdown_fmt"] = "la reproducción coordinada empieza en %d NPC(s) en %.1f segundos",
    ["mmd_vmd_npc.status.started_group_fmt"] = "iniciadas %d reproducciones coordinadas",
    ["mmd_vmd_npc.status.select_npcs_before_group_play"] = "selecciona uno o más NPCs antes de iniciar un baile coordinado",
    ["mmd_vmd_npc.status.select_first_npc_align"] = "selecciona un primer NPC antes de alinear NPCs de baile coordinado",
    ["mmd_vmd_npc.status.aligned_selected_npcs_fmt"] = "%d NPC(s) seleccionados alineados con el primer NPC",
    ["mmd_vmd_npc.status.select_npcs_before_build"] = "selecciona uno o más NPCs antes de construir animaciones de NPC seleccionados",
    ["mmd_vmd_npc.status.started_queued_builds_fmt"] = "iniciadas o en cola %d construcciones; %d ya construidas",
    ["mmd_vmd_npc.status.failed_suffix"] = "; falló: ",
    ["mmd_vmd_npc.status.all_builds_exist_fmt"] = "todas las construcciones de animación de NPCs seleccionados ya existen (%d)",
    ["mmd_vmd_npc.status.no_selected_build_needed"] = "ningún NPC seleccionado necesita construcción",
    ["mmd_vmd_npc.status.removed_npc_selection"] = "NPC eliminado de la selección de baile coordinado",
    ["mmd_vmd_npc.status.invalid_motion_id"] = "ID de movimiento no válido",
    ["mmd_vmd_npc.status.assigned_motion_to_npc_fmt"] = "%s asignado al NPC %s",
    ["mmd_vmd_npc.status.built_cache_exists"] = "la caché construida ya existe",
    ["mmd_vmd_npc.status.built_cache_exists_skip_fmt"] = "La animación construida ya existe para este modelo/opciones; se omite la construcción: %s",
    ["mmd_vmd_npc.status.build_already_fmt"] = "construcción ya %s",
    ["mmd_vmd_npc.status.assigned_motion_missing_build"] = "movimiento asignado; falta caché construida.",
    ["mmd_vmd_npc.status.referencef_build_warning_fmt"] = "Advertencia: el modelo %s usa %s en lugar de la secuencia Reference estándar en pose A. Este addon podría no soportar completamente la construcción de animación para este modelo.",
    ["mmd_vmd_npc.status.no_active_selected_playback_pause"] = "no hay reproducción seleccionada activa para pausar",
    ["mmd_vmd_npc.status.no_active_playback_pause"] = "no hay reproducción activa para pausar",
    ["mmd_vmd_npc.status.coordinated_playback_paused"] = "reproducción coordinada pausada",
    ["mmd_vmd_npc.status.coordinated_playback_resumed"] = "reproducción coordinada reanudada",
    ["mmd_vmd_npc.hint.self_keys"] = "Con la herramienta equipada, pulsa R para asignarte la animación, Shift+R para construirla y E+R para reproducirla en ti.",
    ["mmd_vmd_npc.console.no_motions"] = "No se encontraron archivos de movimiento.",
    ["mmd_vmd_npc.console.motion_files"] = "Archivos de movimiento importados:",
    ["mmd_vmd_npc.console.failed_preview_music_fmt"] = "Error al previsualizar música: %s",
    ["mmd_vmd_npc.console.failed_play_music_fmt"] = "Error al reproducir música %s: %s",
    ["mmd_vmd_npc.console.debug_failed_fmt"] = "Error de depuración para %s: %s",
    ["mmd_vmd_npc.console.build_success_fmt"] = "Animación construida: %s",
    ["mmd_vmd_npc.console.build_failed_fmt"] = "Error al construir animación: %s",
    ["mmd_vmd_npc.console.build_cancelled_fmt"] = "Tareas de construcción canceladas: activas %d, en cola %d",
    ["mmd_vmd_npc.console.built_removed_fmt"] = "cachés construidas eliminadas: %s",
    ["mmd_vmd_npc.console.music_removed_fmt"] = "música eliminada: %s",
    ["mmd_vmd_npc.console.music_checked_fmt"] = "música revisada: %s",
    ["mmd_vmd_npc.console.debug_usage"] = "Uso: mmdvmd_debug <motion_id> [frame]",
    ["mmd_vmd_npc.warning.build_lag_fmt"] = "Construir '%s' procesará %d fotograma(s). El juego puede sufrir pausas breves hasta que termine la barra de progreso.",
    ["mmd_vmd_npc.hud.build_queued"] = "Construcción de animación en cola",
    ["mmd_vmd_npc.hud.countdown"] = "Tiempo restante estimado",
    ["mmd_vmd_npc.hud.build"] = "Construyendo animación: calculando tensores de rotación de huesos",
    ["mmd_vmd_npc.ui.tool_help"] = "El importador genera los movimientos en garrysmod/data/mmd_vmd_npc/motions. Clic izquierdo en un NPC para asignar. Shift+clic izquierdo construye los NPCs seleccionados. E+clic izquierdo inicia todos los NPCs seleccionados juntos. Alt+R detiene toda reproducción de NPCs. Clic derecho pausa/reanuda. Shift+clic central alinea los NPCs seleccionados con el primero. R te selecciona y asigna la animación actual. Shift+R construye para ti. E+R reproduce en ti.",
    ["mmd_vmd_npc.ui.tab.motion"] = "Movimiento",
    ["mmd_vmd_npc.ui.tab.build_playback"] = "Construcción y reproducción",
    ["mmd_vmd_npc.ui.tab.performance"] = "Rendimiento",
    ["mmd_vmd_npc.ui.tab.advanced"] = "Avanzado",
    ["mmd_vmd_npc.ui.selected_motion_none"] = "Movimiento seleccionado: ninguno",
    ["mmd_vmd_npc.ui.selected_motion_fmt"] = "Movimiento seleccionado: %s",
    ["mmd_vmd_npc.ui.pause_warning_fmt"] = "Advertencia: sv_pause=%s y sv_pause_sp=%s. Pon ambos en 0 antes de construir o reproducir animaciones.",
    ["mmd_vmd_npc.ui.music_offset"] = "Desfase de música (segundos)",
    ["mmd_vmd_npc.ui.play_imported_music"] = "Reproducir música importada",
    ["mmd_vmd_npc.ui.play_imported_music_help"] = "Controla si la música importada del movimiento seleccionado se reproduce la próxima vez.",
    ["mmd_vmd_npc.ui.music_volume"] = "Volumen de música",
    ["mmd_vmd_npc.ui.loop_playback"] = "Repetir animación y música",
    ["mmd_vmd_npc.ui.loop_playback_help"] = "Si está activado, la animación vuelve al primer fotograma y la música importada se reinicia cuando termina el movimiento.",
    ["mmd_vmd_npc.ui.column.motion"] = "Movimiento",
    ["mmd_vmd_npc.ui.column.duration"] = "Duración",
    ["mmd_vmd_npc.ui.column.addon"] = "Desde addon",
    ["mmd_vmd_npc.ui.loading"] = "cargando",
    ["mmd_vmd_npc.ui.missing"] = "faltante",
    ["mmd_vmd_npc.ui.open_motion_manager"] = "Abrir gestor de movimientos",
    ["mmd_vmd_npc.ui.refresh_motion_list"] = "Actualizar lista de movimientos",
    ["mmd_vmd_npc.ui.motion_no_metadata"] = "Movimiento: metadatos no cargados",
    ["mmd_vmd_npc.ui.target"] = "Objetivo",
    ["mmd_vmd_npc.ui.selected_actor_none"] = "Actor seleccionado: ninguno",
    ["mmd_vmd_npc.ui.selected_actor_fmt"] = "%s seleccionado: %s | %s",
    ["mmd_vmd_npc.ui.coordinated_npcs_zero"] = "NPCs coordinados: 0",
    ["mmd_vmd_npc.ui.coordinated_npcs_fmt"] = "NPCs coordinados: %d | primero: %s | movimiento: %s | estado: %s",
    ["mmd_vmd_npc.ui.play_selected_group"] = "Reproducir grupo seleccionado",
    ["mmd_vmd_npc.ui.clear_selection"] = "Limpiar selección",
    ["mmd_vmd_npc.ui.clear_missing_invalid"] = "Limpiar faltantes/no válidos",
    ["mmd_vmd_npc.ui.select_yourself"] = "Seleccionarte",
    ["mmd_vmd_npc.ui.self_help"] = "Haz clic izquierdo en un NPC/jugador para seleccionarlo. R te selecciona y asigna la animación actual; Shift+R la construye para ti; E+R reproduce mediante un modelo temporal.",
    ["mmd_vmd_npc.ui.build"] = "Construir",
    ["mmd_vmd_npc.ui.build_idle"] = "Construcción: inactiva",
    ["mmd_vmd_npc.ui.build_status_fmt"] = "Construcción: %s",
    ["mmd_vmd_npc.ui.build_selected_motion"] = "Construir movimiento seleccionado",
    ["mmd_vmd_npc.ui.stop_build_tasks"] = "Detener todas las construcciones",
    ["mmd_vmd_npc.ui.stop_stuck_build_tasks"] = "Detener construcciones atascadas",
    ["mmd_vmd_npc.ui.playback"] = "Reproducción",
    ["mmd_vmd_npc.ui.playback_idle"] = "Reproducción: inactiva",
    ["mmd_vmd_npc.ui.playback_status_fmt"] = "Reproducción: %s",
    ["mmd_vmd_npc.ui.play_built_animation"] = "Reproducir animación construida",
    ["mmd_vmd_npc.ui.stop_animation"] = "Detener animación",
    ["mmd_vmd_npc.ui.start_delay"] = "Retraso de inicio (segundos, mín. 2)",
    ["mmd_vmd_npc.ui.pelvis_z_offset"] = "Desplazamiento Z de pelvis al reproducir",
    ["mmd_vmd_npc.ui.thirdperson_distance"] = "Distancia de tercera persona",
    ["mmd_vmd_npc.ui.thirdperson_height"] = "Altura de tercera persona",
    ["mmd_vmd_npc.ui.eye_tracking"] = "Seguimiento ocular",
    ["mmd_vmd_npc.ui.enable_eye_tracking"] = "Activar seguimiento ocular",
    ["mmd_vmd_npc.ui.enable_eye_tracking_help"] = "Cuando está activado, los huesos de ojos del personaje siguen la vista del jugador durante la reproducción.",
    ["mmd_vmd_npc.ui.eye_smoothing"] = "Velocidad de suavizado",
    ["mmd_vmd_npc.ui.eye_moveback"] = "Factor de retroceso de ojos",
    ["mmd_vmd_npc.ui.eye_pos_ud"] = "Escala de posición de ojos (arriba/abajo)",
    ["mmd_vmd_npc.ui.eye_pos_lr"] = "Escala de posición de ojos (izquierda/derecha)",
    ["mmd_vmd_npc.ui.eye_no_target"] = "Ojos: sin objetivo de reproducción",
    ["mmd_vmd_npc.ui.eye_status_unavailable"] = "Ojos: estado no disponible",
    ["mmd_vmd_npc.ui.audio_sync"] = "Sincronización de audio",
    ["mmd_vmd_npc.ui.audio_sync_help"] = "Abre el gestor para previsualizar música, guardar desfases y gestionar cachés construidas.",
    ["mmd_vmd_npc.ui.manage_built_cache"] = "Gestionar caché construida",
    ["mmd_vmd_npc.ui.clear_built_model"] = "Limpiar para modelo seleccionado",
    ["mmd_vmd_npc.ui.clear_built_all"] = "Limpiar para todos los modelos",
    ["mmd_vmd_npc.ui.build_performance"] = "Rendimiento de construcción",
    ["mmd_vmd_npc.ui.build_performance_help"] = "Valores de lote más altos terminan antes, pero pueden pausar brevemente el cliente.",
    ["mmd_vmd_npc.ui.build_frames_per_batch"] = "Fotogramas por lote de construcción",
    ["mmd_vmd_npc.ui.playback_performance"] = "Rendimiento de reproducción",
    ["mmd_vmd_npc.ui.playback_performance_help"] = "Frecuencias de actualización más altas suavizan la interpolación. Valores menores reducen carga.",
    ["mmd_vmd_npc.ui.playback_updates_per_second"] = "Actualizaciones de reproducción por segundo",
    ["mmd_vmd_npc.ui.disable_armtwist"] = "Desactivar transformaciones ZArmTwist",
    ["mmd_vmd_npc.ui.disable_handtwist"] = "Desactivar torsiones de manos",
    ["mmd_vmd_npc.ui.disable_eyes"] = "Desactivar transformaciones de ojos",
    ["mmd_vmd_npc.ui.disable_spine_pelvis"] = "Desactivar corrección pelvis/columna",
    ["mmd_vmd_npc.ui.debug_selected_motion"] = "Depurar movimiento seleccionado",
    ["mmd_vmd_npc.ui.motion_info_fmt"] = "Movimiento: %s | %.2fs | %d fotograma(s) | %d hueso(s) | %d flex | música: %s | construido: %s",
    ["mmd_vmd_npc.ui.motion_metadata_missing_fmt"] = "Movimiento: %s | metadatos no cargados",
    ["mmd_vmd_npc.ui.motion_none"] = "Movimiento: ninguno",
    ["mmd_vmd_npc.ui.yes"] = "sí",
    ["mmd_vmd_npc.ui.no"] = "no",
    ["mmd_vmd_npc.ui.none"] = "ninguno",
    ["mmd_vmd_npc.ui.not_found"] = "no encontrado",
    ["mmd_vmd_npc.ui.unknown"] = "desconocido",
    ["mmd_vmd_npc.ui.actor"] = "actor",
    ["mmd_vmd_npc.ui.idle"] = "inactivo",
    ["mmd_vmd_npc.ui.motion"] = "movimiento",
    ["mmd_vmd_npc.ui.built"] = "construido",
    ["mmd_vmd_npc.ui.eye_status_none"] = "Ojos: sin objetivo de reproducción",
    ["mmd_vmd_npc.ui.eye_status_fmt"] = "Ojos: L=%s | R=%s",
    ["mmd_vmd_npc.ui.eye_bone_fmt"] = "%s (#%d)",
    ["mmd_vmd_npc.debug.title_fmt"] = "Depuración de animación bruta - %s",
    ["mmd_vmd_npc.debug.summary_fmt"] = "%s | fotograma %d / %d | %.3fs / %.3fs | %d hueso(s) animados | %d flex(es)%s",
    ["mmd_vmd_npc.debug.preview_entity_fmt"] = " | entidad de vista previa %s",
    ["mmd_vmd_npc.debug.reference_fmt"] = " | referencia: %s",
    ["mmd_vmd_npc.debug.column_mmd_bone"] = "Nombre de hueso MMD",
    ["mmd_vmd_npc.debug.column_source_bone"] = "Hueso asignado",
    ["mmd_vmd_npc.debug.column_role"] = "Rol",
    ["mmd_vmd_npc.debug.column_raw_x"] = "Raw +X izquierda",
    ["mmd_vmd_npc.debug.column_raw_y"] = "Raw +Y frente",
    ["mmd_vmd_npc.debug.column_raw_z"] = "Raw +Z arriba",
    ["mmd_vmd_npc.debug.column_bone_position"] = "Posición de hueso (X, Y, Z)",
    ["mmd_vmd_npc.debug.column_manip_angles"] = "ManipulateBoneAngles local (P, Y, R)",
    ["mmd_vmd_npc.debug.column_mmd_morph"] = "Nombre de morph MMD",
    ["mmd_vmd_npc.debug.column_source_flex"] = "Flex asignado",
    ["mmd_vmd_npc.debug.column_weight"] = "Peso",
    ["mmd_vmd_npc.debug.column_target"] = "Objetivo",
    ["mmd_vmd_npc.debug.previous"] = "Anterior",
    ["mmd_vmd_npc.debug.jump"] = "Saltar",
    ["mmd_vmd_npc.debug.vmd_frame"] = "Fotograma VMD",
    ["mmd_vmd_npc.debug.next"] = "Siguiente",
    ["mmd_vmd_npc.debug.refresh"] = "Actualizar",
    ["mmd_vmd_npc.debug.play_preview"] = "Reproducir",
    ["mmd_vmd_npc.debug.pause_preview"] = "Pausar",
    ["mmd_vmd_npc.manager.title"] = "Gestor de movimientos",
    ["mmd_vmd_npc.manager.search_placeholder"] = "Buscar ID, origen o música",
    ["mmd_vmd_npc.manager.refresh"] = "Actualizar",
    ["mmd_vmd_npc.manager.column_motion_id"] = "ID de movimiento",
    ["mmd_vmd_npc.manager.column_duration"] = "Duración",
    ["mmd_vmd_npc.manager.column_frames"] = "Fotogramas",
    ["mmd_vmd_npc.manager.column_bones"] = "Huesos",
    ["mmd_vmd_npc.manager.column_flexes"] = "Flexes",
    ["mmd_vmd_npc.manager.column_music"] = "Música",
    ["mmd_vmd_npc.manager.column_addon"] = "Desde addon",
    ["mmd_vmd_npc.manager.column_built"] = "Construido",
    ["mmd_vmd_npc.manager.select_motion_details"] = "Selecciona un movimiento para ver detalles.",
    ["mmd_vmd_npc.manager.details_fmt"] = "%s\nFPS %s | fotogramas %s-%s | duración %.2fs | huesos %s | flexes %s | música %s | origen %s",
    ["mmd_vmd_npc.manager.play_music"] = "Reproducir música",
    ["mmd_vmd_npc.manager.volume"] = "Volumen",
    ["mmd_vmd_npc.manager.audio_offset_help"] = "Desfase de audio en segundos. Positivo inicia más tarde; negativo adelanta.",
    ["mmd_vmd_npc.manager.preview_music_only"] = "Previsualizar solo música",
    ["mmd_vmd_npc.manager.preview_motion"] = "Previsualizar movimiento",
    ["mmd_vmd_npc.manager.stop_music"] = "Detener música",
    ["mmd_vmd_npc.manager.save_offset"] = "Guardar desfase",
    ["mmd_vmd_npc.manager.debug"] = "Depurar",
    ["mmd_vmd_npc.manager.build_selected"] = "Construir seleccionado",
    ["mmd_vmd_npc.manager.play_built"] = "Reproducir construido",
    ["mmd_vmd_npc.manager.stop"] = "Detener",
    ["mmd_vmd_npc.manager.clear_this_model"] = "Limpiar este modelo",
    ["mmd_vmd_npc.manager.clear_all_models"] = "Limpiar todos los modelos",
    ["mmd_vmd_npc.manager.delete_motion_music"] = "Eliminar movimiento + música",
    ["mmd_vmd_npc.manager.delete_prompt_fmt"] = "¿Eliminar '%s' de data/mmd_vmd_npc/motions y quitar su música importada si es posible?",
    ["mmd_vmd_npc.manager.delete_title"] = "Eliminar movimiento MMD VMD",
    ["mmd_vmd_npc.manager.delete_confirm"] = "Eliminar",
    ["mmd_vmd_npc.manager.cancel"] = "Cancelar",
})

MMDVMDNPC.LanguageAliases = {
    english = "en",
    en = "en",
    spanish = "es",
    es = "es",
    es_es = "es",
    es_mx = "es",
    chinese = "zh",
    schinese = "zh",
    tchinese = "zh",
    zh = "zh",
    zh_cn = "zh",
    zh_tw = "zh",
    japanese = "ja",
    jp = "ja",
    ja = "ja",
    korean = "ko",
    kr = "ko",
    ko = "ko",
    french = "fr",
    fr = "fr",
    russian = "ru",
    ru = "ru",
    arabic = "ar",
    ar = "ar",
}

function MMDVMDNPC.NormalizeLanguage(lang)
    lang = string.lower(tostring(lang or ""))
    lang = string.gsub(lang, "%s+", "")
    lang = string.gsub(lang, "-", "_")
    if MMDVMDNPC.LanguageAliases[lang] then return MMDVMDNPC.LanguageAliases[lang] end
    local prefix = string.sub(lang, 1, 2)
    return MMDVMDNPC.I18N[prefix] and prefix or "en"
end

function MMDVMDNPC.GameLanguage()
    if CLIENT and GetConVar then
        local cvar = GetConVar("gmod_language")
        if cvar then return MMDVMDNPC.NormalizeLanguage(cvar:GetString()) end
    end
    return "en"
end

function MMDVMDNPC.RegisterI18N(lang)
    if not CLIENT or not language or not language.Add then return end
    local code = MMDVMDNPC.NormalizeLanguage(lang or MMDVMDNPC.GameLanguage())
    local selected = MMDVMDNPC.I18N[code] or MMDVMDNPC.I18N.en or {}
    for key, text in pairs(MMDVMDNPC.I18N.en or {}) do
        language.Add(key, selected[key] or text)
    end
end

function MMDVMDNPC.RegisterEnglishI18N()
    MMDVMDNPC.RegisterI18N("en")
end

function MMDVMDNPC.L(key, fallback)
    key = tostring(key or "")
    local selected = MMDVMDNPC.I18N[MMDVMDNPC.GameLanguage and MMDVMDNPC.GameLanguage() or "en"] or {}
    if selected[key] then return selected[key] end
    return (MMDVMDNPC.I18N.en or {})[key] or fallback or key
end

function MMDVMDNPC.LFormat(key, ...)
    return string.format(MMDVMDNPC.L(key, key), ...)
end

if CLIENT then
    MMDVMDNPC.RegisterI18N()
    if cvars and cvars.AddChangeCallback then
        cvars.AddChangeCallback("gmod_language", function()
            MMDVMDNPC.RegisterI18N()
        end, "MMDVMDNPCI18N")
    end
end

local function trim(value)
    return string.Trim(tostring(value or ""))
end

function MMDVMDNPC.NormalizeMotionID(raw)
    local id = trim(raw)
    if id == "" then return nil end

    id = string.Replace(id, "\\", "/")
    id = string.GetFileFromFilename(id)
    id = string.gsub(id, "%.json$", "")
    id = string.gsub(id, "%.vmd$", "")
    id = string.lower(id)

    if id == "" then return nil end
    if string.find(id, "..", 1, true) then return nil end
    if string.find(id, "/", 1, true) then return nil end
    if not string.match(id, "^[%w_%-%.]+$") then return nil end

    return id
end

function MMDVMDNPC.MotionPath(motionID)
    local id = MMDVMDNPC.NormalizeMotionID(motionID)
    if not id then return nil end
    return MMDVMDNPC.MotionRoot .. "/" .. id .. MMDVMDNPC.CacheExtension, id
end

function MMDVMDNPC.SafeModelName(modelPath)
    local name = string.lower(trim(modelPath))
    name = string.Replace(name, "\\", "/")
    name = string.gsub(name, "^models/", "")
    name = string.gsub(name, "%.mdl$", "")
    name = string.gsub(name, "[^%w_%-%.]+", "_")
    name = string.gsub(name, "_+", "_")
    name = string.gsub(name, "^_+", "")
    name = string.gsub(name, "_+$", "")
    if name == "" then return "unknown_model" end
    return name
end

function MMDVMDNPC.BuiltPath(motionID, modelPath, options)
    local id = MMDVMDNPC.NormalizeMotionID(motionID)
    if not id then return nil end

    options = options or {}
    local suffix = string.format(
        "tw%d_ht%d_eye%d_sp%d",
        options.disableArmTwist and 1 or 0,
        options.disableHandTwist and 1 or 0,
        options.disableEyes and 1 or 0,
        options.disableSpinePelvisCorrection and 1 or 0
    )
    local modelName = MMDVMDNPC.SafeModelName(modelPath or "")
    return MMDVMDNPC.BuiltRoot .. "/" .. id .. "_" .. modelName .. "_" .. suffix .. MMDVMDNPC.CacheExtension, id
end

function MMDVMDNPC.Chat(ply, message)
    message = "[MMD VMD] " .. tostring(message or "")
    if IsValid(ply) and ply.ChatPrint then
        ply:ChatPrint(message)
    else
        print(message)
    end
end
