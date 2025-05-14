SELECT_TARGET_ID						=	0

xgl.TargetParamsTable = {}
xgl.AncestagonPlasmatailReturns = {}

local _IsCanBeEffectTarget, _IsExistingTarget, _SelectTarget, _SetOperationInfo, _Hint, _SetLabel, _SetLabelObject, _SetTargetPlayer, _SetTargetParam = Card.IsCanBeEffectTarget, Duel.IsExistingTarget, Duel.SelectTarget, Duel.SetOperationInfo, Duel.Hint, Effect.SetLabel, Effect.SetLabelObject, Duel.SetTargetPlayer, Duel.SetTargetParam

function Card.IsCanBeEffectTarget(c,e)
	xgl.AncestagonPlasmatailPreventLoop = true
	local res=_IsCanBeEffectTarget(c,e)
	xgl.AncestagonPlasmatailPreventLoop = false
	return res
end
function Duel.IsExistingTarget(f,p,loc1,loc2,min,exc,...)
	if last_chk==CHK_ANCESTAGON_PLASMATAIL then
		return false
	else
		return _IsExistingTarget(f,p,loc1,loc2,min,exc,...)
	end
end
function Duel.SelectTarget(selp,f,p,loc1,loc2,min,max,exc,...)
	if last_chk==CHK_ANCESTAGON_PLASMATAIL then
		if not xgl.TargetParamsTable[self_reference_effect] then xgl.TargetParamsTable[self_reference_effect]={} end
		local g=Group.CreateGroup()
		xgl.TargetParamsTable[self_reference_effect][g]={f,p,loc1,loc2,min,max,exc,...}
		return g
	else
		return _SelectTarget(selp,f,p,loc1,loc2,min,max,exc,...)
	end
end
function Duel.SetOperationInfo(ch,cat,g,ct,p,val)
	if last_chk==CHK_ANCESTAGON_PLASMATAIL then
		local tab
		if g and xgl.TargetParamsTable[self_reference_effect][g] then
			tab=xgl.CopyTable(xgl.TargetParamsTable[self_reference_effect][g],ct,p,val)
		else
			tab={ct,p,val}
		end
		if tab then
			table.insert(xgl.AncestagonPlasmatailReturns,{cat,tab})
		end
	else
		return _SetOperationInfo(ch,cat,g,ct,p,val)
	end
end
function Duel.Hint(typ,p,hint)
	if last_chk==CHK_ANCESTAGON_PLASMATAIL then
		return
	else
		return _Hint(typ,p,hint)
	end
end
function Effect.SetLabel(e,...)
	if last_chk==CHK_ANCESTAGON_PLASMATAIL then
		return
	else
		return _SetLabel(e,...)
	end
end
function Effect.SetLabelObject(e,...)
	if last_chk==CHK_ANCESTAGON_PLASMATAIL then
		return
	else
		return _SetLabelObject(e,...)
	end
end
function Duel.SetTargetPlayer(p)
	if last_chk==CHK_ANCESTAGON_PLASMATAIL then
		return
	else
		return _SetTargetPlayer(p)
	end
end
function Duel.SetTargetParam(p)
	if last_chk==CHK_ANCESTAGON_PLASMATAIL then
		return
	else
		return _SetTargetParam(p)
	end
end

--Raise an error if these functions are encountered (cards with these must be dealt with manually)
local _SetTargetCard, _SelectUnselectGroup, _SelectEffect, _SelectOption = Duel.SetTargetCard, aux.SelectUnselectGroup, Duel.SelectEffect, Duel.SelectOption

function Duel.SetTargetCard(g)
	if last_chk==CHK_ANCESTAGON_PLASMATAIL then
		Debug.Message("CHK_ANCESTAGON_PLASMATAIL cannot function with "..tostring(e:GetHandler():GetOriginalCode()).."- Please report to Glitchy")
		return Group.CreateGroup()
	else
		return _SetTargetCard(g)
	end
end
function Auxiliary.SelectUnselectGroup(g,e,tp,minc,maxc,rescon,chk,seltp,hintmsg,finishcon,breakcon,cancelable)
	if last_chk==CHK_ANCESTAGON_PLASMATAIL then
		Debug.Message("CHK_ANCESTAGON_PLASMATAIL cannot function with "..tostring(e:GetHandler():GetOriginalCode()).."- Please report to Glitchy")
		return Group.CreateGroup()
	else
		return _SelectUnselectGroup(g,e,tp,minc,maxc,rescon,chk,seltp,hintmsg,finishcon,breakcon,cancelable)
	end
end
function Duel.SelectEffect(p,...)
	if last_chk==CHK_ANCESTAGON_PLASMATAIL then
		Debug.Message("CHK_ANCESTAGON_PLASMATAIL cannot function with "..tostring(self_reference_effect:GetHandler():GetOriginalCode()).."- Please report to Glitchy")
		return -999
	else
		return _SelectEffect(p,...)
	end
end
function Duel.SelectOption(p,...)
	if last_chk==CHK_ANCESTAGON_PLASMATAIL then
		Debug.Message("CHK_ANCESTAGON_PLASMATAIL cannot function with "..tostring(self_reference_effect:GetHandler():GetOriginalCode()).."- Please report to Glitchy")
		return -999
	else
		return _SelectOption(p,...)
	end
end