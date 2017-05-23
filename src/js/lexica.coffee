---
---

DICTIONARIES = ['hesychius','suda','photios','harpokration','lexseg','lsj']

normalize = (input) ->
  input.normalize().toLowerCase().trim().replace(/[<>†*";.]/g,'')

search_dictionary = (dictionary, value) ->
  normalized_value = normalize(value)
  require ['./vendor/fast-levenshtein/levenshtein'], (levenshtein) ->
    $.ajax "/data/#{dictionary}-headwords.csv",
      type: 'GET'
      dataType: 'text'
      cache: true
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
      success: (data) ->
        console.log("#{dictionary} fetched")
        match_found = false
        match_text = ''
        min_distance = normalized_value.length * 2
        for entry in data.split(/\r?\n/)
          normalized_entry = normalize(entry)
          if normalized_entry == normalized_value
            console.log("Match: #{dictionary}")
            match_found = true
            $("##{dictionary}-match").text("✔")
            $("##{dictionary}-string").append($('<strong>').text(entry))
            break
          else
            distance = levenshtein.get(normalized_value, normalized_entry)
            if distance < min_distance
              min_distance = distance
              match_text = entry
        console.log("#{dictionary} done")
        unless match_found
          $("##{dictionary}-string").text(match_text)
          $("##{dictionary}-match").text("✗")

clear_results = ->
  for dictionary in DICTIONARIES
    $("##{dictionary}-match").empty()
    $("##{dictionary}-string").empty()

search_for = (value) ->
  $('#search_status').empty()
  $('#search_status').append($('<p>').text("Searching for: #{value}"))
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
