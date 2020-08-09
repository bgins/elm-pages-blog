---
{
  'type': 'blog',
  'author': 'Brian Ginsburg',
  'title': 'minima',
  'description': 'Minima is a minimalist web audio playground',
  'image': 'images/blog/minima/minima.png',
  'draft': false,
  'published': '2017-06-20',
}
---

Minima is simple web audio application for experimenting with minimalist music
patterns. Minima is written in Elm and JavaScript.

[Try minima here](https://minima.brianginsburg.com).

## Audio

Minima uses a simple web audio synthesizer written in JavaScript. The Elm
application treats the synthesizer as “hardware” and sends it note messages
through ports provided by the Elm architecture.

## Model

The minima model consists of a `score`, `ticks`, `clock`, and voices.

```elm
type alias Model =
    { score : Score
    , ticks : Int
    , clock : Int
    , one : Voice
    , two : Voice
    , three : Voice
    , four : Voice
    }
```

Minima plays notes from the `score`. The `clock` tracks the current beat up to `ticks` before
returning to 1. On each tick of the `clock`, minima plays all notes in the `score` with a
matching value for `ticks`. Each note has a `frequency`, `duration`, and `tick`.

```elm
type alias Score =
    List Note

type alias Note =
    { frequency : Float
    , duration : Int
    , tick : Int
    }
```

A `Voice` has a `pattern` of notes and a `frequency`. A `Pattern` is a list of actions, which are
read into the `score` as notes or dropped as rests. The option is represented with an algebraic
data type `Action`.

```elm
type alias Voice =
    { id : String
    , frequency : Float
    , pattern : Pattern
    }

type alias Pattern =
    List Action

type Action
    = Play Int
    | Rest Int
```

## More on Minima

Minima was my final project in the Spring 2017 Functional Languages course at
Portland State University. The [source code](https://github.com/bgins/minima)
is available on GitHub.
