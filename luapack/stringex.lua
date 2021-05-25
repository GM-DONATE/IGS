local pattern_escape_replacements = {
	["("] = "%(",
	[")"] = "%)",
	["."] = "%.",
	["%"] = "%%",
	["+"] = "%+",
	["-"] = "%-",
	["*"] = "%*",
	["?"] = "%?",
	["["] = "%[",
	["]"] = "%]",
	["^"] = "%^",
	["$"] = "%$",
	["\0"] = "%z"
}

function string.PatternSafe(str)
	return (string.gsub(str, ".", pattern_escape_replacements))
end

function string.Explode(separator, str, withpattern)
	if separator == "" then return string.ToTable(str) end
	if withpattern == nil then withpattern = false end

	local ret = {}
	local current_pos = 1

	for i = 1, string.len(str) do
		local start_pos, end_pos = string.find(str, separator, current_pos, not withpattern)
		if not start_pos then break end
		ret[i] = string.sub(str, current_pos, start_pos - 1)
		current_pos = end_pos + 1
	end

	ret[#ret + 1] = string.sub(str, current_pos)

	return ret
end

function string.Split(str, delimiter)
	return string.Explode(delimiter, str)
end

