--[[
Magma Power Stone
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--You can only control 1 "Magma Power Stone".
	c:SetUniqueOnField(1,0,id)
	--When this card is activated: You can banish 1 FIRE monster from your hand or field; add 1 "Laval" monster with a different name from your Deck to your hand.
	c:Activation(true,nil,nil,xgl.DummyCost,s.target,s.activate)
	--Once per turn, if a "Laval" monster(s) is Normal or Special Summoned (except during the Damage Step), you can: Immediately after this effect resolves, Normal Summon 1 "Laval" monster.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:OPT(true)
	e2:SetFunctions(s.nscon,nil,s.nstg,s.nsop)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
end
s.listed_names={id}
s.listed_series={SET_LAVAL}

--E0
function s.cfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsFaceupEx() and (c:IsLocation(LOCATION_MZONE) or c:IsMonster()) and c:IsAttribute(ATTRIBUTE_FIRE)
		and Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.thfilter(c,...)
	return c:IsMonster() and c:IsSetCard(SET_LAVAL) and not c:IsCode(...) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetCategory(0)
	e:SetLabel(0)
	if e:IsCostChecked() then
		local g=Duel.Group(s.cfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil,tp)
		if #g>0 and Duel.SelectYesNo(tp,STRING_ASK_BANISH) then
			Duel.HintMessage(tp,HINTMSG_REMOVE)
			local rg=g:Select(tp,1,1,nil)
			e:SetLabel(g:GetFirst():GetCode())
			Duel.Remove(rg,POS_FACEUP,REASON_COST)
			e:SetCategory(CATEGORIES_SEARCH)
			Duel.SetTargetParam(1)
			Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		end
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetTargetParam()==1 then
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
		if #g>0 then
			Duel.Search(g)
		end
	end
end

--E2
function s.nscon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.FaceupFilter(Card.IsSetCard,SET_LAVAL),1,nil)
end
function s.nsfilter(c)
	return c:IsSetCard(SET_LAVAL) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end