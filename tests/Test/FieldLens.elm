module Test.FieldLens exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, list, int, string, map, tuple)
import Test exposing (..)
import FieldLens exposing (..)


type alias Point =
    { x : Int, y : Int }


point : Fuzzer Point
point =
    map (\xy -> Point (Tuple.first xy) (Tuple.second xy)) <| tuple ( int, int )


type alias Player =
    { pos : Point }


fplayer : Fuzzer Player
fplayer =
    map Player point


type alias Game =
    { player : Player }


game : Fuzzer Game
game =
    map Game fplayer


x : FieldLens { b | x : a } a a { b | x : a }
x =
    FieldLens .x (\a r -> { r | x = a })


y : FieldLens { b | y : a } a a { b | y : a }
y =
    FieldLens .y (\a r -> { r | y = a })


pos : FieldLens { b | pos : a } a a { b | pos : a }
pos =
    FieldLens .pos (\a r -> { r | pos = a })


player : FieldLens { b | player : a } a a { b | player : a }
player =
    FieldLens .player (\a r -> { r | player = a })


origin : Point
origin =
    Point 0 0


suite : Test
suite =
    describe "The FieldLens module"
        [ describe "set tests"
            [ fuzz int
                "Update x field correctly"
                (\a -> Expect.equal (set x a origin) { origin | x = a })
            , fuzz int
                "Update y field correctly"
                (\a -> Expect.equal (set y a origin) { origin | y = a })
            , fuzz point
                "Test get x and y correctly"
                (\p -> Expect.equalLists [ p.x, p.y ] [ get x p, get y p ])
            , fuzz point
                "Test modify correctly"
                (\p -> Expect.equal ( modify x ((+) 1) p, modify y (\i -> i - 1) p ) ( { p | x = p.x + 1 }, { p | y = p.y - 1 } ))
            , fuzz game
                "Test compose"
                (\g -> Expect.equal (get (compose (compose player pos) x) g) (g.player.pos.x))
            , fuzz game
                "Test composep with pipes"
                (\g -> Expect.equal (get (player |> composep pos |> composep x) g) (g.player.pos.x))
            ]
        ]
