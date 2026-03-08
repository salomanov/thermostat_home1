# thermostat_home1

Репозиторий с файлами конфигурации и Berry-скриптами для термостата на базе Tasmota/HASPmota.

## Установка

Выполните в консоли Tasmota по очереди 3 команды:

```text
Backlog UrlFetch https://github.com/salomanov/thermostat_home1/raw/refs/heads/main/autoexec.be; UrlFetch https://github.com/salomanov/thermostat_home1/raw/refs/heads/main/cmd.be
```

```text
Backlog UrlFetch https://github.com/salomanov/thermostat_home1/raw/refs/heads/main/termostat.be; UrlFetch https://github.com/salomanov/thermostat_home1/raw/refs/heads/main/tempset.be
```

```text
Backlog UrlFetch https://github.com/salomanov/thermostat_home1/raw/refs/heads/main/telegram.be; UrlFetch https://github.com/salomanov/thermostat_home1/raw/refs/heads/main/work.be; Restart 1
```
