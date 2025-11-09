module RiskOfRain2.Types where

import Prelude
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Data.Map (Map)
import Data.Map as Map
import Data.List (List(..), (:))

-- Item types
data ItemType 
  = ATG 
  | PlasmaShrimp 
  | Ukulele 
  | Polylute 
  | ChargedPerforator 
  | StickyBomb
  -- Add more items as needed

derive instance Eq ItemType
derive instance Generic ItemType _
instance Show ItemType where
  show = genericShow

-- Item representation
type Item =
  { name :: String
  , totalDamageMultiplier :: Number
  , procChance :: Number
  , procCoefficient :: Number
  , hits :: Int
  }

-- Inventory as a multiset
type Inventory = Map ItemType Int

-- Game state with modifiers
type GameState =
  { clover :: Int
  , purity :: Int
  , icbm :: Int
  , inventory :: Inventory
  }

-- Default game state
defaultGameState :: GameState
defaultGameState =
  { clover: 1
  , purity: 0
  , icbm: 1
  , inventory: Map.empty
}
