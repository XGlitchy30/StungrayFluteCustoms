--[[
Ancestagon Silveraptor
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--[[You can place this card from your Pendulum Zone and 1 card from your GY on top of your Deck in any order; add 1 Level 8 or higher "Ancestagon" monster from your Deck to your face-up Extra
	Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetFunctions(
		nil,
		s.tecost,
		s.tetg,
		s.teop
	)
	c:RegisterEffect(e1)
	--[[If this card is Normal Summoned: You can add 1 "Ancestagon" monster from your Deck to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetSearchFunctions(xgl.MonsterFilter(Card.IsSetCard,SET_ANCESTAGON))
	c:RegisterEffect(e2)
	--[[If this card is Pendulum Summoned: You can Tribute 1 monster; destroy 1 Spell/Trap your opponent controls.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:HOPT()
	e3:SetFunctions(
		xgl.PendulumSummonedCond,
		s.descost,
		s.destg,
		s.desop
	)
	c:RegisterEffect(e3)
	--[[If this card is Tributed to activate an "Ancestagon" card or effect: Draw 1 card.]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,3)
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EVENT_RELEASE)
	e4:HOPT()
	e4:SetFunctions(nil,nil,s.drawtg,xgl.DrawOperation())
	c:RegisterEffect(e4)
end
s.listed_series={SET_ANCESTAGON}

--E1
function s.tefilter(c,e,tp)
	return c:IsLevelAbove(8) and c:IsSetCard(SET_ANCESTAGON) and c:IsAbleToExtraFaceup(e,tp)
end
function s.tecost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local c=e:GetHandler()
	local g=Duel.Group(Card.IsAbleToDeckAsCost,tp,LOCATION_GRAVE,0,nil)
	local techk=Duel.IsExists(false,s.tefilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	if chk==0 then
		local og=g:Clone()
		og:AddCard(c)
		return c:IsAbleToDeckAsCost() and #g>0
			and (techk or og:IsExists(s.tefilter,1,nil,e,tp))
	end
	Duel.HintMessage(tp,HINTMSG_TODECK)
	local tg = (s.tefilter(c,e,tp) or techk) and g:Select(tp,1,1,nil) or g:FilterSelect(tp,s.tefilter,1,1,nil,e,tp)
	Duel.HintSelection(tg)
	tg:AddCard(c)
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local isCostChecked=e:GetLabel()==1
		e:SetLabel(0)
		return isCostChecked or Duel.IsExists(false,s.tefilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOEXTRA)
	local sg=Duel.Select(HINTMSG_TOEXTRA,false,tp,s.tefilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #sg>0 then
		Duel.SendtoExtraP(sg,tp,REASON_EFFECT)
	end
end

--E2
function s.descostfilter(c,tp)
	local exg=c:GetEquipGroup()+c
	return Duel.IsExists(false,Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,exg)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.descostfilter,1,false,nil,nil,tp) end
	local sg=Duel.SelectReleaseGroupCost(tp,s.descostfilter,1,1,false,nil,nil,tp)
	Duel.Release(sg,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local isCostChecked=e:GetLabel()==1
		e:SetLabel(0)
		return isCostChecked or Duel.IsExistingMatchingCard(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,nil)
	end
	e:SetLabel(0)
	local g=Duel.Group(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--E4
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end