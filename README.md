# elm-fields: First Class Fieldnames [![Build Status](https://travis-ci.com/sjorn3/elm-fields.svg?token=yqduYxjYcVhWa7fwLx3k&branch=master)](https://travis-ci.com/sjorn3/elm-fields)
This library provides a system for passing field names as arguments to functions
and also applying updates to fields with a clean syntax.

## Why use them?

- Create functions which are general across the field that they make alterations
  to.
- Easily readable syntax:
  - `reset        = set num_lives 10`
  - `addOne field = modify field ((+) 1)`
  - `addLife player = addOne num_lives player`
- Compose them with `compose` (`<-<` or `>->`) to access and modify elements of
  deeply nested records with a smaller code size.
  - ``setX n = set (pos >-> x) n`` 
- Although intended for records, the the underlying lenses are general enough
  for any data type. 

## Game Example

```elm
import FieldLens exposing (..)
```

Let's start by defining some simple player types for a potential game.

```elm
type alias Player =
    { name : String, num_lives : Int, ammo : Int }


type alias Enemy =
    { name : String, num_lives : Int, ammo : Int }
```

We need to now define our lenses for the fields. They are defined in the form
`FieldLens get set`, so all that needs to be defined is a getter and a setter.

The names are defined once and for all and are completely boilerplate, so let's
define them right away and get it over with. Hopefully in the future this
process will be completely automated. 
```elm
name      = FieldLens .name      (\a r -> { r | name =      a })
num_lives = FieldLens .num_lives (\a r -> { r | num_lives = a })
ammo      = FieldLens .ammo      (\a r -> { r | ammo =      a })
```
 
## Usage
Below is simply a list of examples of potential scenarios in the game and how
they can be dealt with using first class fields.

```elm
{-| Imagine we have a list of enemies in play, and we want to find all of their
names, we can do this with a simple List.map.
-}
getEnemyNames : List Enemy -> List String
getEnemyNames =
    List.map (get name)


{-| The same function can be defined for players with only a change to the type.
In fact, you can define one getNames function for both enemies and players, or
any record that has the `name` field.

This is true for all of the functions in this example.
-}
getNames : List { b | name : a } -> List a
getNames =
    List.map (get name)


{-| However, this is not different to using `List.map .name`, so what can we
do that we could already? You might want to reset all of the enemies ammo
to 20 at the start of a new round. 
-}
resetEnemies : List Enemy -> List Enemy
resetEnemies =
    List.map (set ammo 20)


{-| Let's say your player gets hit! We must reduce their number of lives,
which can be done with a call to `modify`
-}
playerHit : Player -> Player
playerHit =
    modify num_lives (flip (-) 1)


{-| Or if you have a list of enemies and you just hit them all in one shot,
you might want to modify all of their lives in one go
-}
attackAllEnemies : List Enemy -> List Enemy
attackAllEnemies =
    List.map (modify num_lives (flip (-) 1))
```
## Field passing

Here are a couple of slightly more complex examples of functions which take
a field and access it.

```elm
{-| If you're debugging and want to print some stats to the screen, you might
want to stringify one particular field, which is where using a field as an
argument comes in handy.
-}
toStringField : FieldLens a b c d -> a -> String
toStringField field = toString << get field

{-| You could also define a function which takes the field and turns it into
a string in a similar way using modify
-}
fieldToString : FieldLens a b String d -> a -> d
fieldToString field = modify field toString
```