--[[
Demonisu Bones
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

function s.initial_effect(c)
	--[[If this card is Normal Summoned: You can target 1 face-up monster your opponent controls; it cannot attack, except to attack this card, while this card is face-up on the field.]]
	Demonisu.RegisterOnSummonEffect(c,id,FLAG_DEMONISU_TARGET,FLAG_REGISTERED_FORCED_ATTACK)
	--[[If your opponent's monster declares an attack involving this card: You can return this card to your hand; negate the attack, then send 1 "Demonisu" card from your Deck to the GY. ]]
	Demonisu.RegisterAttackNegate(c,id,CATEGORY_TOGRAVE,s.negtg,s.negop)
	--[[You can discard this card; this turn, you can Tribute Summon Level 7 or higher "Demonisu" monsters for 1 less Tribute]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,3)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:HOPT()
	e3:SetCost(xgl.DiscardSelfCost)
	e3:SetOperation(s.procop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_DEMONISU}

--E2
function s.tgfilter(c)
	return c:IsSetCard(SET_DEMONISU) and c:IsAbleToGrave()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp,tc,res,IsAttackNegated)
	if IsAttackNegated then
		local tg=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #tg>0 then
			Duel.BreakEffect()
			Duel.SendtoGrave(tg,REASON_EFFECT)
		end
	end
end

--E3
function s.procop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,4)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_DECREASE_TRIBUTE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(s.proctg)
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,4))
end
function s.proctg(e,c)
	return c:IsLevelAbove(7) and c:IsSetCard(SET_DEMONISU)
end