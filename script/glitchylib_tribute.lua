EFFECT_ADD_EXTRA_TRIBUTE_GLITCHY = 3000

STRING_ASK_TRIBUTE_FROM_DECK = aux.Stringid(130000000,1)

function Auxiliary.RegisterSpecialTributeSummon(c)
	if not aux.register_special_tribute_summon_check then
		aux.register_special_tribute_summon_check=true
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(130000000,0))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetRange(0xff)
		e1:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
		e1:SetCondition(Auxiliary.SpecialNormalSummonCondition())
		e1:SetTarget(Auxiliary.SpecialNormalSummonTarget())
		e1:SetOperation(Auxiliary.SpecialNormalSummonOperation())
		e1:SetValue(SUMMON_TYPE_TRIBUTE)
		c:RegisterEffect(e1,true)
	end
end
function Auxiliary.SpecialNormalSummonCondition()
	return function (e,c,minc,zone,relzone,exeff)
		if c==nil then return true end
		local tp=c:GetControler()
		
		local toreset={}
		for _,ce in ipairs({c:IsHasEffect(EFFECT_ADD_EXTRA_TRIBUTE_GLITCHY)}) do
			local val=ce:GetValue()
			local f,loc1,loc2,pos=val(ce,c)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
			e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
			e1:SetTargetRange(loc1,loc2)
			e1:SetTarget(f)
			e1:SetValue(pos)
			c:RegisterEffect(e1)
			table.insert(toreset,e1)
		end
		
		local min,max=c:GetTributeRequirement()
		local mg=Duel.GetTributeGroup(c)
		if relzone~=0xff00ff then
			mg:Match(Auxiliary.IsZone,nil,relzone,tp)
		end
		local res=min>0 and minc<=min and Duel.CheckTribute(c,min,max,mg,tp,zone)
		
		for _,ce in ipairs(toreset) do
			ce:Reset()
		end
		return res
	end
end
function Auxiliary.SpecialNormalSummonTarget()
	return function (e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
		if c==nil then return true end
		
		local toreset={}
		for _,ce in ipairs({c:IsHasEffect(EFFECT_ADD_EXTRA_TRIBUTE_GLITCHY)}) do
			local val=ce:GetValue()
			local f,loc1,loc2,pos=val(ce,c)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
			e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
			e1:SetTargetRange(loc1,loc2)
			e1:SetTarget(f)
			e1:SetValue(pos)
			c:RegisterEffect(e1)
			table.insert(toreset,e1)
		end
		
		local min,max=c:GetTributeRequirement()
		local mg=Duel.GetTributeGroup(c)
		if relzone~=0xff00ff then
			mg:Match(Auxiliary.IsZone,nil,relzone,tp)
		end
		
		for _,ce in ipairs(toreset) do
			ce:Reset()
		end
		
		local g=Group.CreateGroup()
		local decktributes=mg:Filter(Card.IsLocation,nil,LOCATION_DECK)
		if #decktributes>0 and (#mg-#decktributes<min or Duel.SelectYesNo(tp,STRING_ASK_TRIBUTE_FROM_DECK)) then
			local minc=#mg-#decktributes<min and min-#mg+#decktributes or 1
			Duel.HintMessage(tp,HINTMSG_RELEASE)
			local dg=decktributes:Select(tp,1,max,nil)
			if #dg>0 then
				min=min-#dg
				max=max-#dg
				g:Merge(dg)
				mg:Sub(dg)
			end
		end
		if min>0 then
			local rg=Duel.SelectTribute(tp,c,min,max,mg,tp,zone,Duel.IsSummonCancelable())
			if rg and #rg>0 then
				g:Merge(rg)
			else
				return false
			end
		end
		if #g>0 then
			g:KeepAlive()
			e:SetLabelObject(g)
			return true
		end
		return false
	end
end
function Auxiliary.SpecialNormalSummonOperation()
	return function (e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
		local g=e:GetLabelObject()
		c:SetMaterial(g)
		local decktributes=g:Filter(Card.IsLocation,nil,LOCATION_DECK)
		if #decktributes>0 then
			Duel.SendtoGrave(decktributes,REASON_SUMMON|REASON_MATERIAL|REASON_RELEASE)
			g:Sub(decktributes)
		end
		Duel.Release(g,REASON_SUMMON|REASON_MATERIAL)
		g:DeleteGroup()
	end
end

function maplevel(level)
	if level>=5 and level<=6 then
		return 1
	elseif level>=7 then
		return 2
	end
	return 0
end
function Auxiliary.NormalSummonCondition1(min,max,f,opt)
	return function (e,c,minc,zone,relzone,exeff)
		if c==nil then return true end
		local tp=c:GetControler()
		
		local toreset={}
		for _,ce in ipairs({c:IsHasEffect(EFFECT_ADD_EXTRA_TRIBUTE_GLITCHY)}) do
			local val=ce:GetValue()
			local f,loc1,loc2,pos=val(ce,c)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
			e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
			e1:SetTargetRange(loc1,loc2)
			e1:SetTarget(f)
			e1:SetValue(pos)
			c:RegisterEffect(e1)
			table.insert(toreset,e1)
		end
		
		local mg=Duel.GetTributeGroup(c)
		if relzone~=0xff00ff then
			mg:Match(Auxiliary.IsZone,nil,relzone,tp)
		end
		if f then
			mg:Match(f,nil,tp)
		end
		local tributes=maplevel(c:GetLevel())
		local res=(not opt or (tributes>0 and tributes~=max)) and minc<=min and Duel.CheckTribute(c,min,max,mg,tp,zone)
		
		for _,ce in ipairs(toreset) do
			ce:Reset()
		end
		return res
	end
end

function Auxiliary.NormalSummonTarget(min,max,f)
	return function (e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
		
		local toreset={}
		for _,ce in ipairs({c:IsHasEffect(EFFECT_ADD_EXTRA_TRIBUTE_GLITCHY)}) do
			local val=ce:GetValue()
			local f,loc1,loc2,pos=val(ce,c)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
			e1:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
			e1:SetTargetRange(loc1,loc2)
			e1:SetTarget(f)
			e1:SetValue(pos)
			c:RegisterEffect(e1,true)
			table.insert(toreset,e1)
		end
				
		local mg=Duel.GetTributeGroup(c)
		if relzone~=0xff00ff then
			mg:Match(Auxiliary.IsZone,nil,relzone,tp)
		end
		if f then
			mg:Match(f,nil,tp)
		end
		
		for _,ce in ipairs(toreset) do
			ce:Reset()
		end
		
		local g=Group.CreateGroup()
		local decktributes=mg:Filter(Card.IsLocation,nil,LOCATION_DECK)
		if #decktributes>0 and (#mg-#decktributes<min or Duel.SelectYesNo(tp,STRING_ASK_TRIBUTE_FROM_DECK)) then
			local minc=#mg-#decktributes<min and min-#mg+#decktributes or 1
			Duel.HintMessage(tp,HINTMSG_RELEASE)
			local dg=decktributes:Select(tp,minc,max,nil)
			if #dg>0 then
				min=min-#dg
				max=max-#dg
				g:Merge(dg)
				mg:Sub(dg)
			end
		end
		if min>0 then
			local rg=Duel.SelectTribute(tp,c,min,max,mg,tp,zone,Duel.IsSummonCancelable())
			if rg and #rg>0 then
				g:Merge(rg)
			else
				return false
			end
		end
		if #g>0 then
			g:KeepAlive()
			e:SetLabelObject(g)
			return true
		end
		return false
	end
end

function Auxiliary.NormalSummonOperation(min,max,sumop)
	return function (e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
		local g=e:GetLabelObject()
		c:SetMaterial(g)
		local decktributes=g:Filter(Card.IsLocation,nil,LOCATION_DECK)
		if #decktributes>0 then
			Duel.SendtoGrave(decktributes,REASON_SUMMON|REASON_MATERIAL|REASON_RELEASE)
			g:Sub(decktributes)
		end
		Duel.Release(g,REASON_SUMMON|REASON_MATERIAL)
		if sumop then
			sumop(g:Clone(),e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
		end
		g:DeleteGroup()
	end
end