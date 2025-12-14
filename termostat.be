def termostatFSdef()
    var trmst = tasmota.cmd("THERMOSTATMODESET")["ThermostatModeSet1"]
    print(trmst)
    if trmst == 1
    print("Термостат уже запущен")
    else 
    print("Термостат запущен")
    tasmota.cmd("Backlog  SensorInputSet 1; ControllerModeSet 0; THERMOSTATMODESET 1")
    tasmota.cmd("Backlog  PropBandSet 3; TimePiCycleSet 60; TimeMinActionSet 4; TimeMaxActionSet 50; TimeAllowRampupSet 300; TimeRampupMaxSet 120; TimeRampupCycleSet 10; TempRupDeltInSet 3; TempRupDeltOutSet 1; TempHystSet 0.1; TempAntiWindupResetSet 1.0; TimeMinTurnoffActionSet 2")
    end

    if persist.target_temp != nil
    var loaded_value = persist.target_temp
    tasmota.cmd("TEMPTARGETSET " + str(loaded_value))
    print("Температура " + str(loaded_value))
    else
    tasmota.cmd("TEMPTARGETSET 20")
    print("Температура по умолчанию")
    end
end

termostatFSdef()


