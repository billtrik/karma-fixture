json_data = {
  test1: 'check'
  test2: 'ok'
}
json_template = JSON.stringify(json_data)
html_template1 = '<h1 id="tmpl">test</h1>'
html_template2 = '<h2 id="tmpl">test</h2><p>multiple</p>'
html_template3 = '<script>window.test_a_test = true</script>'
fixture_base = 'spec/fixtures'

load_template_as_karma_html2js = (name, string, base = fixture_base)->
  window.__html__ ?= {}
  window.__html__["#{base}/#{name}"] = string

cleanup_karma_html2js_templates = -> window.__html__ = {}

describe 'Fixture', ->
  before ->
    @Fixture = window.Fixture

  it 'is a function', ->
    expect(@Fixture).to.be.a 'function'

  describe 'instance', ->
    afterEach ->
      container = document.getElementById(@instance.id)
      container.parentElement.removeChild(container)
      @instance = null
      delete @instance

    it 'stores the id of the fixtures container in @id', ->
      @instance = new @Fixture()
      expect(@instance.id)
        .to.not.be.null

    it 'stores the base folder from where to load templates in @base', ->
      @instance = new @Fixture()
      expect(@instance.base)
        .to.not.be.null

    it "has a default value of '#{fixture_base}' for the base", ->
      @instance = new @Fixture()
      expect(@instance.base)
        .to.equal fixture_base

    it 'receives a param that changes the base value', ->
      @instance = new @Fixture('checkcheck')
      expect(@instance.base)
        .to.equal 'checkcheck'

    it 'receives the base folder from where to load templates as option', ->
      @instance = new @Fixture()

    it 'has an empty array to store json fixtures in @json', ->
      @instance = new @Fixture()
      expect(@instance.json)
        .to.be.an('array')
        .and.to.be.empty

    it 'has created the fixtures container element', ->
      @instance = new @Fixture()
      container = document.getElementById @instance.id
      expect(container).to.not.be.null

    it 'has a reference to the fixtures container element in @el', ->
      @instance = new @Fixture()
      container = document.getElementById @instance.id
      expect(@instance.el).to.equal(container)

  describe 'API', ->
    beforeEach ->
      @instance = new @Fixture()
      @fixture_cont = @instance.el

    afterEach ->
      container = document.getElementById(@instance.id)
      container.parentElement.removeChild(container)
      @instance = null
      delete @instance

    describe 'load', ->
      beforeEach ->
        load_template_as_karma_html2js 'html1', html_template1
        load_template_as_karma_html2js 'html2', html_template2
        load_template_as_karma_html2js 'html3', html_template3
        load_template_as_karma_html2js 'json.json', json_template

      afterEach ->
        cleanup_karma_html2js_templates()

      it 'creates DOM elements inside the container from the template whose name is passed as the first param', ->
        @instance.load 'html1'
        expect(@fixture_cont.children.length).to.equal 1

      it 'accepts an append boolean as second param', ->
        @instance.load 'html1', true
        expect(@fixture_cont.children.length).to.equal 1

      it 'appends new template to existing one if append is true', ->
        @instance.load 'html1', false
        @instance.load 'html2', true
        @instance.load 'html1', true
        expect(@fixture_cont.children.length).to.equal 4

      it 'replaces older templates with new one if append is false', ->
        @instance.load 'html1', false
        @instance.load 'html2', false
        @instance.load 'html1', false
        expect(@fixture_cont.children.length).to.equal 1

      it 'has a default value of false', ->
        @instance.load 'html1'
        @instance.load 'html1'
        expect(@fixture_cont.children.length).to.equal 1

      it 'returns an array with a list of newly created dom nodes per template', ->
        dom_nodes = @instance.load('html1')

        expect(dom_nodes[0])
          .to.equal @fixture_cont.firstChild

      it 'returns references to all firstChildren nodes created by the template', ->
        dom_nodes = @instance.load('html2')

        expect(dom_nodes.length)
          .to.equal(@fixture_cont.children.length)
          .to.equal(2)

      it 'throws when template does not exist', ->
        fn = => @instance.load('notExistingFixture')
        expect(fn).to.throw(ReferenceError, 'Fixture not found')

      context 'when template contains <script> tags', ->
        beforeEach ->
          @instance.load 'html3'

        it 'places the script tag intact', ->
          expect(@fixture_cont.innerHTML).to.equal html_template3

        it 'executes the javascript', ->
          expect(window.test_a_test).to.equal true

      context 'when multiple templates are requested', ->
        beforeEach ->
          @result = @instance.load 'html1', 'html2'

        it 'accepts multiple templates as params', ->
          expect(@fixture_cont.children.length).to.equal 3

        it 'returns multiple template\'s results in an array', ->
          expect(@result.length).to.equal(2)

        it 'returns references to all firstChildren nodes created by all the templates', ->
          expect(@result[1][1])
            .to.equal @fixture_cont.children[2]

      context 'when it loads json template', ->
        it 'returns the json object', ->
          result = @instance.load 'json.json'
          expect(result).to.include json_data

        it 'loads the json template into fixture.json', ->
          @instance.load 'json.json'
          expect(@instance.json[0]).to.include json_data

        it 'returns multipe json objects', ->
          result = @instance.load 'json.json', 'json.json'
          expect(result.length).to.equal 2

        it 'loads multiple json templates into fixture.json', ->
          result = @instance.load 'json.json', 'json.json'
          expect(@instance.json.length).to.equal 2

      context 'json and html templates', ->
        beforeEach ->
          @result = @instance.load 'html1', 'json.json'

        it 'returns both templates', ->
          expect(@result.length).to.equal 2

        it 'pushes the json obj to fixture.json', ->
          expect(@instance.json[0]).to.include json_data

    describe 'set', ->
      it 'accepts a string as first param and creates a dom element', ->
        @instance.set html_template1
        expect(@fixture_cont.innerHTML).to.equal html_template1

      it 'accepts an append boolean as second param', ->
        @instance.set html_template1, true
        expect(@fixture_cont.children.length).to.equal 1

      it 'appends new template to existing one if append is true', ->
        @instance.set html_template1, false
        @instance.set html_template2, true
        @instance.set html_template1, true
        expect(@fixture_cont.children.length).to.equal 4

      it 'replaces older templates with new one if append is false', ->
        @instance.set html_template1, false
        @instance.set html_template2, false
        @instance.set html_template1, false
        expect(@fixture_cont.children.length).to.equal 1

      it 'has a default value of false', ->
        @instance.set html_template1
        @instance.set html_template1
        expect(@fixture_cont.children.length).to.equal 1

      it 'appends and returns an array with a list of newly created dom nodes per template', ->
        dom_nodes = @instance.set(html_template2)

        expect(dom_nodes[0]).to.equal @fixture_cont.firstChild
        expect(dom_nodes[1]).to.equal @fixture_cont.firstChild.nextSibling

      it 'appends and returns an array of arrays of newly created dom nodes for multiple templates', ->
        dom_nodes = @instance.set(html_template1, html_template2)

        expect(dom_nodes[0][0]).to.equal @fixture_cont.firstChild
        expect(dom_nodes[1][0]).to.equal @fixture_cont.firstChild.nextSibling
        expect(dom_nodes[1][1]).to.equal @fixture_cont.firstChild.nextSibling.nextSibling

      it 'returns references to all firstChildren nodes created by the template', ->
        dom_nodes = @instance.set(html_template2)

        expect(dom_nodes.length)
          .to.equal(@fixture_cont.children.length)
          .to.equal(2)

      context 'when template contains <script> tags', ->
        beforeEach ->
          @result = @instance.set html_template3

        it 'places the script tag intact', ->
          expect(@fixture_cont.innerHTML).to.equal html_template3

        it 'executes the javascript', ->
          expect(window.test_a_test).to.equal true

      context 'when multiple templates are requested', ->
        beforeEach ->
          @result = @instance.set html_template1, html_template2

        it 'accepts multiple templates as params', ->
          expect(@fixture_cont.children.length).to.equal 3

        it 'returns multiple template\'s results in an array', ->
          expect(@result.length).to.equal(2)

        it 'returns references to all firstChildren nodes created by all the templates', ->
          expect(@result[1][1])
            .to.equal @fixture_cont.children[2]

    describe 'cleanup', ->
      beforeEach ->
        load_template_as_karma_html2js 'html1', html_template1
        load_template_as_karma_html2js 'html2', html_template2
        load_template_as_karma_html2js 'json.json', json_template

        @result = @instance.load 'html1', 'json.json'
        @instance.cleanup()

      afterEach ->
        cleanup_karma_html2js_templates()

      it 'resets @json to an empty array', ->
        expect(@instance.json)
          .to.be.an('array')
          .and.to.be.empty

      it 'empties fixture container', ->
        expect(@fixture_cont.innerHTML).to.equal ''

