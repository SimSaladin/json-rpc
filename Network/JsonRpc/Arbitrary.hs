{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
-- | Arbitrary instances and data types for use in test suites.
module Network.JsonRpc.Arbitrary where

import Control.Applicative
import Data.Aeson.Types
import qualified Data.HashMap.Strict as M
import Data.Text (Text)
import qualified Data.Text as T
import Network.JsonRpc
import Test.QuickCheck.Arbitrary
import Test.QuickCheck.Gen

instance Arbitrary Text where
    arbitrary = T.pack <$> arbitrary

instance Arbitrary Ver where
    arbitrary = elements [V1, V2]

instance Arbitrary Request where
    arbitrary = oneof
        [ Request <$> arbitrary <*> arbitrary <*> arbitrary <*> arbitrary
        , Notif <$> arbitrary <*> arbitrary <*> arbitrary
        ]

instance Arbitrary Response where
    arbitrary = oneof
        [ Response <$> arbitrary <*> arbitrary <*> arbitrary
        , ResponseError <$> arbitrary <*> arbitrary <*> arbitrary
        , OrphanError <$> arbitrary <*> arbitrary
        ]


instance Arbitrary ErrorObj where
    arbitrary = oneof
        [ ErrorObj <$> arbitrary <*> arbitrary <*> arbitrary
        , ErrorVal <$> arbitrary
        ]

instance Arbitrary Message where
    arbitrary = oneof
        [ MsgRequest  <$> arbitrary
        , MsgResponse <$> arbitrary
        ]

instance Arbitrary Id where
    arbitrary = oneof [IdInt <$> arbitrary, IdTxt <$> arbitrary]

instance Arbitrary Value where
    arbitrary = resize 10 $ oneof [val, lsn, objn] where
        val = oneof [ toJSON <$> (arbitrary :: Gen String)
                    , toJSON <$> (arbitrary :: Gen Int)
                    , toJSON <$> (arbitrary :: Gen Double)
                    , toJSON <$> (arbitrary :: Gen Bool)
                    ]
        ls   = toJSON <$> listOf val
        obj  = toJSON . M.fromList <$> listOf ps
        ps   = (,) <$> (arbitrary :: Gen String) <*> oneof [val, ls]
        lsn  = toJSON <$> listOf (oneof [ls, obj, val])
        objn = toJSON . M.fromList <$> listOf psn
        psn  = (,) <$> (arbitrary :: Gen String) <*> oneof [val, ls, obj]

