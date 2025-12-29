#!/bin/bash

# UT2004 Installer - Legal Version
# Instalador UT2004 - Versão Legal
# User must provide their own game files
# Usuário deve fornecer seus próprios arquivos do jogo

# Função para debug
debug_msg() {
    echo -e "\n[DEBUG] $1" >&2
}

# Trap para capturar erros
trap 'echo -e "\n[ERRO NA LINHA $LINENO] Pressione ENTER para ver detalhes..."; read' ERR

# Detecção automática do idioma do sistema
if [[ "$LANG" =~ ^pt ]]; then
    LANG_MODE="pt"
else
    LANG_MODE="en"
fi

# Função para mensagens bilíngues
msg() {
    if [ "$LANG_MODE" = "pt" ]; then
        echo -e "\n[INFO] $1" >&2
    else
        echo -e "\n[INFO] $2" >&2
    fi
}

error_msg() {
    if [ "$LANG_MODE" = "pt" ]; then
        echo -e "\n[ERRO] $1" >&2
    else
        echo -e "\n[ERROR] $2" >&2
    fi
}

success_msg() {
    if [ "$LANG_MODE" = "pt" ]; then
        echo -e "\n[SUCESSO] $1" >&2
    else
        echo -e "\n[SUCCESS] $2" >&2
    fi
}

# Função para solicitar CD Key
ask_cdkey() {
    if [ "$LANG_MODE" = "pt" ]; then
        echo -e "\n===================================="
        echo "Digite sua CD Key do UT2004:"
        echo "(Formato: XXXXX-XXXXX-XXXXX-XXXXX)"
        echo "===================================="
    else
        echo -e "\n===================================="
        echo "Enter your UT2004 CD Key:"
        echo "(Format: XXXXX-XXXXX-XXXXX-XXXXX)"
        echo "===================================="
    fi
    read -p "> " CDKEY
    
    if [ -z "$CDKEY" ]; then
        error_msg "CD Key não pode estar vazia!" "CD Key cannot be empty!"
        exit 1
    fi
}

# Função para solicitar caminho do jogo
ask_game_path() {
    if [ "$LANG_MODE" = "pt" ]; then
        echo -e "\n======================================================="
        echo "Indique o caminho para os arquivos do UT2004:"
        echo ""
        echo "Você pode fornecer:"
        echo "  1) Arquivo ISO (será montado automaticamente)"
        echo "  2) Arquivo RAR ou 7Z compactado"
        echo "  3) Pasta com os arquivos extraídos"
        echo "  4) Arquivo setup.exe do instalador"
        echo ""
        echo "Exemplos:"
        echo "  /home/user/Downloads/ut2004.iso"
        echo "  /home/user/Downloads/ut2004.rar"
        echo "  /home/user/Games/UT2004_Files/"
        echo "  ~/Downloads/setup.exe"
        echo ""
        echo "Dica: Você pode arrastar o arquivo/pasta para o terminal"
        echo "======================================================="
    else
        echo -e "\n======================================================="
        echo "Provide the path to your UT2004 files:"
        echo ""
        echo "You can provide:"
        echo "  1) ISO file (will be mounted automatically)"
        echo "  2) RAR or 7Z compressed file"
        echo "  3) Folder with extracted files"
        echo "  4) setup.exe installer file"
        echo ""
        echo "Examples:"
        echo "  /home/user/Downloads/ut2004.iso"
        echo "  /home/user/Downloads/ut2004.rar"
        echo "  /home/user/Games/UT2004_Files/"
        echo "  ~/Downloads/setup.exe"
        echo ""
        echo "Tip: You can drag the file/folder into the terminal"
        echo "======================================================="
    fi
    read -r -p "> " GAME_PATH
    
    # Remover espaços no início e fim
    GAME_PATH=$(echo "$GAME_PATH" | xargs)
    
    # Remover aspas se existirem (quando arrasta arquivo)
    GAME_PATH="${GAME_PATH//\'/}"
    GAME_PATH="${GAME_PATH//\"/}"
    
    # Expandir ~ para home directory
    GAME_PATH="${GAME_PATH/#\~/$HOME}"
    
    debug_msg "Caminho processado: $GAME_PATH"
    debug_msg "Verificando se existe..."
    
    if [ ! -e "$GAME_PATH" ]; then
        error_msg "Caminho não existe: $GAME_PATH" "Path does not exist: $GAME_PATH"
        
        # Mostrar diretório atual para ajudar
        echo ""
        echo "Diretório atual: $(pwd)"
        echo ""
        
        # Tentar com caminho relativo
        if [ -e "./$GAME_PATH" ]; then
            GAME_PATH="./$GAME_PATH"
            msg "Caminho relativo encontrado!" "Relative path found!"
        else
            echo "Pressione ENTER para tentar novamente..."
            read
            ask_game_path
            return
        fi
    fi
    
    msg "Caminho válido encontrado!" "Valid path found!"
}

# Função para montar ISO
mount_iso() {
    local iso_file="$1"
    local mount_point="$TEMP_DIR/iso_mount"
    
    msg "Montando arquivo ISO..." "Mounting ISO file..."
    mkdir -p "$mount_point"
    
    sudo mount -o loop "$iso_file" "$mount_point" || {
        error_msg "Falha ao montar ISO." "Failed to mount ISO."
        exit 1
    }
    
    echo "$mount_point"
}

# Função para desmontar ISO
unmount_iso() {
    local mount_point="$1"
    
    if [ -d "$mount_point" ]; then
        msg "Desmontando ISO..." "Unmounting ISO..."
        sudo umount "$mount_point" 2>/dev/null || true
        rmdir "$mount_point" 2>/dev/null || true
    fi
}

# Função para extrair arquivo compactado
extract_archive() {
    local archive_file="$1"
    local extract_dir="$TEMP_DIR/extracted_archive"
    
    mkdir -p "$extract_dir"
    
    # Detectar tipo de arquivo
    local file_ext="${archive_file##*.}"
    file_ext=$(echo "$file_ext" | tr '[:upper:]' '[:lower:]')
    
    case "$file_ext" in
        rar)
            msg "Extraindo arquivo RAR..." "Extracting RAR file..."
            if command -v unrar &> /dev/null; then
                unrar x -o+ "$archive_file" "$extract_dir/" || {
                    error_msg "Falha ao extrair RAR." "Failed to extract RAR."
                    exit 1
                }
            else
                7z x "$archive_file" -o"$extract_dir" -y || {
                    error_msg "Falha ao extrair RAR." "Failed to extract RAR."
                    exit 1
                }
            fi
            ;;
        7z|zip)
            msg "Extraindo arquivo compactado..." "Extracting compressed file..."
            7z x "$archive_file" -o"$extract_dir" -y || {
                error_msg "Falha ao extrair arquivo." "Failed to extract file."
                exit 1
            }
            ;;
        *)
            error_msg "Formato de arquivo não suportado: $file_ext" "Unsupported file format: $file_ext"
            exit 1
            ;;
    esac
    
    echo "$extract_dir"
}

# Função para encontrar arquivo setup
find_setup_file() {
    local search_dir="$1"
    
    msg "Procurando arquivo setup.exe..." "Searching for setup.exe..."
    debug_msg "Buscando em: $search_dir"
    
    # Buscar recursivamente (com aspas para suportar espaços)
    local setup_file=$(find "$search_dir" -type f -iname "setup*.exe" 2>/dev/null | head -n 1 | tr -d '\n\r')
    
    # Remover espaços extras do resultado
    setup_file=$(echo "$setup_file" | xargs)
    
    if [ -z "$setup_file" ]; then
        error_msg "Arquivo setup.exe não encontrado em: $search_dir" "setup.exe not found in: $search_dir"
        echo "" >&2
        echo "Arquivos .exe encontrados:" >&2
        find "$search_dir" -type f -iname "*.exe" 2>/dev/null >&2 || echo "Nenhum arquivo .exe encontrado" >&2
        echo "" >&2
        echo "Conteúdo do diretório (primeiros 50 itens):" >&2
        ls -laR "$search_dir" 2>/dev/null | head -50 >&2
        echo "" >&2
        echo "Pressione ENTER para continuar..." >&2
        read
        exit 1
    fi
    
    # Retornar APENAS o caminho (sem nenhuma mensagem)
    echo "$setup_file"
}

# Variáveis
PATCH_URL="https://unreal-archive-files.eu-central-1.linodeobjects.com/patches-updates/Unreal%20Tournament%202004/Patches/ut2004-lnxpatch3369-2.tar.bz2"
INSTALL_DIR="$HOME/Games/ut2004"
TEMP_DIR="/tmp/ut2004_install"
ISO_MOUNT_POINT=""

# Banner
clear
echo "=============================================="
if [ "$LANG_MODE" = "pt" ]; then
    echo "  Instalador UT2004 - Versão Legal"
    echo "  Para sistemas Linux modernos"
    echo ""
    echo "  Você deve possuir uma cópia legítima"
    echo "  do jogo para usar este instalador"
else
    echo "  UT2004 Installer - Legal Version"
    echo "  For modern Linux systems"
    echo ""
    echo "  You must own a legitimate copy"
    echo "  of the game to use this installer"
fi
echo "=============================================="

# Verificar se está rodando como root
if [ "$EUID" -eq 0 ]; then 
    error_msg "Não execute este script como root!" "Do not run this script as root!"
    exit 1
fi

# Solicitar informações do usuário
ask_cdkey
ask_game_path

# Criar diretórios
msg "Criando diretórios necessários..." "Creating necessary directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Instalar dependências
msg "Instalando dependências do sistema..." "Installing system dependencies..."
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y wget p7zip-full p7zip-rar unrar innoextract libsdl1.2debian:i386 libopenal1:i386 libstdc++5:i386 imagemagick || {
    error_msg "Falha ao instalar dependências. Verifique sua conexão e repositórios." "Failed to install dependencies. Check your connection and repositories."
    exit 1
}

# Processar o caminho fornecido pelo usuário
WORK_DIR=""
SETUP_FILE=""

debug_msg "Analisando tipo de arquivo/pasta..."
debug_msg "Caminho: $GAME_PATH"

if [ -f "$GAME_PATH" ]; then
    # É um arquivo
    debug_msg "Detectado como arquivo"
    
    file_ext="${GAME_PATH##*.}"
    file_ext=$(echo "$file_ext" | tr '[:upper:]' '[:lower:]')
    
    debug_msg "Extensão detectada: $file_ext"
    
    case "$file_ext" in
        iso)
            msg "Detectado: Arquivo ISO" "Detected: ISO file"
            # Montar ISO
            ISO_MOUNT_POINT=$(mount_iso "$GAME_PATH")
            WORK_DIR="$ISO_MOUNT_POINT"
            ;;
        rar|7z|zip)
            msg "Detectado: Arquivo compactado ($file_ext)" "Detected: Compressed file ($file_ext)"
            # Extrair arquivo compactado
            WORK_DIR=$(extract_archive "$GAME_PATH")
            ;;
        exe)
            msg "Detectado: Arquivo executável (setup.exe)" "Detected: Executable file (setup.exe)"
            # É diretamente o setup.exe
            SETUP_FILE="$GAME_PATH"
            ;;
        *)
            error_msg "Tipo de arquivo não reconhecido: $file_ext" "Unrecognized file type: $file_ext"
            echo "Tipos suportados: .iso, .rar, .7z, .zip, .exe"
            exit 1
            ;;
    esac
elif [ -d "$GAME_PATH" ]; then
    # É uma pasta
    debug_msg "Detectado como pasta"
    msg "Detectado: Pasta com arquivos" "Detected: Folder with files"
    WORK_DIR="$GAME_PATH"
else
    error_msg "Caminho inválido ou tipo desconhecido: $GAME_PATH" "Invalid path or unknown type: $GAME_PATH"
    exit 1
fi

# Encontrar arquivo setup se ainda não foi definido
if [ -z "$SETUP_FILE" ]; then
    debug_msg "Procurando setup.exe em: $WORK_DIR"
    SETUP_FILE=$(find_setup_file "$WORK_DIR")
    # Limpar espaços e quebras de linha
    SETUP_FILE=$(echo "$SETUP_FILE" | xargs)
fi

# Verificar novamente se SETUP_FILE foi definido corretamente
if [ -z "$SETUP_FILE" ]; then
    error_msg "SETUP_FILE está vazio!" "SETUP_FILE is empty!"
    exit 1
fi

debug_msg "SETUP_FILE após limpeza: '$SETUP_FILE'"

# Verificar se o arquivo existe
if [ ! -f "$SETUP_FILE" ]; then
    error_msg "Arquivo não existe: '$SETUP_FILE'" "File does not exist: '$SETUP_FILE'"
    echo "Tentando verificar com ls:"
    ls -lah "$SETUP_FILE" 2>&1 || echo "ls falhou"
    exit 1
fi

msg "Encontrado: $(basename "$SETUP_FILE")" "Found: $(basename "$SETUP_FILE")"
debug_msg "Caminho completo: '$SETUP_FILE'"
debug_msg "Tamanho do arquivo: $(du -h "$SETUP_FILE" 2>/dev/null | cut -f1)"

# Extrair com innoextract
msg "Extraindo arquivos do instalador..." "Extracting files from installer..."
cd "$TEMP_DIR"

# Verificar se arquivo existe antes de processar
if [ ! -f "$SETUP_FILE" ]; then
    error_msg "Arquivo não encontrado: $SETUP_FILE" "File not found: $SETUP_FILE"
    exit 1
fi

debug_msg "Testando innoextract com listagem primeiro..."
innoextract -l "$SETUP_FILE" || {
    error_msg "innoextract não consegue ler o arquivo." "innoextract cannot read the file."
    echo "Caminho do arquivo: '$SETUP_FILE'"
    echo "Tamanho: $(du -h "$SETUP_FILE" 2>/dev/null || echo 'N/A')"
    echo "Pressione ENTER para continuar..."
    read
    exit 1
}

debug_msg "Iniciando extração real com innoextract..."
innoextract -s -p -d "$TEMP_DIR/extracted" "$SETUP_FILE" 2>&1 | tee innoextract.log || {
    error_msg "Falha ao extrair com innoextract. Tentando método alternativo..." "Failed to extract with innoextract. Trying alternative method..."
    
    innoextract -s -p -m -d "$TEMP_DIR/extracted" "$SETUP_FILE" 2>&1 | tee innoextract_alt.log || {
        error_msg "Falha crítica na extração." "Critical extraction failure."
        echo "Pressione ENTER para continuar..."
        read
        exit 1
    }
}

debug_msg "Extração do innoextract concluída. Listando estrutura..."
ls -lah "$TEMP_DIR/extracted" || true

# Desmontar ISO se foi montado
if [ -n "$ISO_MOUNT_POINT" ]; then
    unmount_iso "$ISO_MOUNT_POINT"
fi

# Mover arquivos para diretório de instalação
msg "Movendo arquivos para $INSTALL_DIR..." "Moving files to $INSTALL_DIR..."

if [ -d "$TEMP_DIR/extracted/app" ]; then
    debug_msg "Copiando de extracted/app/"
    cp -rv "$TEMP_DIR/extracted/app/"* "$INSTALL_DIR/"
elif [ -d "$TEMP_DIR/extracted/tmp" ]; then
    debug_msg "Copiando de extracted/tmp/"
    cp -rv "$TEMP_DIR/extracted/tmp/"* "$INSTALL_DIR/"
else
    debug_msg "Estrutura diferente, copiando todas as subpastas"
    find "$TEMP_DIR/extracted" -mindepth 1 -maxdepth 1 -type d -exec cp -rv {} "$INSTALL_DIR/" \;
fi

# Criar arquivo cdkey
msg "Criando arquivo de CD Key..." "Creating CD Key file..."
mkdir -p "$INSTALL_DIR/System"
echo "$CDKEY" > "$INSTALL_DIR/System/cdkey"

# Baixar e aplicar patch Linux
if [ ! -f "$TEMP_DIR/patch.tar.bz2" ]; then
    msg "Baixando patch Linux 3369-2..." "Downloading Linux patch 3369-2..."
    wget -c "$PATCH_URL" -O "$TEMP_DIR/patch.tar.bz2" || {
        error_msg "Falha ao baixar o patch." "Failed to download the patch."
        exit 1
    }
fi

msg "Aplicando patch Linux..." "Applying Linux patch..."
tar -xjf "$TEMP_DIR/patch.tar.bz2" -C "$TEMP_DIR/"

msg "Mesclando arquivos do patch..." "Merging patch files..."
cp -rf "$TEMP_DIR/UT2004-Patch/"* "$INSTALL_DIR/" 2>/dev/null || true

# Corrigir libSDL
msg "Corrigindo biblioteca libSDL-1.2.so.0..." "Fixing libSDL-1.2.so.0 library..."
if [ -f "/usr/lib/i386-linux-gnu/libSDL-1.2.so.0" ]; then
    cp /usr/lib/i386-linux-gnu/libSDL-1.2.so.0 "$INSTALL_DIR/System/"
elif [ -f "/usr/lib32/libSDL-1.2.so.0" ]; then
    cp /usr/lib32/libSDL-1.2.so.0 "$INSTALL_DIR/System/"
fi

# Corrigir OpenAL
msg "Corrigindo biblioteca OpenAL..." "Fixing OpenAL library..."
for openal_path in \
    "/usr/lib/i386-linux-gnu/libopenal.so.1" \
    "/usr/lib32/libopenal.so.1" \
    "/usr/lib/i386-linux-gnu/libopenal.so.1.23.1" \
    "/usr/lib32/libopenal.so.1.23.1"
do
    if [ -f "$openal_path" ]; then
        cp "$openal_path" "$INSTALL_DIR/System/openal.so"
        break
    fi
done

# Criar script de inicialização
msg "Criando script de inicialização..." "Creating launcher script..."
cat > "$INSTALL_DIR/ut2004" << 'EOF'
#!/bin/sh
FindPath()
{
    fullpath=`echo $1 | grep /`
    if [ "$fullpath" = "" ]; then
        oIFS="$IFS"
        IFS=:
        for path in $PATH
        do if [ -x "$path/$1" ]; then
               if [ "$path" = "" ]; then
                   path="."
               fi
               fullpath="$path/$1"
               break
           fi
        done
        IFS="$oIFS"
    fi
    if [ "$fullpath" = "" ]; then
        fullpath="$1"
    fi
    if [ -L "$fullpath" ]; then
        fullpath=`ls -l "$fullpath" |sed -e 's/.* -> //' |sed -e 's/\*//'`
    fi
    dirname $fullpath
}
if [ "${UT2004_DATA_PATH}" = "" ]; then
    UT2004_DATA_PATH=`FindPath $0`/System
fi
LD_LIBRARY_PATH=.:${UT2004_DATA_PATH}:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH
if [ -x "${UT2004_DATA_PATH}/ut2004-bin" ]
then
	cd "${UT2004_DATA_PATH}/"
	exec "./ut2004-bin" $*
fi
echo "Couldn't run Unreal Tournament 2004 (ut2004-bin). Is UT2004_DATA_PATH set?"
exit 1
EOF

chmod +x "$INSTALL_DIR/ut2004"

# Converter e copiar ícone
msg "Convertendo e instalando ícone..." "Converting and installing icon..."
if [ -f "$INSTALL_DIR/Help/Unreal.ico" ]; then
    convert "$INSTALL_DIR/Help/Unreal.ico[0]" "$INSTALL_DIR/ut2004.png" 2>/dev/null || true
    
    mkdir -p "$HOME/.local/share/icons/hicolor/48x48/apps"
    mkdir -p "$HOME/.local/share/icons/hicolor/64x64/apps"
    mkdir -p "$HOME/.local/share/icons/hicolor/128x128/apps"
    
    if [ -f "$INSTALL_DIR/ut2004.png" ]; then
        convert "$INSTALL_DIR/ut2004.png" -resize 48x48 "$HOME/.local/share/icons/hicolor/48x48/apps/ut2004.png" 2>/dev/null || true
        convert "$INSTALL_DIR/ut2004.png" -resize 64x64 "$HOME/.local/share/icons/hicolor/64x64/apps/ut2004.png" 2>/dev/null || true
        convert "$INSTALL_DIR/ut2004.png" -resize 128x128 "$HOME/.local/share/icons/hicolor/128x128/apps/ut2004.png" 2>/dev/null || true
    fi
fi

# Criar atalho no menu
msg "Criando atalho no menu do sistema..." "Creating system menu shortcut..."
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/ut2004.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Unreal Tournament 2004
Comment=Unreal Tournament 2004
Exec=$INSTALL_DIR/ut2004
Icon=ut2004
Terminal=false
Categories=Game;ActionGame;
EOF

chmod +x "$HOME/.local/share/applications/ut2004.desktop"

update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

# Limpar arquivos temporários
msg "Limpando arquivos temporários..." "Cleaning up temporary files..."
cd "$HOME"
rm -rf "$TEMP_DIR"

# Mensagem final
success_msg "=============================================" "============================================="
if [ "$LANG_MODE" = "pt" ]; then
    echo "  INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
    echo ""
    echo "  Jogo instalado em: $INSTALL_DIR"
    echo ""
    echo "  Para jogar:"
    echo "  - Procure 'Unreal Tournament 2004' no menu"
    echo "  - Ou execute: $INSTALL_DIR/ut2004"
    echo ""
    echo "  Divirta-se!"
else
    echo "  INSTALLATION COMPLETED SUCCESSFULLY!"
    echo ""
    echo "  Game installed at: $INSTALL_DIR"
    echo ""
    echo "  To play:"
    echo "  - Search for 'Unreal Tournament 2004' in menu"
    echo "  - Or run: $INSTALL_DIR/ut2004"
    echo ""
    echo "  Have fun!"
fi
success_msg "=============================================" "============================================="
