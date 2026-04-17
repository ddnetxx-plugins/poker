---@param button_offset integer # 0 is the button and 1 is the small blind see also the ButtonOffset global
---@param num_players integer # how many players are sitting at the table
---@return string long_form_position_name # Something like "Button"
local function offset_to_name(button_offset, num_players)
	if button_offset == 0 then
		return "Button"
	end

	if num_players == 2 then
		if num_players == 2 and button_offset == 1 then
			return "Big Blind"
		end
	elseif num_players == 3 then
		if button_offset == 1 then
			return "Small Blind"
		elseif button_offset == 2 then
			return "Big Blind"
		end
	elseif num_players == 4 then
		if button_offset == 1 then
			return "Small Blind"
		elseif button_offset == 2 then
			return "Big Blind"
		elseif button_offset == 3 then
			-- could also be UTG not sure
			return "Cutoff"
		end
	elseif num_players == 5 then
		if button_offset == 1 then
			return "Small Blind"
		elseif button_offset == 2 then
			return "Big Blind"
		elseif button_offset == 3 then
			return "Under the Gun"
		elseif button_offset == 4 then
			return "Cutoff"
		end
	end

	-- With 6 or more players UTG is always offset 2
	-- and the last 3 should not overlap with the first 3


	if button_offset == 1 then
		return "Small Blind"
	elseif button_offset == 2 then
		return "Big Blind"
	elseif button_offset == 3 then
		return "Under the Gun"
	end

	if button_offset == num_players - 1 then
		return "Cutoff"
	elseif button_offset == num_players - 2 then
		return "Hijack"
	elseif button_offset == num_players - 3 then
		return "Lojack"
	elseif button_offset > 2 then
		local utg = button_offset - 3
		return "UTG+" .. utg
	end
	return "UNKNOWN"
end

---@param offset_name_long string # Something like "Button"
---@param string offset_name_short # Something like "BTN"
local function offset_long_to_short(offset_name_long)
	if offset_name_long == "Button" then
		return "BTN"
	end
	return offset_name_long
end

return {
	offset_to_name = offset_to_name,
	offset_long_to_short = offset_long_to_short,
}
