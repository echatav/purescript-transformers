module Control.Monad.State where

import Prelude
import Control.Monad.Identity
import Control.Monad.State.Trans
import Data.Tuple

type State s a = StateT s Identity a

runState :: forall s a. State s a -> s -> Tuple a s
runState s = runIdentity <<< runStateT s

evalState :: forall s a. State s a -> s -> a
evalState m s = fst (runState m s)

execState :: forall s a. State s a -> s -> s
execState m s = snd (runState m s)

mapState :: forall s a b. (Tuple a s -> Tuple b s) -> State s a -> State s b
mapState f = mapStateT (Identity <<< f <<< runIdentity)

withState :: forall s a. (s -> s) -> State s a -> State s a
withState = withStateT
