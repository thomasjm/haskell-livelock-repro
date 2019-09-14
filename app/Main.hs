{-# LANGUAGE QuasiQuotes, OverloadedStrings #-}
module Main where

import Control.Concurrent
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
  -- Remove the default handler and set our own.
  -- If you use the default handler, the problem doesn't happen.
  updateGlobalLogger rootLoggerName removeHandler
  handler <- streamHandler stderr DEBUG
  -- If the message is just "$msg" instead of "Msg: $msg", the problem doesn't happen
  updateGlobalLogger rootLoggerName (addHandler $ setFormatter handler $ simpleLogFormatter "Msg: $msg")
  let logFn = warningM "MyApp"

  -- Repeat this 20 times
  replicateM_ 20 $ do
    logFn [i|Spawning spawnWithPty|]
    forkIO $ do
      logFn [i|Doing spawnWithPty|]
      void $ spawnWithPty Nothing True "sleep" ["99999999"] (80, 24)

    logFn [i|Spawning readCreateProcess|]
    forkIO $ void $ do
      logFn [i|Doing readCreateProcess|]
      liftIO $ readCreateProcess (proc "echo" ["hi"]) ""

  -- All CPUs should now be stuck at 100%
  threadDelay 60000000
