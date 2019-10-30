module HasqlTutorial1.Transaction where

import HasqlTutorial1.Prelude
import Hasql.Transaction
import qualified HasqlTutorial1.Statement as Statement
import qualified Hasql.Session as Session


{-|
Look for an existing user by the specified email,
creating a new one, if it doesn't exist.
-}
register :: Text -> ByteString -> Text -> Maybe Text -> Transaction (Bool, Int32)
register email password name phone = session Write Serializable $ do
  possibleExistingId <- Session.statement email Statement.findUserByEmail
  case possibleExistingId of
    Just existingId -> return (False, existingId)
    Nothing -> do
      newId <- Session.statement (email, password, name, phone) Statement.insertUser
      return (True, newId)

{-|
Same as `register`,
but implemented as a composition of transactions
using the `Selective` instance.

It's only placed here as an example of how you can compose transactions sequentially.
-}
register' :: Text -> ByteString -> Text -> Maybe Text -> Transaction (Bool, Int32)
register' email password name phone =
  fromMaybeS
    (fmap (\ newId -> (True, newId))
      (insertUser email password name phone))
    (fmap (fmap (\ existingId -> (False, existingId)))
      (findUserByEmail email))

findUserByEmail :: Text -> Transaction (Maybe Int32)
findUserByEmail = statement Read ReadCommitted Statement.findUserByEmail

insertUser :: Text -> ByteString -> Text -> Maybe Text -> Transaction Int32
insertUser email password name phone =
  statement Write Serializable Statement.insertUser
    (email, password, name, phone)
