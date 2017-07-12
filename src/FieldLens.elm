module FieldLens exposing (..)

{-| A module that allows field names to become parameters to functions. That is,
a module which provides first class field names.

These operations are intended for use with field names, but the types are
general enough for integration with other data types should the need arise.

@docs Field, set, get, rw

-}


{-| A record that provides a getter and setter function. Very similar to the
interface of a Lens except slightly generalised to allow for the fact that
fields can change their type.

Definitions of the this type will be boilerplate. For example:

```
type alias Model {
  field_name : String
}

field_name = { .field_name, (\a r -> { r | field_name = a })}
```

Notice that the fields name can be reused.
-}
type alias FieldLens a b c d =
    { get : a -> b, set : c -> a -> d }

{-|
Simply a synonym for `.get`. Allows for slightly nice usage of the field name.
```
get field_name record
```
-}
get : FieldLens a b c d -> a -> b
get =
    .get

{-|
As with `get`, this is simply a synonym for `.set` and allows for slightly nicer
usage of the field name.
```
set num_lives 10 player
```
-}
set : FieldLens a b c d -> c -> a -> d
set =
    .set

{-|
Allows applying an update function to the specific field of the record.
-}
map : FieldLens a b c d -> (b -> c) -> a -> d
map field f record =
    set field (f <| get field record) record

{-|
Compose field names, useful when records are nested.
-}
compose : FieldLens a b d e -> FieldLens b c g d -> FieldLens a c g e
compose a b = FieldLens (get a >> get b) (\ x r -> set a (set b x <| get a r) r)