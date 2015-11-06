karma-fixture [![Build Status](https://travis-ci.org/billtrik/karma-fixture.svg?branch=master)](https://travis-ci.org/billtrik/karma-fixture) [![NPM version](https://badge.fury.io/js/karma-fixture.svg)](http://badge.fury.io/js/karma-fixture)
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

```javascript
module.exports = function(config){
  config.set({
    // ...
    frameworks: ['mocha', 'fixture'],
    // ...
```

You also have to register any/all fixtures inside your Karma configuration file.
If all your fixtures exist under a `fixtures/base/path/` folder, then you should include
all files of interest under this base path.


```javascript
module.exports = function(config){
  config.set({
    // ...
    files: [
      {
        pattern: 'fixtures/base/path/**/*',
      },
      // ...
    ],
    // ...
],
```

Finally you have to add the `html2js` and `karma-json-fixtures-preprocessor` karma preprocessors:

```sh
$ npm install karma-html2js-preprocessor --save-dev
$ npm install karma-json-fixtures-preprocessor --save-dev
```

, configure Karma to load all html and JSON fixture files via those preprocessors:

```javascript
module.exports = function(config){
  config.set({
    // ...
    preprocessors: {
      '**/*.html'   : ['html2js'],
      '**/*.json'   : ['json_fixtures']
    },
    // ...
```

and then setup the `karma-json-fixtures-preprocessor` plugin:

```javascript
module.exports = function(config){
  config.set({
    // ...
    jsonFixturesPreprocessor: {
      variableName: '__json__'
    },
    // ...
```

*(optional)* If the plugins won't get loaded by karma, you might have to declare them inside the `plugins` array in your Karma configuration
*(and maybe load `karma-html2js-preprocessor` as well)*:

```javascript
module.exports = function(config){
  config.set({
    // ...
    plugins: [
      'karma-fixture',
      'karma-html2js-preprocessor',
      'karma-json-fixtures-preprocessor',
      // ...
    ],
    // ...
```

Implementation details
-----

All html fixture files are pre-loaded as strings and placed inside the Karma-created `window.__html__` object and all json fixtures are loaded inside 
`window.__json__`.

The fixture plugin is exposed in the `window.fixture` object on every test run.
It loads fixture files from these objects and appends the created html inside the `window.fixture.el` element that gets created on start-up. It appends loaded JSONs inside the `fixture.json` array.


Usage
------

Lets say you have the following fixture files:

- `fixtures/base/path/test1.html`

    ```html
    <p>p</p>
    <a href='#'>
        <span>link</span>
    </a>
    ```

- `fixtures/base/path/json/test1.json`
    ```javascript
    "{"test":true}"
    ```

You can use `fixture` inside your tests to handle the fixtures:


```javascript
describe('some test that needs a fixture', function(){
  // If base path is different from the default `spec/fixtures`
  before(function(){
    fixture.setBase('fixtures/base/path')
  });

  beforeEach(function(){
    this.result = fixture.load('test1.html', 'test1.json');
  });

  afterEach(function(){
    fixture.cleanup()
  });

  it('plays with the html fixture', function(){
    expect(fixture.el.firstChild).to.equal(this.result[0][0]);
  });

  // ...
});
```

API
-------

* `fixture.el`

  Reference to the container element. Every html fixture loaded gets appended inside this container.

* `fixture.json`

  An array of all json objects imported from fixture templates.


* `fixture.load(files..., append = false)`

  It takes multiple filenames as arguments. All filenames are loaded from within the base path.

  It loads and appends them inside the fixtures container element.
  It returns an array with references to the newly created first level html elements.
  When more than one are loaded, it returns an array of the above described format, for each loaded fixture.

  It takes an optional boolean argument which defaults to `false`.
  If `false`, it empties the `window.fixture.el` container element and clears the `window.fixture.json` array.
  If `true`, it just appends the requested fixture to the container.

  If your fixtures exist in a base path other than the default `spec/fixtures`,
  you should call `fixture.setBase('fixtures/base/path')` in your specs, or load them
  with their full, base included, filenames prefixed with a '/'.

  For example: `fixture.load('/my/other/base/path/fixture1.html')`

  Scenarios:

  **html fixture**

  It returns an array of all the first-level nodes created by the fixture file:

  ```javascript
  html_fixture = fixture.load('test1.html');
  // then
  expect(html_fixture[0].innerHTML).to.equal('<p>p</p>')
  // and
  expect(html_fixture[1].innerHTML).to.equal('<a href="#"><span>link</span></a>')
  ```

  **JSON fixture**

  It returns a valid object by JSON.parsing the passed json fixture file.
  Also all JSON files loaded get appended to the `window.fixture.json` array:

  ```javascript
  json_fixture = fixture.load('json/test1.json')
  // then
  expect(json_fixture).to.eql({"test":true})
  // and
  expect(fixture.json[0]).to.eql({"test":true})
  ```

  **Multiple files**

  The result will be an array containing results of each loaded template:

  ```javascript
  loaded_fixtures = fixture.load('test1.html', 'json/test1.json')
  // then
  expect(loaded_fixtures[0][0].innerHTML).to.equal('<p>p</p>')
  // and
  expect(loaded_fixtures[0][1].innerHTML).to.equal('<a href="#"><span>link</span></a>')
  // and
  expect(loaded_fixtures[1]).to.eql({"test":true})
  // and
  expect(fixture.json[0]).to.eql({"test":true})
  ```


* `fixture.set(html_strings, append=false)`

  It takes multiple html_strings as arguments and load them.
  It returns the loaded result, or an array of more than one loaded results

  It takes a boolean argument with default value `false`.
  If `false`, it empties the `window.fixture.el` container element and clears the `window.fixture.json` array.


  ```javascript
  result = fixture.set('<h1>test</h1>')
  // then
  expect(result[0].innerHTML).to.equal('<h1>test</h1>')
  ```

* `fixture.cleanup()`

  It empties the `window.fixture.el` container element and clears the `window.fixture.json` array.

* `fixture.setBase(fixtureBasePath)`

  It set the base path under which all forthcoming fixtures will be loaded.
  This can be bypassed by loading a fixture with its full, base included, filename prefixed with a '/'.


License
-------

The MIT License (MIT)
