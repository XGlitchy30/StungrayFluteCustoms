--[[
Demonisu Blades
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")

if not Demonisu then
	Demonisu = {}
	Duel.LoadScript("glitchylib_archetypes.lua",false)
end

local FLAG_DEMONISU_TARGET			= id
local FLAG_REGISTERED_FORCED_ATTACK = id+100
local FLAG_DELAYED_OP 				= id+200

function s.initial_effect(c)
	--[[If this card is Normal Summoned: You can target 1 face-up monster your opponent controls; it cannot attack, except to attack this card, while this card is face-up on the field.]]
	Demonisu.RegisterOnSummonEffect(c,id,FLAG_DEMONISU_TARGET,FLAG_REGISTERED_FORCED_ATTACK)
	--[[If your opponent's monster declares an attack involving this card: You can return this card to your hand; negate the attack, also destroy the attacking monster during the End Phase of this
	turn]]
	Demonisu.RegisterAttackNegate(c,id,CATEGORY_DESTROY,s.negtg,s.negop)
	--[[You can discard this card; add 1 Level 5 or higher "Demonisu" monster from your Deck to your hand.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,5)
	e3:SetCategory(CATEGORIES_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:HOPT()
	e3:SetCost(xgl.DiscardSelfCost)
	e3:SetSearchFunctions(s.thfilter)
	c:RegisterEffect(e3)
end
s.listed_series={SET_DEMONISU}

--E2
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=eg:GetFirst()
	Duel.SetTargetCard(tc)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp,tc,res)
	if res then
		xgl.DelayedOperation(tc,PHASE_END,FLAG_DELAYED_OP,e,tp,s.desop,nil,nil,nil,aux.Stringid(id,3),aux.Stringid(id,4))
	end
end
function s.desop(g,e,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	if tc then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--E3
function s.thfilter(c)
	return c:IsLevelAbove(5) and c:IsSetCard(SET_DEMONISU)
end