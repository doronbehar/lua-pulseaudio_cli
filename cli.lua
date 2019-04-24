#!/usr/bin/env lua
local Pulseaudio = require('pulseaudio_cli')

-- Remember to install rock lua_cliargs for this to work!
local cli = require('cliargs')
cli:set_name(arg[0])
cli:set_description("Lua based pulseaudio CLI controller")
cli:argument('cmd', "Sub command to run ('up', 'down', 'cycle', 'mute')")
cli:splat("step", "step in which to increase or decrease the volume", "5", 1)
local args, err = cli:parse()
if not args and err then
	print(err)
	return cli:print_usage()
elseif args then
	local pulseaudio = Pulseaudio({
		sink_device = {
			volume_step = args.step,
			volume_max = 100
		},
		source_device = {
			volume_step = args.step,
			volume_max = 100
		}
	})
	if args.cmd == "down" or args.cmd == "up" then
		return pulseaudio["volume_" .. args.cmd]()
	elseif args.cmd == "cycle" then
		return pulseaudio.cycle_sinks()
	elseif args.cmd == "mute" then
		return pulseaudio.toggle_muted()
	end
end
