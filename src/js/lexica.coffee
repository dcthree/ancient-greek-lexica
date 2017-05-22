---
---

DICTIONARIES = ['harpokration','lexseg','suda','hesychius','photios']

normalize = (input) ->
  input.normalize().toLowerCase().trim().replace(/[<>†*";.]/g,'')

search_dictionary = (dictionary, value) ->
  normalized_value = normalize(value)
  $.ajax "/data/#{dictionary}-headwords.csv",
    type: 'GET'
    dataType: 'text'
    cache: true
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data) ->
      console.log("#{dictionary} fetched")
      for entry in data.split(/\r?\n/)
        if normalize(entry) == normalized_value
          console.log("Match: #{dictionary}")
          $("##{dictionary}-match").text("✔")
          $("##{dictionary}-string").text(entry)
          # $('#results').append($('<p>').text(dictionary))
          break
      console.log("#{dictionary} done")

clear_results = ->
  for dictionary in DICTIONARIES
    $("##{dictionary}-match").empty()
    $("##{dictionary}-string").empty()

search_for = (value) ->
  console.log("Searching for: #{value}")
  clear_results()
  for dictionary in DICTIONARIES
    console.log("AJAX: #{dictionary}")
    search_dictionary(dictionary, value)

$(document).ready ->
  console.log('ready')
  $('#search').autocomplete
    delay: 600
    minLength: 1
    source: []
    search: (event, ui) ->
      search_for($('#search').val())
