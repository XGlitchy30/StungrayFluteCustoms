--[[
Destiny HERO - Insomnia
Card Author: Fishy
Scripted by: XGlitchy30
]]

local s,id = GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--"Destiny HERO - Drilldark" + 1 DARK Warrior monster
	Fusion.AddProcMix(c,true,true,CARD_DHERO_DRILLDARK,s.ffilter)
	--Once per turn, at the end of the Battle Phase, if this card destroyed a monster by battle this turn: You can banish 1 card from either GY, and if you do, this card gains 300 ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORIES_ATKDEF)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE|PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:OPT()
	e1:SetFunctions(s.grcon,nil,s.grtg,s.grop)
	c:RegisterEffect(e1)
	--Hidden effect that registers if the handler destroyed a monster by battle during a turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	--If this card is destroyed by your opponent's card effect: You can target 1 non-Fusion "Destiny HERO" monster in your GY; Special Summon it, but banish it when it leaves the field.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:HOPT()
	e3:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_DHERO_DRILLDARK}

--Fusion Material
function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR,fc,sumtype,tp) and c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp)
end

--E1
function s.grcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():HasFlagEffect(id)
end
function s.rmfilter(c)
	return c:IsAbleToRemove() and aux.SpElimFilter(c)
end
function s.grtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanChangeStats(300,300) and Duel.IsExists(false,s.rmfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_EITHER,LOCATION_GRAVE)
	local p,loc=c:GetResidence()
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,c,1,p,loc,300)
end
function s.grop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,aux.Necro(s.rmfilter),tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
			local c=e:GetHandler()
			if c:IsRelateToChain() and c:IsFaceup() and c:IsCanChangeStats(300,300) then
				c:UpdateATKDEF(300,300,true,c)
			end
		end
	end
end

--E2
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
end

--E3
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT)
end
function s.spfilter(c,e,tp)
	return not c:IsType(TYPE_FUSION) and c:IsSetCard(SET_DESTINY_HERO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end 
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SpecialSummonRedirect(e,tc,0,tp,tp,false,false,POS_FACEUP)
	end
end