---
---

DICTIONARIES = ['hesychius','suda','photios','harpokration','lexseg','lsj','logeion']
HEADWORDS = null

$.xhrPool = []
$.xhrPool.abortAll = ->
  $(this).each (i, jqXHR) ->
    jqXHR.abort()
    $.xhrPool.splice(i, 1)
$.ajaxSetup
  beforeSend: (jqXHR) -> $.xhrPool.push(jqXHR)
  complete: (jqXHR) ->
    i = $.xhrPool.indexOf(jqXHR)
    $.xhrPool.splice(i, 1) if (i > -1)

normalize = (input) ->
  input.normalize().toLowerCase().trim().replace(/[<>†*";.]/g,'')

generate_link = (dictionary, entry, ref) ->
  url = switch dictionary
    when 'lsj' then "http://www.perseus.tufts.edu/hopper/text?doc=Perseus:text:1999.04.0057:entry=#{ref}"
    when 'harpokration' then "https://dcthree.github.io/harpokration/#urn_cts_greekLit_tlg1389_tlg001_dc3_#{ref}"
    when 'photios' then "https://dcthree.github.io/photios/#urn_cts_greekLit_tlg4040_lexicon_dc3_#{ref}"
    when 'suda' then "http://www.stoa.org/sol-entries/#{ref}"
    when 'lexseg' then "http://stephanus.tlg.uci.edu/Iris/inst/browser.jsp#doc=tlg&aid=4289&wid=005&q=LEXICA%20SEGUERIANA&ct=~x%22#{ref}&l=40&td=greek"
    when 'hesychius' then "http://stephanus.tlg.uci.edu/Iris/inst/browser.jsp#doc=tlg&aid=4085&wid=002&q=HESYCHIUS&ct=~x%22#{ref}%22z1&rt=y&l=40&td=greek"
    when 'logeion' then "http://logeion.uchicago.edu/index.html##{entry}"
  $('<a>').attr('href',url).attr('target','_blank').text(entry)

search_dictionary = (dictionary, value) ->
  normalized_value = normalize(value)
  require ['./vendor/fast-levenshtein/levenshtein'], (levenshtein) ->
    $.ajax "data/#{dictionary}-headwords.csv",
      type: 'GET'
      dataType: 'text'
      cache: true
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
      success: (data) ->
        console.log("#{dictionary} fetched")
        match_found = false
        match_text = ''
        match_ref = ''
        min_distance = normalized_value.length * 2
        for entry in data.split(/\r?\n/)
          fields = entry.split(',')
          ref = fields[0]
          text = fields[1..].join(',')
          normalized_entry = normalize(text)
          if normalized_entry == normalized_value
            console.log("Match: #{dictionary}")
            match_found = true
            match_text = text
            match_ref = ref
            break
          else
            distance = levenshtein.get(normalized_value, normalized_entry)
            if distance < min_distance
              min_distance = distance
              match_text = text
              match_ref = ref
        console.log("#{dictionary} done")
        if match_found
          $("##{dictionary}-match").text("✔")
          $("##{dictionary}-string").append($('<strong>').append(generate_link(dictionary, match_text, match_ref)))
        else
          $("##{dictionary}-string").append(generate_link(dictionary, match_text, match_ref))
          $("##{dictionary}-match").text("✗")

clear_results = ->
  for dictionary in DICTIONARIES
    $("##{dictionary}-match").empty()
    $("##{dictionary}-string").empty()

search_for = (value) ->
  $.xhrPool.abortAll()
  $('#search_status').empty()
  $('#search_status').append($('<p>').text("Searching for: #{value} - ").append(generate_link('logeion',value,value).text("search for #{value} in Logeion")))
  clear_results()
  for dictionary in DICTIONARIES
    console.log("AJAX: #{dictionary}")
    search_dictionary(dictionary, value)

$(document).ready ->
  console.log('ready')
  $.ajax 'data/all_headwords_unique.csv',
    type: 'GET'
    dataType: 'text'
    cache: true
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data) ->
      console.log("headwords fetched")
      $('#search').prop('disabled',false)
      $('#search').autocomplete
        delay: 600
        minLength: 1
        source: (request, response) ->
          HEADWORDS ?= data.split(/\r?\n/)
          normalized_term = normalize(request.term)
          matches = HEADWORDS.filter (h) -> h.startsWith(normalized_term)
          response(matches[0..20])
        select: (event, ui) ->
          console.log(ui)
          search_for(ui.item.value)
        search: (event, ui) ->
          search_for($('#search').val())
