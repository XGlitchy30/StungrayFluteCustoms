--[[
Demonisu Scales
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")

if not Demonisu then
	Demonisu = {}
	Duel.LoadScript("glitchylib_archetypes.lua",true)
end

local FLAG_DEMONISU_TARGET			= id
local FLAG_REGISTERED_FORCED_ATTACK = id+100

function s.initial_effect(c)
	--[[If this card is Normal Summoned: You can target 1 face-up monster your opponent controls; it cannot attack, except to attack this card, while this card is face-up on the field.]]
	Demonisu.RegisterOnSummonEffect(c,id,FLAG_DEMONISU_TARGET,FLAG_REGISTERED_FORCED_ATTACK)
	--[[If your opponent's monster declares an attack involving this card: You can return this card to your hand; negate the attack, then inflict 500 damage to your opponent]]
	Demonisu.RegisterAttackNegate(c,id,CATEGORY_DAMAGE,s.negtg,s.negop)
	--[[You can discard this card; immediately after this effect resolves, Normal Summon 1 "Demonisu" monster.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,3)
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:HOPT()
	e3:SetFunctions(
		nil,
		xgl.CreateCost(xgl.LabelCost,xgl.DiscardSelfCost),
		s.nstg,
		s.nsop
	)
	c:RegisterEffect(e3)
end
s.listed_series={SET_DEMONISU}

--E2
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,500)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp,tc,res,IsAttackNegated)
	if IsAttackNegated then
		Duel.BreakEffect()
		Duel.Damage(tp,500,REASON_EFFECT)
	end
end

--E3
function s.nsfilter(c)
	return c:IsSetCard(SET_DEMONISU) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local isCostChecked=e:GetLabel()==1
		e:SetLabel(0)
		local exc=isCostChecked and e:GetHandler() or nil
		return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,exc)
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end