{ name =
    "record-fold"
, dependencies =
    [ "arrays"
    , "console"
    , "effect"
    , "maybe"
    , "prelude"
    , "psci-support"
    , "record"
    , "tuples"
    ]
, packages =
    ./packages.dhall
, sources =
    [ "src/**/*.purs", "test/**/*.purs" ]
}
