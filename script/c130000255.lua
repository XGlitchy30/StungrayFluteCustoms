--[[
Alanera - Notus il Vento di Tempesta
Card Author: Knightmare88
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[If you control a "Blackwing" monster other than "Blackwing - Notus the Storm Wind", you can Special Summon this card (from your hand). You can only Special Summon "Blackwing - Notus the Storm Wind" once per turn this way.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT(true)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--[[If this card is in your GY, except the turn it was sent there: You can banish this card from your GY, then target 2 "Blackwing" monsters in your GY; shuffle 1 of them into the Deck, then place the other on the top of the Deck, and if you do, take damage equal to the ATK of the monster placed on the top of the Deck by this effect. You can only use this effect of "Blackwing - Notus the Storm Wind" once per turn.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(aux.exccon,Cost.SelfBanish,s.tdtg,s.tdop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_BLACKWING}

--E1
function s.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_BLACKWING) and not c:IsCode(id)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end

--E2
function s.tdfilter(c)
	return c:IsSetCard(SET_BLACKWING) and c:IsMonster() and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then
		local exc=e:IsCostChecked() and e:GetHandler() or nil
		return Duel.IsExists(true,s.tdfilter,tp,LOCATION_GRAVE,0,2,exc)
	end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,0)
	Duel.SetAdditionalOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,{g:GetFirst():GetAttack(),g:GetNext():GetAttack()})
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards():Filter(Card.IsAbleToDeck,nil)
	if #tg>0 then
		Duel.HintMessage(tp,HINTMSG_TODECKSHUFFLE)
		local sg=tg:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		if Duel.ShuffleIntoDeck(sg)==0 then return end
		local tc=(tg-sg):GetFirst()
		if not tc then return end
		Duel.HintSelection(tc)
		Duel.BreakEffect()
		if Duel.PlaceOnTopOfDeck(tc,tp,nil,nil,nil,xgl.BecauseOfThisEffect(e))>0 then
			Duel.Damage(tp,math.max(tc:GetAttack(),0),REASON_EFFECT)
		end
	end
end