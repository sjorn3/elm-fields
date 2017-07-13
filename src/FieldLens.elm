module FieldLens exposing (FieldLens, get, set, modify, compose, (>->), (<-<))

{-| A module that allows field names to become parameters to functions. That is,
a module which provides first class field names.

These operations are intended for use with field names, but the types are
general enough for integration with other data types should the need arise.

# Field Lenses

@docs FieldLens

# Manipulating Fields

@docs get, set, modify

# Composing field names

@docs compose, (>->), (<-<)
-}


{-| A record that provides a getter and setter function. Allows for the fact
that fields can change their type.

Definitions of the this type will be boilerplate, and will all have a form like
this:

    field_name = { .field_name, (\a r -> { r | field_name = a })}

This example leverages the fact that the field_name can be used as both the
record's name and the field, but it could be called anything.
-}
type alias FieldLens a b c d =
    { get : a -> b, set : c -> a -> d }


{-| Synonym for `.get`. Allows for slightly nicer usage of the field name.

    get num_lives player == 5

-}
get : FieldLens a b c d -> a -> b
get =
    .get


{-| As with `get`, this is simply a synonym for `.set` and allows for slightly
nicer usage of the field name.

     set num_lives 10 player == { num_lives = 10, ... }

-}
set : FieldLens a b c d -> c -> a -> d
set =
    .set


{-| Allows applying an update function to the specific field of the record.

    modify num_lives ((+) 1) player == { num_lives = 11, ... }

-}
modify : FieldLens a b c d -> (b -> c) -> a -> d
modify field f record =
    set field (f <| get field record) record


{-| Compose field names, useful when records are nested.

    player : { pos : { x : Int, y : Int }}
    player = Player (Pos 0 0)

    set (compose pos x) 10 player == Player (Pos 10 0)

-}
compose : FieldLens a b d e -> FieldLens b c g d -> FieldLens a c g e
compose a b =
    FieldLens (get a >> get b) (\x r -> set a (set b x <| get a r) r)



--infixr 5 (<-<)


{-| Right associative infix synonym for compose.

    set (x <-< pos) 10 player == Player (Pos 10 0)
-}
(<-<) : FieldLens b c g d -> FieldLens a b d e -> FieldLens a c g e
(<-<) =
    flip compose



--infixl 5 (>->)


{-| Left associative infix synonym for compose.

    set (pos >-> x) 10 player == Player (Pos 10 0)
-}
(>->) : FieldLens a b d e -> FieldLens b c g d -> FieldLens a c g e
(>->) =
    compose
