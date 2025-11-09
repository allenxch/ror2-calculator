{ name = "ror2-damage-calculator"
, dependencies = 
  [ "console"
  , "effect"
  , "prelude"
  , "lists"
  , "maps"
  , "foldable-traversable"
  , "generics-rep"
  , "psci-support"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
