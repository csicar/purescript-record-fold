module Data.Record.Map where


import Prelude

import Data.Array (cons)
import Data.Symbol (class IsSymbol, SProxy(..), reflectSymbol)
import Data.Tuple (Tuple(..))
import Prim.Row (class Lacks, class Cons)
import Prim.RowList (class RowToList, Cons, Nil, kind RowList)
import Record (delete, get, insert)
import Type.Data.RowList (RLProxy(..))
import Type.Equality (class TypeEquals, to)

-- | Implement this class to create a new way of mapping records:
--| ```purescript
--| data MapToLength = MapToLength
--| instance MapToLengthMapper ∷ Show a => Mapper MapToLength a Int where mapValue = show >>> length
--| ```
-- | `MapToLength` can now be used in `map`
class Mapper mapper a b | mapper a -> b where
  mapValue :: mapper -> a -> b


class MapRL mapper (inputRL :: RowList) input output | inputRL mapper -> output input, inputRL -> input where
  mapRL :: mapper -> RLProxy inputRL -> {|input} -> {|output}

instance mapRLNil ∷ TypeEquals {} {|output} =>  MapRL mapper Nil input output where
  mapRL _ _ input = to {}

instance mapRLCons ∷ 
  ( IsSymbol sym
  , RowToList tailRow tail
  , Cons sym ty tailRow input
  , Cons sym outTy tailOutput output
  , Mapper mapper ty outTy
  , Lacks sym tailRow
  , Lacks sym tailOutput
  , MapRL mapper tail tailRow tailOutput
  ) => MapRL mapper (Cons sym ty tail) input output where
  mapRL mapper _ input = insert label outputValue tailOutput
    where
      label :: SProxy sym
      label = SProxy

      tailInput :: {|tailRow}
      tailInput = delete label input

      value :: ty
      value = get label input

      outputValue :: outTy
      outputValue = (mapValue mapper) value

      tailOutput :: {|tailOutput}
      tailOutput = mapRL mapper (RLProxy :: RLProxy tail) tailInput

class Map mapper input output | mapper input -> output where
  --| ```purescript
  --| map MapToLength {a : "Hello Word", b: [1, 2, 3]}
  --| -- == {a : 12, b : 9 }
  --| ```
  -- | `MapToLength` is an example for a "mapper". The `mapValue` function from the `Mapper` class.
  -- | Every type `a` contained in the record needs a `Mapper a` instance for `map` to be applicable.
  mapRecord :: mapper -> {|input} -> {|output}

instance mapFromRL :: (RowToList input inputRL, MapRL mapper inputRL input output) => Map mapper input output where
  mapRecord mapper input = mapRL mapper (RLProxy :: RLProxy inputRL) input

