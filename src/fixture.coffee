class Fixture

  constructor: (@base = 'spec/fixtures', @id = 'fixture_container') ->
    @json = []

    @el = window[@id] or (=>
      container = document.createElement 'div'
      container.setAttribute 'id', @id
      document.body.appendChild container
    )()

  load: (filenames..., append = false) ->
    unless typeof append is 'boolean'
      filenames.push append
      append = false

    @cleanup() if append is false

    # return created fixtures in an array
    results = []
    for filename in filenames
      string = __html__?["#{@base}/#{filename}"]
      @_throwNoFixture() unless string?

      if filename.indexOf('.json') isnt -1
        try
          json = JSON.parse string
          @json.push json
          results.push json
        catch err
      else
        results.push @_appendFixture string

    results = results[0] if results.length is 1
    return results

  set: (strings..., append = false)->
    unless typeof append is 'boolean'
      strings.push append
      append = false

    @cleanup() if append is false

    results = []
    for string in strings
      results.push @_appendFixture string

    results = results[0] if results.length is 1
    return results

  cleanup: ->
    @json = []
    @el.innerHTML = ''

  _appendFixture: (html_string) ->
    temp_div = document.createElement 'div'
    temp_div.innerHTML = html_string

    results = []
    while i = temp_div.firstChild
      if i.nodeType isnt 1
        temp_div.removeChild i
      else
        @el.appendChild(i)
        results.push i
        eval i.innerText if i.nodeName is 'SCRIPT'
    return results

  _throwNoFixture: ()->
    throw new ReferenceError 'Fixture not found'

if typeof exports is 'object'
  module.exports = Fixture
else if typeof define is 'function' and define.amd
  define 'fixture', [], -> Fixture
else
  this['Fixture'] = Fixture
