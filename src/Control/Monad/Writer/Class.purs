module Control.Monad.Writer.Class where

import Prelude
import Control.Monad.Trans
import Control.Monad.Writer.Trans
import Control.Monad.Error
import Control.Monad.Error.Trans
import Control.Monad.Maybe.Trans
import Control.Monad.State.Trans
import Control.Monad.Reader.Trans
import Data.Monoid
import Data.Tuple

class MonadWriter w m where
  writer :: forall a. Tuple a w -> m a
  listen :: forall a. m a -> m (Tuple a w)
  pass :: forall a. m (Tuple a (w -> w)) -> m a

tell :: forall w m a. (Monoid w, Monad m, MonadWriter w m) => w -> m {}
tell w = writer $ Tuple {} w

listens :: forall w m a b. (Monoid w, Monad m, MonadWriter w m) => (w -> b) -> m a -> m (Tuple a b)
listens f m = do
  Tuple a w <- listen m
  return $ Tuple a (f w)

censor :: forall w m a. (Monoid w, Monad m, MonadWriter w m) => (w -> w) -> m a -> m a
censor f m = pass $ do
  a <- m
  return $ Tuple a f

instance monadWriterWriterT :: (Monoid w, Monad m) => MonadWriter w (WriterT w m) where
  writer = WriterT <<< return
  listen m = WriterT $ do
    Tuple a w <- runWriterT m
    return $ Tuple (Tuple a w) w
  pass m = WriterT $ do
    Tuple (Tuple a f) w <- runWriterT m
    return $ Tuple a (f w)

instance monadWriterErrorT :: (Monad m, Error e, MonadWriter w m) => MonadWriter w (ErrorT e m) where
  writer wd = lift (writer wd)
  listen = liftListenError listen
  pass = liftPassError pass

instance monadWriterMaybeT :: (Monad m, MonadWriter w m) => MonadWriter w (MaybeT m) where
  writer wd = lift (writer wd)
  listen = liftListenMaybe listen
  pass = liftPassMaybe pass

instance monadWriterStateT :: (Monad m, MonadWriter w m) => MonadWriter w (StateT s m) where
  writer wd = lift (writer wd)
  listen = liftListenState listen
  pass = liftPassState pass

instance monadWriterReaderT :: (Monad m, MonadWriter w m) => MonadWriter w (ReaderT r m) where
  writer wd = lift (writer wd)
  listen = mapReaderT listen
  pass = mapReaderT pass
