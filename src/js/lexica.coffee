---
---

DICTIONARIES = ['aeliusdionysius','hesychius','suda','photios','harpokration','synagoge','synagogeb','lsj','logeion','zonaras']
HEADWORDS = null
ACCENTS_REGEX = new RegExp('[\u0300-\u036F\u0374-\u037A\u0384\u0385]', 'g')

$.xhrPool = []
$.xhrPool.abortAll = ->
  $(this).each (i, jqXHR) ->
    jqXHR.abort()
    $.xhrPool.splice(i, 1)

normalize = (input) ->
  input.normalize().toLowerCase().trim().replace(/[-<>†*";.,\][_(){}&:^·\\=0-9]/g,'')

strip_accents = (input) ->
  input.normalize('NFD').replace(ACCENTS_REGEX, '')

generate_link = (dictionary, entry, ref) ->
  url = switch dictionary
    when 'lsj' then "http://www.perseus.tufts.edu/hopper/text?doc=Perseus:text:1999.04.0057:entry=#{ref}"
    when 'harpokration' then "https://dcthree.github.io/harpokration/#urn_cts_greekLit_tlg1389_tlg001_dc3_#{ref}"
    when 'photios' then "https://dcthree.github.io/photios/#urn_cts_greekLit_tlg4040_lexicon_dc3_#{ref}"
    when 'suda' then "http://www.stoa.org/sol-entries/#{ref}"
    when 'zonaras' then "http://stephanus.tlg.uci.edu/Iris/inst/browser.jsp#doc=tlg&aid=3136&wid=001&q=Pseudo-ZONARAS&ct=~x%22#{ref}z1&rt=y&l=40&td=greek"
    when 'synagoge' then "http://stephanus.tlg.uci.edu/Iris/inst/browser.jsp#doc=tlg&aid=4160&wid=001&ct=~x%22#{ref}z1&rt=y&l=40&td=greek"
    when 'synagogeb' then "http://stephanus.tlg.uci.edu/Iris/inst/browser.jsp#doc=tlg&aid=4160&wid=002&ct=~x%22#{ref}z1&rt=y&l=40&td=greek"
    when 'hesychius' then "http://stephanus.tlg.uci.edu/Iris/inst/browser.jsp#doc=tlg&aid=4085&wid=002&q=HESYCHIUS&ct=~x%22#{ref}%22z1&rt=y&l=40&td=greek"
    when 'aeliusdionysius' then "http://stephanus.tlg.uci.edu/Iris/inst/browser.jsp#doc=tlg&aid=1323&wid=001&q=Aelius%20DIONYSIUS&ct=~x%22#{ref}z1&rt=y&l=40&td=greek"
    when 'logeion' then "http://logeion.uchicago.edu/index.html##{entry}"
  $('<a>').attr('href',url).attr('target','_blank').text(entry)

clear_results = ->
  for dictionary in DICTIONARIES
    $("##{dictionary}-match").empty()
    $("##{dictionary}-string").empty()

# assumes the headword index has already been loaded into HEADWORDS
search_dictionaries_for_value = (value) ->
  normalized_value = normalize(value)
  require ['./vendor/fast-levenshtein/levenshtein'], (levenshtein) ->
    for dictionary in DICTIONARIES
      match_found = false
      match_text = ''
      match_ref = ''
      min_distance = normalized_value.length * 2
      for headword,refs of HEADWORDS
        if refs[dictionary]?
          if (headword == normalized_value)
            console.log("Match: #{dictionary}")
            match_found = true
            match_text = headword
            match_ref = refs[dictionary]
            break
          else
            distance = levenshtein.get(normalized_value, headword)
            if distance < min_distance
              min_distance = distance
              match_text = headword
              match_ref = refs[dictionary]
      console.log("#{dictionary} done")
      if match_found
        $("##{dictionary}-match").text("✔")
        $("##{dictionary}-string").append($('<strong>').append(generate_link(dictionary, match_text, match_ref)))
      else
        $("##{dictionary}-match").text("✗")
        $("##{dictionary}-string").append(generate_link(dictionary, match_text, match_ref))

search_for = (value) ->
  $.xhrPool.abortAll()
  $('#search_status').empty()
  $('#search_status').append($('<p>').text("Searching for: #{value} - ").append(generate_link('logeion',value,value).text("search for #{value} in Logeion")))
  clear_results()
  if HEADWORDS?
    search_dictionaries_for_value(value)
  else
    $.ajax "data/headwords.json",
      type: 'GET'
      dataType: 'json'
      cache: true
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
      success: (data) ->
        HEADWORDS ?= data
        search_dictionaries_for_value(value)

$(document).ready ->
  console.log('ready')
  
  $.ajax 'data/headwords.json',
    type: 'GET'
    dataType: 'json'
    cache: true
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data) ->
      console.log("headwords fetched")
      $('#search').autocomplete "option", "source", (request, response) ->
        HEADWORDS ?= data
        normalized_term = normalize(request.term)
        matches = []
        if strip_accents(normalized_term) == normalized_term # no accents in search string, strip accents for matching
          matches = Object.keys(HEADWORDS).filter (h) -> strip_accents(h).startsWith(normalized_term)
        else # accents in search string, don't strip accents for matching
          matches = Object.keys(HEADWORDS).filter (h) -> h.startsWith(normalized_term)
        matches = matches.sort (a,b) -> a.length - b.length
        response(matches[0..20])

  $('#search').autocomplete
    delay: 600
    minLength: 1
    source: []
    select: (event, ui) ->
      console.log(ui)
      search_for(ui.item.value)
    search: (event, ui) ->
      search_for($('#search').val())

  $.ajaxSetup
    beforeSend: (jqXHR) -> $.xhrPool.push(jqXHR)
    complete: (jqXHR) ->
      i = $.xhrPool.indexOf(jqXHR)
      $.xhrPool.splice(i, 1) if (i > -1)
