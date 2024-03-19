#!/bin/bash

# Definindo cores
vermelho='\033[0;31m'
verde='\033[0;32m'
sem_cor='\033[0m'
# Função para exibir o banner
exibir_banner() {
    echo -e "${verde}"
    echo "             (    (                 )      )   (      "  
    echo "    (  (      )\ ) )\ )    *   )  ( /(   ( /(   )\ )  " 
    echo "    )\))(   (()/((()/(   )  /(  )\())  )\()) (()/(  "
    echo "   ((_)()\ )  /(_))/(_))  ( )(_))((_)\  ((_)\   /(_)) "
    echo "  _(())\_)()(_)) (_))   (_(_())   ((_)   ((_) (_))    "  
    echo "  \ \((_)/ // __|/ __|  |_   _|  / _ \  / _ \ | |     "
    echo "   \ \/\/ / \__ \\__ \    | |   | (_) || (_) || |__   "
    echo "    \_/\_/  |___/|___/    |_|    \___/  \___/ |____|  "
    echo "   ____       _   _            _     _ _              "
    echo -e "${verde}"
    echo "==============================================================="
    echo "                 Bem vindo a WSS Pentest Tool                  "
    echo "==============================================================="
    echo "   Script desenvolvido por Luciano V, Italo O, Carol G         "
    echo "==============================================================="
    echo -e "${verde}"
}

exibir_banner

#Função para montar a estrutura de diretórios
monta_diretorios() {
    mkdir -p subdominios temp network/scans_ip network/directories osint/data_leaks osint/google_dork vuls/info vuls/low vuls/medium vuls/hard vuls/critical
}

# Chamar a função para exibir o banner


##testconnectivity

#Chamar a função para montar a estrutura de diretórios
monta_diretorios

# Verifica se o subfinder está instalado
if ! command -v subfinder &> /dev/null; then
    echo "${vermelho}[!] Subfinder não está instalado. Por favor, instale-o primeiro."
    exit 1
fi

# Solicita ao usuário a inserção da URL para enumerar subdomínios
read -p "${verde}[!] Insira a URL para enumerar subdomínios: " input_url

# Mostra a mensagem "Enumerando subdomínios..."
echo -e "${verde}[!] Enumerando subdomínios de $input_url"

# Utiliza o subfinder para buscar os subdomínios da URL
subdomains=$(subfinder -d "$input_url" | assetfinder -subs-only -t 100)
echo "$subdomains" >> temp/subdomains_full.txt
# Testa se foram encontrados subdomínios para a URL informada
if [ -z "$subdomains" ]; then
    echo "Nenhum subdomínio encontrado para $input_url"
else
    echo "${verde}[!] Buscando subdominios..."
    # Grava os subdomínios no arquivo subdomains.txt
    echo "$subdomains" >> temp/subdomains_full.txt
fi 

# Filtra os subdomínios duplicados
cat temp/subdomains_full.txt | anew > subdominios/subdomains_full.txt

# Verifica se o comando httpx está disponível
if ! command -v httpx &> /dev/null; then
    echo "${vermelho}[!] Httpx não está instalado. Por favor, instale-o primeiro."
    exit 1
fi

# Verifica os subdomínios ativos e grava no arquivo subdomains_live.txt
httpx -status-code -mc 200 < subdominios/subdomains_full.txt >> subdominios/subdomains_live.txt

# Verifica se o comando naabu está disponível
if ! command -v naabu &> /dev/null; then
    echo "${vermelho}[!] Naabu não está instalado. Por favor, instale-o primeiro."
    exit 1
fi

# Executa o scanner de portas naabu nos subdomínios ativos
naabu -l subdominios/subdomains_live.txt -v -o network/scans_ip/scan_ports.txt

#enumerar diretorios e arquivos
if ! command -v gobuster

while read subdominios/subdomains_live.txt; do 
    gobuster dir -u subdomain
done <network/directories.txt

#nuclei
if ! command -v nuclei &> /dev/null; then
    echo "Nuclei não está instalado. Por favor, instale-o primeiro."
    exit 1
fi

nuclei -l subdominios/subdomains_live.txt -t nuclei-templates/ -o vuls/nuclei_results.txt

echo "${vermelho}[!] Detecção de vulnerabilidades concluída. Resultados gravados em 'nuclei_results.txt'."

rm -rf temp
