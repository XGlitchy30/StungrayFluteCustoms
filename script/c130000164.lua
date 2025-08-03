--[[
Valerie the Flamespear
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[You can Special Summon this card (from your hand) by sending 1 Spellcaster monster or 1 "Vixen Brew"/"Flamespear Style" Spell/Trap from your hand or field to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spproccon)
	e1:SetTarget(s.spproctg)
	e1:SetOperation(s.spprocop)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can add 1 "Flamespear Style"/"Vixen Brew" Spell/Trap from your Deck to your hand. ]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetSearchFunctions(s.thfilter)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--(Quick Effect): You can shuffle 3 Spell/Traps from your GY into the Deck, including 1 "Flamespear Style"/"Vixen Brew" Spell/Trap; draw 1 card.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetRelevantTimings()
	e3:HOPT()
	e3:SetCost(s.drawcost)
	e3:SetDrawFunctions()
	c:RegisterEffect(e3)
end
s.listed_series={SET_FLAMESPEAR_STYLE,SET_VIXEN_BREW}

--E1
function s.tgfilter(c,tp)
	if not (c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0) then return false end
	if c:IsRace(RACE_SPELLCASTER) then
		return c:IsLocation(LOCATION_MZONE|LOCATION_HAND)
	elseif c:IsSetCard({SET_FLAMESPEAR_STYLE,SET_VIXEN_BREW}) then
		return (c:IsSpellTrapOnField() and c:IsFaceup()) or (c:IsLocation(LOCATION_HAND) and c:IsSpellTrap())
	end
	return false
end
function s.spproccon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,c,tp)
	return #rg>0 and aux.SelectUnselectGroup(rg,e,tp,1,1,nil,0)
end
function s.spproctg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,c,tp)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spprocop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	g:DeleteGroup()
end

--E2
function s.thfilter(c)
	return c:IsSpellTrap() and c:IsSetCard({SET_FLAMESPEAR_STYLE,SET_VIXEN_BREW})
end

--E3
function s.cfilter(c)
	return c:IsSpellTrap() and c:IsAbleToDeckAsCost()
end
function s.firstc(c)
	return c:IsSetCard({SET_FLAMESPEAR_STYLE,SET_VIXEN_BREW})
end
function s.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then
		return xgl.SelectUnselectGroup(0,g,e,tp,3,3,nil,0,nil,nil,nil,nil,nil,s.firstc)
	end
	local tg=xgl.SelectUnselectGroup(0,g,e,tp,3,3,nil,1,tp,HINTMSG_TODECK,nil,nil,nil,s.firstc)
	if Duel.Highlight(tg) then
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end