--CARD TYPE
local _IsType, _IsExactType, _GetType, _GetPreviousTypeOnField, _IsActiveType, _GetActiveType, _GetOriginalType, _IsOriginalType = Card.IsType, Card.IsExactType, Card.GetType, Card.GetPreviousTypeOnField, Effect.IsActiveType, Effect.GetActiveType, Card.GetOriginalType, Card.IsOriginalType

--If a card is in the Pendulum Zone, do not immediately assume its type is only TYPE_PENDULUM; instead allow the addition of extra card types

Card.GetType = function(c,...)
    local x={...}
    local typ = _GetType(c,...)
    if c:IsLocation(LOCATION_PZONE) and not x[2] then
        local eset={c:GetCardEffect(EFFECT_ADD_TYPE)}
        for _,e in ipairs(eset) do
            if not e:GetOperation() then
                local val=e:Evaluate(c,x[3])
                typ = typ|val
            end
        end
    end

    return typ
end
Card.IsType = function(c,typ,...)
    return c:GetType(...)&typ~=0
end
Card.IsExactType = function(c,typ,...)
    return c:GetType(...)&typ==typ
end

--OriginalType
if Glitchy.EnableOriginalTypeMods then
    Card.GetOriginalType = function(c)
        local otype=_GetOriginalType(c)
        local eset={c:GetCardEffect(EFFECT_ADD_ORIGINAL_TYPE)}
        for _,e in ipairs(eset) do
            local val=e:Evaluate(c)
            otype = otype|val
        end
        return otype
    end
    Card.IsOriginalType = function(c,typ)
        return c:GetOriginalType()&typ~=0
    end
    Card.IsMonsterCard=aux.FilterBoolFunction(Card.IsOriginalType,TYPE_MONSTER)
    Card.IsSpellCard=aux.FilterBoolFunction(Card.IsOriginalType,TYPE_SPELL)
    Card.IsTrapCard=aux.FilterBoolFunction(Card.IsOriginalType,TYPE_TRAP)
    Card.IsSpellTrapCard=aux.FilterBoolFunction(Card.IsOriginalType,TYPE_SPELL|TYPE_TRAP)

    --Fusion Material Patch
    local _IsCanBeFusionMaterial = Card.IsCanBeFusionMaterial

    Card.IsCanBeFusionMaterial = function(c,...)
        if not c:IsHasEffect(EFFECT_ADD_ORIGINAL_TYPE) then
            return _IsCanBeFusionMaterial(c,...)
        end

        local xpars={...}
        local fc = #xpars>0 and xpars[1] or nil
        local sumtype = #xpars>1 and xpars[2] or SUMMON_TYPE_FUSION
        local playerid = #xpars>2 and xpars[3] or last_tp
        if c==fc then return false end
        if c:IsStatus(STATUS_FORBIDDEN) then return false end
        
        local eset={c:GetCardEffect(EFFECT_CANNOT_BE_FUSION_MATERIAL)}
        for _,e in ipairs(eset) do
            if e:Evaluate(fc,sumtype) then
                return false
            end
        end
        local eset={c:GetCardEffect(EFFECT_CANNOT_BE_MATERIAL)}
        for _,e in ipairs(eset) do
            if e:Evaluate(fc,sumtype,playerid) then
                return false
            end
        end

        if fc then
            local eset={c:GetCardEffect(EFFECT_EXTRA_FUSION_MATERIAL)}
            if #eset>0 then
                for _,e in ipairs(eset) do
                    if e:Evaluate(fc) then
                        return true
                    end
                end
                return false
            end
        else
            if not c:IsOnField() and not c:IsMonsterCard() and not c:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL) then
                return false
            end
        end
        return true
    end
end



Card.GetPreviousTypeOnField = function(c,...)
    local typ = _GetPreviousTypeOnField(c,...)
    if c:IsPreviousLocation(LOCATION_PZONE) then
        local e=c:GetCardEffect(EFFECT_REMEMBER_PREVIOUS_TYPE)
		if e then
            typ=e:GetLabel()
        end
    end
    return typ
end
function Glitchy.EnableGlobalSavesForPreviousTypeOnField()
    local ge=Effect.GlobalEffect()
    ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
    ge:SetCode(EVENT_LEAVE_FIELD_P)
    ge:SetOperation(Glitchy.SavePreviousTypeOnField)
    Duel.RegisterEffect(ge,0)
end
function Glitchy.SavePreviousTypeOnField(e,tp,eg,ep,ev,re,r,rp)
    for c in eg:Iter() do
        if not c:IsHasEffect(EFFECT_REMEMBER_PREVIOUS_TYPE) then
            local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_UNCOPYABLE)
			e1:SetCode(EFFECT_REMEMBER_PREVIOUS_TYPE)
			e1:SetLabel(c:GetType())
			c:RegisterEffect(e1,true)
		else
			local e1=c:GetCardEffect(EFFECT_REMEMBER_PREVIOUS_TYPE)
			e1:SetLabel(c:GetType())
		end
    end
end

Effect.GetActiveType = function(e,...)
    local etype=_GetActiveType(e,...)
    if e:GetType()&0x7f0~=0 then
        if e:GetActivateLocation(LOCATION_PZONE) then
            etype=e:GetHandler():GetType()
        end
    else
        if e:GetOwner():IsLocation(LOCATION_PZONE) then
            etype=e:GetOwner():GetType()
        end
    end
    return etype
end
Effect.IsActiveType = function(e,etype,...)
    return e:GetActiveType()&etype>0
end

--Remember Monster Attributes for Trap Monsters that can be Summoned by generic effects other than their own ones
if Glitchy.EnableTrapMonsterSSMods then
    local _SpecialSummon, _SpecialSummonStep, _IsCanBeSpecialSummoned = Duel.SpecialSummon, Duel.SpecialSummonStep, Card.IsCanBeSpecialSummoned

    Card.IsCanBeSpecialSummoned = function(tc,e,sumtype,sp,ign1,ign2,...)
        if tc:IsHasEffect(EFFECT_REMEMBER_MONSTER_ATTRIBUTES) then
            local eset={tc:GetCardEffect(EFFECT_REMEMBER_MONSTER_ATTRIBUTES)}
            local eff=eset[1]
            local monster_attr=eff:Evaluate(tc)
            local mtype,attr,lv,race,atk,def=monster_attr.cardtype,monster_attr.attribute,monster_attr.level,monster_attr.race,monster_attr.atk,monster_attr.def
            local x={...}
            local sumpos = #x>0 and x[1] or POS_FACEUP
            local fp = #x>1 and x[2] or sp
            local zone = #x>2 and x[3] or 0xff
            return Duel.IsPlayerCanSpecialSummonMonster(sp,tc:GetCode(),tc:GetSetCard(),TYPE_MONSTER|mtype,atk,def,lv,race,attr,sumpos,fp,sumtype)
                and (zone==0xff or not Duel.IsExistingMatchingCard(aux.IsZone,fp,LOCATION_MZONE,0,1,nil,zone,fp))
        end
        return _IsCanBeSpecialSummoned(tc,e,sumtype,sp,ign1,ign2,...)
    end

    Duel.SpecialSummon = function(g,sumtype,sp,fp,ign1,ign2,pos,...)
        if type(g)~="Group" then g=Group.FromCards(g) end
        if not g:IsExists(Card.IsHasEffect,1,nil,EFFECT_REMEMBER_MONSTER_ATTRIBUTES) then
            return _SpecialSummon(g,sumtype,sp,fp,ign1,ign2,pos,...)
        end

        for tc in g:Iter() do
            if tc:IsHasEffect(EFFECT_REMEMBER_MONSTER_ATTRIBUTES) then
                local eset={tc:GetCardEffect(EFFECT_REMEMBER_MONSTER_ATTRIBUTES)}
                local e=eset[1]
                local monster_attr=e:Evaluate(tc)
                local mtype,attr,lv,race,atk,def=monster_attr.cardtype,monster_attr.attribute,monster_attr.level,monster_attr.race,monster_attr.atk,monster_attr.def
                if mtype then
                    tc:AddMonsterAttribute(mtype)
                end
                if attribute then
                    tc:AssumeProperty(ASSUME_ATTRIBUTE,attribute)
                end
                if lv then
                    tc:AssumeProperty(ASSUME_LEVEL,lv)
                end
                if race then
                    tc:AssumeProperty(ASSUME_RACE,race)
                end
                if atk then
                    tc:AssumeProperty(ASSUME_ATTACK,atk)
                end
                if def then
                    tc:AssumeProperty(ASSUME_DEFENSE,def)
                end
            end
            _SpecialSummonStep(tc,sumtype,sp,fp,ign1,ign2,pos,...)
            tc:AddMonsterAttributeComplete()
        end
        return Duel.SpecialSummonComplete()
    end

    Duel.SpecialSummonStep = function(tc,sumtype,sp,fp,ign1,ign2,pos,...)
        if tc:IsHasEffect(EFFECT_REMEMBER_MONSTER_ATTRIBUTES) then
            local eset={tc:GetCardEffect(EFFECT_REMEMBER_MONSTER_ATTRIBUTES)}
            local e=eset[1]
            local monster_attr=e:Evaluate(tc)
            local mtype,attr,lv,race,atk,def=monster_attr.cardtype,monster_attr.attribute,monster_attr.level,monster_attr.race,monster_attr.atk,monster_attr.def
            if mtype then
                tc:AddMonsterAttribute(mtype)
            end
            if attribute then
                tc:AssumeProperty(ASSUME_ATTRIBUTE,attribute)
            end
            if lv then
                tc:AssumeProperty(ASSUME_LEVEL,lv)
            end
            if race then
                tc:AssumeProperty(ASSUME_RACE,race)
            end
            if atk then
                tc:AssumeProperty(ASSUME_ATTACK,atk)
            end
            if def then
                tc:AssumeProperty(ASSUME_DEFENSE,def)
            end
        end
        local res=_SpecialSummonStep(tc,sumtype,sp,fp,ign1,ign2,pos,...)
        tc:AddMonsterAttributeComplete()
        return res
    end
end