

def work_power(value)
    if value
        persist.heat_time_start = tasmota.rtc()["local"]
        if persist.heat_time_end != nil
            persist.cooling_time_duration = persist.heat_time_start - persist.heat_time_end
         end
         if persist.track
            tasmota.cmd('TERMO')
         end
    else persist.heat_time_end = tasmota.rtc()["local"]
        if persist.heat_time_start != nil
            persist.heat_time_duration = persist.heat_time_end - persist.heat_time_start
        end
        if persist.track
            tasmota.cmd('TERMO')
        end
    end
end

tasmota.add_rule("Power2#State", work_power, "work_power1")
print("Правило для отслеживания нагрева")

def work_set()
    if persist.button
    persist.button = 0
    temp_min_max('MAX')
    else 
    persist.button = 1
    temp_min_max('MIN')
    end
end


def track_power()
     persist.track = ! persist.track
      tasmota.cmd("TmSend " +  ( persist.track  ? "Следим " : "Не следим"))
  
end


tasmota.add_cmd('TRACK', track_power)
print("Команда TRACK добавлена для получения данных.")

tasmota.add_rule("Button1#state", work_set, "Button_change")
print("Правило для отслеживания Button1")