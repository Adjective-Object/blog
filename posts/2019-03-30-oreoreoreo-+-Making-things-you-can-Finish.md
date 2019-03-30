---
title: 🍪 oreoreoreo + Making things you can Finish
tags: javascript
---

I've been spending the bulk of my dev time since last summer flutter app.

I'm the kind of person who ends up building frameworks and tooling for things when they work on a project long enough. I get a perverse satisfaction from ergonomic APIs and developer productivity.

But lately I've been craving the feeling of doing a thing, putting it out there, and being _done with it._

So anyway, check out [oreoreoreo](http://huang-hobbs.co/oreoreoreo/). it's a dumb meme site I made to generate cookies from that one oreo meme

<section class="columnSplit" style="display:flex;">
<section style="flex: 0.5">
![](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F95291386-31b9-4395-bd89-5e0190b4a450%2FUntitled.png)
</section>
<section style="flex: 0.5">
![](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fb3636914-0656-427c-9995-64c0f8d7b367%2FUntitled.png)

</section>
</section>

<section class="columnSplit" style="display:flex;">
<section style="flex: 0.5">
![](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F3be7eb0c-4648-4409-89ac-45229b566e27%2FUntitled.png)
</section>
<section style="flex: 0.5">
![](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fc06165c5-7030-41eb-bbbf-c7bbc8c9c7e1%2FUntitled.png)
</section>
</section>

## How it Works

oreoreoreo uses an [ohm-js](https://github.com/harc/ohm) grammar to parse the oreo tokens from an input string. Their [interactive editor](https://ohmlang.github.io/editor/) is great and you should give it a try.

The oreoreoreo grammar itself is pretty straightforward

```Plain Text
CookieGrammar {
    CookieStack = (Cookie | Cream)*
    Cookie = "o" ("r" ~ "e")*
    Cream = "r" "e"+
}
```

Two notable expansions on the template "oreo meme" grammar were

- Thicker cream can be made by an `r` followed by repeating `e`s


- Thicker cookies can be made with an `o` followed by repeated `r`s.
  - This means that the meaning of the `r` will change from "part of a cookie" to "part of cream" based on if it is followed by an `e` or not.
  



That gets translated into a a whole lot of DOM elements

```HTML
<section class="oreoreo-display" id="oreoreo-host">
  <section style="z-index: 1000" class="biscuit cookie">
    <section class="segment"></section>
    <section class="segment"></section>
    <section class="segment"></section>
  </section>
  <section style="z-index: 999" class="biscuit filling">
    <section class="segment"></section>
    <section class="segment"></section>
  </section>
  <section style="z-index: 998" class="biscuit cookie">
    <section class="segment"></section>
    <section class="segment"></section>
  </section>
</section>
```

And then styled and spaced relative to one another appropriately with CSS adjacency selectors.



All that just to generate some dumb meme images.



I hope you enjoy it!

