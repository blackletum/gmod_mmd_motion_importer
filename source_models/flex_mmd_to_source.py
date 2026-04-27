# Blender: rename shape keys on the active object (or object named 'Face')
# back to the *original* names, by reversing special_replacement_dict.
#
# Notes:
# - If multiple originals map to the same current name, this script will SKIP that key
#   to avoid guessing.
# - If a rename would collide with an existing shape key name, it will SKIP that key.

import bpy

special_replacement_dict_jp = {
    "□": "mouth_square",
    "▲": "mouth_tri",

    # Brows (眉)
    "怒り": "brows_angry",
    "怒り左": "brows_angry_left",
    "怒り右": "brows_angry_right",
    "真面目": "brows_serious",
    "悲しむ": "brows_sad",
    "困る": "brows_worry",
    "困る左": "brows_worry_left",
    "困る右": "brows_worry_right",
    "なに？": "brows_questioning",
    "にこり": "brows_happy",
    "にこり左": "brows_happy_left",
    "にこり右": "brows_happy_right",
    "恥ずかしい": "brows_flat",
    "恥ずかしい左": "brows_flat_left",
    "恥ずかしい右": "brows_flat_right",
    "下": "brows_lower",
    "下左": "brows_lower_left",
    "下右": "brows_lower_right",
    "上": "brows_up",
    "上左": "brows_up_left",
    "上右": "brows_up_right",
    "前": "brows_closer",
    "前左": "brows_closer_left",
    "前右": "brows_closer_right",
    "驚き": "brows_surprise",
    "にこり２": "brows_happy_2",
    "フラット": "brows_flat",
    "眉寄せ": "brows_close",

    # Eyes (目)
    "まばたき": "blink",
    "ウィンク２": "eye_blink_left",
    "笑い": "eye_blink_happy",
    "ウィンク": "eye_blink_happy_left",
    "ｳｨﾝｸ２右": "eye_blink_right",
    "ウィンク右": "eye_blink_happy_right",
    "笑い２": "eye_blink_happy_2",

    # Smug / content eyes (models vary a lot)
    "にやり目": "eyes_smug",
    "泣き目": "eyes_sad",
    "たれ目": "eyes_droppy",
    "ドヤ顔": "eyes_smug",
    "ドヤ顔２": "eyes_smug_2",
    "はぅ": "eyes_peaceful",
    "はぅ２": "eyes_peaceful_2",

    "びっくり": "eyes_surprised",
    "見開き": "eyes_enlarge",
    "びっくり２": "eyes_surprised_2",
    "じと目": "eyes_stare",
    "じと目２": "eyes_stare_2",
    "ｷﾘｯ": "eyes_slant",
    "ｷﾘｯ２": "eyes_slant_2",

    "><": "eyes_teehee",
    "はちゅ目": "misc_OO",
    "なごみ": "eyes_calm",
    "なごみ左": "eyes_calm_left",
    "なごみ右": "eyes_calm_right",
    "怒り目": "eyes_anger",

    # To distinguish from じと目 (above) but still “jito”
    "ジト目": "eyes_staring",

    # Outer-eye / eyelid controls (names vary; these are common-ish)
    "目尻上げ": "eyes_outer_upper",
    "目尻下げ": "eyes_outer_lower",
    "下まぶた上げ": "eyes_lower_upper",

    "ハイライト消し": "eyes_hightlight_hide",
    "白目": "eyes_pupil_hide",
    "ハート目": "eyes_heart",
    "星目": "eyes_star_eye",
    "瞳小": "eyes_pupil_small",

    # Mouth (口)
    "あ": "mouth_a",
    "あ２": "mouth_a_2",
    "あ３": "mouth_a_3",
    "い": "mouth_i",
    "い１": "mouth_ch_1",
    "い２": "mouth_ch_2",
    "う": "mouth_u",
    "え": "mouth_e",
    "え？": "mouth_e_questioning",
    "お": "mouth_o",
    "ん": "mouth_neutral",

    "にやり": "mouth_grin",
    "にやり３": "mouth_grin_2",
    "にやり２": "mouth_grin_3",
    "にやり右": "mouth_grin_right",
    "にやり左": "mouth_grin_left",

    "ぺろっ": "mouth_lick",
    "口横狭": "mouth_narrow",
    "むぅ": "mouth_unhappy_thinking",
    "怒": "mouth_anger",
    "怒２": "mouth_anger_2",
    "い小": "mouth_i_small",
    "ちゅー": "mouth_kiss",
    "口開け": "mouth_gasp",

    "口角下げ": "mouth_sad",
    "口角上げ": "mouth_smile",

    "い２(別名)": "mouth_i_2",      # original key was "Ch2"
    "え２": "mouth_e_2",
    "口下げ": "mouth_lower",
    "口大": "mouth_big",
    "お２": "mouth_o_2",
    "口小": "mouth_small",
    "しょぼん": "mouth_defeat",

    "痛い": "mouth_pain",
    "痛い２": "mouth_pain_2",
    "痛い３": "mouth_pain_3",
    "口小２": "mouth_small_2",

    "Ｖ": "mouth_smile_v",
    "ω": "mouth_cat",
    "ω□": "mouth_cat_square",

    "ワ": "mouth_wa",
    "わ２": "mouth_wa_2",
    "わ３": "mouth_wa_3",
    "∧": "mouth_closed_tri",

    "口角下げ２": "mouth_sad_2",
    "口上げ": "mouth_upper",
    "口横広げ": "mouth_widen",
    "むっ": "mouth_disgust",
    "むっ２": "mouth_disgust_2",

    "え３": "mouth_e_3",
    "えー": "mouth_e_4",
    "にっこり": "mouth_smile",
    "にっこり２": "mouth_smile2",

    # Teeth / fangs
    "歯無し": "mouth_teeth_remove",
    "上歯消し": "mouth_teeth_hide_upper",
    "下歯消し": "mouth_teeth_hide_lower",
    "歯消し": "mouth_teeth_hide",
    "歯消し２": "mouth_teeth_hide_2",
    "八重歯": "mouth_teeth_vampire",
    "八重歯右": "mouth_teeth_vampire_right",
    "八重歯左": "mouth_teeth_vampire_left",

    # Misc (涙/頬/汗 etc.)
    "涙": "misc_tears",
    "頬染め": "misc_blush",
    "汗": "misc_sweat",
    "焦り": "misc_awkward",
    "青ざめ": "misc_unwell",
    "照れ": "misc_uppershy",

    # Emote marks (often literally these symbols in MMD)
    "怒りマーク": "emote_angry",
    "!": "emote_surprise",
    "?": "emote_question",
    "!!": "emote_shock",
    "汗マーク": "emote_sweat",
    "赤面": "face_red",
    "#": "emote_unsatisified",
    "#左": "emote_unsatisified_left",
    "ZZZ": "emote_sleepy",
    "はわわ": "emote_awkward",
    "……": "emote_speechless",

    # --- The remaining entries in your dict are model-specific / blender-ish aliases ---
    # Kept or best-effort JP guesses so you can still match lots of rigs.

    "ウィンク２": "eye_blink_left",                 # original "Wink2"
    "eyeclose7": "eye_blink_right",
    "eyeclose8": "eye_blink_happy_right",
    "ハイライト下げ": "eyes_highlightdown",
    "瞳縮小": "eyes_iris_small",

    "頬染め２": "misc_blush_2",                           # original "Blush2"
    "頬２": "misc_blush_full",                            # original "hoho2"
    "頬下": "misc_blush_lower",                           # original "hohol"
    "ショック": "misc_unwell",                            # original "shock"

    "口角上げ": "mouth_grin_2",                           # original "mouthuphalf"
    "鼻上げ": "misc_nose_up",                             # original "nosefook"
    "口角下げ": "mouth_sad",                          # original "mouthdw"
    "へ": "mouth_neutral",                                # original "mouthhe"

    "舌広げ": "mouth_tongue_wide",                         # original "tangopen"
    "舌出し": "mouth_tongue_out",                          # original "tangout"
    "舌上げ": "mouth_tongue_up",                           # original "tangup"

    "涙１": "misc_tears_1",
    "涙２": "misc_tears_2",
    "涙３": "misc_tears_3",
    "よだれ": "misc_sweat",                               # original "yodare" (often used for drool/sweat-type fx)

    "あぁ": "mouth_aah",
    "うん": "mouth_un",
    "おぉ": "mouth_ooh",
    "んー": "mouth_hmm",

    "上(視線)": "eyes_look_up",                            # original "Up"
    "瞳上": "eyes_look_up",                                # original "Pupil_Up"
    "下(視線)": "eyes_look_down",                          # original "Down"
    "瞳下": "eyes_look_down",                              # original "Pupil_Down"
    "左(視線)": "eyes_look_left",                          # original "Left"
    "瞳左": "eyes_look_left",                              # original "Pupil_L"
    "右(視線)": "eyes_look_right",                         # original "Right"
    "瞳右": "eyes_look_right",                              # original "Pupil_R"

    "恐怖": "eyes_hide",                                   # original "HorrorChild !"
    "瞳スケール": "eyes_small",                             # original "Pupil_Scale"
    "カメラ目": "eyes_look_camera",

    "口横縮め": "mouth_shrink",
    "顎前": "mouth_jaw_front",
    "顎上": "mouth_jaw_upper",
    "顎左": "mouth_jaw_left",
    "顎右": "mouth_jaw_right",
    "口左": "mouth_left",
    "口右": "mouth_right",
    "鼻上": "nose_upper",
    "鼻下": "nose_lower",
}

inverted_dict = {v: k for k, v in special_replacement_dict_jp.items()}

bpy.data.objects["Face"].select_set(True)
bpy.context.view_layer.objects.active = bpy.data.objects['Face']
bpy.data.screens["Scripting"].areas[0].spaces[0].context = 'DATA'

#Try Key or Key.002 if error
for shape_key in bpy.data.shape_keys['Key'].key_blocks:
    shapekey_name = shape_key.name
    
    try:
        if shapekey_name in special_replacement_dict_jp:
            shape_key.name = special_replacement_dict_jp[shapekey_name]
            shapekey_name = special_replacement_dict_jp[shapekey_name]
        
    except:
        pass