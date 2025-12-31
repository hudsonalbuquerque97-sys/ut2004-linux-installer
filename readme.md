# 🎮 UT2004 Installer for Linux | UT2004 Instalador para Linux 🐧 

<div align="center">

![UT2004](https://img.shields.io/badge/Unreal%20Tournament%202004-000000?style=for-the-badge&logo=unrealengine&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Linux Mint](https://img.shields.io/badge/Linux%20Mint-87CF3E?style=for-the-badge&logo=linuxmint&logoColor=white)
![Gaming](https://img.shields.io/badge/Gaming-FF0000?style=for-the-badge&logo=steam&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![PT-BR](https://img.shields.io/badge/PT--BR-009739?style=for-the-badge&logo=googletranslate&logoColor=white)
![EN](https://img.shields.io/badge/EN-012169?style=for-the-badge&logo=googletranslate&logoColor=white)

[🇧🇷 Português (BR)](#português-br)  |  [🇺🇸 English](#english)

</div>

---

**🚨 IMPORTANTE / IMPORTANT 🚨**

**[PT-BR]** Este script **NÃO baixa nem fornece arquivos do jogo**. Você deve possuir uma cópia legítima do Unreal Tournament 2004 para usar este instalador.

**[EN]** This script **DOES NOT download or provide game files**. You must own a legitimate copy of Unreal Tournament 2004 to use this installer.

---

## 📋 Índice / Table of Contents

- [PT-BR](#pt-br)
  - [O que este script faz?](#o-que-este-script-faz)
  - [Onde obter o jogo?](#onde-obter-o-jogo)
  - [Pré-requisitos](#pré-requisitos)
  - [Como usar](#como-usar)
  - [Estrutura de diretórios](#estrutura-de-diretórios)
  - [Desinstalação](#desinstalação)
  - [Solução de problemas](#solução-de-problemas)
- [EN](#en)
  - [What does this script do?](#what-does-this-script-do)
  - [Where to get the game?](#where-to-get-the-game)
  - [Prerequisites](#prerequisites)
  - [How to use](#how-to-use)
  - [Directory structure](#directory-structure)
  - [Uninstallation](#uninstallation)
  - [Troubleshooting](#troubleshooting)

---
# Português (BR)

### O que este script faz?

Este script automatiza a instalação do Unreal Tournament 2004 em sistemas Linux modernos. Ele:

1. **Extrai os arquivos do jogo** usando `innoextract` (especialmente útil para instaladores GOG)
2. **Aceita múltiplos formatos de entrada:**
   - Arquivos ISO (monta automaticamente)
   - Arquivos compactados (RAR, 7Z, ZIP)
   - Pastas com arquivos extraídos
   - Arquivo `setup.exe` direto
3. **Instala dependências necessárias** (bibliotecas 32-bit)
4. **Aplica o patch Linux oficial** (versão 3369-2)
5. **Corrige bibliotecas** (SDL, OpenAL)
6. **Cria atalhos no menu do sistema**
7. **Detecta automaticamente o idioma** (Português/Inglês)

### Onde obter o jogo?

Você pode obter o Unreal Tournament 2004 de fontes legais como:

- **GOG.com** (DRM-free) - Recomendado para usar com este script
- **Steam** (requer extração adicional)
- **CD/DVD original** (se você ainda possui)

**Nota:** O script funciona melhor com o instalador GOG (`setup_unreal_tournament_2004_*.exe`), pois usa `innoextract` para extrair os arquivos diretamente.

### Pré-requisitos

- **Sistema:** Ubuntu, Debian, ou derivados (com `apt`)
- **Arquitetura:** Suporte a 32-bit (multiarch)
- **Conexão com a internet** (para baixar dependências e patch)
- **Permissões sudo** (para instalar pacotes)
- **Espaço em disco:** ~5-7 GB

### Como usar

1. **Baixe o script:**
   ```bash
   wget https://raw.githubusercontent.com/hudsonalbuquerque97-sys/ut2004-linux-installer/refs/heads/main/ut2004_installer.sh
   chmod +x ut2004_installer.sh
   ```

2. **Execute o script:**
   ```bash
   ./ut2004_installer.sh
   ```

3. **Siga as instruções interativas:**
   - Digite sua CD Key (formato: XXXXX-XXXXX-XXXXX-XXXXX)
   - Indique o caminho para seus arquivos do jogo:
     ```
     Exemplos válidos:
     /home/user/Downloads/setup_ut2004_gog.exe
     /home/user/Downloads/ut2004.iso
     /home/user/Downloads/ut2004.rar
     ~/Games/UT2004_Files/
     ```

4. **Aguarde a instalação** (pode levar alguns minutos)

5. **Jogue!**
   - Procure "Unreal Tournament 2004" no menu de aplicativos
   - Ou execute: `~/Games/ut2004/ut2004`

### Estrutura de diretórios

Após a instalação, a estrutura ficará assim:

```
$HOME/
├── Games/
│   └── ut2004/                    # Diretório principal do jogo
│       ├── System/                # Executáveis e bibliotecas
│       │   ├── ut2004-bin         # Binário principal do jogo
│       │   ├── cdkey              # Sua CD Key
│       │   ├── libSDL-1.2.so.0    # Biblioteca SDL
│       │   └── openal.so          # Biblioteca OpenAL
│       ├── Maps/                  # Mapas do jogo
│       ├── Textures/              # Texturas
│       ├── Sounds/                # Sons
│       ├── Music/                 # Músicas
│       ├── StaticMeshes/          # Modelos 3D
│       ├── Animations/            # Animações
│       ├── Help/                  # Arquivos de ajuda
│       ├── ut2004                 # Script de inicialização
│       └── ut2004.png             # Ícone do jogo
│
├── .local/
│   └── share/
│       ├── applications/
│       │   └── ut2004.desktop     # Atalho do menu
│       └── icons/
│           └── hicolor/
│               ├── 48x48/apps/ut2004.png
│               ├── 64x64/apps/ut2004.png
│               └── 128x128/apps/ut2004.png
```

### Desinstalação

Para remover completamente o jogo:

```bash
# Remover arquivos do jogo
rm -rf ~/Games/ut2004

# Remover atalho do menu
rm -f ~/.local/share/applications/ut2004.desktop

# Remover ícones
rm -f ~/.local/share/icons/hicolor/*/apps/ut2004.png

# Atualizar cache do sistema
update-desktop-database ~/.local/share/applications 2>/dev/null
gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor 2>/dev/null
```

Ou use este comando único:

```bash
rm -rf ~/Games/ut2004 ~/.local/share/applications/ut2004.desktop ~/.local/share/icons/hicolor/*/apps/ut2004.png && update-desktop-database ~/.local/share/applications 2>/dev/null && gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor 2>/dev/null
```

### Solução de problemas

#### O jogo não inicia

Tente executar diretamente pelo terminal para ver erros:
```bash
cd ~/Games/ut2004/System
./ut2004-bin
```

#### Erro de bibliotecas faltando

Reinstale as dependências 32-bit:
```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install --reinstall libsdl1.2debian:i386 libopenal1:i386 libstdc++5:i386
```

#### Problemas com som

Verifique se o OpenAL está corretamente linkado:
```bash
ls -la ~/Games/ut2004/System/openal.so
```

Se não existir, copie manualmente:
```bash
cp /usr/lib/i386-linux-gnu/libopenal.so.1 ~/Games/ut2004/System/openal.so
```

#### Script não encontra setup.exe

Certifique-se de que:
- O arquivo existe no caminho especificado
- Você tem permissão de leitura
- O caminho não contém caracteres especiais problemáticos

---

# English

### What does this script do?

This script automates the installation of Unreal Tournament 2004 on modern Linux systems. It:

1. **Extracts game files** using `innoextract` (especially useful for GOG installers)
2. **Accepts multiple input formats:**
   - ISO files (automatically mounted)
   - Compressed files (RAR, 7Z, ZIP)
   - Folders with extracted files
   - Direct `setup.exe` file
3. **Installs required dependencies** (32-bit libraries)
4. **Applies official Linux patch** (version 3369-2)
5. **Fixes libraries** (SDL, OpenAL)
6. **Creates system menu shortcuts**
7. **Automatically detects language** (Portuguese/English)

### Where to get the game?

You can obtain Unreal Tournament 2004 from legal sources such as:

- **GOG.com** (DRM-free) - Recommended for use with this script
- **Steam** (requires additional extraction)
- **Original CD/DVD** (if you still have it)

**Note:** The script works best with GOG installer (`setup_unreal_tournament_2004_*.exe`), as it uses `innoextract` to extract files directly.

### Prerequisites

- **System:** Ubuntu, Debian, or derivatives (with `apt`)
- **Architecture:** 32-bit support (multiarch)
- **Internet connection** (to download dependencies and patch)
- **Sudo permissions** (to install packages)
- **Disk space:** ~5-7 GB

### How to use

1. **Download the script:**
   ```bash
   wget https://raw.githubusercontent.com/hudsonalbuquerque97-sys/ut2004-linux-installer/refs/heads/main/ut2004_installer.sh
   chmod +x ut2004_installer.sh
   ```

2. **Run the script:**
   ```bash
   ./ut2004_installer.sh
   ```

3. **Follow interactive instructions:**
   - Enter your CD Key (format: XXXXX-XXXXX-XXXXX-XXXXX)
   - Provide the path to your game files:
     ```
     Valid examples:
     /home/user/Downloads/setup_ut2004_gog.exe
     /home/user/Downloads/ut2004.iso
     /home/user/Downloads/ut2004.rar
     ~/Games/UT2004_Files/
     ```

4. **Wait for installation** (may take a few minutes)

5. **Play!**
   - Search for "Unreal Tournament 2004" in application menu
   - Or run: `~/Games/ut2004/ut2004`

### Directory structure

After installation, the structure will look like this:

```
$HOME/
├── Games/
│   └── ut2004/                    # Main game directory
│       ├── System/                # Executables and libraries
│       │   ├── ut2004-bin         # Main game binary
│       │   ├── cdkey              # Your CD Key
│       │   ├── libSDL-1.2.so.0    # SDL library
│       │   └── openal.so          # OpenAL library
│       ├── Maps/                  # Game maps
│       ├── Textures/              # Textures
│       ├── Sounds/                # Sounds
│       ├── Music/                 # Music
│       ├── StaticMeshes/          # 3D models
│       ├── Animations/            # Animations
│       ├── Help/                  # Help files
│       ├── ut2004                 # Launch script
│       └── ut2004.png             # Game icon
│
├── .local/
│   └── share/
│       ├── applications/
│       │   └── ut2004.desktop     # Menu shortcut
│       └── icons/
│           └── hicolor/
│               ├── 48x48/apps/ut2004.png
│               ├── 64x64/apps/ut2004.png
│               └── 128x128/apps/ut2004.png
```

### Uninstallation

To completely remove the game:

```bash
# Remove game files
rm -rf ~/Games/ut2004

# Remove menu shortcut
rm -f ~/.local/share/applications/ut2004.desktop

# Remove icons
rm -f ~/.local/share/icons/hicolor/*/apps/ut2004.png

# Update system cache
update-desktop-database ~/.local/share/applications 2>/dev/null
gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor 2>/dev/null
```

Or use this single command:

```bash
rm -rf ~/Games/ut2004 ~/.local/share/applications/ut2004.desktop ~/.local/share/icons/hicolor/*/apps/ut2004.png && update-desktop-database ~/.local/share/applications 2>/dev/null && gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor 2>/dev/null
```

### Troubleshooting

#### Game won't start

Try running directly from terminal to see errors:
```bash
cd ~/Games/ut2004/System
./ut2004-bin
```

#### Missing libraries error

Reinstall 32-bit dependencies:
```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install --reinstall libsdl1.2debian:i386 libopenal1:i386 libstdc++5:i386
```

#### Sound issues

Check if OpenAL is correctly linked:
```bash
ls -la ~/Games/ut2004/System/openal.so
```

If it doesn't exist, copy manually:
```bash
cp /usr/lib/i386-linux-gnu/libopenal.so.1 ~/Games/ut2004/System/openal.so
```

#### Script can't find setup.exe

Make sure that:
- The file exists at the specified path
- You have read permissions
- The path doesn't contain problematic special characters

---

## 📝 License

This installer script is provided as-is for educational purposes. Unreal Tournament 2004 is © Epic Games, Inc. You must own a legitimate copy of the game to use this installer.

## 🤝 Contributing

Feel free to open issues or submit pull requests with improvements!

## ⚠️ Disclaimer

This script is not affiliated with, endorsed by, or connected to Epic Games, GOG, or Steam. It is a community tool to help Linux users install their legally purchased copies of UT2004.
