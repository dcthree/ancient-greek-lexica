---
---

DICTIONARIES = ['apollonius','aeliusdionysius','hesychius','suda','photios','phrynichus-ecloga','phrynichus-praeparatio','harpokration','moeris','orion','stephbyz','synagoge','synagogeb','lsj','logeion','diogenianus-vindob','diogenianus-mazarinco','etymologicum-genuinum','etymologicum-magnum','etymologicum-gudianum','dikon-onomata','lexeis-rhetorikai','zenobius','zonaras','haimodein','wip','brill','wiktionary']
HEADWORDS = null
ACCENTS_REGEX = new RegExp('[\u0300-\u036F\u0374-\u037A\u0384\u0385]', 'g')
SEARCH_WORKER = null
LAST_SEARCH = null

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
    when 'etymologicum-gudianum'
      switch ref.split('%22y%22')[0]
        when 'alpha','beta','gamma','delta','epsilon'
          "#{tlg_prefix()}&aid=4098&wid=001&ct=~x%22#{ref}%22#{tlg_postfix}"
        when 'zeta'
          if ref.split('%22y%22')[1] >= 578
            "#{tlg_prefix()}&aid=4098&wid=001&ct=~x%22#{ref}%22#{tlg_postfix}"
          else
            "#{tlg_prefix()}&aid=4098&wid=002&ct=~x%22#{ref}%22#{tlg_postfix}"
        else
          "#{tlg_prefix()}&aid=4098&wid=002&ct=~x%22#{ref}%22#{tlg_postfix}"
    when 'etymologicum-genuinum'
      if (/^alpha/.test(ref)) and (ref.split('%22y')[1] <= 760)
        "#{tlg_prefix()}&aid=4097&wid=001&ct=~x%22#{ref}#{tlg_postfix}"
      else
        "#{tlg_prefix()}&aid=4097&wid=002&ct=~x%22#{ref}#{tlg_postfix}"
    when 'etymologicum-magnum' then "#{tlg_prefix()}&aid=4099&wid=001&ct=~y%22#{ref}%22#{tlg_postfix}"
    when 'diogenianus-vindob' then "#{tlg_prefix()}&aid=0097&wid=002&ct=~x%22#{ref}%22#{tlg_postfix}"
    when 'diogenianus-mazarinco' then "#{tlg_prefix()}&aid=0097&wid=001&ct=~x%22#{ref}%22#{tlg_postfix}"
    when 'dikon-onomata' then "#{tlg_prefix()}&aid=4289&wid=003&ct=~x%22#{ref}z2&l=40&td=greek"
    when 'lexeis-rhetorikai' then "#{tlg_prefix()}&aid=4289&wid=004&ct=~x%22#{ref}&l=40&td=greek"
    when 'apollonius' then "#{tlg_prefix()}&aid=1168&wid=001&ct=~y#{ref}#{tlg_postfix}"
    when 'moeris' then "#{tlg_prefix()}&aid=1515&wid=002&ct=~x%22#{ref}#{tlg_postfix}"
    when 'orion' then "#{tlg_prefix()}&aid=2591&wid=001&ct=~x%22#{ref}#{tlg_postfix}"
    when 'zenobius' then "#{tlg_prefix()}&aid=0098&wid=001&ct=~x%22#{ref}%22#{tlg_postfix}"
    when 'zonaras' then "#{tlg_prefix()}&aid=3136&wid=001&q=Pseudo-ZONARAS&ct=~x%22#{ref}#{tlg_postfix}"
    when 'stephbyz'
      switch parseInt(ref.split('%22y')[0])
        when 1,2,3
          "#{tlg_prefix()}&aid=4028&wid=003&ct=~x%22#{ref}#{tlg_postfix}"
        when 4,5,6,7,8,9
          "#{tlg_prefix()}&aid=4028&wid=004&ct=~x%22#{ref}#{tlg_postfix}"
        when 10,11,12,13,14,15
          "#{tlg_prefix()}&aid=4028&wid=005&ct=~x%22#{ref}#{tlg_postfix}"
        else
          "#{tlg_prefix()}&aid=4028&wid=006&ct=~x%22#{ref}#{tlg_postfix}"
    when 'synagoge' then "#{tlg_prefix()}&aid=4160&wid=001&ct=~x%22#{ref}#{tlg_postfix}"
    when 'synagogeb' then "#{tlg_prefix()}&aid=4160&wid=002&ct=~x%22#{ref}#{tlg_postfix}"
    when 'hesychius' then "#{tlg_prefix()}&aid=4085&#{ref}%22#{tlg_postfix}"
    when 'phrynichus-ecloga' then "#{tlg_prefix()}&aid=1608&wid=002&q=PHRYNICHUS&ct=~y%22#{ref}%22#{tlg_postfix}"
    when 'phrynichus-praeparatio' then "#{tlg_prefix()}&aid=1608&wid=001&q=PHRYNICHUS&ct=~y#{ref}&l=40&td=greek"
    when 'aeliusdionysius' then "#{tlg_prefix()}&aid=1323&wid=001&q=Aelius%20DIONYSIUS&ct=~x%22#{ref}#{tlg_postfix}"
    when 'haimodein' then "#{tlg_prefix()}&aid=4288&wid=002&ct=~x%22#{ref}#{tlg_postfix}"
    when 'logeion' then "http://logeion.uchicago.edu/#{entry}"
    when 'morpho' then "http://logeion.uchicago.edu/morpho/#{entry}"
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

process_search_worker_result = (e) ->
  console.log('process_search_worker_result called')
  if e.data.search_term == LAST_SEARCH
    requestAnimationFrame ->
      $('#spinner').hide()
      for dictionary,match_ref of e.data.exact_matches
        $("##{dictionary}-match").text("✔")
        $("##{dictionary}-string").empty().append($('<strong>').append(generate_link(dictionary, e.data.search_term, match_ref)))
      for dictionary,result of e.data.inexact_matches
        $("##{dictionary}-string").empty().append(generate_link(dictionary, result.match_text, result.match_ref))
        $("##{dictionary}-search").empty().append(pivot_search_link(result.match_text))

# assumes the headword index has already been loaded into HEADWORDS
search_dictionaries_for_value = (value) ->
  normalized_value = normalize(value)
  LAST_SEARCH = normalized_value
  $('#spinner').show()
  SEARCH_WORKER.postMessage
    search_term: normalized_value

perform_search = (value) ->
  console.log 'perform_search:', value
  requestAnimationFrame ->
    $('#search_status').empty().append(
      $('<p>').text("Searching for: #{value} - ").append(
        generate_link('logeion',value,value).text("search for #{value} in Logeion")
      ).append(
        $('<span>').text(' or ')
      ).append(
        generate_link('morpho',value,value).text("Μορφώ")
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
    console.log('perform_search called with uninitialized headwords!')

search_for = (value) ->
  console.log 'search_for:', value
  $.xhrPool.abortAll()
  window.location = "##{value}"

search_for_hash = ->
  hash_parameter = decodeURI(window.location.hash.substr(1))
  console.log 'got hash parameter:', hash_parameter
  $('#search').val(hash_parameter)
  perform_search(hash_parameter)

$(document).ready ->
  console.log('ready')
 
  fetch 'data/headwords.json',
    method: 'GET'
    cache: 'default'
  .then (response) ->
      SEARCH_WORKER ?= new Worker('src/js/search-worker.js')
      SEARCH_WORKER.postMessage
        dictionaries: DICTIONARIES
      SEARCH_WORKER.onmessage = process_search_worker_result
      response.json().then (headwords_json) ->
        console.log("headwords fetched")
        HEADWORDS ?= headwords_json
        SEARCH_WORKER.postMessage
          headwords: HEADWORDS
        $('#spinner').hide()
        $('#search').prop('placeholder','Enter a Greek search term')
        $('#search').prop('disabled',false)
        $('#tlg_dropdown').prop('disabled',false)
        $('#tlg_dropdown').change ->
          perform_search($('#search').val())
        window.addEventListener('hashchange', search_for_hash, false)
        if window.location.hash?.length
          search_for_hash()
        $('#search').autocomplete "option", "source", (request, response) ->
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
      # console.log(ui)
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
