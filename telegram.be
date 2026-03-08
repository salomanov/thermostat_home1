def TGset()
    var tgst = string.tolower(tasmota.cmd("TmToken")["TmToken"])
    if tgst == ""
    tasmota.cmd("Backlog TmToken 8140788144:AAGz3abBnvx5xgasgxzdjUlVuK4iYHb2lII; TmState 3; TmChatId -1003440808339; TmState 1")
    persist.track = 0
    end
end

TGset()


def telegram_info()
   var result_str = tasmota.read_sensors() # Получаем строку JSON.
  var result_obj = json.load(result_str)  # Парсим строку в объект Berry.
     if result_obj != nil

       # Извлекаем данные SI7021.
       var bme_data = result_obj["SI7021"] # В top-level объекте от read_sensors.
       if bme_data != nil
         var temp = bme_data["Temperature"]
         var hum = bme_data["Humidity"]
         var pow = tasmota.get_power()[1]
         var total_second
         var target_temp = persist.target_temp != nil ? persist.target_temp : 20

        if pow
            total_second = tasmota.rtc()["local"] - (persist.heat_time_start ? persist.heat_time_start : tasmota.rtc()["local"])
        else total_second = tasmota.rtc()["local"] - (persist.heat_time_end ? persist.heat_time_end : tasmota.rtc()["local"])
        end

        def tmc(ts)
            if ts == nil
              ts = 0
            end
            var days = ts / 86400
            var remaining = ts % 86400
            var hours = remaining / 3600
            var minutes = (remaining % 3600) / 60
            var msg = (days ? str(days) + " дн. " : "") + (hours ? str(hours) + " час. " : "") + (minutes ? str(minutes) + " мин." : "")
            if msg == ""
              msg = "0 мин."
            end
            return msg
        end

         var response_text =
                             "🌡 " + str(temp) + "/" + str(target_temp) + " °C " +
                             "💦 " + str(hum) + " % " +
                            (pow ? "🔥 Нагревается " + tmc(total_second) + " 📉 Остыло за " + tmc(persist.cooling_time_duration) : "❄️ Остывает " + tmc(total_second) + " 📈 Нагрелось за " + tmc(persist.heat_time_duration))

         # Отправляем форматированный текст обратно в Telegram.
         tasmota.cmd("TmSend " + response_text)
       else
         # Обработка случая, если данные SI7021 отсутствуют.
         tasmota.cmd("TmSend Данные SI7021 недоступны.")
         tasmota.resp_cmnd_error()
       end
     else
       # Обработка случая, если не удалось распарсить JSON.
       tasmota.cmd("TmSend Ошибка при получении данных сенсора.")
       tasmota.resp_cmnd_error()
     end
end

def temp_min_max(cmd, idx, value)
  var fallback_temp = persist.target_temp != nil ? persist.target_temp : 20
  if cmd == 'MIN'
      if real(value)
      persist.temp_min = value
      end
      persist.target_temp = persist.temp_min != nil ? persist.temp_min : fallback_temp
      tasmota.cmd("TempTargetSet " + str(persist.target_temp))
  elif cmd == 'MAX'
      if real(value)
      persist.temp_max = value
      end
      persist.target_temp = persist.temp_max != nil ? persist.temp_max : fallback_temp
      tasmota.cmd("TempTargetSet " + str(persist.target_temp))
  end
persist.save()
end


def tele_sensor(si7021_data)
  var temp = si7021_data["Temperature"]
  if persist.temp != temp
    persist.temp = temp
    tasmota.cmd("TmSend 🏠 " + str(temp) + " °C")
  end
end

# Привязка к событию Tele#SI7021.
tasmota.add_rule("Tele#SI7021", tele_sensor, "heater_control")

tasmota.add_cmd('TERMO', telegram_info)
print("Команда INFO добавлена для получения данных.")

tasmota.add_cmd('MIN', temp_min_max)
print("Команда T_MIN добавлена для получения данных.")

tasmota.add_cmd('MAX', temp_min_max)
print("Команда T_MAX добавлена для получения данных.")
