
--[[
USE:
	Just require"vis.info"() to set this creates the info command
	You can set the first parameter to the name you wihich to set it to
DESC:
	"Command for fetching state of vis (better than help would do)"
AUTHOR:
	Nomarian
]]

-- luacheck: globals vis
local vis = vis
local M = {}

M.divider = "----------------"

-- invert values to keys
local modes = {} for k,v in pairs(vis.modes) do modes[v] = k end

local F = string.format

local function Section(name, T)
	local splitter = "\n\t"
	return
		"\n" .. M.divider .. " " .. name .. " " .. M.divider .. "\n"
		.. splitter .. table.concat(T, splitter)
end

local function Command(argv, force, win, selection, range)
	local file = win.file
	local R = table.concat({
		-- F("Version: %s", vis.VERSION) -- :help gives you the version
		"Filename: " .. (win.file.name or "")
		, F("Syntax: %s", win.syntax)
		, F("Count: %s", vis.count) -- what even is this?
		, F("Mark: %s", vis.mark)
		, F("Mode: %s", modes[vis.mode])
		, "Pos: " .. selection.pos
		, range and F("Range: %d-%d", range.start, range.finish)
			or "Range: NONE"
		, F("Height: %d", win.height)
		, F("Width: %d", win.width)
		, F("Recording: %s", vis.recording)
		, F("Register: %s", vis.register)

		, Section("UI", {
			  F("Colors: %d", vis.ui.colors)
			, F("layout.Horizontal: %d", vis.ui.layouts.HORIZONTAL)
			, F("layout.Vertical: %d", vis.ui.layouts.VERTICAL)
		})

		, Section("OPTIONS", {
			F("Autoindent: %s", vis.options.autoindent)
			, F("Changecolors: %s", vis.options.changecolors)
			, F("Escdelay: %d", vis.options.escdelay)
			, F("Ignorecase: %s", vis.options.ignorecase)
			, F("Loadmethod: %s", vis.options.loadmethod)
			, F("Shell: %s", vis.options.shell)
		})

		, Section("win.file", {
			F("Lines: %d", file.lines and #file.lines or 0)
			, F("Modified: %s", file.modified)
			, F("Name: %s", file.name or "")
			, F("Path: %s", file.path or "")
			, F("Perm: %s", file.permission)
			, F("SaveMethod: %s", file.savemethod)
			, F("Size: %d", file.size or 0)
		})

	}, "\n")

	vis:message(R)
	return true
end
M.Command = Command

local function Register(name)
	vis:command_register(
		type(name)=='string' and name or "info"
		, Command
		, "Displays information of current window"
	)
end
M.Register = Register

-- so apparently, for some reason, you can't require"vis.info"() because
-- it somehow is doing require"vis.info":Register() FOR SOME REASON
local function Call(a,b)
	Register(a~=M and a or b~=M and b or nil)
	return M
end

return setmetatable(M, {
	__newindex = error
	, __call = Call
})

--[[
TODO:

	if FORCE (or some arg?) then iterate over all windows
	Which means vis. takes precedence and then everything else is iterated over

	vis.input_queue	Currently unconsumed keys in the input queue.
	vis:files()	Create an iterator over all files.
	vis:mappings(mode)	Get all currently active mappings of a mode.
	vis:mark_names()	Create an iterator over all mark names.
	vis:register_names()	Create an iterator over all register names.
	vis:windows()	Create an iterator over all windows.

	window.marks	Window marks.
	window.options	Window Options
	window.selection	The primary selection of this window.
	window.selections	The selections of this window.
	window:selections_iterator()	Create an iterator over all selections of this window.

	selection.anchored	Whether this selection is anchored.
	selection.col	The 1-based column position the cursor of this selection resides on.
	selection.line	The 1-based line the cursor of this selection resides on.
	selection.number	The 1-based selection index.
	selection.pos	The zero based byte position in the file.
	selection.range	The range covered by this selection.

	file:mark_get(mark)	Get position of mark.

	--		, F("Registers: %s", vis.registers) -- ??
--]]
