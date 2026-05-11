# Architecture Modulaire UAL - Système Mémoire

## Vue d'ensemble

L'architecture est conçue de manière modulaire avec des composants réutilisables qui orchestrent le système d'unité arithmétique et logique (UAL) avec sa mémoire et ses buffers.

## Modules

### 1. `register.vhd` - Registre générique synchrone
**Objectif** : Mémoriser des données sur front montant d'horloge  
**Ports** :
- `clk` : horloge
- `reset` : réinitialisation
- `enable` : activation de mémorisation
- `data_in` : données entrantes (largeur configurable)
- `data_out` : données mémorisées

**Instances** :
- `MEM_SEL_FCT` : mémorise SEL_FCT (4 bits) — toujours activé
- `MEM_SEL_OUT` : mémorise SEL_OUT (2 bits) — toujours activé
- `MEM_SR_IN_L` : mémorise SR_IN_L (1 bit) — toujours activé
- `MEM_SR_IN_R` : mémorise SR_IN_R (1 bit) — toujours activé

### 2. `buffer_with_route.vhd` - Buffer/Cache avec sélection de route
**Objectif** : Stocker et router les données selon SEL_ROUTE  
**Ports** :
- `clk` : horloge
- `reset` : réinitialisation
- `input_data` : données d'entrée (provenance externe)
- `ual_output` : résultat UAL (feedback)
- `sel_route` : sélection de la source
- `buffer_out` : sortie du buffer

**Comportement SEL_ROUTE** :
- `"00"` : charger depuis `input_data` (entrées A_IN, B_IN)
- `"01"` : charger depuis résultat UAL `S`
- `"10"` : maintenir la valeur
- `"11"` : effacer (remplir de 0)

**Instances** :
- `Buffer_A` : 4 bits (pour A_IN ou résultat UAL[3:0])
- `Buffer_B` : 4 bits (pour B_IN ou résultat UAL[3:0])
- `MEM_CACHE_1` : 8 bits (résultat UAL)
- `MEM_CACHE_2` : 8 bits (résultat UAL)

### 3. `instruction_memory.vhd` - Mémoire instructions avec pointeur auto-incrémentant
**Objectif** : Stocker le programme et gérer le compteur de programme (PC)  
**Ports** :
- `clk` : horloge
- `reset` : réinitialisation
- `instr_out` : instruction actuelle (10 bits)
- `pc_out` : adresse du programme courant (7 bits, 0-127)

**Format instruction (10 bits)** :
```
[SEL_FCT(4)] & [SEL_ROUTE(4)] & [SEL_OUT(2)]
 bits[9:6]     bits[5:2]       bits[1:0]
```

**Comportement** :
- PC s'incrémente automatiquement à chaque front montant d'horloge
- Boucle à 0 après 127
- Sortie instruction = ROM[PC]

### 4. `memory_controller.vhd` - Contrôleur mémoire (orchestration)
**Objectif** : Orchestrer tous les composants (registres, buffers, instruction memory)  
**Ports** :
- **Entrées externes** : A_IN, B_IN, SR_IN_L, SR_IN_R
- **Entrées UAL** : S_from_ual, SR_OUT_L, SR_OUT_R
- **Sorties vers UAL** : A_to_ual, B_to_ual, SEL_FCT, SEL_ROUTE, SEL_OUT
- **Sorties données** : CACHE_1_OUT, CACHE_2_OUT
- **Visibilité** : PC_OUT

**Architecture interne** :
```
[Entrées externes A_IN, B_IN]
           |
           V
    [Buffer_A] <--> [Buffer_B]
           |
           V
      [Registres SEL_FCT, SEL_OUT, SR_IN]
           |
           V
    [Instruction Memory avec PC]
           |
           V
      [Caches 1 & 2]
           |
           V
    [Sorties vers UAL]
           |
           V
      [Boucle: S_from_ual] -> Caches
```

**Flux de données** :
1. **Cycle N** : PC_N lit l'instruction N depuis ROM
2. Instruction décodée : SEL_FCT_N, SEL_ROUTE_N, SEL_OUT_N
3. Registres synchrones sauvegardent SEL_FCT_N, SEL_OUT_N, SR_IN_N
4. Buffers mettent à jour selon SEL_ROUTE_N
5. UAL calcule avec (Buffer_A, Buffer_B, MEM_SEL_FCT_prev)
6. Résultat S chargé dans Caches selon SEL_ROUTE_N
7. **Front montant suivant** : PC incrémente, prochain cycle démarre

### 5. `custom_operations.vhd` - Opérations personnalisées (NOUVEAU)
**Objectif** : Implémenter 3 opérations mathématiques/logiques spécifiques  
**Ports** :
- `clk` : horloge
- `reset` : réinitialisation
- `start` : lancer un nouveau calcul
- `operation[1:0]` : sélection (00=mult, 01=add, 10=xnor_logic)
- `A[3:0]`, `B[3:0]` : opérandes
- `RES_OUT[7:0]` : résultat (0 pendant calcul)
- `RES_VALID` : indicateur de validité (0=calcul, 1=prêt)

**Opérations implémentées** :
- **Op 00** : RES_OUT_1 = A × B (multiplication 8 bits)
- **Op 01** : RES_OUT_2 = A + B (addition 8 bits)
- **Op 10** : RES_OUT_3 = (A xnor B[0]) or (A xnor B[1]) (logique 4 bits)

**Timing** : 
- Cycle N : Signal start, opérandes stables
- Cycle N+1 : Calcul, RES_VALID=0, RES_OUT=0
- Cycle N+2+ : Résultat disponible, RES_VALID=1, RES_OUT=résultat

Voir [CUSTOM_OPERATIONS.md](CUSTOM_OPERATIONS.md) pour détails complets.

### 6. `ual_system_top.vhd` - Système top-level (NOUVEAU)
**Objectif** : Intégrer memory_controller + UAL + custom_operations
**Connexions** : 
- Memory controller alimente UAL et custom_operations
- UAL calcule les 16 opérations standard
- Custom ops exécute les 3 opérations spécifiques en parallèle
- Résultats disponibles simultanément

## Format d'instruction (10 bits)

### Exemple d'instructions stockées

```vhdl
-- Instr 0: NOP
0 => "0000000000"

-- Instr 1: A+B, charger Buffer_A, SEL_OUT=00
1 => "1001" & "0000" & "00"
     SEL_FCT=1001(ADD), SEL_ROUTE=0000(input), SEL_OUT=00

-- Instr 2: A AND B, charger CACHE_1, SEL_OUT=01
2 => "0101" & "0001" & "01"
     SEL_FCT=0101(AND), SEL_ROUTE=0001, SEL_OUT=01

-- Instr 3: A-B, charger CACHE_2, SEL_OUT=10
3 => "1010" & "0010" & "10"
     SEL_FCT=1010(SUB), SEL_ROUTE=0010, SEL_OUT=10
```

## Compilation et simulation

### Compiler les modules
```powershell
cd "c:\Users\jules\OneDrive - Efrei\Documents\Efrei\S6\vhdl2\Vhdl2\ual"

# Analyser tous les fichiers
ghdl -a --std=08 register.vhd buffer_with_route.vhd instruction_memory.vhd memory_controller.vhd ual.vhd memory_system_tb.vhd

# Élaborer le testbench complet
ghdl -e --std=08 memory_system_tb

# Simuler et générer VCD
ghdl -r --std=08 memory_system_tb --vcd=memory_system.vcd --stop-time=300ns
```

### Visualiser la simulation
```powershell
gtkwave memory_system.vcd
```

## Points clés de l'architecture

1. **Modularité** : Chaque composant a une responsabilité unique et peut être réutilisé
2. **Réutilisabilité** : Registres et buffers sont génériques (largeur configurable)
3. **Synchronisation** : Tous les changements se font sur front montant d'horloge
4. **Contrôle de routage** : SEL_ROUTE contrôle où les données vont sans mémorisation
5. **Instruction auto-incrémentante** : PC gère automatiquement le flux de programme
6. **Boucle fermée** : Le résultat UAL peut être racheté par les buffers/caches

## Améliorations futures

- Ajouter des signaux de validation (valid flags)
- Implémenter des instructions de branchement conditionnel
- Ajouter plus d'étages de pipeline
- Mémoriser SEL_ROUTE pour plus de flexibilité
- Multiplexer les sorties vers différentes destinations mémoire
