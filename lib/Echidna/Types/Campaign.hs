module Echidna.Types.Campaign where

import Control.Concurrent (ThreadId)
import Data.Aeson
import Data.Map (Map)
import Data.Text (Text)
import Data.Text qualified as T
import Data.Word (Word8, Word16)
import GHC.Conc (numCapabilities)

import Echidna.ABI (GenDict, emptyDict, encodeSig)
import Echidna.Types
import Echidna.Types.Coverage (CoverageFileType(..), CoverageMap)
import Echidna.Types.Test (TestType (..), EchidnaTest(..))
import Echidna.Types.Tx (Tx)

-- | Configuration for running an Echidna 'Campaign'.
data CampaignConf = CampaignConf
  { testLimit          :: Int
    -- ^ Maximum number of function calls to execute while fuzzing
  , stopOnFail         :: Bool
    -- ^ Whether to stop the campaign immediately if any property fails
  , estimateGas        :: Bool
    -- ^ Whether to collect gas usage statistics, preDilutionFunctions :: [Text]
    -- ^ list of names of functions to pre-dilute
  , seqLen             :: Int
    -- ^ Number of calls between state resets (e.g. \"every 10 calls,
    -- reset the state to avoid unrecoverable states/save memory\"
  , shrinkLimit        :: Int
    -- ^ Maximum number of candidate sequences to evaluate while shrinking
  , knownCoverage      :: Maybe CoverageMap
    -- ^ If applicable, initially known coverage. If this is 'Nothing',
    -- Echidna won't collect coverage information (and will go faster)
  , seed               :: Maybe Int
    -- ^ Seed used for the generation of random transactions
  , dictFreq           :: Float
    -- ^ Frequency for the use of dictionary values in the random transactions
  , corpusDir          :: Maybe FilePath
    -- ^ Directory to load and save lists of transactions
  , mutConsts          :: MutationConsts Integer
    -- ^ Directory to load and save lists of transactions
  , coverageFormats    :: [CoverageFileType]
    -- ^ List of file formats to save coverage reports
  , workers            :: Maybe Word8
    -- ^ Number of fuzzing workers
  , serverPort         :: Maybe Word16
    -- ^ Server-Sent Events HTTP port number, if missing server is not ran
  , symExec            :: Bool
    -- ^ Whether to add an additional symbolic execution worker
  , symExecConcolic    :: Bool
    -- ^ Whether symbolic execution will be concolic (vs full symbolic execution)
    -- Only relevant if symExec is True
  , symExecTargets     :: Maybe [Text]
  , symExecTimeout     :: Int
    -- ^ Timeout for symbolic execution SMT solver queries.
    -- Only relevant if symExec is True
  , symExecNSolvers    :: Int
    -- ^ Number of SMT solvers used in symbolic execution.
    -- Only relevant if symExec is True
  , symExecMaxIters    :: Integer
    -- ^ Number of times we may revisit a particular branching point.
    -- Only relevant if symExec is True and symExecConcolic is False
  , symExecAskSMTIters :: Integer
    -- ^ Number of times we may revisit a particular branching point
    -- before we consult the SMT solver to check reachability.
    -- Only relevant if symExec is True and symExecConcolic is False
  , preDilutionFunctions :: [String]
    -- ^ list of names of functions to pre-dilute
  , preDilutionWeight    :: Double
    -- ^ pre-dilution weight (0.0–1.0)
    
  -- Multi-Layer Fuzzing Optimization Framework
  , smartMutation        :: Bool
    -- ^ Enable enhanced mutation strategies
  , mutationDepth        :: Int
    -- ^ Layers of mutation (1-5)
  , priorityMutationRate :: Double
    -- ^ Higher mutation rate for priority functions
  , normalMutationRate   :: Double
    -- ^ Lower rate for normal functions
  , differentialTreatment :: Bool
    -- ^ Enable different strategies per function type
  , prioritySequenceLength :: Int
    -- ^ Longer sequences for priority functions
  , normalSequenceLength   :: Int
    -- ^ Shorter sequences for normal functions
  , priorityGasLimit     :: Integer
    -- ^ Higher gas limit for priority functions
  , normalGasLimit       :: Integer
    -- ^ Standard gas limit for normal functions
  , adaptiveFuzzing      :: Bool
    -- ^ Enable adaptive strategy selection
  , crossoverRate        :: Double
    -- ^ Genetic algorithm crossover rate
  , elitismRate          :: Double
    -- ^ Keep best percentage of test cases
  , diversityThreshold   :: Double
    -- ^ Maintain test case diversity
  , optimizationTargets  :: [String]
    -- ^ List of optimization objectives
  , strategyLayers       :: [(String, String)]
    -- ^ Layered strategy configuration
  , maxArraySize         :: Int
    -- ^ Maximum array size for complex testing
  }

data WorkerType = FuzzWorker | SymbolicWorker deriving (Eq)

type WorkerId = Int

data CampaignEvent
  = WorkerEvent WorkerId WorkerType WorkerEvent
  | Failure String
  | ReproducerSaved String -- filename

data WorkerEvent
  = TestFalsified !EchidnaTest
  | TestOptimized !EchidnaTest
  | NewCoverage { points :: !Int, numCodehashes :: !Int, corpusSize :: !Int, transactions :: [Tx] }
  | SymNoNewCoverage
  | TxSequenceReplayed FilePath !Int !Int
  | TxSequenceReplayFailed FilePath Tx
  | WorkerStopped WorkerStopReason
  -- ^ This is a terminal event. Worker exits and won't push any events after
  -- this one
  deriving Show

instance ToJSON WorkerEvent where
  toJSON = \case
    TestFalsified test -> toJSON test
    TestOptimized test -> toJSON test
    NewCoverage { points, numCodehashes, corpusSize } ->
      object [ "coverage" .= points, "contracts" .= numCodehashes, "corpus_size" .= corpusSize]
    SymNoNewCoverage -> object []
    TxSequenceReplayed file current total ->
      object [ "file" .= file, "current" .= current, "total" .= total ]
    TxSequenceReplayFailed file tx ->
      object [ "file" .= file, "tx" .= tx ]
    WorkerStopped reason -> object [ "reason" .= show reason ]

data WorkerStopReason
  = TestLimitReached
  | SymbolicDone
  | TimeLimitReached
  | FastFailed
  | Killed !String
  | Crashed !String
  deriving Show

ppCampaignEvent :: CampaignEvent -> String
ppCampaignEvent = \case
  WorkerEvent _ _ e -> ppWorkerEvent e
  Failure err -> err
  ReproducerSaved f -> "Saved reproducer to " <> f

ppWorkerEvent :: WorkerEvent -> String
ppWorkerEvent = \case
  TestFalsified test ->
    "Test " <> T.unpack (showTest test) <> " falsified!"
  TestOptimized test ->
    let name = case test.testType of OptimizationTest n _ -> n; _ -> error "fixme"
    in "New maximum value of " <> T.unpack name <> ": " <> show test.value
  NewCoverage { points, numCodehashes, corpusSize } ->
    "New coverage: " <> show points <> " instr, "
      <> show numCodehashes <> " contracts, "
      <> show corpusSize <> " seqs in corpus"
  SymNoNewCoverage ->
    "Symbolic execution finished with no new coverage."
  TxSequenceReplayed file current total ->
    "Sequence replayed from corpus file " <> file <> " (" <> show current <> "/" <> show total <> ")"
  TxSequenceReplayFailed file tx ->
    "WARNING: Sequence replay from corpus file " <> file <> " failed. " <>
    "The destination contract is not deployed for this transaction: " <> show tx <> ". " <>
    "Remove the file or the transaction to fix the issue."
  WorkerStopped TestLimitReached ->
    "Test limit reached. Stopping."
  WorkerStopped SymbolicDone ->
    "Symbolic worker ran out of transactions to work on. Stopping."
  WorkerStopped TimeLimitReached ->
    "Time limit reached. Stopping."
  WorkerStopped FastFailed ->
    "A test was falsified. Stopping."
  WorkerStopped (Killed e) ->
    "Killed (" <> e <>"). Stopping."
  WorkerStopped (Crashed e) ->
    "Crashed:\n\n" <>
    e <>
    "\n\nPlease report it to https://github.com/crytic/echidna/issues"
  where
    showTest test = case test.testType of
      PropertyTest n _ -> n
      AssertionTest _ n _ -> encodeSig n
      CallTest n _ -> n
      _ -> error "impossible"

-- | The state of a fuzzing campaign.
data WorkerState = WorkerState
  { workerId    :: !Int
    -- ^ Worker ID starting from 0
  , gasInfo     :: !(Map Text (Gas, [Tx]))
    -- ^ Worst case gas (NOTE: we don't always record this)
  , genDict     :: !GenDict
    -- ^ Generation dictionary
  , newCoverage :: !Bool
    -- ^ Flag to indicate new coverage found
  , ncallseqs   :: !Int
    -- ^ Number of times the callseq is called
  , ncalls      :: !Int
    -- ^ Number of calls executed while fuzzing
  , totalGas    :: !Int
    -- ^ Total gas consumed while fuzzing
  , runningThreads :: [ThreadId]
    -- ^ Extra threads currently being run,
    --   aside from the main worker thread
  }

initialWorkerState :: WorkerState
initialWorkerState =
  WorkerState { workerId = 0
              , gasInfo = mempty
              , genDict = emptyDict
              , newCoverage = False
              , ncallseqs = 0
              , ncalls = 0
              , totalGas = 0
              , runningThreads = []
              }

defaultTestLimit :: Int
defaultTestLimit = 50000

defaultSequenceLength :: Int
defaultSequenceLength = 100

defaultShrinkLimit :: Int
defaultShrinkLimit = 5000

defaultSymExecTimeout :: Int
defaultSymExecTimeout = 30

defaultSymExecNWorkers :: Int
defaultSymExecNWorkers = 1

defaultSymExecMaxIters :: Integer
defaultSymExecMaxIters = 10

-- | Same default as in hevm, "everything else is unsound"
-- (https://github.com/ethereum/hevm/pull/252)
defaultSymExecAskSMTIters :: Integer
defaultSymExecAskSMTIters = 1

defaultCampaignConf :: CampaignConf
defaultCampaignConf = CampaignConf
  { testLimit = defaultTestLimit
  , stopOnFail = False
  , estimateGas = False
  , seqLen = defaultSequenceLength
  , shrinkLimit = defaultShrinkLimit
  , knownCoverage = Just mempty
  , seed = Nothing
  , dictFreq = 0.40
  , corpusDir = Nothing
  , mutConsts = (1, 1, 1, 1)
  , coverageFormats = [Txt,Html,Lcov]
  , workers = Nothing
  , serverPort = Nothing
  , symExec = False
  , symExecConcolic = True
  , symExecTargets = Nothing
  , symExecTimeout = defaultSymExecTimeout
  , symExecNSolvers = defaultSymExecNWorkers
  , symExecMaxIters = defaultSymExecMaxIters
  , symExecAskSMTIters = defaultSymExecAskSMTIters
  , preDilutionFunctions = []
  , preDilutionWeight = 0.5
  
  -- Multi-Layer Fuzzing Optimization Framework defaults
  , smartMutation = True
  , mutationDepth = 3
  , priorityMutationRate = 0.8
  , normalMutationRate = 0.3
  , differentialTreatment = True
  , prioritySequenceLength = 150
  , normalSequenceLength = 50
  , priorityGasLimit = 8000000
  , normalGasLimit = 3000000
  , adaptiveFuzzing = True
  , crossoverRate = 0.6
  , elitismRate = 0.1
  , diversityThreshold = 0.7
  , optimizationTargets = ["coverage", "bug_detection"]
  , strategyLayers = []
  , maxArraySize = 1000
  }
-- | Get number of fuzzing workers (doesn't include sym exec worker)
-- Defaults to `N` if set to Nothing, where `N` is Haskell's -N value,
-- usually the number of cores, clamped between 1 and 4.
getNFuzzWorkers :: CampaignConf -> Int
getNFuzzWorkers conf = maybe defaultN fromIntegral conf.workers
  where
    n = numCapabilities
    maxN = max 1 n
    defaultN = min 4 maxN -- capped at 4 by default

-- | Number of workers, including SymExec worker if there is one
getNWorkers :: CampaignConf -> Int
getNWorkers conf = getNFuzzWorkers conf + (if conf.symExec then 1 else 0)

workerIDToType :: CampaignConf -> WorkerId -> WorkerType
workerIDToType conf wid = if conf.symExec && wid == (getNWorkers conf - 1) then SymbolicWorker else FuzzWorker
