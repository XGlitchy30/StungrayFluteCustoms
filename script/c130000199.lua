--[[
Evil★Twin Planning
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--If an "Evil★Twin" monster is in your Monster Zone, or in your GY (and you control no monsters): Target 1 card your opponent controls, also you can Tribute 1 "Ki-sikil" or "Lil-la" monster; negate that target's effects until the end of this turn, then, if you Tributed a monster when you activated this card, you can add 1 "Evil★Twin" or "Live☆Twin" card from your GY to your hand, except "Evil★Twin Planning".
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:HOPT(true)
	e1:SetCondition(s.condition)
	e1:SetCost(xgl.DummyCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_KI_SIKIL,SET_LIL_LA,SET_EVIL_TWIN,SET_LIVE_TWIN}

--E1
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_EVIL_TWIN) and (c:IsLocation(LOCATION_MZONE) or c:IsMonster())
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,s.filter,tp,LOCATION_MZONE,0,1,nil) or (Duel.IsExists(false,s.filter,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetMonstersCount(tp)==0)
end
function s.cfilter(c)
	return c:IsSetCard({SET_KI_SIKIL,SET_LIL_LA})
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsNegatable() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	local hasTributed=0
	if e:IsCostChecked() and Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,g) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local rg=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,g)
		Duel.Release(rg,REASON_COST)
		e:SetCategory(CATEGORY_DISABLE|CATEGORY_TOHAND)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
		hasTributed=1
	else
		e:SetCategory(CATEGORY_DISABLE)
	end
	Duel.SetTargetParam(hasTributed)
end
function s.thfilter(c)
	return c:IsSetCard({SET_EVIL_TWIN,SET_LIVE_TWIN}) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsControler(1-tp) and tc:IsCanBeDisabledByEffect(e) then
		local _,_,res=Duel.Negate(tc,e,RESET_PHASE|PHASE_END)
		if res and Duel.GetTargetParam()==1 then
			local g=Duel.Group(aux.Necro(s.thfilter),tp,LOCATION_GRAVE,0,nil)
			if #g>0 and Duel.SelectYesNo(tp,STRING_ASK_RETURN_TO_HAND) then
				Duel.HintMessage(tp,HINTMSG_ATOHAND)
				local tg=g:Select(tp,1,1,nil)
				if Duel.Highlight(tg) then
					Duel.BreakEffect()
					Duel.Search(tg)
				end
			end
		end
	end
end