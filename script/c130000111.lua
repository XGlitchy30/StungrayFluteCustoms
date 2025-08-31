--[[
Resurgence Paladin
Card Author: LimitlessSocks
Scripted by: XGlitchy30
]]

local s,id = GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1 Spell + 1 Trap
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SPELL),aux.FilterBoolFunctionEx(Card.IsType,TYPE_TRAP))
	--Must first be Special Summoned (from your Extra Deck) by Tributing the above cards from your field.
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit,nil,nil,aux.Stringid(id,0))
	--[[For the rest of the Duel after this card's owner Special Summons it, they play with their hand revealed, also, if a monster is in their hand or field that began the Duel in their Main Deck,
	their opponent wins the Duel.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.pubcon)
	e1:SetOperation(s.pubop)
	c:RegisterEffect(e1)
	--[[During your Draw Phase, instead of conducting your normal draw: You can banish 1 Spell and 1 Trap from your GY; Special Summon this card from your GY.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_GRAVE)
	e2:OPT()
	e2:SetFunctions(
		s.spcon,
		s.spcost,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e2)
end

function s.contactfil(tp)
	return Duel.GetReleaseGroup(tp)+Duel.Group(Card.IsReleasable,tp,LOCATION_ONFIELD&(~LOCATION_MZONE),0,nil,REASON_COST|REASON_MATERIAL|REASON_SPSUMMON)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST|REASON_MATERIAL|REASON_SPSUMMON)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end

--E1
function s.pubcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=c:GetOwner()
	return c:GetSummonPlayer()==p and not Duel.PlayerHasFlagEffect(p,id)
end
function s.pubop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p=c:GetOwner()
	Duel.RegisterFlagEffect(p,id,0,0,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetTargetRange(LOCATION_HAND,0)
	Duel.RegisterEffect(e1,p)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetOperation(s.loseop)
	Duel.RegisterEffect(e2,p)
end
function s.losefilter(c)
	return c:IsMonsterType() and not c:IsOriginalType(TYPE_EXTRA|TYPE_TOKEN)
end
function s.loseop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(s.losefilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	if #g>0 then
		if not g:IsExists(Card.IsFaceupEx,1,nil) then
			Duel.ConfirmCards(1-tp,g)
		end
		Duel.Win(1-tp,WIN_REASON_CUSTOM)
		Duel.Readjust()
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and Duel.GetDrawCount(tp)>0
end
function s.rmcostfilter(c)
	return c:IsSpellTrap() and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.rmcostfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetMainCardType),0) end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetMainCardType),1,tp,HINTMSG_REMOVE)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false) end
	local dt=Duel.GetDrawCount(tp)
	if dt~=0 then
		_replace_count=0
		_replace_max=dt
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE|PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	_replace_count=_replace_count+1
	if _replace_count<=_replace_max and c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end