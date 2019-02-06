class-name
===========
A simple utility function for generating a string for use as a DOM element's
`className`.

The library is intended for use with React but is simple enough to be useful in
any situation where you just want to build a className string.

**To install:** `npm install class-name --save`.

API
===
`class-name` exports two functions:

 * `className(...classNames:ClassNameValue):className` (*default export*) creates a className
   object populated with the *ClassNameValue*s.

 * `PropType(props:object, propName:string):void` - A React propType validator for valid *ClassNameValue*s.

To use, simply import the library in to your project, for example with ES6 modules:

```js
import className, { PropType } from 'class-name'
```

### className(...className:ClassNameValue):className

This function accepts any number of valid *ClassNameValue*s as arguments
(read below to see what we consider a valid *ClassNameValue*).

 * `add(...className:ClassNameValue):className` - attempts to update the current
   list of class names to include the provided *ClassNameValue*s.

   Because className objects are immutable, if the class names list is changed,
   a new `className` will be returned and the original object will remain
   untouched. If no changes are made, the existing `className` will be returned.

 * `has(className:string)` - returns `true` if the string is in the list of class
   names, `false` if not.

 * `toString():string` - returns a string of the joined class names for use
   with a DOM element.

 * `toClassList():array` - returns an array of the unique class names.

    Warning: This function currently returns the data structure used by the
    function internals for efficient className composition — do not mutate this
    value directly unless you're looking for weird behaviour ;)

### PropType(props:Object, propName:String):void

For use with React as a PropType validator. This function will make sure the
prop value is considered a valid *ClassNameValue*. If the prop is valid, the
function will be void (i.e. return  `undefined`), if not, it will throw an
`Error`. See the **React PropType** section for how to use this.

# ClassNameValue

In the scope of the library, a valid *ClassNameValue* is considered any of the
following:

  * **A plain string or number (will be casted to a string).**

   ```js
    className("hello") // "hello"

    className(1) // "1"
   ```

  * **An object with a `toClassList` method (which should return an array)** - e.g. a `className` instance.

    ```js
    className('button', className('big')) // "button big"
    ```

  * **A plain object mapping class name prefixes to a valid class name value.**

    ```js
    className({ hello: 'world' }) // "hello-world"
    ```

  * **A plain object mapping class name prefixes to a truthy value** — if the value
    is truthy, the key will be included in the class name list. If not, it will
    be ignored.

    ```js
    className({ hello: true, world: false }) // "hello"
    ```

  * **An array of valid *ClassNameValue*s.**

   ```js
    className(["hello", { "world": true }]) // "hello world"
    ```

# Test coverage

None at the moment, sorry! :-(

# Using an object as a *ClassNameValue*

When you pass an object as a  *ClassNameValue*, the object's keys will be used
as a prefix to the values (the object values will just be treated as *ClassNameValue*s).

# Example outputs

```js
className('a').toString() // "a"
className('a', 'b').toString(); // "a b"
className(['a', 'b']).toString(); // "a b"
className('a', ['b', 'c']).toString(); // "a b c"
className('a', { b: true }).toString(); // "a b"
className('a', { b: 'c' }).toString(); // "a b-c"
className('a', { b: { c: true } }).toString() // "a b-c"
className('a', { b: { c: ['d', 'e', 'f' ] } }).toString() // "a b-c-d b-c-e b-c-f"

const blueButton = className('button', 'blue');
const bigBlueButton = className(blueButton, 'big');

bigBlueButton.toString(); // "button blue big"
```

# React PropType

When using React, you're most likely going to want to accept a className as a
component prop at some point. The library provides a simple `PropType` function
which you can use to ensure the prop you receive can be handled via `class-name`.

Example:
```js
import React, { Component } from 'react';
import { className as ClassName, PropType as classNamePropType } from 'class-name';

class ButtonComponent extends Component {
  static propTypes = {
    className: classNamePropType
  };

  render() {
    const className = ClassName('button', this.props.className);

    return (
      <button className={className}>
        {this.props.children}
      </button>
    );
  }
}

class FooComponent extends Component {
  render() {
    return (
      <ButtonComponent className="foo-button">
        Click me!
      </ButtonComponent>
    );
  }
}
```
