--[[
Lady Luck Exploderoll
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1 Fairy Tuner + 1+ non-Tuner "Lady Luck" monsters
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FAIRY),1,1,Synchro.NonTunerEx(Card.IsSetCard,SET_LADY_LUCK),1,99)
	--If this card is Synchro Summoned: You can add 1 "Lady Luck" card from your GY or banishment to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(xgl.SynchroSummonedCond)
	e1:SetSearchFunctions(xgl.ArchetypeFilter(SET_LADY_LUCK),LOCATION_GB)
	c:RegisterEffect(e1)
	--[[During the Main Phase (Quick Effect): You can roll a six-sided die, then apply the appropriate effect based on the result. You can only use each effect of "Lady Luck Exploderoll" once per turn.
	● 1, 2 or 3: Special Summon 1 "Lady Luck" monster from your hand, or, if you cannot, gain 600 LP.
	● 4, 5 or 6: Banish 1 "Lady Luck" monster from your GY, and if you do, Special Summon it during the Standby Phase of the next turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DICE|CATEGORY_SPECIAL_SUMMON|CATEGORY_RECOVER|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetFunctions(
		xgl.MainPhaseCond(),
		nil,
		s.dicetg,
		s.diceop
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_LADY_LUCK}
s.roll_dice=true

--E2
function s.rmfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_LADY_LUCK) and c:IsAbleToRemove()
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_LADY_LUCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.Group(s.rmfilter,tp,LOCATION_GRAVE,0,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,600)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	if d>=1 and d<=3 then
		local spchk=false
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,2))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
		if Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then
			local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if #g>0 then
				spchk=true
				Duel.BreakEffect()
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
		if not spchk then
			Duel.BreakEffect()
			Duel.Recover(tp,600,REASON_EFFECT)
		end
		
	elseif d>3 and d<=6 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,3))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.rmfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if Duel.Highlight(g) then
			Duel.BreakEffect()
			if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
				local tc=g:GetFirst()
				if tc:IsBanished(POS_FACEUP) then
					local rct=Duel.GetCurrentPhase()<=PHASE_STANDBY and 2 or 1
					xgl.DelayedOperation(tc,PHASE_STANDBY,id,e,tp,s.spop2,s.spcon2,nil,rct,aux.Stringid(id,4),aux.Stringid(id,5))
				end
			end
		end
	end
end
function s.spcon2(g,e,tp,eg,ep,ev,re,r,rp,turncount)
	return Duel.GetTurnCount()>turncount
end
function s.spop2(g,e,tp,eg,ep,ev,re,r,rp,turncount)
	Duel.Hint(HINT_CARD,tp,id)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end