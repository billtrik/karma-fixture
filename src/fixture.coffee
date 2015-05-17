class Fixture

  constructor: (@base = 'spec/fixtures', @id = 'fixture_container') ->
    @json = []
    @scriptTypes = {
      'application/ecmascript': 1,
      'application/javascript': 1,
      'application/x-ecmascript': 1,
      'application/x-javascript': 1,
      'text/ecmascript': 1,
      'text/javascript': 1,
      'text/javascript1.0': 1,
      'text/javascript1.1': 1,
      'text/javascript1.2': 1,
      'text/javascript1.3': 1,
      'text/javascript1.4': 1,
      'text/javascript1.5': 1,
      'text/jscript': 1,
      'text/livescript': 1,
      'text/x-ecmascript': 1,
      'text/x-javascript': 1
    }

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
      if filename[0] is '/'
        fixture_path = filename.substr(1)
      else
        fixture_path = "#{@base}/#{filename}"

      string = __html__?[fixture_path]
      @_throwNoFixture(fixture_path) unless string?

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

  setBase: (@base)->

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
        eval (i.innerText || i.textContent) if i.nodeName is 'SCRIPT' and (!i.type or @scriptTypes[i.type])
    return results

  _throwNoFixture: (fixture_path)->
    throw new ReferenceError "Cannot find fixture '#{fixture_path}'"

if typeof exports is 'object'
  module.exports = Fixture
else if typeof define is 'function' and define.amd
  define 'fixture', [], -> Fixture
else
  this['Fixture'] = Fixture
