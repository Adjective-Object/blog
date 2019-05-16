---
title: Downloads and Drag-Drop in radial-dots
tags: rust, personal, toys, dev
---

I recently pushed an update to [radial dots](http://huang-hobbs.co/radial-dots/) that lets you save the document you're editing to an SVG, with the document's state embedded in it. This is similar to the approach I took for [dots](http://huang-hobbs.co/dots/), but took significantly more work to accomplish in the framework.

## Downloading : A Difference in Approach

Yew is built around message passing — state manipulation code lives in a separate worker than the event handlers. Access to the state is encouraged only inside the `update` method of a component.

This makes the [original approach](https://github.com/Adjective-Object/dots/blob/1.0/FormDrawing.js#L53-L72) of interrupting the mouse click event and serializing the link target feel out of place in yew.

Instead, `dots` takes the approach of [rendering the document to a link href](https://github.com/Adjective-Object/radial-dots/blob/1.0/src/components/app.rs#L399-L405) whenever the model is updated.

This simpler and fits with yew's model a little better, but it's less efficient at runtime since we are now performing more DOM updates than we would otherwise need to.

## Drag and Drop : `async` Hell

The biggest issue I ran into while trying to implement this was the problem of callbacks in `stdweb`.

Any callback in stdweb must have a static lifetime. Conceptually that makes sense — the browser makes no guarantees as to when a callback is invoked, so there's no reason to expect that the data you're pulling on isn't already cleaned up then.

This was specifically a problem for me because of FileReader, since the filereader api uses an event-based API.

1. The consumer registers a callback for the 'loadend' event


1. The consumer reads the contents of a file


1. an event is emitted on the FileReader and consumed by a callback handler.


Since the callback needs to read from the FileReader, but the FileReader needs to be moved from the stack into the callback for the callback to be static, this ends up in a bit of a catch-22 situation 

After poking around with a hack involving global refs I [reached out for some help from the maintainers of stdweb](https://github.com/koute/stdweb/issues/338). Objects in stdweb have reference semantics, and are just referencing objects in javascript shim functions. The solution was to [clone the reader](https://github.com/Adjective-Object/radial-dots/blob/1.0/src/components/app.rs#L265-#L295) and operate on the clone in the callback.

As far as I can tell this is the preferred way to access "browser-native" APIs from wasm, as [wasm doesn't even have dom access yet](http://webassemblycode.com/webassembly-cant-access-dom/)... But I don't know for sure. I still have open questions about how those browser objects end up being memory managed. If there's one thing this project has revealed to me, it's that I need to do deeper reading on both rust and the webassembly runtime.

## A Dirty Hack

While the problem with FileReader was solved, I still need to emit an event against the `App` struct in a `'static` lifetime callback. In the existing code, I accomplish this by taking an unsafe static ref to the app and storing it globally.

On thinking about this in retrospect, it might be doable by enforcing a 'static lifetime on all apps — I'm not so sure what kind of lifetime requirements yew enforces on the component. Seems like a nice way to clean things up

## Wrapping up

I'm still not 100% happy with my solution, but it works, and it's done enough that I don't plan on digging back into it.

I suppose part of the point of trying new things on small isolated projects is that the mistakes won't haunt me forever.

