class Fixture
  @el_id: 'fixture_container'

  constructor: (base = 'spec/fixtures')->
    @base = base
    @json = []

    @el = window.fixture_container or (->
      container = document.createElement('div')
      container.setAttribute('id',Fixture.el_id)
      document.body.appendChild container
    )()

  load: (filenames..., append = false) ->
    unless typeof(append) is 'boolean'
      filenames.push(append)
      append = false

    @cleanup() if append is false

    # return created fixtures in an array
    results = []
    for filename in filenames
      string = __html__?["#{@base}/#{filename}"] or ''

      if filename.indexOf('.json') isnt -1
        try
          json = JSON.parse(string)
          @json.push json
          results.push json
        catch err
      else
        results.push @_add_fixture string

    results = results[0] if results.length is 1
    return results

  set: (strings..., append = false)->
    unless typeof(append) is 'boolean'
      strings.push(append)
      append = false

    @cleanup() if append is false

    @_add_fixture string for string in strings

  cleanup: ->
    @json = []
    @el.innerHTML = ''

  _add_fixture: (html_string) ->
    temp_div = document.createElement('div')
    temp_div.innerHTML = html_string

    results = []
    while(i = temp_div.firstChild)
      if i.nodeType isnt 1
        temp_div.removeChild i
      else
        @el.appendChild(i)
        results.push i
        eval i.innerText if i.nodeName is 'SCRIPT'
    return results

if typeof exports is "object"
  module.exports = Fixture
else if typeof define is "function" and define.amd
  define 'fixture', [], -> Fixture
else
  this['Fixture'] = Fixture
