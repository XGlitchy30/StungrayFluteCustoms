--[[
Captain Shores
Card Author: Ani
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[When this card declares an attack: It gains 200 ATK.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--[[If you started the Duel with exactly 8 cards in your Extra Deck: You can shuffle your opponent's face-down Extra Deck, then send the top card to the GY]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(s.tgcon,nil,s.tgtg,s.tgop)
	c:RegisterEffect(e2)
	--Count cards at the start of the Duel
	aux.GlobalCheck(s,function()
		local ge=Effect.GlobalEffect()
		ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_STARTUP)
		ge:SetOperation(s.regop)
		Duel.RegisterEffect(ge,0)
	end)
end
local FLAG_STARTED_WITH_8_CARDS_IN_EXTRA = id

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if Duel.GetExtraDeckCount(p)==8 then
			Duel.RegisterFlagEffect(p,FLAG_STARTED_WITH_8_CARDS_IN_EXTRA,0,0,0)
		end
	end
end

--E1
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,0,200)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToChain() then
		c:UpdateATK(200,true,c)
	end
end

--E2
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.PlayerHasFlagEffect(tp,FLAG_STARTED_WITH_8_CARDS_IN_EXTRA)
end
function s.tgfilter(c)
	return c:IsFacedown() and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_EXTRA,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_EXTRA)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_EXTRA,nil)==0 then return end
	Duel.ShuffleExtra(1-tp)
	local tc=Duel.GetExtraTopGroup(1-tp,1):GetFirst()
	if tc and tc:IsAbleToGrave() then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end