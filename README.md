# com-lang
iced-coffee-script with extended syntax for CoffeeKup-like components

Main purpose of this module: write less code

Inspired by [CoffeeKup](http://coffeekup.org/)


**NOTE**. This is not fully ready to use template engine. This is part of toolchain that helps use CoffeeKup-like syntax with react.

# Short motivation

CoffeeKup (before)

    html ->
      head ->
    

com-lang (after)

    html
      head
    
# More examples

    html
      head
      body
        a {href:"/home"}
        p {style:
          color: "#aaa"
        }
          "text"
    
# How to use with react
see https://github.com/hu2prod/webcom-hello-world
