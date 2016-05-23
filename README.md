Задание.
Необходимо написать приложение, которое будет в конфигурации принимать список url и мониторить ответ от них с определенным промежутком времени. В нормальном режиме ответ должен быть 20x (бонусом, корректно обрабатывать 30x). Если ответ меняется на какой-то другой, или становится вообще не доступен, url нужно начинать мониторить с другой частотой (чаще?) до получения нормального ответа.
Все детали и интерфейс системы остаются на усмотрение исполнителя и могут быть любыми.

----
 Написаны на базе WebSocket`ов:
   - Сервер мониторинга. В сервере реализован API, в котором предусмотрены функции для изменения конфигурации (добавления и удаления IP разрешенных клиентов).
     В коде задаются IP, c которых разрешено отправлять команды добавления,удаления клиентов и принимать сообщения от клиентов(переменная CONNECTION_ADMIN)
     Запускается: ruby server.rb 
     
   - Клиент. В браузере работает JavaScript, в котором на сервер отправляются сообщения, выбранные случайным образом 20x или 30x.
     Запускается: в браузере открываете файл client-connect_to_localhost.html
     
   - Frontend. Называется monit и написан на Ruby on Rails c Coffee. Позволяет выполнять функции API сервера мониторинга и получать сообщения. Если получено сообщение 30х, то меняется цвет текста сообщений на красный.
    Запускается: rails s -b 0.0.0.0