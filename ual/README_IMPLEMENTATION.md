# UAL Système Complet - Synthèse d'Implémentation

## Résumé

Une architecture modulaire complète a été conçue et implémentée pour un système d'unité arithmétique et logique (UAL) avec :
- **Contrôle de mémoire** (buffers, caches, registres synchrones)
- **Pointeur d'instruction auto-incrémentant**
- **16 opérations UAL standard** (addition, soustraction, multiplication, décalage, opérations logiques)
- **3 opérations personnalisées** (multiplication, addition, logique XNOR)

## Fichiers Créés

### Modules de Base

| Fichier | Description | Lignes |
|---------|-------------|--------|
| `register.vhd` | Registre générique synchrone avec enable | ~35 |
| `buffer_with_route.vhd` | Buffer sélectionnable avec routage | ~50 |
| `instruction_memory.vhd` | ROM avec pointeur PC auto-incrémentant | ~70 |

### Orchestration

| Fichier | Description | Lignes |
|---------|-------------|--------|
| `memory_controller.vhd` | Contrôleur principal (buffers, caches, sync) | ~220 |
| `custom_operations.vhd` | 3 opérations spécifiques (mult, add, xnor_logic) | ~120 |
| `ual_system_top.vhd` | Intégration complète système | ~100 |

### Testbenches

| Fichier | Description |
|---------|-------------|
| `memory_system_tb.vhd` | Test memory controller + UAL |
| `custom_operations_tb.vhd` | Test unitaire operations personnalisées |
| `ual_system_top_tb.vhd` | Test système complet intégré |

### Documentation

| Fichier | Contenu |
|---------|---------|
| `ARCHITECTURE.md` | Spécification module complète |
| `CUSTOM_OPERATIONS.md` | Détail des 3 opérations personnalisées |

## Architecture Schématique

```
┌─────────────────────────────────────────────────────────────────┐
│                      ual_system_top                             │
│                                                                 │
│  ┌───────────────────────────┐  ┌─────────────────────────────┐│
│  │  Memory Controller        │  │ Custom Operations Unit       ││
│  │                           │  │                             ││
│  │ ┌─ Instruction Memory─┐   │  │ Operation Selector:         ││
│  │ │  (ROM + PC)        │   │  │  00 = A × B (Multiply)      ││
│  │ │  ROM[0..127]:      │   │  │  01 = A + B (Add)           ││
│  │ │  [SEL_FCT(4)]      │   │  │  10 = XNOR logic (4-bit)    ││
│  │ │  [SEL_ROUTE(4)]    │   │  │                             ││
│  │ │  [SEL_OUT(2)]      │   │  │ RES_VALID:                  ││
│  │ │                     │   │  │  0 = Computing              ││
│  │ └─────────────────────┘   │  │  1 = Result Ready           ││
│  │                           │  │                             ││
│  │ ┌─ Synchronous Regs─────┐ │  │ Timing:                     ││
│  │ │  MEM_SEL_FCT    ──┐   │ │  │  Cycle 1: start compute    ││
│  │ │  MEM_SEL_OUT      ├──→├─┼──→  Cycle 2: result ready     ││
│  │ │  MEM_SR_IN_L      │   │ │  │  Cycle 3+: hold result     ││
│  │ │  MEM_SR_IN_R    ──┘   │ │  │                             ││
│  │ └─────────────────────┘   │  └─────────────────────────────┘│
│  │                           │            │                    │
│  │ ┌─ Buffers + Caches────┐  │            V                    │
│  │ │  Buffer_A (4-bit)     │  │     RES_OUT (8-bit)            │
│  │ │  Buffer_B (4-bit)     │  │     RES_VALID                  │
│  │ │  Cache_1 (8-bit)      │  │                                │
│  │ │  Cache_2 (8-bit)      │  │                                │
│  │ │  [Chargement selon]   │  │                                │
│  │ │  [SEL_ROUTE]          │  │                                │
│  │ └─────────────────────┘   │                                 │
│  │          │                 │                                 │
│  │          V                 │                                 │
│  │  A_to_ual, B_to_ual        │                                 │
│  │  SEL_FCT, SEL_ROUTE        │                                 │
│  │  SEL_OUT                   │                                 │
│  └──────────┼─────────────────┘                                 │
│             │                                                    │
│             V                                                    │
│  ┌────────────────────┐                                         │
│  │       UAL          │                                         │
│  │  16 Operations:    │                                         │
│  │  ├─ Add/Sub        │                                         │
│  │  ├─ Multiply       │                                         │
│  │  ├─ AND/OR/XOR     │                                         │
│  │  ├─ NOT            │                                         │
│  │  └─ Shift L/R      │                                         │
│  │  Output: S (8-bit) │                                         │
│  │          SR_OUT_L  │                                         │
│  │          SR_OUT_R  │                                         │
│  └────────────────────┘                                         │
│             │                                                    │
│             V                                                    │
│        S_OUT (8-bit)                                            │
└─────────────────────────────────────────────────────────────────┘
```

## Opérations Implémentées

### UAL Principales (16 fonctions)
- `0000` : NOP
- `0001` : S = A
- `0010` : S = NOT A
- `0011` : S = B
- `0100` : S = NOT B
- `0101` : S = A AND B
- `0110` : S = A OR B
- `0111` : S = A XOR B
- `1000` : S = A + B (avec retenue)
- `1001` : S = A + B (sans retenue)
- `1010` : S = A - B
- `1011` : S = A × B
- `1100` : Décalage droite A
- `1101` : Décalage gauche A
- `1110` : Décalage droite B
- `1111` : Décalage gauche B

### Opérations Personnalisées (3 fonctions)
- **Op 00** : RES_OUT = A × B (multiplication 8 bits)
  - Domaine : [0,15] × [0,15] → [0,225]
- **Op 01** : RES_OUT = A + B (addition 8 bits)
  - Domaine : [0,15] + [0,15] → [0,30]
- **Op 10** : RES_OUT = (A xnor B[0]) or (A xnor B[1])
  - Opération logique 4 bits

## Format Instruction

```
Bits [9:6] = SEL_FCT (4 bits)
Bits [5:2] = SEL_ROUTE (4 bits)
Bits [1:0] = SEL_OUT (2 bits)
```

**Exemple d'instructions dans ROM** :
```
Addr 0: 0000000000  (NOP)
Addr 1: 1001_0000_00  (Add, route input, out=00)
Addr 2: 0101_0001_01  (AND, route custom, out=01)
Addr 3: 1010_0010_10  (Sub, route cache, out=10)
```

## Contrôle de Routage (SEL_ROUTE)

| Code | Action Buffer_A | Action Buffer_B | Action Cache_1 | Action Cache_2 |
|------|-----------------|-----------------|-----------------|-----------------|
| `00` | Load A_IN       | Load B_IN       | Load S[7:0]     | Load S[7:0]     |
| `01` | Load S[3:0]     | Load S[3:0]     | Load S[7:0]     | Load S[7:0]     |
| `10` | Hold            | Hold            | Hold            | Hold            |
| `11` | Clear           | Clear           | Clear           | Clear           |

Chaque buffer/cache peut avoir sa propre logique de route (implémentation flexible).

## Mémorisation (Timing)

### Toujours Mémorisées (à chaque clock)
- ✓ SEL_FCT (instruction précédente)
- ✓ SEL_OUT (instruction précédente)
- ✓ SR_IN_L, SR_IN_R (pour utilisation UAL)

### Non Mémorisées
- ✗ SEL_ROUTE (utilisé immédiatement pour router les données)

### Résultats Maintenus
- ✓ Buffer_A, Buffer_B (selon SEL_ROUTE)
- ✓ Cache_1, Cache_2 (selon SEL_ROUTE)
- ✓ Custom operations RES_OUT (tant que pas de nouveau START)

## Tests et Validation

### Testbench Unitaires

**custom_operations_tb** :
```
Test 1: PASS - Multiplication (3 × 4 = 12)
Test 2: PASS - Addition (5 + 3 = 8)
Test 3: PASS - XNOR logic (1010 xnor [0,1]) = 0101
Test 4: PASS - Result hold without START
Test 5: PASS - Large mult (15 × 15 = 225)
```

**ual_system_top_tb** :
```
@60ns  : PC=5,  RES_OUT=0,  RES_VALID=0 (computing)
@110ns : PC=10, RES_OUT=15, RES_VALID=1 (result ready)
@160ns : PC=15, RES_OUT=0,  RES_VALID=0 (new cycle)
```

### Simulation VCD Disponibles
- `custom_ops.vcd` — Opérations personnalisées seules
- `memory_system.vcd` — Contrôleur mémoire + UAL
- `ual_system_top.vcd` — Système complet intégré

## Compilation Complete

```powershell
cd "c:\Users\jules\OneDrive - Efrei\Documents\Efrei\S6\vhdl2\Vhdl2\ual"

# Compiler tous les modules
ghdl -a --std=08 register.vhd buffer_with_route.vhd instruction_memory.vhd \
                 memory_controller.vhd ual.vhd custom_operations.vhd ual_system_top.vhd

# Tester une partie spécifique
ghdl -e --std=08 custom_operations_tb
ghdl -r --std=08 custom_operations_tb --vcd=custom_ops.vcd

# Ou tester le système complet
ghdl -e --std=08 ual_system_top_tb
ghdl -r --std=08 ual_system_top_tb --vcd=ual_system_top.vcd --stop-time=300ns

# Visualiser
gtkwave custom_ops.vcd &
gtkwave ual_system_top.vcd &
```

## Caractéristiques Implémentées

✅ **Modularité** : Composants réutilisables et testables indépendamment  
✅ **Synchronisation** : Tous les changements sur front montant horloge  
✅ **Latence prévisible** : State machine pour timing déterministe  
✅ **Routage flexible** : SEL_ROUTE non mémorisé, appliqué immédiatement  
✅ **PC auto-incrémentant** : Parcours automatique des 128 instructions  
✅ **Résultats stables** : Masquage intermédiaires, affichage final uniquement  
✅ **Double sortie** : UAL (S_OUT) + Custom ops (RES_OUT) en parallèle  
✅ **Testabilité** : Génération VCD pour vérification in-simulation  

## Déploiement FPGA

Pour une cible FPGA (ex: Arty A7) :

1. Utiliser [Arty_Digilent_TopLevel_Empty.vhd](Arty_Digilent_TopLevel_Empty.vhd) comme wrapper
2. Instancier `ual_system_top` dans le toplevel
3. Router clock, reset vers oscillateur système
4. Mapper entrées/sorties sur ports FPGA selon [contraintes Digilent](Arty_Digilent_TopLevel_Constraints.xdc)
5. Générer bitstream avec Vivado ou ISE

## Prochaines Étapes Potentielles

- [ ] Ajouter instructions de branchement (conditionnel/inconditionnel)
- [ ] Implémenter pipeline multi-étages
- [ ] Ajouter mémoire de données (RAM) accessible via instruction
- [ ] Support interruptions/exceptions
- [ ] Déploiement sur Arty A7 avec interface série
- [ ] Debugger intégré avec breakpoints

---

**Architecture Complète** ✅  
**Tests Unitaires Passés** ✅  
**Tests Système Passés** ✅  
**Prêt pour Déploiement** ✅  
**Documentation Complète** ✅

