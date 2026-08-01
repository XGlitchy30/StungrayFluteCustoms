--[[
Combattenti Pelliccia Mercenaria
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")

function s.initial_effect(c)
	c:Activation(nil,TIMING_ATTACK)
	--Monsters "Fur Hire" you control gain 100 ATK for each monster "Fur Hire" you control. 
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_FUR_HIRE))
	e1:SetValue(xgl.ForEach(xgl.ArchetypeFilter(SET_FUR_HIRE),LOCATION_MZONE,0,nil,100))
	c:RegisterEffect(e1)
	--[[(When you activate the following effect, you can also Tribute 1 monster "Fur Hire".) Once per turn: You can target 1 monster "Fur Hire" you control; return it to the hand, then, you can apply any of the following effects, in sequence.
	● Special Summon 1 monster "Fur Hire" from your hand.
	● If you Tributed a monster at activation, you can Special Summon 1 monster "Fur Hire" from your GY.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT()
	e2:SetFunctions(
		nil,
		s.cost,
		s.target,
		s.operation
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FUR_HIRE}

--E1
function s.cfilter(c,tp)
	return c:IsSetCard(SET_FUR_HIRE) and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,c)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_FUR_HIRE) and c:IsAbleToHand()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	if Duel.CheckReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,tp) and Duel.SelectYesNo(tp,STRING_ASK_TRIBUTE) then
		local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,tp)
		Duel.Release(g,REASON_COST)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then
		return e:IsCostChecked() or Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
	end
	local v = e:IsCostChecked() and e:GetLabel() or 0
	local locs = v==1 and LOCATION_HAND|LOCATION_GRAVE or LOCATION_HAND
	e:SetLabel(0)
	local tc=Duel.Select(HINTMSG_RTOHAND,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.SetTargetParam(v)
	Duel.SetCardOperationInfo(tc,CATEGORY_TOHAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,locs)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_FUR_HIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)	
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.SearchAndCheck(tc) then
		local v=Duel.GetTargetParam()
		if Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.ShuffleHand(tp)
			local spc=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
			Duel.BreakEffect()
			Duel.SpecialSummon(spc,0,tp,tp,false,false,POS_FACEUP)
		end
		if v==1 and Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(aux.Necro(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			local spc=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
			Duel.BreakEffect()
			Duel.SpecialSummon(spc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end