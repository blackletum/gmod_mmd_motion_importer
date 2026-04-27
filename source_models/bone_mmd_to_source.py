import bpy
import re

# =========================
# User settings
# =========================
# If your MMD bones are Japanese (センター/上半身/左腕...), use "JP".
# If you previously renamed to English (center/upper body/left arm...), use "EN".
MMD_NAME_STYLE = "JP"   # "JP" or "EN"

RENAME_VERTEX_GROUPS = True
PROCESS_SELECTED_ARMATURES = True  # if False, only uses active object

# Output Valve names with or without the "ValveBiped." prefix
OUTPUT_WITH_VALVEBIPED_PREFIX = True

# If True, also tries to match names that got auto-suffixed like "左腕_01" or "center_02"
STRIP_COLLISION_SUFFIX = True

# =========================
# Forward mappings (Valve -> MMD)
# We invert these to get MMD -> Valve
# =========================

JP_MAP_BASE = {
    "ValveBiped.Bip01_Pelvis": "下半身",

    "ValveBiped.Bip01_Spine": "上半身",
    "ValveBiped.Bip01_Spine1": "上半身1",
    "ValveBiped.Bip01_Spine2": "上半身2",
    "ValveBiped.Bip01_Spine4": "胸",
    "ValveBiped.Bip01_Neck1": "首",
    "ValveBiped.Bip01_Head1": "頭",

    "ValveBiped.Bip01_L_Eye": "左目",
    "ValveBiped.Bip01_R_Eye": "右目",

    "ValveBiped.Bip01_L_Clavicle": "左肩",
    "ValveBiped.Bip01_L_UpperArm": "左腕",
    "ZArmTwist_L": "左腕捩",
    "ValveBiped.Bip01_L_Forearm": "左ひじ",
    "ZHandTwist_L": "左手捩",
    "ValveBiped.Bip01_L_Hand": "左手首",

    "ValveBiped.Bip01_R_Clavicle": "右肩",
    "ValveBiped.Bip01_R_UpperArm": "右腕",
    "ZArmTwist_R": "右腕捩",
    "ValveBiped.Bip01_R_Forearm": "右ひじ",
    "ZHandTwist_R": "右手捩",
    "ValveBiped.Bip01_R_Hand": "右手首",

    "ValveBiped.Bip01_L_Thigh": "左足",
    "ValveBiped.Bip01_L_Calf": "左ひざ",
    "ValveBiped.Bip01_L_Foot": "左足首",
    "ValveBiped.Bip01_L_Toe0": "左つま先",

    "ValveBiped.Bip01_R_Thigh": "右足",
    "ValveBiped.Bip01_R_Calf": "右ひざ",
    "ValveBiped.Bip01_R_Foot": "右足首",
    "ValveBiped.Bip01_R_Toe0": "右つま先",

    "ValveBiped.Bip01_L_Finger0":  "左親指０",
    "ValveBiped.Bip01_L_Finger01": "左親指１",
    "ValveBiped.Bip01_L_Finger02": "左親指２",

    "ValveBiped.Bip01_L_Finger1":  "左人指１",
    "ValveBiped.Bip01_L_Finger11": "左人指２",
    "ValveBiped.Bip01_L_Finger12": "左人指３",

    "ValveBiped.Bip01_L_Finger2":  "左中指１",
    "ValveBiped.Bip01_L_Finger21": "左中指２",
    "ValveBiped.Bip01_L_Finger22": "左中指３",

    "ValveBiped.Bip01_L_Finger3":  "左薬指１",
    "ValveBiped.Bip01_L_Finger31": "左薬指２",
    "ValveBiped.Bip01_L_Finger32": "左薬指３",

    "ValveBiped.Bip01_L_Finger4":  "左小指１",
    "ValveBiped.Bip01_L_Finger41": "左小指２",
    "ValveBiped.Bip01_L_Finger42": "左小指３",

    "ValveBiped.Bip01_R_Finger0":  "右親指０",
    "ValveBiped.Bip01_R_Finger01": "右親指１",
    "ValveBiped.Bip01_R_Finger02": "右親指２",

    "ValveBiped.Bip01_R_Finger1":  "右人指１",
    "ValveBiped.Bip01_R_Finger11": "右人指２",
    "ValveBiped.Bip01_R_Finger12": "右人指３",

    "ValveBiped.Bip01_R_Finger2":  "右中指１",
    "ValveBiped.Bip01_R_Finger21": "右中指２",
    "ValveBiped.Bip01_R_Finger22": "右中指３",

    "ValveBiped.Bip01_R_Finger3":  "右薬指１",
    "ValveBiped.Bip01_R_Finger31": "右薬指２",
    "ValveBiped.Bip01_R_Finger32": "右薬指３",

    "ValveBiped.Bip01_R_Finger4":  "右小指１",
    "ValveBiped.Bip01_R_Finger41": "右小指２",
    "ValveBiped.Bip01_R_Finger42": "右小指３",
}

EN_MAP_BASE = {
    "ValveBiped.Bip01_Root": "mother",
    "ValveBiped.Bip01": "center",

    "ValveBiped.Bip01_Pelvis": "lower body",
    "ValveBiped.Bip01_Spine": "upper body",
    "ValveBiped.Bip01_Spine1": "upper body2",
    "ValveBiped.Bip01_Spine2": "upper body3",
    "ValveBiped.Bip01_Spine3": "upper body4",
    "ValveBiped.Bip01_Spine4": "chest",
    "ValveBiped.Bip01_Neck1": "neck",
    "ValveBiped.Bip01_Head1": "head",

    "ValveBiped.Bip01_L_Eye": "left eye",
    "ValveBiped.Bip01_R_Eye": "right eye",

    "ValveBiped.Bip01_L_Clavicle": "left shoulder",
    "ValveBiped.Bip01_L_UpperArm": "left arm",
    "ValveBiped.Bip01_L_UpperArm_twist": "left arm twist",
    "ValveBiped.Bip01_L_Forearm": "left elbow",
    "ValveBiped.Bip01_L_Forearm_twist": "left wrist twist",
    "ValveBiped.Bip01_L_Hand": "left wrist",

    "ValveBiped.Bip01_R_Clavicle": "right shoulder",
    "ValveBiped.Bip01_R_UpperArm": "right arm",
    "ValveBiped.Bip01_R_UpperArm_twist": "right arm twist",
    "ValveBiped.Bip01_R_Forearm": "right elbow",
    "ValveBiped.Bip01_R_Forearm_twist": "right wrist twist",
    "ValveBiped.Bip01_R_Hand": "right wrist",

    "ValveBiped.Bip01_L_Thigh": "left leg",
    "ValveBiped.Bip01_L_Calf": "left knee",
    "ValveBiped.Bip01_L_Foot": "left ankle",
    "ValveBiped.Bip01_L_Toe0": "left toe",

    "ValveBiped.Bip01_R_Thigh": "right leg",
    "ValveBiped.Bip01_R_Calf": "right knee",
    "ValveBiped.Bip01_R_Foot": "right ankle",
    "ValveBiped.Bip01_R_Toe0": "right toe",
}

# =========================
# Helpers
# =========================

_collision_suffix_re = re.compile(r"^(.*)_(\d{2,})$")

def strip_collision_suffix(name: str) -> str:
    m = _collision_suffix_re.match(name)
    return m.group(1) if m else name

def build_reverse_mapping(style: str):
    base = JP_MAP_BASE if style.upper() == "JP" else EN_MAP_BASE

    # Invert: MMD -> Valve
    rev = {}
    dup = []
    for valve_name, mmd_name in base.items():
        if mmd_name in rev:
            dup.append((mmd_name, rev[mmd_name], valve_name))
            continue
        rev[mmd_name] = valve_name

    warnings = []
    for mmd_name, first_valve, skipped_valve in dup:
        warnings.append(f'Duplicate MMD name "{mmd_name}" maps to both "{first_valve}" and "{skipped_valve}". Using "{first_valve}".')

    # Optionally strip prefix in output
    if not OUTPUT_WITH_VALVEBIPED_PREFIX:
        out = {}
        for mmd, valve in rev.items():
            out[mmd] = valve.replace("ValveBiped.", "", 1) if valve.startswith("ValveBiped.") else valve
        rev = out

    return rev, warnings

def meshes_using_armature(arm_obj: bpy.types.Object):
    users = []
    for ob in bpy.data.objects:
        if ob.type != "MESH":
            continue
        uses = False
        for m in ob.modifiers:
            if m.type == "ARMATURE" and m.object == arm_obj:
                uses = True
                break
        if ob.parent == arm_obj and ob.parent_type == "ARMATURE":
            uses = True
        if uses:
            users.append(ob)
    return users

def rename_vertex_groups(mesh_objs, rename_map, warnings):
    for ob in mesh_objs:
        vgs = ob.vertex_groups
        for old, new in rename_map.items():
            vg = vgs.get(old)
            if not vg and STRIP_COLLISION_SUFFIX:
                base_old = strip_collision_suffix(old)
                vg = vgs.get(base_old)
                if vg:
                    old = base_old
            if not vg:
                continue

            existing = vgs.get(new)
            if existing and existing != vg:
                warnings.append(f'[VG] "{ob.name}": "{new}" already exists; skipped "{old}" -> "{new}".')
                continue
            vg.name = new

def plan_renames(arm_data, reverse_mapping):
    plan = {}
    for b in arm_data.bones:
        src = b.name
        if src in reverse_mapping:
            plan[src] = reverse_mapping[src]
            continue
        if STRIP_COLLISION_SUFFIX:
            base = strip_collision_suffix(src)
            if base in reverse_mapping:
                plan[src] = reverse_mapping[base]
    return plan

def rename_armature_bones(arm_obj: bpy.types.Object, reverse_mapping):
    warnings = []
    renamed = {}

    plan = plan_renames(arm_obj.data, reverse_mapping)
    if not plan:
        return renamed, ["No matching MMD bone names found on this armature."]

    ctx = bpy.context
    view_layer = ctx.view_layer
    prev_active = view_layer.objects.active
    prev_mode = prev_active.mode if prev_active else "OBJECT"

    bpy.ops.object.mode_set(mode="OBJECT")
    view_layer.objects.active = arm_obj
    bpy.ops.object.mode_set(mode="EDIT")

    ebones = arm_obj.data.edit_bones

    # Two-pass to avoid collisions: old -> temp -> final
    temp_of_old = {}
    i = 0
    for old, new in plan.items():
        eb = ebones.get(old)
        if not eb:
            continue
        tmp = f"__TMP_RENAME__{i:04d}__"
        eb.name = tmp
        temp_of_old[old] = tmp
        i += 1

    for old, target in plan.items():
        tmp = temp_of_old.get(old)
        if not tmp:
            continue
        eb = ebones.get(tmp)
        if not eb:
            continue

        final_name = target
        if final_name in ebones and ebones.get(final_name) != eb:
            n = 1
            while f"{final_name}_{n:02d}" in ebones:
                n += 1
            new_final = f"{final_name}_{n:02d}"
            warnings.append(f'[Bone] "{final_name}" already existed; renamed "{old}" -> "{new_final}" instead.')
            final_name = new_final

        eb.name = final_name
        renamed[old] = final_name

    bpy.ops.object.mode_set(mode="OBJECT")
    if prev_active:
        view_layer.objects.active = prev_active
        try:
            bpy.ops.object.mode_set(mode=prev_mode)
        except Exception:
            pass

    return renamed, warnings

# =========================
# Main
# =========================

def main():
    reverse_map, map_warnings = build_reverse_mapping(MMD_NAME_STYLE)

    if PROCESS_SELECTED_ARMATURES:
        armatures = [o for o in bpy.context.selected_objects if o.type == "ARMATURE"]
    else:
        arm = bpy.context.view_layer.objects.active
        armatures = [arm] if arm and arm.type == "ARMATURE" else []

    if not armatures:
        print("No armature selected/active.")
        return

    all_lines = []
    if map_warnings:
        all_lines.append("Mapping warnings:")
        for w in map_warnings:
            all_lines.append("  - " + w)

    for arm_obj in armatures:
        renamed, warnings = rename_armature_bones(arm_obj, reverse_map)
        if renamed:
            all_lines.append(f'Armature "{arm_obj.name}": renamed {len(renamed)} bones (MMD -> ValveBiped).')
        else:
            all_lines.append(f'Armature "{arm_obj.name}": no bones renamed.')

        for w in warnings:
            all_lines.append("  - " + w)

        if RENAME_VERTEX_GROUPS and renamed:
            meshes = meshes_using_armature(arm_obj)
            vg_warnings = []
            # IMPORTANT: use the actual old->new mapping that happened
            rename_vertex_groups(meshes, renamed, vg_warnings)
            all_lines.append(f'  Vertex groups updated on {len(meshes)} mesh object(s).')
            for w in vg_warnings:
                all_lines.append("  - " + w)

    report = "\n".join(all_lines)
    print(report)

    def draw(self, context):
        for line in all_lines[:30]:
            self.layout.label(text=line[:140])

    bpy.context.window_manager.popup_menu(draw, title="MMD → ValveBiped Rename Report", icon="ARMATURE_DATA")

main()
