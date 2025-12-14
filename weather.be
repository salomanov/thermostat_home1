def get_weather()
  var wc = webclient()
  wc.begin("https://api.open-meteo.com/v1/forecast?latitude=57.257538&longitude=65.136679&current=temperature_2m,relative_humidity_2m&timezone=Asia/Yekaterinburg")
  var temp
  if wc.GET() == 200
    var body = wc.get_string()
    var d = json.load(body)
    if d != nil && d["current"] != nil
      temp = str(d["current"]["temperature_2m"])
    end
  end
  wc.close()
  return temp
end
