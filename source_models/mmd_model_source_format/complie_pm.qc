// Created by Crowbar 0.74

$modelname "sheepylord/arknight_endfield/li_zhiyan_pm.mdl" 

$model "Face" "Face.smd" {

	flexfile "Face.vta"
	{
		defaultflex frame 0
		flex "blink" frame 1
		flex "eye_blink_happy" frame 2
		flex "eye_blink_happy_left" frame 3
		flex "eye_blink_happy_right" frame 4
		flex "eye_blink_left" frame 5
		flex "eyes_calm" frame 6
		flex "eyes_surprised" frame 7
		flex "eyes_stare" frame 8
		flex "mouth_a" frame 9
		flex "mouth_i" frame 10
		flex "mouth_u" frame 11
		flex "mouth_e" frame 12
		flex "mouth_o" frame 13
		flex "mouth_a_2" frame 14
		flex "mouth_neutral" frame 15
		flex "mouth_tri" frame 16
		flex "mouth_closed_tri" frame 17
		flex "mouth_wa" frame 18
		flex "mouth_cat" frame 19
		flex "mouth_cat_square" frame 20
		flex "mouth_grin" frame 21
		flex "mouth_grin_2" frame 22
		flex "mouth_smile" frame 23
		flex "mouth_laugh" frame 24
		flex "mouth_sad" frame 25
		flex "mouth_widen" frame 26
		flex "mouth_narrow" frame 27
		flex "brows_serious" frame 28
		flex "brows_worry" frame 29
		flex "brows_happy" frame 30
		flex "brows_angry" frame 31
		flex "brows_up" frame 32
		flex "brows_lower" frame 33
		flex "eye_blink_right" frame 34
		flex "eyes_slant" frame 35
		flex "eyes_pupil_small" frame 36
		flex "eyes_hide" frame 37
		flex "eyes_dead" frame 38
		flex "eyes_look_up" frame 39
		flex "eyes_look_down" frame 40
		flex "eyes_look_left" frame 41
		flex "eyes_look_right" frame 42
		flex "eyes_look_camera" frame 43
	}

	flexcontroller phoneme range 0 1 "blink"
	flexcontroller phoneme range 0 1 "eye_blink_happy"
	flexcontroller phoneme range 0 1 "eye_blink_happy_left"
	flexcontroller phoneme range 0 1 "eye_blink_happy_right"
	flexcontroller phoneme range 0 1 "eye_blink_left"
	flexcontroller phoneme range 0 1 "eyes_calm"
	flexcontroller phoneme range 0 1 "eyes_surprised"
	flexcontroller phoneme range 0 1 "eyes_stare"
	flexcontroller phoneme range 0 1 "mouth_a"
	flexcontroller phoneme range 0 1 "mouth_i"
	flexcontroller phoneme range 0 1 "mouth_u"
	flexcontroller phoneme range 0 1 "mouth_e"
	flexcontroller phoneme range 0 1 "mouth_o"
	flexcontroller phoneme range 0 1 "mouth_a_2"
	flexcontroller phoneme range 0 1 "mouth_neutral"
	flexcontroller phoneme range 0 1 "mouth_tri"
	flexcontroller phoneme range 0 1 "mouth_closed_tri"
	flexcontroller phoneme range 0 1 "mouth_wa"
	flexcontroller phoneme range 0 1 "mouth_cat"
	flexcontroller phoneme range 0 1 "mouth_cat_square"
	flexcontroller phoneme range 0 1 "mouth_grin"
	flexcontroller phoneme range 0 1 "mouth_grin_2"
	flexcontroller phoneme range 0 1 "mouth_smile"
	flexcontroller phoneme range 0 1 "mouth_laugh"
	flexcontroller phoneme range 0 1 "mouth_sad"
	flexcontroller phoneme range 0 1 "mouth_widen"
	flexcontroller phoneme range 0 1 "mouth_narrow"
	flexcontroller phoneme range 0 1 "brows_serious"
	flexcontroller phoneme range 0 1 "brows_worry"
	flexcontroller phoneme range 0 1 "brows_happy"
	flexcontroller phoneme range 0 1 "brows_angry"
	flexcontroller phoneme range 0 1 "brows_up"
	flexcontroller phoneme range 0 1 "brows_lower"
	flexcontroller phoneme range 0 1 "eye_blink_right"
	flexcontroller phoneme range 0 1 "eyes_slant"
	flexcontroller phoneme range 0 1 "eyes_pupil_small"
	flexcontroller phoneme range 0 1 "eyes_hide"
	flexcontroller phoneme range 0 1 "eyes_dead"
	flexcontroller phoneme range 0 1 "eyes_look_up"
	flexcontroller phoneme range 0 1 "eyes_look_down"
	flexcontroller phoneme range 0 1 "eyes_look_left"
	flexcontroller phoneme range 0 1 "eyes_look_right"
	flexcontroller phoneme range 0 1 "eyes_look_camera"

	%blink  = blink
	%eye_blink_happy  = eye_blink_happy
	%eye_blink_happy_left  = eye_blink_happy_left
	%eye_blink_happy_right  = eye_blink_happy_right
	%eye_blink_left  = eye_blink_left
	%eyes_calm  = eyes_calm
	%eyes_surprised  = eyes_surprised
	%eyes_stare  = eyes_stare
	%mouth_a  = mouth_a
	%mouth_i  = mouth_i
	%mouth_u  = mouth_u
	%mouth_e  = mouth_e
	%mouth_o  = mouth_o
	%mouth_a_2  = mouth_a_2
	%mouth_neutral  = mouth_neutral
	%mouth_tri  = mouth_tri
	%mouth_closed_tri  = mouth_closed_tri
	%mouth_wa  = mouth_wa
	%mouth_cat  = mouth_cat
	%mouth_cat_square  = mouth_cat_square
	%mouth_grin  = mouth_grin
	%mouth_grin_2  = mouth_grin_2
	%mouth_smile  = mouth_smile
	%mouth_laugh  = mouth_laugh
	%mouth_sad  = mouth_sad
	%mouth_widen  = mouth_widen
	%mouth_narrow  = mouth_narrow
	%brows_serious  = brows_serious
	%brows_worry  = brows_worry
	%brows_happy  = brows_happy
	%brows_angry  = brows_angry
	%brows_up  = brows_up
	%brows_lower  = brows_lower
	%eye_blink_right  = eye_blink_right
	%eyes_slant  = eyes_slant
	%eyes_pupil_small  = eyes_pupil_small
	%eyes_hide  = eyes_hide
	%eyes_dead  = eyes_dead
	%eyes_look_up  = eyes_look_up
	%eyes_look_down  = eyes_look_down
	%eyes_look_left  = eyes_look_left
	%eyes_look_right  = eyes_look_right
	%eyes_look_camera  = eyes_look_camera
}
$bodygroup "Body"
{
	studio "Body.smd"
}

$bodygroup "Coat"
{
	studio "Coat.smd"
	blank
}

$bodygroup "Device"
{
	studio "Device.smd"
	blank
}

$bodygroup "Hair"
{
	studio "Hair.smd"
}

$surfaceprop "flesh" 

$contents "solid" 

$illumposition -0.637 0 35.954 

$ambientboost 

$mostlyopaque 

$cdmaterials "models/sheepylord/li_zhiyan/" 

$cbox 0 0 0 0 0 0 

$bbox -13 -13 0 13 13 72 

//Define Bone Head
$definebone "ValveBiped.Bip01_Pelvis" "" 0.000000 -1.144069 39.416836 -0.000000 0.000057 89.999985 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "ValveBiped.Bip01_L_Thigh" "ValveBiped.Bip01_Pelvis" 3.066641 -1.147423 -1.056764 0.120207 -89.999695 -90.016136 0.000000 0.000000 -0.000000 -0.000000 0.000000 0.000000 
$definebone "ValveBiped.Bip01_L_Calf" "ValveBiped.Bip01_L_Thigh" 15.810871 0.000057 -0.000089 -0.006188 1.656134 -0.283729 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 
$definebone "ValveBiped.Bip01_L_Foot" "ValveBiped.Bip01_L_Calf" 16.186586 -0.000017 0.000001 1.006744 -59.962376 0.492686 0.000000 0.000000 0.000000 0.000000 0.000001 0.000000 
$definebone "ValveBiped.Bip01_R_Thigh" "ValveBiped.Bip01_Pelvis" -3.066639 -1.147423 -1.056777 0.120207 -90.000328 -89.984627 0.000000 -0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "ValveBiped.Bip01_R_Calf" "ValveBiped.Bip01_R_Thigh" 15.810852 0.000057 0.000089 0.006188 1.656077 0.282468 -0.000002 -0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "ValveBiped.Bip01_R_Foot" "ValveBiped.Bip01_R_Calf" 16.186583 -0.000013 0.000000 -1.119273 -59.953953 -0.110695 0.000000 0.000000 0.000000 -0.000000 0.000007 -0.000000 
$definebone "ValveBiped.Bip01_Spine" "ValveBiped.Bip01_Pelvis" 0.000000 2.329639 0.000000 4.944168 89.999695 89.999931 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "ValveBiped.Bip01_Spine1" "ValveBiped.Bip01_Spine" 3.233772 0.279742 -0.000018 0.000057 -1.675042 -0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "ValveBiped.Bip01_Spine2" "ValveBiped.Bip01_Spine1" 2.125530 0.243174 -0.000009 -0.002521 5.748371 -0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 
$definebone "ValveBiped.Bip01_Spine4" "ValveBiped.Bip01_Spine2" 1.106331 0.016816 -0.000053 0.002979 11.121111 0.000516 0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 
$definebone "ValveBiped.Bip01_R_Clavicle" "ValveBiped.Bip01_Spine4" 6.678905 -2.290320 -0.583795 64.042557 169.573318 -90.208466 0.000000 0.000000 0.000000 0.000001 -0.000005 0.000001 
$definebone "ValveBiped.Bip01_R_UpperArm" "ValveBiped.Bip01_R_Clavicle" 3.992109 0.143494 0.162059 -5.598371 -10.497799 94.073540 0.000000 0.000000 0.000000 -0.000007 0.000001 -0.000002 
$definebone "ValveBiped.Bip01_R_Forearm" "ValveBiped.Bip01_R_UpperArm" 8.268751 0.000029 0.000008 -0.205755 -5.129521 -0.012778 -0.000002 0.000000 0.000000 -0.000007 -0.000001 -0.000001 
$definebone "ValveBiped.Bip01_R_Hand" "ValveBiped.Bip01_R_Forearm" 9.840573 -0.000036 -0.000004 6.094946 7.462719 -89.591751 -0.000001 0.000000 0.000000 -0.000001 -0.000005 0.000001 
$definebone "ValveBiped.Bip01_L_Clavicle" "ValveBiped.Bip01_Spine4" 6.678898 -2.290319 0.583858 -63.945385 170.169937 89.633728 0.000002 0.000000 -0.000000 -0.000000 0.000000 -0.000000 
$definebone "ValveBiped.Bip01_L_UpperArm" "ValveBiped.Bip01_L_Clavicle" 3.992554 0.150318 -0.143735 5.348217 -10.393345 -94.105911 0.000000 0.000000 0.000000 0.000003 -0.000000 0.000000 
$definebone "ValveBiped.Bip01_L_Forearm" "ValveBiped.Bip01_L_UpperArm" 8.268749 -0.000000 -0.000004 0.216468 -5.129635 -0.025325 0.000000 0.000000 -0.000004 0.000003 -0.000001 0.000000 
$definebone "ValveBiped.Bip01_L_Hand" "ValveBiped.Bip01_L_Forearm" 9.840587 0.000032 -0.000008 -6.115636 7.729485 90.152161 -0.000001 0.000000 -0.000000 0.000001 -0.000005 -0.000001 
$definebone "ValveBiped.Bip01_Neck1" "ValveBiped.Bip01_Spine4" 7.067463 -2.901073 0.000033 -0.001146 21.370409 179.999741 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "ValveBiped.Bip01_Head1" "ValveBiped.Bip01_Neck1" 3.375988 1.702625 0.000057 0.000573 17.347158 -0.000229 0.000000 0.000000 -0.000000 -0.000000 0.000000 0.000000 
$definebone "Eye_L" "ValveBiped.Bip01_Head1" 2.126728 -0.132408 -1.049855 -89.998528 -164.528320 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "Eye_R" "ValveBiped.Bip01_Head1" 2.126678 -0.132419 1.050037 -89.998528 -165.867218 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "ValveBiped.Bip01_L_Toe0" "ValveBiped.Bip01_L_Foot" 4.578928 1.606308 -0.114700 -0.219443 -31.819956 -0.052082 0.000000 0.000000 -0.000000 0.000000 0.000000 -0.000000 
$definebone "L_Boots_01" "ValveBiped.Bip01_L_Thigh" 9.287817 -3.119868 0.330684 -89.992363 -178.445572 0.000000 0.000000 0.000000 0.000002 -0.000000 0.000000 0.000000 
$definebone "ValveBiped.Bip01_R_Toe0" "ValveBiped.Bip01_R_Foot" 4.579363 1.606387 0.094874 0.238007 -31.850433 -3.501574 0.000000 0.000000 0.000000 0.000000 0.000003 0.000000 
$definebone "R_Boots_01" "ValveBiped.Bip01_R_Thigh" 9.287828 -3.119900 -0.330471 -89.976891 179.441086 0.000000 -0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 
$definebone "ValveBiped.Bip01_L_Finger2" "ValveBiped.Bip01_L_Hand" 2.660374 -0.066967 0.503060 -7.362968 -1.239026 1.083061 0.000000 0.000000 0.000000 -0.000001 -0.000005 -0.000000 
$definebone "ValveBiped.Bip01_L_Finger21" "ValveBiped.Bip01_L_Finger2" 1.219877 -0.000004 0.000000 0.001087 0.228663 -1.899183 0.000000 0.000000 0.000000 -0.000001 -0.000005 -0.000000 
$definebone "ValveBiped.Bip01_L_Finger22" "ValveBiped.Bip01_L_Finger21" 0.940395 0.000004 0.000000 0.176241 -12.398239 0.000057 0.000000 0.000000 -0.000000 -0.000001 -0.000005 0.000000 
$definebone "ValveBiped.Bip01_L_Finger1" "ValveBiped.Bip01_L_Hand" 2.550770 -0.170971 1.127055 -11.939981 -1.165289 13.753677 0.000000 0.000000 0.000001 -0.000003 -0.000007 0.000002 
$definebone "ValveBiped.Bip01_L_Finger11" "ValveBiped.Bip01_L_Finger1" 1.172852 0.000000 0.000000 -0.217727 -0.764214 -2.300826 0.000000 0.000000 0.000000 -0.000003 -0.000003 0.000000 
$definebone "ValveBiped.Bip01_L_Finger12" "ValveBiped.Bip01_L_Finger11" 0.792894 0.000008 0.000001 0.148565 -13.997822 -0.000114 -0.000001 0.000000 0.000000 -0.000003 -0.000005 0.000002 
$definebone "ValveBiped.Bip01_L_Finger0" "ValveBiped.Bip01_L_Hand" 0.260654 -0.343704 0.632754 -42.690063 -24.446571 -88.168350 -0.000002 0.000000 0.000000 0.000005 -0.000008 -0.000003 
$definebone "ValveBiped.Bip01_L_Finger01" "ValveBiped.Bip01_L_Finger0" 1.130629 0.000000 0.000000 -1.980997 -1.142141 -4.629501 -0.000001 0.000000 0.000000 0.000007 -0.000007 -0.000001 
$definebone "ValveBiped.Bip01_L_Finger02" "ValveBiped.Bip01_L_Finger01" 1.115273 0.000002 0.000000 0.645499 20.790457 0.000460 0.000000 0.000000 0.000000 0.000009 -0.000002 -0.000001 
$definebone "ValveBiped.Bip01_L_Finger4" "ValveBiped.Bip01_L_Hand" 2.330072 -0.402863 -0.686411 3.144853 -1.331733 -25.513639 0.000000 0.000000 0.000002 0.000005 -0.000003 -0.000004 
$definebone "ValveBiped.Bip01_L_Finger41" "ValveBiped.Bip01_L_Finger4" 0.983139 0.000004 0.000002 0.198248 -1.727989 -0.432587 0.000000 0.000004 0.000000 0.000003 -0.000007 -0.000003 
$definebone "ValveBiped.Bip01_L_Finger42" "ValveBiped.Bip01_L_Finger41" 0.562397 0.000008 0.000004 0.285279 -13.994964 -0.000235 -0.000001 0.000000 0.000000 0.000005 -0.000010 -0.000003 
$definebone "ValveBiped.Bip01_L_Finger3" "ValveBiped.Bip01_L_Hand" 2.571388 -0.194180 -0.125527 -1.770898 -0.051287 -11.267447 0.000000 0.000000 0.000000 0.000001 -0.000009 -0.000002 
$definebone "ValveBiped.Bip01_L_Finger31" "ValveBiped.Bip01_L_Finger3" 1.152981 0.000000 0.000000 0.105140 -1.045945 0.284987 0.000000 0.000000 0.000000 0.000002 -0.000009 -0.000002 
$definebone "ValveBiped.Bip01_L_Finger32" "ValveBiped.Bip01_L_Finger31" 0.898380 -0.000004 -0.000001 0.421467 -24.684687 0.000054 0.000002 0.000000 0.000000 -0.000000 -0.000005 -0.000003 
$definebone "ZHandTwist_L" "ValveBiped.Bip01_L_Forearm" 4.920293 0.000015 -0.000004 -36.158623 -3.429956 -174.875214 0.000000 0.000000 0.000000 -0.000000 0.000001 0.000001 
$definebone "ZArmTwist_L" "ValveBiped.Bip01_L_UpperArm" 4.134371 0.000000 0.000000 -35.943821 -8.531688 -174.922470 0.000000 0.000000 0.000000 0.000002 0.000001 0.000001 
$definebone "ValveBiped.Bip01_R_Finger2" "ValveBiped.Bip01_R_Hand" 2.662813 -0.070717 -0.489476 7.072307 -1.292715 -0.930883 0.000000 0.000004 0.000000 0.000003 -0.000007 0.000000 
$definebone "ValveBiped.Bip01_R_Finger21" "ValveBiped.Bip01_R_Finger2" 1.219875 0.000004 -0.000000 0.001378 0.229575 1.831689 0.000000 0.000000 0.000000 0.000003 -0.000007 0.000001 
$definebone "ValveBiped.Bip01_R_Finger22" "ValveBiped.Bip01_R_Finger21" 0.940397 0.000000 0.000000 -0.255536 -12.396066 0.000000 0.000000 0.000000 0.000000 0.000003 -0.000012 0.000000 
$definebone "ValveBiped.Bip01_R_Finger1" "ValveBiped.Bip01_R_Hand" 2.556286 -0.179462 -1.113195 11.649783 -1.253579 -13.801177 0.000000 0.000000 0.000000 0.000004 -0.000005 0.000003 
$definebone "ValveBiped.Bip01_R_Finger11" "ValveBiped.Bip01_R_Finger1" 1.172846 -0.000011 0.000000 0.212744 -0.766795 2.414620 0.000000 0.000000 0.000000 0.000004 -0.000005 0.000003 
$definebone "ValveBiped.Bip01_R_Finger12" "ValveBiped.Bip01_R_Finger11" 0.792910 0.000004 -0.000001 -0.240810 -13.998232 0.000174 -0.000001 0.000000 0.000000 0.000004 -0.000014 0.000003 
$definebone "ValveBiped.Bip01_R_Finger0" "ValveBiped.Bip01_R_Hand" 0.263775 -0.348503 -0.628838 42.253819 -24.701607 104.692688 0.000000 0.000000 0.000000 -0.000017 -0.000006 0.000007 
$definebone "ValveBiped.Bip01_R_Finger01" "ValveBiped.Bip01_R_Finger0" 1.130633 -0.000002 0.000000 1.564160 -1.668346 6.166409 -0.000001 -0.000002 -0.000002 -0.000015 -0.000008 0.000006 
$definebone "ValveBiped.Bip01_R_Finger02" "ValveBiped.Bip01_R_Finger01" 1.115269 0.000006 0.000002 -0.551263 20.792006 -0.000742 0.000002 -0.000002 -0.000002 -0.000019 0.000000 0.000000 
$definebone "ValveBiped.Bip01_R_Finger4" "ValveBiped.Bip01_R_Hand" 2.326683 -0.397560 0.700879 -3.435916 -1.307099 25.496569 0.000000 0.000004 0.000000 -0.000009 -0.000009 0.000003 
$definebone "ValveBiped.Bip01_R_Finger41" "ValveBiped.Bip01_R_Finger4" 0.983141 0.000008 -0.000002 -0.210452 -1.725467 -0.278969 0.000000 0.000000 0.000000 -0.000007 -0.000007 0.000003 
$definebone "ValveBiped.Bip01_R_Finger42" "ValveBiped.Bip01_R_Finger41" 0.562399 -0.000004 0.000000 -0.351400 -13.996395 0.000347 0.000000 0.000000 0.000000 -0.000003 -0.000012 0.000003 
$definebone "ValveBiped.Bip01_R_Finger3" "ValveBiped.Bip01_R_Hand" 2.570759 -0.193142 0.139615 1.489346 -0.063146 10.694029 0.000000 0.000004 0.000000 -0.000002 -0.000007 0.000000 
$definebone "ValveBiped.Bip01_R_Finger31" "ValveBiped.Bip01_R_Finger3" 1.152977 0.000000 -0.000001 -0.102446 -1.045827 -0.148338 0.000000 0.000000 0.000000 -0.000002 -0.000010 0.000000 
$definebone "ValveBiped.Bip01_R_Finger32" "ValveBiped.Bip01_R_Finger31" 0.898382 -0.000008 0.000002 -0.553536 -24.682301 0.000116 0.000000 0.000000 0.000000 -0.000003 -0.000024 0.000000 
$definebone "ZHandTwist_R" "ValveBiped.Bip01_R_Forearm" 4.920264 -0.000020 -0.000027 -32.316067 89.999901 179.999817 0.000000 0.000001 0.000000 0.000002 0.000002 -0.000007 
$definebone "ZArmTwist_R" "ValveBiped.Bip01_R_UpperArm" 4.134363 0.000016 -0.000004 -35.961639 171.552856 4.933454 0.000000 0.000000 0.000000 0.000003 -0.000001 0.000001 
$definebone "BreastUpper2_L" "ValveBiped.Bip01_Spine4" 4.645954 1.026848 2.230255 -89.999733 -9.919390 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "BreastUpper2_R" "ValveBiped.Bip01_Spine4" 4.647499 1.032566 -2.243748 -89.999733 -10.264939 0.000000 0.000000 0.000000 -0.000004 -0.000000 0.000000 0.000000 
$definebone "Knief" "ValveBiped.Bip01_Spine" 0.870571 -3.115150 -3.770222 -89.999695 4.990520 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 
$definebone "FrontSleeves_0_1" "ValveBiped.Bip01_Pelvis" -0.000002 1.688450 3.287875 -0.000057 0.000000 90.000153 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 
$definebone "FrontSleeves_3_1" "FrontSleeves_0_1" -0.000000 0.000008 2.576996 0.000000 -0.000000 -0.000115 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 
$definebone "FrontSleeves_6_1" "FrontSleeves_3_1" 0.000000 0.000002 2.576988 0.000000 -0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 
$definebone "SideSleeves_0_2" "ValveBiped.Bip01_Pelvis" 4.800942 3.553535 0.358661 -0.000000 0.000000 90.000099 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "SideSleeves_3_2" "SideSleeves_0_2" 1.013092 0.024517 2.806660 -0.000000 0.000000 -0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "SideSleeves_6_2" "SideSleeves_3_2" 1.030836 -0.013432 2.807026 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "AfterSleeves_0_4" "ValveBiped.Bip01_Pelvis" 0.000003 1.688469 -4.390042 -0.000057 0.000000 90.000153 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 
$definebone "AfterSleeves_3_4" "AfterSleeves_0_4" -0.000000 -0.859909 2.576996 0.000000 -0.000000 -0.000115 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 
$definebone "AfterSleeves_6_4" "AfterSleeves_3_4" 0.000000 -0.469208 2.576992 0.000000 -0.000000 -0.000057 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 
$definebone "L_SleeveA_01" "ValveBiped.Bip01_L_Forearm" -0.501366 -0.098574 2.836170 -36.158276 -3.429841 -174.875259 0.000000 0.000000 0.000004 0.000000 0.000001 0.000000 
$definebone "L_SleeveB_01" "ValveBiped.Bip01_L_Forearm" -0.310835 2.487154 0.751034 -36.158733 -3.429899 -174.875214 0.000000 0.000000 0.000000 0.000000 0.000001 0.000001 
$definebone "L_SleeveC_01" "ValveBiped.Bip01_L_Forearm" -0.121672 0.158803 -1.990501 -36.158684 -3.429899 -174.875229 0.000000 0.000000 0.000004 0.000003 0.000002 0.000001 
$definebone "L_SleeveD_01" "ValveBiped.Bip01_L_Forearm" -0.302229 -2.063664 0.227287 -36.158909 -3.429899 -174.875214 0.000000 0.000000 0.000000 -0.000002 0.000001 0.000001 
$definebone "SleeveE" "ZArmTwist_L" 2.364578 -0.589649 1.329384 -29.101334 40.063282 -109.105324 0.000002 0.000000 0.000000 -0.000005 -0.000005 0.000000 
$definebone "L_CollarB_01" "ValveBiped.Bip01_L_Clavicle" 1.960249 1.268234 0.671702 -0.160772 26.053881 89.908829 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 
$definebone "L_CollarC_01" "ValveBiped.Bip01_L_Clavicle" 2.695761 1.769398 -2.108343 -0.160772 26.053881 89.908829 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 
$definebone "R_Bracelet" "ValveBiped.Bip01_R_Forearm" 8.038846 -0.000037 0.000008 -36.167164 176.683228 4.932365 -0.000002 0.000000 0.000000 -0.000007 -0.000001 0.000002 
$definebone "Zip_01" "ValveBiped.Bip01_R_UpperArm" 3.330801 2.072622 -0.682835 -35.960720 171.553192 4.933454 -0.000000 0.000000 0.000000 -0.000002 -0.000000 0.000001 
$definebone "R_CapeC_Jnt1" "ValveBiped.Bip01_R_UpperArm" -0.069912 0.906928 -1.840305 -35.961868 171.552902 4.933454 0.000000 0.000000 0.000000 -0.000005 -0.000000 0.000002 
$definebone "R_CapeC_Jnt5" "R_CapeC_Jnt1" -2.736311 -0.208191 1.777721 -0.000005 -0.000000 0.000002 0.000000 0.000000 0.000000 -0.000005 -0.000000 0.000002 
$definebone "R_CapeC_Jnt9" "R_CapeC_Jnt5" -3.893618 -0.296227 2.529659 -0.000005 -0.000000 0.000059 -0.000001 0.000000 -0.000004 -0.000005 -0.000000 0.000002 
$definebone "R_CapeC_Jnt13" "R_CapeC_Jnt9" -3.893618 -0.296225 2.529625 -0.000005 -0.000000 -0.000055 0.000000 0.000000 0.000000 -0.000005 -0.000000 0.000002 
$definebone "R_CapeD_Jnt1" "ValveBiped.Bip01_R_UpperArm" 0.007914 2.477953 -0.121296 -35.960262 171.553253 4.933454 0.000000 0.000000 0.000004 -0.000003 -0.000000 0.000001 
$definebone "R_CapeD_Jnt5" "R_CapeD_Jnt1" -2.142181 -0.310485 2.450569 -0.000003 -0.000000 0.000001 0.000000 0.000000 0.000004 -0.000003 -0.000000 0.000001 
$definebone "R_CapeD_Jnt9" "R_CapeD_Jnt5" -3.048205 -0.441779 3.486988 -0.000003 -0.000000 0.000058 0.000000 0.000000 0.000000 -0.000003 -0.000000 0.000001 
$definebone "R_CapeD_Jnt13" "R_CapeD_Jnt9" -3.048218 -0.441783 3.486973 -0.000003 -0.000000 -0.000056 0.000000 0.000000 0.000000 -0.000003 -0.000000 0.000001 
$definebone "R_CollarB_01" "ValveBiped.Bip01_R_Clavicle" 2.317741 1.526947 -0.442077 0.091157 -154.042389 -90.010986 0.000000 0.000000 0.000000 -0.000003 -0.000000 0.000001 
$definebone "R_CollarC_01" "ValveBiped.Bip01_R_Clavicle" 2.675810 1.607479 2.240008 0.091157 -154.042389 -90.010986 0.000000 0.000000 0.000000 -0.000003 -0.000000 0.000001 
$definebone "Phone" "BreastUpper2_L" 0.464340 1.057479 -1.270733 -0.000000 0.000000 -0.000057 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "ClipA" "Phone" -0.461034 0.031881 0.188992 -0.000000 0.000000 0.000115 0.000000 -0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "RibbonJ_01" "BreastUpper2_L" 0.685850 2.199544 0.423634 -0.000000 0.000000 -0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "RibbonJ_02" "RibbonJ_01" 0.377205 0.603703 1.893459 -0.000000 0.000000 0.000057 0.000000 0.000000 0.000004 -0.000000 0.000000 0.000000 
$definebone "RibbonJ_03" "RibbonJ_02" 0.245484 0.240418 1.993446 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "L_CapeA_Jnt1" "BreastUpper2_L" 1.595158 2.163889 1.452988 -0.000000 0.000000 -0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "L_CapeA_Jnt5" "L_CapeA_Jnt1" 1.151755 0.381649 5.601215 -0.000000 0.000000 0.000115 0.000000 0.000000 0.000004 -0.000000 0.000000 0.000000 
$definebone "L_CapeA_Jnt9" "L_CapeA_Jnt5" 1.151755 0.381660 5.601242 -0.000000 0.000000 -0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "L_CapeA_Jnt13" "L_CapeA_Jnt9" 1.151754 0.381648 5.601227 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "RibbonE_01" "L_CapeA_Jnt13" 0.206457 0.579710 2.425198 -0.000000 0.000000 0.000057 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "R_CapeA_Jnt1" "BreastUpper2_R" -2.172478 0.882883 1.472336 -0.000000 0.000000 0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "R_CapeA_Jnt5" "R_CapeA_Jnt1" -1.246392 0.303027 5.432598 -0.000000 0.000000 -0.000229 -0.000000 0.000000 -0.000004 -0.000000 0.000000 0.000000 
$definebone "R_CapeA_Jnt9" "R_CapeA_Jnt5" -1.246386 0.303015 5.432758 -0.000000 0.000000 0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "R_CapeA_Jnt13" "R_CapeA_Jnt9" -1.246384 0.303030 5.432713 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "R_CapeA_Jnt17" "R_CapeA_Jnt13" 0.817205 0.421694 4.618914 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "R_CapeA_Jnt21" "R_CapeA_Jnt17" -0.653050 0.588241 6.464840 -0.000000 0.000000 -0.000115 -0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "R_CapeA_Jnt25" "R_CapeA_Jnt21" -1.276752 0.743046 6.354874 -0.000000 0.000000 0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "M_CollarA_01" "ValveBiped.Bip01_Spine4" 6.852283 0.058167 0.000031 -89.999733 -10.211253 0.000000 -0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "Chain_03" "ValveBiped.Bip01_Spine4" 3.566082 3.941404 0.177130 -89.999733 -10.545000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "Chain_04" "ValveBiped.Bip01_Spine4" 4.878384 2.743864 -0.656349 -89.999733 -10.215494 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "Hat_01" "ValveBiped.Bip01_Spine4" 6.627636 -5.090593 0.000031 -89.999733 -9.871203 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "Hat_02" "Hat_01" -0.000001 -1.964310 3.720959 -0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "Hat_03" "Hat_02" 0.000001 -0.480012 -2.856281 -0.000000 0.000000 -0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "M_Cape_Jnt1" "ValveBiped.Bip01_Spine4" 3.278927 -5.099619 0.000016 -89.999733 -10.377125 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "M_Cape_Jnt5" "M_Cape_Jnt1" 0.000000 -0.873336 4.770760 -0.000000 0.000000 -0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "L_CapeB_Jnt1" "M_Cape_Jnt5" 3.024378 -0.660295 4.768158 -0.000000 0.000000 0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "L_CapeB_Jnt5" "L_CapeB_Jnt1" 2.008680 -1.691057 7.049278 -0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "L_CapeB_Jnt9" "L_CapeB_Jnt5" 2.046468 -2.284343 6.868830 -0.000000 0.000000 -0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "L_CapeB_Jnt13" "L_CapeB_Jnt9" 2.046460 -2.284352 6.868828 -0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "RibbonC_Jnt1" "L_CapeB_Jnt1" 0.855251 -0.586555 0.778137 -0.000000 0.000000 -0.000057 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "RibbonC_Jnt5" "RibbonC_Jnt1" 1.948187 -3.091225 7.813740 -0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "RibbonC_Jnt9" "RibbonC_Jnt5" 1.948187 -3.091228 7.813757 -0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "RibbonC_Jnt13" "RibbonC_Jnt9" 1.948190 -3.091225 7.813753 -0.000000 0.000000 -0.000000 0.000000 0.000000 -0.000002 -0.000000 0.000000 -0.000000 
$definebone "R_CapeB_Jnt1" "M_Cape_Jnt5" -3.024370 -0.660288 4.768284 -0.000000 0.000000 0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "R_CapeB_Jnt5" "R_CapeB_Jnt1" -2.008686 -1.691044 7.049179 -0.000000 0.000000 -0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "R_CapeB_Jnt9" "R_CapeB_Jnt5" -2.046438 -2.284360 6.868776 -0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "R_CapeB_Jnt13" "R_CapeB_Jnt9" -2.046474 -2.284360 6.868832 -0.000000 0.000000 0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "L_CapeF" "M_Cape_Jnt5" 4.854838 0.371485 2.293686 -0.000000 0.000000 0.000115 -0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "R_CapeF" "M_Cape_Jnt5" -4.854839 0.371638 2.293545 -0.000000 0.000000 0.000115 -0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "BeltA_Jnt1" "M_Cape_Jnt1" 0.000006 -0.000005 -0.000015 -0.000000 0.000000 -0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "BeltA_Jnt2" "BeltA_Jnt1" -0.000001 -0.975393 2.793037 -0.000000 0.000000 -0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "BeltA_Jnt3" "BeltA_Jnt2" -0.000001 -1.046295 2.767281 -0.000000 0.000000 0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "BeltA_Jnt4" "BeltA_Jnt3" -3.734117 -2.054445 4.513763 -0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "BeltA_Jnt6" "BeltA_Jnt4" -0.674850 -1.017693 4.321392 -0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "BeltA_Jnt8" "BeltA_Jnt6" -0.674808 -1.017731 4.321457 -0.000000 0.000000 0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "RibbonB_01" "BeltA_Jnt3" -3.895116 0.231089 3.445038 -0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "RibbonB_02" "RibbonB_01" -1.208590 -1.398669 3.855606 -0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "L_CapeE" "M_Cape_Jnt1" 4.045701 0.084681 2.572830 -0.000000 0.000000 -0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "R_CapeE" "M_Cape_Jnt1" -4.045701 0.084837 2.572712 -0.000000 0.000000 -0.000057 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "R_EarA_01" "ValveBiped.Bip01_Head1" 2.561260 1.376130 4.370574 89.998550 -165.211014 0.000000 -0.000000 0.000000 -0.000004 -0.000000 0.000000 -0.000000 
$definebone "L_EarA_01" "ValveBiped.Bip01_Head1" 2.561497 1.376166 -4.370234 89.998550 -166.936462 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "L_EarA_02" "L_EarA_01" 1.787445 -0.724845 1.787437 -0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "L_EarB_01" "ValveBiped.Bip01_Head1" 7.661335 0.969304 -1.252929 89.998550 -166.499252 0.000000 0.000000 0.000000 0.000008 -0.000000 0.000000 0.000000 
$definebone "L_EarB_02" "L_EarB_01" 0.172808 -0.617988 -2.022339 -0.000000 0.000000 0.000057 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "L_HairB_01" "ValveBiped.Bip01_Head1" 6.397343 -2.197487 -0.724219 89.998550 -167.548111 0.000000 -0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "L_HairB_02" "L_HairB_01" 0.758598 0.370361 1.778320 -0.000000 0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "L_HairC_01" "ValveBiped.Bip01_Head1" 5.363174 -1.281011 -2.629470 89.998528 -165.456009 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "L_HairC_02" "L_HairC_01" 0.296149 -0.042753 2.408886 -0.000000 0.000057 0.000057 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "L_HairD_01" "ValveBiped.Bip01_Head1" 5.509205 -0.408948 -3.236319 89.998550 -167.574234 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "L_HairD_02" "L_HairD_01" 0.572596 -0.405022 2.743748 -0.000000 0.000000 0.000057 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "L_HairE_01" "ValveBiped.Bip01_Head1" 0.132935 1.654080 -1.348784 89.998550 -166.196503 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "L_HairE_02" "L_HairE_01" 0.249921 -0.728099 1.527504 -0.000000 0.000000 -0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "M_HairF_01" "ValveBiped.Bip01_Head1" -0.420654 2.116269 0.000015 89.998550 -167.123077 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "M_HairF_02" "M_HairF_01" 0.000001 -0.691534 1.195740 -0.000000 -0.000000 0.000115 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "R_EarA_02" "R_EarA_01" -1.787463 -0.724846 1.787407 -0.000000 0.000000 -0.000000 0.000000 0.000000 0.000004 -0.000000 0.000000 -0.000000 
$definebone "R_EarB_01" "ValveBiped.Bip01_Head1" 7.661381 0.969325 1.253576 89.998550 -165.823792 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "R_EarB_02" "R_EarB_01" -0.172811 -0.617987 -2.022057 -0.000000 0.000000 -0.000057 -0.000000 -0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "R_HairB_01" "ValveBiped.Bip01_Head1" 6.397320 -2.197485 0.724569 89.998550 -167.817963 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "R_HairB_02" "R_HairB_01" -0.758596 0.370363 1.778488 -0.000000 0.000000 0.000115 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "R_HairC_01" "ValveBiped.Bip01_Head1" 5.362995 -1.281038 2.629947 89.998528 -165.456009 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "R_HairC_02" "R_HairC_01" -0.296151 -0.042756 2.408794 -0.000000 0.000057 0.000057 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "R_HairD_01" "ValveBiped.Bip01_Head1" 5.508915 -0.409003 3.236814 89.998550 -166.936462 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "R_HairD_02" "R_HairD_01" -0.572588 -0.405016 2.743778 -0.000000 0.000000 -0.000057 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "R_HairE_01" "ValveBiped.Bip01_Head1" 0.132847 1.654059 1.348807 89.998550 -166.196503 0.000000 0.000000 -0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "R_HairE_02" "R_HairE_01" -0.249926 -0.728103 1.527676 -0.000000 0.000000 0.000229 0.000000 0.000000 0.000000 -0.000000 0.000000 -0.000000 
$definebone "Plait_Jnt1" "ValveBiped.Bip01_Head1" 5.212753 6.616145 0.000271 89.998528 -163.208023 0.000000 -0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "Plait_Jnt5" "Plait_Jnt1" 0.000008 -3.844866 7.576172 -0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "Plait_Jnt9" "Plait_Jnt5" 0.000011 -2.561467 8.100658 -0.000000 -0.000000 0.000229 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "Plait_Jnt13" "Plait_Jnt9" 0.000021 -2.121163 8.226917 -0.000000 -0.000000 -0.000229 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "Plait_Jnt17" "Plait_Jnt13" 0.000012 -2.869190 7.565613 -0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "Plait_Jnt21" "Plait_Jnt17" 0.000009 -4.001745 7.032558 -0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "Plait_Jnt25" "Plait_Jnt21" 0.000009 -4.001747 7.032562 -0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "Plait_Jnt29" "Plait_Jnt25" 0.000011 -3.220516 7.422872 -0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "L_PlaitB" "Plait_Jnt9" 1.618277 -1.369873 5.116982 -0.000000 -0.000000 -0.000229 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "R_PlaitB" "Plait_Jnt9" -1.618266 -1.369877 5.116993 -0.000000 -0.000000 -0.000114 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "L_PlaitA" "Plait_Jnt5" 3.351578 0.610249 -1.604958 -0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "R_PlaitA" "Plait_Jnt5" -3.351447 0.610250 -1.604919 -0.000000 -0.000000 0.000057 0.000000 -0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "RibbonF_01" "ValveBiped.Bip01_Head1" 5.468513 6.535377 0.000277 89.998550 -166.953140 0.000000 -0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "RibbonF_02" "RibbonF_01" -0.000003 -1.717993 -1.100021 -0.000000 0.000000 -0.000057 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "RibbonG_01" "ValveBiped.Bip01_Head1" 4.021687 6.082070 -0.308774 89.998550 -166.955719 0.000000 0.000000 0.000000 0.000000 -0.000000 0.000000 0.000000 
$definebone "RibbonH_01" "ValveBiped.Bip01_Head1" 3.860352 6.069139 -0.255084 89.998550 -167.460220 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "RibbonH_02" "RibbonH_01" 0.137824 -0.407634 1.914932 -0.000000 -0.000000 0.000057 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "RibbonH_03" "RibbonH_02" 0.137486 -0.285604 1.936893 -0.000000 -0.000000 -0.000057 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "RibbonI_01" "ValveBiped.Bip01_Head1" 4.074841 6.088397 0.168863 89.998550 -166.948120 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "RibbonI_02" "RibbonI_01" -0.478467 -0.244037 1.429482 -0.000000 -0.000000 -0.000057 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "FLH_0_1" "ValveBiped.Bip01_Head1" 1.671352 -0.892581 -2.613133 89.998550 -167.105164 0.000000 0.000000 -0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "FLH_2_1" "FLH_0_1" -0.016023 -0.232545 1.778595 -0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "FLH_4_1" "FLH_2_1" 0.322581 0.325073 1.778603 -0.000000 -0.000000 0.000000 0.000000 -0.000000 0.000004 -0.000000 -0.000000 0.000000 
$definebone "FLH_6_1" "FLH_4_1" 0.561080 0.663026 1.778606 -0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 
$definebone "FLH_8_1" "FLH_6_1" 0.691881 0.819267 1.778591 -0.000000 -0.000000 0.000000 -0.000000 0.000000 -0.000004 -0.000000 -0.000000 0.000000 
$definebone "FLH_10_1" "FLH_8_1" 0.707389 0.831751 1.778595 -0.000000 -0.000000 0.000000 0.000000 0.000000 0.000000 -0.000000 -0.000000 0.000000 

//Define Hbox Head
$hbox 3 "ValveBiped.Bip01_Pelvis" -5.75 -5.43 -4.99  5.75 5.82 3.84 
$hbox 6 "ValveBiped.Bip01_L_Thigh" -3.97 -4.33 -5.84  22.07 3.94 3.62 
$hbox 6 "ValveBiped.Bip01_L_Calf" -5.84 -2.96 -2.02  18.29 3.17 2.30 
$hbox 6 "ValveBiped.Bip01_L_Foot" -2.68 -2.42 -1.83  6.41 6.63 2.18 
$hbox 7 "ValveBiped.Bip01_R_Thigh" -4.12 -4.33 -3.62  22.07 3.94 5.84 
$hbox 7 "ValveBiped.Bip01_R_Calf" -5.84 -2.96 -2.30  18.29 3.17 2.02 
$hbox 7 "ValveBiped.Bip01_R_Foot" -2.68 -2.42 -2.22  6.41 6.63 1.80 
$hbox 3 "ValveBiped.Bip01_Spine" -4.62 -4.17 -5.08  7.52 5.16 5.08 
$hbox 2 "ValveBiped.Bip01_Spine1" -3.38 -4.33 -4.62  6.36 5.11 4.68 
$hbox 2 "ValveBiped.Bip01_Spine4" -2.94 -5.68 -4.87  9.17 4.67 5.07 
$hbox 5 "ValveBiped.Bip01_R_Clavicle" -1.37 -5.12 -4.77  5.72 2.83 5.06 
$hbox 5 "ValveBiped.Bip01_R_UpperArm" -2.79 -2.32 -2.75  9.14 3.40 2.67 
$hbox 5 "ValveBiped.Bip01_R_Forearm" -2.73 -1.29 -1.43  10.77 1.47 1.35 
$hbox 5 "ValveBiped.Bip01_R_Hand" -0.95 -1.12 -1.75  3.18 0.96 1.01 
$hbox 4 "ValveBiped.Bip01_L_Clavicle" -1.32 -5.40 -4.40  5.92 3.40 5.01 
$hbox 4 "ValveBiped.Bip01_L_UpperArm" -2.74 -2.32 -2.67  9.41 3.18 2.92 
$hbox 4 "ValveBiped.Bip01_L_Forearm" -2.22 -2.06 -1.99  10.63 2.49 2.84 
$hbox 4 "ValveBiped.Bip01_L_Hand" -1.24 -1.15 -1.36  3.52 1.03 1.71 
$hbox 8 "ValveBiped.Bip01_Neck1" -1.35 -2.27 -2.47  4.09 4.50 3.96 
$hbox 1 "ValveBiped.Bip01_Head1" -2.77 -4.19 -7.96  10.19 9.55 7.96 

//Define Jbone Head
$jigglebone "L_Boots_01"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -10 10
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -5 5
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 10
 }
}
$jigglebone "R_Boots_01"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -10 10
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -5 5
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 10
 }
}
$jigglebone "BreastUpper2_L"
{
 is_flexible
 {
     length 15
     tip_mass 30
     pitch_stiffness 40
     pitch_damping 5
     yaw_stiffness 40
     yaw_damping 3
     along_stiffness 100
     along_damping 0
     angle_constraint 14
 }
 has_base_spring
 {
     base_mass 15
     stiffness 50
     damping 6
     left_constraint -0.15 0.15
     left_friction 0.01
     up_constraint -0.15 0.15
     up_friction 0.01
     forward_constraint -0.01 0.01
     forward_friction 0.05
 }
}
$jigglebone "BreastUpper2_R"
{
 is_flexible
 {
     length 15
     tip_mass 30
     pitch_stiffness 40
     pitch_damping 5
     yaw_stiffness 40
     yaw_damping 3
     along_stiffness 100
     along_damping 0
     angle_constraint 14
 }
 has_base_spring
 {
     base_mass 15
     stiffness 50
     damping 6
     left_constraint -0.15 0.15
     left_friction 0.01
     up_constraint -0.15 0.15
     up_friction 0.01
     forward_constraint -0.01 0.01
     forward_friction 0.05
 }
}
$jigglebone "Knief"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "FrontSleeves_0_1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "FrontSleeves_3_1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "FrontSleeves_6_1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "SideSleeves_0_2"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 -2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "SideSleeves_3_2"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 -2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "SideSleeves_6_2"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 -2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "AfterSleeves_0_4"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "AfterSleeves_3_4"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "AfterSleeves_6_4"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_SleeveA_01"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "L_SleeveB_01"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "L_SleeveC_01"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "L_SleeveD_01"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "SleeveE"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "L_CollarB_01"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "L_CollarC_01"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "Zip_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeC_Jnt1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeC_Jnt5"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeC_Jnt9"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeC_Jnt13"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeD_Jnt1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeD_Jnt5"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeD_Jnt9"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 -2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeD_Jnt13"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 -2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CollarB_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CollarC_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "Phone"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "ClipA"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "RibbonJ_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonJ_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonJ_03"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_CapeA_Jnt1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_CapeA_Jnt5"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 -2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_CapeA_Jnt9"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 -2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_CapeA_Jnt13"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 -2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonE_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 -2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeA_Jnt1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeA_Jnt5"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 -2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeA_Jnt9"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 -2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeA_Jnt13"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 -2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeA_Jnt17"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 -2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeA_Jnt21"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 -2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeA_Jnt25"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 -2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "M_CollarA_01"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "Chain_03"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "Chain_04"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "Hat_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "Hat_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "Hat_03"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "M_Cape_Jnt1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "M_Cape_Jnt5"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_CapeB_Jnt1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_CapeB_Jnt5"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_CapeB_Jnt9"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_CapeB_Jnt13"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonC_Jnt1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonC_Jnt5"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonC_Jnt9"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonC_Jnt13"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeB_Jnt1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeB_Jnt5"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeB_Jnt9"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_CapeB_Jnt13"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_CapeF"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "R_CapeF"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "BeltA_Jnt1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "BeltA_Jnt2"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "BeltA_Jnt3"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "BeltA_Jnt4"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "BeltA_Jnt6"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "BeltA_Jnt8"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonB_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonB_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -10 10
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_CapeE"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "R_CapeE"
{
 is_flexible
 {
     length 15
     tip_mass 0
     pitch_constraint -25 25
     pitch_stiffness 10
     pitch_damping 2
     yaw_constraint -10 10
     yaw_stiffness 10
     yaw_damping 2
     along_stiffness 100
     along_damping 0
     angle_constraint 30
 }
}
$jigglebone "R_EarA_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_EarA_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_EarA_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_EarB_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_EarB_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_HairB_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_HairB_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_HairC_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_HairC_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_HairD_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_HairD_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_HairE_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_HairE_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "M_HairF_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "M_HairF_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_EarA_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_EarB_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_EarB_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_HairB_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_HairB_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_HairC_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_HairC_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_HairD_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_HairD_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_HairE_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_HairE_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -45 2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "Plait_Jnt1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "Plait_Jnt5"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "Plait_Jnt9"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "Plait_Jnt13"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "Plait_Jnt17"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "Plait_Jnt21"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "Plait_Jnt25"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "Plait_Jnt29"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_PlaitB"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_PlaitB"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "L_PlaitA"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "R_PlaitA"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonF_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonF_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonG_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonH_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonH_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonH_03"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonI_01"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "RibbonI_02"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -45 2
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 -2
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "FLH_0_1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "FLH_2_1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "FLH_4_1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "FLH_6_1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "FLH_8_1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}
$jigglebone "FLH_10_1"
{
 is_flexible
 {
     length 10
     tip_mass 100
     pitch_constraint -2 45
     pitch_stiffness 25
     pitch_damping 2
     yaw_constraint -2 45
     yaw_stiffness 25
     yaw_damping 2
     along_stiffness 50
     along_damping 1
     angle_constraint 90
 }
}

$ikchain "rhand" "ValveBiped.Bip01_R_Hand" knee 0.707 0.707 0 
$ikchain "lhand" "ValveBiped.Bip01_L_Hand" knee 0.707 0.707 0 
$ikchain "rfoot" "ValveBiped.Bip01_R_Foot" knee 0.707 -0.707 0 
$ikchain "lfoot" "ValveBiped.Bip01_L_Foot" knee 0.707 -0.707 0 

$ikautoplaylock "rfoot" 0.7 0.1 
$ikautoplaylock "lfoot" 0.7 0.1 

$sequence reference "anims/reference_female" fps 1 
$origin 0 0 -2.40 

$animation a_proportions "anims/proportions" subtract reference 0 

$sequence proportions a_proportions predelta autoplay 

$Sequence "ragdoll" {
	"anims/proportions"
	activity "ACT_DIERAGDOLL" 1
	fadein 0.2
	fadeout 0.2
	fps 60
}

$includemodel "f_anm.mdl" 
$includemodel "f_anm.mdl" 
$includemodel "f_gst.mdl" 
$includemodel "f_pst.mdl" 
$includemodel "f_shd.mdl" 
$includemodel "f_ss.mdl" 
$includemodel "humans/female_shared.mdl" 
$includemodel "humans/female_ss.mdl" 
$includemodel "humans/female_gestures.mdl" 
$includemodel "humans/female_postures.mdl" 
$includemodel "alyx_animations.mdl" 
$includemodel "alyx_postures.mdl" 
$includemodel "humans/female_shared.mdl" 
$includemodel "humans/female_ss.mdl" 

//Define Collision Head
$collisionjoints "Physics.smd" 
{
	$mass 48 
	$inertia 12 
	$damping 0.8 
	$rotdamping 4 
	$rootbone "ValveBiped.Bip01_Pelvis" 

	$jointrotdamping "ValveBiped.Bip01_Pelvis" 3 

	$jointmassbias "ValveBiped.Bip01_Spine1" 8 
	$jointrotdamping "ValveBiped.Bip01_Spine1" 5 
	$jointconstrain "ValveBiped.Bip01_Spine1" x limit -10 10 0 
	$jointconstrain "ValveBiped.Bip01_Spine1" y limit -16 16 0 
	$jointconstrain "ValveBiped.Bip01_Spine1" z limit -19 19 0 

	$jointmassbias "ValveBiped.Bip01_Spine4" 9 
	$jointrotdamping "ValveBiped.Bip01_Spine4" 5 
	$jointconstrain "ValveBiped.Bip01_Spine4" x limit -10 10 0 
	$jointconstrain "ValveBiped.Bip01_Spine4" y limit -10 10 0 
	$jointconstrain "ValveBiped.Bip01_Spine4" z limit -20 20 0 

	$jointmassbias "ValveBiped.Bip01_R_Clavicle" 4 
	$jointrotdamping "ValveBiped.Bip01_R_Clavicle" 6 
	$jointconstrain "ValveBiped.Bip01_R_Clavicle" x limit -10 10 0 
	$jointconstrain "ValveBiped.Bip01_R_Clavicle" y limit -5 5 0 
	$jointconstrain "ValveBiped.Bip01_R_Clavicle" z limit 0 15 0 

	$jointmassbias "ValveBiped.Bip01_R_UpperArm" 5 
	$jointconstrain "ValveBiped.Bip01_R_UpperArm" x limit -15 20 0 
	$jointconstrain "ValveBiped.Bip01_R_UpperArm" y limit -40 32 0 
	$jointconstrain "ValveBiped.Bip01_R_UpperArm" z limit -80 25 0 

	$jointmassbias "ValveBiped.Bip01_L_Clavicle" 4 
	$jointrotdamping "ValveBiped.Bip01_L_Clavicle" 6 
	$jointconstrain "ValveBiped.Bip01_L_Clavicle" x limit -10 10 0 
	$jointconstrain "ValveBiped.Bip01_L_Clavicle" y limit -5 5 0 
	$jointconstrain "ValveBiped.Bip01_L_Clavicle" z limit 0 15 0 

	$jointmassbias "ValveBiped.Bip01_L_UpperArm" 5 
	$jointconstrain "ValveBiped.Bip01_L_UpperArm" x limit -15 20 0 
	$jointconstrain "ValveBiped.Bip01_L_UpperArm" y limit -40 32 0 
	$jointconstrain "ValveBiped.Bip01_L_UpperArm" z limit -80 25 0 

	$jointmassbias "ValveBiped.Bip01_L_Forearm" 4 
	$jointrotdamping "ValveBiped.Bip01_L_Forearm" 4 
	$jointconstrain "ValveBiped.Bip01_L_Forearm" x limit -40 15 0 
	$jointconstrain "ValveBiped.Bip01_L_Forearm" y limit 0 0 0 
	$jointconstrain "ValveBiped.Bip01_L_Forearm" z limit -120 10 0 

	$jointrotdamping "ValveBiped.Bip01_L_Hand" 1 
	$jointconstrain "ValveBiped.Bip01_L_Hand" x limit -25 25 0 
	$jointconstrain "ValveBiped.Bip01_L_Hand" y limit -35 35 0 
	$jointconstrain "ValveBiped.Bip01_L_Hand" z limit -50 50 0 

	$jointmassbias "ValveBiped.Bip01_R_Forearm" 4 
	$jointrotdamping "ValveBiped.Bip01_R_Forearm" 4 
	$jointconstrain "ValveBiped.Bip01_R_Forearm" x limit -40 15 0 
	$jointconstrain "ValveBiped.Bip01_R_Forearm" y limit 0 0 0 
	$jointconstrain "ValveBiped.Bip01_R_Forearm" z limit -120 10 0 

	$jointrotdamping "ValveBiped.Bip01_R_Hand" 1 
	$jointconstrain "ValveBiped.Bip01_R_Hand" x limit -25 25 0 
	$jointconstrain "ValveBiped.Bip01_R_Hand" y limit -35 35 0 
	$jointconstrain "ValveBiped.Bip01_R_Hand" z limit -50 50 0 

	$jointmassbias "ValveBiped.Bip01_Head1" 4 
	$jointrotdamping "ValveBiped.Bip01_Head1" 3 
	$jointconstrain "ValveBiped.Bip01_Head1" x limit -50 50 0 
	$jointconstrain "ValveBiped.Bip01_Head1" y limit -20 20 0 
	$jointconstrain "ValveBiped.Bip01_Head1" z limit -26 30 0 

	$jointmassbias "ValveBiped.Bip01_R_Thigh" 7 
	$jointrotdamping "ValveBiped.Bip01_R_Thigh" 7 
	$jointconstrain "ValveBiped.Bip01_R_Thigh" x limit -30 30 0 
	$jointconstrain "ValveBiped.Bip01_R_Thigh" y limit -60 30 0 
	$jointconstrain "ValveBiped.Bip01_R_Thigh" z limit -100 30 0 

	$jointmassbias "ValveBiped.Bip01_R_Calf" 4 
	$jointrotdamping "ValveBiped.Bip01_R_Calf" 5 
	$jointconstrain "ValveBiped.Bip01_R_Calf" x limit -15 15 0 
	$jointconstrain "ValveBiped.Bip01_R_Calf" y limit -5 5 0 
	$jointconstrain "ValveBiped.Bip01_R_Calf" z limit -10 125 0 

	$jointrotdamping "ValveBiped.Bip01_R_Foot" 9 
	$jointconstrain "ValveBiped.Bip01_R_Foot" x limit -15 15 0 
	$jointconstrain "ValveBiped.Bip01_R_Foot" y limit -15 15 0 
	$jointconstrain "ValveBiped.Bip01_R_Foot" z limit -18 25 0 

	$jointmassbias "ValveBiped.Bip01_L_Thigh" 7 
	$jointrotdamping "ValveBiped.Bip01_L_Thigh" 7 
	$jointconstrain "ValveBiped.Bip01_L_Thigh" x limit -30 30 0 
	$jointconstrain "ValveBiped.Bip01_L_Thigh" y limit -30 60 0 
	$jointconstrain "ValveBiped.Bip01_L_Thigh" z limit -100 30 0 

	$jointmassbias "ValveBiped.Bip01_L_Calf" 4 
	$jointrotdamping "ValveBiped.Bip01_L_Calf" 5 
	$jointconstrain "ValveBiped.Bip01_L_Calf" x limit -15 15 0 
	$jointconstrain "ValveBiped.Bip01_L_Calf" y limit -5 5 0 
	$jointconstrain "ValveBiped.Bip01_L_Calf" z limit -10 125 0 

	$jointrotdamping "ValveBiped.Bip01_L_Foot" 9 
	$jointconstrain "ValveBiped.Bip01_L_Foot" x limit -15 15 0 
	$jointconstrain "ValveBiped.Bip01_L_Foot" y limit -15 15 0 
	$jointconstrain "ValveBiped.Bip01_L_Foot" z limit -18 25 0 

	$jointconstrain "FrontSleeves_0_1" x limit -80 2 0 
	$jointconstrain "FrontSleeves_0_1" y limit -2 2 0 
	$jointconstrain "FrontSleeves_0_1" z limit -2 2 0 

	$jointconstrain "FrontSleeves_3_1" x limit -80 2 0 
	$jointconstrain "FrontSleeves_3_1" y limit -2 2 0 
	$jointconstrain "FrontSleeves_3_1" z limit -2 2 0 

	$jointconstrain "SideSleeves_0_2" x limit -2 2 0 
	$jointconstrain "SideSleeves_0_2" y limit -2 80 0 
	$jointconstrain "SideSleeves_0_2" z limit -2 2 0 

	$jointconstrain "SideSleeves_3_2" x limit -2 2 0 
	$jointconstrain "SideSleeves_3_2" y limit -2 80 0 
	$jointconstrain "SideSleeves_3_2" z limit -2 2 0 

	$jointconstrain "AfterSleeves_0_4" x limit -2 80 0 
	$jointconstrain "AfterSleeves_0_4" y limit -2 2 0 
	$jointconstrain "AfterSleeves_0_4" z limit -2 2 0 

	$jointconstrain "AfterSleeves_3_4" x limit -2 80 0 
	$jointconstrain "AfterSleeves_3_4" y limit -2 2 0 
	$jointconstrain "AfterSleeves_3_4" z limit -2 2 0 

	$jointconstrain "FLH_0_1" x limit -100 100 0 
	$jointconstrain "FLH_0_1" y limit -45 45 0 
	$jointconstrain "FLH_0_1" z limit -30 30 0 

	$jointconstrain "FLH_4_1" x limit -100 100 0 
	$jointconstrain "FLH_4_1" y limit -45 45 0 
	$jointconstrain "FLH_4_1" z limit -30 30 0 

	$jointconstrain "Plait_Jnt1" x limit -30 105 0 
	$jointconstrain "Plait_Jnt1" y limit -30 30 0 
	$jointconstrain "Plait_Jnt1" z limit -15 15 0 

	$jointconstrain "Plait_Jnt5" x limit -100 100 0 
	$jointconstrain "Plait_Jnt5" y limit -45 45 0 
	$jointconstrain "Plait_Jnt5" z limit -30 30 0 

	$jointconstrain "Plait_Jnt9" x limit -100 100 0 
	$jointconstrain "Plait_Jnt9" y limit -45 45 0 
	$jointconstrain "Plait_Jnt9" z limit -30 30 0 

	$jointconstrain "Plait_Jnt13" x limit -100 100 0 
	$jointconstrain "Plait_Jnt13" y limit -45 45 0 
	$jointconstrain "Plait_Jnt13" z limit -30 30 0 

	$jointconstrain "Plait_Jnt17" x limit -100 100 0 
	$jointconstrain "Plait_Jnt17" y limit -45 45 0 
	$jointconstrain "Plait_Jnt17" z limit -30 30 0 

	$jointconstrain "Plait_Jnt21" x limit -100 100 0 
	$jointconstrain "Plait_Jnt21" y limit -45 45 0 
	$jointconstrain "Plait_Jnt21" z limit -30 30 0 

}

$collisiontext
{
	animatedfriction
	{
		animfrictionmin		"80.000000"
		animfrictionmax		"600.000000"
		animfrictiontimein		"0.150000"
		animfrictiontimeout		"0.250000"
		animfrictiontimehold		"1.750000"
	}
	editparams
	{
		rootname		"valvebiped.bip01_pelvis"
		totalmass		"50.000000"
	}
}
