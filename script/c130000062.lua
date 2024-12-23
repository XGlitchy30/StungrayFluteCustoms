--[[
Brotherhood of the Fire Fist - Crocodile
Card Author: AuroraUline
Scripted by: XGlitchy30
]]

local s,id = GetID()
Duel.LoadScript("glitchylib_new.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--You can only control 1 "Brotherhood of the Fire Fist - Crocodile".
	c:SetUniqueOnField(1,0,id)
	--2 Beast-Warrior monsters, including a "Fire Fist" monster
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)
	--[[If this card is Fusion Summoned: You can banish 1 "Fire Fist" monster from your GY; other "Fire Fist" monsters you control gain ATK equal to the banished monster's
	Level x 100 while you control this card.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(xgl.FusionSummonedCond,xgl.LabelCost,s.atktg,s.atkop)
	c:RegisterEffect(e1)
	--[[When this card is sent to the GY: You can target 1 "Fire Formation" Spell/Trap you control; send it to the GY, and if you do, draw 1 card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.tgtg,s.tgop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_FIRE_FIST}
s.material_setcode={SET_FIRE_FIST}

function s.ffilter(c,fc,sumtype,sp,sub,mg,sg)
	return c:IsRace(RACE_BEASTWARRIOR,fc,sumtype,sp) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:IsExists(Card.IsSetCard,1,c,SET_FIRE_FIST,fc,sumtype,sp))
end

--E1
function s.rmfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_FIRE_FIST) and c:IsLevelAbove(1) and c:IsAbleToRemoveAsCost()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExists(false,s.rmfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	e:SetLabel(0)
	local tc=Duel.Select(HINTMSG_REMOVE,false,tp,s.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc then
		local lv=tc:GetLevel()
		Duel.SetTargetParam(lv)
		Duel.Remove(tc,POS_FACEUP,REASON_COST)
		local g=Duel.Group(aux.FaceupFilter(Card.IsSetCard,SET_FIRE_FIST),tp,LOCATION_MZONE,0,e:GetHandler())
		if #g>0 then
			Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0,lv*100)
		else
			Duel.SetPossibleCustomOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,LOCATION_MZONE,lv*100)
		end
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		local lv=Duel.GetTargetParam()
		if lv<=0 then return end
		local val=lv*100
		c:UpdateATKField(val,LOCATION_MZONE,LOCATION_MZONE,0,s.atkfilter,nil,RESET_EVENT|RESETS_STANDARD,c,EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,0,0,aux.Stringid(id,2))
		c:SetHint(CHINT_NUMBER,val)
	end
end
function s.atkfilter(e,c)
	return c:IsSetCard(SET_FIRE_FIST) and c~=e:GetHandler()
end

--E2
function s.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_FIRE_FORMATION) and c:IsSpellTrap() and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	aux.DrawInfo(tp,1)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end