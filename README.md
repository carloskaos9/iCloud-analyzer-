# Wi-Fi Analyzer Pro - iOS App

Aplicação nativa para iOS que oferece análise avançada de redes Wi-Fi, testes de velocidade em tempo real e monitoramento de conexão.

## Requisitos

- **iOS 16.0+**
- **Xcode 15.0+**
- **Swift 5.9+**
- **macOS 13.0+** (para compilação)

## Funcionalidades

### 🌐 Monitoramento de Rede
- Detecção automática de tipo de conexão (Wi-Fi, Celular, Ethernet)
- Identificação de geração de rede (4G, 5G, LTE)
- Monitoramento de latência em tempo real
- Força de sinal Wi-Fi
- Endereço IP local e público

### ⚡ Teste de Velocidade Real
- Download real com arquivos de teste
- Upload real com dados de teste
- Medição de latência (ping)
- Histórico de velocidade com gráficos
- Progresso visual durante testes

### 📡 Análise de Redes
- Escanear redes Wi-Fi disponíveis
- Detectar força de sinal de cada rede
- Identificar tipo de segurança (WPA3, WPA2, etc)
- Listar dispositivos conectados na rede

### 📍 Geolocalização
- Localização GPS em tempo real
- Geocodificação reversa (cidade, país)
- Coordenadas precisas

### 🎨 Interface Otimizada para iPhone
- Design responsivo e intuitivo
- Navegação por abas
- Temas claros e escuros
- Compatível com Face ID e Touch ID

## Instalação

### 1. Clonar o Repositório
```bash
git clone https://github.com/carloskaos9/iCloud-analyzer-.git
cd WiFiAnalyzerPro
```

### 2. Abrir no Xcode
```bash
open WiFiAnalyzerPro.xcodeproj
```

### 3. Configurar Assinatura
- Selecione o projeto no Xcode
- Vá para "Signing & Capabilities"
- Selecione sua equipe de desenvolvimento
- Configure o Bundle Identifier

### 4. Compilar e Executar
- Selecione um simulador ou dispositivo
- Pressione `Cmd + R` para compilar e executar

## Permissões Necessárias

O app requer as seguintes permissões:

### NSLocationWhenInUseUsageDescription
Necessária para obter a localização do usuário e fornecer análise de rede precisa.

### NSLocalNetworkUsageDescription
Necessária para escanear redes Wi-Fi próximas e detectar dispositivos conectados.

### NSBonjourServices
Necessária para descoberta de serviços na rede local.

## Estrutura do Projeto

```
WiFiAnalyzerPro/
├── WiFiAnalyzerApp.swift          # Ponto de entrada do app
├── ContentView.swift               # View principal com navegação por abas
├── NetworkManager.swift            # Gerenciamento de informações de rede
├── SpeedTestManager.swift          # Lógica de teste de velocidade
├── LocationManager.swift           # Gerenciamento de localização
├── Assets.xcassets                # Ícones e imagens
└── Preview Content/               # Conteúdo de preview
```

## APIs Utilizadas

### Network Framework
- `NWPathMonitor` - Monitoramento de conexão de rede
- `NWPath` - Informações sobre tipo de conexão

### CoreLocation
- `CLLocationManager` - Gerenciamento de localização
- `CLGeocoder` - Geocodificação reversa

### CoreTelephony
- `CTTelephonyNetworkInfo` - Informações de rede celular
- `CTCellularData` - Dados de rede celular

### URLSession
- Download/Upload de arquivos para teste de velocidade
- Requisições HTTP para APIs externas

## Segurança

- ✅ Sem armazenamento de dados sensíveis
- ✅ Sem rastreamento de usuário
- ✅ Sem coleta de dados pessoais
- ✅ Permissões mínimas necessárias
- ✅ Criptografia de dados em trânsito

## Compilação para Release

### 1. Preparar o Build
```bash
# Limpar build
xcodebuild clean -project WiFiAnalyzerPro.xcodeproj

# Build para release
xcodebuild -project WiFiAnalyzerPro.xcodeproj \
  -scheme WiFiAnalyzerPro \
  -configuration Release \
  -derivedDataPath build
```

### 2. Gerar Archive
```bash
xcodebuild -project WiFiAnalyzerPro.xcodeproj \
  -scheme WiFiAnalyzerPro \
  -configuration Release \
  -archivePath build/WiFiAnalyzerPro.xcarchive \
  archive
```

### 3. Exportar para Distribuição
Use o Xcode Organizer para exportar o archive e distribuir via TestFlight ou App Store.

## Troubleshooting

### Erro: "Cannot find module in scope"
- Limpe o build: `Cmd + Shift + K`
- Feche e reabra o Xcode

### Erro: "Code signing failed"
- Verifique as credenciais de desenvolvimento
- Atualize o certificado no Keychain

### Erro: "Permission denied"
- Verifique as permissões no Info.plist
- Solicite permissões ao usuário

## Desenvolvimento Futuro

- [ ] Integração com HealthKit para monitoramento de saúde da rede
- [ ] Background monitoring com notificações
- [ ] Exportação de relatórios em PDF
- [ ] Sincronização com iCloud
- [ ] Modo escuro aprimorado
- [ ] Suporte a Widgets

## Licença

Este projeto é privado e destinado apenas para uso pessoal.

## Contato

Para sugestões ou relatórios de bugs, entre em contato com o desenvolvedor.

---

**Desenvolvido com ❤️ para iOS 16+**
