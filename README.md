# The Awakening of Titus: Dawn Light

Game Design base do projeto `projetTitus`.

## Visão Geral
- Título: **The Awakening of Titus: Dawn Light**
- Gênero: **Aventura / RPG / Plataforma / Metroidvania**
- Estilo visual: **HD-2D** (pixel art com profundidade e efeitos modernos)
- Perspectiva: **Side Scroller 2D com profundidade visual**
- Engine: **Godot Engine 4**
- Plataformas-alvo: **Nintendo Switch, iOS, Android**
- Estúdio: **PH Studio**
- Idioma: **Diálogos em textbox (sem voz)**

## História
O mundo foi distorcido pela emergência de monstros do submundo, movidos por ódio e inveja. A natureza foi corrompida, o céu escureceu e a lua tornou-se sangue.

Titus desperta em meio ao caos e, guiado por Alba, inicia sua jornada para restaurar o equilíbrio. Ao longo de biomas corrompidos e confrontos com entidades ancestrais, seu destino o leva ao combate final contra **Aodh**, deus do fogo celta.

## Pilar de Gameplay: Luz como Mecânica Central
A luz é uma regra do mundo, não apenas um efeito visual.

### Loop central
1. Titus entra em área corrompida (baixa luz).
2. Inimigos e obstáculos tornam-se hostis.
3. Titus canaliza ou recupera luz.
4. O ambiente reage (plataformas, padrões inimigos, clima).
5. Alba reforça narrativa e feedback emocional.

### Estados de luz por área
- **Escuridão**
- **Instável**
- **Iluminada**

Esses estados controlam comportamento de inimigos, plataformas, ambientação e áudio.

## Mecânicas Principais
- Parallax scrolling em múltiplas camadas
- Movimento: pulo, abaixar, correr, dash, pulo duplo, wall cling
- Combate: corpo a corpo + distância
- Progressão Metroidvania com habilidades desbloqueáveis
- Sistema de armaduras e gemas com efeitos de gameplay
- Upgrade de armas (rotas elementais)
- Drops de inimigos: moedas, mana, itens raros
- Exploração com mapa interconectado e backtracking

## Mundo e Biomas
Cada bioma tem identidade própria e regra de luz específica:

- **Floresta Mística**: cura e sabedoria
- **Deserto Desolado**: resistência e fome
- **Tundra Congelada**: isolamento e mistério
- **Terras Cinzentas Vulcânicas**: destruição e ira
- **Profundezas Oceânicas (secreto)**: verdade oculta
- **Ruínas Antigas**: memória e conhecimento
- **Superfície Transformada (endgame)**: desequilíbrio e colapso

## Personagens-Chave
- **Titus**: protagonista versátil em combate
- **Alba**: guia espiritual e catalisadora da luz
- **Aodh**: boss final, deus do fogo celta

NPCs notáveis:
- Sábio Ancião
- Curandeiro Místico
- Explorador Curioso
- Guerreiro Corajoso
- Sobrevivente Resiliente
- Figura Misteriosa

## Sistemas
- Armaduras/Gemas: slots e bônus situacionais
- Upgrade de armas: evolução funcional e visual
- Inventário: equipamentos, recursos, chaves, relíquias
- Missões: principais e secundárias com recompensas de progressão

## UI, Áudio e Arte
- HUD minimalista: vida, mana, minimapa, inventário
- Textbox com retrato de personagem
- Trilha inspirada nos anos 80 com atmosfera sombria
- Efeitos sonoros retrô e ambiência por bioma
- HD-2D com shaders modernos (introdução gradual)

## Tecnologia e Deploy
- Engine: Godot 4
- Pipeline: 2D + shaders para profundidade
- Alvos: Switch, iOS e Android
- Foco técnico: performance e fluidez

## Roadmap Inicial (curto prazo)
1. Estruturar projeto Godot 4 com cena base de teste.
2. Implementar sistema de estado de luz (Escuridão/Instável/Iluminada).
3. Criar vertical slice: Floresta + Alba + mini-chefe.
4. Validar HUD de luz e ciclo de exploração/combate.

## Estratégia de Branches (Gitflow)
- `main`: produção/estável.
- `develop`: integração contínua de desenvolvimento.
- `codex/feat/initial-setup`: implementação inicial do projeto.

Fluxo inicial:
1. Criar `develop` a partir de `main`.
2. Criar branch de feature a partir de `develop`.
3. Implementar base inicial funcional na feature.
4. Merge da feature em `develop`.
