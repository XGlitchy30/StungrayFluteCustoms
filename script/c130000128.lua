--[[
Demonisu Throne
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--Equip only to a Level 5 or higher "Demonisu" monster.
	aux.AddEquipProcedure(c,nil,s.eqfilter)
	--If it would be destroyed by a card effect, destroy this card instead.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	e1:SetValue(s.desval)
	c:RegisterEffect(e1)
	--[[If the equipped monster attacks: You can send 1 "Demonisu" monster from your hand to the GY; the equipped monster gains 1000 ATK until the end of the Battle Phase]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:HOPT()
	e2:SetFunctions(
		s.atkcon,
		xgl.ToGraveCost(xgl.MonsterFilter(Card.IsSetCard,SET_DEMONISU),LOCATION_HAND),
		s.atktg,
		s.atkop
	)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DEMONISU}

function s.eqfilter(c)
	return c:IsSetCard(SET_DEMONISU) and c:IsLevelAbove(5)
end

--E1
function s.desval(e,re,r,rp)
	return r&REASON_EFFECT~=0
end

--E2
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler():GetEquipTarget()
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_DEMONISU)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetHandler():GetEquipTarget()
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,tp,1000)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		local tc=c:GetEquipTarget()
		if tc then
			tc:UpdateATK(1000,RESET_PHASE|PHASE_BATTLE,c,true)
		end
	end
end