--[[Differently from the regular SelectUnselectLoop, now rescon can also be used to define a razor filter that will restrict which members of (mg) can be added to the current subgroup]]
function Glitchy.SelectUnselectLoop(c,sg,mg,e,tp,minc,maxc,rescon)
	local res=not rescon
	if #sg>=maxc then return false end
	local mg2=mg:Clone()
	sg:AddCard(c)
	local razor
	if rescon then
		local stop
		res,stop,razor=rescon(sg,e,tp,mg2,c)
		if stop then
			sg:RemoveCard(c)
			return false
		end
	end
	
	if razor then
		if type(razor)=="table" then
			local razorfunc=razor[1]
			table.remove(razor,1)
			mg2:Match(razorfunc,nil,table.unpack(razor))
		else
			mg2:Match(razor,nil)
		end
	end
	
	if #sg<minc then
		res=mg2:IsExists(Glitchy.SelectUnselectLoop,1,sg,sg,mg2,e,tp,minc,maxc,rescon)
	elseif #sg<maxc and not res then
		res=mg2:IsExists(Glitchy.SelectUnselectLoop,1,sg,sg,mg2,e,tp,minc,maxc,rescon)
	end
	sg:RemoveCard(c)
	return res
end

--[[Function to check the existence and to select subgroups of (g) that satisfy a certain (rescon)
Hybrid method for selecting and unselecting cards from a group (g).
The method dynamically switches between two selection approaches depending on the group size:
- The regular Auxiliary.SelectUnselectGroup is used for small groups (when the group size is below a threshold).
- The Glitchy implementation is used for large groups (when the group size exceeds the threshold).

**Parameters:**
  g (Group): The group of cards from which a selection is being made.
  e (Effect): The effect triggering the selection.
  tp (Player): The player whose cards are being selected.
  minc (integer): The minimum number of cards required in the selected group.
  maxc (integer): The maximum number of cards allowed in the selected group.
  rescon (function): A function that checks the validity of a subgroup based on the current selection.
  chk (integer): A flag used for the check phase (0 or 1).
  seltp (integer): Selecting player.
  hintmsg (integer): The message type for hinting.
  finishcon (function): A function to check if the current group is finishable.
  breakcon (function): A function that checks whether the loop should break.
  cancelable (boolean): Whether the selection can be canceled.
  firstElementFilter (function): If this filter is defined, it forces the check/selection to start from an element of the group that satisfies the filter's condition

**Return:**
  The selected group (Group) of cards that satisfies the conditions defined by `minc`, `maxc`, and `rescon` (if chk==1), or whether a valid subgroup exists (if chk==0)

**Steps
1) (g) is cloned into (eg)
2) The first member (c0) of (eg) is passed to rescon, and the latter is evaluated (sg is the current subgroup being built and checked, while mg is the group of available members that can still be added to the current subgroup)
3) Regardless of the result, another member is taken from (eg) and is evaluated. This process repeats until the subgroup reaches the minimum size AND satisfies rescon. If the subgroup reaches the maximum size and it still does NOT satisfy rescon, then the member (c0) is removed from (eg) and the process starts again from STEP 2 with the next member of (eg): note that the previous (c0) will not be able to be added to any subgroup from that point onwards
4) If rescon returns a second false, the subgroup creation abrupts immediately and the check is failed. (c0) is removed from (eg) and the process starts again from STEP 2 with the next member of (eg): note that the previous (c0) will not be able to be added to any subgroup from that point onwards.

The rescon function is expected to return three possible outputs:
1) Boolean: The first return value indicates whether the current subgroup (sg) is valid or not.
2) Boolean: The second return value is a flag (stop) that determines if the subgroup selection process should be halted immediately. If stop is true, the current selection process is stopped, and the function backtracks.
3) Optional Value (razor): The third return value is an optional value, which can either be a function, a table, or nil. If provided, it allows for additional modifications or pruning of the group. Specifically:
	- A function (razorfunc): This function can be used to prune the remaining candidates for selection based on some criteria. It applies a filtering function to mg2 (the candidate group) to narrow down the possible selections further.
	- A table (razor): If a table is returned, the first element is expected to be the pruning function, while the remaining ones are the parameters required by such function
	- nil: If razor is nil, no further pruning or filtering is applied.
]]

GLITCHY_LARGE_GROUP_THRESHOLD_STRICT = 6

local function ApplyDelta(group,delta)
    for card in aux.Next(delta.added) do group:AddCard(card) end
    for card in aux.Next(delta.removed) do group:RemoveCard(card) end --for futureproofing
end
function Glitchy.SelectUnselectGroup(customLargeGroupThreshold,g,e,tp,minc,maxc,rescon,chk,seltp,hintmsg,finishcon,breakcon,cancelable,firstElementFilter)
	if type(customLargeGroupThreshold)=="Group" then
		g,e,tp,minc,maxc,rescon,chk,seltp,hintmsg,finishcon,breakcon,cancelable=customLargeGroupThreshold,g,e,tp,minc,maxc,rescon,chk,seltp,hintmsg,finishcon,breakcon
		customLargeGroupThreshold=nil
	end

	local LARGE_GROUP_SIZE = customLargeGroupThreshold or 16
	
	--Use regular auxiliary for small groups
	if #g<LARGE_GROUP_SIZE then
		return aux.SelectUnselectGroup(g,e,tp,minc,maxc,rescon,chk,seltp,hintmsg,finishcon,breakcon,cancelable)
	end
	
	local minc=minc or 1
	local maxc=maxc or #g
	if chk==0 then
		if #g<minc then return false end
		local eg=g:Clone()
		if firstElementFilter then
			local typ=type(firstElementFilter)
			if typ=="function" then
				local fg=g:Filter(firstElementFilter,nil,e,tp)
				for c in aux.Next(fg) do
					if Glitchy.SelectUnselectLoop(c,Group.CreateGroup(),eg,e,tp,minc,maxc,rescon) then return true end
					eg:RemoveCard(c)
				end
				return false
			elseif typ=="Card" then
				if Glitchy.SelectUnselectLoop(firstElementFilter,Group.CreateGroup(),eg,e,tp,minc,maxc,rescon) then return true end
				eg:RemoveCard(firstElementFilter)
				return false
			end
		else
			for c in aux.Next(g) do
				if Glitchy.SelectUnselectLoop(c,Group.CreateGroup(),eg,e,tp,minc,maxc,rescon) then return true end
				eg:RemoveCard(c)
			end
		end
		return false
	end
	local hintmsg=hintmsg or 0
	local sg=Group.CreateGroup()
	local history={}
	local deltas={}
	local g2=g:Clone()
	while true do
		local finishable = #sg>=minc and (not finishcon or finishcon(sg,e,tp,g2))
		local mg=g2:Filter(Glitchy.SelectUnselectLoop,sg,sg,g2,e,tp,minc,maxc,rescon)
		if (breakcon and breakcon(sg,e,tp,mg)) or #mg<=0 or #sg>=maxc then break end
		local selg=mg
		if firstElementFilter and #sg==0 then
			local typ=type(firstElementFilter)
			if typ=="function" then
				selg=mg:Filter(firstElementFilter,nil,e,tp)
			elseif typ=="Card" then
				selg=Group.FromCards(firstElementFilter)
			end
		end
		Duel.Hint(HINT_SELECTMSG,seltp,hintmsg)
		local tc=selg:SelectUnselect(sg,seltp,finishable,finishable or (cancelable and #sg==0),minc,maxc)
		if not tc then break end
		if sg:IsContains(tc) then
			while true do
				local tc2=table.remove(history)
				sg:RemoveCard(tc2)
				local lastDelta = table.remove(deltas)
				ApplyDelta(g2, { added = lastDelta.removed, removed = lastDelta.added })
				if tc2==tc then
					break
				end
			end
		else
			sg:AddCard(tc)
			
			if rescon then
				local delta = { added = Group.CreateGroup(), removed = Group.CreateGroup() }	--delta.added just for futureproofing
				table.insert(deltas, delta)

				
				table.insert(history,tc)
				local _,_,razor=rescon(sg,e,tp,mg,tc)
				if razor then
					if type(razor)=="table" then
						local razorfunc=razor[1]
						table.remove(razor,1)
						g2:Match(razorfunc,nil,table.unpack(razor))
					else
						g2:Match(razor,nil,sg,e,tp,mg)
					end
					delta.removed = g:Filter(function(card) return not g2:IsContains(card) end, nil)
				end
			end
		end
	end
	return sg
end


--SelectUnselectGroup aux functions
function Auxiliary.dncheckbrk(g,e,tp,mg,c)
	local res=g:GetClassCount(Card.GetCode)==#g
	return res, not res
end
function Glitchy.dncheck(g,e,tp,mg,c)
    local valid = g:GetClassCount(Card.GetCode)==#g
    local razor = {aux.NOT(Card.IsCode),c:GetCode()}
    return valid,false,razor
end

function Auxiliary.sncheck(g)
	return g:GetClassCount(Card.GetCode)==1
end

function Auxiliary.ogdncheckbrk(g,e,tp,mg,c)
	local res=g:GetClassCount(Card.GetOriginalCodeRule)==#g
	return res, not res
end

function Glitchy.dloccheck(g,e,tp,mg,c)
    local valid = g:GetClassCount(Card.GetLocation)==#g
    local razor = {aux.NOT(Card.IsLocation),c:GetLocation()}
    return valid,false,razor
end
function Glitchy.dloccheck_field(g,e,tp,mg,c)
    local valid = g:GetClassCount(Card.GetLocationSimple)==#g
    local razor = {aux.NOT(Card.IsLocation),c:GetLocationSimple()}
    return valid,false,razor
end

--Group logical operations
function Group.Intersection(g1,...)
	local groups={...}
	local g=g1:Clone()
	for _,group in ipairs(groups) do
		for tc in group:Iter() do
			if not g:IsContains(tc) then
				g:RemoveCard(tc)
			end
		end
	end
	return g
end