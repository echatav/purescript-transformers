module Control.Monad.Reader.Trans where

import Prelude
import Control.Monad.Trans

data ReaderT r m a = ReaderT (r -> m a)

runReaderT :: forall r m a. ReaderT r m a -> (r -> m a)
runReaderT (ReaderT x) = x

withReaderT :: forall r1 r2 m a b. (r2 -> r1) -> ReaderT r1 m a -> ReaderT r2 m a
withReaderT f m = ReaderT $ runReaderT m <<< f

mapReaderT :: forall r m1 m2 a b. (m1 a -> m2 b) -> ReaderT r m1 a -> ReaderT r m2 b
mapReaderT f m = ReaderT $ f <<< runReaderT m

liftReaderT :: forall r m a. m a -> ReaderT r m a
liftReaderT m = ReaderT (const m)

instance functorReaderT :: (Functor m) => Functor (ReaderT r m) where
  (<$>) f = mapReaderT $ (<$>) f
  
instance applyReaderT :: (Applicative m) => Apply (ReaderT r m) where
  (<*>) f v = ReaderT \r -> runReaderT f r <*> runReaderT v r
    
instance applicativeReaderT :: (Applicative m) => Applicative (ReaderT r m) where
  pure = liftReaderT <<< pure
  
instance alternativeReaderT :: (Alternative m) => Alternative (ReaderT r m) where
  empty = liftReaderT empty
  (<|>) m n = ReaderT \r -> runReaderT m r <|> runReaderT n r

instance bindReaderT :: (Monad m) => Bind (ReaderT r m) where
  (>>=) m k = ReaderT \r -> do
    a <- runReaderT m r
    runReaderT (k a) r

instance monadReaderT :: (Monad m) => Monad (ReaderT r m)

instance monadTransReaderT :: MonadTrans (ReaderT r) where
  lift = liftReaderT

liftCatchReader :: forall r m e a. (m a -> (e -> m a) -> m a) -> ReaderT r m a -> (e -> ReaderT r m a) -> ReaderT r m a
liftCatchReader catch m h = ReaderT $ \r -> catch (runReaderT m r) (\e -> runReaderT (h e) r)

liftCallCCReader :: forall r m a b. (((a -> m b) -> m a) -> m a) -> ((a -> ReaderT r m b) -> ReaderT r m a) -> ReaderT r m a
liftCallCCReader callCC f = ReaderT $ \r -> callCC $ \c -> runReaderT (f (\a -> ReaderT $ const $ c a)) r
