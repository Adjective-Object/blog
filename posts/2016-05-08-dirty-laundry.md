---
title: Coping with Dirty Code
tags: code quality, culture
---

Code cleanliness is one of those things people like to talk a lot about. Programmers never seem to stop talking about a million different ways to simplify thinking about problems. Whenever I read [lobste.rs](https://www.lobste.rs) or [hackernews](https://news.ycombinator.com), it feels like half the posts try to sell me on some new code pattern, and the other half complain about how some other pattern is 'considered harmful'.



This weekend I wrote what may be some of the dirtiest, hackiest garbage I have written since high school. I participated in [TOJam 11](http://www.tojam.ca/), and my team made a simple adventure game in C# & XNA — A language I am not familiar with, using a library I was am not familiar with. The end result was a mixed bag of hidden state and half-baked abstractions, including but not limited to:

- A number of singletons that permitted multiple instances
- Arbitrary field visibilities (just put `public` everywhere!)
- A system for managing game states that was only used once
- Two separate `Input` singletons
- Constructors taking an enum and crashing on all but one possible enum value.
- A combined entity-subclass & entity-component model 
- Objects that were their own factories

It felt gross.

It felt really, _really_ gross.

There were weird bugs that took longer than I would have liked to track down, and most of the time I had to keep large interacting systems in my head to write anything.

If I'm being honest with myself, most of it was caused by my own half-baked abstractions. I tried to build a nice system underneath the character interactions, but when I ran into a roadblock under time pressure I opted for quick patches instead of the time consuming process of rethinking and restructuring the engine.



## The Other Side of the Coin

I'd like to take a second to talk about my friend Tyler. He's almost completely self-taught, and uses XNA on a daily basis as an independent game developer. Tyler prefaced working together at TOJam by saying that he didn't want our code to interface in any way. He ended up writing isolated minigames inside our end project.

Each minigmame was several thousand lines of if/else statements, and integers used as flags. Lots of duplicated logic and little to no compartmentalization of the parts.

The thing is, it didn't matter that it was 'messy'. It worked just as well as the code anyone else wrote. It was finished in the timespan of the jam, and as far as I can tell, he wrote it without even having to think that hard.

This approach is so radically foreign to me. The fact that it works at all feels strange.

## Takeaway

Most of the programmers I know emphasize good design and removing as much replicated behavior as possible from their applications. However, I'm beginning to think that under steep time constraints it might be better to abandon the urge to write pristinely clean systems. Good system design is a thoughtful and time-consuming process, and it's better to write specialized code than wrangle with a system of poorly generalized logic.

I guess what I'm trying to say is that sometimes it's okay to let go of your urge to abstract and just write some shit.

#### tl;dr good code considered harmful
ps, [download our game](https://github.com/Adjective-Object/tojam11/releases/tag/0.1)