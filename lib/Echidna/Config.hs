module Echidna.Config where

import Control.Applicative ((<|>))
import Control.Monad.State (StateT(..), runStateT, modify')
import Control.Monad.Trans (lift)
import Data.Aeson
import Data.Aeson.KeyMap (keys)
import Data.Bool (bool)
import Data.ByteString qualified as BS
import Data.Functor ((<&>))
import Data.Maybe (fromMaybe)
import Data.Set qualified as Set
import Data.Text (isPrefixOf)
import Data.Yaml qualified as Y

import EVM.Types (VM(..), W256)

import Echidna.Mutator.Corpus (defaultMutationConsts)
import Echidna.Test
import Echidna.Types.Campaign
import Echidna.Types.Config
import Echidna.Types.Coverage (CoverageFileType(..))
import Echidna.Types.Solidity
import Echidna.Types.Test (TestConf(..))
import Echidna.Types.Tx (TxConf(TxConf), maxGasPerBlock, defaultTimeDelay, defaultBlockDelay)

instance FromJSON EConfig where
  parseJSON x = (.econfig) <$> parseJSON @EConfigWithUsage x

instance FromJSON EConfigWithUsage where
  parseJSON o = do
    let v' = case o of Object v -> v; _ -> mempty
    (c, ks) <- runStateT (parser v') $ Set.fromList []
    let found = Set.fromList (keys v')
    pure $ EConfigWithUsage c
               (found `Set.difference` ks)
               (ks    `Set.difference` found)
    where
    parser v =
      EConfig
        <$> campaignConfParser
        <*> pure names
        <*> solConfParser
        <*> testConfParser
        <*> txConfParser
        <*> (UIConf <$> v ..:? "timeout" <*> formatParser)
        <*> v ..:? "rpcUrl"
        <*> v ..:? "rpcBlock"
        <*> v ..:? "etherscanApiKey"
        <*> v ..:? "projectName"
      where
      useKey k = modify' $ Set.insert k
      x ..:? k  = useKey k >> lift (x .:? k)
      x ..!= y  = fromMaybe y <$> x

      getWord256 k def = do
        value :: Integer <- fromMaybe (fromIntegral (def :: W256)) <$> v ..:? k
        if value > fromIntegral (maxBound :: W256)
         then fail $ show k <> ": value does not fit in 256 bits"
         else pure $ fromIntegral value

      txConfParser = TxConf
        <$> v ..:? "propMaxGas"    ..!= maxGasPerBlock
        <*> v ..:? "testMaxGas"    ..!= maxGasPerBlock
        <*> getWord256 "maxGasprice" 0
        <*> getWord256 "maxTimeDelay" defaultTimeDelay
        <*> getWord256 "maxBlockDelay" defaultBlockDelay
        <*> getWord256 "maxValue" 100000000000000000000

      testConfParser = do
        psender <- v ..:? "psender" ..!= 0x10000
        fprefix <- v ..:? "prefix"  ..!= "echidna_"
        let goal fname = if (fprefix <> "revert_") `isPrefixOf` fname then ResRevert else ResTrue
            classify fname vm = maybe ResOther classifyRes vm.result == goal fname
        pure $ TestConf classify (const psender)

      campaignConfParser = CampaignConf
        <$> v ..:? "testLimit"           ..!= defaultTestLimit
        <*> v ..:? "stopOnFail"          ..!= False
        <*> v ..:? "estimateGas"         ..!= False
        <*> v ..:? "seqLen"              ..!= defaultSequenceLength
        <*> v ..:? "shrinkLimit"         ..!= defaultShrinkLimit
        <*> (v ..:? "coverage" <&> \case Just False -> Nothing; _ -> Just mempty)
        <*> v ..:? "seed"
        <*> v ..:? "dictFreq"            ..!= 0.40
        <*> v ..:? "corpusDir"           ..!= Nothing
        <*> v ..:? "mutConsts"           ..!= defaultMutationConsts
        <*> v ..:? "coverageFormats"     ..!= [Txt,Html,Lcov]
        <*> v ..:? "workers"
        <*> v ..:? "server"
        <*> v ..:? "symExec"             ..!= False
        <*> v ..:? "symExecConcolic"     ..!= True
        <*> v ..:? "symExecTargets"      ..!= Nothing
        <*> v ..:? "symExecTimeout"      ..!= defaultSymExecTimeout
        <*> v ..:? "symExecNSolvers"     ..!= defaultSymExecNWorkers
        <*> v ..:? "symExecMaxIters"     ..!= defaultSymExecMaxIters
        <*> v ..:? "symExecAskSMTIters"  ..!= defaultSymExecAskSMTIters

        -- Multi-Layer Fuzzing Optimization Framework
        <*> v ..:? "preDilutionFunctions" ..!= []
        <*> v ..:? "preDilutionWeight"    ..!= 0.35
        <*> v ..:? "smartMutation"        ..!= True
        <*> v ..:? "mutationDepth"        ..!= 3
        <*> v ..:? "priorityMutationRate" ..!= 0.8
        <*> v ..:? "normalMutationRate"   ..!= 0.3
        <*> v ..:? "differentialTreatment" ..!= True
        <*> v ..:? "prioritySequenceLength" ..!= 150
        <*> v ..:? "normalSequenceLength"   ..!= 50
        <*> v ..:? "priorityGasLimit"     ..!= 8000000
        <*> v ..:? "normalGasLimit"       ..!= 3000000
        <*> v ..:? "adaptiveFuzzing"      ..!= True
        <*> v ..:? "crossoverRate"        ..!= 0.6
        <*> v ..:? "elitismRate"          ..!= 0.1
        <*> v ..:? "diversityThreshold"   ..!= 0.7
        <*> v ..:? "optimizationTargets"  ..!= ["coverage", "bug_detection"]
        <*> v ..:? "strategyLayers"       ..!= []
        <*> v ..:? "maxArraySize"         ..!= 1000

      solConfParser = SolConf
        <$> v ..:? "contractAddr"    ..!= defaultContractAddr
        <*> v ..:? "deployer"        ..!= defaultDeployerAddr
        <*> v ..:? "sender"          ..!= Set.fromList [0x10000, 0x20000, defaultDeployerAddr]
        <*> v ..:? "balanceAddr"     ..!= 0xffffffff
        <*> v ..:? "balanceContract" ..!= 0
        <*> v ..:? "codeSize"        ..!= 0xffffffff
        <*> v ..:? "prefix"          ..!= "echidna_"
        <*> v ..:? "disableSlither"  ..!= False
        <*> v ..:? "cryticArgs"      ..!= []
        <*> v ..:? "solcArgs"        ..!= ""
        <*> v ..:? "solcLibs"        ..!= []
        <*> v ..:? "quiet"           ..!= False
        <*> v ..:? "initialize"      ..!= Nothing
        <*> v ..:? "deployContracts" ..!= []
        <*> v ..:? "deployBytecodes" ..!= []
        <*> ((<|>) <$> v ..:? "allContracts" <*> lift (v .:? "multi-abi")) ..!= False
        <*> mode
        <*> v ..:? "testDestruction" ..!= False
        <*> v ..:? "allowFFI"        ..!= False
        <*> fnFilter
        where
          mode = v ..:? "testMode" >>= \case { Just s  -> pure $ validateTestMode s; Nothing -> pure "property" }
          fnFilter = bool Whitelist Blacklist <$> v ..:? "filterBlacklist" ..!= True
                                             <*> v ..:? "filterFunctions"  ..!= []

      names :: Names
      names Sender = (" from: " ++) . show
      names _      = const ""

      formatParser = fromMaybe Interactive <$> (v ..:? "format" >>= \case
        Just ("text" :: String) -> pure . Just . NonInteractive $ Text
        Just "json"             -> pure . Just . NonInteractive $ JSON
        Just "none"             -> pure . Just . NonInteractive $ None
        Nothing -> pure Nothing
        _ -> fail "Unrecognized format type (should be text, json, or none)"
        )

-- | The default config used by Echidna
defaultConfig :: EConfig
defaultConfig = either (error "Config parser got messed up :(")
                        id
                        $ Y.decodeEither' ""

-- | Parse an Echidna config file
parseConfig :: FilePath -> IO EConfigWithUsage
parseConfig f = BS.readFile f >>= Y.decodeThrow
