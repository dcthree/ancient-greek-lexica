---
---

console.log('search-worker loaded')
importScripts('./vendor/requirejs/2.3.3/require.js')
HEADWORDS = null
DICTIONARIES = null

onmessage = (e) ->
  console.log('search-worker received message')
  if e.data.headwords?
    console.log('search-worker initializing headwords')
    HEADWORDS ?= e.data.headwords
  if e.data.dictionaries
    console.log('search-worker initializing dictionaries')
    DICTIONARIES ?= e.data.dictionaries
  if e.data.search_term?
    require ['./vendor/fast-levenshtein/levenshtein'], (levenshtein) ->
      exact_matches = HEADWORDS[e.data.search_term]
      inexact_matches = {}
      remaining_dictionaries = DICTIONARIES
      if exact_matches?
        matching_dictionaries = Object.keys(exact_matches)
        remaining_dictionaries = (dictionary for dictionary in DICTIONARIES when dictionary not in matching_dictionaries)
      else
        exact_matches = {}
      for dictionary in remaining_dictionaries
        # $("##{dictionary}-match").text("✗")
        match_text = ''
        match_ref = ''
        min_distance = e.data.search_term.length * 3
        for headword,refs of HEADWORDS
          if refs[dictionary]?
            distance = levenshtein.get(e.data.search_term, headword)
            if distance < min_distance
              min_distance = distance
              match_text = headword
              match_ref = refs[dictionary]
        inexact_matches[dictionary] =
          match_text: match_text
          match_ref: match_ref
      console.log('search-worker done, posting message')
      postMessage
        search_term: e.data.search_term
        exact_matches: exact_matches
        inexact_matches: inexact_matches

self.addEventListener('message', onmessage, false)
