module RiskOfRain2.ProcChain where

import Prelude
import Data.List (List(..), (:), null)
import Data.Map (Map, toUnfoldable, lookup)
import RiskOfRain2.Types (ItemType, Item, Inventory, GameState)

-- Type for item builders that can create items based on game state
type ItemBuilder = GameState -> ItemType -> Int -> Item

-- Calculate luck-adjusted proc chance
calculateAdjustedProcChance :: Number -> Int -> Int -> Number
calculateAdjustedProcChance baseProcChance clover purity =
  let luck = (toNumber clover) - (toNumber purity)
  in if luck > 0.0 then
        1.0 - (1.0 - baseProcChance) `pow` (1.0 + luck)
     else
        baseProcChance `pow` (1.0 - luck)
  where
  pow = (\base exp -> base `pow` exp)

-- Apply ICBM modifications to missile-type items
applyIcbmModifications :: Item -> Int -> Item
applyIcbmModifications item icbm =
  let damageMultiplier = if icbm > 1 then 
          item.totalDamageMultiplier * (1.0 + 0.5 * (toNumber (icbm - 1)))
        else
          item.totalDamageMultiplier
      hits = if icbm > 0 then item.hits * 3 else item.hits
  in item { totalDamageMultiplier = damageMultiplier, hits = hits }

-- Default item builder
defaultItemBuilder :: ItemBuilder
defaultItemBuilder state itemType count = case itemType of
  ATG -> 
    let baseItem = 
          { name: "ATG Missile Mk. 2"
          , totalDamageMultiplier: 3.0 * (toNumber count)
          , procChance: 0.1
          , procCoefficient: 1.0
          , hits: 1
          }
    in applyIcbmModifications baseItem state.icbm
    
  PlasmaShrimp ->
    let baseItem =
          { name: "Plasma Shrimp"
          , totalDamageMultiplier: 0.4 * (toNumber count)
          , procChance: 1.0
          , procCoefficient: 0.2
          , hits: 1
          }
    in applyIcbmModifications baseItem state.icbm
    
  Ukulele ->
    { name: "Ukulele"
    , totalDamageMultiplier: 0.8
    , procChance: 0.25
    , procCoefficient: 0.2
    , hits: 2 * count + 1
    }
    
  Polylute ->
    { name: "Polylute"
    , totalDamageMultiplier: 0.6
    , procChance: 0.25
    , procCoefficient: 0.2
    , hits: 3 * count
    }
    
  ChargedPerforator ->
    { name: "Charged Perforator"
    , totalDamageMultiplier: 5.0 * (toNumber count)
    , procChance: 0.1
    , procCoefficient: 1.0
    , hits: 1
    }
    
  StickyBomb ->
    { name: "Sticky Bomb"
    , totalDamageMultiplier: 1.8
    , procChance: 0.05 * (toNumber count)
    , procCoefficient: 0.0  -- Sticky bombs don't proc chains
    , hits: 1
    }

-- Convert inventory map to list of items
inventoryToItems :: Inventory -> ItemBuilder -> GameState -> List Item
inventoryToItems inventory builder state =
  let entries = toUnfoldable inventory :: List { key :: ItemType, value :: Int }
  in map (\({key, value}) -> builder state key value) entries

-- Core proc chain calculation
calculateProcChain :: ItemBuilder -> GameState -> Number -> Int -> Number
calculateProcChain builder state procCoefficient hits =
  if procCoefficient == 0.0 || Map.isEmpty state.inventory then
    1.0
  else
    let items = inventoryToItems state.inventory builder state
    in 1.0 + procCoefficient * calculateProcChainSum items state procCoefficient hits

-- Helper function to calculate the sum part of proc chain
calculateProcChainSum :: List Item -> GameState -> Number -> Int -> Number
calculateProcChainSum Nil _ _ _ = 0.0
calculateProcChainSum (item : remainingItems) state procCoefficient hits =
  let adjustedProcChance = calculateAdjustedProcChance item.procChance state.clover state.purity
      -- Create a new state without the current item for recursion
      newInventory = Map.delete (case item.name of
                                  "ATG Missile Mk. 2" -> ATG
                                  "Plasma Shrimp" -> PlasmaShrimp
                                  "Ukulele" -> Ukulele
                                  "Polylute" -> Polylute
                                  "Charged Perforator" -> ChargedPerforator
                                  "Sticky Bomb" -> StickyBomb
                                  _ -> ATG) state.inventory
      newState = state { inventory = newInventory }
      chain = item.totalDamageMultiplier 
            * adjustedProcChance 
            * (toNumber item.hits)
            * calculateProcChain defaultItemBuilder newState item.procCoefficient item.hits
  in chain + calculateProcChainSum remainingItems state procCoefficient hits
