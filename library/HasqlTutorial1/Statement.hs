module HasqlTutorial1.Statement where

import HasqlTutorial1.Prelude
import Hasql.Statement
import qualified Hasql.Encoders as E
import qualified Hasql.Decoders as D


findUserByEmail :: Statement Text (Maybe Int32)
findUserByEmail =
  Statement
    "select id from user where email = $1"
    (E.param (E.nonNullable E.text))
    (D.rowMaybe (D.column (D.nonNullable D.int4)))
    True

insertUser :: Statement (Text, ByteString, Text, Maybe Text) Int32
insertUser = let
  sql =
    "insert into user (email, password, name, phone) \
    \values ($1, $2, $3, $4) \
    \returning id"
  encoder =
    contrazip4
      (E.param (E.nonNullable E.text))
      (E.param (E.nonNullable E.bytea))
      (E.param (E.nonNullable E.text))
      (E.param (E.nullable E.text))
  decoder =
    D.singleRow ((D.column . D.nonNullable) D.int4)
  in Statement sql encoder decoder True

authenticateUser :: Statement (Text, ByteString) (Maybe (Bool, Int32))
authenticateUser = let
  sql =
    "select password = $2, id from user where email = $1"
  encoder =
    contrazip2
      (E.param (E.nonNullable E.text))
      (E.param (E.nonNullable E.bytea))
  decoder =
    D.rowMaybe $
      (,) <$>
        D.column (D.nonNullable D.bool) <*>
        D.column (D.nonNullable D.int4)
  in Statement sql encoder decoder True

getUserDetails :: Statement Int32 (Maybe (Text, Text, Maybe Text, Bool))
getUserDetails = let
  sql =
    "select name, email, phone, admin \
    \from user \
    \where id = $1"
  encoder =
    E.param (E.nonNullable E.int4)
  decoder =
    D.rowMaybe $
      (,,,) <$>
        D.column (D.nonNullable D.text) <*>
        D.column (D.nonNullable D.text) <*>
        D.column (D.nullable D.text) <*>
        D.column (D.nonNullable D.bool)
  in Statement sql encoder decoder True

getUserNotifications :: Statement Int32 (Vector (Int32, Text, Bool))
getUserNotifications = let
  sql =
    "select id, message, read \
    \from notification \
    \where user = $1"
  encoder =
    E.param (E.nonNullable E.int4)
  decoder =
    D.rowVector $
      (,,) <$>
        D.column (D.nonNullable D.int4) <*>
        D.column (D.nonNullable D.text) <*>
        D.column (D.nonNullable D.bool)
  in Statement sql encoder decoder True

markNotificationRead :: Statement Int32 Bool
markNotificationRead =
  Statement
    "update notification \
    \set read = true \
    \where id = $1"
    (E.param (E.nonNullable E.int4))
    (fmap (> 0) D.rowsAffected)
    True

insertNotification :: Statement (Int32, Text) Int32
insertNotification =
  Statement
    "insert into notification (user, message, read) \
    \values ($1, $2, 'false') \
    \returning id"
    (contrazip2
      (E.param (E.nonNullable E.int4))
      (E.param (E.nonNullable E.text)))
    (D.singleRow (D.column (D.nonNullable D.int4)))
    True
