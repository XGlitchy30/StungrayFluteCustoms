--[[
Disturbing Burial
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Send 1 Level 3 or lower Normal Monster from your hand or Deck to the GY; Special Summon 1 Level 3 or lower Normal Monster with a different name from your GY in Attack Position, also its DEF becomes 0
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetFunctions(
		nil,
		xgl.DummyCost,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--If a Normal Monster you control destroys a monster by battle, while this card is in your GY: You can Set this card, but banish it when it leaves the field.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCustomCategory(CATEGORY_SET_SPELLTRAP)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.setcon)
	e2:SetSSetSelfFunctions(false,true)
	c:RegisterEffect(e2)
end

--E1
function s.cfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3) and c:IsAbleToGraveAsCost()
		and Duel.IsExists(false,s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter(c,e,tp,...)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(3) and not c:IsCode(...) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() and Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.cfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)
	end
	local v=0
	local tc=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.cfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	local codes={tc:GetCode()}
	e:SetLabel(table.unpack(codes))
	Duel.SendtoGrave(tc,REASON_COST)
	local sg=Duel.Group(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp,table.unpack(codes))
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,#sg>0 and sg or nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local tc=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetLabel()):GetFirst()
	if tc then
		tc:AssumeProperty(ASSUME_DEFENSE,0)
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
		end
		Duel.SpecialSummonComplete()
	end
end

--E2
function s.egfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsType(TYPE_NORMAL)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.egfilter,1,nil,tp)
end