GlitchyHelper=GlitchyHelper or {}
help=GlitchyHelper

--Glitchy Helper
local s,id=GetID()
TOKEN_GLITCHY_HELPER					= 1232

GLITCHY_HELPER_FLAG_MANUAL_MOVEMENT		= 0x1
GLITCHY_HELPER_FLAG_NORMAL_SUMMON		= 0x2
GLITCHY_HELPER_FLAG_SPECIAL_SUMMON		= 0x4
GLITCHY_HELPER_FLAG_PENDULUM_SUMMON		= 0x8
GLITCHY_HELPER_FLAG_POSITION			= 0x10
GLITCHY_HELPER_FLAG_EQUIP				= 0x20
GLITCHY_HELPER_FLAG_LP					= 0x40
GLITCHY_HELPER_FLAG_DRAWORDISCARD		= 0x80
GLITCHY_HELPER_FLAG_GAMBLE				= 0x100
GLITCHY_HELPER_FLAG_COUNTER				= 0x200
GLITCHY_HELPER_FLAG_CONCEDE_CONTROL		= 0x400

GLITCHY_HELPER_FLAGS_STANDARD			= 0x7ff

local STRING_EXCLUDE_AI 					= aux.Stringid(TOKEN_GLITCHY_HELPER,0)
local STRING_ASK_FOR_OPPONENT_PERMISSION 	= aux.Stringid(TOKEN_GLITCHY_HELPER,1)
local STRING_SELECT_CARDS_TO_MOVE			= aux.Stringid(TOKEN_GLITCHY_HELPER,2)
local STRING_DO_NOTHING						= aux.Stringid(TOKEN_GLITCHY_HELPER,3)
local STRING_SHUFFLE_DECK					= aux.Stringid(TOKEN_GLITCHY_HELPER,4)
local STRING_REARRANGE						= aux.Stringid(TOKEN_GLITCHY_HELPER,5)
local STRING_SELF_DESTINATION				= aux.Stringid(TOKEN_GLITCHY_HELPER,6)
local STRING_OPPO_DESTINATION				= aux.Stringid(TOKEN_GLITCHY_HELPER,7)
local STRING_CONFIRM_SELECTION				= aux.Stringid(TOKEN_GLITCHY_HELPER,8)
local STRING_ALL_FACEUP						= aux.Stringid(TOKEN_GLITCHY_HELPER,9)
local STRING_ALL_FACEDOWN					= aux.Stringid(TOKEN_GLITCHY_HELPER,10)
local STRING_CHOOSE_FOR_EACH_CARD			= aux.Stringid(TOKEN_GLITCHY_HELPER,11)
local STRING_IGNORE_DECK					= aux.Stringid(TOKEN_GLITCHY_HELPER,12)
local STRING_INCLUDE_DECK					= aux.Stringid(TOKEN_GLITCHY_HELPER,13)
local STRING_TRANSFER_MATERIALS				= aux.Stringid(TOKEN_GLITCHY_HELPER,14)
local STRING_MANUAL_MOVEMENT				= aux.Stringid(TOKEN_GLITCHY_HELPER,15)

local STRING_NORMAL_SUMMON					= aux.Stringid(TOKEN_GLITCHY_HELPER+1,0)
local STRING_REGULAR_SUMMON					= aux.Stringid(TOKEN_GLITCHY_HELPER+1,1)
local STRING_NO_TRIBUTING					= aux.Stringid(TOKEN_GLITCHY_HELPER+1,2)
local STRING_MODIFIED_TRIBUTING				= aux.Stringid(TOKEN_GLITCHY_HELPER+1,3)
local STRING_ALLOW_RESPONSE					= aux.Stringid(TOKEN_GLITCHY_HELPER+1,4)
local STRING_SPECIAL_SUMMON					= aux.Stringid(TOKEN_GLITCHY_HELPER+1,5)
local STRING_REGULAR_SPSUMMON				= aux.Stringid(TOKEN_GLITCHY_HELPER+1,6)
local STRING_SPSUMMON_TO_OPPO				= aux.Stringid(TOKEN_GLITCHY_HELPER+1,7)
local STRING_SPSUMMON_PROC					= aux.Stringid(TOKEN_GLITCHY_HELPER+1,8)
local STRING_KEEP_SPSUMMONING				= aux.Stringid(TOKEN_GLITCHY_HELPER+1,9)
local STRING_TREAT_AS_SPSUMMON				= aux.Stringid(TOKEN_GLITCHY_HELPER+1,10)
local STRING_PENDULUM_SUMMON				= aux.Stringid(TOKEN_GLITCHY_HELPER+1,11)
local STRING_SPSUMMON_MONSTER				= aux.Stringid(TOKEN_GLITCHY_HELPER+1,12)
local STRING_SPSUMMON_TOKEN					= aux.Stringid(TOKEN_GLITCHY_HELPER+1,13)
local STRING_HOW_MANY_TOKENS				= aux.Stringid(TOKEN_GLITCHY_HELPER+1,14)
local STRING_ASK_OPPO_TOKEN					= aux.Stringid(TOKEN_GLITCHY_HELPER+1,15)

local STRING_CHANGE_POSITION				= aux.Stringid(TOKEN_GLITCHY_HELPER+2,0)
local STRING_CONCEDE_CONTROL				= aux.Stringid(TOKEN_GLITCHY_HELPER+2,1)
local STRING_STOP							= aux.Stringid(TOKEN_GLITCHY_HELPER+2,2)
local STRING_GLITCHY_HELPER_EQUIP			= aux.Stringid(TOKEN_GLITCHY_HELPER+2,3)
local STRING_ASK_UNION_STATE				= aux.Stringid(TOKEN_GLITCHY_HELPER+2,4)
local STRING_TOPDECK_ONLY					= aux.Stringid(TOKEN_GLITCHY_HELPER+2,5)
local STRING_SELECT_TOPDECK					= aux.Stringid(TOKEN_GLITCHY_HELPER+2,6)
local STRING_GLITCHY_HELPER_LP				= aux.Stringid(TOKEN_GLITCHY_HELPER+2,7)
local STRING_LP_INCREASE					= aux.Stringid(TOKEN_GLITCHY_HELPER+2,8)
local STRING_LP_DECREASE					= aux.Stringid(TOKEN_GLITCHY_HELPER+2,9)
local STRING_LP_CHANGE						= aux.Stringid(TOKEN_GLITCHY_HELPER+2,10)
local STRING_LP_RECOVER						= aux.Stringid(TOKEN_GLITCHY_HELPER+2,11)
local STRING_LP_DAMAGE						= aux.Stringid(TOKEN_GLITCHY_HELPER+2,12)
local STRING_LP_PAYMENT						= aux.Stringid(TOKEN_GLITCHY_HELPER+2,13)
local STRING_LP_LOSE						= aux.Stringid(TOKEN_GLITCHY_HELPER+2,14)
local STRING_LP_INFO						= aux.Stringid(TOKEN_GLITCHY_HELPER+2,15)

local STRING_GLITCHY_HELPER_DRAWORDISCARD	= aux.Stringid(TOKEN_GLITCHY_HELPER+3,0)
local STRING_GAMBLE							= aux.Stringid(TOKEN_GLITCHY_HELPER+3,1)
local STRING_HINT_GAMBLE					= aux.Stringid(TOKEN_GLITCHY_HELPER+3,2)
local STRING_INFO_COUNTER					= aux.Stringid(TOKEN_GLITCHY_HELPER+3,3)
local STRING_HOW_MANY_COUNTERS				= aux.Stringid(TOKEN_GLITCHY_HELPER+3,4)
local STRING_REVEAL_ONLY					= aux.Stringid(TOKEN_GLITCHY_HELPER+3,5)


local FLAG_PREVENT_RESET = id+1

--Modify functions in order to make the game consider the Helper as a non-playable card
function Card.IsNonPlayableCard(c)
	return c:HasFlagEffect(TOKEN_GLITCHY_HELPER)
end

local _IsExistingMatchingCard, _IsExistingTarget, _GetMatchingGroup, _GetMatchingGroupCount, _SelectMatchingCard, _SelectTarget, _GetFieldGroup, _GetFieldGroupCount
=
Duel.IsExistingMatchingCard, Duel.IsExistingTarget, Duel.GetMatchingGroup, Duel.GetMatchingGroupCount, Duel.SelectMatchingCard, Duel.SelectTarget, Duel.GetFieldGroup, Duel.GetFieldGroupCount

Duel.IsExistingMatchingCard = function(f,pov,l1,l2,min,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=type(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _IsExistingMatchingCard(f,pov,l1,l2,min,g,...)
	else
		return _IsExistingMatchingCard(f,pov,l1,l2,min,exc,...)
	end
end
Duel.IsExistingTarget = function(f,pov,l1,l2,min,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=type(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _IsExistingTarget(f,pov,l1,l2,min,g,...)
	else
		return _IsExistingTarget(f,pov,l1,l2,min,exc,...)
	end
end
Duel.GetMatchingGroup = function(f,pov,l1,l2,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=type(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _GetMatchingGroup(f,pov,l1,l2,g,...)
	else
		return _GetMatchingGroup(f,pov,l1,l2,exc,...)
	end
end
Duel.GetMatchingGroupCount = function(f,pov,l1,l2,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=type(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _GetMatchingGroupCount(f,pov,l1,l2,g,...)
	else
		return _GetMatchingGroupCount(f,pov,l1,l2,exc,...)
	end
end
Duel.SelectMatchingCard = function(p,f,pov,l1,l2,min,max,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=type(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _SelectMatchingCard(p,f,pov,l1,l2,min,max,g,...)
	else
		return _SelectMatchingCard(p,f,pov,l1,l2,min,max,exc,...)
	end
end
Duel.SelectTarget = function(p,f,pov,l1,l2,min,max,exc,...)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		local typ=type(exc)
		if typ=="Card" then
			g:AddCard(exc)
		elseif typ=="Group" then
			g:Merge(exc)
		end
		
		return _SelectTarget(p,f,pov,l1,l2,min,max,g,...)
	else
		return _SelectTarget(p,f,pov,l1,l2,min,max,exc,...)
	end
end
Duel.GetFieldGroup = function(pov,l1,l2)
	local g0=_GetFieldGroup(pov,l1,l2)
	local g=_GetMatchingGroup(Card.IsNonPlayableCard,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if #g>0 then
		g0:Sub(g)
	end
	return g0
end
Duel.GetFieldGroupCount = function(pov,l1,l2)
	local ct0=_GetFieldGroupCount(pov,l1,l2)
	local ct=_GetMatchingGroupCount(Card.IsNonPlayableCard,pov,l1,l2,nil)
	return math.max(ct0-ct,0)
end

--Spawns the Helper at the start of the game
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	if not s.global_check then
		s.global_check=true
		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCountLimit(1,id|EFFECT_COUNT_CODE_DUEL)
		e1:SetOperation(help.SpawnGlitchyHelper(c,GLITCHY_HELPER_FLAGS_STANDARD))
		Duel.RegisterEffect(e1,0)
	end
end

help.GlitchyHelperIgnorePlayerTable={false,false}
function help.SpawnGlitchyHelper(c,flags)
	return	function(e,tp,eg,ep,ev,re,r,rp)
		local compensate_draw = {0,0}
		Duel.DisableShuffleCheck(true)
		for p=0,1 do
			local g=Duel.Group(Card.IsOriginalCode,p,LOCATION_HAND|LOCATION_DECK,0,nil,id)
			if #g>0 then
				compensate_draw[p+1]=g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
				Duel.SendtoDeck(g,nil,-2,REASON_RULE)
			end
			if Duel.GetDeckCount(p)+Duel.GetHandCount(p)<40 then
				Debug.Message('Player '..p..' has less than 40 cards in their Main Deck. The Duel cannot proceed.')
				Duel.Win(1-p,WIN_REASON_EXODIA)
				return
			end
		end
		for p=0,1 do
			local ct=compensate_draw[p+1]
			if ct>0 then
				Duel.Draw(p,ct,REASON_RULE)
				Duel.ShuffleHand(p)
			end
		end
		
		Duel.DisableShuffleCheck(false)
		
		if not help.GlitchyHelper then
			help.GlitchyHelper=Duel.CreateToken(0,TOKEN_GLITCHY_HELPER)
			Duel.Remove(help.GlitchyHelper,POS_FACEUP,REASON_RULE)
			help.GlitchyHelper:RegisterFlagEffect(TOKEN_GLITCHY_HELPER,0,0,1)
			
			local e4=Effect.CreateEffect(help.GlitchyHelper)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
			e4:SetCode(EFFECT_IMMUNE_EFFECT)
			e4:SetValue(function(ef,te)
				return te:GetOwner()~=ef:GetOwner()
			end)
			help.GlitchyHelper:RegisterEffect(e4)
			
			help.GlitchyHelperFlags=0
			
			local p=c:GetOwner()
			local res=Duel.SelectYesNo(p,STRING_EXCLUDE_AI)
			if not res then
				help.GlitchyHelperIgnorePlayerTable[2-p]=true
				Debug.Message("Player "..tp.." prevented the opponent from using the Helper for the rest of the Duel")
			end
			
			for p=0,1 do
				if help.GlitchyHelperIgnorePlayerTable[p+1]==false then
					help.ReadGlitchyHelperFlags(p,flags)
					local h1=Effect.CreateEffect(help.GlitchyHelper)
					h1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
					h1:SetCode(EVENT_FREE_CHAIN)
					h1:SetOperation(help.GlitchyHelperSelectEffect)
					Duel.RegisterEffect(h1,p)
				end
			end
		end
	end
end

help.HelperEffects={}
help.PreventHotPotato=false

function help.ReadGlitchyHelperFlags(p,flags)
	if flags&GLITCHY_HELPER_FLAG_MANUAL_MOVEMENT>0 and help.GlitchyHelperFlags&GLITCHY_HELPER_FLAG_MANUAL_MOVEMENT==0 then
		help.GlitchyHelperFlags = help.GlitchyHelperFlags|GLITCHY_HELPER_FLAG_MANUAL_MOVEMENT
		local h1=Effect.CreateEffect(help.GlitchyHelper)
		h1:SetDescription(STRING_MANUAL_MOVEMENT)
		h1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		h1:SetCode(EVENT_FREE_CHAIN)
		h1:SetOperation(help.GlitchyHelperManualMovement)
		--Duel.RegisterEffect(h1,p)
		if p==0 then table.insert(help.HelperEffects,h1) end
	end

	if flags&GLITCHY_HELPER_FLAG_NORMAL_SUMMON>0 and help.GlitchyHelperFlags&GLITCHY_HELPER_FLAG_NORMAL_SUMMON==0 then
		help.GlitchyHelperFlags = help.GlitchyHelperFlags|GLITCHY_HELPER_FLAG_NORMAL_SUMMON
		local h1=Effect.CreateEffect(help.GlitchyHelper)
		h1:SetDescription(STRING_NORMAL_SUMMON)
		h1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		h1:SetCode(EVENT_FREE_CHAIN)
		h1:SetOperation(help.GlitchyHelperNormalSummon)
		--Duel.RegisterEffect(h1,p)
		if p==0 then table.insert(help.HelperEffects,h1) end
	end

	if flags&GLITCHY_HELPER_FLAG_SPECIAL_SUMMON>0 and help.GlitchyHelperFlags&GLITCHY_HELPER_FLAG_SPECIAL_SUMMON==0 then
		help.GlitchyHelperFlags = help.GlitchyHelperFlags|GLITCHY_HELPER_FLAG_SPECIAL_SUMMON
		local h1=Effect.CreateEffect(help.GlitchyHelper)
		h1:SetDescription(STRING_SPECIAL_SUMMON)
		h1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		h1:SetCode(EVENT_FREE_CHAIN)
		h1:SetOperation(help.GlitchyHelperSpecialSummon)
		--Duel.RegisterEffect(h1,p)
		if p==0 then table.insert(help.HelperEffects,h1) end
	end
	
	if flags&GLITCHY_HELPER_FLAG_PENDULUM_SUMMON>0 and help.GlitchyHelperFlags&GLITCHY_HELPER_FLAG_PENDULUM_SUMMON==0 then
		help.GlitchyHelperFlags = help.GlitchyHelperFlags|GLITCHY_HELPER_FLAG_PENDULUM_SUMMON
		local h1=Effect.CreateEffect(help.GlitchyHelper)
		h1:SetDescription(STRING_PENDULUM_SUMMON)
		h1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		h1:SetCode(EVENT_FREE_CHAIN)
		h1:SetCondition(function(e,tp) return Duel.IsPlayerCanPendulumSummon(tp) end)
		h1:SetOperation(help.GlitchyHelperPendulumSummon)
		--Duel.RegisterEffect(h1,p)
		if p==0 then table.insert(help.HelperEffects,h1) end
	end
	
	if flags&GLITCHY_HELPER_FLAG_POSITION>0 and help.GlitchyHelperFlags&GLITCHY_HELPER_FLAG_POSITION==0 then
		help.GlitchyHelperFlags = help.GlitchyHelperFlags|GLITCHY_HELPER_FLAG_POSITION
		local h1=Effect.CreateEffect(help.GlitchyHelper)
		h1:SetDescription(STRING_CHANGE_POSITION)
		h1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		h1:SetCode(EVENT_FREE_CHAIN)
		h1:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>0 end)
		h1:SetOperation(help.GlitchyHelperPosition)
		--Duel.RegisterEffect(h1,p)
		if p==0 then table.insert(help.HelperEffects,h1) end
	end
	
	if flags&GLITCHY_HELPER_FLAG_EQUIP>0 and help.GlitchyHelperFlags&GLITCHY_HELPER_FLAG_EQUIP==0 then
		help.GlitchyHelperFlags = help.GlitchyHelperFlags|GLITCHY_HELPER_FLAG_EQUIP
		local h1=Effect.CreateEffect(help.GlitchyHelper)
		h1:SetDescription(STRING_GLITCHY_HELPER_EQUIP)
		h1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		h1:SetCode(EVENT_FREE_CHAIN)
		h1:SetCondition(function(e,tp) return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExists(false,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end)
		h1:SetOperation(help.GlitchyHelperEquip)
		--Duel.RegisterEffect(h1,p)
		if p==0 then table.insert(help.HelperEffects,h1) end
	end
	
	if flags&GLITCHY_HELPER_FLAG_LP>0 and help.GlitchyHelperFlags&GLITCHY_HELPER_FLAG_LP==0 then
		help.GlitchyHelperFlags = help.GlitchyHelperFlags|GLITCHY_HELPER_FLAG_LP
		local h1=Effect.CreateEffect(help.GlitchyHelper)
		h1:SetDescription(STRING_GLITCHY_HELPER_LP)
		h1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		h1:SetCode(EVENT_FREE_CHAIN)
		h1:SetOperation(help.GlitchyHelperLP)
		if p==0 then table.insert(help.HelperEffects,h1) end
	end
	
	if flags&GLITCHY_HELPER_FLAG_DRAWORDISCARD>0 and help.GlitchyHelperFlags&GLITCHY_HELPER_FLAG_DRAWORDISCARD==0 then
		help.GlitchyHelperFlags = help.GlitchyHelperFlags|GLITCHY_HELPER_FLAG_DRAWORDISCARD
		local h1=Effect.CreateEffect(help.GlitchyHelper)
		h1:SetDescription(STRING_GLITCHY_HELPER_DRAWORDISCARD)
		h1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		h1:SetCode(EVENT_FREE_CHAIN)
		h1:SetCondition(function(e,tp) return Duel.IsPlayerCanDraw(tp,1) or Duel.GetHand(tp):IsExists(Card.IsDiscardable,1,nil,REASON_RULE) end)
		h1:SetOperation(help.GlitchyHelperDrawOrDiscard)
		if p==0 then table.insert(help.HelperEffects,h1) end
	end
	
	if flags&GLITCHY_HELPER_FLAG_GAMBLE>0 and help.GlitchyHelperFlags&GLITCHY_HELPER_FLAG_GAMBLE==0 then
		help.GlitchyHelperFlags = help.GlitchyHelperFlags|GLITCHY_HELPER_FLAG_GAMBLE
		local h1=Effect.CreateEffect(help.GlitchyHelper)
		h1:SetDescription(STRING_GAMBLE)
		h1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		h1:SetCode(EVENT_FREE_CHAIN)
		h1:SetOperation(help.GlitchyHelperGamble)
		if p==0 then table.insert(help.HelperEffects,h1) end
	end
	
	if flags&GLITCHY_HELPER_FLAG_COUNTER>0 and help.GlitchyHelperFlags&GLITCHY_HELPER_FLAG_COUNTER==0 then
		help.GlitchyHelperFlags = help.GlitchyHelperFlags|GLITCHY_HELPER_FLAG_COUNTER
		local h1=Effect.CreateEffect(help.GlitchyHelper)
		h1:SetDescription(STRING_PLACE_COUNTER)
		h1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		h1:SetCode(EVENT_FREE_CHAIN)
		h1:SetCondition(function(e,tp) return Duel.IsExists(false,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,nil) end)
		h1:SetOperation(help.GlitchyHelperCounter)
		if p==0 then table.insert(help.HelperEffects,h1) end
	end
	
	if help.GlitchyHelperIgnorePlayerTable[2-p]==false and flags&GLITCHY_HELPER_FLAG_CONCEDE_CONTROL>0 and help.GlitchyHelperFlags&GLITCHY_HELPER_FLAG_CONCEDE_CONTROL==0 then
		help.GlitchyHelperFlags = help.GlitchyHelperFlags|GLITCHY_HELPER_FLAG_CONCEDE_CONTROL
		local h1=Effect.CreateEffect(help.GlitchyHelper)
		h1:SetDescription(STRING_CONCEDE_CONTROL)
		h1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		h1:SetCode(EVENT_FREE_CHAIN)
		h1:SetCondition(function() return not help.PreventHotPotato end)
		h1:SetOperation(help.GlitchyHelperConcedeControl)
		if p==0 then table.insert(help.HelperEffects,h1) end
	end
end
function help.GlitchyHelperSelectEffect(e,tp)
	local eset={}
	local descs={}
	for _,ce in ipairs(help.HelperEffects) do
		local cond=ce:GetCondition()
		if not cond or cond(ce,tp) then
			table.insert(eset,ce)
			table.insert(descs,ce:GetDescription())
		end
	end
	
	local opt=Duel.SelectOption(tp,STRING_STOP,table.unpack(descs))
	if opt~=0 then
		local ce=eset[opt]
		ce:GetOperation()(ce,tp)
	end
end

--
function help.AskOpponentPermission(e,tp)
	return true
	-- if Duel.SelectYesNo(1-tp,STRING_ASK_FOR_OPPONENT_PERMISSION) then
		-- Debug.Message("The opponent allowed the use of the Helper")
		-- return true
	-- else
		-- Debug.Message("The opponent denied the use of the Helper")
		-- return false
	-- end
end
function help.GlitchyHelperManualMovement(e,tp)
	Debug.Message("Player "..tp.. " is trying to use the Helper. Reason flag: MANUAL_MOVEMENT")
	if not help.AskOpponentPermission(e,tp) then return end
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetOwner()
	
	local locations=LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_EXTRA
	local og=Duel.GetFieldGroup(tp,locations,0)+Duel.GetXyzMaterialGroup(tp,1,0)
	local dg=Duel.GetDeck(tp)
	local dct=#dg
	
	local nodeckcon=#og>0
	local deckcon=dct>0
	
	local askLocations=aux.Option(tp,nil,nil,
		{nodeckcon,STRING_IGNORE_DECK},
		{deckcon,STRING_INCLUDE_DECK},
		{deckcon,STRING_TOPDECK_ONLY}
	)
	
	local mustShuffleDeck=false
	if askLocations==1 then
		og=og+dg
		mustShuffleDeck=true
	end
	
	local g
	if askLocations~=2 then
		Duel.HintMessage(tp,STRING_SELECT_CARDS_TO_MOVE)
		g=og:Select(tp,1,99,nil)
		Duel.ConfirmCards(1-tp,g:Filter(function(_c) return not _c:IsOnField() and not _c:IsLocation(LOCATION_OVERLAY) end,nil))
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
			mustShuffleDeck=false
		end
		if g:IsExists(aux.NOT(Card.IsLocation),1,nil,LOCATION_DECK|LOCATION_EXTRA) or g:GetClassCount(Card.GetLocation)>1 then
			Duel.HintMessage(1-tp,STRING_CONFIRM_SELECTION)
			g:Select(1-tp,0,99,nil)
		end
	else
		Duel.HintMessage(tp,STRING_SELECT_TOPDECK)
		local n=Duel.AnnounceNumberRange(tp,1,dct)
		g=Duel.GetDecktopGroup(tp,n)
		Duel.DisableShuffleCheck()
	end
	
	if #g>0 then
		local option=Duel.SelectOption(tp,STRING_REVEAL_ONLY,STRING_SELF_DESTINATION,STRING_OPPO_DESTINATION)
		
		if option==0 then
			if askLocations==2 then
				Duel.ConfirmDecktop(tp,#g)
				Duel.ConfirmCards(1-tp,g)
			end
		else
			local targetp=option==1 and tp or 1-tp
			
			local xyzg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_XYZ)
			local xyzct=#xyzg
			
			local pzct=0
			for i=0,1 do
				if Duel.CheckLocation(targetp,LOCATION_PZONE,i) then
					pzct=pzct+1
				end
			end
			
			local opt=aux.Option(tp,nil,nil,
				{true,STRING_DECKTOP},
				{true,STRING_DECKBOTTOM},
				{g:IsExists(aux.NOT(aux.PLChk),1,nil,targetp,LOCATION_HAND),1001},
				{Duel.GetMZoneCount(targetp,nil,tp)>=#g,1002},
				{Duel.GetLocationCount(targetp,LOCATION_SZONE,tp)>=#g,1003},
				{g:IsExists(aux.NOT(aux.PLChk),1,nil,targetp,LOCATION_GRAVE),1004},
				{g:IsExists(aux.NOT(aux.PLChk),1,nil,targetp,LOCATION_REMOVED),STRING_BANISHMENT},
				{g:IsExists(aux.NOT(aux.PLChk),1,nil,targetp,LOCATION_EXTRA) and not g:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_EXTRA|TYPE_PENDULUM),1006},
				{xyzct>0 and not (g:FilterCount(Card.IsContained,nil,xyzg)==#xyzg) and (g:IsExists(aux.NOT(aux.PLChk),1,nil,targetp,LOCATION_OVERLAY) or xyzct>1),1007},
				{#g==1 and g:GetFirst():IsType(TYPE_FIELD) and not aux.PLChk(g:GetFirst(),targetp,LOCATION_FZONE),1008},
				{#g<=2 and pzct>=#g and g:IsExists(aux.NOT(aux.PLChk),1,nil,targetp,LOCATION_PZONE) and not g:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_PENDULUM),1009}
			)
			
			local hasXyzMats=g:Filter(Card.HasCardAttached,nil)
			if #hasXyzMats>0 and opt~=8 then
				local mats=hasXyzMats:GetXyzMaterialGroup()
				Duel.SendtoGrave(mats,REASON_RULE)
			end
			
			if opt==0 then
				--Top of Deck
				local g1,g2=g:Split(aux.PLChk,nil,targetp,LOCATION_DECK)
				if #g1>0 then
					Duel.MoveToDeckTop(g1)
				end
				if #g2>0 then
					Duel.SendtoDeck(g,targetp,SEQ_DECKTOP,REASON_RULE)
				end
				local opt2=aux.Option(targetp,nil,nil,{true,STRING_DO_NOTHING},{#g>1,STRING_REARRANGE},{true,STRING_SHUFFLE_DECK})
				if opt2==0 then
					Debug.Message("Player "..tp.." placed "..#g.." card(s) on top of Player "..targetp.."'s Deck")
				elseif opt2==1 then
					Duel.SortDecktop(targetp,targetp,g:FilterCount(aux.PLChk,nil,targetp,LOCATION_DECK))
					Debug.Message("Player "..tp.." placed "..#g.." card(s) on top of Player "..targetp.."'s Deck and the latter changed their order")
				elseif opt2==2 then
					Duel.ShuffleDeck(targetp)
					Debug.Message("Player "..tp.." placed "..#g.." card(s) on top of Player "..targetp.."'s Deck and the latter shuffled their Deck")
				end
				if tp==targetp then mustShuffleDeck=false end
			
			elseif opt==1 then
				--Bottom of Deck
				local g1,g2=g:Split(aux.PLChk,nil,targetp,LOCATION_DECK)
				if #g1>0 then
					Duel.MoveToDeckBottom(g1)
				end
				if #g2>0 then
					Duel.SendtoDeck(g,targetp,SEQ_DECKBOTTOM,REASON_RULE)
				end
				local opt2=aux.Option(targetp,nil,nil,{true,STRING_DO_NOTHING},{#g>1,STRING_REARRANGE})
				if opt2==0 then
					Debug.Message("Player "..tp.." placed "..#g.." card(s) on top of Player "..targetp.."'s Deck")
				elseif opt2==1 then
					Duel.SortDeckbottom(targetp,targetp,g:FilterCount(aux.PLChk,nil,targetp,LOCATION_DECK))
					Debug.Message("Player "..tp.." placed "..#g.." card(s) on the bottom of Player "..targetp.."'s Deck and the latter changed their order")
				end
				if tp==targetp then mustShuffleDeck=false end
			
			elseif opt==2 then
				--Hand
				local tg=g:Filter(aux.NOT(aux.PLChk),nil,targetp,LOCATION_HAND)
				if #tg>0 then
					Duel.SendtoHand(tg,targetp,REASON_RULE)
				end
				Debug.Message("Player "..tp.." added "..#g.." card(s) to Player "..targetp.."'s hand")
			
			elseif opt==3 then
				--Monster Zone
				for tc in g:Iter() do
					if not tc:IsLocation(LOCATION_MZONE) then
						Duel.MoveToField(tc,tp,targetp,LOCATION_MZONE,Duel.SelectPosition(tp,tc,POS_ATTACK|POS_DEFENSE),true)
						if tp~=targetp then
							tc:RegisterFlagEffect(FLAG_PREVENT_RESET,RESET_EVENT|RESETS_STANDARD_FACEDOWN,0,1)
							local e1=Effect.CreateEffect(c)
							e1:SetType(EFFECT_TYPE_FIELD)
							e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_IGNORE_IMMUNE)
							e1:SetCode(EFFECT_SET_CONTROL)
							e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
							e1:SetCondition(help.ResetCondition(tc))
							e1:SetTarget(function(_e,_c) return _c==tc end)
							e1:SetValue(function(_e,_c) return targetp end)
							Duel.RegisterEffect(e1,tp)
						end
					else
						if tp==targetp then
							Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0),2))
						else
							Duel.GetControl(tc,targetp,0,0,0xff,tp)
						end
					end
				end
				Debug.Message("Player "..tp.." placed "..#g.." card(s) into Player "..targetp.."'s Main Monster Zones")
			
			elseif opt==4 then
				--Spell & Trap Zone
				for tc in g:Iter() do
					if not tc:IsLocation(LOCATION_SZONE) or targetp~=tp then
						Duel.MoveToField(tc,tp,targetp,LOCATION_SZONE,Duel.SelectPosition(tp,tc,POS_ATTACK),true)
					else
						Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,LOCATION_SZONE,0,0)>>8,2))
					end
				end
				Debug.Message("Player "..tp.." placed "..#g.." card(s) into Player "..targetp.."'s Spell & Trap Zones")
			
			elseif opt==5 then
				--GY
				local tg=g:Filter(aux.NOT(aux.PLChk),nil,targetp,LOCATION_GRAVE)
				if #tg>0 then
					Duel.SendtoGrave(tg,REASON_RULE,targetp)
				end
				Debug.Message("Player "..tp.." sent "..#tg.." card(s) to Player "..targetp.."'s GY")
			
			elseif opt==6 then
				--Banishment
				local tg=g:Filter(aux.NOT(aux.PLChk),nil,targetp,LOCATION_REMOVED)
				if #tg==1 then
					Duel.Remove(tg,Duel.SelectPosition(tp,tg:GetFirst(),POS_ATTACK),REASON_RULE,targetp)
				elseif #tg>1 then
					local opt2=Duel.SelectOption(tp,STRING_ALL_FACEUP,STRING_ALL_FACEDOWN,STRING_CHOOSE_FOR_EACH_CARD)
					if opt2==2 then
						local upct,downct=0,0
						for tc in tg:Iter() do
							local pos=Duel.SelectPosition(tp,tc,POS_ATTACK)
							if pos&POS_FACEUP>0 then
								upct=upct+1
							else
								downct=downct+1
							end
							Duel.Remove(tc,pos,REASON_RULE,targetp)
						end
						Debug.Message("Player "..tp.." sent "..#tg.." card(s) to Player "..targetp.."'s banishment (Face-up: "..upct..", Face-down: "..downct..")")
					else
						local pos=opt2==0 and POS_FACEUP or POS_FACEDOWN
						local posString=opt2==0 and "face-up" or "face-down"
						Duel.Remove(tg,pos,REASON_RULE,targetp)
						Debug.Message("Player "..tp.." sent "..#tg.." card(s) to Player "..targetp.."'s banishment, in "..posString.." position")
					end
				end
			
			elseif opt==7 then
				--Extra Deck
				local tg=g:Filter(aux.NOT(aux.PLChk),nil,targetp,LOCATION_EXTRA)
				local pends,notpends=tg:Split(Card.IsType,nil,TYPE_PENDULUM)
				local faceup=Group.CreateGroup()
				if #pends>0 then
					local edpends=pends:Filter(Card.IsType,nil,TYPE_EXTRA)
					for tc in edpends:Iter() do
						local pos=Duel.SelectPosition(tp,tc,POS_ATTACK)
						if pos&POS_FACEUP==0 then
							notpends:AddCard(tc)
						end
					end
					pends:Sub(notpends)
				end
				if #notpends>0 then
					Duel.SendtoDeck(notpends,targetp,SEQ_DECKSHUFFLE,REASON_RULE)
					Debug.Message("Player "..tp.." sent "..#notpends.." card(s) into Player "..targetp.."'s Extra Deck")
				end
				if #pends>0 then
					Duel.SendtoExtraP(pends,targetp,REASON_RULE)
					Debug.Message("Player "..tp.." placed "..#pends.." Pendulum Card(s) into Player "..targetp.."'s Extra Deck, face-up")
				end
			
			elseif opt==8 then
				--Xyz Material
				local xyz=Duel.Select(HINTMSG_ATTACHTO,false,tp,Card.IsType,targetp,LOCATION_MZONE,0,1,1,nil,TYPE_XYZ):GetFirst()
				local tg=g:Filter(aux.NOT(Card.IsAttachedTo),nil,xyz)
				for tc in tg:Iter() do
					local transfer=false
					if tc:GetOverlayCount()>0 then
						Duel.HintSelection(tc)
						transfer=Duel.SelectYesNo(tp,STRING_TRANSFER_MATERIALS)
					end
					Duel.Attach(tc,xyz,transfer)
				end
				Debug.Message("Player "..tp.." attached "..#tg.." card(s) tp Player "..targetp.."'s Xyz Monster ("..xyz:GetOriginalCode()..")")
			
			elseif opt==9 then
				--Field Zone
				local tc=g:GetFirst()
				local fc=Duel.GetFieldCard(targetp,LOCATION_FZONE,0)
				if fc then
					Duel.SendtoGrave(fc,REASON_RULE)
					Duel.BreakEffect()
				end
				Duel.MoveToField(tc,tp,targetp,LOCATION_FZONE,POS_FACEUP,true)
				Debug.Message("Player "..tp.." placed a card into Player "..targetp.."'s Field Zone")
			
			elseif opt==10 then
				--Pendulum Zones
				local tg=g:Filter(aux.NOT(aux.PLChk),nil,targetp,LOCATION_PZONE)
				for tc in tg:Iter() do
					Duel.MoveToField(tc,tp,targetp,LOCATION_PZONE,POS_FACEUP,true)
				end
				Debug.Message("Player "..tp.." placed "..#tg.." Pendulum Card(s) into Player "..targetp.."'s Pendulum Zones")
				
			end
		end
	
	end
	
	if mustShuffleDeck then
		Duel.ShuffleDeck(tp)
	end
	
	if not Duel.SelectYesNo(tp,STRING_ALLOW_RESPONSE) then
		Debug.Message("Player "..tp.." prevented effects from responding to this action")
		Duel.SetChainLimit(aux.FALSE)
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	end
	
	Debug.Message("END OF OPERATION")
end

function help.GlitchyHelperNormalSummon(e,tp)
	Debug.Message("Player "..tp.. " is trying to use the Helper. Reason flag: NORMAL_SUMMON")
	if not help.AskOpponentPermission(e,tp) then return end
	
	local g=Duel.Group(help.NSFilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	if #g==0 then
		Debug.Message("ERROR 01: There are no monsters that can be Normal Summoned/Set")
		Debug.Message("END OF OPERATION")
		return
	end
	
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetOwner()
	Duel.HintMessage(tp,HINTMSG_SUMMON)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc then
		local code=tc:GetOriginalCode()
		local min,max=tc:GetTributeRequirement()
		local nscon0=tc:IsSummonable(true,nil) or tc:IsMSetable(true,nil)
		
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetCondition(help.NSWithoutTributingCondition)
		tc:RegisterEffect(e1)
		local nscon1=tc:IsSummonable(true,e1) or tc:IsMSetable(true,e1)
		e1:Reset()
		
		local validTributes={}
		for i=1,6 do
			local e1=Effect.CreateEffect(help.GlitchyHelper)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_SUMMON_PROC)
			e1:SetCondition(aux.NormalSummonCondition1(i,i,nil,false))
			tc:RegisterEffect(e1)
			if tc:IsSummonable(true,e1) or tc:IsMSetable(true,e1) then
				table.insert(validTributes,i)
			end
			e1:Reset()
		end
		
		local opt=aux.Option(tp,nil,nil,
			{nscon0,STRING_REGULAR_SUMMON},
			{nscon1,STRING_NO_TRIBUTING},
			{#validTributes>0,STRING_MODIFIED_TRIBUTING}
		)
		if opt==0 then
			Duel.SummonOrSet(tp,tc,true,nil)
			Debug.Message("Player "..tp.." Normal Summoned/Set a monster ("..code..")")
		elseif opt==1 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_SUMMON_PROC)
			e1:SetCondition(help.NSWithoutTributingCondition)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
			Duel.SummonOrSet(tp,tc,true,e1)
			Debug.Message("Player "..tp.." Normal Summoned/Set a monster ("..code..") without Tributing")
		elseif opt==2 then
			local n=Duel.AnnounceNumber(tp,table.unpack(validTributes))
			local e1=Effect.CreateEffect(help.GlitchyHelper)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_SUMMON_PROC)
			e1:SetCondition(aux.NormalSummonCondition1(n,n,nil,false))
			e1:SetTarget(aux.NormalSummonTarget(n,n,nil))
			e1:SetOperation(aux.NormalSummonOperation(n,n,nil))
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
			Duel.SummonOrSet(tp,tc,true,e1)
			Debug.Message("Player "..tp.." Normal Summoned/Set a monster ("..code..") with a custom amount of Tributes")
		end
		
	end
	
	Duel.SetChainLimit(aux.FALSE)
	Duel.SetChainLimitTillChainEnd(aux.FALSE)
	Debug.Message("END OF OPERATION")
end
function help.NSFilter(c)
	if not c:IsFaceupEx() then return false end
	if c:IsSummonable(true,nil) or c:IsMSetable(true,nil) then
		return true
	elseif not c:IsLocation(LOCATION_HAND) then
		return false
	end
	
	local e1=Effect.CreateEffect(help.GlitchyHelper)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(help.NSWithoutTributingCondition)
	c:RegisterEffect(e1)
	local res=c:IsSummonable(true,e1) or c:IsMSetable(true,e1)
	e1:Reset()
	if res then return true end
	
	for i=1,6 do
		local e1=Effect.CreateEffect(help.GlitchyHelper)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetCondition(aux.NormalSummonCondition1(i,i,nil,false))
		c:RegisterEffect(e1)
		local res=c:IsSummonable(true,e1) or c:IsMSetable(true,e1)
		e1:Reset()
		if res then return true end
	end
	return false
end
function help.NSWithoutTributingCondition(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:GetLevel()>4 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end

--SPECIAL SUMMON
function help.GlitchyHelperSpecialSummon(e,tp)
	Debug.Message("Player "..tp.. " is trying to use the Helper. Reason flag: SPECIAL_SUMMON")
	if not help.AskOpponentPermission(e,tp) then return end
	
	local opt0=Duel.SelectOption(tp,STRING_SPSUMMON_MONSTER,STRING_SPSUMMON_TOKEN)
	
	if opt0==0 then
		local locations=LOCATION_SZONE|LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_EXTRA
		local og=Duel.GetFieldGroup(tp,locations,0)+Duel.GetXyzMaterialGroup(tp,1,0)
		og:Match(help.SSFilter,nil,e,tp)
		
		local askLocations=#og==0 and 1 or Duel.SelectOption(tp,STRING_IGNORE_DECK,STRING_INCLUDE_DECK)
		local mustShuffleDeck=false
		if askLocations==1 then
			locations=locations|LOCATION_DECK
			og=Duel.GetFieldGroup(tp,locations,0)+Duel.GetXyzMaterialGroup(tp,1,0)
			og:Match(help.SSFilter,nil,e,tp)
			mustShuffleDeck=true
		end
		
		if #og==0 then
			Debug.Message("ERROR 02: There are no monsters that can be Special Summoned")
			Debug.Message("END OF OPERATION")
			return
		end
		
		Duel.Hint(HINT_CARD,0,id)
		local c=e:GetOwner()
		
		local keepSummoning=true
		local isProcedureSummon=false
		local completeProcGroup=Group.CreateGroup()
		local code=0
		
		while keepSummoning do
			Duel.HintMessage(tp,HINTMSG_SPSUMMON)
			local tc=og:Select(tp,1,1,nil):GetFirst()
			
			if tc then
				if mustShuffleDeck and tc:IsLocation(LOCATION_DECK) then
					mustShuffleDeck=false
				end
				
				code=tc:GetOriginalCode()
				
				local sumtype=tc:IsOriginalType(TYPE_EXTRA|TYPE_RITUAL) and tc:GetMechanicSummonType() or 0
				local spcon0=Duel.GetMZoneCountFromLocation(tp,tp,nil,tc)>0 and (tc:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEUP|POS_FACEDOWN_DEFENSE,tp)
					or (sumtype~=0 and tc:IsCanBeSpecialSummoned(e,sumtype,tp,true,true,POS_FACEUP|POS_FACEDOWN_DEFENSE,tp)
					and aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,tc,nil,help.GetMechanicReason(tc)):GetCount()<=0))
				local spcon1=Duel.GetMZoneCountFromLocation(1-tp,tp,nil,tc)>0 and (tc:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEUP|POS_FACEDOWN_DEFENSE,1-tp)
					or (sumtype~=0 and tc:IsCanBeSpecialSummoned(e,sumtype,tp,true,true,POS_FACEUP|POS_FACEDOWN_DEFENSE,1-tp)
					and aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,tc,nil,help.GetMechanicReason(tc)):GetCount()<=0))
				local spcon2=tc:IsSpecialSummonable() or tc:IsSpecialSummonable(1) or (sumtype~=0 and c:IsSpecialSummonable(sumtype))
				
				local opt=aux.Option(tp,nil,nil,
					{spcon0,STRING_REGULAR_SPSUMMON},
					{spcon1,STRING_SPSUMMON_TO_OPPO},
					{spcon2,STRING_SPSUMMON_PROC}
				)
				
				if opt==0 or opt==1 then
					local p=opt==0 and tp or 1-tp
					local positions,sumtype_positions=0,0
					for _,pos in ipairs{POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE} do
						if tc:IsCanBeSpecialSummoned(e,0,tp,true,true,pos,p) then
							positions=positions|pos
						end
						if sumtype~=0 and tc:IsCanBeSpecialSummoned(e,sumtype,tp,true,true,pos,p) then
							sumtype_positions=sumtype_positions|pos
						end
					end
					
					local summonType=0
					if positions~=0 and sumtype_positions~=0 then
						if Duel.SelectYesNo(tp,STRING_TREAT_AS_SPSUMMON) then
							summonType=sumtype
							positions=sumtype_positions
							completeProcGroup:AddCard(tc)
						end
					elseif sumtype_positions~=0 then
						summonType=sumtype
						positions=sumtype_positions
						completeProcGroup:AddCard(tc)
					end
					Duel.SpecialSummonStep(tc,summonType,tp,p,true,true,positions)
					
				elseif opt==2 then
					Duel.SpecialSummonRule(tp,tc)
					isProcedureSummon=true
				end
			end
			
			if isProcedureSummon or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or not Duel.SelectYesNo(tp,STRING_KEEP_SPSUMMONING) then
				keepSummoning=false
			else
				og=Duel.GetFieldGroup(tp,locations,0)+Duel.GetXyzMaterialGroup(tp,1,0)
				og:Match(help.SSFilter,nil,e,tp)
				if #og==0 then
					keepSummoning=false
				end
			end
		end
		
		if not isProcedureSummon then
			local n=Duel.SpecialSummonComplete()
			for tc in completeProcGroup:Iter() do
				tc:CompleteProcedure()
			end
			Debug.Message("Player "..tp.." Special Summoned "..n.." monsters")
		else
			Debug.Message("Player "..tp.." Special Summoned a monster ("..code..") using its procedure")
		end
		
		if mustShuffleDeck then
			Duel.ShuffleDeck(tp)
		end
		
		if isProcedureSummon or not Duel.SelectYesNo(tp,STRING_ALLOW_RESPONSE) then
			Debug.Message("Player "..tp.." prevented effects from responding to this action")
			Duel.SetChainLimit(aux.FALSE)
			Duel.SetChainLimitTillChainEnd(aux.FALSE)
		end
	
	else
		local announceFilter={TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_ALLOW_TOKENS}
		for p=tp,1-tp,1-2*tp do
			if p==tp or Duel.SelectYesNo(tp,STRING_ASK_OPPO_TOKEN) then
				local ft=Duel.GetMZoneCount(p,nil,tp)
				if ft>0 then
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
					if ft>1 then
						Duel.HintMessage(tp,STRING_HOW_MANY_TOKENS)
						ft=Duel.AnnounceNumberRange(tp,1,ft)
					end
					for i=1,ft do
						local code=Duel.AnnounceCard(tp,table.unpack(announceFilter))
						local token=Duel.CreateToken(tp,code)
						Duel.SpecialSummonStep(token,0,tp,p,true,true,POS_FACEUP)
					end
				end
			end
		end
		local n=Duel.SpecialSummonComplete()
		Debug.Message("Player "..tp.." Special Summoned "..n.." Tokens")
		
		if not Duel.SelectYesNo(tp,STRING_ALLOW_RESPONSE) then
			Debug.Message("Player "..tp.." prevented effects from responding to this action")
			Duel.SetChainLimit(aux.FALSE)
			Duel.SetChainLimitTillChainEnd(aux.FALSE)
		end
		
	end
	Debug.Message("END OF OPERATION")
end
function help.SSFilter(c,e,tp)
	local sumtype=c:IsOriginalType(TYPE_EXTRA|TYPE_RITUAL) and c:GetMechanicSummonType() or 0
	for p=0,1 do
		if Duel.GetMZoneCountFromLocation(p,tp,nil,c)>0
			and (c:IsCanBeSpecialSummoned(e,0,tp,true,true,POS_FACEUP|POS_FACEDOWN_DEFENSE,p)
			or (sumtype~=0 and c:IsCanBeSpecialSummoned(e,sumtype,tp,true,true,POS_FACEUP|POS_FACEDOWN_DEFENSE,p)
			and aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,c,nil,help.GetMechanicReason(c)):GetCount()<=0)) then
			return true
		end
	end
	
	return c:IsSpecialSummonable() or c:IsSpecialSummonable(1) or (sumtype~=0 and c:IsSpecialSummonable(sumtype))
end
function help.GetMechanicReason(c)
	local ctypes={
		[TYPE_FUSION]=REASON_FUSION;
		[TYPE_RITUAL]=REASON_RITUAL;
		[TYPE_SYNCHRO]=REASON_SYNCHRO;
		[TYPE_XYZ]=REASON_XYZ;
		[TYPE_LINK]=REASON_LINK;
	}
	for typ,r in pairs(ctypes) do
		if c:IsType(typ) then
			return r
		end
	end
	return 0
end

--PENDULUM SUMMON
function help.GlitchyHelperPendulumSummon(e,tp)
	Debug.Message("Player "..tp.. " is trying to use the Helper. Reason flag: PENDULUM_SUMMON")
	if not help.AskOpponentPermission(e,tp) then return end
	
	Duel.PendulumSummon(tp)
	
	Debug.Message("Player "..tp.." performed a Pendulum Summon")
	Debug.Message("END OF OPERATION")
end

--POSITION
function help.GlitchyHelperPosition(e,tp)
	Debug.Message("Player "..tp.. " is trying to use the Helper. Reason flag: CHANGE_POSITION")
	if not help.AskOpponentPermission(e,tp) then return end
	
	local g=Duel.Select(HINTMSG_POSITION,false,tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,99,nil)
	for tc in aux.Next(g) do
		local pos=(POS_FACEUP|POS_FACEDOWN_DEFENSE)&~tc:GetPosition()
		if not tc:IsLocation(LOCATION_MZONE) or tc:IsType(TYPE_LINK) then
			pos=pos&~POS_DEFENSE
		end
		Duel.ChangePosition(tc,Duel.SelectPosition(tp,tc,pos))
	end
	
	Debug.Message("Player "..tp.." changed the position of "..#g.." cards on their field")
	if not Duel.SelectYesNo(tp,STRING_ALLOW_RESPONSE) then
		Debug.Message("Player "..tp.." prevented effects from responding to this action")
		Duel.SetChainLimit(aux.FALSE)
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	end
	Debug.Message("END OF OPERATION")
end

--EQUIP
function help.GlitchyHelperEquip(e,tp)
	Debug.Message("Player "..tp.. " is trying to use the Helper. Reason flag: EQUIP")
	if not help.AskOpponentPermission(e,tp) then return end
	
	local c=e:GetOwner()
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local og=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=0
	local tcp=PLAYER_NONE
	
	Duel.HintMessage(tp,HINTMSG_EQUIPTO)
	local tc=og:Select(tp,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(tc)
		tcp=tc:GetControler()
		
		local locations=LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_EXTRA
		local og=Duel.GetFieldGroup(tp,locations,0)+Duel.GetXyzMaterialGroup(tp,1,0)
		og:RemoveCard(tc)
		local dg=Duel.GetDeck(tp)
		local dct=#dg
		
		local nodeckcon=#og>0
		local deckcon=dct>0
		
		local askLocations=aux.Option(tp,nil,nil,
			{nodeckcon,STRING_IGNORE_DECK},
			{deckcon,STRING_INCLUDE_DECK},
			{deckcon,STRING_TOPDECK_ONLY}
		)
		
		local mustShuffleDeck=false
		if askLocations==1 then
			og=og+dg
			mustShuffleDeck=true
		end
		
		if #og==0 then
			Debug.Message("ERROR 04: There exist no valid equip targets in any of your locations for the chosen monster")
			Debug.Message("END OF OPERATION")
			return
		end
		
		local eqg
		if askLocations~=2 then
			Duel.HintMessage(tp,HINTMSG_EQUIP)
			eqg=og:Select(tp,1,ft,nil)
			if eqg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
				mustShuffleDeck=false
			end
		else
			Duel.HintMessage(tp,STRING_SELECT_TOPDECK)
			local n=Duel.AnnounceNumberRange(tp,1,math.min(dct,ft))
			eqg=Duel.GetDecktopGroup(tp,n)
			Duel.DisableShuffleCheck()
		end

		for eqc in eqg:Iter() do
			local pos=help.EquipCardFilter(eqc,tc,tp)
			if pos and not eqc:IsFaceup() then
				pos=Duel.SelectPosition(tp,eqc,POS_FACEUP_ATTACK|POS_FACEDOWN_ATTACK)==POS_FACEUP_ATTACK
			end
			if Duel.Equip(tp,eqc,tc,pos,true) then
				ct=ct+1
				if pos and eqc:IsType(TYPE_UNION) and eqc:CheckUnionTarget(tc) and aux.CheckUnionEquip(eqc,tc) and Duel.SelectYesNo(tp,STRING_ASK_UNION_STATE) then
					aux.SetUnionState(eqc)
				elseif not eqc:IsOriginalType(TYPE_EQUIP) or not pos then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_EQUIP_LIMIT)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetValue(function(e,c)
						return c==tc
					end)
					e1:SetReset(RESET_EVENT|RESETS_STANDARD)
					eqc:RegisterEffect(e1)
				end
			end
		end
		
		if mustShuffleDeck then
			Duel.ShuffleDeck(tp)
		end
	end
	
	Duel.EquipComplete()
	Debug.Message("Player "..tp.." equipped "..ct.." cards to a monster controlled by Player "..tcp.." ("..tc:GetOriginalCode()..")")
	if not Duel.SelectYesNo(tp,STRING_ALLOW_RESPONSE) then
		Debug.Message("Player "..tp.." prevented effects from responding to this action")
		Duel.SetChainLimit(aux.FALSE)
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	end
	Debug.Message("END OF OPERATION")
end
function help.EquipCardFilter(c,eqc,tp)
	if c:IsForbidden() or not c:CheckUniqueOnField(tp,LOCATION_SZONE) then return false end
	return not c:IsEquipSpell() or c:CheckEquipTarget(eqc)
end

--LP
function help.GlitchyHelperLP(e,tp)
	Debug.Message("Player "..tp.. " is trying to use the Helper. Reason flag: LIFE POINTS")
	if not help.AskOpponentPermission(e,tp) then return end
	
	local mode=Duel.SelectOption(tp,STRING_LP_INCREASE,STRING_LP_DECREASE,STRING_LP_CHANGE)
	Duel.SelectOption(tp,STRING_LP_INFO)
	
	local amount=math.floor(aux.ComposeNumberDigitByDigit(tp,1,9999))
	
	if mode==0 then
		if Duel.SelectYesNo(tp,STRING_LP_RECOVER) then
			Duel.Recover(tp,amount,REASON_RULE)
			Debug.Message("Player "..tp.." gained "..amount.." LP")
		else
			Duel.SetLP(tp,lp+amount)
			Debug.Message("Player "..tp.." increased their LP by "..amount.." for no effect")
		end
	elseif mode==1 then
		local submode=Duel.SelectOption(tp,STRING_LP_DAMAGE,STRING_LP_PAYMENT,STRING_LP_LOSE)
		if submode==0 then
			Duel.Damage(tp,amount,REASON_EFFECT)
			Debug.Message("Player "..tp.." inflicted "..amount.." damage to their own LP")
		elseif submode==1 then
			Duel.PayLP(tp,amount)
			Debug.Message("Player "..tp.." paid "..amount.." LP")
		else
			Duel.SetLP(tp,lp-amount)
			Debug.Message("Player "..tp.." lost "..amount.." LP")
		end
	else
		Duel.SetLP(tp,amount)
		Debug.Message("Player "..tp.." set their own LP to "..amount)
	end
	
	if not Duel.SelectYesNo(tp,STRING_ALLOW_RESPONSE) then
		Debug.Message("Player "..tp.." prevented effects from responding to this action")
		Duel.SetChainLimit(aux.FALSE)
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	end
	Debug.Message("END OF OPERATION")
end

--DRAW/DISCARD
function help.GlitchyHelperDrawOrDiscard(e,tp)
	Debug.Message("Player "..tp.. " is trying to use the Helper. Reason flag: DRAW_OR_DISCARD")
	if not help.AskOpponentPermission(e,tp) then return end
	
	local b1=Duel.IsPlayerCanDraw(tp,1)
	local b2=Duel.GetHand(tp):IsExists(Card.IsDiscardable,1,nil,REASON_RULE)
	local opt=aux.Option(tp,nil,nil,{b1,1108},{b2,501})
	
	if opt==0 then
		local n=Duel.AnnounceNumberRange(tp,1,Duel.GetDeckCount(tp))
		local ct=Duel.Draw(tp,n,REASON_RULE)
		Debug.Message("Player "..tp.." drew "..ct.." cards")
	elseif opt==1 then
		local ct=Duel.DiscardHand(tp,nil,1,Duel.GetHandCount(tp),REASON_RULE|REASON_DISCARD)
		Debug.Message("Player "..tp.." discarded "..ct.." cards")
	end
	
	if not Duel.SelectYesNo(tp,STRING_ALLOW_RESPONSE) then
		Debug.Message("Player "..tp.." prevented effects from responding to this action")
		Duel.SetChainLimit(aux.FALSE)
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	end
	Debug.Message("END OF OPERATION")
end

--GAMBLE
function help.GlitchyHelperGamble(e,tp)
	Debug.Message("Player "..tp.. " is trying to use the Helper. Reason flag: COIN_OR_DICE")
	if not help.AskOpponentPermission(e,tp) then return end
	
	local opt=aux.Option(tp,nil,nil,{true,STRING_COIN},{true,STRING_DICE})
	
	if opt==0 then
		Duel.HintMessage(tp,STRING_HINT_GAMBLE)
		local n=Duel.AnnounceNumberRange(tp,1,5)
		Duel.TossCoin(tp,n)
		Debug.Message("Player "..tp.." tossed a coin "..n.." times")
	elseif opt==1 then
		local n=Duel.AnnounceNumberRange(tp,1,5)
		Duel.TossDice(tp,n)
		Debug.Message("Player "..tp.." rolled a die "..n.." times")
	end
	
	if not Duel.SelectYesNo(tp,STRING_ALLOW_RESPONSE) then
		Debug.Message("Player "..tp.." prevented effects from responding to this action")
		Duel.SetChainLimit(aux.FALSE)
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	end
	Debug.Message("END OF OPERATION")
end

--COUNTER
help.CounterList={}
function help.GlitchyHelperCounter(e,tp)
	Debug.Message("Player "..tp.. " is trying to use the Helper. Reason flag: COUNTER")
	if not help.AskOpponentPermission(e,tp) then return end
		
	if #help.CounterList==0 then
		local preCounterList={}
		local g=Duel.Group(help.HasCounterListed,tp,LOCATION_ALL,LOCATION_ALL,nil)+Duel.GetXyzMaterialGroup(tp,1,1,nil,help.HasCounterListed)
		if #g==0 then
			Debug.Message("ERROR 05: You are playing no cards that can place counters")
			Debug.Message("END OF OPERATION")
			return
		end
		for tc in aux.Next(g) do
			if tc.counter_list then
				for _,ccounter in ipairs(tc.counter_list) do
					if not preCounterList[ccounter] then
						preCounterList[ccounter]=true
					end
				end
			elseif tc.counter_place_list then
				for _,ccounter in ipairs(tc.counter_place_list) do
					if not preCounterList[ccounter] then
						preCounterList[ccounter]=true
					end
				end
			end
		end
		
		for ctype,val in pairs(preCounterList) do
			table.insert(help.CounterList,ctype)
		end
	end
	
	Duel.SelectOption(tp,STRING_INFO_COUNTER)
	local ctype=Duel.AnnounceNumber(tp,table.unpack(help.CounterList))
	
	Duel.HintMessage(tp,STRING_HOW_MANY_COUNTERS)
	local n=Duel.AnnounceNumberRange(tp,1,60)
	
	local rg=Duel.Group(aux.FaceupFilter(Card.IsCanAddCounter,ctype,n),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #rg==0 then
		Debug.Message("ERROR 06: There are no cards on which you can place counters of type "..ctype)
		Debug.Message("END OF OPERATION")
		return
	end
	
	local ct=#rg
	local tc=nil
	for i=1,n do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
		tc=rg:Select(tp,1,1,nil):GetFirst()
		tc:AddCounter(ctype,1)
	end
	
	Debug.Message("Player "..tp.." placed "..n.." counters of type "..ctype)
	if not Duel.SelectYesNo(tp,STRING_ALLOW_RESPONSE) then
		Debug.Message("Player "..tp.." prevented effects from responding to this action")
		Duel.SetChainLimit(aux.FALSE)
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	end
	Debug.Message("END OF OPERATION")
end
function help.HasCounterListed(c)
	return c.counter_list or c.counter_place_list
end

--CONCEDE CONTROL
function help.GlitchyHelperConcedeControl(e,tp)
	Debug.Message("Player "..tp.. " is trying to use the Helper. Reason: PASS_CONTROL_OF_THE_HELPER_TO_OPPONENT")
	if not help.AskOpponentPermission(e,tp) then return end
	
	help.PreventHotPotato=true
	
	local eset={}
	local descs={}
	for _,ce in ipairs(help.HelperEffects) do
		local cond=ce:GetCondition()
		if not cond or cond(ce,1-tp) then
			table.insert(eset,ce)
			table.insert(descs,ce:GetDescription())
		end
	end
	
	local opt=Duel.SelectOption(1-tp,STRING_STOP,table.unpack(descs))
	if opt~=0 then
		local ce=eset[opt]
		ce:GetOperation()(ce,1-tp)
	else
		Debug.Message("Player "..(1-tp).." decided not to use the Helper")
		Debug.Message("END OF OPERATION")
	end
	
	help.PreventHotPotato=false
end

function help.ResetCondition(tc)
	return	function(e)
				if not tc or not tc:HasFlagEffect(FLAG_PREVENT_RESET) then
					e:Reset()
					return false
				end
				return true
			end
end