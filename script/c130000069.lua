--[[
Hieratic Awakening
Card Author: ExaltedDawn
Scripted by: XGlitchy30
]]

local s,id=GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	--[[This card is used to Ritual Summon "Hieratic Dragon Priest of Anub". You must also Tribute monsters from your hand or field whose total Levels equal or exceed the Level of the Ritual Monster
	you Ritual Summon.]]
	Ritual.AddProcGreater(c,s.ritualfil)
	--[[You can banish this card from your GY; add 1 "Hieratic" card from your face-up Extra Deck or GY to your hand, also you cannot Special Summon monsters for the rest of this turn, except
	"Hieratic" monsters.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		xgl.CreateCost(xgl.LabelCost,aux.bfgcost),
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e1)
end
s.listed_series={SET_HIERATIC}
s.fit_monster={130000068}

function s.ritualfil(c)
	return c:IsCode(130000068) and c:IsRitualMonster()
end

--E1
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(SET_HIERATIC) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local exc=e:GetLabel()==1 and e:GetHandler() or nil
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,exc)
	end
	e:SetLabel(0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(id,1)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splim)
	Duel.RegisterEffect(e1,tp)
end
function s.splim(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(SET_HIERATIC)
end