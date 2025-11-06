--[[
Ancestagon Tricereapeter
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--[[You can Tribute 1 "Ancestagon" monster from your hand or face-up field; Special Summon this card from your Pendulum Zone, then if you Tributed an "Ancestagon" monster from your hand to
	activate this effect, and it is now in the GY or banished, add that Tributed monster to your Extra Deck face-up.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetOriginalCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		xgl.LabelCost,
		s.tetg,
		s.teop
	)
	c:RegisterEffect(e1)
	
	local spsum_restriction = xgl.SSRestrictionCost(aux.FilterBoolFunction(Card.IsRace,RACE_DINOSAUR),true,nil,id,LOCATION_EXTRA,1,nil,nil,aux.TargetBoolFunction(Card.IsOriginalRace,RACE_DINOSAUR))
	--[[If this card is Pendulum Summoned: You can draw 1 card, then if it is a "Ancestagon" Spell/Trap, you can Set it to your Spell/Trap Zone, also it can be activated this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetCustomCategory(CATEGORY_SET_SPELLTRAP)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(
		xgl.PendulumSummonedCond,
		spsum_restriction,
		s.drawtg,
		s.drawop
	)
	c:RegisterEffect(e2)
	--[[If this card is Tributed: You can Special Summon 1 Level 2 "Ancestagon" monster from your Deck, except "Ancestagon Tricereapeter".]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,3)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:HOPT()
	e3:SetCost(spsum_restriction)
	e3:SetSpecialSummonFunctions(nil,nil,s.spfilter,LOCATION_DECK,0,1,1,nil)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ANCESTAGON}
s.listed_names={id}

--E1
function s.costfilter(c,tp)
	return c:IsMonsterType() and c:IsSetCard(SET_ANCESTAGON)
		and (c:IsFaceup() or (c:IsLocation(LOCATION_HAND) and (not c:IsType(TYPE_PENDULUM) or not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_TO_EXTRA_P))))
		and Duel.GetMZoneCount(tp,c)>0
end
function s.tecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,true,nil,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,true,nil,nil,tp):GetFirst()
	if Duel.Release(tc,REASON_COST)>0 and xgl.BecauseOfThisCost(e)(tc) and tc:IsLocation(LOCATION_GB) and tc:IsType(TYPE_PENDULUM) then
		Duel.SetTargetCard(tc)
		Duel.SetCardOperationInfo(tc,CATEGORY_TOEXTRA)
	end
end
function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local isCostChecked=e:GetLabel()==1
	e:SetLabel(0)
	local c=e:GetHandler()
	if chk==0 then
		local costchk = isCostChecked and s.tecost(e,tp,eg,ep,ev,re,r,rp,0) or Duel.GetMZoneCount(tp)>0
		return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and costchk
	end
	if isCostChecked then
		s.tecost(e,tp,eg,ep,ev,re,r,rp,chk)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToChain() and tc:IsAbleToExtraFaceup(e,tp) then
			Duel.BreakEffect()
			Duel.SendtoExtraP(tc,tp,REASON_EFFECT)
		end
	end
end


--E2
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleCustomOperationInfo(0,CATEGORY_SET_SPELLTRAP,nil,1,tp,LOCATION_HAND)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		local tc=Duel.GetOperatedGroup():GetFirst()
		if tc:IsSpellTrap() and tc:IsSetCard(SET_ANCESTAGON) and not tc:IsType(TYPE_FIELD) and Duel.SelectYesNo(tp,STRING_ASK_SET) then
			Duel.BreakEffect()
			Duel.SSetAndFastActivation(tp,tc,e)
		end
	end
end

--E3
function s.spfilter(c)
	return c:IsSetCard(SET_ANCESTAGON) and c:IsLevel(2) and not c:IsCode(id)
end