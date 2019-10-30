module HasqlTutorial1.Session
where

import HasqlTutorial1.Prelude
import Hasql.Session
import qualified Hasql.Transaction as Transaction
import qualified HasqlTutorial1.Statement as Statement
import qualified HasqlTutorial1.Transaction as Transaction


{-|
Authenticate a user by email and password.

The result is one of the following:

- @Nothing@, if no user is found by the specified email,
- @Just (False, userId)@, if the user is found, but the password doesn't match,
- @Just (True, userId)@, if the user is successfully authenticated.
-}
authenticate :: Text -> ByteString -> Session (Maybe (Bool, Int32))
authenticate email password = statement (email, password) Statement.authenticateUser

{-|
Register a user by email, password, name and possible phone number.

The result is one of the following:

- @(True, userId)@, if a new user has been created,
- @(False, userId)@, if a user with the provided email already existed and no changes have been made.
-}
register :: Text -> ByteString -> Text -> Maybe Text -> Session (Bool, Int32)
register email password name phone = Transaction.transact (Transaction.register email password name phone)

{-|
Get details of a user by ID.

The result is Nothing if the user doesn't exist.
Otherwise it is its name, email, phone numer and its admin access.
-}
getUserDetails :: Int32 -> Session (Maybe (Text, Text, Maybe Text, Bool))
getUserDetails id = statement id Statement.getUserDetails

{-|
Get notifications of a user by its ID.

The result is a vector of tuples of notification ID, message and its read status.
-}
getNotifications :: Int32 -> Session (Vector (Int32, Text, Bool))
getNotifications userId = statement userId Statement.getUserNotifications

{-|
Mark a notification as read by its ID.

The result is a boolean specifying,
whether such a notification at all existed and changes have been made.
-}
markNotificationRead :: Int32 -> Session Bool
markNotificationRead notificationId = statement notificationId Statement.markNotificationRead
