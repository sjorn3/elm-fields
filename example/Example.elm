module Example exposing (..)

import FieldLens exposing (..)


{-| Let's start by defining some simple player types for a potential game.
-}
type alias Player =
    { name : String, num_lives : Int, ammo : Int }


type alias Enemy =
    { name : String, num_lives : Int, ammo : Int }


{-| We need to now define our lenses for the fields.

The names are defined once and for all, so let's create them right away.

-}
name =
    FieldLens .name (\a r -> { r | name = a })


num_lives =
    FieldLens .num_lives (\a r -> { r | num_lives = a })


ammo =
    FieldLens .ammo (\a r -> { r | ammo = a })


anger =
    FieldLens .anger (\a r -> { r | anger = a })


{-| Below is simply a list of examples of potential scenarios in the game and how
they can be dealt with using first class fields.

Imagine we have a list of enemies in play, and we want to find all of their
names, we can do this with a simple List.map

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


{-| Or maybe a new round starts and you want to set all of the enemies ammo
to 10
-}
resetEnemies : List Enemy -> List Enemy
resetEnemies =
    List.map (set ammo 20)


{-| Let's say your player gets hit! We must reduce their number of lives,
which can be done with a call to `modify`
-}
playerHit : Player -> Player
playerHit =
    modify num_lives ((-) 1)


{-| Or if you have a list of enemies and you just hit them all in one shot,
you might want to modify all of their lives in one go
-}
attackAllEnemies : List Enemy -> List Enemy
attackAllEnemies =
    List.map (modify num_lives ((-) 1))
