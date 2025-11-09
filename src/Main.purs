-- module Main where
-- 
-- import Prelude
-- 
-- import Effect (Effect)
-- import Effect.Console (log)
-- 
-- main :: Effect Unit
-- main = do
--   log "🍝"


module Main where

import Prelude
import Effect (Effect)
import Effect.Console (log)
import Data.Map as Map
import RiskOfRain2.Types (GameState, ItemType(..), defaultGameState)
import RiskOfRain2.DamageCalculator (calculateTotalDamage, testDamageCalculation)

main :: Effect Unit
main = do
  log "Risk of Rain 2 Damage Calculator"
  
  -- Test with your original example
  log $ "Test damage calculation: " <> show testDamageCalculation
  
  -- Example with different setup
  let customState = defaultGameState
        { clover = 2
        , purity = 1
        , icbm = 2
        , inventory = Map.fromFoldable
            [ (ATG, 3)
            , (Ukulele, 1)
            , (PlasmaShrimp, 2)
            ]
        }
  
  let damage = calculateTotalDamage customState 0.75 1
  log $ "Custom damage calculation: " <> show damage
