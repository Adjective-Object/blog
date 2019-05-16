---
title: Rust, Wasm, and a new Tattoo
tags: rust, personal, toys, dev
---

tl;dr I made [this thing](http://huang-hobbs.co/radial-dots) and I'm going to use it to make myself a new tattoo.

It might look something like one of these:

<section class="columnSplit" style="display:flex;"><section style="flex: 0.3333333333333333; padding: 0.5em">
!["live/and let/live"](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F79e3783f-9d33-4444-bacd-616227b909bd%2FUntitled.png)

</section>
<section style="flex: 0.3333333333333334; padding: 0.5em">
!["try/to keep/up"](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F85e14e7c-4bcc-455a-b73f-757d2e44f680%2FUntitled.png)

</section>
<section style="flex: 0.3333333333333333; padding: 0.5em">
!["?/aurora/borealis"](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fe1d24bf2-6003-425c-baf5-aa0d1d4ce90e%2FUntitled.png)

</section></section>

---


I've been looking for an excuse to use rust for a project for a while now. I've also been thinking I might get a second tattoo soon, so why not tackle both goals at once.

## Motivation

I've always liked the idea of text encoded into interesting patterns for tattoo designs. 1-2 colour graphic tattoos are up my alley visually, but a lot of the designs are pulled from colonized peoples, and being A Tech Bro With A Tribal Tattoo always put me off the idea.

To avoid a design totally divorced from its original cultural context, I thought a simple graphical text cypher would be a nice way to have a tattoo that was more than just some cool lines.

I made [the original dots tool](http://huang-hobbs.co/dots/) to design my first tattoo while stuck on planes flying back and fourth between California and Toronto for contract jobs. It was scrapped together pretty quickly.

I was hoping to slap something together quickly just as a way to learn rust, but while the initial learning curve for rust is a lot better now than when they had n-different types of pointers, it's still not 100% straightforward.

## The Easy Part

I pretty quickly had the data model for my diagram and a function to render it to an SVG string. Nice! No real complaints about that. The borrow checker is pretty unobtrusive when you're working with immutable references and producing new values.

## Trying to render a UI and virtual_dom_rs

The original `dots` was written with simple event handlers and pulled a lot of information from annotations in the HTML dom itself. Looking at the api for dealing with js values made it seem really cumbersome.

It looked like pretty much every framework out there was pretty early stages and offering slightly different models. the pitch of lightweight "pay for what you use" code that all the wasm-bindgen based frameworks were making.

- I was a little put-off by the bootstrapping code you need to write to load a wasm module and deal with it. 


- debugging wasm-pack'd code is needlessly difficult because there are no sourcemaps and panic doesn't preserve error messages


At the end of the day, `virtual_dom_rs` was crashing out during patching under what seemed like they should have been safe circumstances. The internet had nothing to say, and there weren't any relevant open github issues.

Time to pack it up and move to a slightly less buggy framework

## Picking up a framework at random

I picked `yew` because

- It had minimal up front work.


- It had html macro templating that supported dropping in components.


- It came with a prescribed state management, and I was concerned about other things.


Yew was comfortable to work with. It got me to a place where I was actually building interactions quickly but I came up against a few unintuitive problems

- callbacks have to be bound inline, and can't be passed in via bound locals — the templating tools look specifically for a lambda in the attribute and the result is parsed into different function calls. `cargo expand` keyed me off on that.


- Component names have to be suffixed with `:` when being used in an `html{` macro. 


- There doesn't seem to be a concept of separate props and state, so each component reading from a larger data model ended up copying its props into the state.


- I wasn't able to figure out how to put a ref into a component struct. Because my data model had a lot of shared data, I ended up copying things around a lot at prop barriers.


As a new user to rust, debugging macros was a major pain point for me. Entire `html` blocks would light up as erroring whenever there was an error in the macro. I'm assuming the macros don't have access to type information, because there are a lot of awkward workarounds to deal with handling of types compared to JSX.

Yew seems to be set up to solve some of these problems soon in the future (they have Renderable set up different from Component, and it looks like they're going to set up some kind of stateless component system which should solve a lot of the issues I've been having with it.

## Bundle Size

By default, `cargo-web` builds in dev mode.

![The application built in debug mode is 2.4 MB\](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F8c155f7b-d6a4-4a7f-81d1-3e0e18bbaba6%2FUntitled.png)

Building with `cargo web deploy --release` cutts that immediately to 408k

You can further optimize automatically with `wasm-opt` from [`binaryen`](https://github.com/WebAssembly/binaryen) .

```Bash
nix-env -iA nixpkgs.binaryen

wasm-opt -Oz \
    -o ./target/deploy/radial_dots_compressed.wasm \
    ./target/deploy/radial_dots.wasm
```



![After optimization steps, the non-gzipped wasm is 256k.](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Ffd487727-c48f-484b-9071-5a8a5d448b5d%2FUntitled.png)

The overall size is still an order of magnitude larger than the handwritten js for `dots`. I think the added complexity of having multiple layers of text made a component library a natural thing to structure my work around.

I'm curious what the bundlesize would have come out to had used a different library as a starting point. I think this whole experience has gotten me interested in the prospect of trying out `seed` or `quasar` next, if I can think of something sufficiently small so as to be a good learning project.

## Next Up 

### CI/CD

I spent some time trying to get the project to build with nixpkgs. but `cargo-web` is out of date in nixpks master, and its dependencies weren't available when I did the traditional nixpkgs version override.

### Export

One of the really nice features I put in the original dots was svg import / export with some additional data added to the saved SVG with the settings for the diagram.

Maybe I'll get around to doing that. I've seen `serde` used around a lot so if I'm going to be using rust at all I should probably learn its de-facto json library.

### Getting a Tattoo

I like a lot of the designs I've been getting out of this thing. I think I might go for a mixed illustration + graphical approach to this next one. Leave some negative space in the middle and fill it in with some line-work in a different colour.

<section class="columnSplit" style="display:flex;"><section style="flex: 0.33333333333333337; padding: 0.5em">
!["I/know/enough"](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F39e67ca7-9751-4efa-b659-e49855caeac2%2FUntitled.png)

</section>
<section style="flex: 0.33333333333333337; padding: 0.5em">
![";)/;^)"](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fc0536477-0dd0-464e-8ee5-97f642c968c0%2FUntitled.png)

</section>
<section style="flex: 0.3333333333333333; padding: 0.5em">
!["sugar/oh/honey/honey"](https://www.notion.so/signed/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F1fbc88d9-e465-4da0-9cd5-7eff2c788cec%2FUntitled.png)

</section></section>



