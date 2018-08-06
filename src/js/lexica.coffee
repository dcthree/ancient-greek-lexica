---
---

DICTIONARIES = ['aeliusdionysius','hesychius','suda','photios','phrynichus-ecloga','phrynichus-praeparatio','harpokration','synagoge','synagogeb','lsj','logeion','diogenianus-vindob','diogenianus-mazarinco','etymologicum-genuinum','etymologicum-magnum','zenobius','zonaras','haimodein','wip','brill','wiktionary']
HEADWORDS = null
ACCENTS_REGEX = new RegExp('[\u0300-\u036F\u0374-\u037A\u0384\u0385]', 'g')

$.xhrPool = []
$.xhrPool.abortAll = ->
  $(this).each (i, jqXHR) ->
    jqXHR.abort()
    $.xhrPool.splice(i, 1)

normalize = (input) ->
  input.normalize().toLowerCase().trim().replace(/[-<>⸤⸥†*";.,\][_(){}&:^·\\=0-9]/g,'')

strip_accents = (input) ->
  input.normalize('NFD').replace(ACCENTS_REGEX, '')

tlg_subscription = ->
  $('#tlg_dropdown').val()

tlg_prefix = ->
  "http://stephanus.tlg.uci.edu/Iris/#{tlg_subscription()}/browser.jsp#doc=tlg"

tlg_postfix = "z1&rt=y&l=40&td=greek"

generate_link = (dictionary, entry, ref) ->
  url = switch dictionary
    when 'lsj' then "http://www.perseus.tufts.edu/hopper/text?doc=Perseus:text:1999.04.0057:entry=#{ref}"
    when 'harpokration' then "https://dcthree.github.io/harpokration/#urn_cts_greekLit_tlg1389_tlg001_dc3_#{encodeURIComponent(ref)}"
    when 'photios' then "https://dcthree.github.io/photios/entry#urn_cts_greekLit_tlg4040_lexicon_dc3_#{encodeURIComponent(ref)}"
    when 'suda' then "http://www.stoa.org/sol-entries/#{ref}"
    when 'etymologicum-genuinum'
      if (/^alpha/.test(ref)) and (ref.split('%22y')[1] <= 760)
        "#{tlg_prefix()}&aid=4097&wid=001&ct=~x%22#{ref}#{tlg_postfix}"
      else
        "#{tlg_prefix()}&aid=4097&wid=002&ct=~x%22#{ref}#{tlg_postfix}"
    when 'etymologicum-magnum' then "#{tlg_prefix()}&aid=4099&wid=001&ct=~y%22#{ref}%22#{tlg_postfix}"
    when 'diogenianus-vindob' then "#{tlg_prefix()}&aid=0097&wid=002&ct=~x%22#{ref}%22#{tlg_postfix}"
    when 'diogenianus-mazarinco' then "#{tlg_prefix()}&aid=0097&wid=001&ct=~x%22#{ref}%22#{tlg_postfix}"
    when 'zenobius' then "#{tlg_prefix()}&aid=0098&wid=001&ct=~x%22#{ref}%22#{tlg_postfix}"
    when 'zonaras' then "#{tlg_prefix()}&aid=3136&wid=001&q=Pseudo-ZONARAS&ct=~x%22#{ref}#{tlg_postfix}"
    when 'synagoge' then "#{tlg_prefix()}&aid=4160&wid=001&ct=~x%22#{ref}#{tlg_postfix}"
    when 'synagogeb' then "#{tlg_prefix()}&aid=4160&wid=002&ct=~x%22#{ref}#{tlg_postfix}"
    when 'hesychius' then "#{tlg_prefix()}&aid=4085&#{ref}%22#{tlg_postfix}"
    when 'phrynichus-ecloga' then "#{tlg_prefix()}&aid=1608&wid=002&q=PHRYNICHUS&ct=~y%22#{ref}%22#{tlg_postfix}"
    when 'phrynichus-praeparatio' then "#{tlg_prefix()}&aid=1608&wid=001&q=PHRYNICHUS&ct=~y#{ref}&l=40&td=greek"
    when 'aeliusdionysius' then "#{tlg_prefix()}&aid=1323&wid=001&q=Aelius%20DIONYSIUS&ct=~x%22#{ref}#{tlg_postfix}"
    when 'haimodein' then "#{tlg_prefix()}&aid=4288&wid=002&ct=~x%22#{ref}#{tlg_postfix}"
    when 'logeion' then "http://logeion.uchicago.edu/index.html##{entry}"
    when 'wiktionary' then "https://en.wiktionary.org/wiki/#{entry}"
    when 'morph' then "http://www.perseus.tufts.edu/hopper/morph?l=#{entry}&la=greek"
    when 'wip' then "http://www.aristarchus.unige.net/Wordsinprogress/it-it/Database/View/#{ref}"
    when 'brill' then "http://dictionaries.brillonline.com/search#dictionary=montanari&id=#{ref}"
    when 'self' then "https://dcthree.github.io/ancient-greek-lexica/##{encodeURIComponent(ref)}"
  $('<a>').attr('href',url).attr('target','_blank').text(entry)

clear_results = ->
  for dictionary in DICTIONARIES
    $("##{dictionary}-match").empty()
    $("##{dictionary}-string").empty()
    $("##{dictionary}-search").empty()

pivot_search_link = (search_string) ->
  "<a href=\"#{window.location.href.split('#')[0]}##{encodeURIComponent(search_string)}\"><svg class=\"icon icon-search\"><use xlink:href=\"#icon-search\"></use></svg></a>"

# assumes the headword index has already been loaded into HEADWORDS
search_dictionaries_for_value = (value) ->
  normalized_value = normalize(value)
  exact_matches = HEADWORDS[normalized_value]
  remaining_dictionaries = DICTIONARIES
  if exact_matches?
    matching_dictionaries = Object.keys(exact_matches)
    remaining_dictionaries = $(DICTIONARIES).not(matching_dictionaries).get()
    for dictionary,match_ref of exact_matches
      $("##{dictionary}-match").text("✔")
      $("##{dictionary}-string").empty().append($('<strong>').append(generate_link(dictionary, normalized_value, match_ref)))
      console.log("#{dictionary} done")
  require ['./vendor/fast-levenshtein/levenshtein'], (levenshtein) ->
    for dictionary in remaining_dictionaries
      $("##{dictionary}-match").text("✗")
      match_text = ''
      match_ref = ''
      min_distance = normalized_value.length * 2
      for headword,refs of HEADWORDS
        if refs[dictionary]?
          distance = levenshtein.get(normalized_value, headword)
          if distance < min_distance
            min_distance = distance
            match_text = headword
            match_ref = refs[dictionary]
      $("##{dictionary}-string").empty().append(generate_link(dictionary, match_text, match_ref))
      $("##{dictionary}-search").empty().append(pivot_search_link(match_text))
      console.log("#{dictionary} done")

search_for = (value) ->
  $.xhrPool.abortAll()
  window.location = "##{value}"
  $('#search_status').empty().append(
    $('<p>').text("Searching for: #{value} - ").append(
      generate_link('logeion',value,value).text("search for #{value} in Logeion")
    ).append(
      $('<span>').text(', ')
    ).append(
      generate_link('morph',value,value).text("search for #{value} in the Perseus Greek Word Study Tool")
    ).append(
      $('<span>').text(', ')
    ).append(
      generate_link('self',value,value).text("link to these search results")
    )
  )
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

search_for_hash = ->
  hash_parameter = decodeURI(window.location.hash.substr(1))
  console.log 'got hash parameter:', hash_parameter
  $('#search').val(hash_parameter)
  search_for(hash_parameter)

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

  $('#tlg_dropdown').change ->
    search_for($('#search').val())

  $('#search').autocomplete
    delay: 600
    minLength: 1
    source: []
    select: (event, ui) ->
      console.log(ui)
      if window.location.hash != ui.item.value
        search_for(ui.item.value)
    search: (event, ui) ->
      if window.location.hash != $('#search').val()
        search_for($('#search').val())

  $.ajaxSetup
    beforeSend: (jqXHR) -> $.xhrPool.push(jqXHR)
    complete: (jqXHR) ->
      i = $.xhrPool.indexOf(jqXHR)
      $.xhrPool.splice(i, 1) if (i > -1)

  window.addEventListener('hashchange', search_for_hash, false)

  if window.location.hash?.length
    search_for_hash()
