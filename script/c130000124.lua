--[[
Demonisu Gears
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
	--[[If your opponent's monster declares an attack involving this card: You can return this card to your hand; negate the attack, then you can return 1 Spell/Trap your opponent controls to the
	hand.]]
	Demonisu.RegisterAttackNegate(c,id,CATEGORY_TOHAND,s.negtg,s.negop)
	--[[You can discard this card; add 1 "Demonisu" monster from your GY to your hand.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,3)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:HOPT()
	e3:SetFunctions(
		nil,
		xgl.CreateCost(xgl.LabelCost,xgl.DiscardSelfCost),
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e3)
end
s.listed_series={SET_DEMONISU}

--E2
function s.rtfilter(c)
	return c:IsSpellTrapOnField() and c:IsAbleToHand()
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.Group(s.rtfilter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp,tc,res,IsAttackNegated)
	if IsAttackNegated then
		local g=Duel.Group(s.rtfilter,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 and Duel.SelectYesNo(tp,STRING_ASK_RETURN_TO_HAND) then
			Duel.HintMessage(tp,HINTMSG_RTOHAND)
			local tg=g:Select(tp,1,1,nil)
			if Duel.Highlight(tg) then
				Duel.BreakEffect()
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
			end
		end
	end
end

--E3
function s.thfilter(c)
	return c:IsSetCard(SET_DEMONISU) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local isCostChecked=e:GetLabel()==1
		e:SetLabel(0)
		if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) then return true end
		local c=e:GetHandler()
		return isCostChecked and c:IsSetCard(SET_DEMONISU) and c:IsMonster() and c:IsAbleToGraveAsCost() and Duel.IsPlayerCanSendtoHandFromLocation(tp,LOCATION_GRAVE,c)
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end