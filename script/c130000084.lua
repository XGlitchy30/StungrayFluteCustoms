--[[
Who I Never Should Have Been
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 monsters, including a "Linaan" monster
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	--[[During your Standby Phase: You can target 1 "Motherhood" card in your GY; place it on the bottom of your Deck, and if you do, add 1 "Motherhood" card with a different name from your Deck to
	your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:HOPT()
	e1:SetFunctions(xgl.TurnPlayerCond(0),nil,s.target,s.operation)
	c:RegisterEffect(e1)
	--[[If this card would be destroyed by battle, you can banish 1 card from your hand instead.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetTarget(s.reptg)
	c:RegisterEffect(e2)
end
s.listed_series={SET_LINAAN,SET_MOTHERHOOD}

function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_LINAAN,lc,sumtype,tp)
end

--E1
function s.filter(c,tp)
	return c:IsSetCard(SET_MOTHERHOOD) and c:IsAbleToDeck() and Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,c,c:GetCode())
end
function s.thfilter(c,...)
	return c:IsSetCard(SET_MOTHERHOOD) and c:IsAbleToHand() and not c:IsCode(...)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,tp)
	end
	if chk==0 then
		return Duel.IsExists(true,s.filter,tp,LOCATION_GRAVE,0,1,nil,tp)
	end
	local tc=Duel.Select(HINTMSG_TODECK,true,tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	Duel.SetCardOperationInfo(tc,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local codes={tc:GetCode()}
		if Duel.ShuffleIntoDeck(tc,nil,nil,SEQ_DECKBOTTOM)>0 then
			local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,table.unpack(codes))
			if #g>0 and Duel.Search(g)>0 then
				Duel.ShuffleDeck(tp)
				Duel.DisableShuffleCheck()
				Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
			end
		end
	end
end

--E2
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
			and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil,tp,POS_FACEUP,REASON_EFFECT|REASON_REPLACE)
	end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil,tp,POS_FACEUP,REASON_EFFECT|REASON_REPLACE)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT|REASON_REPLACE)
		return true
	else
		return false
	end
end