Aqui está uma versão melhorada da documentação, mais organizada e com informações mais claras:

# Configuração de Autenticação OAuth2 Google no SonarQube

## Pré-requisitos
- Acesso administrativo ao SonarQube
- Conta Google com acesso ao Google Cloud Console

## 1. Instalação do Plugin
1. Acesse o SonarQube como administrador
2. Navegue até a seção de Marketplace:
   - URL: `http://localhost:9000/admin/marketplace?search=open`
3. Instale o plugin:
   - **OpenID Connect Authentication for SonarQube** (versão 2.1.1 ou superior)

## 2. Configuração no Google Cloud Console
1. Acesse o [Google Cloud Console](https://console.cloud.google.com/)
2. Navegue até "APIs e Serviços" > "Credenciais"
3. Crie um novo cliente OAuth:
   - Tipo de aplicativo: "Aplicativo da Web"
4. Configure as URIs de redirecionamento:
   ```
   URIs autorizados: http://localhost:9000/oauth2/callback/oidc
   Origens JavaScript autorizadas: http://localhost:9000
   ```
5. Anote as credenciais geradas:
   - Client ID
   - Client Secret

## 3. Configuração no SonarQube
Acesse a seção de segurança do SonarQube:
- URL: `http://localhost:9000/admin/settings?category=security`

Configure os seguintes parâmetros:

| Chave | Valor | Observação |
|-------|-------|------------|
| `sonar.auth.oidc.enabled` | `true` | Habilita autenticação OIDC |
| `sonar.auth.oidc.issuerUri` | `https://accounts.google.com` | Provedor OIDC |
| `sonar.auth.oidc.clientId.secured` | `<seu-client-id>` | Obtido no Google Cloud Console |
| `sonar.auth.oidc.clientSecret.secured` | `<seu-client-secret>` | Obtido no Google Cloud Console |
| `sonar.auth.oidc.loginStrategy` | `Same as OpenID Connect login` | Estratégia de login |
| `sonar.auth.oidc.iconPath` | `https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg` | Ícone do provedor |

## 4. Validação
1. Efetue logout da conta administrativa
2. Tente fazer login usando a opção Google
3. Verifique se o redirecionamento ocorre corretamente

## Solução de Problemas
- **Erro de redirecionamento**: Verifique se as URIs no Google Cloud Console coincidem exatamente com as do SonarQube
- **Problemas de autenticação**: Verifique se o plugin está na versão correta
- **Problemas de ícone**: Certifique-se que a URL do ícone está acessível

## Observações Importantes
- Mantenha as credenciais (Client ID e Secret) em local seguro
- Para ambientes de produção, substitua `localhost:9000` pelo domínio real do seu SonarQube
- Recomenda-se testar em ambiente de homologação antes de aplicar em produção





Provide a token
Analyze "integrator-vcom": sqp_7dcd169ad0a2a840a04b4b5ffa9e16a98d3f7716


docker run --rm \
  -e SONAR_HOST_URL="http://localhost:9000" \
  -e SONAR_LOGIN="sqp_7dcd169ad0a2a840a04b4b5ffa9e16a98d3f7716" \
  -v "$(pwd):/usr/src" \
  sonarsource/sonar-scanner-cli:latest \
  -Dsonar.projectKey=integrator-vcom \
  -Dsonar.sources=. \
  -Dsonar.scm.provider=git \
  -Dsonar.sourceEncoding=UTF-8