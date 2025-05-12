--[[
Demonisu Feathers
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
	--[[If your opponent's monster declares an attack involving this card: You can return this card to your hand; negate the attack, then gain 1000 LP]]
	Demonisu.RegisterAttackNegate(c,id,CATEGORY_RECOVER,s.negtg,s.negop)
	--[[If you control a "Demonisu" monster: You can discard this card, then target 1 face-up monster your opponent controls; negate its effects until the end of this turn.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,3)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_HAND)
	e3:HOPT()
	e3:SetFunctions(
		xgl.LocationGroupCond(aux.FaceupFilter(Card.IsSetCard,SET_DEMONISU),LOCATION_MZONE,0,1),
		xgl.DiscardSelfCost,
		s.distg,
		s.disop
	)
	c:RegisterEffect(e3)
end
s.listed_series={SET_DEMONISU}

--E2
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp,tc,res,IsAttackNegated)
	if IsAttackNegated then
		Duel.BreakEffect()
		Duel.Recover(tp,1000,REASON_EFFECT)
	end
end

--E3
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp) and chkc:IsNegatableMonster() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,tp,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		tc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END)
	end
end