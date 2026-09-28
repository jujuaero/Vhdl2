# VHDL2 - Conception de systèmes numériques

[![Test du jeu](Capture%20d%27%C3%A9cran%202026-09-28%20180247.png)](test%20du%20jeu.mp4)

Ce dépôt regroupe plusieurs projets VHDL réalisés dans le cadre du module de conception de systèmes numériques. Il contient notamment :

- une Unité Arithmétique et Logique (UAL) avec contrôleur mémoire et opérations personnalisées,
- un jeu électronique basé sur une logique de réaction / validation d'appuis,
- des blocs de génération de nombres pseudo-aléatoires (LFSR),
- plusieurs projets Vivado / simulation VHDL pour validation fonctionnelle.

## Objectif du projet

Le but de ce projet est de concevoir et simuler des blocs numériques modulaires en VHDL, puis de les intégrer dans des systèmes plus complets. Les composants sont pensés pour être testés de manière indépendante avant intégration dans un système global.

## Structure du dépôt

```text
Vhdl2/
├── README.md                      # Documentation générale du projet
├── Arty_Digilent_TopLevel_Constraints.xdc
├── extract_pdf_text.py           # Script d'extraction de texte PDF
├── instruction_memory.vhd        # Mémoire d'instructions principale
├── lfsr.vhd                      # LFSR
├── lfsr_mcu.vhd                  # LFSR + microcontrôleur
├── mem_instructions.vhd          # Fichier d'instructions mémoire
├── ual_controller.vhd            # Contrôleur UAL
├── ual/                          # Système UAL complet
├── jeu/                          # Projet principal du jeu
├── implémentation_jeu/           # Version de développement / implémentation du jeu
├── projetv1/                    # Projet Vivado supplémentaire
├── vhdl2_ual/                   # Projet UAL Vivado
└── TE608 - 25_26 - Conception de systèmes numériques 2 - v1.1.pdf
```

## Composants principaux

### 1. UAL

Le dossier `ual/` contient une architecture complète d'unité arithmétique et logique avec :

- registres synchrones,
- buffer avec routage,
- mémoire d'instructions,
- contrôleur de mémoire,
- opérations logiques et arithmétiques,
- opérations personnalisées,
- testbenches de validation.

Les documents de référence dans ce dossier incluent :

- `ual/ARCHITECTURE.md`
- `ual/CUSTOM_OPERATIONS.md`
- `ual/README_IMPLEMENTATION.md`

### 2. Jeu

Le dossier `jeu/` contient le développement d'un mini-jeu numérique avec :

- générateur LFSR pour la couleur affichée,
- validation des appuis boutons,
- compteur de score,
- gestion du timeout,
- contrôleur de jeu,
- testbench de simulation.

Le fichier `jeu/TESTBENCH.md` décrit les scénarios de test et la commande de compilation/simulation.

### 3. VHDL / Vivado

Le projet contient plusieurs sous-projets Vivado dans :

- `jeu/`
- `implémentation_jeu/`
- `projetv1/`
- `vhdl2_ual/`

Ces dossiers sont utiles pour synthèse, implémentation FPGA et validation de fonctionnement sur cible de type Arty Digilent.

## Simulation

Le projet peut être simulé avec GHDL et les fichiers de testbench présents.

### Exemple de compilation

```bash
ghdl -a --std=08 ual/register.vhd ual/buffer_with_route.vhd ual/instruction_memory.vhd \
                 ual/memory_controller.vhd ual/ual.vhd ual/custom_operations.vhd \
                 ual/ual_system_top.vhd
```

### Exemple de lancement d'un testbench

```bash
ghdl -e --std=08 custom_operations_tb
ghdl -r --std=08 custom_operations_tb --vcd=custom_ops.vcd
```

### Exemple de simulation avec le jeu

```bash
cd jeu
ghdl -a -g --std=08 ../ual/register.vhd ../ual/buffer_with_route.vhd ../ual/instruction_memory.vhd \
                   ../ual/memory_controller.vhd ../ual/custom_operations.vhd ../ual/ual.vhd \
                   ../ual/ual_system_top.vhd lfsr.vhd timeout.vhd score_counter.vhd \
                   validation.vhd debounce.vhd game_controller.vhd game_controller_tb.vhd

ghdl -e game_controller_tb
ghdl -r game_controller_tb --wave=game_controller.ghw
```

## Outils utilisés

- GHDL pour la simulation
- Vivado pour la synthèse / implémentation FPGA
- GTKWave pour visualisation des signaux

## Remarques

Ce dépôt est avant tout un projet académique de conception numérique. Il met l'accent sur :

- la modélisation RTL en VHDL,
- la validation par testbench,
- l'intégration de blocs fonctionnels,
- la compréhension de l'architecture matériel d'un système numérique complet.

## Auteurs / contexte

Projet réalisé dans le cadre de l'enseignement :

- Conception de systèmes numériques 2
- École : EFREI
- Période : S6

---

Pour plus de détails sur les parties du projet, consultez les fichiers de documentation présents dans les sous-dossiers `ual/` et `jeu/`.
