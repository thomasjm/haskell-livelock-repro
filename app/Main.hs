{-# LANGUAGE CPP, QuasiQuotes, MultiWayIf, ViewPatterns, LambdaCase, RecordWildCards, ScopedTypeVariables, OverloadedStrings #-}
module Main where

import Control.Concurrent
import Control.Concurrent.Async
import Control.Monad
import Control.Monad.IO.Class
import Data.String.Interpolate.IsString
import System.IO
import System.Log.Formatter
import System.Log.Handler (setFormatter)
import System.Log.Handler.Simple (streamHandler)
import System.Log.Logger
import System.Posix.Pty
import System.Process


main :: IO ()
main = do
  updateGlobalLogger rootLoggerName (setLevel INFO)
  updateGlobalLogger rootLoggerName removeHandler
  handler <- streamHandler stderr DEBUG
  updateGlobalLogger rootLoggerName (addHandler $ setFormatter handler $ simpleLogFormatter "[$time $loggername $prio] $msg")
  let logFn = warningM "MyApp"

  -- let logFn = putStrLn

  replicateM_ 20 $ do
    logFn [i|Spawning spawnWithPty|]
    async $ do
      logFn [i|Doing spawnWithPty|]
      void $ spawnWithPty Nothing True "sleep" ["99999999"] (80, 24)

    logFn [i|Spawning readCreateProcess|]
    async $ do
      logFn [i|Doing readCreateProcess|]
      liftIO $ readCreateProcess (proc "echo" ["hi"]) ""

  threadDelay 60000000
