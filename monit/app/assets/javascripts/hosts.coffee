$ ->
  client = new WebSocket('ws://192.168.43.64:8080')
  client.onopen = ->
    console.log 'hello'
  client.onmessage = (message) ->
    $('#hosts').append "<div> #{message.data} </div>"
    str = message.data
    words = str.split(" ")
    # console.log words[0]
    # console.log words[1]
    # console.log message.data

    if (words[1] == "20x")
      $('#hosts').css("color","red")
    else
      $('#hosts').css("color","black")

  $('#host_add').keyup (e) ->
    if e.keyCode == 13
      message = 'ADD ' + $('#host_add').val()
      client.send message
      $('#host_add').val ''
      
  $('#host_remove').keyup (e) ->
    if e.keyCode == 13
      message = 'REMOVE ' + $('#host_remove').val()
      client.send message
      $('#host_remove').val ''
