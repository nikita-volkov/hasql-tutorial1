{-|
Project's internal prelude.
We can reexport all things we want to be available in project's every module.
-}
module HasqlTutorial1.Prelude
(
  module Exports,
)
where

{-
Please notice that this is not the prelude from "base",
it is a richer drop-in replacement for it from the "rerebase" package.
It provides us with a lot of useful types and functions like `Text` or `Vector`.
-}
import Prelude as Exports
