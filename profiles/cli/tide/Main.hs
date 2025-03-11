import Data.Function ((&))
import Data.Functor ((<&>))
import Data.List (isPrefixOf)
import Data.List.Extra (replace)
import System.Environment (getArgs)

main :: IO ()
main = do
  arg <- getArgs <&> head
  cnt <- readFile arg
  let
    cfg =
      cnt
        & lines
        & filter (\x -> "-------------------------------------------------------> set -U" `isPrefixOf` x)
        & map (replace "-------------------------------------------------------> set -U" "set -U")
        & unlines
  putStr cfg
