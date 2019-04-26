local pulseaudio = require("pulseaudio")

local get_sinks_indexed = function()
	local sinks = {}
	local all_sinks = pulseaudio.get_sinks()
	for index in pairs(all_sinks) do
		if type(index) == "number" then
			sinks[index] = all_sinks[index]
		end
	end
	return sinks
end

local Pulseaudio = {}
Pulseaudio = function(settings)
	if type(settings) ~= 'table' then
		settings = {}
	end
	setmetatable(settings, {
		__index = {
			sink_device = {
				volume_step = 5,
				volume_max = 100
			},
			source_device = {
				volume_step = 5,
				volume_max = 100
			},
		}
	})
	local ret = {}
	ret.volume_up = function()
		for _, sink in pairs(get_sinks_indexed()) do
			if sink.default then
				local volume_to_set = math.min(sink.volume + settings.sink_device.volume_step, settings.sink_device.volume_max)
				return pulseaudio.set_sink_volume(sink.index, {volume = volume_to_set})
			end
		end
	end
	ret.volume_down = function()
		for _, sink in pairs(get_sinks_indexed()) do
			if sink.default then
				local volume_to_set = math.max(sink.volume - settings.sink_device.volume_step, 0)
				return pulseaudio.set_sink_volume(sink.index, {volume = volume_to_set})
			end
		end
	end
	ret.toggle_muted = function()
		for _, sink in pairs(get_sinks_indexed()) do
			if sink.default then
				return pulseaudio.set_sink_volume(sink.index, {mute = not sink.mute})
			end
		end
	end
	ret.cycle_sinks = function()
		for _, sink in pairs(get_sinks_indexed()) do
			if not sink.default then
				sink.index = math.floor(sink.index)
				if not pulseaudio.set_default_sink(sink.index) then
					print("failed setting " .. sink.index .. " as default sink")
					return false
				end
			end
		end
		for _, sink in pairs(get_sinks_indexed()) do
			if sink.default then
				for _, sink_input in pairs(pulseaudio.get_sink_inputs()) do
					sink_input.index = math.floor(sink_input.index)
					if not pulseaudio.move_sink_input(sink_input.index, sink.index) then
						print("failed to move sink input ".. sink_input.index .. " to sink indexed " .. sink.index)
						return false
					end
					print("moved sink input ".. sink_input.index .. " to sink indexed " .. sink.index)
				end
				return true
			end
		end
	end

	ret.volume_up_mic = function()
		-- not implemented
	end
	ret.volume_down_mic = function()
		-- not implemented
	end
	ret.toggle_muted_mic = function()
		-- not implemented
	end
	ret.cycle_sources = function()
		-- not implemented
	end
	return ret
end

return Pulseaudio
