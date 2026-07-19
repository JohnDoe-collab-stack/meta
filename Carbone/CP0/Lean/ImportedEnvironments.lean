import Carbone.CP0.Lean.EnvironmentImport

set_option maxRecDepth 100000
set_option maxHeartbeats 5000000

/-! Generated target-free CP0 environment data.  Do not edit by hand. -/

namespace Meta
namespace Carbone
namespace CP0
namespace EnvironmentImport

def importedEnvironments : List EnvironmentTemplate :=
  [ EnvironmentTemplate.mk "0123483cdf29c21b4197d81102cdf561f708e9672497bababbb81aa89f0bc31c" "939af634e9f35c2c715b16628bca4a32adc17452664d26f4b44b1b03064c5950" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 14 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 9227469 8388608) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 107 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "0a72a1d5bf4f643f58eea7ce7883afb861d22522ef3e664262c5fc866dfdd804" "95e8ffc42ee61220566cfb4c96a9fb9bb45dc06261eea26d55ea635460ad94fc" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 96 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "0ade244afeba8ea78a3e5bb80a7d4b61d0f0efe71edec57fd968907f2a27b18f" "a7dfd3b36d2560d995c48cef4feffa907c098bcbbb8dcaa24ebcfcc2018596e7" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 178 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "0cfbb37350180c4b6255b4fa13a6676d520b82bdd1258ab9142fcd4eb448e3a2" "0860019191f4a93d1c82ebf19cd38a8f9d3560f14eb0503772cb879369c1dc9f" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 186 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "0d62ae2535e8839622048ad3e921a2bdb1d09039fea796f7a4af9ee4f904d8ab" "fad606f9631c021b3baf95f1e1272537a9af34daaaaca0035be36685235c96be" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 120 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 13421773 134217728) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 94 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "10a3e4c7110d47ea0f023ee1e0ef426906aa155cc4e91c7f26bcf5d7ffd4c432" "6d2c2b1a9999ae814c026ace5dfb4c938044a997cc746b8e4882ff5e59bb2d36" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 145 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "12654fbe4afb144f86ee7faff06d292eff52408ea62bfa66db91d88672d7b3f5" "010baee795fb4f00194dd43d517e16fec589afc3b584586ce60fa459fcce742b" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 181 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "148a991483b32e8b50fd022029b6ce9aba3fe1d78b25c0e303d115b8a9d5f30c" "3263e6ac8a50b2d6aac7f140510f3971441ebac657f3dc0a7656777dc3ce0a5c" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 41 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "185b74020b2a779026a2993c2109fa3c5f7fa352f7f64c31a6126a0bbeee3dac" "69c04c9836ff3ae2ca364b40aaa06efae58e891bd408a44db25fd1a9398c3bc1" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 184 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 8 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "1c39bcc1f5d87dd3fb2df9e8b7ba4f7284d974ccd5f054ed5ebfaa158283ac9a" "1fe2c3c41b7418ac96ec51e423397e0fc9139310c9a67b781314121835c63279" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 100 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 46 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "1e0069d7beb87d5d9c8034cf015c99a4da2cf16aa4f422cb8406d599d693563f" "5aa9aead2bc9be102228baedafed8f0f4c910148c7fa9674b22998b96c8df902" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 184 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 87 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "1ff66211e617c97e784b19f02393c50e2a6c7d2435a744360514a5aacf3d93f4" "b4c86ae41564102fb091e1766dd6e7c1e54696d98c7da9cc299cd005fa7f3006" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 172 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "20fd852de4cc097f656b8970277a62dc036a8ff8d1d743f85ca3e3e9e37b699b" "f031b304d333dbf6dd5d719826862c91dc2465e33d66c21751152b4ecce26d87" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 87 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "23b5f8203debb6ee5e85316abcfc19610f3186dd6b4fb5ca68115eebf8a5de56" "a3bcfa545ec6447e4076dd6dde7c6379c1d14614aa9012f81bef1f690c1d9695" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 94 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "265ec339b3332cf33531c190be7d5a21a8283819e576ace6718dad3ab05df22f" "e15315247571bc4ae8ed565274685cf1b88581a4bfa26e2615713b89e5101b8d" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 120 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 13421773 134217728) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "2a619d796feb3b5bd2fc9bd7506e143ebf4e0f3b00608b51122cf4604ab48415" "5a5714766eee8e8bbfffe4a69278013a019a4763928da4c92b346a0a1a6db4cd" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "2b967e4f7f4a808e53fc47c08547cb7bde2f87feefe34e7c5895ac36b77ed9e4" "8c297f5b31ac3fc8aaa53df12d69769d720a801488c07779e9c87ca61f246b3e" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 6 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "39ba777af1cbffb13decc755e9c85163a74c2d380d9cf911aad49482ff578b7e" "36011c625463c1e3ab4033890cf7588f07ed54bd7fea47324a9386ac7d3cf0f0" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 184 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 140 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "3c1f91d82ed4bc67b0e3a6a4e6029dd091e5c36960ad3c71e77ef309da6f273e" "3ed1e6a7deb99aa10eb607d37fc7b5076be391d71aa23345002d774d0efaada9" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 165 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "3fb98bfb7247d84598233ad50e6b4f4248eac81c767553bfceb8b67b6ed1ee9c" "4315b6bdcae7bae1aadbb707f4a880c487bc4b161f059fbfe7f44be43b7c0004" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 58 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "4166304973039eacb55316da7779cda66747f262a2203b67453a31e950e22808" "f005b7eaebf6b834860631309e17b69ee45c22500e73b25cc812c3dd7e6cadf6" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 193 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "4541c8f83b42d7a2e0306412c678615e5fda4ff43b46fd028d346e6853ba786a" "232558e497d6c73fe54222effd696f2485299904b0bd6d70fc5fecd0371e7022" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 94 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "454711e11286f336ee73d234c07113c06be7476ad38f8f62b1ba3df6cc6ab25b" "4f83c2da21ce6364f5f38623649f6bb6c95a224be75f9cc669a00d1e195d9380" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 145 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 8 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "4875ea0a114106cb3fc4f64f2009970cf0904dbe87630e48a46a5cee82c2e161" "e842a37b9951a2c4f491eedee6ae00183c1e6a956dcdac1ac508a29c32f1c719" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 171 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "56b893548ac05b21091e45e3667c5a4d2b4aa4feaa87fbc2f58508ff85051288" "3290919cd53a882d39239f2d7958de2989e07deb3cb9c9cc4c5d233f4d328e66" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 125 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "5c57c13d8b64de9efab0cea3946c10a4c247a66d766258627d31bc208349ca33" "18c65d1eea4e9bc392d757fd73fb5ad43f5dcb863b2c8fb75a2dcb98fed9c4e7" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 173 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "5e59b4acd2f3e6686f978df983f674106dbb9c5078b6db7e28abce14e3e88b4d" "722dab897b8f3d7d283f03d15b1ebb65aeed875ef2f10f6411e6831cdeb17bbf" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 136 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 8 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "6510e13ebc7666252896d6b2552fc176189fb1ee24dc6ffe9539ed616e9cceb3" "0b6c165f24285f8e52258a25ac55b26f401c5d54df388832e74b7d48cd0c536e" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 168 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "6975ce6695a801b51d6e24cf473c208c34e82e40b6cb3eaceca937f64dcb6007" "d3fb14dd2c5f3ad0e1ceeab0d396431139d3ae365d634827fb85f8b607af5f92" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 83 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "69bb63e2795278be1181c1b667954c81ffe73a9338f36cbe07a4581462c54c21" "9668005ff1ffad71f124c5b7c53d4d5d9363448b290ad15310637ac30380877c" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 145 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "6a3d41e4d1cce8c57f0a297d87ce9a130c719e62559bc7e22c36e06e6bca377d" "f9dd9aa502e935dbb806496fa9ba163a22ef9d2d34c550e33a4b174610d0491d" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 96 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "6a905497446eef6dc2f5b855c9d252b6b4fad5c3bf01bd3af1c2a94bd26c3e64" "027404a14b3af92612e6734a4d1c758d742e316f739f217aa9c11b04e42df40c" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 136 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "6d9f4d043a88421924053cbd07fd78ba6d41d7d9bf948399d25bf5408665267b" "48e7757932c13d549e94e4455b1928a504505aff3b8cd4892213b27ddbf06f89" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 72 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "6f883011b3d9ca496c9598e8172b46be426a6c8457140fa065dfe8c6dda02724" "5752f1720064d86b734ff7785e8d4e4d19bd4772869ae5eab54e052eebbd4a7a" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 145 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "70ba5ffb2ebabdf7e24f512bb48ee70200d48a79dbdabceb1245e15d3cdcc03b" "1c3d02226e7244856ea99f592631b05c83c1715b9020179972be677ca6752c42" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 184 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "7219340849f5231f1210c6c7deff89dfa6bdeae7a5dac2ffa732feebc162e743" "221de68a6fa0b62e6897c026c0bb0d188a4dcead6f172c2a9516e68d67b1ee55" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 176 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "7503b21cce9aee118104f94d07cf02c21877eaa5157e97f02d836e7617f0b994" "a2b806c03a8663dcc10962c2b226d89ad4e04dcfc50654e83a14a2e1f1ede586" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 119 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "75f6fd8e31ddf03381e6e37baec0c29247d6d27df141b12a9ad6a46b7a7c7306" "a227f20d5474422e121beb43a43c169ba78093454e097fbd9e62094be39984d7" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 46 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "785e887051f8263b5f30f62e5863004135d97a4229f301a5687c74277f3880b1" "673dd22cdd7787bfa2951890a7e916e181b48a3fdafb7bfcb680b2f818efc457" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 42 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 114 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "7c2de13d74a71c44042730c4f3b837cea26c036df614f043b0c073b1dec9bf17" "ffa80eaa9e1e3be8dbd38b36fa9ad92a7b6b06abfd3ee12661109e17a480a22c" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 181 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 8 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "7cafa0a280f263e8bfa5a80f470522a3ca9ec3615d6976175487a64d302b8297" "e9406f4c9647bf193e5a5e5877833c7033fddace9f6d4ff1a4d63f5b744bf453" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 181 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "7f3b91c83b54168d175f2661889a08b26fc4867130cf43e1bd2c79e399f5ca7a" "5bd97e3d69b5a8457e40575947d1c6d344d0d80ca7dbb2745f6b2d6d0fdb5f23" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 184 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "830ad74147df31ad8af9b2ca988a028cf90cdf0a0e05c6470b9ff109680aa34d" "b2be611a65ee12acfdd78ac8197473ded6f5544468f666bd22605cb26e0dc7f1" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "83e505bb72d22707f2528cd83bbd79f6c3d2eaa1cd87cdd1a9fd913562a09991" "83664f9aa7739d18912dd775792c66baa7b5cf4ab6fcb32843de27122a7555c4" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 136 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 8 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "8da67b0ca2ae4b3d80d7e70684fffa628ae635bea0dc45ae18f03f553494aa10" "a8365ebb9be91d5b3d0077d1c21c79fddd6a91d8eecfe5614ab523fa83c7c7a1" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 100 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 107 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "8e9993105e4b11b3cf9fe5e5fbd0789cda91d2a38b49a7887c07bd46fb7dcdc5" "3dbf5aa58217d4a3c92e8dcf14ea7ac20e525d27f562e2482fedef2bb72bb581" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 184 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 58 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "8f273aacf9a335432e0b96ba766b458340c7f59b71ba6b36f19a5ca46feae93b" "c9485fa0c2306bfc2e840e74b6897dd930ab285de75f02d6c0eee57472651f60" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 46 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "8f7e088c50492e6a07b9a4f6545fdf0d611a0c4bea0082ec1b93d03ce38cd11c" "71e7bd4fed08dd34180318b146066a597fd4b20aa5e3443c349e17ad299439a0" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 187 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "9530b05f4d0ab4ddc1c8879174dc8bcf05bd85d22b859a654fd6fac2285f2bb6" "648a8b8088b1051f63cbff468ea5d0f56b188757af06653c2b4e5c73aa93ae11" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 142 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "9c48f6b0a0fca8035e665ede0b113915a85cffdd17a6204b052eded303e35cc8" "1b3df86337da48bd76d6d3e1fbf9bf993444867399066f3c986e85ebb3a6c905" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 181 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 8 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "9e3b528d9f16df747e818c6904622dd7f36325ea8861e4c92d041ea0fbf55869" "0a2dec234ff678fc4fc1b50298f741e6e039074549f216804144b29ccf3fe533" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 145 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "a1d8e92ee32127f8c07b1dc216b2edc77840a20841a94cb7fccc287f096534a0" "43ce035db623d42d37508fe910f3ffa210c3b84b323cffd7dcf2fc8c6843219a" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "a3a2648884c704b830721f177ba6b4536449f30a4f39f64388edf50f5857089e" "4c648e4eb94f75c0dd063b61333dbafe0b03d9e2925d89739ba162df9ca7d8d7" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 48 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 5033165 4194304) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "b3202815af18cdcaeaace808b071533318aa0ff5cbeec9ea055e2e6cdc8e85ad" "af84677ea4b1b9b4ccee3f33e629e8b144a95ca1888bb7c48052cf33d24c5409" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 100 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 180 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "b524989468ec314c84c05c1da2f5070db8377809b788510b198c3e86ebbedd0c" "4db21709f2e0ff0c61e9147b20e863e217787348b866704d8e170c1fffe10234" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 183 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "b62689e0afb6f37c4054c745e4fee61eb360e9332bf7b3eda1a215451da0d15d" "31c8f9c124640a1c8ea172421e3c9465123cd334ff5308ac59eddc9f2196f75d" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 184 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 72 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "b84f0698786a49b739a0a9805500e522db6c4647d67ef2ff1c85187cc26b49ee" "863914057b91295d93d0d45565c343cfad941678d3348730327b754a3701c13b" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 1 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "b86ee713353d31a04b81e11caada85f3cc7afc0889a5bd1f33e607dc4763e156" "72373c07c6dcf76d8fd3ce272a644ef8cc9628befc307dbd7a99e27efff0eb0e" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 30 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "b89030c55d47f3467849507dbe2fe3b38e0e31ca6a322aad995c312fa8ba5446" "e06ea3c45b8e2b04968e12814a49ba85f1facd86dad3db2dda2724605c0f829f" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 150 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "b98f9b786fa1a32360122120205aefc7dd75c6331eb1158f914c5946d8469a5f" "7103b628d72c3e171ce03e02e9c2dd8e9c95c35730a8d5b810b137728241fdb5" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 184 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 114 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "b9f6fee1cf07f48c6019d4cc79d1bd54a41794abef84a97279471a6e019c2851" "46f530d747b4deb049b2c34e6048ad837e1eeb0f0691bb5472a756a15950da5e" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 67 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "bb2d5101917ddb0f44a424081c61824f5c53081e46336779cde80b3736c797e7" "3c2ff23734f75913cfecee81d57e05fad2b9c15db4647ca33faf87f628444a30" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 187 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "bba91f3959fb635b247708e54efb5fdaeaec64194d5464f056ee9b9687445fea" "8f566dcd41b180410f62054548f8188ec5aeab5432180994de1a2e6390cbfdd4" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 5 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "bc758cac7add9a09ee93bc9bee3529ad8c18acf37bd1cfdac2a266fba817cd5d" "9c55c49ff727e191ddbfd35621509f739b6325fb931b9a96755b324fb556126d" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 174 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "bcff81a6d5daaf95b9135927c287a46dd6cf8480c826a6cd5d218be380d13a90" "1f6676675f1ceccca8cc90623c4d3718408b5657578389e490e78e853ca2c738" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 6 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "bf2d539e7ca5a1b26a44eba4b2e121c4ac1fd8492f661802d266759d4e11b971" "a201576f2900cfd4a3c333a65619c1c8f80c1a0c575c6703a56ae2a018b543bd" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 104 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 9227469 8388608) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 91 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 4) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "c13d257b2c5592be8b4645ad811faa671132c5effa670481daf908e34cc60219" "f61be1dd1d9beb50b89b8027383f4553105d3bbc02c2de589f14f28518759e99" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 162 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 120 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "c1aa5079e185a8f0c2ccebff33c0c92a16488c26cb2724af3471334c4c8fddde" "73abbb783a19df8ad638fc4736b73a52b1f9490a467e31bd65c663b8c98b2ce7" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 181 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "c6efd3ce8b7684fbbee81945bdc045c55f4dcbfaf29fc607bcd5a21a04f13777" "c103461355b66a1f27184d11497397cfc899543d2c2402fd4c3ee865a3199837" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 136 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "c86cc15fa75d08b94f09ac0fb2acb7b1e8d15c68258a4f5007fb3da33f6114ca" "215d58114ac5053cb03f79afcb5b4db99b3b7fb056ae74af9cc91ad773b0a31f" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 61 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "c8b96ab2b21c7a59863f23d54c6ccf89b3a91e27f664a4b055643b021bfab8c7" "971a057dff25688a3d7a572664f28f04bc9128a827f347d5484206dcca2ea6c5" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 100 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "cb92403a88f07cdeeb126165fdb711a3f0db139ddc8c9e93fd15a0844e063b19" "afcde7301340677a4d9b1cf7448090f2837e2c0fa6998108b9f3586aedac942d" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 184 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "cc47106db35f23529ad668e01bdecb5689b5e8e9171ef52c911b27fc42421934" "118afede980961836f404029b7fcfc65322f8716aca94bc523dff52d5c45f68c" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 28 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "d00a48cb2d2743a2de9c892f5620320e9a091bbc610e1e40415c86f3db37a73c" "ec3d2d9839f0944513204909a8670290e369425b6e25ec17fd0c561e8997b544" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 168 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "d0d5861f3934dbefb5cb73f834d9881a30c30e83cbcc4a643c4727d340746d70" "1bbf359f477b626f90749bf57bf5d23910fcf4aa5e390583a3c267ba8791feaf" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 171 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "d67b4f73a459be75e6e0fe6e1d5c6987e36c4fa5aea5263bf2fed2a7c9642485" "b5c8744c286d023c3706ca94566eb27cafdfe89646fe12b0b65ca77172c9e9ce" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 41 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "d6f37d86ead92a19c1e28732213e69ea4f090e6dc724421100836d33bee4d36f" "1fe4d4c1f9e54dc271903e3554e65ec9a3cf5fc95028f349948e9b916dfdc5f4" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 6 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "d903bef826ece817b67cf5353d476f80205cd2364cb0ec36f7c14c1bd0683ac5" "872fc9a94affc6457e024161b400c7150480c1df5aa54dc01924daadaea34fe3" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 140 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "daba3aa5aacb7196c2fc32c014c62e958921f7077a3a45c1c3be7e554a6aebb8" "8fb06a5d6a52032f11f81aa1ec8b1d690f97de7b3a7a0466f487450ac6989775" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 184 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 179 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "db6e530815ce18bcc3b43ed8848935efab4ca20869e22cc58cc1a4046e186b0f" "b22ddd4730998bfffdc6f70f8391af80b22fd0fcad9bb4b43d3fc4b293b97833" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 101 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 175 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "dd74cc29836863a0ed08214b7fea8dbf9c5fa17464a363d2c9a8b17eba314ff4" "9d7ddee057d188372f6654fbdb1898dd001cde290d6f72d3495e1031eb007a07" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 60 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "e0e8be54123a8da985c22ccee8e1179f74b891d8c312e95e5dad933e9b91891c" "465ba2ca7379562d077975f961687c99b4ade51c68169e27367528d1020dd2b5" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 145 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 8 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "e1095e0023168b3e5748f03540f22a5de753b4fcbc6601c1ebd9a32d1fe1abc8" "ac4b80261c2b29eb5c4ec9e1478674c30d46b88af9107856fcccc31281cc79cb" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 168 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 107 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "e2e90c29294e32f5f314d657f596e87e3ecb7dbf4835d422a72c2b65fdc80635" "2aa2a15b7ba74e21f6c2c473500dea7e20d9f1e50c442b322ce2db43d8a86d44" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 181 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "e69a02dffdf90f7f01e20afda010e006051fd8c6c4ce46362f49564ca63201d4" "b6e08834fdf574e7ff89a00c83a58d20390c984e87af7d655d5a6bd174911c74" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 186 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "ecfacad1fd1169f9051d7be83b28c30b411f194c0e856db9abff6b0071ed4513" "b5cab0f674fd5029abb1d46121b1f6639b95eef1404f3e6c5d95776759f5ca8e" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 100 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "f379bc8d8737f86ce03c792fc88078604c284a929d025880e14adb0f683d06d0" "33d61513168fd96b2d2858339fc8f186af7a637507cc6d2986b695c2f434c4fc" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 100 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 41 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "f431b41fa7ec1b55b9c455fc18ab1e6eadd90ad349cbf31c777749cd002b5b31" "0cb6fd0f2ae937cdf20f2a0982ef2dc29243c42d4c2f00f0500327b73ffe063d" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 184 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 107 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "f6910f49e73f6aa783452aefd57b70f5af9fed0ed9f3d17cf5efea6c8c2caacd" "2fe8e3d5d16a8b0aec552a1aa418db590bc018edc2ab7241077c53784be0ac7c" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 179 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "f914109756c94b081bb3052eb7052d9dd8c05ebd575e52e3d00e9d0538f4c22d" "8783f6120af1bf7c512ddbd5328b4a10efabbcba10ea0f80c9ff66594bc2100a" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 136 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "fb7a9bdd1e05f0de56d1112378ad48c9b6f8babcd0b26422f3fdb2560b5352f7" "5cfd1d19c45293c1d2e2c76dcdfecd41c16f1f79d42c83b5e755f5423448c7a3" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 171 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 107 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "fbbd948fb64d9f381a80b7a7c7a3071b72e28638433660cb831ab68c98cdd803" "f41c43a28edbbbcb8d53ac6459ab647733eaaa147fbe15907eb6ca757d61d0b0" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 102 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "fcc4dd2b046bda388f608eaba27cff03e36264b341c6417ece94ccdf62485796" "6088fdaacee6c87df91e1dce4c52492618492e2aa799b6a0ec7f921a2b1a0472" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 136 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 53 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 40 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
    , EnvironmentTemplate.mk "fd947534dc3fc36dce4b500b889434b8f102eeec899324a7a2690289a3ef39f8" "df3adbd1fe4f8c1e44cb2ccf11520a3f5866ad24e7af573cbc821234ad185396" (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) (ImportedAmount.mk (ImportedPositiveRatio.mk 1 1) .millimole) ([ ImportedComponent.mk .carboxylicAcid 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .additive 6 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .additive 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .activationAgent 97 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 2) .millimole)
      , ImportedComponent.mk .activationAgent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 100 1) .microliter)
      , ImportedComponent.mk .amine 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 25 1) .microliter)
      , ImportedComponent.mk .base 164 .reagent (ImportedAmount.mk (ImportedPositiveRatio.mk 3 1) .millimole)
      , ImportedComponent.mk .base 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
      , ImportedComponent.mk .solvent 133 .solvent (ImportedAmount.mk (ImportedPositiveRatio.mk 50 1) .microliter)
    ]) ([ AdditionStep.mk .carboxylicAcid 1 (none) .pipette
      , AdditionStep.mk .additive 2 (none) .pipette
      , AdditionStep.mk .activationAgent 3 (none) .pipette
      , AdditionStep.mk .amine 4 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .base 5 (some (ImportedPositiveRatio.mk 1 2)) .pipette
      , AdditionStep.mk .solvent 6 (some (ImportedPositiveRatio.mk 1 2)) .pipette
    ]) (ImportedPhysicalCondition.mk (ImportedSignedRatio.mk (25 : Int) 1) .celsius .dryAluminumPlate .ambient .air .stirBar false)
  ]

def importedAmineIdentityHashes : List String :=
  [ "040b8fe7c214e871685ff4f24c09004efb8fde442fa4aa7dedfd4356585b0fd8"
    , "0aeac3787886f84198f1c487fa3ce9f5aa213351e47391a8753d4d2fa7565f01"
    , "0d3ba29e11b425b6a7015fd78896e00b887ea1b77c98fbce55b9eb8768b62179"
    , "141969a5555636266f38449605ef420e8e121b2a7802233867129070c07ad941"
    , "1a14cd5d4d8db1763f1214f44614f5671d61a962a7e2c584c17c37700c69f054"
    , "1bfb450b836b89b6800cecadb3b3fe8d951d47419b36aa52c1bd96dcd1306f47"
    , "1ce42990d2cf1e018cde4634935ea2557f3c32bdbddc44eaea82d1ebc4bd9891"
    , "1e006f3c2e92bbc04ff911ab2e44abf412ea94fd810fa9350d38492ea25b8970"
    , "1f385b0db1ca840c6e642188e9b8f1fef3930dc9ad3dd3ee3a845092fe3f1334"
    , "222351a0beeca381af2c540baf2f4fa9fb0558bbc99f1a3aa59e7f8188e8d298"
    , "235cdf210780f216cf2ac2ce1b8396ed4accc98aaab4e67de7b19e38c2bfd257"
    , "2663ab376559fefdd9d3c7a5342326e6e06a33ed66791d8db75080f04321ac0a"
    , "277a576f22bf3a170dceeb29d7550b9697b61c3f01d9e7a8006256282c6954d0"
    , "31ae9cfbcb79e8dd91c59011b36ec60ae346d812c4f8556413317a6db43093f0"
    , "3450520bb10f660fe10201590f4b43bc1dea2793c516805ede3f0dbd197e8379"
    , "37fd2ad3aac83a71404cde8b78710535fc7ac7945a1a5b7c2e4c9cfe5dd5cb73"
    , "38d3eb2b20cda29cb11a44560840e652b38e226fd8e399b98c5e815e844c79ab"
    , "3a384cb045f3d23e7e905f2b1d9888cb864ff2fdfe33be5e8ff6673f18b83041"
    , "47fdad0d57e1a97afbf343384bda63a53efc0beadeefa151fb6a10201992b55f"
    , "493612164b1af44a62d9e1b1c5186ce35e3a8ab84e2c0047deb47b52005d9c07"
    , "520cf480a0621ebc4a9aabcc25e3351bba3ee72fd1c6a912f6076b082ecac671"
    , "54e471d7f88a70fee11ba97d8f8a23722a914082ff064145a681ded9065a187f"
    , "55a5eb2117948936248bca661b8723ba3e7000f6bd3645adde92cd6753fdae68"
    , "577f0d06f5075804583aeebb7e345507eb282d1a1eff50d12ee51ce0b8632f18"
    , "6fee75c4589dd53d632cb572105e6b85cd16502fe3226cdc25197024d3ebebc7"
    , "709c850c68df1389ae113bcb9df351cf22474bee6511e2d154f0f18d86c8dfd4"
    , "70ed69bbf946bd31468ba7227fdf41f8123c1ff18482b34a58691746560d41b9"
    , "721b851ef2d015c64d5c3bf8c0ccf86ccd811214dea85f0bc9b289e8c2bfd3b1"
    , "79fba427e8aece74a554958114fbde79d75912848130184e6f8cc0a4ef67b2fa"
    , "7aaec9298a0d139ea639b2575a7847811853807b9a676e6ad6d2107fbfe8002c"
    , "7d6c5a383b4d7f332b2fbedd6beaa1da377ea1cff42441401d8a5441fa49df3f"
    , "7eb1b0bc6101c62065cbe52eb9fdeabeb51655f7ec2b8f2f5b9da44dd8737f75"
    , "8383f9a2f8234edfa2cf341a29d072fd39eeb59366462604afd608afebf829c2"
    , "84182435ac1fdbace07e84a2cb4a83574ddd5ddff8fdef30d5cd9fb1ee49e3db"
    , "8759f91274eaac2f504f39ef186c63ee9863a3e4364d54ee7c0db0f4fea80c5f"
    , "8e789dc83d69d912c9b64c09a0bcb7e64524d3d7400a2a89ee3900ca33398bfe"
    , "93992c9a35a689c4560993510b7975c9eef1dd8d81ee7f4162f93fbccab4a7fa"
    , "978a462b3bebc912f1ef99d7235a998cf627df12e5271135c4c9ef8ee30b897d"
    , "98eb5c83928c6ddbb3d05ae4a2e3b0989d165033efcf4711ed5edbdbcebfaef1"
    , "9a0cbc800b036539d6c4a3fb00039d9b797e9f492c2e5fcccb1ee3a25822d2b9"
    , "a0949a7c458e910c369462a035beb94647ab2b28b80579953d4f67761e8eabec"
    , "a2723416f78157de455dea9a746be22aea47aa14076a3329bd88fef23c3ec19c"
    , "a5f60319cca2467043a1e6b1fc29e0f7144e2f7e5baf67fa9af83dc7ba35727b"
    , "a70ad7f26343a7a7e84044262decd98da1d31a2d08d912abf7bee0d42e082570"
    , "ac25b0cc6e16cda7dea7919c3daebb9dd3882811cc354a7e9cff2268020d875f"
    , "acb70b440ecea9ede8f9adb107d31b238b3d3d1e3e8efcb141f9511f3e851435"
    , "af3a16b984a76e8b1e59bb6642fb5387dce2dccd15923257b79293f6f8eedf82"
    , "b339f418baa9acca6cfc23ea162aeb549b17b5fb76fd0760a8b2976e8a42ddd5"
    , "b411378ee9c539294fb8dc3304be7f3893968ddc1ac12bfbb8043de1a9060e6a"
    , "b85b08145ba43cdc1b18c6d433a5e0da60c5fbb6c8cc76b67c4bbfc5afecd0e8"
    , "bc1f13bbf143289e44217068a63f5af16da5eec929f918235a866be3ad8e1cca"
    , "bc22b086455fc1dfae1746130455d37a3c0df05fee224c3fb0eab3244b20f7f3"
    , "be705e7c18daa81f2c96a9dae3a52d74440afe3b3fd63a73b74531ebad91e432"
    , "c27c276c2551d347e09acb75fa42b80c43f776ad7f988417749598b107e2853b"
    , "c553474065e149af0eb5b0a160fbaa688b0fe3977fd29178e1589eade722127a"
    , "c74adfac74acd96bdf6d53b195dc80cf9de7d3f0cf1de39521d7571d173bcf5d"
    , "cf93663130c5332f0949c18be7d17462ad5ae05b4790f7aa786d931466bf69b2"
    , "d29e5be0c6f2cbb48ab9d8024740808c064d16448b23efbccecc8ba29ea99ad8"
    , "d4f0f639f74eb8247f2098d0819c15a544474472b5e21222e6ff5a995196b326"
    , "d83232613a0363382afd39781a88377cafecb8027db2bc00ba84e03eaeaf4edd"
    , "d8caf8ed5904ce26e4289d18037297bd02975941b254a423fb8a84689ad6789a"
    , "d9b423575b18ea5dd545c472246049dde19dd35f212a26a46366910a294e26fc"
    , "e0a6182bb4c9fa86c06baa9d94e714efe303faa34c472884492b5dbe837be63b"
    , "e2505aaaf02c24f7e92b7dd5a08c7ab2a8deb856c243baf80c14d0a3a92cc75f"
    , "e645d77084d3563192e96fe9f0e016d6ac8ba0a073ff1cc0a285793f9e77e9d5"
    , "e71e6735d1beb5975a59de3b44cff1bbc0fc5209939224775723c1356a19082e"
    , "e7ade8f5bd9b7041887f28c49312d3f431ddf6d7f3f534c0ed1b41921abbf36d"
    , "f58facf26b014fc82529430cd0f8f0230ead6c65b9330db19a7866685da149c0"
    , "f7d02104835c4ebcf0c573e16e9a938aa9efd95f82ae1e6830d47a652716dacd"
    , "faf0102abf4f34be3d5fb7cb8c7fac51e78665b1dc9055a10286a6a02b917533"
  ]

def importedAcidIdentityHashes : List String :=
  [ "0adb3ffe8cee473fa7c9c5cbfcf58048a186c569c7c4271bf90a1d2021e9c6e1"
    , "0f60792fcdec24e75760f6b907c94ecd020206167c581db1d44a75b7cd00eb1c"
    , "18c080f3e4f4a90390fccd498bcc8982c74e8f941a5b64a5c933537ea33c4ecb"
    , "1d8278cd05f75a09765b4a91761c213e543d0a41020e3891cbaad08cc7c34ad6"
    , "1ea401dd8a4a2d81b0a96845eaded0a5de20e769fa56bb9a156d01514d206901"
    , "1eaff18f2037bb67b6ca50213d2c11f02a1e612417954afc901b342b3f94590c"
    , "21e776dad51ee65c1dc88b94fc08cc0b2a17fff421263163188a57a2243f0731"
    , "230e256b98e4b84b530d01cb51f6267a7a89bad75aa9fd561cf0fc518b70808c"
    , "24232cfed9fde4959047ee795442fa08c8698d1c37ca441bed8c48304b80ada0"
    , "2b334968e1373e20ca0b2dfdbc944a193b33ffb87a28a8bda4862604b3c3a920"
    , "2dc7bfec2a828155fb0257078f35aacf3c6157463d82ef2d9dec44582ef270ea"
    , "2ff0c4909c50a2462356da8cd24930265352cabe0290f54e101141321db81130"
    , "340ca73543d1c46223f2ac78ce9e7c7a1aa71278c04d26a89c8072f4c7673cb1"
    , "34dcb56221cd14fcee879bd72e599220bac92a93b0c74e8c7b468369b74d0903"
    , "39a11922332664dcfd1c68f8e35416561d9140fa2d4a079ca35df59c1fc7c853"
    , "415178b5e950e524fd9ab878f2cb26c5d1c4c2376361d40d2ec1e68f4b203591"
    , "547197a9cb1211277e40e7809de21ec14d98f8b96023fb1a79b18e6ea8ae56bc"
    , "5bc062a0d573a4184c8cdfae44820e14f6634e0f52488db78b7f6063750ce7da"
    , "5d68983bc202e454f1285e249a8777a90a1cd92a029c58c1a164830f9c8e63e7"
    , "5fd9c94c88c6b97ae2d55f0ea7f35a19184b1b5d507f3787dfc65153a0c79e56"
    , "60245fd609b620520c5091e42bd6866b5af2084d8875cc3da725dc876e4ff95c"
    , "60f37e00c8a5cce5f2149241226482190e3229479aacac22754664619cbd1000"
    , "63d43b64d63389b59843a7544bd042fd8a13eb7f6d0512e20311d2314f147594"
    , "640c52765abed82aaf0b203d24825cab75e1af7c16970672e89de99d77238743"
    , "644a4d3bf72748f079f2de3f6e4c41367f582dee9a1b50c921cdb8e5d33a61dd"
    , "669fc9e1a52bebeb2570f7d65b31480ceff3eaaeb893e27ec0a18e65b7720580"
    , "6ae21b5473b9cd44be9ec9339113a5a44a07d8c011a420c6075178c674cf1dd5"
    , "6f2ca522a504c11fcab3a2fc71f36270333e40533d5e1a3757c6d9af787890c5"
    , "7b543a39fd21e00da754f847889130ccb11ed9282f0912c44ed001ba034dbe6c"
    , "81abce798593a59217755ab886e3396efa9cbe670068f7f6ec105dad56eed8eb"
    , "834586727c17659648dfb912590c9b47211ebeb2ea9f0e565fc83f5b19b0106f"
    , "861175e3d34bac6e208d38f161321d89bf9147126ec827072b6f653c8fbe3aa6"
    , "88a901be96e20719fcc29af2b2c09c553a8a376c99bfd8bedc7ded2420346747"
    , "90f042433b9e9b696531a6b60b6759a5487f9208275828622d73e025cd2b782d"
    , "9568b36d10e3411bbe43ea559dfe756871c414699ed7e0f55cc9ef27a4da72fe"
    , "9677b651a7eef444b154220181acadc27819c5b009e1ff4f1a94b9433c2322c4"
    , "9d5f360ca12282eb812c21fa9eba0f174b798808722fd043671d430724550ea6"
    , "a0bb3fe9e48878e9e191f4ddaf66a51a8757fa739659c8f6b371371760787cd8"
    , "ae3e6198647b705489fac695abbaae64165e5ef2b61cebd34dd5ae439b0abeae"
    , "ae897c50bbecaef6ff6be6ec86aefdfdd17ae766e1063c4daf026ead9ef93dcb"
    , "b0210db3e5a9d6eb823b5cfabe602598f0f76752b39b96f4e16ce6e5ea64a3e3"
    , "b0d89e7fc4502880adfb656aba42e670e28cd5942537029e24a458bfd1656e09"
    , "b33eef743b2833d54b9593eafc33b91530cf9f7cf801e19547f3ee623330ec3c"
    , "bdb9bb7681b7ffec40ad0fa5fb98c11fe9680cb1c78bc24f61d6fa41353deda9"
    , "c1b39c3ebfdc54e03bfc87f2edffd58657fd0f311b5dcdc19f7ae679efcfe79e"
    , "c2c23e2b20dcf09375633bc71c4bf7af961a20f0d92558a691fbbdf0f9eeab09"
    , "c4b78b323efef2fbec3d4aa92e6a994cc93f37cb680c799819352018177f80ab"
    , "c79c406b4329467c3e0ecffa05593df2b7bf80481a9bf349573716dbcb244523"
    , "ca223c070c2b2e60324f648cb93472d5c58ef9b2af9ba6aa74433823927225a7"
    , "cc07bf470f7652ec2550a0ca0d0c63c93e65e789b3adb6d6484b7e1f1a750b80"
    , "d41de96d677311a4e374dd5aa5e0bb9cf4b9de52db467e2155c32ab321245b28"
    , "d4e2d84ad2b5e63408fa7482eabd0d52ee6035287ba74987230d5df6bd61e429"
    , "d5120367e45990727e86d5e11b2b04de593182d19aefb70f6ef5eaae3b1f7a8b"
    , "d823ee929dc3a9472111ee9d58fc84ddc196c4ac1d4a6174caa4321726d6b6f1"
    , "d9be83847775322789d24b2dd0dc9aa7e2af35758324b48761da6ef7bd3016b2"
    , "da5efd4623da63d34f5d217529c5fc93dccaed50241d93d7b3d63bf17e3c6b40"
    , "de194fc3bd4a53e076d5595042eccade6306ee4dfcfb6cb3afd37dbab13a1159"
    , "dee4a7a21049f88bf3c22f4c907278d576022b232ec4e9737246c82d26ba47b2"
    , "e06e347c7eed6f0b96b0dd528b448701b7983085fa31952e376a84aaa3862f50"
    , "e0ba805a9fad9a66f1bbce367b4c2873222d7de04551d96f6fb90580bb81aca3"
    , "e62c3d2b8d114599fbbc99ab3c2134357c1dfcd8d6bcaf82fc33445a6114c1d7"
    , "ecc350d8fc259a017609420fc19e53e7728b56349d95aec173fedfbec98bef67"
    , "f31e62ac07a81f85780af771a4dc7a7a1cc28bc7eef9d384313fea3848ce7edb"
    , "f79558e4fb08a88f180b1b2616f37f01e29e8b5052e557b54fdad971151b2e06"
    , "f980e125330b63d5a94de630308ac79f115edfe5251368761e52b75ed2fabdb4"
    , "fc80b170c37a6acab47c8867a2817a32c947b91959d83813145251b9fa98a6fc"
  ]

def validatedEnvironmentImport : ValidatedEnvironmentImport where
  environments := importedEnvironments
  count94 := by rfl
  allValid := by rfl
  semanticHashesUnique := by rfl
  contentHashesUnique := by rfl

def validatedInputDomainImport : ValidatedInputDomainImport where
  environments := importedEnvironments
  amineIdentityHashes := importedAmineIdentityHashes
  acidIdentityHashes := importedAcidIdentityHashes
  environmentCount94 := by rfl
  amineCount70 := by rfl
  acidCount66 := by rfl
  allEnvironmentsValid := by rfl
  environmentSemanticHashesUnique := by rfl
  environmentContentHashesUnique := by rfl
  amineHashesUnique := by rfl
  acidHashesUnique := by rfl
  allAmineHashesImported := by rfl
  allAcidHashesImported := by rfl

def resolveImportedInput?
    (amineIdentitySha256 acidIdentitySha256 semanticConditionSha256 : String) :
    Option InputOrganization :=
  resolveQualifiedInput?
    importedEnvironments
    importedAmineIdentityHashes
    importedAcidIdentityHashes
    amineIdentitySha256 acidIdentitySha256 semanticConditionSha256

def knownInputOrganization? : Option InputOrganization :=
  resolveImportedInput?
    "79fba427e8aece74a554958114fbde79d75912848130184e6f8cc0a4ef67b2fa"
    "dee4a7a21049f88bf3c22f4c907278d576022b232ec4e9737246c82d26ba47b2"
    "a3a2648884c704b830721f177ba6b4536449f30a4f39f64388edf50f5857089e"

def knownInputProjection? : Option InputProjection :=
  knownInputOrganization?.map projectInput

theorem knownInputOrganization_resolves :
    knownInputOrganization?.isSome = true := by
  rfl

theorem knownInputProjection_resolves :
    knownInputProjection?.isSome = true := by
  rfl

end EnvironmentImport
end CP0
end Carbone
end Meta

/- AXIOM_AUDIT_BEGIN -/
#print axioms Meta.Carbone.CP0.EnvironmentImport.importedEnvironments
#print axioms Meta.Carbone.CP0.EnvironmentImport.validatedEnvironmentImport
#print axioms Meta.Carbone.CP0.EnvironmentImport.validatedInputDomainImport
#print axioms Meta.Carbone.CP0.EnvironmentImport.resolveImportedInput?
#print axioms Meta.Carbone.CP0.EnvironmentImport.knownInputOrganization_resolves
#print axioms Meta.Carbone.CP0.EnvironmentImport.knownInputProjection_resolves
/- AXIOM_AUDIT_END -/
