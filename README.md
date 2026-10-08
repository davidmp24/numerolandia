# 🌟 Numerolândia: Aventura em Blocos (Numerolândia Kids)

Jogo educativo infantil focado no aprendizado lúdico de matemática e aritmética inspirado no universo dos blocos numéricos (*Numberblocks*), desenvolvido na **Godot Engine 4** com **GDScript**.

---

## 📱 Informações do Pacote
- **Engine**: Godot Engine 4 (Compatível com 4.0, 4.1, 4.2 e 4.3+)
- **Package Name (Android)**: `com.devmp.numerolandia`
- **Público**: Infantil (Sem anúncios, 100% offline, seguro para crianças)

---

## 🗣️ Sistema de Narrador e Vozes Individuais

Cada personagem conta com o seu próprio banco de voz, afinação tonal e personalidade:

1. **Numberling Interativo (Toque no Número)**:
   - Acima da cabeça de cada personagem, o número (Numberling) **pulsa suavemente** no início da fase, indicando que é tocável.
   - Ao tocar no número, ele dá um **pulo elástico animado** (Tween scale $1.5\times \to 1.0\times$) e fala com sua voz característica: *"Sou o [Número]!"*.
2. **Narração de Operações Matemáticas**:
   - Sempre que dois blocos se fundem ou se dividem, o narrador anuncia em alto e bom som a conta pedagógica:
     - *"Um mais um é igual a Dois!"*
     - *"Dois mais um é igual a Três! Hummm, maçã!"*
     - *"Três mais um é igual a Quatro!"*
     - *"Três mais dois é igual a Cinco! Toca aqui!"*
     - *"Quatro mais três é igual a Sete! As cores do arco-íris!"*
     - *"Oito menos dois é igual a Seis!"*
     - *"Atchim! Nove menos um é igual a Oito!"*
     - *"Quatro mais quatro mais dois é igual a Dez! Preparar para decolar!"*
3. **Design Gentil sem Punição**:
   - Caso a criança junte mais blocos do que um obstáculo permite, o personagem balança a cabeça suavemente e diz: *"Opa, fiquei muito grande!"*, incentivando o uso da mecânica de corte (subtração) sem frustrações.
4. **Suporte Híbrido de Áudio**:
   - Suporte a arquivos de voz `.ogg`/`.wav` em `res://Assets/Audio/` (ex: `voz_1.ogg`, `sou_o_1.ogg`), complementado por síntese procedural melódica em tempo real, garantindo que o jogo funcione completo mesmo sem arquivos externos gravados.

---

## 🗺️ Progressão Didática das Fases

### **Mundo 1: O Despertar das Formas (Adição Básica)**

* **Fase 1: O Encontro (1 + 1 = 2)**
  - *Cenário:* Jardim com abismo e ponte levadiça. Placa de pressão exige peso 2 para abaixar a ponte.
  - *Mecânica:* A criança toca no 1, ele pula e fala *"Um!"*. Cai outro 1 do céu dizendo *"Junte a gente!"*. Ao juntá-los: *"Um mais um é igual a Dois!"*. O 2 abaixa a ponte!

* **Fase 2: A Escada para a Maçã (2 + 1 = 3)**
  - *Cenário:* Macieira com maçã suculenta no galho alto. O 2 é baixo demais.
  - *Mecânica:* A criança une 2 + 1 = 3 (*"Dois mais um é igual a Três! Hummm, maçã!"*). O 3 ou 4 alcança o galho e colhe a maçã!

* **Fase 3: O Elevador Exigente (3 + 2 = 5)**
  - *Cenário:* Torre com elevador que tem o formato da luva estrelada do 5.
  - *Mecânica:* Começa com o 3 (*"O elevador só leva o Cinco. Quantos faltam?"*). Ao juntar 3 + 2 = 5 (*"Três mais dois é igual a Cinco! Toca aqui!"*), o 5 embarca e o elevador sobe ao céu!

---

### **Mundo 2: Os Desafios do Superócto (Adição Avançada & Subtração)**

* **Fase 4: O Pedágio do Arco-Íris (4 + 3 = 7)**
  - *Cenário:* Nuvem cinza triste bloqueia a passagem com placa *"Traga as 7 cores"*.
  - *Mecânica:* A criança junta o 4 (verde) e o 3 (amarelo), formando o Sete Arco-Íris. O 7 espalha suas cores, a nuvem sorri e flutua para longe!

* **Fase 5: A Caverna Estreita (8 - 2 = 6)**
  - *Cenário:* Entrada de túnel rochoso com placa *"Altura Máxima: 6"*.
  - *Mecânica:* O Superócto (8) não cabe e diz: *"Sou muito grande! Me divida!"*. Com dois toques ou gesto de corte, o 8 se divide em 6 e 2 (*"Oito menos dois é igual a Seis!"*). O 6 passa livremente!

* **Fase 6: O Resfriado do 9 (Subtração Contínua -1)**
  - *Cenário:* Trilha de inverno com 3 portões (tamanhos 8, 7 e 6) e casinha quente com chá no final.
  - *Mecânica:* O 9 está resfriado. Ao tocar nele, ele espirra (*"Atchim! Nove menos um é igual a Oito!"*) e solta um bloco 1, diminuindo sucessivamente para 8, 7 e 6 até se aconchegar na casinha!

---

### **Mundo 3: A Grande Viagem (Lógica & Sistema Decimal)**

* **Fase 7: O Lançamento do Foguete (4 + 4 + 2 = 10)**
  - *Cenário:* Plataforma de lançamento espacial. O Foguete 10 está desmontado em módulos: dois blocos 4 e um bloco 2.
  - *Mecânica:* Ao juntar todos os módulos, o Foguete 10 surge com olhos de estrela vermelha e asas (*"Quatro mais quatro mais dois é igual a Dez! Preparar para decolar!"*). A criança aperta o botão de lançamento, a contagem 3, 2, 1... dispara e o foguete voa pelo espaço!

---

### **Modo Livre (Playground)**
- Mesa de brinquedo sem limite de tempo.
- Barra inferior com botões coloridos de 1 a 10 para criar qualquer bloco à vontade.
- Empilhamento livre, somas grandes ($10 + 10 = 20$) e corte com toque duplo.

---

## 🏗️ Como Abrir no Godot 4 e Testar

1. Baixe e abra o **Godot Engine 4**.
2. Clique em **Import** e selecione o arquivo [`project.godot`](file:///c:/Users/40968587810/Documents/Projeto/JOGOS/Numerolandia/project.godot).
3. Pressione **F5** para jogar no computador.
4. Para gerar o APK Android: vá em **Project > Export...**, selecione o preset **Android** (`com.devmp.numerolandia`) e exporte!
