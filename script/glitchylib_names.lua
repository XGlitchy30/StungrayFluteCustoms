--Custom Cards associated with custom effects

CARD_HIDDEN_MONASTERY_OF_NECROVALLEY	=	130000000   --[[While this effect is applied to a card, that card will only be affected by the effect of EFFECT_NECRO_VALLEY that prevents the change of
															Type/Attribute]]
															
CARD_MX_MUSIC							=	130000022	--[[This effect must be assigned to monsters that cannot be Special Summoned from the banishment due to specific card effects and restrictions.
															Named after "Mx. Music", this effect is necessary to correctly handle interactions with effects that banish a monster and Special Summon the same monster right after.
															It is the banishment analogue of the CARD_CLOCK_LIZARD effect, which handles Summons from the Extra Deck instead (see "Clock Lizard")]]
															
CARD_ANCESTAGON_PLASMATAIL				=	130000138	--[[This effect is used to implement certain procedures in such a way that they interact correctly with "Ancestagon Plasmatail". The Value Function specifies which player cannot target the card affected by this effect]]

CARD_ANCESTAGON_DUKE_SILVERAPTOR		=	130000150	--[[Hardcoded effect specific to "Ancestagon Duke Silveraptor"]]

--Custom Archetypes
SET_MOBLINS					=	0x300
SET_WICCINK					=	0x301
SET_LINAAN					=	0x302
SET_MOTHERHOOD				=	0x303
SET_QUELTZ					=	0x304
SET_FIENTHALETE				=	0x305
SET_PERCUSSION_BEETLE		=	0x306
SET_DEMONISU				=	0x307
SET_ANCESTAGON				=	0x308
SET_LADY_LUCK				=	0x309
SET_FLAMESPEAR				=	0x30a
SET_FLAMESPEAR_STYLE		=	0x130a
SET_VIXEN_BREW				=	0x30b

--Official Cards/Custom Cards
CARD_AMPLIFIER				=	303660
CARD_DHERO_DRILLDARK		=	91691605
CARD_FIREWING_PEGASUS		=	27054370
CARD_GAIA_THE_FIERCE_KNIGHT	=	6368038
CARD_KAISER_DRAGON			=	94566432
CARD_MIRACLE_STONE			=	31461282
CARD_ZOMBIE_WORLD			=	4064256

CARD_ADIRA_APOTHEOSIZED		=   130000020
CARD_ADIRAS_WILL			=	130000021
CARD_BEF_SHIELD_MACHINERY	=	130000132
CARD_BEF_ZELOS_FORCE		=	130000133
CARD_HIERATIC_AWAKENING		=	130000069
CARD_NUMBERS_REVOLUTION		=	130000015
CARD_REGRESSED_RITUAL_ART	=	130000003
CARD_THE_VALLEY_OF_LINAAN	=	130000078
CARD_VALERIE_THE_FLAMESPEAR	=	130000164
CARD_WAVE_KING_OF_DEMONISU	=	130000126

--Custom Tokens
TOKEN_ANCESTAGON			=	130000151
TOKEN_BES_GARUN				=	130000137
TOKEN_LADY_LUCK				=	130000161
TOKEN_WICCINK				=	130000050

--Official Counters/Custom Counters
COUNTER_BES					=	0x1f

--Desc
STRING_ACTIVATE_PENDULUM			=	4003
STRING_ADD_TO_HAND					=	1105
STRING_BANISH_TEMP					=	4006
STRING_BANISHMENT					=	4009
STRING_CHANGE_POSITION				=	4016
STRING_COIN							=	4010
STRING_DECKBOTTOM					=	4008
STRING_DECKTOP						=	4007
STRING_DETACH						=	4004
STRING_DICE							=	4011
STRING_DO_NOT_APPLY					=	4014
STRING_EQUIPPED_BY_OWN_EFFECT		=	4005
STRING_FAST_ACTIVATION				=	4013
STRING_PLACE_COUNTER				=	4012
STRING_PLACE_IN_PZONE				=	4015
STRING_RELEASE						=	500
STRING_SPECIAL_SUMMON				=	2
STRING_SELECT_DIE_RESULT			=	4017
STRING_SET_SPELLTRAP				=	4018
STRING_DISABLE						=	4019

STRING_AVOID_BATTLE_DAMAGE								=	3210
STRING_CANNOT_ATTACK									=	3206
STRING_CANNOT_BE_DESTROYED								=	3008
STRING_CANNOT_BE_DESTROYED_BY_BATTLE					=	3000
STRING_CANNOT_BE_DESTROYED_BY_EFFECTS					=	3001
STRING_CANNOT_BE_DESTROYED_OR_TARGETED_BY_EFFECTS		=	3009
STRING_CANNOT_BE_DESTROYED_OR_TARGETED_BY_EFFECTS_OPPO	=	3067
STRING_CANNOT_BE_DESTROYED_AT_ALL						=	4000
STRING_CANNOT_BE_TRIBUTED								=	3303
STRING_CANNOT_TRIGGER									=	3302

STRING_BANISH_REDIRECT									=	3300
STRING_BOTTOM_OF_DECK_REDIRECT							=	4002
STRING_SHUFFLE_INTO_DECK_REDIRECT						=	3301
STRING_TOP_OF_DECK_REDIRECT								=	4001

STRING_ASK_POSITION										=	5000
STRING_ASK_TO_HAND										=	5001
STRING_ASK_SHUFFLE_DECK									=	5002
STRING_ASK_SUMMON										=	5003
STRING_ASK_RETURN_TO_HAND								=	5004
STRING_ASK_SET											=	5005
STRING_ASK_SPSUMMON										=	5006
STRING_ASK_BANISH										=	5007
STRING_ASK_SEARCH										=	5008
STRING_ASK_DESTROY										=	5009

----Hint messages
HINTMSG_ATTACHTO					=	aux.Stringid(130000015,2)
HINTMSG_EQUIPTO						=	4800
HINTMSG_TOEXTRA						=	4801