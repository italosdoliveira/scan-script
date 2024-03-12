#!/bin/bash

# Função para exibir o banner
exibir_banner() {
    echo -e "\e[1;34m"
    echo "             (    (                 )      )   (      "  
    echo "    (  (      )\ ) )\ )    *   )  ( /(   ( /(   )\ )  " 
    echo "    )\))(   (()/((()/(   )  /(  )\())  )\()) (()/(  "
    echo "   ((_)()\ )  /(_))/(_))  ( )(_))((_)\  ((_)\   /(_)) "
    echo "  _(())\_)()(_)) (_))   (_(_())   ((_)   ((_) (_))    "  
    echo "  \ \((_)/ // __|/ __|  |_   _|  / _ \  / _ \ | |     "
    echo "   \ \/\/ / \__ \\__ \    | |   | (_) || (_) || |__   "
    echo "    \_/\_/  |___/|___/    |_|    \___/  \___/ |____|  "
    echo "   ____       _   _            _     _ _              "
    echo -e "\e[0m"
    echo "==============================================================="
    echo "                 Bem vindo a WSS Pentest Tool                  "
    echo "==============================================================="
    echo "   Script desenvolvido por Bonde da WSS                        "
    echo "==============================================================="
}

# Chamar a função para exibir o banner
exibir_banner

# Verifica se o subfinder está instalado
if ! command -v subfinder &> /dev/null; then
    echo "Subfinder não está instalado. Por favor, instale-o primeiro."
    exit 1
fi

# Solicita ao usuário a inserção da URL para enumerar subdomínios
read -p "Insira a URL para enumerar subdomínios: " input_url

# Mostra a mensagem "Enumerando subdomínios..."
echo "Enumerando subdomínios para $input_url"

# Utiliza o subfinder para buscar os subdomínios da URL
subdomains=$(subfinder -d "$input_url" -silent)

# Testa se foram encontrados subdomínios para a URL informada
if [ -z "$subdomains" ]; then
    echo "Nenhum subdomínio encontrado para $input_url"
else
    echo "Subdomínios encontrados para $input_url:"
    echo "$subdomains"
fi 

# Grava os subdomínios no arquivo subdomains.txt
echo "$subdomains" >> "subdomains.txt"

# Extrai os subdomínios separados
curl -s "https://crt.sh/?q=%.$input_url&output=json" | jq -r '.[] | select(.name_value | test("^[^*]+\\.'$input_url'$")) | .name_value' | sed 's/\*\.//' > subdomains_separated.txt
cat subdomains.txt | tr ' ' '\n' >> subdomains_separated.txt

# Filtra os subdomínios duplicados
cat subdomains_separated.txt | sort -u > subdomains_filter.txt

# Verifica se o comando httpx está disponível
if ! command -v httpx &> /dev/null; then
    echo "httpx não está instalado. Por favor, instale-o primeiro."
    exit 1
fi

# Verifica os subdomínios ativos e grava no arquivo subdomains_live.txt
httpx -status-code -mc 200 < subdomains_filter.txt >> subdomains_live.txt

# Extrai apenas os nomes de domínio dos URLs
awk '{gsub("^https?://", "", $1); split($1, arr, "/"); print arr[1]}' subdomains_live.txt > filtrados.txt

# Verifica se o comando naabu está disponível
if ! command -v naabu &> /dev/null; then
    echo "naabu não está instalado. Por favor, instale-o primeiro."
    exit 1
fi

# Executa o scanner de portas naabu nos subdomínios ativos
naabu -l filtrados.txt -v -o scan_ports.txt