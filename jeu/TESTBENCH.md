# Game Controller Testbench

## Fichiers de simulation

- `game_controller_tb.vhd` - Testbench pour game_controller
- `run_sim.tcl` - Script Tcl pour lancer la simulation (Vivado)

## Dépendances du testbench

Le testbench compile dans cet ordre:
1. `../ual/register.vhd` - Registre synchrone générique
2. `../ual/buffer_with_route.vhd` - Buffer avec routage
3. `../ual/instruction_memory.vhd` - ROM d'instructions
4. `../ual/memory_controller.vhd` - Contrôleur mémoire
5. `../ual/custom_operations.vhd` - Opérations personnalisées
6. `../ual/ual.vhd` - UAL (opérations logiques/arithmétiques)
7. `../ual/ual_system_top.vhd` - Intégration UAL
8. `lfsr_mcu.vhd` - LFSR via UAL
9. `timeout.vhd` - Gestion du timeout
10. `score_counter.vhd` - Compteur de score
11. `validation.vhd` - Validation des appuis boutons
12. `debounce.vhd` - Anti-rebond des boutons
13. `game_controller.vhd` - Contrôleur principal du jeu
14. `game_controller_tb.vhd` - Testbench

## Scénario de test

Le testbench simule:
1. Reset du système
2. Affichage d'une première couleur (LFSR)
3. Appui sur le bouton RED
4. Appui sur le bouton GREEN
5. Appui sur le bouton BLUE
6. Plusieurs rounds supplémentaires

## Génération de signaux pour gtkwave

### Avec GHDL:
```bash
# Compilation
ghdl -a ../ual/register.vhd ../ual/buffer_with_route.vhd ../ual/instruction_memory.vhd ../ual/memory_controller.vhd ../ual/custom_operations.vhd ../ual/ual.vhd ../ual/ual_system_top.vhd lfsr_mcu.vhd timeout.vhd score_counter.vhd validation.vhd debounce.vhd game_controller.vhd game_controller_tb.vhd

# Elaboration
ghdl -e game_controller_tb

# Simulation avec VCD
ghdl -r game_controller_tb --vcd=game_controller.vcd

# Affichage avec gtkwave
gtkwave game_controller.vcd
```

### Avec Vivado:
1. Créer un nouveau projet
2. Ajouter les fichiers VHDL
3. Créer le testbench (ou importer game_controller_tb.vhd)
4. Lancer la simulation
5. Exporter en VCD via le menu Simulation

## Signaux observables

- `clk` - Clock 100MHz
- `res` - Reset
- `sw_level` - Sélection difficulté (timeout)
- `btn_r`, `btn_g`, `btn_b` - Appuis boutons
- `led_color` - Couleur affichée (RGB)
- `score` - Score actuel (4 bits, 0-15)
- `game_over` - Indicateur fin de partie

## Observations attendues

1. Au reset: `led_color = "000"`, `score = 0000`
2. Après 1-2 cycles: `led_color` affiche une couleur aléatoire (LFSR)
3. Chaque appui correct: `score` s'incrémente, nouvelle couleur
4. Appui incorrect: `game_over = '1'`, jeu terminé
5. Timeout sans appui: `game_over = '1'`
6. Après 15 appuis corrects: `game_over = '1'` (victoire)