#!/usr/bin/env bash

set -e

echo "=== Configurador de ambiente Java 17 LTS + Maven + IntelliJ IDEA Community (Debian 11) ==="

# Detectar distribuição
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    DISTRO=$(uname -s)
fi

echo "Detectado: $DISTRO"

# Atualizar pacotes
echo "Atualizando repositórios..."
sudo apt update -y
sudo apt upgrade -y

# Instalar dependências básicas
sudo apt install -y wget curl gnupg apt-transport-https software-properties-common

# Instalar OpenJDK 17
echo "Instalando OpenJDK 17 LTS..."
if ! java -version &>/dev/null; then
    sudo apt install -y openjdk-17-jdk
else
    echo "Java 17 já instalado."
fi

# Instalar Maven
echo "Instalando Maven..."
if ! mvn -v &>/dev/null; then
    sudo apt install -y maven
else
    echo "Maven já instalado."
fi

# Instalar IntelliJ IDEA Community
echo "Instalando IntelliJ IDEA Community Edition..."

# Verificar se Snap está disponível
if ! command -v snap &>/dev/null; then
    echo "Snap não encontrado. Instalando snapd..."
    sudo apt install -y snapd
    sudo systemctl enable --now snapd.socket
    sudo ln -s /var/lib/snapd/snap /snap || true
fi

# Corrigir possíveis conflitos de AppArmor no Debian 11
sudo systemctl restart apparmor || true

# Instalar IntelliJ via Snap
sudo snap install intellij-idea-community --classic

# Configurar variáveis de ambiente
echo "Configurando variáveis de ambiente..."
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
MAVEN_HOME=$(dirname $(dirname $(readlink -f $(which mvn))))

PROFILE_FILE="$HOME/.bashrc"
if [ -f "$HOME/.zshrc" ]; then
    PROFILE_FILE="$HOME/.zshrc"
fi

# Evitar duplicação das variáveis
grep -q "JAVA_HOME" "$PROFILE_FILE" || {
    {
        echo ""
        echo "# Configuração Java & Maven"
        echo "export JAVA_HOME=$JAVA_HOME"
        echo "export M2_HOME=$MAVEN_HOME"
        echo "export PATH=\$PATH:\$JAVA_HOME/bin:\$M2_HOME/bin"
    } >> "$PROFILE_FILE"
}

# Aplicar alterações
source "$PROFILE_FILE"

echo ""
echo "=== Instalação concluída com sucesso! ==="
echo ""
echo "Java version:"
java -version
echo ""
echo "Maven version:"
mvn -version
echo ""
echo "Para abrir o IntelliJ IDEA Community, use o comando:"
echo "intellij-idea-community"
