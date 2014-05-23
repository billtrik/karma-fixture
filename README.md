karma-fixture [![Build Status](https://travis-ci.org/billtrik/karma-fixture.svg?branch=master)](https://travis-ci.org/billtrik/karma-fixture)
=============

A plugin for the Karma test runner that loads `.html` and `.json` fixtures.

It provides the same API as the teaspoon fixture package.

Installation
------------

Install the plugin from npm:

```sh
$ npm install karma-fixture --save-dev
```

Add `fixture` to the `frameworks` array in your Karma configuration:

```coffee
module.exports = (config) ->
  config.set

    # frameworks to use
    frameworks: ['mocha', 'fixture']

    # ...
```

You also have to register any/all fixtures in your Karma configuration:

(defaults to `spec/fixtures`)


```coffee
files: [
    {
        pattern: 'spec/fixtures/**/*',
    },

    # ...
],
```

Finally you have to add the html2js karma preprocessor:

```sh
$ npm install karma-html2js-preprocessor --save-dev
```

and then configure it Karma configuration to process all html and JSON files:

```coffee
preprocessors: {
    '**/*.html'   : ['html2js'],
    '**/*.json'   : ['html2js']
}
```


Implementation details
-----

All fixtures files are pre-loaded as strings as-well, and placed inside the Karma-created `window.__html__` array.

The fixture plugin is exposed in the `window.fixture` object on every test run. It loads fixture files from that array and appends the created html inside the `window.fixture.el` element that gets created on start-up.


Usage
------

Lets say you have the following fixture files:

- `spec/fixtures/test1.html`

    ```html
    <p>p</p>
    <a href='#'>
        <span>link</span>
    </a>
    ```

- `spec/fixtures/json/test1.json`
    ```javascript
    "{"test":true}"
    ```

So you can use `fixture` inside your tests.


```coffee
describe 'some test that needs a fixture', ->
  beforeEach ->
    @result = fixture.load('html_fixture', 'json_fixture')

  afterEach ->
    fixture.cleanup()

  it 'play with the html fixture', ->
    expect(fixture.el.firstChild).to.equal(@result[0][0])
```

API
-------

* `fixture.el`

  Reference to the container element. Inside this container element, all html fixture files get appended, after creation.

* `fixture.json`

  An array of all json objects created from fixture templates.


* `fixture.load(files..., append = false)`

  It takes multiple filenames as arguments and load them.
  It returns the loaded result, or an array of more than one loaded results

  It takes a boolean argument with default value `false`.
  If `false`, it empties the `window.fixture.el` container element and clears the `window.fixture.json` array.

  Scenarios:

  **html fixture**

  It returns an array of all the first-level nodes created by the fixture file:

  ```coffee
  html_fixture = fixture.load('test1.html')

  expect(html_fixture[0].innerHTML).to.equal('<p>p</p>')

  expect(html_fixture[1].innerHTML).to.equal('<a href='#'><span>link</span></a>')
  ```

  **JSON fixture**

  It returns a valid object by JSON.parsing the passed json fixture file.
  Also all JSON files loaded get appended to the `window.fixture.json` array:

  ```coffee
  json_fixture = fixture.load('json/test1.json')

  expect(json_fixture).to.eql({"test":true})

  expect(fixture.json[0]).to.eql({"test":true})
  ```

  **Multiple files**

  The result will be an array containing results of each loaded template:

  ```coffee
  loaded_fixtures = fixture.load('test1.html', 'json/test1.json')

  expect(loaded_fixtures[0][0].innerHTML).to.equal('<p>p</p>')

  expect(loaded_fixtures[0][1].innerHTML).to.equal('<a href='_'><span>link</span></a>')

  expect(loaded_fixtures[1]).to.eql({"test":true})

  expect(fixture.json[0]).to.eql({"test":true})
  ```


* `fixture.set(html_strings, append=false)`

  It takes multiple html_strings as arguments and load them.
  It returns the loaded result, or an array of more than one loaded results

  It takes a boolean argument with default value `false`.
  If `false`, it empties the `window.fixture.el` container element and clears the `window.fixture.json` array.


  ```coffee
  result = fixture.set('<h1>test</h1>')
  # and
  expect(result[0].innerHTML).to.equal('<h1>test</h1>')
  ```

* `fixture.clear()`

  It empties the `window.fixture.el` container element and clears the `window.fixture.json` array.



License
-------

The MIT License (MIT)
