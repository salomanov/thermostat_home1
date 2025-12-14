class ThermostatSliderUI
  var loaded_value

  def init()
    if persist.target_temp != nil
    self.loaded_value =  persist.target_temp
    else
    self.loaded_value = 20.0  # Храним как float
    persist.target_temp = 20
    end
   
  end

  def web_add_main_button()
    webserver.content_send("<h3>Целевая температура</h3>")
    webserver.content_send("<p>Уставка: <span id='tempValue'>" + str(self.loaded_value) + "</span> °C</p>")
    
    # HTML Input Range отправляет ЦЕЛОЕ ЧИСЛО (умноженное на 10)
    webserver.content_send("<input type='range' id='tempSlider' min='50' max='300' step='5' oninput='la(\"&set_temp_int=\" + this.value); updateLabel(this.value)'>")
    
    # ВСЕ JavaScript-блоки отправляются через content_send(), а не content_send_style()
    webserver.content_send("<script>")
    webserver.content_send("function updateLabel(val) {")
    webserver.content_send("  var temp = val / 10.0;")
    webserver.content_send("  document.getElementById('tempValue').innerText = temp.toFixed(1);")
    webserver.content_send("}")
    webserver.content_send("window.onload = function() {")
    webserver.content_send("  document.getElementById('tempSlider').value = " + str(self.loaded_value * 10) + ";")
    webserver.content_send("};")
    webserver.content_send("</script>")
  end

  def web_sensor()
    # Проверяем наличие нашего нового аргумента "set_temp_int"
    if webserver.has_arg("set_temp_int")
      var temp_int_str = webserver.arg("set_temp_int")
      
      # Преобразуем строку в целое число
      var temp_int_val = int(temp_int_str)

      # Делим на 10.0, чтобы получить float обратно в Berry
      self.loaded_value = temp_int_val / 10.0 

      # Отправляем команду в ваш драйвер (он ожидает float)
      tasmota.cmd("TempTargetSet " + str(self.loaded_value))
      persist.target_temp = self.loaded_value
      print("Сохранили в память: " + str(persist.target_temp))
      persist.save()
    end
  end
end

d1 = ThermostatSliderUI()
tasmota.add_driver(d1)