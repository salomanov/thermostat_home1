def TGset()
    var tgst = string.tolower(tasmota.cmd("TmToken")["TmToken"])
    if tgst == ""
    tasmota.cmd("Backlog TmToken 8140788144:AAGz3abBnvx5xgasgxzdjUlVuK4iYHb2lII; TmState 3; TmChatId -1003440808339; TmState 1")
    persist.track = 0
    end
end

TGset()



def telegram_info()
   var result_str = tasmota.read_sensors() # Получаем строку JSON
  var  result_obj = json.load(result_str)  # Парсим строку в объект Berry
     if result_obj != nil


       # Извлекаем данные BME280
       var bme_data = result_obj["SI7021"] # В top-level объекте от read_sensors
       if bme_data != nil
         var temp = bme_data["Temperature"]
         var hum = bme_data["Humidity"]
         var dp = bme_data["DewPoint"]
                # Форматируем сообщение в красивый вид в указанном порядке
          var pow   =  tasmota.get_power()[1] 
          var total_second
        if pow
            total_second = tasmota.rtc()["local"] -  ( persist.heat_time_start  ?  persist.heat_time_start : tasmota.rtc()["local"] )
        else total_second = tasmota.rtc()["local"] -   ( persist.heat_time_end  ?  persist.heat_time_end : tasmota.rtc()["local"] )
        end
        def tmc(ts)
            var days    = ts / 86400
           var remaining = ts % 86400
           var hours   = remaining / 3600
          var  minutes = (remaining % 3600) / 60
          var msg = ( days  ? str(days) + " дн. " : "") + ( hours  ? str(hours) + " час. " : "") +  ( minutes  ? str(minutes) + " мин." : "")
          return  msg
        end
         var response_text = 
                             "🌡 " + str(temp) +  "/" + str(persist.target_temp) + " °C " +
                             "💦 " + str(hum) + " % " +
                            ( pow  ? "🔥Нагревается " : "❄️Остывает ") +  tmc(total_second) +
                            ( persist.heat_time_duration  ? " 📈" + "Скорость нагрева " + tmc(persist.heat_time_duration) : "" ) + 
                            ( persist.cooling_time_duration  ? " 📉" + "Скорость остывания " + tmc(persist.cooling_time_duration) : "" )

         # Отправляем форматированный текст обратно в Telegram
         tasmota.cmd("TmSend " + response_text)
         # tasmota.resp_cmnd_done() - не удаляйте эту строку, если функция зарегистрирована как обработчик команды (tasmota.add_cmd('TEMP', ...))
         # Она нужна для формирования ответа на команду Tasmota. Если вы используете другой способ вызова (например, по таймеру),
         # то эту строку нужно убрать.
         #  tasmota.resp_cmnd_str("") # Устанавливаем пустой ответ на команду Tasmota, чтобы избежать второго JSON
       else
         # Обработка случая, если данные BME280 отсутствуют
         tasmota.cmd("TmSend Данные SI7021 недоступны.")
         tasmota.resp_cmnd_error()
       end
     else
       # Обработка случая, если не удалось распарсить JSON
       tasmota.cmd("TmSend Ошибка при получении данных сенсора.")
      tasmota.resp_cmnd_error()
     end
      
end

def temp_min_max(cmd, idx, value)
  if cmd == 'MIN' 
      if real(value) 
      persist.temp_min = value
      end
      persist.target_temp = persist.temp_min
      tasmota.cmd("TempTargetSet " + str(persist.target_temp))
  elif cmd == 'MAX' 
      if real(value) 
      persist.temp_max = value
      end
      persist.target_temp = persist.temp_max
      tasmota.cmd("TempTargetSet " + str(persist.target_temp))
  end
persist.save()
end


def tele_sensor(si7021_data)
  var temp = si7021_data["Temperature"]
  var street = get_weather()
  if persist.temp != temp || persist.street != street
    persist.temp = temp
    if street != nil
    persist.street = street
    end
    tasmota.cmd("TmSend " + "🏠  " + str(temp) + " °C " + "🏞 " + str(persist.street) + " °C ")
  end
end

# Привязка к событию Tele#SI7021
tasmota.add_rule("Tele#SI7021", tele_sensor, "heater_control")

tasmota.add_cmd('TERMO', telegram_info)
print("Команда INFO добавлена для получения данных.")

tasmota.add_cmd('MIN', temp_min_max)
print("Команда T_MIN добавлена для получения данных.")

tasmota.add_cmd('MAX', temp_min_max)
print("Команда INFO добавлена для получения данных.")




